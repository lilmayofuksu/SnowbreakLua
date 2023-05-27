-- ========================================================
-- @File    : DefendTargetByKillNumExecute.lua
-- @Brief   : 防御-消灭怪物
-- @Author  : cms
-- @Date    : 2022/1/25
-- ========================================================

local DefendTargetByKillNum = Class()

DefendTargetByKillNum.DeathHandle = nil
DefendTargetByKillNum.HadKillNum = 0

DefendTargetByKillNum.TargetName = {"A","B","C"}

function DefendTargetByKillNum:OnActive()
    local tags = { self.Tag1, self.Tag2, self.Tag3 }
    self.DefendTargets = self:FindDefendTargets()
    for i = 1, self.DefendTargets:Length() do
        local one = self.DefendTargets:Get(i)
        
        one:SetActive(true)
        for t,v in ipairs(tags) do
            if v == one.InActorTag then
               one:CreateUIItem(self.TargetName[t])
            end
        end
        
        one.Ability.OnCharacterDie:Add(
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
                self.HadKillNum = self.HadKillNum + 1
                self:UpdateDataToClient(self.HadKillNum)
                if self.HadKillNum >= self.DefendKillNum then
                    self:Finish()
                end
            end
        end,
        false
    )
    self:SetExecuteDescription()
    TaskCommon.AddHandle(self.DeathHandle)
end

function DefendTargetByKillNum:OnActive_Client()
    
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.LevelGuard then
        self.LevelGuardUI = FightUMG.LevelGuard
        self.LevelGuardUI:Active(self)
        self.LevelGuardUI:SetGuardType(1)
    end
end

function DefendTargetByKillNum:OnUpdate_Client(HadKillNum)
    self.HadKillNum = HadKillNum
    if self.LevelGuardUI then
        self.LevelGuardUI:Update(self)
    end
end

function DefendTargetByKillNum:ClearDeathHandle()
    EventSystem.Remove(self.DeathHandle)
end

function DefendTargetByKillNum:OnFail()
    self:Clear()
end

function DefendTargetByKillNum:OnFail_Client()
    self:Clear()
end

function DefendTargetByKillNum:OnFinish()
    self:Clear()
end

function DefendTargetByKillNum:OnFinish_Client()
    self:Clear()
end

function DefendTargetByKillNum:Clear()
    self:ClearTimerHandle()
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
    self.DefendTargets = self:FindDefendTargets()
    for i = 1, self.DefendTargets:Length() do
        self.DefendTargets:Get(i):SetActive(false)
        self.DefendTargets:Get(i):ResetUIItem()
    end
end

function DefendTargetByKillNum:ClearTimerHandle()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.TimerHandle)
end

function DefendTargetByKillNum:GetDefendPercent()
    return self.HadKillNum / self.DefendKillNum
end

function DefendTargetByKillNum:GetDefendDesc_Name()
    return self.DefendDesc_Name
end

function DefendTargetByKillNum:GetDefendDesc_Num()
    return string.format(self.DefendDesc_Num, self.HadKillNum .. "/" .. self.DefendKillNum)
end

return DefendTargetByKillNum
