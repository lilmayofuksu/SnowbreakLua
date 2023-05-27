-- ========================================================
-- @File    : KillMonsterByTag.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

local KillMonsterByTag = Class("Task.GameTaskExectue.KillMonsterBaseExecute")

---子类复写 怪物死亡检查  组  类型 等
function KillMonsterByTag:CheckCondition(InMonster)
    if not IsAI(InMonster) and self.IgnoreSummon then
        return false
    end
    if InMonster.Tags:Contains(self.Tag) then
        return true
    end
    return false
end

function KillMonsterByTag:OnCountDown_Client()
    UI.Call("Fight", "UpdateTaskCountDown", self:GetCountDown(), self)
end

function KillMonsterByTag:OnEnd_Client()
	UI.Call("Fight", "HiddenTaskCountDown", self)
end


return KillMonsterByTag
