-- ========================================================
-- @File    : uw_develop_item_data.lua
-- @Brief   : 开发调试界面
-- @Author  :
-- @Date    :
-- ========================================================

local uw_develop_item_data = Class("UMG.SubWidget")

local Data = uw_develop_item_data

Data.bSelect = false
Data.ChangeHandel = nil
Data.Agrs = {}
Data.ChangeEvent = "Data_Change_Event"

function Data:Change(InSelect)
    self.bSelect = InSelect
    EventSystem.TriggerTarget(self, self.ChangeEvent)
end

return uw_develop_item_data
