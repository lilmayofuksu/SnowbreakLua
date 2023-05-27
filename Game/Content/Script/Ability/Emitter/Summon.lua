-- ========================================================
-- @File    : Summon.lua
-- @Brief   : 召唤物
-- @Author  : XiongHongJi
-- @Date    : 2019-09-02
-- ========================================================

---@class USkillEmitter_Summon:USkillEmitter
local Summon = Class()

function Summon:OnEmit()
    local CTs = self:GetSkillAnchorTransform()
    if CTs:Length() > 0 then
        local CT = CTs:Get(1);

        ---TODO : New skill info
        --- Param1 : 召唤物ID
        --- Param2 : 召唤物AI Id
        --- Param3 : 召唤物等级
        --- Param4 : 召唤物个数
        --- Param5 : 召唤物存在时长
        --- Param6 : 是否不会被选为目标
        --- Param7 : 最大数量
        --- Param8 : 召唤物等级是否和召唤者同步
        --- Param9 : 召唤物的特化技能
        --- Param10: 召唤物的特化属性
        --- Param11: 召唤物类型(0 : 正常，1:附属物(Exp : 召唤心脏))
        --- Param12: 召唤物生成位置控制
        --- Param13: 是否不需要Trace到NavMesh上（bool）
        --- Param14: 是否需要做障碍物检测（bool）
        --- Param15: 是否需要做寻路检测（bool）
        --- Param16: 是否使用场上角色队伍信息（bool）
        local SummonID = self:GetParamintValue(0)
        local SummonAI = self:GetParamintValue(1)
        local SummonLevel = self:GetParamintValue(2)
        local SummonNum = self:GetParamintValue(3)
        local SummonLife = self:GetParamfloatValueForLevel(4)
        local bIgnore = self:GetParamboolValue(5)
        local MaxNum = self:GetParamintValue(6)
        local ParamLength = self:GetParamLength()
        local LevelFollowSummoner = false;
        if ParamLength > 7 then
            LevelFollowSummoner =  self:GetParamboolValue(7)
        end
        local SpecificSkillIDs = UE4.TArray(UE4.int32);
        if ParamLength > 8 then
            SpecificSkillIDs =  self:GetParamInt32ArrayValue(8)
        end
        local SpecificAttributeID;
        if ParamLength > 9 then
            SpecificAttributeID =  self:GetParamintValue(9)
        end
        local SummonType = 0
        if ParamLength > 10 then
            SummonType=  self:GetParamintValue(10)
        end

        local SummonLocationControl = false;
        if ParamLength > 11 then
            SummonLocationControl = self:GetParamboolValue(11)
        end
        local DoNotSpawnOnNav = false;
        if ParamLength > 12 then
            DoNotSpawnOnNav = self:GetParamboolValue(12)
            print("DoNotSpawnOnNav Value is : ", DoNotSpawnOnNav)
            print("Emitter ID is : ",self:GetEmitterInfo().ID )
        end
        local bTraceObstacle = false;
        if ParamLength > 13 then
            bTraceObstacle = self:GetParamboolValue(13)
            -- print("bTraceObstacle Value is : ", bTraceObstacle)
            -- print("Emitter ID is : ",self:GetEmitterInfo().ID )
        end
        local bCheckNavPath = false;
        if ParamLength > 14 then
            bCheckNavPath = self:GetParamboolValue(14)
        end
        local bUseCurrentPlayerTeam = true;
        if ParamLength > 15 then
            bUseCurrentPlayerTeam = self:GetParamboolValue(15)
        end

        local CurrentPlayer = self:GetInstigator()
        if self:GetInstigator():GetCharacterController() and self:GetInstigator():GetCharacterController():K2_GetPawn() then 
            CurrentPlayer = self:GetInstigator():GetCharacterController():K2_GetPawn()
        end
        local SummonOwner = self:GetInstigator()
        if not CurrentPlayer or not SummonOwner then
            return UE4.EEmitterResult.Finish
        end
        for i = 1 , SummonNum do
            if self.QueryResults:Length() > (i - 1) then
                CT.Translation = self.QueryResults:Get(i).QueryPoint;
                print("Emitter Position")
            end
            -- UE4.UKismetSystemLibrary.DrawDebugSphere(self, CT.Translation, 50.0, 12, UE4.FLinearColor(1, 1, 0, 1), 5)
            if bTraceObstacle then
                local IgnoreActors = UE4.TArray(UE4.AActor);
                IgnoreActors:Add(SummonOwner);
                SummonOwner:GetAttachedActors(IgnoreActors, false);
                local OutHit = UE4.FHitResult();
                local bHit = UE4.UKismetSystemLibrary.LineTraceSingleByProfile(self, SummonOwner:K2_GetActorLocation(), CT.Translation, "BulletIgnorePawn", false, IgnoreActors, UE4.EDrawDebugTrace.None, OutHit, true);
                if bHit then
                    CT.Translation = OutHit.Location;
                end
            end
            if not DoNotSpawnOnNav then
                local NavPoint, bHasPoint = self:TracePointToNav(CT.Translation, bCheckNavPath);
                CT.Translation = NavPoint;
                print("Nav Position")
            end
                
            if not SummonLocationControl then
                local Team = CurrentPlayer.AIControlData.Team;
                if Team ~= nil and Team:GetCurrentTeamSlotConfig() and CurrentPlayer == SummonOwner then
                    CT = Team:GetNextEmptySlotTrans()
                    print("Slot Position")
                end
            end

            print("Spawn Loc is : ",CT.Translation)
            local NpcParams = UE4.FSpawnNpcParams()
            NpcParams.Id = SummonID
            NpcParams.Level = SummonLevel
            if LevelFollowSummoner == true then
                NpcParams.Level = SummonOwner.Level;
            end
            NpcParams.Location = CT.Translation
            NpcParams.Rotation = CT.Rotation:ToRotator();
            NpcParams.Type = UE4.ECharacterType.Summon
            NpcParams.bUseHalfCapsuleHeight = true;
            NpcParams.AI = SummonAI
            NpcParams.Camp = SummonOwner.Camp
            NpcParams.Team = self:FindOwnerTeam(CurrentPlayer)
            NpcParams.SpecializedSkillsConfig.SpecializedSkillIDs = SpecificSkillIDs
            NpcParams.SpecializedSkillsConfig.SpecializedPropertyID = SpecificAttributeID
            NpcParams.SpecializedSkillsConfig.MinNum = SpecificSkillIDs:Length();
            NpcParams.SpecializedSkillsConfig.MaxNum = SpecificSkillIDs:Length();
            if SummonType == 0 then
                NpcParams.SummonType = UE4.ESummonType.Normal
            end
            if SummonType == 1 then
                NpcParams.SummonType = UE4.ESummonType.Accessory
            end
            
            local SummonRef = UE4.ULevelLibrary.SpawnMonsterAtLocation(self:GetAbilityOwner(), NpcParams, SummonOwner)
            SummonRef.bIgnore = bIgnore;
            SummonRef:SetLifeSpan(SummonLife);
            SummonRef.SummonedRuntimeEASInfo.SkillID, SummonRef.SummonedRuntimeEASInfo.SkillRuntimeID = self:GetSkillId()
            SummonRef.SummonedRuntimeEASInfo.SkillLevel = self:GetSkillLevel();
            if self:GetEmitterInfo().bMarkRunning then
                SummonRef:MarkRunning();
                local GameSkill = self:GetGameSkillOwner();
                if GameSkill then
                    GameSkill:K2_MarkRunningObject(SummonRef);
                end
            end

            if MaxNum > 0 then 
                UE4.ULevelLibrary.LimitNPCMaxNum(self:GetAbilityOwner(), SummonOwner, SummonRef, MaxNum);
            end

            self:ApplyEffect(NpcParams.Location, NpcParams.Rotation);
        end
    end
    return UE4.EEmitterResult.Finish
