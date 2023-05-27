-- ========================================================
-- @File    : uw_role_detail_tips_item_data.lua
-- @Brief   : 角色详情
-- @Author  :
-- @Date    :
-- ========================================================

local tbDetailData=Class("UMG.SubWidget")

function tbDetailData:OnInit(InParam)
   self.sUIType = InParam.sUIType
   self.InName = InParam.sName
   self.sECate = InParam.ECate
   self.InRoleAttr = InParam.fRoleAttr
   self.InWeaponAttr = InParam.fWeaponAttr
   self.InLogisAttr = InParam.fLogisAttr
   self.InBase = InParam.fBase
   self.InScale = InParam.fScale
   self.InTotal = InParam.fTotal
end



return tbDetailData