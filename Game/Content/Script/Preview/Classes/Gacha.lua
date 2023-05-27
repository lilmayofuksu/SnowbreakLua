-- ========================================================
-- @File    : Gacha.lua
-- @Brief   : 抽卡场景
-- ========================================================

---@class tbClass 
local tbClass = PreviewScene.Class('Gacha')

function tbClass:OnEnter(fCallback)
    if fCallback then fCallback() end
end

function tbClass:OnLeave()

end

return tbClass
