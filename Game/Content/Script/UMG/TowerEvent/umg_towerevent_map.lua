-- ========================================================
-- @File    : umg_towerevent_map.lua
-- @Brief   : 爬塔-战术考核主界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()

end

function tbClass:OnOpen(bFirstOpen)
    Launch.SetType(LaunchType.TOWEREVENT)
    self.uw_towerevent_chapter:UpdateChapters(bFirstOpen, self.LevelScrollBox)
end

function tbClass:OnClose()
    -- TowerEventChapter.SetChapterID(nil)
    -- TowerEventChapter.SetLevelID(nil)
end

return tbClass
