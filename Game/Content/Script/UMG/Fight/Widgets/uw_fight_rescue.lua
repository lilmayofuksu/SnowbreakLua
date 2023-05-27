-- ========================================================
-- @File    : uw_fight_rescue.lua
-- @Brief   : 战斗界面救助按钮
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_rescue = Class("UMG.SubWidget")

function uw_fight_rescue:BindExitInteractEvent()
    self:RegisterEvent(
        Event.EndOverlapTombstone,
        function(InTombstone)
            if InTombstone == self.ItemOwner then
                self:RemoveFromList()
            end
        end
    )
end

function uw_fight_rescue:TriggerInteract()
    if self.ItemOwner then
        --- 发出救护操作
        local OwnerPlayer = UE4.AGamePlayerController
        OwnerPlayer:Revive(self.ItemOwner)
        self:RemoveFromList()
    end
end

return uw_fight_rescue
