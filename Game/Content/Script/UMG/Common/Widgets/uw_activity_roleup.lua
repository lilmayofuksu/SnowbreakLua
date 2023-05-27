-- ========================================================
-- @File    : uw_activity_roleup.lua
-- @Brief   : 一种少女图标显示
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data
    self:SetIcon(self.tbParam.nIcon, self.tbParam.bGray, self.tbParam.FunClick)
end

---@param nIcon number 头像
---@param bGray bool 是否置灰
---@param funcClick func 点击时的回调
function tbClass:SetIcon(nIcon, bGray, funcClick)
    if (not nIcon) or nIcon <= 0 then
        --- 默认星期三头像
        local pTemp = UE4.UItem.FindTemplate(1, 2, 1, 1)
        SetTexture(self.Girl2, pTemp.Icon)
    else
        SetTexture(self.Girl2, nIcon)
    end
    
    self.Girl2:SetDesaturate(bGray)

    BtnClearEvent(self.BtnItem)
    if funcClick then
        BtnAddEvent(self.BtnItem, funcClick)
    end
end

return tbClass
