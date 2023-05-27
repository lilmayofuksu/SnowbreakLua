-- ========================================================
-- @File    : uw_levelinfo_skill.lua
-- @Brief   : 关卡详情技能
-- ========================================================

local tbClass = Class('UMG.SubWidget')

function tbClass:Show()
    for i = 1, 3 do
        local member = Formation.GetMember(i - 1)
        if member and member:GetCard() then
            WidgetUtils.Visible(self['Role'..i])
            local Card = member:GetCard()
            local g,d,p,l = Card:Genre(), Card:Detail(), Card:Particular(), Card:Level()
            self['Role'..i]:Set(UE4.UItem.FindTemplate(g,d,p,l).Icon, function() self:OnClick(Card, i) end)
            if i == 1 then self:OnClick(Card, 1) end
        else
            WidgetUtils.Collapsed(self['Role'..i])
        end
    end
end

function tbClass:OnClick(pCard, index)
    for i = 1, 3 do
        self['Role'..i]:SetRenderOpacity(i == index and 1 or 0.6)
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self['Role'..i].Select, i == index)
    end
    self['Role'..index]:PlayAnimation(self['Role'..index].Click1)
    local ArrayID = RoleCard.GetProLevelSkillID(pCard)
    local ProLevel = pCard:ProLevel()
    ProLevel = ProLevel == 0 and 1 or ProLevel
    SetTexture(self.Image_1, 2001000 + ProLevel)
    if ArrayID and ArrayID:Length() > 0 then
        local id = ArrayID:Get(1)
        self.TxtContent:SetContent(SkillDesc(id))
        self.TxtTitle:SetText(SkillName(id))
    else
        self.TxtContent:SetContent(Localization.Get("ui.TxtRolebreaklvNot2"))
        self.TxtTitle:SetText(Localization.Get("ui.TxtRolebreaklvNot2"))
    end
end

return tbClass