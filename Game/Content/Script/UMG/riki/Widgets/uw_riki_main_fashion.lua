-- ========================================================
-- @File    : uw_riki_main_fashion.lua
-- @Brief   : 图鉴时装档案
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClick, function() UI.Open('RikiList',self.type) end)
    WidgetUtils.Collapsed(self.PanelNormal)
    WidgetUtils.Visible(self.PanelLock)
    WidgetUtils.Visible(self.Image_733)

    BtnAddEvent(self.BtnLock,function() UI.ShowTip("ui.TxtNotOpen") end)
    self.BtnClick.OnPressed:Add(self, 
    	function() 
    		EventSystem.TriggerTarget(UI.GetUI("RikiMain"), "BUTTON_PRESSED")
		end)

    self.BtnClick.OnReleased:Add(self, 
    	function() 
    		EventSystem.TriggerTarget(UI.GetUI("RikiMain"), "BUTTON_RELEASED")
		end)
end

---设置
---@param cfg DailyTemplateLogic
function tbClass:Set(type)
	self.type = type
    
    local nAct,nRed,nSum = RikiLogic:GetTypeRikiNum(type)
    self.TxtNum:SetText(nAct.."/"..nSum);
    return nAct,nSum
end

return tbClass