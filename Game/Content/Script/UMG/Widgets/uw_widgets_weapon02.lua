-- ========================================================
-- @File    : uw_widgets_weapon02.lua
-- @Brief   : 武器属性样式
-- ========================================================

local tbClass = Class("UMG.SubWidget")

---@param nNum number
---@param nAdd number
function tbClass:SetData(nNum, nAdd)
    self.TxtNum:SetText(nNum or 1)
    local Str = "attack"
    self.DesTxt:SetText(Text(Str))
    if nAdd then
        WidgetUtils.HitTestInvisible(self.PanelAdd)
        self.TxtAddNum:SetText(nAdd)
    else
        WidgetUtils.Collapsed(self.PanelAdd)
    end
end

return tbClass