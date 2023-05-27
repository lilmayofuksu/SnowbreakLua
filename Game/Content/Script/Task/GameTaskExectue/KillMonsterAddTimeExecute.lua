-- ========================================================
-- @File    : KillMonsterAddTime.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

local KillMonsterAddTime = Class("Task.GameTaskExectue.KillMonsterBaseExecute")

function KillMonsterAddTime:OnDeath(InMonster)
    if not self:CheckCondition(InMonster) then
        return
    end
    self.KillNum = self.KillNum + 1
    if self:Check() then
        self:Finish()
        --self:SetCurrentState(UE4.ETaskItem_State.Finish)
        EventSystem.Remove(self.DeathHook)
    end
    ---发送数据
    self:SetExecuteDescription()
    local Character = InMonster:Cast(UE4.AGameAICharacter)
    if Character and Character.AdditionalAttribute and Character.AdditionalAttribute.AddTimeByKill > 0 then
        if self.IsAddLevelTime then
            local TaskActor = self:GetGameTaskActor()
            TaskActor:SetLevelCountDownTime(TaskActor:GetLevelCountDownTime() + Character.AdditionalAttribute.AddTimeByKill)
        elseif InMonster.Tags:Contains(self.Tag) then
            --self:ClearCountDownTimer()
            self:SetCountDown(self:GetCountDown() + Character.AdditionalAttribute.AddTimeByKill)
            --self:ActiveCountDown()
            local FightUMG = UI.GetUI("Fight")
            if FightUMG and FightUMG.LevelGuard then
                FightUMG.LevelGuard:AddTime(Character.AdditionalAttribute.AddTimeByKill)
            end
        end
    end
end

---子类复写 怪物死亡检查  组  类型 等
function KillMonsterAddTime:CheckCondition(InMonster)
    if not IsAI(InMonster) then
        return false
    end
    return true
end

function KillMonsterAddTime:OnCountDown_Client()
    UI.Call("Fight", "UpdateTaskCountDown", self:GetCountDown(), self)
end



return KillMonsterAddTime
