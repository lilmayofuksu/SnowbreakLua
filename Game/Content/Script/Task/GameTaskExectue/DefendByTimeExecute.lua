-- ========================================================
-- @File    : DefendByTimeExecute.lua
-- @Brief   : 坚守-存活时间
-- @Author  : cms
-- @Date    : 2021/9/14
-- ========================================================

local DefendByTime = Class()

DefendByTime.TimerHandle = nil
DefendByTime.LeftTime = 0
DefendByTime.LevelGuardUI = nil

function DefendByTime:OnActive()
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
                if self.LevelGuardUI then
                    self.LevelGuardUI:Update(self)
                end
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
    self:SetExecuteDescription()
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.LevelGuard then
        self.LevelGuardUI = FightUMG.LevelGuard
        self.LevelGuardUI:Active(self)
        self.LevelGuardUI:SetGuardType(2)
    end
end

function DefendByTime:OnActive_Client()
    --self:SetExecuteDescription()
    self.LeftTime = self.DefendTime
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.LevelGuard then
        self.LevelGuardUI = FightUMG.LevelGuard
        self.LevelGuardUI:Active(self)
    end
end

function DefendByTime:OnUpdate_Client(leftTime)
    self.LeftTime = leftTime;
    if self.LevelGuardUI then
        self.LevelGuardUI:Update(self)
    end
end

function DefendByTime:ClearTimerHandle()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
end

function DefendByTime:OnFail_Client()
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendByTime:OnFail()
    self:ClearTimerHandle()
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendByTime:OnFinish_Client()
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendByTime:OnFinish()
    self:ClearTimerHandle()
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendByTime:OnEnd()
    print("DefendbyTime:OnEnd")
    self:ClearTimerHandle()
end

function DefendByTime:OnEnd_Client()
    print("DefendbyTime:OnEnd_Client")
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendByTime:GetDefendPercent()
    return 1 - self.LeftTime / self.DefendTime
end

function DefendByTime:GetDefendDesc_Name()
    return self.DefendDesc_Name
end

function DefendByTime:GetDefendDesc_Num()
    --策划要求改成00:03这种
    local time = math.max(self.LeftTime, 0)
    return os.date("%M:%S", time)
    --return string.format(self.DefendDesc_Num, self.LeftTime)
end

return DefendByTime