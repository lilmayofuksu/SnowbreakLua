-- ========================================================
-- @File    : DeleteUITipItemEvent.lua
-- @Brief   : 删除万向轮指示ui
-- @Author  :
-- @Date    :
-- ========================================================
---@class DeleteUITipItemEvent : GameTaskEvent
local DeleteUITipItemEvent = Class()

function DeleteUITipItemEvent:OnTrigger()
    local BindActor = self:GetBindActor()
    local FightUMG = UI.GetUI("Fight")
    if BindActor and FightUMG and FightUMG.uw_fight_monster_tips then
        self.UIItem = FightUMG.uw_fight_monster_tips:FindUsedItem(BindActor,self.TipType)
        if self.UIItem then
            self.UIItem:Reset()
        end
        return true
    end
    return false
end

return DeleteUITipItemEvent
