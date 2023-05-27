-- ========================================================
-- @File    : TimerExecute.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================


---@class  TimerExecute: GameTask_Execute
local Timer = Class()

Timer.TimerHandle=nil;
Timer.CurrentNum=0;

function Timer:OnActive()
    self.Current = self.Num;
    self.TimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, Timer.Add}, 0.1, true)
    self:SetExecuteDescription()
    if self.bTimer then
        local FightUMG = UI.GetUI("Fight")
        print("Timer-OnActive: pre active LevelGuard")
        if FightUMG and FightUMG.LevelGuard then
            self.LevelGuardUI = FightUMG.LevelGuard
            self.LevelGuardUI:Active(self)
            self.LevelGuardUI:SetGuardType(2)
            print("Timer-OnActive: post active LevelGuard")
        end
    end
end


function Timer:Add()
    local bIsPause = self:IsPauseExecute()
    if bIsPause then
        return;
    end
    self.Current = self.Current - 0.1;
    -- if self.bTimer then
        self:Update(self.Current)
    -- end

    if self:Check() then
        self:Finish()
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
    end
    self:SetExecuteDescription()
end

function Timer:Update(LeftTime)
    self.LeftTime = self.Current;
    if self.LevelGuardUI then
        self.LevelGuardUI:Update(self)
    end

end


function Timer:GetDescription()
    if self:IsServer() then
        self.DescArgs:Clear()
        self.DescArgs:Add(math.floor(self.Current * 10))
    elseif self:IsClient() then
        self.Current = self.DescArgs:Get(1) / 10
    end
    return string.format(self:GetUIDescription(),math.ceil(self.Current))
end

function Timer:OnEnd()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function Timer:Check()
    return self.Current <= 0;
end

function Timer:GetDefendDesc_Num()
    local time = math.ceil(self.Current)
    return os.date("%M:%S", time)
end


return Timer