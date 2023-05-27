-- ========================================================
-- @File    : ClearAbnormalState.lua
-- @Brief   : 清除当前的异常状态,并对造成者造成伤害和Modifier
-- @Author  : XiongHongJi
-- @Date    : 2019-5-29
-- ========================================================

---@class USkillEmitter_ClearAbnormalState:USkillEmitter
local ClearAbnormalState = Class();

function ClearAbnormalState:OnEmit()
    local EmitterInfo = self:GetEmitterInfo()

    local ABType = self:GetParamValue(0)
    local bClearAll = self:GetParamboolValue(1)

    local CTs = EmitterSearcher:GetCenterTransform(self)
    local length = CTs:Length()
    for i = 1, length do
        local CT = CTs:Get(i)
        self:ApplyEffect(CT.Translation, CT.Rotation);
    end

    local OwnerAbility = self:GetAbilityOwner();
    if  OwnerAbility ~= nil then
        local AbnormalInfo = OwnerAbility:GetCurrentAbnormalInfo();
        local Casuer = AbnormalInfo.AbnormalCauser;

        if Casuer ~= nil then
            local CauserResult =  UE4.UAbilityFunctionLibrary.MakeQueryResult_AdjustToTarget(Casuer, EmitterInfo.ApplyLocationType);
            self.QueryResults:Add(CauserResult);
            self:AddQueryResult(Casuer, Casuer:K2_GetActorLocation());
            self:ApplyMagicToActor(CauserResult, CauserResult.QueryPoint, OwnerAbility:GetOwner():K2_GetActorLocation());
            self:AddTargetApplyNum(Casuer)
        end

        OwnerAbility:ClearAbnormalState(ABType, bClearAll);
    end

    return UE4.EEmitterResult.Finish
end

function ClearAbnormalState:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end
function ClearAbnormalState:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function ClearAbnormalState:EmitterDestroyLua()
    self:Destroy()
end

return ClearAbnormalState;

