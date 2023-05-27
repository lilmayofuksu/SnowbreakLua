-- ========================================================
-- @File    : ExecuteFunctionEvent.lua
-- @Brief   : 激活障碍物
-- @Author  :
-- @Date    :
-- ========================================================
---@class ExecuteFunctionEvent : GameTaskEvent
local ExecuteFunctionEvent = Class()

function ExecuteFunctionEvent:OnTrigger()

    local pFunc = function ()
        if self.MultType then
            local TaskActor = self:GetGameTaskActor()
            if TaskActor then 
                for _,v in ipairs(ChallengeMgr.tbBarricade[TaskActor.AreaId] or {}) do
                    self.Names:Add(v)
                end
            end
           
            if self.Names:Length() < 1 then return false end
        end
        return self:Activated()
    end
	
    if self.Delay > 0 then 
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                pFunc
            },
            self.Delay,
            false
        )
        return true
    else

        return pFunc()
    end
end

return ExecuteFunctionEvent
