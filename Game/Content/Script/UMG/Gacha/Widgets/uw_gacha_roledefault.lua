-- ========================================================
-- @File    : uw_gacha_roledefault.lua
-- @Brief   : 角色蛋池
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnShow(cfg)
    if cfg.nPoolUI then
        WidgetUtils.HitTestInvisible(self.ImgBG)
        SetTexture(self.ImgBG, cfg.nPoolUI)
    else
        WidgetUtils.Collapsed(self.ImgBG)
    end

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