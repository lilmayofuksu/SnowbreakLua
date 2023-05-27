-- ========================================================
-- @File    : uw_logistics_affix_info2.lua
-- @Brief   : 特殊洗练界面信息展示
-- ========================================================

local  tbAffixInfo2 = Class("UMG.BaseWidget")

function tbAffixInfo2:Construct()
    BtnAddEvent(
        self.BtnAffixClear, 
        function()
            self.OnClickFunc()
        end 
    )
end

function tbAffixInfo2:OnOpen(InParam)
    local cfg = Item.tbBreakLevelLimit[InParam.SupportCard:BreakLimitID()]
    self:SetState(InParam.SupportCard:EnhanceLevel() == cfg[#cfg])
    self.OnClickFunc = InParam.OnClick
    self.TxtIntro:SetText(Logistics.GetAffixShowName(InParam.TxtTitle, InParam.TxtCont))
end

function tbAffixInfo2:SetState(IsMaxLevel)
    WidgetUtils.Collapsed(self.PanelOff)
    WidgetUtils.Collapsed(self.PanelOn)
    if IsMaxLevel then
        WidgetUtils.SelfHitTestInvisible(self.PanelOn)
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelOff)
    end

end

return tbAffixInfo2