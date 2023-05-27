-- ========================================================
-- @File    : TransformedToMonster.lua
-- @Brief   : 
-- @Author  : XiongHongJi
-- @Date    : 2021-12-29
-- ========================================================

---@class USkillEmitter_SwitchToNextPlayer:USkillEmitter
local TransformedToMonster = Class()

function TransformedToMonster:OnEmit()
    local DefaultID = self:GetParamintValue(0);

    local CharacterOwner = self:GetInstigator();
    if CharacterOwner ~= nil then
        local AICharacter = CharacterOwner:Cast(UE4.AGameAICharacter);
        if AICharacter ~= nil then
            local NewMonster = AICharacter:TransformedToMonster(DefaultID, DefaultID);
        end
    end
end

function TransformedToMonster:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function TransformedToMonster:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

function TransformedToMonster:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

function TransformedToMonster:EmitterDestroyLua()
    self:Destroy()
end

return TransformedToMonster;