

-- ========================================================
-- @File    : uw_Logistics_show_item_data.lua
-- @Brief   : 后勤展示条目
-- @Author  :
-- @Date    :
-- ========================================================
local uw_Logistics_show_item_data =Class("UMG.SubWidget")
local LogiShowData = uw_Logistics_show_item_data

LogiShowData.SelectChange = "SELECT_CHANGE"

function LogiShowData:OnInit(tbParam)
    self.bSelect = tbParam.bSelect
    self.OnClick = tbParam.OnClick
    self.pItem = tbParam.pItem
end

function LogiShowData:SetSelect(bSelect)
    self.bSelect = bSelect
    EventSystem.TriggerTarget(self, self.SelectChange,self.bSelect)
end

function LogiShowData:OnDestruct()
    EventSystem.Remove(self.SelectChange)
end

return LogiShowData