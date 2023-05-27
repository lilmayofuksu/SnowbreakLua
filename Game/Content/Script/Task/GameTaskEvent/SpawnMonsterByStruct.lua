-- ========================================================
-- @File    : SpawnMonsterByStruct.lua
-- @Brief   :
-- @Author  :
-- @Date    :
-- ========================================================

---@class SpawnMonsterByStruct : SpawnMonsterBaseEvent
local SpawnMonsterByStruct = Class()

SpawnMonsterByStruct.NowSpawnIndex = 0
---执行事件
function SpawnMonsterByStruct:TrySpawn()
    self.MonsterCount = 0
    if self.bRandom then
        self:RandomSpawn()
        return
    end

    self.NowSpawnIndex = self.SpawnStartIndex
    for i = 1,self.MonsterStructs:Length() do
        local struct = self.MonsterStructs:Get(i)
        self:SpawnByTmp(struct)
    end

    return true
end

function SpawnMonsterByStruct:RandomSpawn()
    local RandomIndex = math.random(self.MonsterStructs:Length())
    local TaskActor = self:GetGameTaskActor()
    if IsValid(TaskActor) and TaskActor.LevelType == UE4.ELevelType.Defend and IsValid(TaskActor.TaskDataComponent) then
        local MonsWave = TaskActor.TaskDataComponent:GetOrAddValue('MonsterWave')
        DefendLogic:WaveIndexLog(MonsWave,RandomIndex)
    end
    local struct = self.MonsterStructs:Get(RandomIndex)
    self:SpawnByTmp(struct)
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

function SpawnMonsterByStruct:GetSpawnNum()
    if self.bRandom then
        return self.MonsterCount or 0
    end

    local num = 0
    for i = 1,self.MonsterStructs:Length() do
        local struct = self.MonsterStructs:Get(i)
        if not struct.ByGroup then
            num = num + struct.config.SpawnTimes
        else
            local pointNum = 0
            local points = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(self,UE4.ANPCSpawnPoint,struct.GroupName)
            pointNum = pointNum + points:Length()
            --[[for i = 1, points:Length() do
                local point = points:Get(i)
                local path = point:GetFolderPath()
                if string.find(path,struct.GroupName) then
                    pointNum = pointNum + 1
                end
            end]]
            num = num + struct.config.SpawnTimes * pointNum
        end
    end
    return num
end

function SpawnMonsterByStruct:GetTagArray(TagArray,BSpArray,FirstIDArray)
    for i = 1,self.MonsterStructs:Length() do
        local struct = self.MonsterStructs:Get(i)
        local spawnerCfg = struct.config.SpawnerConfigs:Get(1)
        if spawnerCfg then
            local firstId = spawnerCfg.SpawnerID
            while(firstId >= 10) 
            do
                firstId = math.floor(firstId / 10)
            end
            if not struct.ByGroup then
                for i=1,struct.config.SpawnTimes do
                    TagArray:Add(struct.Tag or 'None')
                    BSpArray:Add(spawnerCfg.SpecializedSkillsConfig.MaxNum > 0)
                    FirstIDArray:Add(firstId)
                end
            else
                local pointNum = 0
                local points = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(self,UE4.ANPCSpawnPoint,struct.GroupName)
                pointNum = pointNum + points:Length()
                --[[for i = 1, points:Length() do
                    local point = points:Get(i)
                    local path = point:GetFolderPath()
                    if string.find(path,struct.GroupName) then
                        pointNum = pointNum + 1
                    end
                end]]
                for i=1,struct.config.SpawnTimes*pointNum do
                    TagArray:Add(struct.Tag or 'None')
                    BSpArray:Add(spawnerCfg.SpecializedSkillsConfig.MaxNum > 0)
                    FirstIDArray:Add(firstId)
                end
            end
        end
    end
end

function SpawnMonsterByStruct:SpawnByTmp(Template)
    if not Template then
        return false
    end
    local tbSpawn = {}
    ---次数
    for i = 1, Template.config.SpawnTimes do
        local Info = {
            Template = Template,
            DelayTime = Template.config.InitDelayTime + Template.config.IntervalTime * (i - 1)
        }
        table.insert(tbSpawn, Info)
    end
    self:Spawn(tbSpawn)
