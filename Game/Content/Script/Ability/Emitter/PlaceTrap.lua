-- ========================================================
-- @File    : PlaceTrap.lua
-- @Brief   : 防止陷阱
-- @Author  : XiongHongJi
-- @Date    : 2020-5-22
-- ========================================================

---@class USkillEmitter_Trap:USkillEmitter
local PlaceTrapEmitter = Class();

function PlaceTrapEmitter:OnEmitSearch()
    if self:GetEmitterInfo().bUseAppointTarget == false then
        EmitterSearcher:OnEmitSearch(self)
    end
end

function PlaceTrapEmitter:OnEmit()
    local CTs = EmitterSearcher:GetCenterTransform(self);
    print("CTS Num is : ", CTs:Length(), "Info id is :",self:GetEmitterInfo().ID, "EmitterResult Num is : ", self.QueryResults:Length())
    
    local CT = UE4.FTransform();
    if CTs:Length() > 0 then
        CT = CTs:Get(1);
    end

    if self.QueryResults:Length() > 0 then
        local CenterLoc = self.QueryResults:Get(1).QueryPoint;
        --- Param1 : 陷阱名
        --- Param2 : 陷阱持续时间
        --- Param3 : 进入陷阱触发技能
        --- Param4 : 陷阱持续触发技能
        --- Param5 : 离开陷阱触发技能
        --- Param6 : 是否放置在地面上
        --- Param7 : 陷阱最大数量
        local EmitterInfo = self:GetEmitterInfo()
        local TrapName = self:GetParamValue(0)
        local TrapLife = self:GetParamfloatValue(1); 
        local TrapEnterSkill = self:GetParamintValue(2); 
        local TrapKeepSkill = self:GetParamintValue(3);
        local TrapLeaveSkill = self:GetParamintValue(4);
        local TraceOnLand = self:GetParamboolValue(5);
        local TrapMaxNum = self:GetParamintValue(6);
      
        local LimitAllSameClassTrapNum = self:GetParamintValue(7);

        local path = string.format("/Game/Blueprints/Ability/Trap/%s.%s_C" , TrapName , TrapName);
        local TrapClass = UE4.UKismetSystemLibrary.MakeSoftClassPath(path)

        local StartLoc = CenterLoc
        StartLoc = self:GetNextApplyResultByEffectPriority().QueryPoint;

        CenterLoc = StartLoc;
        
        if TraceOnLand == true then
            StartLoc = CenterLoc + UE4.FVector(0, 0, 50.0);
            local EndLoc = StartLoc - UE4.FVector(0, 0, 5000.0)
            local HitResult =
                UE4.UAbilityFunctionLibrary.LineTraceSingle(
                StartLoc,
                EndLoc,
                UE4.ECollisionChannel.ECC_GameTraceChannel4, --- ECC_GameTraceChannel4(LandScape Trace)
                self:GetSkillLauncher()
            )

            if HitResult.bBlockingHit == true then
                CenterLoc = HitResult.ImpactPoint;
            else
                EndLoc = StartLoc;
                StartLoc = StartLoc + UE4.FVector(0, 0, 100.0);
                HitResult =
                UE4.UAbilityFunctionLibrary.LineTraceSingle(
                StartLoc,
                EndLoc,
                UE4.ECollisionChannel.ECC_GameTraceChannel4, --- ECC_GameTraceChannel4(LandScape Trace)
                self:GetSkillLauncher()
                )
                if HitResult.bBlockingHit == true then
                    CenterLoc = HitResult.ImpactPoint;
                end
            end
        end

        local TrapInfo = UE4.FTrapSpawnInfo();
        TrapInfo.ID = 1;
        TrapInfo.TrapType = TrapClass;
        TrapInfo.LifeTime:Add(1, TrapLife);
        TrapInfo.bRemoveOnLeave = false;
        TrapInfo.EnterSubSkill = TrapEnterSkill;
        TrapInfo.KeepingSubSkill = TrapKeepSkill;
        TrapInfo.LeaveSubSkill = TrapLeaveSkill;

        CT.Translation = CenterLoc;
        local Trap = UE4.ATrap.SpawnTrapDeferred(self:GetInstigator() , TrapInfo , CT ,self);
        if Trap ~= nil then
            if EmitterInfo.bMarkRunning then
                Trap:MarkRunning();
                local GameSkill = self:GetGameSkillOwner();
                if GameSkill then
                    GameSkill:K2_MarkRunningObject(Trap);
                end
            end

            local Result = UE4.UAbilityFunctionLibrary.MakeQueryResult_AdjustToTarget(Trap, EmitterInfo.ApplyLocationType);
            self:ApplyMagicToActor(Result , Result.QueryPoint ,Trap:K2_GetActorLocation() , 1);
            if TrapMaxNum > 0 then
                UE4.ATrap.LimitTrapMaxNum(self:GetInstigator(), Trap, self:GetInstigator(), TrapMaxNum, LimitAllSameClassTrapNum);
            end
        end

        self:ApplyEffect(CT.Translation, CT.Rotation);
    end
 

    return UE4.EEmitterResult.Finish;
end

function PlaceTrapEmitter:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

function PlaceTrapEmitter:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function PlaceTrapEmitter:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

function PlaceTrapEmitter:EmitterDestroyLua()
    self:Destroy()
end

return PlaceTrapEmitter;

