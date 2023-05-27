-- ========================================================
-- @File    : Normal.lua
-- @Brief   : 通用
-- ========================================================

---@class tbClass 
local tbClass = PreviewScene.Class('Normal')

function tbClass:OnEnter(fCallback)
if fCallback then fCallback() end
end

function tbClass:OnLeave()
    
end

return tbClass
