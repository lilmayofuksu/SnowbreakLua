local AirBlockTrigger = Class()



function AirBlockTrigger:OnActive()
    --@ATimerTeleportTrigger
    self.TriggerItem = self:FindTrigger()
    if self.TriggerItem then
        self.TriggerItem:Active(self)
    end
    self:CheckState()
end

function AirBlockTrigger:GetTriggerItem()
    return self.TriggerItem
end

function AirBlockTrigger:OnFinish()
    if self.TriggerItem then
        self.TriggerItem:Deactive()
    end
end

return AirBlockTrigger