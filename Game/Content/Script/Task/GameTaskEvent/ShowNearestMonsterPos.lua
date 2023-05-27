-- ========================================================
-- @File    : ShowNearestMonsterPos.lua
-- @Brief   : 显示最近的敌人的危险标志
-- @Author  :
-- @Date    :
-- ========================================================
local ShowNearestMonsterPos = Class()

ShowNearestMonsterPos.minDistance = 0
ShowNearestMonsterPos.RedPoint = nil
function ShowNearestMonsterPos:OnTrigger()
    if not self.IsShow then
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, function()
            if TaskCommon.ShowMonsterPos then
                EventSystem.TriggerTarget(TaskCommon, "ResMonsterRedPoint")
            end
        end}, 0.5, false)
        return true
    end

    self.DeathHook = EventSystem.On(Event.CharacterDeath, function(InMonster)
        if InMonster then
            local UpdateUITimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, function()
                self:OnDeath(InMonster)
            end}, 0.01, false)
        end
    end)

    self.ResRedPointHook = EventSystem.OnTarget(TaskCommon, "ResMonsterRedPoint", function()
        if self.Reset then
            self:Reset()
        end
    end)

    TaskCommon.AddHandle(self.ResRedPointHook)
    TaskCommon.AddHandle(self.DeathHook)

    self.EndLevelEvent = EventSystem.On(Event.OnLevelFinish, function()
        if self.Reset then
            self:Reset()
        end
    end)

    self.UpdateRedTimer = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, function()
        self:UpdateRedPoint()
    end}, 1, true)

    return true
end

function ShowNearestMonsterPos:UpdateRedPoint()
    self:ResetRed()
    self.minDistance = 0
    local enemyArray = self:GetAllEnemyActors()
    if enemyArray:Length() == 0 then
        return
    end
    local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    local playPos = controller:K2_GetPawn():K2_GetActorLocation()
    local enemy
    if enemyArray:Length() > 0 then
        for i = 1, enemyArray:Length() do
            local enemy = enemyArray:Get(i)
            local enemyPos = enemy:K2_GetActorLocation()
            if self:GetDistance(playPos, enemyPos) then
                self.TargetEnemy = enemy
            end
        end
    end

    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.uw_fight_monster_tips and self.TargetEnemy then
        if self:CheckMonsterState(self.TargetEnemy, UE4.EFightMonsterTipsType.Monster) or
        self:CheckMonsterState(self.TargetEnemy, UE4.EFightMonsterTipsType.Elite) or
        self:CheckMonsterState(self.TargetEnemy, UE4.EFightMonsterTipsType.Boss) then
            return
        end
        self.RedPoint = FightUMG.uw_fight_monster_tips:CreateItem(self.TargetEnemy, UE4.EFightMonsterTipsType.Attack)
        if self.RedPoint then
            TaskCommon.ShowMonsterPos = true
        end
    end
end

function ShowNearestMonsterPos:CheckMonsterState(InActor, MonsterTipsType)
    local FightUMG = UI.GetUI("Fight")
    local TipsItem = FightUMG.uw_fight_monster_tips:FindUsedItem(self.TargetEnemy, UE4.EFightMonsterTipsType.Monster)
    if TipsItem and TipsItem.bCanShow and TipsItem.Visibility == UE4.ESlateVisibility.HitTestInvisible then
        return true
    end
end

function ShowNearestMonsterPos:GetDistance(player, monster)
    local function pow2(input)
        return input * input
    end
    local dis = math.sqrt(pow2(player.X - monster.X) + pow2(player.Z - monster.Z) + pow2(player.Y - monster.Y))
    if self.minDistance == 0 or self.minDistance > dis then
        self.minDistance = dis
        return true
    end
    return false
end

function ShowNearestMonsterPos:OnDeath(InMonster)
    local enemyArray = self:GetAllEnemyActors()
    if enemyArray:Length() > 0 then
        return
    end
    self:ResetRed()
end

function ShowNearestMonsterPos:ResetRed()
    if IsValid(self.RedPoint) and self.RedPoint.BindActor == self.TargetEnemy then
        self.RedPoint:Reset()
    end
end

function ShowNearestMonsterPos:Reset()
    self:ResetRed()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.UpdateRedTimer)
    EventSystem.Remove(self.DeathHook)
    EventSystem.Remove(self.AISwitchTarget)
    EventSystem.Remove(self.ResRedPointHook)
    EventSystem.Remove(self.EndLevelEvent)
    TaskCommon.ShowMonsterPos = false
end

return ShowNearestMonsterPos
