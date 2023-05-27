-- ========================================================
-- @File    : uw_logistics_attr_Item_data.lua
-- @Brief   : 角色后勤属性数据
-- @Author  :
-- @Date    :
-- ========================================================

local  tbData = Class("UMG.SubWidget")

tbData.sCate = ""
tbData.New = 0
tbData.nData = 0
tbData.ESign=0

function tbData:OnInit(tbParam)
    self.sCate = tbParam.Name
    self.New = tbParam.New
    self.nData = tbParam.Now
    self.ESign = tbParam.ESign
end

return tbData