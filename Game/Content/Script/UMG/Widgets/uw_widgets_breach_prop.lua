-- ========================================================
-- @File    : uw_widgets_breach_prop.lua
-- @Brief   : 通用材料显示
-- @Author  :
-- @Date    :
-- ========================================================

local breach_prop = Class("UMG.SubWidget")

function breach_prop:OnListItemObjectSet(InObj)
    if InObj == nil or InObj.Data == nil then
        return
    end
    --
end
return breach_prop
