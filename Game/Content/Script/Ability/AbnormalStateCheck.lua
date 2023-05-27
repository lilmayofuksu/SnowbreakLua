-- ========================================================
-- @File    : AbnormalStateCheck.lua
-- @Brief   : 异常状态持续条件检测
-- @Author  : XiongHongJi
-- @Date    : 2020-5-7
-- ========================================================

---@class AbnormalStateCheck 用于检测异常状态的结束
AbnormalStateCheck = {}

---@param float DeltaTime 间隔
---@param FAbnormalInfo AbnormalInfo 当前异常状态信息
---@param UAbilityComponent AbilityComp 所属技能组件
function AbnormalStateCheck.AbnormalTick(DeltaTime, AbnormalInfo, AbilityComp)
    if AbnormalInfo.AbnormalState == UE4.EAbnormalState.Breathless then
        if AbnormalInfo.CurrentTime >= AbnormalInfo.KeepTime then
            AbilityComp:RemoveAbnormalState(AbnormalInfo.AbnormalState, AbnormalInfo.AppliedModifierRunTimeID)
        end
    end
end
