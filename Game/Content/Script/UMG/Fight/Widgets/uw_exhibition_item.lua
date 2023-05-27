-- ========================================================
-- @File    : uw_exhibition_item.lua
-- @Brief   : 玩家信息
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Init(sName)
    self.TxtName:SetText(sName)
end

return tbClass;
