-- ========================================================
-- @File    : uw_general_sort_list_item.lua
-- @Brief   : 排序筛选界面的按钮
-- ========================================================
local tbClass = Class("UMG.SubWidget");

---初始化
function tbClass:Init(sText, OnClick, bSelected)
    self.untext:SetText(sText);
    self.text:SetText(sText);
    self.OnClick = OnClick;

    self:Selected(bSelected or false);
end

---点击事件
function tbClass:OnMouseButtonDown(MyGeometry, InTouchEvent)
    if self.OnClick then
        self.OnClick()
    end;
    return UE4.UWidgetBlueprintLibrary.Handled()
end

---设置选中状态
function tbClass:Selected(bSelected)
    if bSelected then
        self.Switcher:SetActiveWidgetIndex(1);
    else
        self.Switcher:SetActiveWidgetIndex(0);
    end
end

return tbClass;