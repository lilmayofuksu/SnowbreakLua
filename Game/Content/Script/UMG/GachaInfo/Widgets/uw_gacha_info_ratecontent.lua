-- ========================================================
-- @File    : uw_gacha_info_ratecontent.lua
-- @Brief   : 抽奖概率展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
    local data = pObj.Data
    self.TxtContent:SetText(data.sTxt)
end

return tbClass