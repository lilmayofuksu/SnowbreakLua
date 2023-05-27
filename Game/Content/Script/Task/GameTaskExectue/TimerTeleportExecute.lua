-- ========================================================
-- @File    : TimerTeleportExecute.lua
-- @Brief   :
-- @Author  : cms
-- @Date    : 2022.1.21
-- ========================================================

---@class  TimerTeleportExecute: GameTask_Execute
local TimerTeleport = Class()



function TimerTeleport:OnActive()
    --@ATimerTeleportTrigger
    self.TriggerItem = self:FindTrigger()
    if self.TriggerItem then
        self.TriggerItem:Active(self)
    end
    self.CurrentNum = self.TimerNum
    self.TimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, TimerTeleport.TimerCountDown}, 1, true)
    self.bTPSuccess = false
    self:FlushKeys()
    self:CheckState()
end

function TimerTeleport:OnActive_Client()
    self.CurrentNum = self.TimerNum
    self:SetExecuteDescription(string.format(self:GetUIDescription(), self.CurrentNum))
end

function TimerTeleport:TimerCountDown()
    self.CurrentNum = self.CurrentNum - 1
    if self.CurrentNum > 0 then
        self:UpdateDataToClient(self.CurrentNum)
    elseif not self.bTPSuccess then
        self.bTPSuccess = true
        self:TPAllPlayers()
    end
end

function TimerTeleport:OnUpdate_Client(CurrentNum)
    self.CurrentNum = CurrentNum
    self:SetExecuteDescription(string.format(self:GetUIDescription(), self.CurrentNum))
end

function TimerTeleport:GetTitleDescription()
    return string.format(self:GetUIDescription(), self.TimerNum)
end

function TimerTeleport:GetTriggerItem()
    return self.TriggerItem
end

function TimerTeleport:OnFinish()
    if self.TriggerItem then
        self.TriggerItem:Deactive()
    end
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
end

function TimerTeleport:OnEnd()
    if self.TriggerItem then
        self.TriggerItem:Deactive()
    end
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
end

return TimerTeleport
