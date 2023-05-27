-- ========================================================
-- @File    : uw_riki_exploreitem.lua
-- @Brief   : 图鉴探索列表子面板
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Btnchoose, function() self.tbData.Show(); end)
end

function tbClass:OnListItemObjectSet(pObj)
	self.tbData = pObj.Data;
    self.ParentUI = pObj.ParentUI;
    pObj.UI_List = self;
    if self.tbData.bSelected == true then
        self.tbData.Show();
    end
    local fragmentConfig =  FragmentStory.tbConfig[self.tbData.ExploreID]
	if not fragmentConfig then
		return
	end
    local  sShowTxt = ReplaceEllipsis(Text(fragmentConfig.sTitle),20)
	self.TxtName:SetText(sShowTxt)
	self.TxtName1:SetText(sShowTxt)
	self.TxtName2:SetText(sShowTxt)
	if self.tbData.tbConfig.Extension1 then
		local icon = tonumber(self.tbData.tbConfig.Extension1)
	    SetTexture(self.ImgIcon, icon)
	    SetTexture(self.ImgIcon1, icon)
	    SetTexture(self.ImgIcon2, icon)
	end

    WidgetUtils.Collapsed(self.PanelNormal)
    WidgetUtils.Collapsed(self.PanelNot)
    if self.tbData.nGet == 1 then
    	WidgetUtils.Visible(self.PanelNormal);
    	WidgetUtils.Visible(self.ImgIcon)
    	WidgetUtils.Visible(self.ImgIcon1)
    else
    	WidgetUtils.Visible(self.PanelNot);
    	WidgetUtils.Collapsed(self.ImgIcon)
    	WidgetUtils.Collapsed(self.ImgIcon1)
    	WidgetUtils.Collapsed(self.ImgIcon2)
    end
    self:SetSelected(self.tbData.bSelected);
end

function tbClass:SetSelected(bSelect)
    self.tbData.bSelected = bSelect;
    if bSelect then
        WidgetUtils.Visible(self.PanelSelect);
        if self.tbData.nGet == 1 then
        	WidgetUtils.Collapsed(self.ImgLock1)
        else
        	WidgetUtils.Visible(self.ImgLock1)
        end
    else
        WidgetUtils.Hidden(self.PanelSelect);
    end
end

return tbClass;

