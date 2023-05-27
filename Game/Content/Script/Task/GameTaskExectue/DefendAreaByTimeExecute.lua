-- ========================================================
-- @File    : DefendAreaByTimeExecute.lua
-- @Brief   : 坚守区域-存活时间
-- @Author  : cms
-- @Date    : 2021/9/14
-- ========================================================

local DefendAreaByTime = Class()

DefendAreaByTime.TimerHandle = nil
DefendAreaByTime.LeftTime = 0

DefendAreaByTime.TargetTriggers = nil
DefendAreaByTime.HadExecuteFail = false

DefendAreaByTime.AreaIDs = {"A","B","C"}

function DefendAreaByTime:OnActive()
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
    self:SetExecuteDescription()
end

function DefendAreaByTime:OnActive_Client()
    --self:SetExecuteDescription()
    self.LeftTime = self.DefendTime
    local FightUMG = UI.GetUI("Fight")
    self.TargetTriggers = self:GetTargetTriggers()
    for i = 1, self.TargetTriggers:Length() do
        if FightUMG and FightUMG.uw_fight_monster_tips then
            local UIItem = FightUMG.uw_fight_monster_tips:CreateTaskItem(self.TargetTriggers:Get(i),UE4.EFightMonsterTipsType.DefendArea, "")
            if UIItem.TxtGuardName then
                UIItem.TxtGuardName:SetText(i)
            end
            self.TargetTriggers:Get(i):Active(self, UIItem,self.AreaIDs[i])
        end
    end
    if FightUMG and FightUMG.LevelGuard then
        self.LevelGuardUI = FightUMG.LevelGuard
        self.LevelGuardUI:Active(self)
        self.LevelGuardUI:SetGuardType(2)
    end
end

function DefendAreaByTime:OnUpdate_Client(LeftTime)
    self.LeftTime = LeftTime
    if self.LevelGuardUI then
        self.LevelGuardUI:Update(self)
    end
end

function DefendAreaByTime:ClearTimerHandle()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
end

function DefendAreaByTime:OnFail()
    self:ClearTimerHandle()
    for i = 1, self.TargetTriggers:Length() do
        self.TargetTriggers:Get(i):Deactive(false)
    end
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendAreaByTime:OnFail_Client()
    for i = 1, self.TargetTriggers:Length() do
        self.TargetTriggers:Get(i):Deactive(false)
    end
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendAreaByTime:OnFinish()
    self:ClearTimerHandle()
    for i = 1, self.TargetTriggers:Length() do
        self.TargetTriggers:Get(i):Deactive(true)
    end
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendAreaByTime:OnFinish_Client()
    for i = 1, self.TargetTriggers:Length() do
        self.TargetTriggers:Get(i):Deactive(true)
    end
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end


function DefendAreaByTime:TryFail()
    if not self.HadExecuteFail then
        self.HadExecuteFail = true
        self:Fail()
    end
end

function DefendAreaByTime:GetDefendPercent()
    return 1 - self.LeftTime / self.DefendTime
end

function DefendAreaByTime:GetDefendDesc_Name()
    return self.DefendDesc_Name
end

function DefendAreaByTime:GetDefendDesc_Num()
    local time = math.max(self.LeftTime, 0)
    return os.date("%M:%S", time)
    --return string.format(self.DefendDesc_Num, self.LeftTime)
end

return DefendAreaByTime
