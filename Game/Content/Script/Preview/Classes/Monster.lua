-- ========================================================
-- @File    : Monster.lua
-- @Brief   : Boss场景
-- ========================================================

---@class tbClass 
local tbClass = PreviewScene.Class('Monster')

function tbClass:OnEnter(fCallback)
    if fCallback then fCallback() end
end

function tbClass:OnLeave()

end

return tbClass