end

function SpawnMonsterByStruct:Spawn(tbSpawn)
    if not tbSpawn or #tbSpawn <= 0 then
        return
    end

    self.MonsterCount = self.MonsterCount + #tbSpawn
    for i = 1, #tbSpawn do
        local SpawnItem = tbSpawn[i]
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

function SpawnMonsterByStruct:Do(InTemplate)
    local AllCfgLength = InTemplate.config.SpawnerConfigs:Length()
    if AllCfgLength <= 0 then
        return
    end
    local spawnerCfg = InTemplate.config.SpawnerConfigs:Get(1)
    local MonsterInfo = UE4.ULevelLibrary.GetCharacterTemplate(spawnerCfg.SpawnerID)
    if InTemplate.ByGroup then
        local points = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(self,UE4.ANPCSpawnPoint,InTemplate.GroupName)
        for i = 1, points:Length() do
            local point = points:Get(i)
            --[[local path = point:GetFolderPath()]]
            --if string.find(path,InTemplate.GroupName) then
            local Tags = {
                InTemplate.Tag,
                string.format("SpawnIndex_%s", self.NowSpawnIndex),
                self:GetGameTaskAsset():GetTaskTag()
            };
            for i=1,InTemplate.ExTags:Length() do
                Tags[#Tags + 1] = InTemplate.ExTags:Get(i)
            end
            MonsterSpawnStatistics.SpawnNpc(
                self,
                {
                    PointName = point:GetName(),
                    Id = spawnerCfg.SpawnerID,
                    AI = MonsterInfo.AI,
                    Level = InTemplate.config.Level,
                    Team = InTemplate.config.Team,
                    AIEventID = InTemplate.config.AIEvent,
                    SpecializedSkillsConfig = spawnerCfg.SpecializedSkillsConfig,
                    IdleAnimIndex = spawnerCfg.IdleAnimIndex,
                    SpawnNpcSpCfg = InTemplate.config.SpawnNpcSpCfg,
                    SpawnEffectId = spawnerCfg.SpawnEffectID,
                    CampPriority = InTemplate.CampPriority
                },
                Tags,
                self.bSummon
            )
            self.NowSpawnIndex = self.NowSpawnIndex + 1
            --end
        end
    else
        local Tags = {
            InTemplate.Tag,
            string.format("SpawnIndex_%s", self.NowSpawnIndex),
            self:GetGameTaskAsset():GetTaskTag()
        };
        for i=1,InTemplate.ExTags:Length() do
            Tags[#Tags + 1] = InTemplate.ExTags:Get(i)
        end
        MonsterSpawnStatistics.SpawnNpc(
            self,
            {
                PointName = InTemplate.PointName,
                Id = spawnerCfg.SpawnerID,
                AI = MonsterInfo.AI,
                Level = InTemplate.config.Level,
                Team = InTemplate.config.Team,
                AIEventID = InTemplate.config.AIEvent,
                SpecializedSkillsConfig = spawnerCfg.SpecializedSkillsConfig,
                IdleAnimIndex = spawnerCfg.IdleAnimIndex,
                SpawnNpcSpCfg = InTemplate.config.SpawnNpcSpCfg,
                SpawnEffectId = spawnerCfg.SpawnEffectID,
                CampPriority = InTemplate.CampPriority,
                Type = MonsterInfo.Type
            },
            Tags,
            self.bSummon
        )
        self.NowSpawnIndex = self.NowSpawnIndex + 1
    end
end

function SpawnMonsterByStruct:GetUniqueMonsId(MonsterIdArray)
    for i = 1,self.MonsterStructs:Length() do
        local struct = self.MonsterStructs:Get(i)
        for j = 1,struct.config.SpawnerConfigs:Length() do
            local spawnerCfg = struct.config.SpawnerConfigs:Get(j)
            if spawnerCfg then
                MonsterIdArray:AddUnique(spawnerCfg.SpawnerID)
            end
        end
    end
end

return SpawnMonsterByStruct
