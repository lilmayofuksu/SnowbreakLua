-- ========================================================
-- @File    : CastNewSkill.lua
-- @Brief   : 触发另一个技能
-- @Author  : XiongHongJi
-- @Date    : 2019-5-29
-- ========================================================

---@class USkillEmitter_CastNewSkill:USkillEmitter
local CastNewSkill = Class();

function CastNewSkill:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

function CastNewSkill:OnEmit()

    local CT = self:GetInstigator():GetTransform()
    self:ApplyEffect(CT.Translation, CT.Rotation);

    --- Param1 : 触发的SkillID
 
    local NewSkillID = self:GetParamintValue(0);
    local bSubSkill = self:GetParamboolValue(1);
    local bJump = self:GetParamboolValue(2);


    local CurSkillID = self:GetSkillInfo().ID;
    local OwnerChara = self:GetInstigator();
    if OwnerChara ~= nil then
        local Ability = OwnerChara.Ability;
        Ability:K2_FindOrAddSkill(NewSkillID, self:GetSkillLevel());
        if bJump == true then
            Ability:JumpSkill(NewSkillID,CurSkillID, self:GetSkillLevel());
        else
            if bSubSkill == false then
                Ability:CastSkill(NewSkillID, UE4.ESkillCastType.Auto, self:GetSkillLevel());
            else
                Ability:CastSubSkill(NewSkillID, self:GetSkillLevel(), OwnerChara);
            end
        end
    end

    return UE4.EEmitterResult.Finish
end

function CastNewSkill:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

function CastNewSkill:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function CastNewSkill:EmitterDestroyLua()
    self:Destroy()
end

return CastNewSkill;