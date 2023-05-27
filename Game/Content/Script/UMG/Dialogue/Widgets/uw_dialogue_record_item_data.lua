-- ========================================================
-- @File    : uw_dialogue_record_item_data.lua
-- @Brief   : 剧情回顾条目数据
-- @Author  :
-- @Date    :
-- ========================================================

local uw_dialogue_record_item_data = Class("UMG.SubWidget")

local Data = uw_dialogue_record_item_data
Data.Content = nil
Data.bTalk = nil
Data.sName = nil

function Data:Init(InFlag, InName, InContent)
    self.bTalk = InFlag
    self.Content = InContent
    self.sName = InName
end

return Data
