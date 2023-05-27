-- ========================================================
-- @File    : uw_chessiteminfo_item.lua
-- @Brief   : 道具信息展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
    WidgetUtils.Collapsed(self.PanelPiece)
    WidgetUtils.Collapsed(self.ImgRole)
end

function tbClass:ShowChessItem(cfg)
    self.TxtNum:SetText(cfg.count)
    self.TxtSkillIntro1:SetText(Text(cfg.desc))
    self.TxtNameItem:SetText(Text(cfg.name))
    SetTexture(self.ImgIcon, cfg.icon)
end

return tbClass
