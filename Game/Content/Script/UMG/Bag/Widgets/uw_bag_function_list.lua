-- ========================================================
-- @File    : uw_bag_function_list.lua
-- @Brief   : 仓库分类标签
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(
        self.BtnUnchecked,
        function()
            if not self.ParentUI.bSellMode then
                self.ParentUI:OpenPage(self.nPage)
            end
        end
    )
end

function tbClass:OnListItemObjectSet(pObj)
    self.nPage = pObj.Data.nPage
    self.ParentUI = pObj.ParentUI
    pObj.SubUI = self
    self:SetDisbale(pObj.bDisbale)
    self:SetChecked(pObj.bChecked)
    self:SetRedDot(Item.GetDotState(self.nPage))
    SetTexture(self.ImgCheck, pObj.Data.nIcon)
    SetTexture(self.ImgUncheck, pObj.Data.nIcon)
    SetTexture(self.ImgDisable, pObj.Data.nIcon)

    self.TxtBtn:SetText(Text(pObj.Data.sTitle))
    self.TxtBtnUnCheck:SetText(Text(pObj.Data.sTitle))
    self.TxtBtnDisable:SetText(Text(pObj.Data.sTitle))
end

function tbClass:SetChecked(bChecked)
    if bChecked then
        WidgetUtils.Visible(self.Checked)
        WidgetUtils.Collapsed(self.Unchecked)
        WidgetUtils.Collapsed(self.Disable)
    else
        WidgetUtils.Visible(self.Unchecked)
        WidgetUtils.Collapsed(self.Checked)
        WidgetUtils.Collapsed(self.Disable)
    end
end

function tbClass:SetDisbale(bDisbale)
    if bDisbale then
        WidgetUtils.Visible(self.Disable)
        WidgetUtils.Collapsed(self.Checked)
        WidgetUtils.Collapsed(self.Unchecked)
    else
        WidgetUtils.Visible(self.Unchecked)
        WidgetUtils.Collapsed(self.Disable)
        WidgetUtils.Collapsed(self.Checked)
    end
end

function tbClass:SetRedDot(bNew)
    if bNew then
        WidgetUtils.Visible(self.New)
    else
        WidgetUtils.Collapsed(self.New)
    end
end

return tbClass
