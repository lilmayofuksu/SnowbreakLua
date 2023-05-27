-- ========================================================
-- @File    : DefendTargetByWavesExecute.lua
-- @Brief   : 防御-波次
-- @Author  : cms
-- @Date    : 2022/2/27
-- ========================================================

local DefendTargetByWaves = Class()

DefendTargetByWaves.DeathHandle = nil
DefendTargetByWaves.MaxWaveIndex = 0
DefendTargetByWaves.CurrentWaveIndex = 1
DefendTargetByWaves.CurrentWaveNeedKillNum = 0
DefendTargetByWaves.CurrentWaveHadKillNum = 0

DefendTargetByWaves.WaveCountDown = 0
DefendTargetByWaves.TimerHandle = nil

DefendTargetByWaves.TargetName = {"A", "B", "C"}

function DefendTargetByWaves:OnActive()
    self.DefendTargets = self:FindDefendTargets()
    for i = 1, self.DefendTargets:Length() do
        self.DefendTargets:Get(i):SetActive(true)
        self.DefendTargets:Get(i):CreateUIItem(self.TargetName[i])
        self.DefendTargets:Get(i).Ability.OnCharacterDie:Add(
            self,
            function(ThisPtr)
                self:Fail()
            end
        )
    end
    self.DeathHandle =
        EventSystem.On(
        "CharacterDeath",
        function(InMonster)
            if IsAI(InMonster) then
                self.CurrentWaveHadKillNum = self.CurrentWaveHadKillNum + 1
                self:UpdateDataToClient(1, self.CurrentWaveHadKillNum)
                if self.CurrentWaveHadKillNum >= self.CurrentWaveNeedKillNum then
                    self.CurrentWaveIndex = self.CurrentWaveIndex + 1
                    self:UpdateDataToClient(4, self.CurrentWaveIndex)
                    if self.CurrentWaveIndex > self.MaxWaveIndex then
                        self:Finish()
                        return
                    end
                    local time = self:GetIntervalTime()
                    if time <= 0 then
                        self:TryNextWave()
                    else
                        self.WaveCountDown = time
                        self:UpdateDataToClient(2, self.WaveCountDown)
                        self.TimerHandle =
                            UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                            {
                                self,
                                function()
                                    self.WaveCountDown = self.WaveCountDown - 1
                                    self:UpdateDataToClient(2, self.WaveCountDown)
                                    if self.WaveCountDown <= 0 then
                                        self:TryNextWave()
                                        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
                                    end
                                end
                            },
                            1,
                            true
                        )
                    end
                end
            end
        end,
        false
    )
    self.MaxWaveIndex = self.SpawnWaves:Length()
    self:TryNextWave()
    TaskCommon.AddHandle(self.DeathHandle)
end

function DefendByWaves:GetIntervalTime()
    local count = self.IntervalTime:Length()
    if count < 1 then return 5 end
    if count == 1 then
        return self.IntervalTime:Get(1)
    end
    return self.IntervalTime:Get(math.min(self.CurrentWaveIndex, count))
end

function DefendTargetByWaves:OnActive_Client()
    self.DefendTargets = self:FindDefendTargets()
    for i = 1, self.DefendTargets:Length() do
        self.DefendTargets:Get(i):CreateUIItem(self.TargetName[i])
    end
    self:SetExecuteDescription()
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.LevelGuard then
        self.LevelGuardUI = FightUMG.LevelGuard
        self.LevelGuardUI:Active(self)
        self.LevelGuardUI:SetGuardType(1)
    end
    self.MaxWaveIndex = self.SpawnWaves:Length()
    self:InitWaveInfo()

    if self.LevelGuardUI then
        self.LevelGuardUI:Update(self)
        self:SetExecuteDescription()
    end
end

