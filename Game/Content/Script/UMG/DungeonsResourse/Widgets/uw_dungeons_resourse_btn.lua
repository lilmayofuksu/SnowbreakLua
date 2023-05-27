-- ========================================================
-- @File    : uw_dungeons_resourse_btn.lua
-- @Brief   : 出击主界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnGold, function()
        UI.Open('DungeonsSmap', self.nID)
    end)
end

function tbClass:Set(tbCfg)
    -- 联机临时处理
    if tbCfg.nType == 6 then
        self.nID = tbCfg.nID
        self.nType = tbCfg.nType
        self.nMode = tbCfg.nMode
        self.TxtGoldDungeons:SetText('联机关卡')
        self.TxtGoldTime:SetText(string.format('%d人模式', self.nMode))
        WidgetUtils.Collapsed(self.PanelLock)
        return
    else
        self.nType = nil
        self.nMode = nil
    end

    self.nID = tbCfg.nID
    self.TxtGoldDungeons:SetText(Text(tbCfg.sName))
    local tbOpenDay = tbCfg.tbOpenDay
    self.TxtGoldTime:SetText(Daily.OpenDayToStr(tbOpenDay))

    if Daily.IsOpen(self.nID) then
        WidgetUtils.Collapsed(self.PanelLock)
    else
        WidgetUtils.HitTestInvisible(self.PanelLock)
    end

    WidgetUtils.Collapsed(self.PanelTag)

    self.TxtTime:SetText(Daily.GetRemainTime(self.nID))
end

return tbClass