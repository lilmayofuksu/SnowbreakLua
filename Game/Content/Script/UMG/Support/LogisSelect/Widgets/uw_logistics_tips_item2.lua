-- ========================================================
-- @File    : uw_logistics_tips_item2.lua
-- @Brief   : 角色后勤Tip2 item
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")


tbClass.tbTips = {
    {Des = Text("tip.support_equip_ok")},
    {Des = Text("tip.support_replace_ok")},
    {Des = Text("tip.support_unload_ok")},
}

tbClass.tbQuality = {
    1700001,
    1700002,
    1700003,
    1700004,
    1700005,
}

function tbClass:Display(InCard)
    if not InCard then return end
    self:TipAttrList(InCard)
    self.Level:OnOpen({nStar = InCard:Break(),nLv = InCard:EnhanceLevel(), nMaxStar = Logistics.GetBreakMax(InCard) - 1})
    self.TextName:SetText(Text(InCard:I18N()))
    self.TxtType:SetText(Text(Logistics.tbTeamDes[InCard:Detail()]))
    SetTexture(self.ImgType, Item.SupportTypeIcon[InCard:Detail()])
    SetTexture(self.ImgQuality,self.tbQuality[InCard:Color()])
    self.Quality:Set(InCard:Color())
end

--- 属性列表
---@param InType integer 属性列表
function tbClass:TipAttrList(InItem)
    WidgetUtils.Collapsed(self.Attr1)
    WidgetUtils.Collapsed(self.Attr2)
    WidgetUtils.Collapsed(self.Attr3)
    WidgetUtils.Collapsed(self.SubAttr1)
    WidgetUtils.Collapsed(self.SubAttr2)

    local MainAttrList = Logistics.GetMainAttr(InItem)
    local tbSubAttr = Logistics.GetSubAttr(InItem)
    for _, tbMainAttr in pairs(MainAttrList) do
        local tbMainParam = {
            nValue = tbMainAttr.Attr,
            sType = tbMainAttr.sType,
            sDes = Text(string.format('attribute.%s', tbMainAttr.sType)),
        }
        self["Attr".._]:Display(tbMainParam)
        WidgetUtils.HitTestInvisible(self["Attr".._])
    end

    if tbSubAttr then
        local tbSubParam = {
            nValue = tbSubAttr.Attr,
            sType = tbSubAttr.sType,
            sDes = Text(string.format('attribute.%s', tbSubAttr.sType)),
            IsPercent = tbSubAttr.IsPercent,
        }
        self.SubAttr1:Display(tbSubParam)
        WidgetUtils.HitTestInvisible(self.SubAttr1)
    end
end
return tbClass