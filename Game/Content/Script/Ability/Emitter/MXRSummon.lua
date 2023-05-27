-- ========================================================
-- @File    : MXRSummon.lua
-- @Brief   : 召唤物
-- @Author  : XiongHongJi
-- @Date    : 2019-09-02
-- ========================================================

---@class USkillEmitter_Summon:USkillEmitter
local MXRSummon = Class()

function MXRSummon:OnEmit()
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

    local SummonID = self:GetParamintValue(0)
    local SummonAI = self:GetParamintValue(1)
    local SummonLevel = self:GetParamintValue(2)
    local SummonNum = self:GetParamintValue(3)
    local SummonLife = self:GetParamfloatValue(4)
    local bIgnore = self:GetParamboolValue(5)
    local MaxNum = self:GetParamintValue(6)
    local LevelFollowSummoner = false;
    local ParamsLength = self:GetParamLength()
    if ParamsLength > 7 then
        LevelFollowSummoner =  self:GetParamboolValue(7)
    end
    local SpecificSkillIDs = self:GetParamInt32ArrayValue(8)

    local SpecificAttributeID =  self:GetParamintValue(9)

    local SummonType = self:GetParamintValue(10)

    local ModifierID = self:GetParamintValue(12)

    local LimitMaxType = self:GetParamintValue(13)

    local CTs = EmitterSearcher:GetCenterTransform(self)
    for i = 1, CTs:Length() do
        self:ApplyEffect(CTs:Get(i).Translation, CTs:Get(i).Rotation);
    end

    local SummonOwner = self:GetInstigator()
    if not SummonOwner then
        return UE4.EEmitterResult.Finish
    end

    for i = 1 , self.QueryResults:Length() do
        if SummonNum < i then
            return UE4.EEmitterResult.Finish;
        end

        self:FreshSpawnTransform(i);
        local CT = self.SpawnTransform;
        local SpawnLoc = CT.Translation;

        local NpcParams = UE4.FSpawnNpcParams()
        NpcParams.Id = SummonID
        NpcParams.Level = SummonLevel
        if LevelFollowSummoner == true then
            NpcParams.Level = SummonOwner.Level;
        end
        NpcParams.Location = CT.Translation
        NpcParams.Rotation = CT.Rotation:ToRotator();
        NpcParams.Type = UE4.ECharacterType.Summon
        NpcParams.AI = SummonAI
        NpcParams.Team = 0
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
        self:SetSummonTarget(SummonRef, self.QueryResults:Get(i).QueryTarget)
        if MaxNum > 0 then
            if LimitMaxType == 0 then
                UE4.ULevelLibrary.LimitNPCMaxNum(self:GetAbilityOwner(), SummonOwner, SummonRef, MaxNum);
            elseif LimitMaxType == 1 then
                self:LimitSameTargetSummonMaxNum(self:GetAbilityOwner(), SummonOwner, SummonRef, MaxNum);
            end
        end

        local EmitterInfo = self:GetEmitterInfo()
        

        local Result = self.QueryResults:Get(i)
        if self:IsTargetCanApply(Result.QueryTarget) == true then
            local Target = Result.QueryTarget;
            local DamageScaler = 1.0

            if self:GetSkillInfo().DivideDamage == true then
                DamageScaler = 1.0 / length
            end

            self:ApplyMagicToActor(Result, Result.QueryPoint, Center, DamageScaler)
            self:AddTargetApplyNum(Target)
        end

        if SummonRef ~= nil then
            UE4.UModifier.MakeModifier(ModifierID, self, self:GetAbilityOwner(), SummonRef.Ability,
             self, SummonRef:K2_GetActorLocation(), CT.Translation);
        end
    end
    return UE4.EEmitterResult.Finish
end


function MXRSummon:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function MXRSummon:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

function MXRSummon:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end


function MXRSummon:EmitterDestroyLua()
    self:Destroy()
end

function MXRSummon:LimitSameTargetSummonMaxNum(Ability, SummonOwner, SummonRef, MaxNum)
    if Ability == nil then
        return;
    end
    MaxNum = math.max(MaxNum, 1);
    local CurrentNum = 1;
    local OldestSummoned;
    local OtherSumoned = {}
    local GameCharacters = UE4.UGameplayStatics.GetAllActorsOfClass(Ability, UE4.AGameCharacter)
    for i = 1, GameCharacters:Length() do
        local GameCharacter = GameCharacters:Get(i);
        if GameCharacter.Type == UE4.ECharacterType.Summon and GameCharacter.SummonedOwner == SummonOwner and self:IsSameTarget(GameCharacter, SummonRef) then
            if SummonRef ~= GameCharacter and GameCharacter:GetLifeSpan() >= 0.1 and SummonRef:GetTemplateID() == GameCharacter:GetTemplateID() then
                table.insert(OtherSumoned, GameCharacter)
                CurrentNum = CurrentNum + 1;
            end
        end
    end
    table.sort(OtherSumoned, function(a, b)
        return a:GetGameTimeSinceCreation() < b:GetGameTimeSinceCreation()
    end)
    for i = MaxNum, #OtherSumoned do
        OtherSumoned[i]:SetLifeSpan(0.01);
    end
end

return MXRSummon
