-- ========================================================
-- @File    : KillAllMonsterExecute.lua
-- @Brief   : 杀所有怪
-- @Author  :
-- @Date    :
-- ========================================================

---@class KillAllMonsterExecute : GameTask_Execute
local KillAllMonsterExecute = Class()


---死亡回调函数
KillAllMonsterExecute.DeathFunc = nil

function KillAllMonsterExecute:OnActive()
    ---注册怪死亡
    self.DeathHook =
        EventSystem.On(
        Event.CharacterDeath,
        function(InMonster)
            if InMonster then
                --延迟执行  防止立即注册立即调用
                local UpdateUITimerHandle =
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {
                        self,
                        function()
                            self:OnDeath(InMonster)
                        end
                    },
                    0.01,
                    false
                )
            end
        end
    )
    self:SetExecuteDescription()
    TaskCommon.AddHandle(self.DeathHook)
    if self.bCheckOnActive then
        if self:Check() then
            self:Finish()
            EventSystem.Remove(self.DeathHook)
        end
    end
end

function KillAllMonsterExecute:OnActive_Client()
    --self:SetExecuteDescription()
end

function KillAllMonsterExecute:OnCountDown_Client()
    UI.Call("Fight", "UpdateTaskCountDown", self:GetCountDown(), self)
end

function KillAllMonsterExecute:OnDeath(InMonster)
    if not InMonster then
        return
    end
    if self:Check() then
        self:Finish()
        EventSystem.Remove(self.DeathHook)
    end
    self:SetExecuteDescription()
end

function KillAllMonsterExecute:OnEnd_Client()
    UI.Call("Fight", "HiddenTaskCountDown", self)
end

function KillAllMonsterExecute:OnEnd()
    EventSystem.Remove(self.DeathHook)
end

return KillAllMonsterExecute
