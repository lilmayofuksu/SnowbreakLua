-- ========================================================
-- @File    : PreventOccupation.lua
-- @Brief   : 防止占领
-- @Author  :
-- @Date    :
-- ========================================================

---@class PreventOccupation : GameTask_Execute
local PreventOccupation = Class()
PreventOccupation.TimerHandle = nil
PreventOccupation.DeathHandle = nil

---关注的触发器
PreventOccupation.Boxs = nil

---已经击杀的怪物数量
PreventOccupation.KillNum = 0

PreventOccupation.RemainingTime = 0

function PreventOccupation:OnActive()

    self.Boxs = self:GetBox()
    ---激活找到的
    for i = 1, self.Boxs:Length() do
        ---@param f TargetTrigger
        local f = self.Boxs:Get(i)
        f:DoActive(self)
    end

    if self.Time > 0 then
        self.RemainingTime = self.Time
        self.TimerHandle =
            UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                function()
                    self.RemainingTime = self.RemainingTime - 1
                    self:SetExecuteDescription(self:GetFormatTitle())
                    if self.RemainingTime <= 0 then
                        self:Finish()
                    end
                end
            },
            1,
            true
        )
    end
    if self.NeedKillNum ~= -1 then
        self.DeathHandle =
            EventSystem.On(
            Event.CharacterDeath,
            function(InMonster)
                if InMonster then
                    self.KillNum = self.KillNum + 1
                    self:SetExecuteDescription(self:GetFormatTitle())
                    if self.KillNum >= self.NeedKillNum then
                        self:Finish()
                    end
                end
            end
        )
        TaskCommon.AddHandle(self.DeathHandle)
    end

    self:SetExecuteDescription(self:GetFormatTitle())
end

---条件更新
function PreventOccupation:Update()
    local bAllFill = true
    for i = 1, self.Boxs:Length() do
        ---@param f TargetTrigger
        local f = self.Boxs:Get(i)
        if not f.bFill then
            bAllFill = false
        end
    end
    if bAllFill then
        self:Fail()
    end
end

function PreventOccupation:OnFail()
    self:OnFinish()
    
end

function PreventOccupation:OnFinish()
    if self.Boxs then
        for i = 1, self.Boxs:Length() do
            self.Boxs:Get(i):Clear()
        end
    end
    self.Boxs = nil
    if self.TimerHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
        self.TimerHandle = nil
    end
    EventSystem.Remove(self.DeathHandle)
end

function PreventOccupation:GetFormatTitle()
    local Title = ""
    if self.Time > 0 then
        Title = string.format(self:GetUIDescription(),self.RemainingTime)
    elseif self.NeedKillNum > 0 then
        Title = string.format(self:GetUIDescription(),self.KillNum .. "/" .. self.NeedKillNum)
    end
    return Title
end

return PreventOccupation
