-- ========================================================
-- @File    :
-- @Brief   :
-- @Author  :
-- @DATE    : ${date} ${time}
-- ========================================================
local uw_newgm_category = Class("UMG.SubWidget")
local tbClass = uw_newgm_category
local ColorGreen = UE.FLinearColor(0, 1, 0, 1);
local ColorWhite = UE.FLinearColor(1, 1, 1, 1);

function tbClass:Construct()
	self:RegisterEvent(Event.OnGMCategorySelect, function(idx) self:UpdateSelected(idx == self.tbParam.index) end)
end

function tbClass:OnListItemObjectSet(pObj)
	local tbParam = pObj and pObj.Data
	if not tbParam then
		return
	end

	self.tbParam = tbParam
	self.TxtName:SetText(tbParam.category)--Text('gm.'..tbParam.category)
	BtnClearEvent(self.Btn)
	BtnAddEvent(self.Btn,function ()
		tbParam.onClick(self);
	end)
	self:UpdateSelected(self.tbParam.bSelect)
end

function tbClass:UpdateSelected(bSelect)
	self.tbParam.bSelect = bSelect
	if bSelect then
        self.Btn:SetBackgroundColor(ColorGreen)
    else
        self.Btn:SetBackgroundColor(ColorWhite)
    end
end

return uw_newgm_category;
