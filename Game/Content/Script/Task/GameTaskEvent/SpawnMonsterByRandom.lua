-- ========================================================
-- @File    : SpawnMonsterByRandom.lua
-- @Brief   :
-- @Author  : cms
-- @Date    : 2021/10/8
-- ========================================================

---@class SpawnMonsterByRandom : SpawnMonsterBaseEvent
local SpawnMonsterByRandom = Class()

SpawnMonsterByRandom.tbSpawn = nil
---执行事件
---
function SpawnMonsterByRandom:TrySpawn()
    self:RandomSpawn()
end

function SpawnMonsterByRandom:RandomSpawn()
    local RandomTableID = self.RandomTableIDs:Get(math.random(1, self.RandomTableIDs:Length()))
    self.tbSpawn = {}
    ---@type FActiveSpawnersTemplate
    local Template = UE4.ULevelLibrary.GetActiveSpawnersTemplate(RandomTableID, self:GetLevelType())
    ---次数
    for i = 1, Template.SpawnTimes do
        self:Do(Template)
    end
    self.RandomTimes = self.RandomTimes - 1
    if self.RandomTimes > 0 then
        if self.IntervalTime > 0 then
            UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                {
                    self,
                    function()
                        self:RandomSpawn()
                    end
                },
                self.IntervalTime,
                false
            )
        else
            self:RandomSpawn()
        end
    end
end

function SpawnMonsterByRandom:Do(InTemplate)
    local AllPointNum = InTemplate.Points:Length()
    if AllPointNum <= 0 then
        return
    end
    local Size = math.min(InTemplate.Points:Length(), InTemplate.SpawnerConfigs:Length())
    for i = 1, Size do
        local spawnerConfig = InTemplate.SpawnerConfigs:Get(i)
        local MonsterInfo = UE4.ULevelLibrary.GetCharacterTemplate(spawnerConfig.SpawnerID)
        MonsterSpawnStatistics.SpawnNpc(
            self,
            {
                PointName = TaskCommon.CheckGet(InTemplate.Points, i),
                Id = spawnerConfig.SpawnerID,
                Camp = MonsterInfo.Camp,
                AI = MonsterInfo.AI,
                Level = InTemplate.Level,
                Team = InTemplate.Team,
                AIEventID = InTemplate.AIEvent,
                SpecializedSkillsConfig = InTemplate.SpawnerConfigs:Get(i).SpecializedSkillsConfig,
                IdleAnimIndex = InTemplate.SpawnerConfigs:Get(i).IdleAnimIndex,
                SpawnNpcSpCfg = InTemplate.SpawnNpcSpCfg,
                SpawnEffectId = spawnerConfig.SpawnEffectID
            },
            {self:GetGameTaskAsset():GetTaskTag()}
        )
    end
end

return SpawnMonsterByRandom
