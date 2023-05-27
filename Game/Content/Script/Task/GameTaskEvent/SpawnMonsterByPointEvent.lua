-- ========================================================
-- @File    : KillMonsterBase.lua
-- @Brief   :
-- @Author  :
-- @Date    :
-- ========================================================
--require("socket.core")
---@class SpawnMonsterByPointEvent : SpawnMonsterBaseEvent
local SpawnMonsterByPoint = Class()

SpawnMonsterByPoint.tbSpawn = nil
SpawnMonsterByPoint.NowSpawnIndex = 0

-- function SpawnMonsterByPoint:Initialize()
--         print("Initialize! unlua version ===> ".._VERSION)
-- end

---执行事件
function SpawnMonsterByPoint:TrySpawn()
    self.tbSpawn = {}
    if self.TableID < 0 then
        return false
    end

    ---@type FActiveSpawnersTemplate
    local Template = UE4.ULevelLibrary.GetActiveSpawnersTemplate(self.TableID, self:GetLevelType())
    if not Template then
        return false
    end
    self.NowSpawnIndex = self.SpawnStartIndex

    ---次数
    for i = 1, Template.SpawnTimes do
        local Info = {
            Template = Template,
            DelayTime = Template.InitDelayTime + Template.IntervalTime * (i - 1)
        }
        table.insert(self.tbSpawn, Info)
    end
    self:Spawn()
    return true
end

function SpawnMonsterByPoint:Spawn()
    if not self.tbSpawn or #self.tbSpawn <= 0 then
        return
    end
    for i = 1, #self.tbSpawn do
        local SpawnItem = self.tbSpawn[i]
        if SpawnItem.DelayTime > 0 then
            UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                {
                    self,
                    function()
                        self:Do(SpawnItem.Template)
                    end
                },
                SpawnItem.DelayTime,
                false
            )
        else
            self:Do(SpawnItem.Template)
        end
    end
end

function SpawnMonsterByPoint:Do(InTemplate)
    local AllPointNum = InTemplate.Points:Length()
    if AllPointNum <= 0 then
        return
    end
    local Size = math.min(InTemplate.Points:Length(), InTemplate.SpawnerConfigs:Length())

    for i = 1, Size do
        local spawnerConfig = InTemplate.SpawnerConfigs:Get(i)
        local MonsterInfo = UE4.ULevelLibrary.GetCharacterTemplate(spawnerConfig.SpawnerID)
        print("SpawnMonsterByPoint:id-", MonsterInfo.ID, "BronGod-", MonsterInfo.bBornGod)
        MonsterSpawnStatistics.SpawnNpc(
            self,
            {
                PointName = TaskCommon.CheckGet(InTemplate.Points, i),
                Id = spawnerConfig.SpawnerID,
                AI = MonsterInfo.AI,
                Level = InTemplate.Level,
                Team = (self.Team == "") and InTemplate.Team or self.Team,
                AIEventID = InTemplate.AIEvent,
                SpecializedSkillsConfig = InTemplate.SpawnerConfigs:Get(i).SpecializedSkillsConfig,
                IdleAnimIndex = InTemplate.SpawnerConfigs:Get(i).IdleAnimIndex,
                SpawnNpcSpCfg = InTemplate.SpawnNpcSpCfg,
                SpawnEffectId = spawnerConfig.SpawnEffectID
            },
            {self.Tag, string.format("SpawnIndex_%s", self.NowSpawnIndex),self:GetGameTaskAsset():GetTaskTag()},
            self.bSummon
        )
        self.NowSpawnIndex = self.NowSpawnIndex + 1
    end
end

return SpawnMonsterByPoint
