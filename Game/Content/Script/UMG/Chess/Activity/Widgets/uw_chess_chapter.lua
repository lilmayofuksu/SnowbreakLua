-- ========================================================
-- @File    : uw_chess_chapter.lua
-- @Brief   : 棋盘活动章节界面
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Show(tbMap)
    for i = 1, 6 do
        if tbMap[i] then
            WidgetUtils.SelfHitTestInvisible(self['Node'..i])
            self['Node'..i]:Show(tbMap[i])
        else
            WidgetUtils.Collapsed(self['Node'..i])
        end
    end
end

return tbClass