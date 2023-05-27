-- ========================================================
-- @File    : umg_genral_construction.lua
-- @Brief   : 提示
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self:BindToAnimationEvent(
        self.OpenAnim,
        {
            self,
            function()
                UI.sCacheLastTip = nil
                UI.Close(self)
                EventSystem.Trigger(Event.OnMessageTipsEnd)
            end
        },
        UE4.EWidgetAnimationEvent.Finished
    )
end

function tbClass:OnOpen(InTip)
    self.Tip:SetText(InTip)
    if not self.OpenAnim then  return  end
    self:PlayAnimation(self.OpenAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end

return tbClass
