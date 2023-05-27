-- ========================================================
-- @File    : uw_widgets_attribute08.lua
-- @Brief   : 后勤界面属性条目
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Display(InParam)
    if InParam.IsPercent and InParam.nValue then
        InParam.nValue = InParam.nValue .. "%"
    end

    if InParam.bItemInfo then
        local Color = UE4.UUMGLibrary.GetSlateColorFromHex('#111125FF')
        self.Text_Cate:SetColorAndOpacity(Color)
        WidgetUtils.Collapsed(self.IText_Num)
        WidgetUtils.Visible(self.TxtItemNum)
        self.TxtItemNum:SetText(InParam.nValue)
    else
        WidgetUtils.Visible(self.IText_Num)
        WidgetUtils.Collapsed(self.TxtItemNum)
        self.IText_Num:SetText(InParam.nValue)
    end

    if self.ImgBBg and self.ImgBg then
        if InParam.bItemInfo then
            WidgetUtils.Collapsed(self.ImgBBg)
            WidgetUtils.SelfHitTestInvisible(self.ImgBg)
        else
            WidgetUtils.SelfHitTestInvisible(self.ImgBBg)
            WidgetUtils.Collapsed(self.ImgBg)
        end
    end
    self.Text_Cate:SetText(Text(InParam.sDes))
    
    
    SetTexture(self.ImgIcon, Resource.GetAttrPaint(InParam.sType))
end

return tbClass