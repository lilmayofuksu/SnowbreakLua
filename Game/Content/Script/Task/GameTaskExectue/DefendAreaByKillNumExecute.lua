-- ========================================================
-- @File    : DefendAreaByKillNumExecute.lua
-- @Brief   : 坚守区域-消灭数量
-- @Author  : cms
-- @Date    : 2021/9/14
-- ========================================================

local DefendAreaByKillNum = Class()

DefendAreaByKillNum.DeathHandle = nil
DefendAreaByKillNum.HadKillNum = 0

DefendAreaByKillNum.TargetTriggers = nil
DefendAreaByKillNum.HadExecuteFail = false

DefendAreaByKillNum.AreaIDs = {"A", "B", "C"}

function DefendAreaByKillNum:OnActive()
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
    TaskCommon.AddHandle(self.DeathHandle)
    self:SetExecuteDescription()
end

function DefendAreaByKillNum:OnActive_Client()
    --self:SetExecuteDescription()
    local FightUMG = UI.GetUI("Fight")
    self.TargetTriggers = self:GetTargetTriggers()
    for i = 1, self.TargetTriggers:Length() do
        if FightUMG and FightUMG.uw_fight_monster_tips then
            local UIItem = FightUMG.uw_fight_monster_tips:CreateTaskItem(self.TargetTriggers:Get(i), UE4.EFightMonsterTipsType.DefendArea, "")
            if UIItem.TxtGuardName then
                UIItem.TxtGuardName:SetText(i)
            end
            self.TargetTriggers:Get(i):Active(self, UIItem, self.AreaIDs[i])
        end
    end
    if FightUMG and FightUMG.LevelGuard then
        self.LevelGuardUI = FightUMG.LevelGuard
        self.LevelGuardUI:Active(self)
        self.LevelGuardUI:SetGuardType(1)
    end
end

function DefendAreaByKillNum:OnUpdate_Client(HadKillNum)
    self.HadKillNum = HadKillNum
    if self.LevelGuardUI then
        self.LevelGuardUI:Update(self)
    end
end

function DefendAreaByKillNum:ClearDeathHandle()
    EventSystem.Remove(self.DeathHandle)
end

function DefendAreaByKillNum:OnFail()
    self:ClearDeathHandle()
    for i = 1, self.TargetTriggers:Length() do
        self.TargetTriggers:Get(i):Deactive(false)
    end
end

function DefendAreaByKillNum:OnFail_Client()
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendAreaByKillNum:OnFinish()
    self:ClearDeathHandle()
    for i = 1, self.TargetTriggers:Length() do
        self.TargetTriggers:Get(i):Deactive(true)
    end
end

function DefendAreaByKillNum:OnFinish_Client()
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendAreaByKillNum:GetFormatTitle()
    local Title = self:GetUIDescription()
    Title = string.format(Title, self.HadKillNum .. "/" .. self.DefendKillNum)
    return Title
end

function DefendAreaByKillNum:TryFail()
    if not self.HadExecuteFail then
        self.HadExecuteFail = true
        self:Fail()
    end
end

function DefendAreaByKillNum:GetDefendPercent()
    return self.HadKillNum / self.DefendKillNum
end

function DefendAreaByKillNum:GetDefendDesc_Name()
    return self.DefendDesc_Name
end

function DefendAreaByKillNum:GetDefendDesc_Num()
    return string.format(self.DefendDesc_Num, self.HadKillNum .. "/" .. self.DefendKillNum)
end

return DefendAreaByKillNum
