-- ========================================================
-- @File    : uw_fight_teammate_title.lua
-- @Brief   : 战斗界面队友头顶 title
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    WidgetUtils.Collapsed(self.BarHpRed)
    WidgetUtils.Collapsed(self.Bar)
    WidgetUtils.Collapsed(self.BarDie)
    WidgetUtils.Collapsed(self.BarDie_1)
    WidgetUtils.Collapsed(self.PanelTeamBar)
end

function tbClass:SetName(InName)
    self.Name:SetText(InName)
end

function tbClass:GetReviveBar()
    return self.BarDie
end

function tbClass:GetOtherReviveBar()
    return self.BarTeamHeal
end

function tbClass:GetPanelTeamBar()
    return self.PanelTeamBar
end

function tbClass:PlayOtherReviveAnim(bPlay)
    if bPlay then
        if not self:IsAnimationPlaying(self.RevivePeople) then
            self:PlayAnimation(self.RevivePeople, 0)
        end
    else
        if self:IsAnimationPlaying(self.RevivePeople) then
            self:StopAnimation(self.RevivePeople, 0)
        end
        self:PlayAnimation(self.Reset)
    end
end

function tbClass:SetReviveBarShow(InShow)
    if InShow then 
        WidgetUtils.SelfHitTestInvisible(self.PanelRevive)
    else 
        WidgetUtils.Collapsed(self.PanelRevive)
    end
end

function tbClass:SetNameShow(InShow)
    if InShow then 
        WidgetUtils.SelfHitTestInvisible(self.Name)
    else 
        WidgetUtils.Collapsed(self.Name)
    end
end

return tbClass
