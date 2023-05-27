-- ========================================================
-- @File    : uw_bag_function_list.lua
-- @Brief   : 仓库分类标签
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(
        self.BtnSelect,
        function()
            self.ParentUI:OnOpen(self.nPage)
        end
    )
    self.ItemPath = "/Game/UI/UMG/Riki/Widgets/uw_riki_tab2.uw_riki_tab2_C"
end

function tbClass:OnListItemObjectSet(pObj)
    self.nPage = pObj.Data.nPage
    self.ParentUI = pObj.ParentUI
    pObj.SubUI = self
    self:SetMainTab(pObj)
    self:SetChildTab(pObj.bChecked)
end

function tbClass:SetMainTab(pObj)
    SetTexture(self.IconBg, pObj.Data.nIcon)
    SetTexture(self.IconBg_1, pObj.Data.nIcon)
    SetTexture(self.IconBgSecond, pObj.Data.nIcon)
    SetTexture(self.IconCheckSecond, pObj.Data.nIcon)
    self.TxtBg:SetText(Text(pObj.Data.TxtTitle))
    self.TxtBg_1:SetText(Text(pObj.Data.TxtTitle))
    self.TxtCheckSecond:SetText(Text(pObj.Data.TxtTitle))
    self.TxtBgSecond:SetText(Text(pObj.Data.TxtTitle))
    if pObj.bChecked then
        WidgetUtils.Visible(self.Check)
    else
        WidgetUtils.Collapsed(self.Check)
    end
end

function tbClass:SetChildTab(bChecked)
    if bChecked and self.ParentUI.tbPage[self.nPage] and self.ParentUI.tbPage[self.nPage].tbChildPage then
        local tbChildList = self.ParentUI.tbPage[self.nPage].tbChildPage
        WidgetUtils.Visible(self.SecondTab)
        self.ListSecondary:ClearChildren()
        for idx, tbInfo in ipairs(tbChildList) do
            local pWidget = LoadWidget(self.ItemPath)
            if pWidget then
                local tbData = {sTitle=tbInfo[1], bChecked=false, root=self.ParentUI, parent = self, nIndex = idx}
                self.ListSecondary:AddChild(pWidget)
                pWidget:UpdatePanel(tbData)
            end
        end

        self.ParentUI.ListFunction:RequestRefresh()
    else
        WidgetUtils.Collapsed(self.SecondTab)
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
