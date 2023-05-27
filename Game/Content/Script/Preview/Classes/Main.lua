-- ========================================================
-- @File    : Main.lua
-- @Brief   : 主界面场景逻辑
-- ========================================================

---@class tbClass 
local tbClass = PreviewScene.Class('Main')

function tbClass:OnEnter(fCallback)
    PreviewMain.bValid = true
    if fCallback then fCallback() end
    PreviewMain.ResetCamera()
end

function tbClass:OnLeave()
    PreviewMain.Clear()
    PreviewMain.bValid = false
end

return tbClass
