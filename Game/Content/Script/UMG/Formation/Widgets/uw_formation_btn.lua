-- ========================================================
-- @File    : uw_formation_btn.lua
-- @Brief   : 编队按钮
-- ========================================================
local tbClass = Class("UMG.Widgets.uw_widgets_common_btn")

function tbClass:Construct()
    BtnAddEvent(self.Btn, function()
        if self.State == BtnState.Select then return end
        if self.OnClickFun then self.OnClickFun(self.LineupIndex) end 
    end)
end

---初始化
function tbClass:OnInit(InTxt, InLineupIndex)
    self.FNumber:SetText(InTxt)
    self.FNumber_1:SetText(InTxt)
    self.LineupIndex = InLineupIndex
end

---选中处理
function tbClass:OnSelect()
    self.Select:SetVisibility(UE4.ESlateVisibility.Visible)
    self.UnSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

---未选中处理
function tbClass:OnUnSelect()
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.UnSelect:SetVisibility(UE4.ESlateVisibility.Visible)
end

return tbClass
