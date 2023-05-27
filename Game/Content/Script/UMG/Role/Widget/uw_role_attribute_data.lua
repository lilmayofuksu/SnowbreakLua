-- ========================================================
-- @File    : uw_role_attribute_data.lua
-- @Brief   : 属性详情
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")
tbClass.Cate = ''
tbClass.ECate = ''
tbClass.Data = ''

function tbClass:OnInit(InParam)
    self.sCate = InParam.Cate
    self.sECate = InParam.ECate
    self.nData = InParam.Data
    self.IsPercent = InParam.IsPercent
    self.bShowBG = InParam.ShowBG
end

return tbClass