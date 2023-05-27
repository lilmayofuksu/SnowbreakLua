-- ========================================================
-- @File    : uw_chess_bag_item.lua
-- @Brief   : 背包内容条目
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    BtnAddEvent(self.BtnClick, function()
        UI.Open("ChessItemInfo", {
            count = self.tbData.count,
            name = self.tbData.cfg.Name,
            desc = self.tbData.cfg.Desc,
            icon = self.tbData.cfg.Icon
        })
    end)
    WidgetUtils.Collapsed(self.PanelNot)
    WidgetUtils.Collapsed(self.PanelLimitTime)
    WidgetUtils.Collapsed(self.Lock)
end

function view:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data;
    self.TxtNum:SetText(self.tbData.count)
    self.TxtDesc:SetText(Text(self.tbData.cfg.Desc))
    self.TxtName:SetText(Text(self.tbData.cfg.Name))
    SetTexture(self.Icon, self.tbData.cfg.Icon)
end

return view