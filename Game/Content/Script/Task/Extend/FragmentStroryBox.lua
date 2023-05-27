-- ========================================================
-- @File    : FragmentStoryBox.lua
-- @Brief   : 交互触发碎片化剧情
-- @Author  : MYF
-- @Date    :
-- ========================================================

---@class FragmentStoryBox : TreasureBoxBase
local FragmentStoryBox = Class('Task.Extend.TreasureBoxBase')

function FragmentStoryBox:ReceiveBeginPlay()
    self.bCanActive = not FragmentStory.IsGot(self.FragmentId) --记录过的ID，不再激活
    self:SetActive(self.bCanActive)
    self.Handle = EventSystem.On(
        Event.OnFragmentStroyInteractFinish,
        function(FragmentId)
            --print("FragmentStoryBox:Interact Finish:", FragmentId)
            if FragmentId == self.FragmentId and self.UIItem then
                --print("FragmentStoryBox:Interact Finish!")
                self.bCanActive = false
            end
        end, true
    )

    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                local FightUMG = UI.GetUI("Fight")
                if FightUMG and FightUMG.uw_fight_monster_tips and self.bCanActive then
                    self.UIItem = FightUMG.uw_fight_monster_tips:CreateItem(self, UE4.EFightMonsterTipsType.Dialogue,
                        "GuideUIPos")
                end
            end
        },
        0.1,
        false
    )
end

function FragmentStoryBox:TriggerHandle(bIsBeginOverlap, OtherActor)
    if self:IsLocalPlayer(OtherActor) then
        if bIsBeginOverlap then
            self.UIItem:SetShow(false)--overlap 一律关掉显示
            EventSystem.Trigger(Event.OnInteractListAddItem, self.InteractWidgetClass, 1, self)
        else
            self.UIItem:SetShow(self.bCanActive)--EndOverLap 由激活状态决定
            EventSystem.Trigger(Event.EndOverlapFragmentstory, self)
        end
    end
end

function FragmentStoryBox:ReceiveEndPlay()
    EventSystem.Remove(self.Handle)
    self.Handle = nil
end

return FragmentStoryBox
