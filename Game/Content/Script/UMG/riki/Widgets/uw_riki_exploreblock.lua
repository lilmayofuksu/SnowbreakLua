-- ========================================================
-- @File    : uw_riki_exploreblock.lua
-- @Brief   : 探索图鉴
-- ========================================================
local tbClass = Class("UMG.SubWidget")


function tbClass:Construct()
	BtnAddEvent(self.BtnClick, function() UI.Open('RikiExploreInfo',{type=self.nType,sName = RikiLogic.TxtNameType[self.nType]}); end)
	BtnAddEvent(self.BtnLock, function() UI.ShowTip("ui.TxtHandbook20"); end)

end

function tbClass:OnDestruct()

end

function tbClass:OnListItemObjectSet(pObj)
	self.nType = pObj.Data.nType

	WidgetUtils.Visible(self.PanelNormal)
	WidgetUtils.Visible(self.PanelNot)
	WidgetUtils.Visible(self.Icon)

	self.Num1:SetText(pObj.Data.nGet)
	self.Num2:SetText(pObj.Data.nTotal)
	self.Num:SetText(self.nType)
	self.TxtName:SetText(Text(RikiLogic.TxtNameType[self.nType]))

	SetTexture(self.ImgPic, RikiLogic.FrontPageImg[self.nType], true)
	SetTexture(self.ImgIcon, RikiLogic.FrontPageSmallImg[self.nType], true)
	SetTexture(self.ImgIcon_1, RikiLogic.FrontPageSmallImg[self.nType], true)
	-- print("self.nType:",self.nType,RikiLogic.FrontPageSmallImg[self.nType],self.ImgIcon)
	
	if pObj.Data.nGet ~= 0 then
		-- WidgetUtils.Visible(self.PanelNormal)
		WidgetUtils.Collapsed(self.PanelNot)
	else
		-- WidgetUtils.Visible(self.PanelNot)
		WidgetUtils.Collapsed(self.Icon)
		-- WidgetUtils.Collapsed(self.PanelNormal)
	end
end

return tbClass