-- ========================================================
-- @File    : uw_help_page_img.lua
-- @Brief   : 图片轮播介绍界面的一页
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Init(data)
    if data.Path then
        SetTexture(self.Image, data.Path)
    end
end

return tbClass