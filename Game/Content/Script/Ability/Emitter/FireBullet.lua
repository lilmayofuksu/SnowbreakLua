-- ========================================================
-- @File    : FireBullet.lua
-- @Brief   : 强制武器射击
-- @Author  : 
-- @Date    : 
-- ========================================================

---@class USkillEmitter_FireBullet:USkillEmitter
local FireBullet = Class();

---@param Skill USkill
function FireBullet:OnEmit()
    --- Param1 : 子弹ID
    local EmitterInfo = self:GetEmitterInfo()
    local BulletID = 0
    local ParamsLength = self:GetParamLength()
    if ParamsLength >= 1 then
        BulletID = self:GetParamintValue(0); 
    end
    local lpAbility = self:GetAbilityOwner()
    if not lpAbility then return UE4.EEmitterResult.Finish end
    local lpCharacter = lpAbility:GetOriginCharacter()
    if not lpCharacter then return UE4.EEmitterResult.Finish end
    local lpWeapon = lpCharacter:GetWeapon()
    if not lpWeapon then return UE4.EEmitterResult.Finish end
    if BulletID > 0 then
        lpWeapon:SetTempBulletID(BulletID, 0, 1)
    end
    lpWeapon:ForceFireBullet(BulletID)
    
    return UE4.EEmitterResult.Finish;
end

function FireBullet:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

function FireBullet:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function FireBullet:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

function FireBullet:EmitterDestroyLua()
    self:Destroy()
end

return FireBullet;

