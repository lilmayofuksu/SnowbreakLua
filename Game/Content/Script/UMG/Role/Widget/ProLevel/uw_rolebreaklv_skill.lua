-- ========================================================
-- @File    : uw_rolebreaklv_skill.lua
-- @Brief   : 
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSkill, function()
        if self.CurCard then
            UI.Open('RoleSkillDetail', {Card = self.CurCard, SkillId = self.SkillId, SkillState = self.SkillState, Idx = 1})
        end
    end)
end

function tbClass:UpdatePanel(tbInfo)
    if not tbInfo or not tbInfo.tbSkillID then
        WidgetUtils.Collapsed(self)
        return
    end

    self.Index = tbInfo.Index
    self.CurCard = tbInfo.CurCard
    self.SkillId = tbInfo.tbSkillID[1]
    self.tbCondition = tbInfo.tbCondition

    local sIcon = UE4.UAbilityLibrary.GetSkillFixInfoStaticId(self.SkillId)
    SetTexture(self.ImgSkillCompleted, sIcon)
    SetTexture(self.ImgSkillGo, sIcon)
    SetTexture(self.ImgSkillLock, sIcon)

    self:UpdateSkillItem()
end

function tbClass:UpdateSkillItem()
    if not self.CurCard then
        WidgetUtils.Collapsed(self.PanelCompleted)
        WidgetUtils.Collapsed(self.PanelGo)
        WidgetUtils.HitTestInvisible(self.PanelLock)
        return
    end

    self.SkillState = RBreak.BreakState.UnActive
    local ProLevel = self.CurCard:ProLevel()

    if ProLevel+1 == self.Index then
        WidgetUtils.HitTestInvisible(self.PanelCurrent)
    else
        WidgetUtils.Collapsed(self.PanelCurrent)
    end
    if ProLevel >= self.Index then
        WidgetUtils.Collapsed(self.PanelLock)
        WidgetUtils.Collapsed(self.PanelGo)
        WidgetUtils.HitTestInvisible(self.PanelCompleted)
        self.SkillState = RBreak.BreakState.Actived
    elseif Condition.Check(self.tbCondition) then
        WidgetUtils.Collapsed(self.PanelLock)
        WidgetUtils.Collapsed(self.PanelCompleted)
        WidgetUtils.SelfHitTestInvisible(self.PanelGo)
        self.SkillState = RBreak.BreakState.Actived
    else
        WidgetUtils.Collapsed(self.PanelCompleted)
        WidgetUtils.Collapsed(self.PanelGo)
        WidgetUtils.HitTestInvisible(self.PanelLock)
        self.SkillState = RBreak.BreakState.Actived
    end
end

return tbClass
