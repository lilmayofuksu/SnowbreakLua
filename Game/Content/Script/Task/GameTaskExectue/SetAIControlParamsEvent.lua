-- ========================================================
-- @File    : SetAIControlParamsEvent.lua
-- @Brief   : 设置AIControlParams
-- @Author  :
-- @Date    :
-- ========================================================

---@class SetAIControlParamsEvent : TaskItem
local SetAIControlParamsEvent = Class()

function SetAIControlParamsEvent:OnTrigger()
    local pFunc = function()
        local monsters = self:GetMonstersByTag()
        for i=1,monsters:Length() do
            UE4.UAILibrary.UpdateAIControlParam(monsters:Get(i), self.AIControlParamsID) 
        end
    end

    if self.DelayTime > 0 then
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                pFunc
            },
            self.DelayTime,
            false
        )
    else
        pFunc()
    end
	
	return true
end

return SetAIControlParamsEvent
