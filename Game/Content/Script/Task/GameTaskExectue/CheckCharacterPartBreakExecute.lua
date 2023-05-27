-- ========================================================
-- @File    : CheckCharacterPartBreakExecute.lua
-- @Brief   : 部位破坏
-- @Author  :
-- @Date    :
-- ========================================================

---@class CheckCharacterPartBreakExecute : TaskItem
local CheckCharacterPartBreakExecute = Class()

function CheckCharacterPartBreakExecute:OnActive()
	self.requireBreak = self.BreakPartNum
	if self.MultType then
		local TaskActor = self:GetGameTaskActor()
    	self.challengeCfg = UE4.UTaskRandomSubsystem.GetBattleChallange(TaskActor, TaskActor.AreaId)
    	if self.challengeCfg then
    		self.requireBreak = self.challengeCfg.PartialCount
    	end
	end
	
	self.PartBreakHook =
        EventSystem.On(
        Event.PartBreak,
        function(InMonster, bWeaknessPart)
            if InMonster and not bWeaknessPart then
                --延迟执行  防止立即注册立即调用
                local UpdateUITimerHandle =
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {
                        self,
                        function()
                        	self.requireBreak = self.requireBreak - 1
                            print('=====================>破坏部件,还剩%d个达成目标', self.requireBreak)
                            if self.requireBreak <= 0 then
                            	self:Finish()
                            end
                        end
                    },
                    0.01,
                    false
                )
            end
        end
    )
end

function CheckCharacterPartBreakExecute:OnActive_Client()
    
end

function CheckCharacterPartBreakExecute:OnEnd()
	EventSystem.Remove(self.PartBreakHook)
end

return CheckCharacterPartBreakExecute
