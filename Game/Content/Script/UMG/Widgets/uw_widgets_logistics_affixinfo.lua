local tbClass = Class("UMG.SubWidget")

function tbClass:OnOpen(InItem)
    for i = 1, 2 do
        local affixs = InItem:GetAffix(i)
        self["TxtAffixIntro"..i]:SetText(Logistics.GetAffixShowNameByTarray(affixs))
    end
    local affix3 = InItem:GetAffix(3)
    if affix3 and affix3:Length() > 0 then
        local key = affix3:Get(1)
        local value = affix3:Get(2)
        if key and key ~= 0 and value and value ~= 0 then
            self.TxtAffixIntro3:SetText(Logistics.GetAffixShowNameByTarray(affix3))
            WidgetUtils.Collapsed(self.PanelAffix3lock)
            WidgetUtils.HitTestInvisible(self.PanelAffix3)
            return
        end
    end
    WidgetUtils.HitTestInvisible(self.PanelAffix3lock)
    WidgetUtils.Collapsed(self.PanelAffix3)
end
return tbClass