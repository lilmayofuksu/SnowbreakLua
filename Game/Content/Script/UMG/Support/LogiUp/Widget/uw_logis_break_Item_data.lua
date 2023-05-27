-- ========================================================
-- @File    : uw_logis_break_Item_data.lua
-- @Brief   : 升级界面属性数据
-- @Author  :
-- @Date    :
-- ========================================================


local  AttrData ={}

AttrData.Name = ""
AttrData.nDelt = 0
AttrData.nAttr = 0
function AttrData:OnInit(tbParam)
    self.Name = tbParam.Name
    self.New = tbParam.New
    self.Now = tbParam.Now
end

return AttrData