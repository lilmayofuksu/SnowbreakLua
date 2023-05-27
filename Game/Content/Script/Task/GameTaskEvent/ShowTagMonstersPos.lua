-- ========================================================
-- @File    : ShowTagMonstersPos.lua
-- @Brief   : 显示所有指定Tag的敌人的标记，该标记不会被小三角标记顶掉
-- @Author  :
-- @Date    :
-- ========================================================

local ShowTagMonstersPos = Class()

ShowTagMonstersPos.RedPoint = nil
function ShowTagMonstersPos:OnTrigger()
    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                function()
                    self:InitMark()
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

function ShowTagMonstersPos:InitMark()
    self.tbMark = {}
    local AllEnemy = self:GetEnemysByTag()
    -- print("ShowTagMonstersPos All Size:", AllEnemy:Length());
    if not AllEnemy then return end
    local FightUMG = UI.GetUI("Fight")

    if FightUMG and FightUMG.uw_fight_monster_tips and AllEnemy then
        if not self.IsShow then
            -- print("ShowTagMonstersPos unshow Size:", AllEnemy:Length())
            for i=1,AllEnemy:Length() do
                local mark = FightUMG.uw_fight_monster_tips:FindUsedItem(AllEnemy:Get(i), UE4.EFightMonsterTipsType.TargetMonster)
                if mark then table.insert(self.tbMark, mark) end
                if self.IsIgnoreAll then --借着遍历TargetMonster的时机，处理Native的提示符突破界限
                    local mon = FightUMG.uw_fight_monster_tips:FindUsedItem(AllEnemy:Get(i), UE4.EFightMonsterTipsType.Monster)
                    local elite = FightUMG.uw_fight_monster_tips:FindUsedItem(AllEnemy:Get(i), UE4.EFightMonsterTipsType.Elite)
                    local boss = FightUMG.uw_fight_monster_tips:FindUsedItem(AllEnemy:Get(i), UE4.EFightMonsterTipsType.Boss)
                    if mon then
                         mon:BreakLimits()
                        -- print("ShowTagMonstersPos BreakLimits Monster:", mon)
                        end
                    if boss then
                        boss:BreakLimits()
                        -- print("ShowTagMonstersPos BreakLimits Boss:", boss)T
                    end
                    if elite then
                        elite:BreakLimits()
                    end
                end
            end
        else
            -- print("ShowTagMonstersPos show Size:", AllEnemy:Length());
            for i=1,AllEnemy:Length() do
                local mark = FightUMG.uw_fight_monster_tips:FindUsedItem(AllEnemy:Get(i), UE4.EFightMonsterTipsType.TargetMonster)
                local bHad = true
                if not mark then
                    mark = FightUMG.uw_fight_monster_tips:CreateItem(AllEnemy:Get(i), UE4.EFightMonsterTipsType.TargetMonster)
                    bHad = false
                end
                if mark then
                    local mon = FightUMG.uw_fight_monster_tips:FindUsedItem(AllEnemy:Get(i), UE4.EFightMonsterTipsType.Monster)
                    local elite = FightUMG.uw_fight_monster_tips:FindUsedItem(AllEnemy:Get(i), UE4.EFightMonsterTipsType.Elite)
                    local boss = FightUMG.uw_fight_monster_tips:FindUsedItem(AllEnemy:Get(i), UE4.EFightMonsterTipsType.Boss)
                    if mon then mon:Reset() end
                    if boss then boss:Reset() end
                    if elite then elite:Reset() end
                    if self.IsIgnoreAll then
                        if mon then mon:BreakLimits() end
                        if boss then boss:BreakLimits() end
                        if elite then elite:BreakLimits() end
                    end
                    if  not bHad then
                        table.insert(self.tbMark, mark)
                    end
                end
            end
        end
    end

    if not self.IsShow then
        for i,v in ipairs(self.tbMark) do
            v:Reset()
        end
        EventSystem.Remove(self.DeathHook)
    end
end

function ShowTagMonstersPos:OnDeath(InMonster)
    self:Reset(InMonster)
end

function ShowTagMonstersPos:Reset(InMonster)
    if not self.tbMark then return end
    for i,v in ipairs(self.tbMark) do
        if v.BindActor == InMonster then
            v:Reset()
            table.remove(self.tbMark, i);
        end
    end

    if #self.tbMark < 1 then
        EventSystem.Remove(self.DeathHook)
    end
end

return ShowTagMonstersPos