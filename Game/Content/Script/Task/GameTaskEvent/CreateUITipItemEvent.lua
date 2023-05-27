-- ========================================================
-- @File    : CreateUITipItemEvent.lua
-- @Brief   : 创建万向轮指示ui
-- @Author  :
-- @Date    :
-- ========================================================
---@class CreateUITipItemEvent : GameTaskEvent
local CreateUITipItemEvent = Class()

function CreateUITipItemEvent:OnTrigger()
    local BindActor = self:GetBindActor()
    local FightUMG = UI.GetUI("Fight")
    if BindActor and FightUMG and FightUMG.uw_fight_monster_tips then
        self.UIItem = FightUMG.uw_fight_monster_tips:CreateTaskItem(BindActor,self.TipType,"")
        return true
    end
    return false
end

return CreateUITipItemEvent
