-- ========================================================
-- @File    : DefendByWavesExecute.lua
-- @Brief   : 坚守-消灭波次
-- @Author  : cms
-- @Date    : 2021/9/15
-- ========================================================

local DefendByWaves = Class()

DefendByWaves.DeathHandle = nil
DefendByWaves.MaxWaveIndex = 0
DefendByWaves.CurrentWaveIndex = 1
DefendByWaves.CurrentWaveNeedKillNum = 0
DefendByWaves.CurrentWaveHadKillNum = 0

DefendByWaves.WaveCountDown = 0
DefendByWaves.TimerHandle = nil

function DefendByWaves:OnActive()
    self.DeathHandle =
        EventSystem.On(
        "CharacterDeath",
        function(InMonster)
            if IsAI(InMonster) then
                self.CurrentWaveHadKillNum = self.CurrentWaveHadKillNum + 1
                self:UpdateDataToClient(1, self.CurrentWaveHadKillNum, self.MaxWaveIndex)
                if self.CurrentWaveHadKillNum >= self.CurrentWaveNeedKillNum then
                    self.CurrentWaveIndex = self.CurrentWaveIndex + 1
                    self:UpdateDataToClient(4, self.CurrentWaveIndex, self.MaxWaveIndex)
                    if self.CurrentWaveIndex > self.MaxWaveIndex then
                        self:Finish()
                        return
                    end

                    local time = self:GetIntervalTime()
                    if time <= 0 then
                        self:TryNextWave()
                    else
                        self.WaveCountDown = time
                        self:UpdateDataToClient(2, self.WaveCountDown, self.MaxWaveIndex)
                        self.TimerHandle =
                            UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                            {
                                self,
                                function()
                                    self.WaveCountDown = self.WaveCountDown - 1
                                    self:UpdateDataToClient(2, self.WaveCountDown, self.MaxWaveIndex)
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

    if self.MultType then
        local TaskActor = self:GetGameTaskActor()
        self.AreaId = TaskActor.AreaId
        self.SpawnWaves = UE4.UTaskRandomSubsystem.GetBattleMonsteres(TaskActor, self.AreaId)
    end 
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

function DefendByWaves:OnActive_Client()
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.LevelGuard then
        self.LevelGuardUI = FightUMG.LevelGuard
        self.LevelGuardUI:Active(self)
        self.LevelGuardUI:SetGuardType(1)
    end

    if self.LevelGuardUI then
        self.LevelGuardUI:Update(self)
    end
end

---@param Type number 传入类型,传入为1时传入CurrentWaveHadKillNum,传入为2时传入WaveCountDown,传入为3时传入CurrentWaveNeedKillNum,传入为4时传入CurrentWaveIndex
---@param Num number
function DefendByWaves:OnUpdate_Client(Type, Num, Length)
    if self.LevelGuardUI then
        self.LevelGuardUI:Active(self)
        self.LevelGuardUI:SetGuardType(1)
    end

    self.MaxWaveIndex = Length
    if Type == 1 then
        self.CurrentWaveHadKillNum = Num
        if self.LevelGuardUI then
            self.LevelGuardUI:Update(self)
            self.LevelGuardUI:SetGuardType(1)
        end
    elseif Type == 2 then
        self.WaveCountDown = Num
        if self.LevelGuardUI and self.WaveCountDown >= 0 then
            self.LevelGuardUI:SpecialUpdate(self, self.IntervalDesc, os.date("%M:%S",self.WaveCountDown), 0)
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
        end
    end
end

function DefendByWaves:TryNextWave()
    if self.CurrentWaveIndex <= self.MaxWaveIndex then
        local Template = self:InitWaveInfo()
        self:Spawn(Template)
        self:SetExecuteDescription()
        self:UpdateDataToClient(3, self.CurrentWaveNeedKillNum, self.MaxWaveIndex)
    else
        self:Finish()
    end
end

function DefendByWaves:InitWaveInfo()
    local Template =
        UE4.ULevelLibrary.GetActiveSpawnersTemplate(self.SpawnWaves:Get(self.CurrentWaveIndex), self:GetLevelType())
    local SpawnerNum = math.min(Template.Points:Length(), Template.SpawnerConfigs:Length())
    self.CurrentWaveNeedKillNum = SpawnerNum * Template.SpawnTimes
    self.CurrentWaveHadKillNum = 0
    return Template
end

function DefendByWaves:ClearDeathHandle()
    EventSystem.Remove(self.DeathHandle)
end

function DefendByWaves:CloseUI()
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendByWaves:OnEnd()
    self:ClearDeathHandle()
end

function DefendByWaves:OnEnd_Client()
    self:CloseUI()
end

function DefendByWaves:GetDescription()
    if self:IsServer() then
        self.DescArgs:Clear()
        self.DescArgs:Add(self.CurrentWaveIndex)
        self.DescArgs:Add(self.MaxWaveIndex)
        self.DescArgs:Add(self.CurrentWaveNeedKillNum)
    elseif self:IsClient() then
        self.CurrentWaveIndex = self.DescArgs:Get(1)
        self.MaxWaveIndex = self.DescArgs:Get(2)
        self.CurrentWaveNeedKillNum = self.DescArgs:Get(3)
    end

    local Title = self:GetUIDescription()
    Title = string.format(Title, self.CurrentWaveIndex - 1 .. "/" .. self.MaxWaveIndex)
    return Title
end

function DefendByWaves:GetDefendPercent()
    return self.CurrentWaveHadKillNum / self.CurrentWaveNeedKillNum
end

function DefendByWaves:GetDefendDesc_Name()
    return self.DefendDesc_Name
end

function DefendByWaves:GetDefendDesc_Num()
    return string.format(self.DefendDesc_Num, self.CurrentWaveHadKillNum .. "/" .. self.CurrentWaveNeedKillNum)
end

function DefendByWaves:Spawn(Template)
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

function DefendByWaves:DoSpawn(InTemplate)
    local AllPointNum = InTemplate.Points:Length()
    if AllPointNum <= 0 then
        return
    end
    local Size = math.min(InTemplate.Points:Length(), InTemplate.SpawnerConfigs:Length())
    for i = 1, Size do
        local spawnerConfig = InTemplate.SpawnerConfigs:Get(i)
        local MonsterInfo = UE4.ULevelLibrary.GetCharacterTemplate(spawnerConfig.SpawnerID)

        local pName = TaskCommon.CheckGet(InTemplate.Points, i);
        if self.MultType then pName =  string.format("%s_%s", self.AreaId, pName) end
        MonsterSpawnStatistics.SpawnNpc(
            self,
            {
                PointName = pName,
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

return DefendByWaves
