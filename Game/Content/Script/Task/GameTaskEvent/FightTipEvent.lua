-- ========================================================
-- @File    : FightTipEvent.lua
-- @Brief   : 客户端提示
-- @Author  :
-- @Date    :
-- ========================================================
---@class FightTipEvent : GameTaskEvent
local FightTipEvent = Class()

function FightTipEvent:OnTrigger()
    if self.Important then
        self:ImportantTip(Text('tip.'..self.TipTitle), Text('tip.'..self.TipId))--addtipstext tipskey
        return
    end
    EventSystem.Trigger(Event.FightTip, {bShowCompleteTip = true, Type = self.Type, bShowUIAnim = true, Msg = Text('tip.'..self.TipId)}) --tips queue.
end

return FightTipEvent
