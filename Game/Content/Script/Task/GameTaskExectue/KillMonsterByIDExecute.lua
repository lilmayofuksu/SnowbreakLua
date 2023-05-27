-- ========================================================
-- @File    : KillMonsterBase.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

local KillMonsterById = Class("Task.GameTaskExectue.KillMonsterBaseExecute")

---子类复写 怪物死亡检查  组  类型 等

function KillMonsterById:CheckCondition(InMonster)
    if not IsAI(InMonster) then
        return false
    end

    if InMonster.TemplateId ~= self.MID then
        return false
    end
    return true
end

function KillMonsterById:OnCountDown_Client()
    UI.Call("Fight", "UpdateTaskCountDown", self:GetCountDown(), self)
end

function KillMonsterById:OnEnd_Client()
	UI.Call("Fight", "HiddenTaskCountDown", self)
end




return KillMonsterById
