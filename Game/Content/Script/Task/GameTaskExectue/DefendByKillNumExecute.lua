-- ========================================================
-- @File    : DefendByKillNumExecute.lua
-- @Brief   : 坚守-消灭数量
-- @Author  : cms
-- @Date    : 2021/9/14
-- ========================================================

local DefendByKillNum = Class()

DefendByKillNum.DeathHandle = nil
DefendByKillNum.HadKillNum = 0

function DefendByKillNum:OnActive()
    self.DeathHandle = EventSystem.On(
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
        false)
    TaskCommon.AddHandle(self.DeathHandle)
    self:SetExecuteDescription()
end

function DefendByKillNum:OnActive_Client()
    --self:SetExecuteDescription()
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.LevelGuard then
        self.LevelGuardUI = FightUMG.LevelGuard
        self.LevelGuardUI:Active(self)
        self.LevelGuardUI:SetGuardType(1)
    end
end

function DefendByKillNum:OnUpdate_Client(HadKillNum)
    self.HadKillNum = HadKillNum
    if self.LevelGuardUI then
        self.LevelGuardUI:Update(self)
    end
end

function DefendByKillNum:ClearDeathHandle()
    EventSystem.Remove(self.DeathHandle)
end

function DefendByKillNum:OnFail()
    self:ClearDeathHandle()
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendByKillNum:OnFail_Client()
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendByKillNum:OnFinish()
    self:ClearDeathHandle()
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendByKillNum:OnFinish_Client()
    if self.LevelGuardUI then
        self.LevelGuardUI:Deactive(self)
    end
end

function DefendByKillNum:GetDefendPercent()
    return self.HadKillNum / self.DefendKillNum
end

function DefendByKillNum:GetDefendDesc_Name()
    return self.DefendDesc_Name
end

function DefendByKillNum:GetDefendDesc_Num()
    return string.format(self.DefendDesc_Num, self.HadKillNum.."/"..self.DefendKillNum)
end


return DefendByKillNum