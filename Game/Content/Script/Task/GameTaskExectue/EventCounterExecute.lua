local tbClass = Class()

function tbClass:OnActive()
	self.TriggerNum = 0;
	self.EventHandle = EventSystem.On(self.TargetEvent,function ( ... )
		self.TriggerNum = self.TriggerNum + 1;
		self:UpdateDataToClient(self.TriggerNum)
		if self.TriggerNum >= (self.NeedNum or 1) then
			self:Finish()
		end
	end)
	TaskCommon.AddHandle(self.EventHandle)
end

function tbClass:OnUpdate_Client(TriggerNum)
	self.TriggerNum_Client = TriggerNum;
	self:SetExecuteDescription();
end

function tbClass:OnActive_Client()
	self.TriggerNum_Client = 0;
	self:SetExecuteDescription();
end

function tbClass:GetDescription()
	return string.format(self:GetUIDescription(),self.TriggerNum_Client..'/'..self.NeedNum)
end

function tbClass:OnEnd( ... )
	EventSystem.Remove(self.EventHandle)
end

return tbClass;