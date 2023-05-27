-- ========================================================
-- @File    : uw_attribute.lua
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
    elseif self.IText_Num then
        if InParam.IsPercent then
            self.IText_Num:SetText(InParam.Attr .. "%")
        else
            self.IText_Num:SetText(InParam.Attr)
        end
    end

    local sPath = Resource.GetAttrPaint(InParam.sType)
    SetTexture(self.ImgAttIcon,sPath)
end

function tbAttrDetail:OnListItemObjectSet(InParm)
    self.Param = InParm.Logic
    local sCate = Text(string.format('attribute.%s',self.Param.sCate))
    self.Text_Cate:SetText(sCate)
    self.IText_Num:SetText(self.Param.nData)
    local sPath = Resource.GetAttrPaint(self.Param.sECate)
    SetTexture(self.ImgAttIcon, sPath)
    if self.Param.sCate == 'Defence' then
        self.IText_Num:SetText(TackleDecimalUnit(self.Param.nData))
    end
    if self.Param.sCate == "CriticalDamage" or self.Param.sCate == "CriticalValue" then
        local sTxt = TackleDecimalUnit(self.Param.nData,'%')
        local sReal = UE4.UKismetStringLibrary.Replace(sTxt, '%%', '%')
        self.IText_Num:SetText(sReal)
    end
    self:ShowBG(self.Param.bShowBG)
end

function tbAttrDetail:ShowBG(bShow)
    if bShow then
        WidgetUtils.HitTestInvisible(self.Bg)
    else
        WidgetUtils.Collapsed(self.Bg)
    end
end

function tbAttrDetail:SetColor(sColor)
    if type(sColor) == "string" then
        Color.SetTextColor(self.IText_Num, sColor)
    end
end

function tbAttrDetail:ShowSkillInfo(tbParam)
    local sName = SkillName(tbParam.nSkillId)
    self.Text_Cate:SetText(sName)
    local sIcon = UE4.UAbilityLibrary.GetSkillIcon(tbParam.nSkillId)
    SetTexture(self.AttrIcon, sIcon)
    if tbParam.fClickFun then
        self.fClickFun = tbParam.fClickFun
    end
end

return tbAttrDetail