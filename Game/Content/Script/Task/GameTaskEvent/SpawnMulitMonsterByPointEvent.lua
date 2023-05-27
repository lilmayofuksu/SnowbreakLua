-- ========================================================
-- @File    : SpawnMulitMonsterByPoint.lua
-- @Brief   :
-- @Author  :
-- @Date    :
-- ========================================================

---@class SpawnMulitMonsterByPoint : SpawnMonsterBaseEvent
local SpawnMulitMonsterByPoint = Class()

SpawnMulitMonsterByPoint.tbSpawn = nil
SpawnMulitMonsterByPoint.NowSpawnIndex = 0

function SpawnMulitMonsterByPoint:GetSpawnNum()
    local TaskActor = self:GetGameTaskActor()
    self.AreaId = TaskActor.AreaId
    
    if self.RandomMonster then
        local RandomCfg = UE4.UTaskRandomSubsystem.GetBattleRandomMonster(TaskActor, self.AreaId)
        print('=======================>随机怪物刷新', self.AreaId, RandomCfg.MonsterId, RandomCfg.BuffId);
        if RandomCfg then self.TableID = RandomCfg.MonsterId end
    else
        self.TableID = UE4.UTaskRandomSubsystem.GetBattleMonsteresById(TaskActor, self.AreaId , self.BranchID)
    end

    local Num = self:ThenGetSpawnNum()
    return Num
end

---执行事件
function SpawnMulitMonsterByPoint:TrySpawn()
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
        if Template.Points:Length() ~= 0 and Template.SpawnerConfigs:Length() ~= 0 then
            local Info = {
                Template = Template,
                DelayTime = Template.InitDelayTime + Template.IntervalTime * (i - 1)
            }
            table.insert(self.tbSpawn, Info)
        end
    end
    self:Spawn()
    if self.Tip and self.Tip ~= "" and #self.tbSpawn > 0 then self:TipToClient('challenge.'..self.Tip, 3) end
    return true
end

function SpawnMulitMonsterByPoint:Spawn()
    if not self.tbSpawn or #self.tbSpawn <= 0 then
        return
    end
    for i = 1, #self.tbSpawn do
        local SpawnItem = self.tbSpawn[i]
        if SpawnItem.DelayTime > 0 or self.Delay > 0 then
            UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                {
                    self,
                    function()
                        self:Do(SpawnItem.Template)
                    end
                },
                SpawnItem.DelayTime + self.Delay,
                false
            )
        else
            self:Do(SpawnItem.Template)
        end
    end
end

function SpawnMulitMonsterByPoint:Do(InTemplate)
    local TaskActor = self:GetGameTaskActor()
    local AllPointNum = InTemplate.Points:Length()
    if AllPointNum <= 0 then
        return
    end
    local TaskActor = self:GetGameTaskActor()
    local Size = math.min(InTemplate.Points:Length(), InTemplate.SpawnerConfigs:Length())

    for i = 1, Size do
        -- 这里根据任务区域的不同刷怪点位变化
        local spawnerConfig = InTemplate.SpawnerConfigs:Get(i)
        local MonsterInfo = UE4.ULevelLibrary.GetCharacterTemplate(spawnerConfig.SpawnerID)
        local pName = string.format("%s_%s", self.AreaId, TaskCommon.CheckGet(InTemplate.Points, i));
        local SpawnNpcSpCfg = UE4.ULevelLibrary.GetAreaSkillId(TaskActor)
        
        print("SpawnMulitMonsterByPoint:  ", MonsterInfo.ID,MonsterInfo.bBornGod, pName, SpawnNpcSpCfg.SkillId)
        MonsterSpawnStatistics.SpawnNpc(
            self,
            {
                PointName = pName,
                Id = spawnerConfig.SpawnerID,
                AI = MonsterInfo.AI,
                Level = InTemplate.Level,
                Team = (self.Team == "") and InTemplate.Team or (tonumber(self.Team) + self.AreaId * 1000),
                AIEventID = InTemplate.AIEvent,
                SpecializedSkillsConfig = InTemplate.SpawnerConfigs:Get(i).SpecializedSkillsConfig,
                IdleAnimIndex = InTemplate.SpawnerConfigs:Get(i).IdleAnimIndex,
                SpawnNpcSpCfg = SpawnNpcSpCfg,
                SpawnEffectId = spawnerConfig.SpawnEffectID
            },
            {self.Tag, string.format("SpawnIndex_%s", self.NowSpawnIndex),self:GetGameTaskAsset():GetTaskTag()},
            self.bSummon
        )
        self.NowSpawnIndex = self.NowSpawnIndex + 1
    end
end

return SpawnMulitMonsterByPoint
