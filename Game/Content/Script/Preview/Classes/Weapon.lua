-- ========================================================
-- @File    : Weapon.lua
-- @Brief   : 武器场景
-- ========================================================

---@class tbClass 
local tbClass = PreviewScene.Class('Weapon')

function tbClass:OnEnter(fCallback)
   
if fCallback then fCallback() end
end

function tbClass:OnLeave()
    
end

return tbClass
