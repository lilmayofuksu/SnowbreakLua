-- ========================================================
-- @File    : DefendTargetByTimeExecute.lua
-- @Brief   : 坚守-存活时间
-- @Author  : cms
-- @Date    : 2022/1/25
-- ========================================================

local DefendTargetByTime = Class()

DefendTargetByTime.TimerHandle = nil
DefendTargetByTime.LeftTime = 0
DefendTargetByTime.LevelGuardUI = nil

DefendTargetByTime.TargetName = {"A","B","C"}

function DefendTargetByTime:OnActive()
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

    self.LeftTime = self.DefendTime
    self.TimerHandle =
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                local bIsPause = self:IsPauseExecute()
                if bIsPause then
                    return;
                end
                self.LeftTime = self.LeftTime - 1
                self:UpdateDataToClient(self.LeftTime)
                if self.LeftTime <= 0 then
                    self:Finish()
                    return
                end
            end
        },
        1,
        true
    )
end

function DefendTargetByTime:OnActive_Client()
    --self:SetExecuteDescription()
    self.LeftTime = self.DefendTime
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.LevelGuard then
        self.LevelGuardUI = FightUMG.LevelGuard
        self.LevelGuardUI:Active(self)
        self.LevelGuardUI:SetGuardType(2)
    end
end

function DefendTargetByTime:OnUpdate_Client(LeftTime)
    self.LeftTime = LeftTime
    if self.LevelGuardUI then
        self.LevelGuardUI:Update(self)
    end
end

function DefendTargetByTime:ClearTimerHandle()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
end

function DefendTargetByTime:OnFail()
    self:Clear()
end

function DefendTargetByTime:OnFail_Client()
    self:Clear()
end

function DefendTargetByTime:OnFinish()
    self:Clear()
end

function DefendTargetByTime:OnFinish_Client()
    self:Clear()
end

function DefendTargetByTime:Clear()
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

function DefendTargetByTime:GetDefendPercent()
    return 1 - self.LeftTime / self.DefendTime
end

function DefendTargetByTime:GetDefendDesc_Name()
    return self.DefendDesc_Name
end

function DefendTargetByTime:GetDefendDesc_Num()
    return string.format(self.DefendDesc_Num, os.date("%M:%S",self.LeftTime))
end

return DefendTargetByTime
