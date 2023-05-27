-- ========================================================
-- @File    : uw_role_attribute1.lua
-- @Brief   : 属性详情
-- @Author  :
-- @Date    :
-- ========================================================

local tbAttrDetail = Class("UMG.SubWidget")

function tbAttrDetail:Construct()
    BtnAddEvent(self.Button, function ()
        if self.fClickFun then
            self.fClickFun()
        end
    end)
end

function tbAttrDetail:Display(InParam)
    local sCate = Text(string.format('attribute.%s', InParam.sType))
    self.Text_Cate:SetText(sCate)
    if self.Text_Num then
        if InParam.IsPercent then
            self.Text_Num:SetText(InParam.Attr .. "%")
        else
            self.Text_Num:SetText(InParam.Attr)
        end
    end

    local sPath = Resource.GetAttrPaint(InParam.sType)
    SetTexture(self.ImgAttIcon,sPath)
end

function tbAttrDetail:OnListItemObjectSet(InParm)
    self.Param = InParm.Logic
    local sCate = Text(string.format('attribute.%s',self.Param.sCate))
    self.Text_Cate:SetText(sCate)
    local sPath = Resource.GetAttrPaint(self.Param.sECate)
    SetTexture(self.ImgAttIcon,sPath)
end


return tbAttrDetail