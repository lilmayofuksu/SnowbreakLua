-- ========================================================
-- @File    : uw_arms_attribute_item.lua
-- @Brief   : 武器界面属性条目
-- ========================================================
local tbClass = Class("UMG.SubWidget")

--- 后勤界面 uw_logistics_tips_item调用此接口
function tbClass:Display(InParam)
    self.TextName:SetText(Text(InParam.sDes))
    if InParam.IsPercent then
        InParam.nValue = InParam.nValue .. "%"
    end
    self.TextNum:SetText(InParam.nValue)
    SetTexture(self.ImgIcon, Resource.GetAttrPaint(InParam.sType))
end

function tbClass:OnListItemObjectSet(pObj)
    local tbInfo = pObj.Data
    if not tbInfo then return end
    if tbInfo.nFlag == 2 then
        WidgetUtils.HitTestInvisible(self.Not)
        WidgetUtils.Collapsed(self.Normal)
        return
    end
    WidgetUtils.Collapsed(self.Not)
    WidgetUtils.SelfHitTestInvisible(self.Normal)
    self.TextName:SetText(Text(tbInfo.sDes))
    self.TextNum:SetText(tbInfo.nValue)
    SetTexture(self.ImgIcon, tbInfo.nIcon)
    if tbInfo.ECate == "CriticalDamage" then
        self.TextNum:SetText(tbInfo.nValue..'%')
    end
end
return tbClass
