-- ========================================================
-- @File    :
-- @Brief   :
-- @Author  :
-- @DATE    : ${date} ${time}
-- ========================================================
local uw_Select_Moster_Command = Class("UMG.SubWidget")
local tbClass = uw_Select_Moster_Command

function tbClass:OnListItemObjectSet(pObj)
	local tbParam = pObj and pObj.Data
	if not tbParam then
		return
    end
	self.TxtName:SetText(tbParam.MonName)--or tbParam.tb.nameKey

	BtnClearEvent(self.Btn)
	BtnAddEvent(self.Btn,function ()
		tbParam.onClick(tbParam.MonID, tbParam.MonAI)
	end)
end

-- function tbClass:UpdateSelected(bSelect)
-- 	if bSelect then
--         self.Btn:SetBackgroundColor(ColorGreen)
--     else
--         self.Btn:SetBackgroundColor(ColorWhite)
--     end
-- end

return uw_Select_Moster_Command;
