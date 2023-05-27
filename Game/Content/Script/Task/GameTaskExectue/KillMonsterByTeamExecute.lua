-- ========================================================
-- @File    : KillMonsterBase.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

local KillMonsterByTeam = Class("Task.GameTaskExectue.KillMonsterBaseExecute")

---子类复写 怪物死亡检查  组  类型 等
function KillMonsterByTeam:CheckCondition(InMonster)
    if not IsAI(InMonster) then
        return false
    end

    if InMonster:GetTeamName() ~= self.Team then
        return false
    end
    return true
end

function KillMonsterByTeam:OnCountDown_Client()
    UI.Call("Fight", "UpdateTaskCountDown", self:GetCountDown(), self)
end

function KillMonsterByTeam:OnEnd_Client()
	UI.Call("Fight", "HiddenTaskCountDown", self)
end

return KillMonsterByTeam
