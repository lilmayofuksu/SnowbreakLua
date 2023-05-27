-- ========================================================
-- @File    :
-- @Brief   :
-- @Author  :
-- @DATE    : ${date} ${time}
-- ========================================================
local uw_newgm_command = Class("UMG.SubWidget")
local tbClass = uw_newgm_command
local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
local ColorWhite = UE.FLinearColor(1, 1, 1, 1);

--{name = name,tb = tb}
function tbClass:OnListItemObjectSet(pObj)
	local tbParam = pObj and pObj.Data
	if not tbParam then
		return
	end
	self.tbParam = tbParam
	self.TxtName:SetText(tbParam.tbParam.name)--or tbParam.tb.nameKey

	if tbParam.selectedIndex == tbParam.index then 
		tbParam.onClick(tbParam.tbParam.tb, self)
	end

	BtnClearEvent(self.Btn)
	BtnAddEvent(self.Btn,function ()
		tbParam.onClick(tbParam.tbParam.tb, self)
	end)

	if tbParam.onListAdd then 
		tbParam.onListAdd(tbParam.tbParam.tb, self)
		tbParam.onListAdd = nil
	end

	self:UpdateSelected( tbParam.selectedIndex == tbParam.index)
end

function tbClass:UpdateSelected(bSelect)
	if bSelect then
        self.Btn:SetBackgroundColor(ColorGreen)
    else
        self.Btn:SetBackgroundColor(ColorWhite)
    end
end

return uw_newgm_command;
