-- ========================================================
-- @File    : uw_gacha_rolerookie.lua
-- @Brief   : 新手池表现
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnShow(cfg)
    WidgetUtils.PlayEnterAnimation(self)
end

function tbClass:OnHide()
    Audio.PlaySounds(3040)
end

function tbClass:OnDestruct()
    Audio.PlaySounds(3040)
end

function tbClass:OnEnterMap()
end

return tbClass