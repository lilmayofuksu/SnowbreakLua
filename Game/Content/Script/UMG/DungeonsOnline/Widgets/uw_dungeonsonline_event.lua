-- ========================================================
-- @File    : uw_dungeonsonline_event.lua
-- @Brief   : 联机界面 玩法卡面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

--打开界面
function tbClass:OnOpen(tbConfig)
    if not tbConfig then 
        self:ShowEmpty()
        return
    end

    self:ShowMain(tbConfig)
    self:PlayAnimation(self.AllEnter)
end

--显示空
function tbClass:ShowEmpty()
    WidgetUtils.SelfHitTestInvisible(self.Empty)
    WidgetUtils.Collapsed(self.Bg)
    WidgetUtils.Collapsed(self.Icon)
    WidgetUtils.Collapsed(self.TxtName)
    WidgetUtils.Collapsed(self.TxtTime)
    WidgetUtils.Collapsed(self.BtnEvent)
    WidgetUtils.Collapsed(self.ImgTimeBg)
    WidgetUtils.Collapsed(self.HorizontalBox_64)
    WidgetUtils.Collapsed(self.CanvasPanel_108)
    WidgetUtils.Collapsed(self.ImgUp)
    WidgetUtils.Collapsed(self.Imgdown)
end

--显示主要界面
function tbClass:ShowMain(tbConfig)
    WidgetUtils.Collapsed(self.Empty)
    WidgetUtils.SelfHitTestInvisible(self.CanvasPanel_108)
    WidgetUtils.SelfHitTestInvisible(self.ImgTimeBg)
    WidgetUtils.SelfHitTestInvisible(self.HorizontalBox_64)
    WidgetUtils.SelfHitTestInvisible(self.ImgUp)
    WidgetUtils.SelfHitTestInvisible(self.Imgdown)

    if tbConfig.nBg then
        WidgetUtils.SelfHitTestInvisible(self.Bg)
        SetTexture(self.Bg, tbConfig.nBg)
    end

    if tbConfig.nIcon and self.Icon then
        WidgetUtils.SelfHitTestInvisible(self.Icon)
        SetTexture(self.Icon, tbConfig.nIcon)
    end

    if tbConfig.sName then
        WidgetUtils.SelfHitTestInvisible(self.TxtName)
        self.TxtName:SetText(Text(tbConfig.sName))
    end

    if tbConfig.tbDate then
        WidgetUtils.SelfHitTestInvisible(self.TxtTime)
        self.TxtTime:SetText(self:ChangeDateText(tbConfig.tbDate, tbConfig.tbOpenHour))
    end

    WidgetUtils.Visible(self.BtnEvent)
    self.BtnEvent.OnClicked:Clear()
    self.BtnEvent.OnClicked:Add(self, function()
        self:OnClickOne(tbConfig)
    end)

    self:UpdatePanel()
end

--数字(周几)转为大写(周几)
function tbClass:ChangeDateText(tbDate, tbOpenHour)
    if not tbDate then return "" end

    local sHour = ""
    if type(tbOpenHour) == "table" and #tbOpenHour > 0 then
        sHour = ""
        for i,v in ipairs(tbOpenHour) do
            if type(v) == "table" and #v >= 2 then
                local nPre = tonumber(v[1])
                local nEnd = tonumber(v[2])

                if nPre > nEnd then
                    nEnd = tonumber(v[1])
                    nPre = tonumber(v[2])
                end
                if i > 1 then
                    sHour = sHour ..","
                end

                sHour = sHour .. string.format("%d:00-%d:00", nPre, nEnd)
            end
        end
    end

    if #tbDate == 7 then
        if sHour == "" then
            return Text('ui.DailyOpenTimeAll')
        else
            return string.format(Text('ui.DailyOpenTimeNight'), sHour)
        end
    end

    local sDate = ""
    for i,v in ipairs(tbDate) do
        sDate = sDate..(Text("ui.TxtNum"..v) or "")
    end

    return string.format(Text('ui.TxtDailyOpenTime'), sDate)..sHour
end

--进入编队界面
function tbClass:OnClickOne(tbConfig)
    local bOk, sTip = Online.CheckOpen(tbConfig)
    if not bOk then
        UI.ShowTip(sTip or 'tip.congif_err')
        return
    end

    Online.SetOnlineId(tbConfig.nId)
    --调用主界面的点击函数 从头开始
    local sUI = UI.GetUI("DungeonsOnlineLevel")
    if not sUI then
        UI.Open("DungeonsOnlineLevel", tbConfig)
    else
        sUI:OnOpen(tbConfig)
    end
end

--每秒刷新
function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.detime then self.detime = 0 end
    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end
    self.detime = 0

    self:UpdatePanel()
end

--刷新显示时间 xx日xx时xx分
function tbClass:UpdatePanel()
    local nDisTime = GetTimeFor4AM(GetTime(), 2)
    local nDay, nHour, nMin, nSec = TimeDiff(nDisTime, GetTime())
    if nMin and (nDay + nHour + nMin + nSec) > 0 then
        if nDay > 0 then
            local strTime = string.format("%s%s", nDay, Text("ui.TxtTimeDay"))
            WidgetUtils.SelfHitTestInvisible(self.Txt4)
            WidgetUtils.Collapsed(self.Txt3)
            self.Txt4:SetText(strTime)
        else
            local strTime = string.format("%02d:%02d:%02d", nHour, nMin, nSec)
            WidgetUtils.SelfHitTestInvisible(self.Txt3)
            WidgetUtils.Collapsed(self.Txt4)
            self.Txt3:SetText(strTime)
        end
    else
        WidgetUtils.Collapsed(self.Txt3)
        WidgetUtils.Collapsed(self.Txt4)
    end
end

return tbClass
