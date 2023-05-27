-- ========================================================
-- @File    : AccessoryCastSkill.lua
-- @Brief   : 触发挂件技能
-- @Author  : XiongHongJi
-- @Date    : 2019-5-29
-- ========================================================

---@class USkillEmitter_AccessoryCastSkill:USkillEmitter
local AccessoryCastSkill = Class();

function AccessoryCastSkill:OnEmit()
    local CT = self:GetSkillLauncher():GetTransform()
    self:ApplyEffect(CT.Translation, CT.Rotation);

    --- Param1 : 配件名
    --- Param2 : 触发的SkillID
    local AccessoryName = self:GetParamValue(0)
    local AccessorySkillID = self:GetParamintValue(1); 

    local OwnerChara = self:GetInstigator();
    if OwnerChara ~= nil then
        local Accessory = OwnerChara:GetAccessoryByName(AccessoryName);
        if Accessory ~= nil then
            local TargetAbility = self:GetAccessoryAbility(Accessory , AccessorySkillID);
        end
    end

    return UE4.EEmitterResult.Finish
end

function AccessoryCastSkill:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end


function AccessoryCastSkill:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

function AccessoryCastSkill:EmitterDestroyLua()
    self:Destroy()
end

return AccessoryCastSkill;