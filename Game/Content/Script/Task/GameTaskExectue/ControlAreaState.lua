-- ========================================================
-- @File    : ControlAreaState.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

local ControlAreaState = Class()

function ControlAreaState:OnActive()
	self.Areas = self:GetAreasByTag()
	self:SetExecuteDescription()
end

function ControlAreaState:OnTick()
	for i=1,self.Areas:Length() do
		local area = self.Areas:Get(i)
		if area and area.AreaOwner ~= self.AreaOwner then
			return
		end
	end
	self:Finish()
end

function ControlAreaState:OnActive_Client()
end

function ControlAreaState:OnFail()
    
end

function ControlAreaState:OnFinish()
end

return ControlAreaState
