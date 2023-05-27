-- ========================================================
-- @File    : uw_dialogue_record_item.lua
-- @Brief   : 剧情回顾条目
-- @Author  :
-- @Date    :
-- ========================================================

local uw_dialogue_record_item = Class("UMG.SubWidget")

local Item = uw_dialogue_record_item

function Item:OnListItemObjectSet(InObj)
    if not InObj then
        return
    end

    if InObj.bTalk then
        self.Record:SetText(InObj.sName .. "   " .. InObj.Content)
        self.Record:SetJustification(UE4.ETextJustify.Left)
    else
        self.Record:SetJustification(UE4.ETextJustify.Right)
        self.Record:SetText(InObj.Content)
    end
end

return Item
