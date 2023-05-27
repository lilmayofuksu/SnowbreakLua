-- ========================================================
-- @File    : uw_role_attribute_num.lua
-- @Brief   : 角色详情
-- @Author  :
-- @Date    :
-- ========================================================

local tbDetailTitle=Class("UMG.SubWidget")
tbDetailTitle.tbDes={'role','weapon','supporter','total'}

function tbDetailTitle:OnInit(InParam)
   -- print('tbDetailTitle')
end


function tbDetailTitle:CateDes(InIndex)
    self.ETextCate:SetText(string.upper(self.tbDes[InIndex]))
    self.TextCate:SetText(self:GetTitleDes(InIndex))
end

--- 获取描述
function tbDetailTitle:GetTitleDes(Inindex)
    return Text('ui.'..self.tbDes[Inindex])
end

function tbDetailTitle:SignDes()
    Color.Set(self.ETextCate,Color.White)
    Color.Set(self.TextCate,Color.White)
end

return tbDetailTitle