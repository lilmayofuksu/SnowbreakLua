-- ========================================================
-- @File    : ShowTagMonsterPos.lua
-- @Brief   : 显示最近的敌人的危险标志
-- @Author  :
-- @Date    :
-- ========================================================

local ShowTagMonsterPos = Class()

ShowTagMonsterPos.RedPoint = nil
function ShowTagMonsterPos:OnTrigger()
    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                function()
                    self:InitRedPoint()
                end
            },
            0.5,
            false
        )

    self.DeathHook =
    EventSystem.On(
        Event.CharacterDeath,
        function(InMonster)
            if InMonster then
                local UpdateUITimerHandle =
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {
                        self,
                        function()
                            self:OnDeath(InMonster)
                        end
                    },
                    0.01,
                    false
                )
            end
        end
    )
    return true
end

function ShowTagMonsterPos:InitRedPoint()
    self.TargetEnemy = self:GetFirstEnemyByTag()
    if not self.TargetEnemy then 
        return 
    end

    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.uw_fight_monster_tips and self.TargetEnemy then
        self.RedPoint = FightUMG.uw_fight_monster_tips:CreateItem(self.TargetEnemy, UE4.EFightMonsterTipsType.Attack)
    end
end

function ShowTagMonsterPos:OnDeath(InMonster)
    if self.TargetEnemy ~= InMonster then
        return
    end
    self:Reset()
end

function ShowTagMonsterPos:Reset()
    if self.RedPoint and self.RedPoint.BindActor == self.TargetEnemy then
        self.RedPoint:Reset()
    end
    if self.DeathHandle then
        EventSystem.Remove(self.DeathHandle)
    end
end

return ShowTagMonsterPos