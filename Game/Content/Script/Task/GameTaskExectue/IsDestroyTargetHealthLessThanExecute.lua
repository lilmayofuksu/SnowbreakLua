-- ========================================================
-- @File    : IsDestroyTargetHealthLessThanExecute.lua
-- @Brief   : 破坏物血量检查
-- @Author  :
-- @Date    :
-- ========================================================
local IsDestroyTargetHealthLessThanExecute = Class()

function IsDestroyTargetHealthLessThanExecute:OnActive()
    self.Target = self:FindTarget()
    if not self.Target then 
        self:Finish()
        return
    end

    if not self:Check() then
        ---注册物体受到伤害
        self.OnDamageHook =
            EventSystem.On(
            "DestructibleOnReceiveDamage",
            function(InObject)
                self:OnDamage(InObject)
            end
        )
        TaskCommon.AddHandle(self.OnDamageHook)
    end
end

function IsDestroyTargetHealthLessThanExecute:Check()
    local curHp = self.Target:GetCurrentHp()
    local maxHp = math.max(1, self.Target:GetMaxHp())
    if self.Value > curHp / maxHp then
        self:Finish()
        return true
    end
    return false
end

function IsDestroyTargetHealthLessThanExecute:OnDamage(InObject)
    if InObject == self.Target then
        self:Check()
    end
end

function OnEnd()
    EventSystem.Remove(self.OnDamageHook)
end

return IsDestroyTargetHealthLessThanExecute
