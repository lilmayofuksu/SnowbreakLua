-- ========================================================
-- @File    : umg_iteminfo.lua
-- @Brief   : 道具信息展示
-- ========================================================
---@class tbClass : UUserWidget
---@field PanelInfo UOverlay
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(
        self.BtnClose,
        function()
            UI.Close(self)
        end
    )
end

function tbClass:OnOpen(tbParam)
    self.ChessItemInfo:ShowChessItem(tbParam)
end

return tbClass