end


function Summon:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function Summon:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

function Summon:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end


function Summon:EmitterDestroyLua()
    self:Destroy()
end

function Summon:TracePointToNav(Location, bCheckNavPath)
    -- UE4.UKismetSystemLibrary.DrawDebugSphere(self, Location, 50.0, 12, UE4.FLinearColor(1, 0, 0, 1), 5)
    local SummonOwner = self:GetInstigator()
    if not SummonOwner then
        return Location, false;
    end
    -- 不做寻路检测
    if not bCheckNavPath then
        local ProjectedLocation = UE4.FVector();
        local bProjectSuccess = UE4.UNavigationSystemV1.K2_ProjectPointToNavigation(self, Location, ProjectedLocation, nil, nil, self.MaxQueryExtent);
        if bProjectSuccess then
            return ProjectedLocation, true;
        end
        return Location, false;
    end
    -- local QueryExtent = self.MaxQueryExtent / self.MaxIteratorCount;
    local StartPosition = SummonOwner:GetNavAgentLocation();
    local LastProjectedLocation = UE4.FVector();
    for i = 1, self.MaxIteratorCount do
        local LerpLocation = UE4.UKismetMathLibrary.VLerp(Location, StartPosition, 1 / (self.MaxIteratorCount - 1) * (i-1));
        -- UE4.UKismetSystemLibrary.DrawDebugSphere(self, LerpLocation, 50.0, 12, UE4.FLinearColor(1, 0, 0, 1), 5)
        local ProjectedLocation = UE4.FVector();
        local bProjectSuccess = UE4.UNavigationSystemV1.K2_ProjectPointToNavigation(self, LerpLocation, ProjectedLocation, nil, self.NavQueryFilter, self.MaxQueryExtent);
        if bProjectSuccess then
            LastProjectedLocation = ProjectedLocation;
            -- UE4.UKismetSystemLibrary.DrawDebugSphere(self, ProjectedLocation, 50.0 * 1.1 ^ i, 12, UE4.FLinearColor(1 / self.MaxIteratorCount * i, 0, 0, 1), 5)
            local PathLength;
            local ResultType = UE4.UNavigationSystemV1.GetPathLength(self, StartPosition, ProjectedLocation, PathLength, nil, self.NavQueryFilter);
            if ResultType == UE4.ENavigationQueryResult.Success then
                return ProjectedLocation, true;
            end
        end
    end
    if not UE4.UKismetMathLibrary.Vector_IsZero(LastProjectedLocation) then
        return LastProjectedLocation, true;
    end

    -- 没有投影到导航网格上，则取当前角色位置
    local IgnoreActors = UE4.TArray(UE4.AActor);
    IgnoreActors:Add(SummonOwner);
    SummonOwner:GetAttachedActors(IgnoreActors, false);
    local OutHit = UE4.FHitResult();
    local DownVector = UE4.FVector(0, 0, -1000);
    local bHit = UE4.UKismetSystemLibrary.LineTraceSingleByProfile(self, SummonOwner:K2_GetActorLocation(), SummonOwner:K2_GetActorLocation() + DownVector, "BulletIgnorePawn", false, IgnoreActors, UE4.EDrawDebugTrace.None, OutHit, true);
    if bHit then
        return OutHit.Location, false;
    else
        return StartPosition, false;
    end

    return Location, false;
end

return Summon
