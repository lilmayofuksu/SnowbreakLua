-- ========================================================
-- @File    : uw_chess_help.lua
-- @Brief   : 棋盘帮助界面
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    BtnAddEvent(self.BtnClose, function() self:OnClose() end)
    self:RegisterEvent(Event.NotifyChessOpenHelp, function(tbParam) self:OnOpen(tbParam) end) 
    self:OnClose()
end

function view:OnOpen(tbParam)
    WidgetUtils.Visible(self.Root)   
    ChessEditor.IsOpenSpecialUI = true
end

function view:OnClose()
    ChessEditor.IsOpenSpecialUI = false
    WidgetUtils.Collapsed(self.Root)
end

return view