-- ========================================================
-- @File    : Default.lua
-- @Brief   : 默认功能发生器
-- @Author  : Xiong
-- @Date    : 2020-05-21
-- ========================================================

---@class USkillEmitter_Default:USkillEmitter
local Default = Class()


function Default:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function Default:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

function Default:OnEmitTick()
    local CT = EmitterSearcher:GetCenterTransform(self);
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    if CT:Length() > 0 then
        UE4.USkillEmitter.EmitterAnchorEffectFresh(self:GetSkillLauncher(),self:GetEmitterInfo(),CT:Get(1).Translation,CT:Get(1).Rotation,HashIndex);
    end
end

function Default:OnEmit()
    local CTs = EmitterSearcher:GetCenterTransform(self)
    local EmitterInfo = self:GetEmitterInfo()
    local BulletSettingNum = EmitterInfo.BulletSettings:Length()
    local AnchorTransform = UE4.FTransform();
    if CTs:Length() > 0 then
        AnchorTransform = CTs:Get(1)
    end
    
    local length = CTs:Length()
    for i = 1, length do
        local CT = CTs:Get(i)
        self:ApplyEffect(CT.Translation, CT.Rotation);
    end

    if BulletSettingNum > 0 then
        EmitterBullet:BulletSpawn(self, AnchorTransform)
    else
        self:OnEmit_SelfData(AnchorTransform.Translation, AnchorTransform.Rotation)
        return
    end
end

--仅用自身搜寻数据
function Default:OnEmit_SelfData(Center , Rotator)
    local length = self.QueryResults:Length()
    for i = 1, length do
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
    end
end

function Default:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

function Default:EmitterDestroyLua()
    self:Destroy()
end

return Default
