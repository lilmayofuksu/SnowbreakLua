-- ========================================================
-- @File    : uw_widgets_frameicon.lua
-- @Brief   : 玩家头像
-- ========================================================

local tbClass = Class("UMG.SubWidget")

---@param nIcon number 头像
---@param funcClick func 点击时的回调
function tbClass:Set(nIcon, funcClick)
    if (not nIcon) or nIcon <= 0 then
        --- 默认星期三头像
        local pTemp = UE4.UItem.FindTemplate(1, 2, 1, 1)
        SetTexture(self.icon, pTemp.Icon)
    else
        SetTexture(self.icon, nIcon)
    end
    BtnClearEvent(self.BtnCheck)
    if funcClick then
        BtnAddEvent(self.BtnCheck, funcClick)
    end
end

return tbClass
