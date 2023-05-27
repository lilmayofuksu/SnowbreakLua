-- ========================================================
-- @File    : uw_riki_main_weapon.lua
-- @Brief   : 图鉴武器档案
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClick, function() UI.Open('RikiList',self.type) end)
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


    local nAct_p,nRed_p,nSum_p = RikiLogic:GetTypeRikiNum(RikiLogic.tbType.Parts)
    self.TxtNum:SetText(nAct+nAct_p.."/"..nSum+nSum_p);
    return nAct+nAct_p,nSum+nSum_p
end

return tbClass