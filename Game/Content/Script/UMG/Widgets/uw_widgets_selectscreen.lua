-- ========================================================
-- @File    : uw_widgets_selectscreen.lua
-- @Brief   : 道具选择
-- ========================================================

---@class tbClass
---@field List UTileView
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClose, function() if self.fClose then self.fClose() end end)
    self.List:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.ListFactory = Model.Use(self)
    self:DoClearListItems(self.List)
end

function tbClass:InitScreen(tbSortParam)
    WidgetUtils.SelfHitTestInvisible(self.Screen)
    self.Screen:Init(tbSortParam)
end

---显示选择列表
function tbClass:Show(tbParam, fClose)
    self.fClose = fClose
    if fClose then
        WidgetUtils.Visible(self.BtnClose)
    else
        WidgetUtils.Collapsed(self.BtnClose)
    end

    self:DoClearListItems(self.List)
    for _, param in ipairs(tbParam) do
        local pObj = self.ListFactory:Create(param)
        self.List:AddItem(pObj)
    end

    if #tbParam > 0 then
        WidgetUtils.Collapsed(self.PanelEmpty)
    else
        WidgetUtils.HitTestInvisible(self.PanelEmpty)
    end
end

return tbClass