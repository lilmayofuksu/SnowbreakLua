-- ========================================================
-- @File    : Role.lua
-- @Brief   : 角色养成界面场景
-- ========================================================

---@class tbClass 
local tbClass = PreviewScene.Class('Role')

function tbClass:OnEnter(fCallback)
if fCallback then fCallback() end
end

function tbClass:OnLeave()
    
end

return tbClass
