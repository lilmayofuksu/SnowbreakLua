-- ========================================================
-- @File    : umg_friend_list_item.lua
-- @Brief   : 好友界面分类标签
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(
        self.BtnSelect,
        function()
            if self.funcOnClick then
                self.funcOnClick()
            end
        end
    )
end

function tbClass:OnListItemObjectSet(pObj)
    self.Data = pObj.Data
    self.funcOnClick = pObj.Data.funcOnClick
    SetTexture(self.IconBgFirst, pObj.Data.nIcon)
    SetTexture(self.IconBgFirst_1, pObj.Data.nIcon)
    self.TxtBg:SetText(pObj.Data.sTitle)
    self.TxtCheck:SetText(pObj.Data.sTitle)
    self:SetSelected(pObj.Data.bSelected)
    self:SetNew(pObj.Data.bNew)
    pObj.Data.SubUI = self
end

function tbClass:SetSelected(bSelected)
    if bSelected then
        WidgetUtils.SelfHitTestInvisible(self.Check)
        WidgetUtils.Collapsed(self.Bg)
        self.p1:ActivateSystem()
    else
        WidgetUtils.Collapsed(self.Check)
        WidgetUtils.SelfHitTestInvisible(self.Bg)
        self.p1:DeactivateSystem()
    end
end

function tbClass:SetNew()
    if self.Data.bNew then
        WidgetUtils.Visible(self.ImgNew)
    else
        WidgetUtils.Collapsed(self.ImgNew)
    end
end

return tbClass
