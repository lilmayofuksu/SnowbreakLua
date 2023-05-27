-- ========================================================
-- @File    : ZetaTeleport.lua
-- @Brief   : 
-- @Author  : CMS
-- @Date    : 2021-3-15
-- ========================================================

---@class USkillMove_ZetaTeleport:USkillMove
local ZetaTeleport = Class()

function ZetaTeleport:OnMoveEnd(MovementComp)
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end

return ZetaTeleport
