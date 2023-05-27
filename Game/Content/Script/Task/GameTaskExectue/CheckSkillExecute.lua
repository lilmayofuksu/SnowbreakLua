-- ========================================================
-- @File    : CheckSkillExecute.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

local CheckSkillExecute = Class()

function CheckSkillExecute:OnActive()
    self.SkillCheck =
        EventSystem.On(
        Event.OnSkillCast,
        function(InCharacter, ID)
            if ID == self.SkillID then
                self:Finish()
            end
        end
    )
    TaskCommon.AddHandle(self.SkillCheck)
    self:SetExecuteDescription()
end

function CheckSkillExecute:OnEnd()
    EventSystem.Remove(self.SkillCheck)
end

return CheckSkillExecute
