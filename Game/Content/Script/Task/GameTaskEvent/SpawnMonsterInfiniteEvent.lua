-- ========================================================
-- @File    : KillMonsterBase.lua
-- @Brief   :
-- @Author  :
-- @Date    :
-- ========================================================

---@class SpawnMonsterInfinite : GameTask_Execute
local SpawnMonsterInfinite = Class()

SpawnMonsterInfinite.CurrentIndex = 1
SpawnMonsterInfinite.WaveNum = 0

SpawnMonsterInfinite.DeathHandle = nil

function SpawnMonsterInfinite:TrySpawn()
    self.CurrentIndex = 1
    self.WaveNum = self.TableIDs:Length()
    if self.WaveNum <= 0 then
        return false
    end

    self.DeathHandle =
        EventSystem.On(
        Event.CharacterDeath,
        function(...)
            self:OnDeath(...)
        end
    )
    TaskCommon.AddHandle(self.DeathHandle)
    self:Do(self.InitDelayTime)
    MonsterSpawnStatistics.AddInfiniteSpawn(self)
    return true
end

function SpawnMonsterInfinite:OnDeath(InCharater, ...)
    if InCharater and InCharater:IsAI() then
        local Num = UE4.ULevelLibrary.GetMonsterNumByTag(self, self:MakeTagName(self.TagName))
        if Num <= self.KillCondtion then
            self:Do(self.IntervalTime)
        end
    end
end

function SpawnMonsterInfinite:Do(InDelayTime)
    if InDelayTime <= 0 then
        self:Spawn()
    else
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                function()
                    self:Spawn()
                end
            },
            InDelayTime,
            false
        )
    end
end

function SpawnMonsterInfinite:Spawn()
    local Index = 0
    if not self.Random then
        Index = self.CurrentIndex
        self.CurrentIndex = self.CurrentIndex + 1
        if self.CurrentIndex > self.WaveNum then
            self.CurrentIndex = 1
        end
    else
        Index = math.random(1, self.WaveNum)
    end
    local Template = UE4.ULevelLibrary.GetActiveSpawnersTemplate(self.TableIDs:Get(Index), self:GetLevelType())
    if not Template then
        return
    end
    local AllPointNum = Template.Points:Length()
    if AllPointNum <= 0 then
        return
    end
    local Size = math.min(Template.Points:Length(), Template.SpawnerConfigs:Length())
    for i = 1, Size do
        local spawnerConfig = Template.SpawnerConfigs:Get(i)
        local MonsterInfo = UE4.ULevelLibrary.GetCharacterTemplate(spawnerConfig.SpawnerID)
        MonsterSpawnStatistics.SpawnNpc(
            self,
            {
                PointName = TaskCommon.CheckGet(Template.Points, i),
                Id = spawnerConfig.SpawnerID,
                Camp = MonsterInfo.Camp,
                AI = MonsterInfo.AI,
                Level = Template.Level,
                Team = Template.Team,
                AIEventID = Template.AIEvent,
                SpecializedSkillsConfig = Template.SpawnerConfigs:Get(i).SpecializedSkillsConfig,
                IdleAnimIndex = Template.SpawnerConfigs:Get(i).IdleAnimIndex,
                SpawnNpcSpCfg = Template.SpawnNpcSpCfg,
                SpawnEffectId = spawnerConfig.SpawnEffectID
            },
            {self:MakeTagName(self.TagName),self:GetGameTaskAsset():GetTaskTag()}
        )
    end
end

function SpawnMonsterInfinite:Stop()
    EventSystem.Remove(self.DeathHandle)
    self.CurrentIndex = 1
end

return SpawnMonsterInfinite
