-- ========================================================
-- @File    : uw_photograph_list.lua
-- @Brief   : 角色条目
-- ========================================================
---@class tbClass
local tbClass = Class("UMG.SubWidget")


function tbClass:OnListItemObjectSet(InObj)
    InObj.pItem = self
    self.pCard = InObj.Data.pCard
    self.TxtName:SetText(self.pCard.ShowName)
    self:OnSelect(InObj.Data.bSelect)
end

function tbClass:OnSelect(bSelect)
    if bSelect then
        WidgetUtils.SelfHitTestInvisible(self.Select)
    else
        WidgetUtils.Collapsed(self.Select)
    end
end

return tbClass