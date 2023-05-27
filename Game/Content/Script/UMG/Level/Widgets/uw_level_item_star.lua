-- ========================================================
-- @File    : uw_level_item_star.lua
-- @Brief   : 关卡星级显示
-- ========================================================

---@class tbClass : UUserWidget
local tbClass = Class("UMG.SubWidget")

function tbClass:Set(tbCfg)

    if not tbCfg then return end

     ---显示星级情况
    local tbStarInfo = tbCfg:DidGotStars()
    for i = 0, 2 do
        local Img = self['BgFull_' .. i ]
        if Img then
            if tbStarInfo[i] then
                WidgetUtils.HitTestInvisible(Img)
            else
                WidgetUtils.Collapsed(Img)
            end
        end
    end
end

return tbClass