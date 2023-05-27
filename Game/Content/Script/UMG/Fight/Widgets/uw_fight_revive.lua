-- ========================================================
-- @File    : uw_fight_revive.lua
-- @Brief   : 战斗界面复活按钮
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_revive = Class("UMG.SubWidget")

function uw_fight_revive:BindExitInteractEvent()
    self:RegisterEvent(
        Event.EndOverlapReviver,
        function(InReviver)
            if InReviver == self.ItemOwner then
                self:RemoveFromList()
            end
        end
    )
end

function uw_fight_revive:TriggerInteract()
    if self.ItemOwner and self.ItemOwner:StartRevive() then
        self:RemoveFromList()
    end
end

return uw_fight_revive
