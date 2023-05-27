-- ========================================================
-- @File    : uw_widgets_arms_parts_bar.lua
-- @Brief   : 武器配件属性显示条目
-- ========================================================
local tbClass = Class("UMG.SubWidget")

---属性最大值
local MAX_VALUE = 100

function tbClass:OnListItemObjectSet(pObj)
    self:Update(pObj.Data)
end

---更新显示
function tbClass:Update(tbData)
    local nBase = tbData.nBase
    local nAdd = tbData.nAdd
    ---属性名称显示
    self.TxtAttrit:SetText(tbData.Des)
    local nNum = nBase + nAdd
    local Percent = UE4.TArray(0.0)
    ---属性增加
    if nAdd >= 0 then
        WidgetUtils.SelfHitTestInvisible(self.TxtDown)
        self.TxtDown:SetText(nNum)
        Percent:Add(0)
        Percent:Add(nNum / MAX_VALUE)
        Percent:Add(nBase / MAX_VALUE)
    else
        WidgetUtils.SelfHitTestInvisible(self.TxtDown)
        self.TxtDown:SetText(nNum)
        Percent:Add(nBase / MAX_VALUE)
        Percent:Add(0)
        Percent:Add(nNum / MAX_VALUE)
    end
    self.Bar:SetPercents(Percent)
end

return tbClass
