-- ========================================================
-- @File    : DefendAreaByWavesExecute.lua
-- @Brief   : 坚守区域-消灭波次
-- @Author  : cms
-- @Date    : 2021/9/15
-- ========================================================

local DefendAreaByWaves = Class()

DefendAreaByWaves.DeathHandle = nil
DefendAreaByWaves.MaxWaveIndex = 0
DefendAreaByWaves.CurrentWaveIndex = 1
DefendAreaByWaves.CurrentWaveNeedKillNum = 0
DefendAreaByWaves.CurrentWaveHadKillNum = 0

DefendAreaByWaves.TargetTriggers = nil
DefendAreaByWaves.HadExecuteFail = false

DefendAreaByWaves.AreaIDs = {"A", "B", "C"}

function DefendAreaByWaves:OnActive()

    local pCheckTime = function ()
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
                    --self:SetExecuteDescription()
                    if self.CurrentWaveIndex > self.MaxWaveIndex then
                        self:Finish()
                        return
                    end
                    pCheckTime()
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

    local count = self.IntervalTime:Length()
    if count ~= 1 and self:GetIntervalTime() > 0 then
        pCheckTime()
    else
        self:TryNextWave()
    end
    TaskCommon.AddHandle(self.DeathHandle)
    self:SetExecuteDescription()
end

function DefendAreaByWaves:GetIntervalTime()
    local count = self.IntervalTime:Length()
    if count < 1 then return 5 end
    if count == 1 then
        return self.IntervalTime:Get(1)
    end
    return self.IntervalTime:Get(math.min(self.CurrentWaveIndex, count))
end

function DefendAreaByWaves:OnActive_Client()
    local FightUMG = UI.GetUI("Fight")
    self.TargetTriggers = self:GetTargetTriggers()
    for i = 1, self.TargetTriggers:Length() do
        if FightUMG and FightUMG.uw_fight_monster_tips then
            local UIItem = nil
            if not self:IsClient() then
                UIItem =
                    FightUMG.uw_fight_monster_tips:CreateTaskItem(
                    self.TargetTriggers:Get(i),
                    UE4.EFightMonsterTipsType.DefendArea,
                    ""
                )
                if UIItem.TxtGuardName then
                    UIItem.TxtGuardName:SetText(i)
                end
            end
            self.TargetTriggers:Get(i):Active(self, UIItem, self.AreaIDs[i])
        end
    end 

    if FightUMG and FightUMG.LevelGuard then
        self.LevelGuardUI = FightUMG.LevelGuard
        self.LevelGuardUI:Active(self)

        local count = self.IntervalTime:Length()
        local time = self:GetIntervalTime()
        if count ~= 1 and time > 0 then
            self.LevelGuardUI:SpecialUpdate(self, self.IntervalDesc, os.date("%M:%S",time), 0)
            self.LevelGuardUI:SetGuardType(2)
        else
            self.LevelGuardUI:Update(self)
            self.LevelGuardUI:SetGuardType(1)
        end
    end
end

---@param Type number 传入类型,传入为1时传入CurrentWaveHadKillNum,传入为2时传入WaveCountDown,传入为3时传入CurrentWaveNeedKillNum,传入为4时传入CurrentWaveIndex
---@param Num number
function DefendAreaByWaves:OnUpdate_Client(Type, Num, Length)
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
            --self:SetExecuteDescription()
            self.LevelGuardUI:SetGuardType(1)
        end
    end
end

function DefendAreaByWaves:CloseUI()
    if self.TargetTriggers then
        for i = 1, self.TargetTriggers:Length() do
            self.TargetTriggers:Get(i):Deactive(true)
        end
    end
    
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendAreaByWaves:TryNextWave()
    if self.CurrentWaveIndex <= self.MaxWaveIndex then
        local Template = self:InitWaveInfo()
        self:Spawn(Template)
        self:SetExecuteDescription()
        self:UpdateDataToClient(3, self.CurrentWaveNeedKillNum, self.MaxWaveIndex)
    else
        self:Finish()
    end
end

function DefendAreaByWaves:InitWaveInfo()
    local Template =
        UE4.ULevelLibrary.GetActiveSpawnersTemplate(self.SpawnWaves:Get(self.CurrentWaveIndex), self:GetLevelType())
    local SpawnerNum = math.min(Template.Points:Length(), Template.SpawnerConfigs:Length())
    self.CurrentWaveNeedKillNum = SpawnerNum * Template.SpawnTimes
    self.CurrentWaveHadKillNum = 0
    return Template
end

function DefendAreaByWaves:ClearDeathHandle()
    EventSystem.Remove(self.DeathHandle)
end

function DefendAreaByWaves:OnEnd()
    self:ClearDeathHandle()
end

function DefendAreaByWaves:OnEnd_Client()
    self:CloseUI()
end

function DefendAreaByWaves:GetDescription()
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

function DefendAreaByWaves:GetDefendPercent()
    return self.CurrentWaveHadKillNum / self.CurrentWaveNeedKillNum
end

function DefendAreaByWaves:GetDefendDesc_Name()
    return self.DefendDesc_Name
end

function DefendAreaByWaves:GetDefendDesc_Num()
    return string.format(self.DefendDesc_Num, self.CurrentWaveHadKillNum .. "/" .. self.CurrentWaveNeedKillNum)
end

function DefendAreaByWaves:Spawn(Template)
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

function DefendAreaByWaves:DoSpawn(InTemplate)
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

function DefendAreaByWaves:TryFail()
    if not self.HadExecuteFail then
        self.HadExecuteFail = true
        self:Fail()
    end
end

return DefendAreaByWaves