---@param Type number 传入类型,传入为1时传入CurrentWaveHadKillNum,传入为2时传入WaveCountDown,传入为3时传入CurrentWaveNeedKillNum,传入为4时传入CurrentWaveIndex
---@param Num number
function DefendTargetByWaves:OnUpdate_Client(Type, Num)
    if Type == 1 then
        self.CurrentWaveHadKillNum = Num
        if self.LevelGuardUI then
            self.LevelGuardUI:Update(self)
            self.LevelGuardUI:SetGuardType(1)
        end
    elseif Type == 2 then
        self.WaveCountDown = Num
        if self.LevelGuardUI then
            self.LevelGuardUI:SpecialUpdate(self, self.IntervalDesc, self.WaveCountDown, 0)
            self.LevelGuardUI:SetGuardType(2)
        end
    elseif Type == 3 then
        self.CurrentWaveNeedKillNum = Num
        self.CurrentWaveHadKillNum = 0
        if self.LevelGuardUI then
            self.LevelGuardUI:Update(self)
            self.LevelGuardUI:SetGuardType(1)
        end
    elseif Type == 4 then
        self.CurrentWaveIndex = Num
        if self.LevelGuardUI then
            self.LevelGuardUI:Update(self)
            self.LevelGuardUI:SetGuardType(1)
            self:SetExecuteDescription()
        end
    end
end

function DefendTargetByWaves:TryNextWave()
    if self.CurrentWaveIndex <= self.MaxWaveIndex then
        local Template = self:InitWaveInfo()
        self:Spawn(Template)
        self:UpdateDataToClient(3, self.CurrentWaveNeedKillNum)
    else
        self:Finish()
    end
end

function DefendTargetByWaves:InitWaveInfo()
    local Template =
        UE4.ULevelLibrary.GetActiveSpawnersTemplate(self.SpawnWaves:Get(self.CurrentWaveIndex), self:GetLevelType())
    local SpawnerNum = math.min(Template.Points:Length(), Template.SpawnerConfigs:Length())
    self.CurrentWaveNeedKillNum = SpawnerNum * Template.SpawnTimes
    self.CurrentWaveHadKillNum = 0
    return Template
end

function DefendTargetByWaves:ClearDeathHandle()
    EventSystem.Remove(self.DeathHandle)
end

function DefendTargetByWaves:OnFail()
    self:Clear()
end

function DefendTargetByWaves:OnFail_Client()
    self:Clear()
end

function DefendTargetByWaves:OnFinish()
    self:Clear()
end

function DefendTargetByWaves:OnFinish_Client()
    self:Clear()
end

function DefendTargetByWaves:Clear()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
    self.DefendTargets = self:FindDefendTargets()
    for i = 1, self.DefendTargets:Length() do
        self.DefendTargets:Get(i):SetActive(false)
        self.DefendTargets:Get(i):ResetUIItem()
    end
end

function DefendTargetByWaves:GetDescription()
    if self:IsServer() then
        self.DescArgs:Clear()
        self.DescArgs:Add(self.CurrentWaveIndex - 1)
        self.DescArgs:Add(self.MaxWaveIndex)
    elseif self:IsClient() then
        self.CurrentWaveIndex = self.DescArgs:Get(1)
        self.MaxWaveIndex = self.DescArgs:Get(2)
    end

    local Title = self:GetUIDescription()
    Title = string.format(Title, self.CurrentWaveIndex - 1 .. "/" .. self.MaxWaveIndex)
    return Title
end

function DefendTargetByWaves:GetDefendPercent()
    return self.CurrentWaveHadKillNum / self.CurrentWaveNeedKillNum
end

function DefendTargetByWaves:GetDefendDesc_Name()
    return self.DefendDesc_Name
end

function DefendTargetByWaves:GetDefendDesc_Num()
    return string.format(self.DefendDesc_Num, self.CurrentWaveHadKillNum .. "/" .. self.CurrentWaveNeedKillNum)
end

function DefendTargetByWaves:Spawn(Template)
    self.tbSpawn = {}
    if not Template then
        return false
    end
    ---次数
    for i = 1, Template.SpawnTimes do
        local Info = {
            Template = Template,
            DelayTime = Template.InitDelayTime + Template.IntervalTime * (i - 1)
        }
        table.insert(self.tbSpawn, Info)
    end

    if not self.tbSpawn or #self.tbSpawn <= 0 then
        return
    end
    local SpawnNum = 0
    for i = 1, #self.tbSpawn do
        local SpawnItem = self.tbSpawn[i]
        if SpawnItem.DelayTime > 0 then
            UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                {
                    self,
                    function()
                        self:DoSpawn(SpawnItem.Template)
                    end
                },
                SpawnItem.DelayTime,
                false
            )
        else
            self:DoSpawn(SpawnItem.Template)
        end
    end
end

function DefendTargetByWaves:DoSpawn(InTemplate)
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

return DefendTargetByWaves
