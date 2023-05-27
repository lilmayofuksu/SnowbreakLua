-- ========================================================
-- @File    : EvacuationTriggerExecute.lua
-- @Brief   : 关卡撤退任务
-- @Author  : 刘东锫
-- @Date    : 2022/2/7
-- ========================================================
local EvacuationTrigger = Class()

EvacuationTrigger.LeftTime = 0

function EvacuationTrigger:OnActive()
    self.EvacuationTriggerList = self:FindEvacuationByTag()
    if self.EvacuationTriggerList:Length() >= 1 then
    	self.EvaTrigger = self.EvacuationTriggerList:Get(1)
    	self.EvaTrigger:DoActive(function ()
    		self:Finish()
    	end,function ()
    		self:UpdateDesc()
    	end,self.EvacuationTime)
    end
end

function EvacuationTrigger:ClearTimerHandle()
	if self.EvaTrigger then
	    self.EvaTrigger:ClearTimerHandle()
	end
end

function EvacuationTrigger:OnFail()
    self:ClearTimerHandle()
end

function EvacuationTrigger:OnFinish()
    self:ClearTimerHandle()
end

function EvacuationTrigger:GetDescription()
	local desc = self:GetUIDescription()
	--[[if not desc or desc == '' then
		return string.format("在撤退区域坚守%d秒",self.EvaTrigger and self.EvaTrigger.LeftTime or 0)
	end
	return string.format(desc,self.EvaTrigger and self.EvaTrigger.LeftTime or 0)]]
	return desc or '在撤退区域坚守30秒'
end

--这样写是否合适?
function EvacuationTrigger:UpdateDesc()
	self:SetExecuteDescription()
end

return EvacuationTrigger;