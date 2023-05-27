-- ========================================================
-- @File    : Teleport.lua
-- @Brief   : 
-- @Author  : CMS
-- @Date    : 2021-3-15
-- ========================================================

---@class USkillMove_Teleport:USkillMove
local Teleport = Class()

function Teleport:OnMoveEnd(MovementComp)
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end


return Teleport
