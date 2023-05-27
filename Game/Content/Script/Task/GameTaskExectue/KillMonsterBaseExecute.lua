-- ========================================================
-- @File    : KillMonsterBase.lua
-- @Brief   : 杀怪基类
-- @Author  :
-- @Date    :
-- ========================================================

---@class KillMonsterBase : GameTask_Execute
local KillMonsterBase = Class()

---当前杀怪数量
KillMonsterBase.KillNum = 0

---死亡回调函数
KillMonsterBase.DeathFunc = nil

function KillMonsterBase:OnActive()
    self.KillNum = 0
    ---注册怪死亡
    self.DeathHook =
        EventSystem.On(
        Event.CharacterDeath,
        function(InMonster, killer)
            if InMonster then
                --延迟执行  防止立即注册立即调用
                local UpdateUITimerHandle =
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {
                        self,
                        function()
                            if (not self.IngnoreSuicide) or (killer and killer ~= InMonster) then
                                self:OnDeath(InMonster)
                            end
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
end

function KillMonsterBase:OnActive_Client()
    --self:SetExecuteDescription()
end

function KillMonsterBase:OnCountDown_Client()
    UI.Call("Fight", "UpdateTaskCountDown", self:GetCountDown(), self)
end

function KillMonsterBase:OnDeath(InMonster)
    if not self:CheckCondition(InMonster) then
        return
    end
    self.KillNum = self.KillNum + 1
    if self:Check() then
        self:Finish()
        --self:SetCurrentState(UE4.ETaskItem_State.Finish)
        EventSystem.Remove(self.DeathHook)
    end
    ---发送数据
    self:SetExecuteDescription()
    --self:DoSendData()
end

---子类复写 怪物死亡检查  组  类型 等
function KillMonsterBase:CheckCondition(InMonster)
    return IsAI(InMonster)
end

function KillMonsterBase:Check()
    return self.KillNum >= self.Num
end

function KillMonsterBase:GetDescription()
    if self:IsServer() then
        self.DescArgs:Clear()
        self.DescArgs:Add(self.KillNum)
        self.DescArgs:Add(self.Num)
    elseif self:IsClient() then
        self.KillNum = self.DescArgs:Get(1)
        self.Num = self.DescArgs:Get(2)
    end

    local Title = string.format(self:GetUIDescription(),self.KillNum .. "/" .. self.Num)
    return Title
end

function KillMonsterBase:OnEnd()
    EventSystem.Remove(self.DeathHook)
end

function KillMonsterBase:OnEnd_Client()
    UI.Call("Fight", "HiddenTaskCountDown", self)
end

return KillMonsterBase
