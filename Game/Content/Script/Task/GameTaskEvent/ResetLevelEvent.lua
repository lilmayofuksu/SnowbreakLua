-- ========================================================
-- @File    : ResetLevelEvent.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================
---@class ResetLevelEvent : GameTaskEvent
local ResetLevelEvent = Class()

function ResetLevelEvent:OnTrigger()
	self:UpdateDataToClient()
    return true
end

function ResetLevelEvent:OnUpdate_Client()
    local fOkEvent = function()
        UE4.UGameplayStatics.SetGamePaused(self, false)
        local ins = GetGameIns()
        UE4.ULevelLibrary.KillActorByTag(ins, 'Target')
        UE4.ULevelLibrary.ResetPlayerToStartPoint(ins)
        local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
        if controller then
            controller:SwitchPlayerCharacter(0, false)
        end
        local TaskActor = UE4.AGameTaskActor.GetGameTaskActor(ins)
        if TaskActor then
            UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                {
                    self,
                    function() TaskActor:RestartGameTask() end
                },
                0.1,
                false
            )
        end
    end
    local fCancel = function()
        UE4.UGameplayStatics.SetGamePaused(self, false)
        self:TaskFinish()
    end
    UE4.UGameplayStatics.SetGamePaused(self, true)
    UI.Open("MessageBox", Text(self.key), fOkEvent, fCancel)
end

return ResetLevelEvent
