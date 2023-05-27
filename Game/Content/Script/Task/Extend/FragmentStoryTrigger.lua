-- ========================================================
-- @File    : FragmentStoryTrigger.lua
-- @Brief   : 区域触发碎片化剧情
-- @Author  : MYF
-- @Date    :
-- ========================================================
---@class FragmentStoryTrigger : ATriggerBox
local FragmentStoryTrigger = Class()

---进入
function FragmentStoryTrigger:ReceiveActorBeginOverlap(OtherActor)
    if IsPlayer(OtherActor) then
        local subsytem = UE4.UUMGLibrary.GetFightUMGSubsystem(GetGameIns());
        if self.TriggerDelay > 0 then
            UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, function()
                --FragmentStory.Show(self.FragmentId)
                subsytem:ApplyOpen(UE4.EUIDialogueType.FragmentStory,self.FragmentId);
            end}, self.TriggerDelay, false)
        else
            --FragmentStory.Show(self.FragmentId)
            subsytem:ApplyOpen(UE4.EUIDialogueType.FragmentStory,self.FragmentId);
        end
    end
end

return FragmentStoryTrigger
