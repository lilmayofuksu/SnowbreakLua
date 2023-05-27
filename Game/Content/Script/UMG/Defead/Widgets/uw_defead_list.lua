-- ========================================================
-- @File    : uw_defead_list.lua
-- @Brief   : 失败词条
-- ========================================================

local tbClass = Class('UMG.SubWidget')

function tbClass:OnListItemObjectSet(pObj)
    self:Init(pObj.Data)
end

function tbClass:Init(cfg)
    self.TxtWarn:SetText(Text(cfg[1]))
end

return tbClass