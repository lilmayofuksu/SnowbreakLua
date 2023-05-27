-- ========================================================
-- @File    : TowerMap.lua
-- @Brief   : TowerMap
-- ========================================================

---@class tbClass 
local tbClass = Map.Class('TowerMap')

function tbClass:OnEnter()
    if ClimbTowerLogic.IsChangeToNext() then
        ClimbTowerLogic.IsToNext = nil
        local widget = Activity.LoadCaseItem("/Game/UI/UMG/Fight/Widgets/Loading/uw_fight_scene_off.uw_fight_scene_off_C")
        widget:AddToViewport(1)
        widget:SceneOff()
    end
end

return tbClass
