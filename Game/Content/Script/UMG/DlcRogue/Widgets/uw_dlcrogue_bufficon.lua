-- ========================================================
-- @File    : uw_dlcrogue_bufficon.lua
-- @Brief   : 肉鸽活动 bufficon
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Show(Icon)
    if Icon then
        SetTexture(self.ImgBuffIcon, Icon)
    end
end

return tbClass
