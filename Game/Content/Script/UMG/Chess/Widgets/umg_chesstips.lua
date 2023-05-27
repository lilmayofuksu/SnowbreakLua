-- ========================================================
-- @File    : umg_chesstips.lua
-- @Brief   : 棋盘 - 主线任务提示
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClose, function()
        UI.Close(self)
        EventSystem.Trigger(Event.OnMessageTipsEnd) 
    end)
end

function tbClass:OnOpen(tbCfg)
    self.TxtTitle:SetText(Text(tbCfg.tbArg.name))
    self.TxtContent:SetText(Text(tbCfg.tbContent.desc))
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.Start, tbCfg.bStart)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.End, not tbCfg.bStart)

end

return tbClass