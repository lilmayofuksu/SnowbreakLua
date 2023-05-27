-- ========================================================
-- @File    : uw_activity_skill_tab.lua
-- @Brief   : 
-- ========================================================

local tbClass = Class('UMG.SubWidget')

function tbClass:Construct()
    BtnAddEvent(self.BtnSeclet, function() self:OnClick() end)
end

function tbClass:OnListItemObjectSet(obj)
    self.tbParam = obj.Data
    self:Show()
end

function tbClass:Show()
    self.OnText:SetText(Text(self.tbParam[1]))
    self.OffText:SetText(Text(self.tbParam[1]))
    WidgetUtils.Collapsed(self.Group_on)
    WidgetUtils.SelfHitTestInvisible(self.Group_off)
    if self.tbParam[2] then
        self:OnClick()
    end
end

function tbClass:OnClick()
    if self.Group_On:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
        return
    end
    if self.tbParam[3] then
        self.tbParam[3](self)
    end
    self:PlayAnimation(self.Select)
end

return tbClass