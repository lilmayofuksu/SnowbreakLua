-- ========================================================
-- @File    : WeaponPart.lua
-- @Brief   : 武器配件场景
-- ========================================================

---@class tbClass 
local tbClass = PreviewScene.Class('WeaponPart')

function tbClass:OnEnter(fCallback)
if fCallback then fCallback() end
end

function tbClass:OnLeave()
   
end

return tbClass
