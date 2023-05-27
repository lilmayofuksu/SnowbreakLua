-- ========================================================
-- @File    : uw_chess_node.lua
-- @Brief   : 棋盘活动章节节点
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSelect, function()
        ChessLogic.EnterMap(self.tbConf.nId, self.tbConf.nMapId)
    end)
end

function tbClass:Show(tbMapInfo)
    local timeConf = ChessLogic.GetTimeConf()
    self.tbConf = tbMapInfo
    self.TxtName:SetText(Text(tbMapInfo.sName))
    local isUnlock = ChessLogic.IsMapUnlock(tbMapInfo.nId, tbMapInfo.nMapId)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.ImgLock, not isUnlock)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.UnLock, isUnlock)
    local startTime = tbMapInfo.nUnlockTime < timeConf.nBeginTime and timeConf.nBeginTime or tbMapInfo.nUnlockTime
    self.TxtTimeStart:SetText(os.date('%m/%d', startTime))
    self.TxtTimeEnd:SetText(os.date('%m/%d', timeConf.nEndTime))
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.Red, isUnlock and not ChessLogic.IsMapEnter(tbMapInfo.nId, tbMapInfo.nMapId))
    if not isUnlock then
        self.BarNum:SetPercent(0)
    else
        local Score = ChessReward:GetScore(tbMapInfo.nId, ChessActivityType.DLC1, tbMapInfo.tbMapResource[2])
        self.BarNum:SetPercent(Score / 1000)
    end
end

return tbClass