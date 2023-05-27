-- ========================================================
-- @File    : RevivePlayer.lua
-- @Brief   : 复活角色
-- @Author  : cms
-- @Date    : 2022/2/26
-- ========================================================

---@class USkillEmitter_RevivePlayer:USkillEmitter
local RevivePlayer = Class()

function RevivePlayer:OnEmit()
    --- Param1 : 复活人数
    --- Param2 : 是否随机选择(否则根据换人顺序)
    --- Param3 : 是否切换上场
    --- Param4 : 回复值
    --- Param5 : 是否按百分比回复
    --- Param6 : 触发ModifierID(,分隔)

    local ReviveNum = self:GetParamintValue(0)
    local bRandomSelect = self:GetParamboolValue(1)
    local bSwitchPlayer = self:GetParamboolValue(2)
    local HealthValue = self:GetParamfloatValue(3)
    local bUsePercentValue = self:GetParamboolValue(4)
    local ModifierIDs = self:GetParamInt32ArrayValue(5)
    if bUsePercentValue then
        HealthValue = HealthValue/100
    end

    --需要复活的角色数组
    local NeedReviveChars = UE4.TArray(UE4.AGameCharacter)
    local OriginChar = self:GetAbilityOwner():GetOriginCharacter()
    if OriginChar and OriginChar:GetCharacterController() then
        local PlayerController = OriginChar:GetCharacterController():Cast(UE4.AGamePlayerController)
        if PlayerController then
            local AllCharacter = PlayerController:GetPlayerCharacters()
            local DeadChars = UE4.TArray(UE4.AGameCharacter)
            for i = 1, AllCharacter:Length() do
                if not AllCharacter:Get(i):IsAlive() then
                    DeadChars:Add(AllCharacter:Get(i))
                end
            end
            local SwitchPlayer = nil
            local CurrentCharIndex = PlayerController:GetCharacterIndex(OriginChar)
            for i = 1, ReviveNum do
                if DeadChars:Length() == 0 then
                    break
                end
                local RevivePlayer = nil
                if bRandomSelect then
                    local RandomIndex = math.random(1, DeadChars:Length())
                    RevivePlayer = DeadChars:Get(RandomIndex)
                else
                    RevivePlayer = DeadChars:Get(1)
                end
                if RevivePlayer then
                    RevivePlayer:Revive(HealthValue,bUsePercentValue)
                    for i = 1,ModifierIDs:Length() do
                        UE4.UModifier.MakeModifier(ModifierIDs:Get(i), self, self:GetAbilityOwner(), RevivePlayer.Ability, self)
                    end
                end
                DeadChars:RemoveItem(RevivePlayer)
                if not SwitchPlayer then
                    SwitchPlayer = RevivePlayer
                end
            end
            if bSwitchPlayer and SwitchPlayer then
                PlayerController:SwitchPlayerCharacter(PlayerController:GetCharacterIndex(SwitchPlayer))
            end
        end
    end
    return UE4.EEmitterResult.Finish
end

function RevivePlayer:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

function RevivePlayer:ApplyEffect(Center, Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self)
    UE4.USkillEmitter.EmitterAnchorEffectPlay(
        self:GetSkillLauncher(),
        self:GetEmitterInfo(),
        Center,
        UE4.UKismetMathLibrary.Quat_Rotator(Rotator),
        HashIndex,
        self.QueryResults
    )
end

function RevivePlayer:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self)
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(), HashIndex,self:GetEmitterInfo())
end

function RevivePlayer:EmitterDestroyLua()
    self:Destroy()
end

return RevivePlayer
