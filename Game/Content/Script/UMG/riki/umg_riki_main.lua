-- ========================================================
-- @File    : umg_riki_main.lua
-- @Brief   : 图鉴系统主面板
-- ========================================================

local tbClass = Class('UMG.BaseWidget')

function tbClass:Construct()

end

function tbClass:OnInit()
--addbtn
	-- BtnAddEvent(self.Role,function() UI.Open('Dungeons') end)
	-- BtnAddEvent(self.Role, function() UI.Open('Dungeons') end)

	self.tbCacheFunc = {
		[RikiLogic.tbType.Role] 	= {btn = self.Role ,},
		[RikiLogic.tbType.Weapon] 	= {btn = self.Weapon ,},
		[RikiLogic.tbType.Support] 	= {btn = self.Support ,},
		[RikiLogic.tbType.Monster] 	= {btn = self.Enemy ,},
		[RikiLogic.tbType.Fashion] 	= {btn = self.Fashion ,},
		[RikiLogic.tbType.Plot] 	= {btn = self.Plot ,},
		[RikiLogic.tbType.Explore] 	= {btn = self.Explore ,}
		-- [RikiLogic.tbType.Parts] = {btn = self. ,},
		
	}

	EventSystem.Remove(self.nButtonPressed)
	self.nButtonPressed = EventSystem.OnTarget(
		self,
		"BUTTON_PRESSED",
		function() 
			-- print("OnMouseButtonDownEvent");
			self:PlayAnimation(self.Click1)	
		end)

	EventSystem.Remove(self.nButtonReleased)
	self.nButtonReleased = EventSystem.OnTarget(
		self,
		"BUTTON_RELEASED",
		function() 
			-- print("OnMouseButtonUpEvent");
			self:PlayAnimationReverse(self.Click1)	
		end)
end

function tbClass:OnOpen()
	--get data
	local nSumAct = 0
	local nSums = 0
	for type, info in pairs(self.tbCacheFunc) do
        if info.btn then
            WidgetUtils.Visible(info.btn)
                local nAct,nSum = info.btn:Set(type)
                if nAct then
                	nSumAct = nSumAct + nAct
                	nSums = nSums + nSum
                end
        end
    end

    self.Num:SetText(nSumAct);
    self.Num2:SetText(nSums);
end

function tbClass:OnClose()
	print("OnClose")
    EventSystem.Remove(self.nButtonReleased)
    EventSystem.Remove(self.nButtonPressed)
end

return tbClass;