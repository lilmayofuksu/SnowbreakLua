-- ========================================================
-- @File    : UseTempSkill.lua
-- @Brief   : 替换指定插槽的技能
-- @Author  : XiongHongJi
-- @Date    : 2020-07-07
-- ========================================================

---@class USkillEmitter_UseTempSkill:USkillEmitter
local UseTempSkill = Class()


function UseTempSkill:OnEmit()
    local CT = self:GetSkillLauncher():GetTransform()
    self:ApplyEffect(CT.Translation, CT.Rotation);
    --- Param1 : 临时技能位置
    --- Param2 : 临时技能ID
    --- Param3 : 临时技能持续时间
    --- Param4 : 决定持续时间的ModifierID
    --- Param5 : 前置CD

    local EmitterInfo = self:GetEmitterInfo()
    local Index = self:GetParamintValue(0)
    local SkillID = self:GetParamintValue(1)
    local ActiveTime = self:GetParamfloatValue(2)
    local ModifierID = self:GetParamintValue(3)
    local PreCD = self:GetParamfloatValue(4)

    local Abilitys = UE4.TArray(UE4.UAbilityComponent);
    Abilitys:Add(self:GetAbilityOwner():Cast(UE4.UAbilityComponent)) ;
    
    if EmitterInfo.AppointType == UE4.EAppointTargetType.owner then
        local OriginChar = self:GetAbilityOwner():GetOriginCharacter();
        if OriginChar ~= nil then
            Abilitys:Add(OriginChar.Ability);
        end
    end

    if EmitterInfo.AppointType == UE4.EAppointTargetType.Summoned then
        local OriginChar = self:GetAbilityOwner():GetOriginCharacter();
        if OriginChar.SummonedOwner ~= nil then
            OriginChar = OriginChar.SummonedOwner;
        end
        if OriginChar ~= nil then
            Abilitys:Add(OriginChar.Ability);
        end
    end

    if EmitterInfo.AppointType == UE4.EAppointTargetType.Teammate or EmitterInfo.AppointType == UE4.EAppointTargetType.TeamPlayer then
        local OriginChar = self:GetAbilityOwner():GetOriginCharacter();
        if OriginChar ~= nil and OriginChar:GetCharacterController() ~= nil then
            local PlayerController = OriginChar:GetCharacterController()
            if PlayerController then
                local AllCharacter = PlayerController:GetPlayerCharacters()
                for i = 1, AllCharacter:Length() do
                    local TmpCharacter = AllCharacter:Get(i)
                    Abilitys:Add(TmpCharacter.Ability);
                end
            end
        end
    end
    
    if EmitterInfo.AppointType == UE4.EAppointTargetType.TeamMajor then
        local OriginChar = self:GetAbilityOwner():GetOriginCharacter();
        OriginChar = UE4.UAbilityFunctionLibrary.GetOriginPlayer(OriginChar)
        if OriginChar ~= nil and OriginChar:GetCharacterController() ~= nil then
            local PlayerController = OriginChar:GetCharacterController()
            if PlayerController then
                local AllCharacter = PlayerController:GetPlayerCharacters()
                for i = 1, AllCharacter:Length() do
                    local TmpCharacter = AllCharacter:Get(i)
                    if TmpCharacter == PlayerController:GetCurrentChar() then
                        Abilitys:Add(TmpCharacter.Ability);
                    end
                end
            end
        end
    end

    if EmitterInfo.AppointType == UE4.EAppointTargetType.TeamSupport then
        local OriginChar = self:GetAbilityOwner():GetOriginCharacter();
        OriginChar = UE4.UAbilityFunctionLibrary.GetOriginPlayer(OriginChar)
        if OriginChar ~= nil and OriginChar:GetCharacterController() ~= nil then
            local PlayerController = OriginChar:GetCharacterController()
            if PlayerController then
                local AllCharacter = PlayerController:GetPlayerCharacters()
                for i = 1, AllCharacter:Length() do
                    local TmpCharacter = AllCharacter:Get(i)
                    if TmpCharacter ~= PlayerController:GetCurrentChar() then
                        Abilitys:Add(TmpCharacter.Ability);
                    end
                end
            end
        end
    end

    for i = 1, Abilitys:Length() do 
        local Ability = Abilitys:Get(i);
        if Ability ~= nil then
            Ability:ReplaceSkillAtIndex(Index , SkillID , ActiveTime, ModifierID);
        end
    
        Ability:ChangeSkillCD(SkillID,PreCD);
    end

    return UE4.EEmitterResult.Finish
end

function UseTempSkill:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function UseTempSkill:OnEmitTick()
    local CT = EmitterSearcher:GetCenterTransform(self);
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    if CT:Length() > 0 then
        UE4.USkillEmitter.EmitterAnchorEffectFresh(self:GetSkillLauncher(),self:GetEmitterInfo(),CT:Get(1).Translation,CT:Get(1).Rotation,HashIndex);
    end
end

function UseTempSkill:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

function UseTempSkill:OnEmitterInterrupt()
end


function UseTempSkill:EmitterDestroyLua()
    self:Destroy()
end

return UseTempSkill
