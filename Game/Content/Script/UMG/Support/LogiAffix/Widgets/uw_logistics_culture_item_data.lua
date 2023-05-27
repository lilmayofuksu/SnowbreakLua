-- ========================================================
-- @File    : umg_logistics_culture.lua
-- @Brief   : 后勤养成属性界面
-- @Author  :
-- @Date    :
-- ========================================================


local  tbData = Class("UMG.SubWidget")

function tbData:OnInit(tbParam)
    self.Name = tbParam.Name
    self.nAttr = tbParam.nAttr
end
return tbData