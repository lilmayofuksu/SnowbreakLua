local tbClass = Class("Task.Extend.TreasureBoxBase")
require("DS_ProfileTest.Utils.DsCommonfunc")

function tbClass:OnActive_Client()
	if not self.bActive then
		self:DoActive()
	end
end

function tbClass:DoActive()
	-- print("GearSwitch:DoActive")
	self:SetActive(true)
	self:SetInteractable()
	self.TargetGear = self:FindGear()
	self:BindElevator()
	-- print("GearSwitch:post DoActive")
end

function tbClass:OnTrigger_Client(bIsBeginOverlap, OtherActor)
	if self.bActive and not self.TargetGear then
		self:DoActive()
	end
	self:TriggerHandle(bIsBeginOverlap, OtherActor)
end

function tbClass:CheckInteractCondition()
	return self:CheckShowHandle()
end

function tbClass:TriggerHandle(bIsBeginOverlap, OtherActor)
	-- print("GearSwitch:TriggerHandle")
    if bIsBeginOverlap then
		if self:CheckShowHandle() and self:IsLocalPlayer(OtherActor) then
			-- print("GearSwitch:OnInteractListAddItem")
			self.Super.TriggerHandle(self, bIsBeginOverlap, OtherActor)
            -- EventSystem.Trigger(Event.OnInteractListAddItem, self.InteractWidgetClass ,1,self)
			-- 添加交互物队列
			DSCommonfunc.AddInteractList(self)
			local isCan = self:CheckShowHandle() --true表示可交互
			print("====== TriggerHandle isCan = ",isCan)
        end
    else
		self.Super.TriggerHandle(self, bIsBeginOverlap, OtherActor)
        -- EventSystem.Trigger(Event.EndOverlapTaskBox, self)
		-- 移除交互物队列
		DSCommonfunc.RemoveInteract(self)
    end
	-- print("GearSwitch:TriggerHandle bLastAngleCheckResult", self.bLastAngleCheckResult)
end

--决定是否显示交互按钮
function tbClass:CheckShowHandle()
	if not IsValid(self.TargetGear) then
		return false
	end
	if self.TargetGear.IsRunning then
		return false
	end
	if self.SwitchType == 2 then
		return true
	end
	local TargetGearType = self.TargetGear.IsToTarget and 0 or 1

	return TargetGearType == self.SwitchType
end

function tbClass:IsLocalPlayer(OtherActor)
    if IsPlayer(OtherActor) and OtherActor:GetController() and OtherActor:GetController():IsLocalController() then
        return true
    end
    return false
end

return tbClass;