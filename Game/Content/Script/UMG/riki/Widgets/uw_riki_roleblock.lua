-- ========================================================
-- @File    : uw_riki_roleblock.lua
-- @Brief   : 角色图鉴
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
	BtnAddEvent(
		self.BtnEntry, 
		function() 
			-- print("onBtnEntry")
			UI.Open('RikiRoleInfo',self.tbData)
		end)
	WidgetUtils.Collapsed(self.Girl)
end

function tbClass:OnDestruct()

end

function tbClass:OnListItemObjectSet(pObj)
	self.tbData = pObj.Data;

	local pItem = pObj.Data.pItem

	SetTexture(self.Girl, pItem:Icon(), true)
	WidgetUtils.Visible(self.Girl)
	local sName = Text(pItem:I18N())
	if pItem:Color() == 5 then
    	sName = sName..'-'..Text(pItem:I18N()..'_title')
    end
    self.TextName:SetText(sName)
    -- print("pItem:I18N():",pItem:I18N())
    -- self.TextName:SetText(Text(pItem:I18N()))
    SetTexture(self.Color, Item.RikiRoleColorIcon[pItem:Color()])

    WidgetUtils.Visible(self.BtnEntry)
	WidgetUtils.Collapsed(self.PanelEmpty)

	if pObj.Data.nGet == 0 then
		WidgetUtils.Visible(self.PanelEmpty)

	end

end

return tbClass