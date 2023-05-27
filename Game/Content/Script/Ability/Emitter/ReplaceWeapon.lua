-- ========================================================
-- @File    : ReplaceWeapon.lua
-- @Brief   : 替换当前武器
-- @Author  : XiongHongJi
-- @Date    : 2020-05-12
-- ========================================================

---@class USkillEmitter_ReplaceWeapon:USkillEmitter
local ReplaceWeapon = Class()

function ReplaceWeapon:OnEmitBegin()
    --- Param1 : Weapon ID
    local EmitterInfo = self:GetEmitterInfo()
    local NewWeaponID = self:GetParamintValue(0)
    self.bKeepRunning = true
    local Self = self:GetInstigator()
    local WeaponClass = UE4.UAbilityFunctionLibrary.GetWeaponClass(NewWeaponID)
    if WeaponClass == nil then
        return EmitterInfo.Fail
    end

    if Self ~= nil then
        self.OldWeapon = Self:GetWeapon()
        self.OldWeapon:SetActorHiddenInGame(true)
        self.OldWeapon:SetOwner(nil)
        Self:AttachWeaponByWeaponID(NewWeaponID);
        self:ApplyEffect(self.OldWeapon:K2_GetActorLocation() , self.OldWeapon:K2_GetActorRotation());
    end

    Self:SetWeaponState(UE4.EWeaponState.Aim)
end


function ReplaceWeapon:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function ReplaceWeapon:OnEmit()
    return UE4.EEmitterResult.Finish
end

function ReplaceWeapon:OnEmitTick()
    local CT = EmitterSearcher:GetCenterTransform(self);
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    if CT:Length() > 0 then
        UE4.USkillEmitter.EmitterAnchorEffectFresh(self:GetSkillLauncher(),self:GetEmitterInfo(),CT:Get(1).Translation,CT:Get(1).Rotation,HashIndex);
    end
end

function ReplaceWeapon:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
    local Character = self:GetInstigator()
    if Character ~= nil and self.OldWeapon ~= nil and self.OldWeapon ~= Character:GetWeapon() then
        Character:GetWeapon():SetActorHiddenInGame(true)
        Character:GetWeapon():SetOwner(nil)
        Character:GetWeapon():SetLifeSpan(0.1)
         
        self.OldWeapon:SetActorHiddenInGame(false)
        self.OldWeapon:SetOwner(Character)
    end
end

function ReplaceWeapon:OnEmitterInterrupt()
    local Character = self:GetInstigator()
    if Character ~= nil and self.OldWeapon ~= nil and self.OldWeapon ~= Character:GetWeapon() then
        Character:GetWeapon():SetActorHiddenInGame(true)
        Character:GetWeapon():SetOwner(nil)
        Character:GetWeapon():SetLifeSpan(0.1)

        self.OldWeapon:SetActorHiddenInGame(false)
        self.OldWeapon:SetOwner(Character)
    end
end

function ReplaceWeapon:EmitterDestroyLua()
    self:Destroy()
end

return ReplaceWeapon
