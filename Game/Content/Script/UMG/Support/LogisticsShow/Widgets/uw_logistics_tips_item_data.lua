

-- ========================================================
-- @File    : uw_logistics_tips_item_data.lua
-- @Brief   : 后勤展示条目
-- @Author  :
-- @Date    :
-- ========================================================
local uw_logistics_tips_item_data =Class("UMG.SubWidget")
local LogiTipData = uw_logistics_tips_item_data

function LogiTipData:OnInit(tbParam)
    self.Model = tbParam.Model
    self.SlotNum=tbParam.SlotNum
end

return LogiTipData