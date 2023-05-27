-- ========================================================
-- @File    : uw_widgets_attribute01.lua
-- @Brief   : 属性说明文本1号样式
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Display(InParam)
    self.Text_Cate:SetText(Text(string.format('attribute.%s', InParam.sType)))
    if InParam.IsPercent then
        InParam.Attr = InParam.Attr .. "%"
    end
    self.IText_Num:SetText(InParam.Attr)
end

function tbClass:OnListItemObjectSet(pObj)
    if pObj.Data.nIcon then
        SetTexture(self.ImgIcon, pObj.Data.nIcon)
    end
    if pObj.Data.bItemInfo then
        WidgetUtils.Collapsed(self.IText_Num) 
        WidgetUtils.HitTestInvisible(self.TxtItemNum)
        local Color = UE4.UUMGLibrary.GetSlateColorFromHex('#111125FF')
        self.Text_Cate:SetColorAndOpacity(Color)
        self.TxtItemNum:SetText(pObj.Data.nNum)
    else
        WidgetUtils.HitTestInvisible(self.IText_Num)
        WidgetUtils.Collapsed(self.TxtItemNum)
        self.IText_Num:SetText(pObj.Data.nNum)
        if pObj.Data.sKey == "Attack" then
            Color.SetTextColor(self.IText_Num, "#0E0A8AFF")
        else
            Color.SetTextColor(self.IText_Num, "#0B0B10FF")
        end
    end
    self.Text_Cate:SetText(pObj.Data.sPreWord)
end

return tbClass