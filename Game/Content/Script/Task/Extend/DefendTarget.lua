-- ========================================================
-- @File    : DefendTarget.lua
-- @Brief   : 用于DefendTarget条目的保护物
-- @Author  :
-- @Date    :
-- ========================================================
local DefendTarget = Class()

function DefendTarget:CreateUIItem(InText)
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.uw_fight_monster_tips then
        self.UIItem = FightUMG.uw_fight_monster_tips:CreateTaskItem(self, UE4.EFightMonsterTipsType.DefendTarget, "")
        self:UpdateUIItem(1)
        if self.UIItem then
            self.UIItem.TxtDefenseName:SetText(InText)
            self.UIText = InText
        end
    end
end

function DefendTarget:ResetUIItem()
    if self.UIItem then
        self.UIItem:Reset()
    end
end

function DefendTarget:UpdateUIItem(HealthPercent)
    if self.UIItem then
        self.UIItem:SetDefendTargetPercent(HealthPercent)
    end
    self.NowHealthPercent = HealthPercent
end

return DefendTarget
