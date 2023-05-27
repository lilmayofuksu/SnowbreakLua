-- ========================================================
-- @File    : uw_bag_function_list.lua
-- @Brief   : 仓库分类标签
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(
        self.BtnSelect,
        function()
            local nIdx = self.RootUI.tbPage[self.ParentUI.nPage].tbChildPage[self.nIndex][2]
            self.RootUI:UpdateList(self.ParentUI.nPage, nIdx)
            local nNum = self.ParentUI.ListSecondary:GetChildrenCount()
            for idx=1,nNum do
                local pTab = self.ParentUI.ListSecondary:GetChildAt(idx-1)
                if idx == self.nIndex then
                    pTab:SetCheck(true)
                else
                    pTab:SetCheck(false)
                end
            end
        end
    )
end

function tbClass:UpdatePanel(tbData)
    self.RootUI = tbData.root
    self.ParentUI = tbData.parent
    self.nIndex = tbData.nIndex
    self:SetTab(tbData)
end

function tbClass:SetTab(tbData)
    self.TxtBgFirst:SetText(Text(tbData.sTitle))
    self.TxtBgFirst_1:SetText(Text(tbData.sTitle))
    self:SetCheck(tbData.bChecked)
end

function tbClass:SetCheck(bChecked)
    if bChecked then
        WidgetUtils.Visible(self.CheckFirst)
    else
        WidgetUtils.Collapsed(self.CheckFirst)
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
