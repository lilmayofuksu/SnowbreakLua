-- ========================================================
-- @File    : uw_widgets_time.lua
-- @Brief   : 时间控件
-- ========================================================

local tbClass = Class("UMG.SubWidget")
tbClass.tbDefaultColor = { --第一个文字和时间图标的颜色，第二个时间的颜色
    {1.0,1.0,1.0,0.6},
    {1.0,1.0,1.0,1},
}

--传入倒计时时间、倒计时结束执行的函数(可选)
-- sKey文本key  bCloseBG隐藏背景图片  
-- tbColor修改字体颜色{第一个文字和时间图标的颜色，第二个时间的颜色}
function tbClass:ShowNormal(time, fun, sKey, bCloseBG, tbColor)
    --倒计时间
    self.DisTime = time
    --倒计时结束执行的函数
    self.FunCallback = fun

    if bCloseBG then
        WidgetUtils.Collapsed(self.ImgBg)
    else
        WidgetUtils.SelfHitTestInvisible(self.ImgBg)
    end

    if tbColor and tbColor[1] then
        self.ImgTime:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(table.unpack(tbColor[1])))
        self.Txtnew:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(table.unpack(tbColor[1])))
    else
        self.ImgTime:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(table.unpack(self.tbDefaultColor[1])))
        self.Txtnew:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(table.unpack(self.tbDefaultColor[1])))
    end

    if tbColor and tbColor[2] then
        self.TxtDay:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(table.unpack(tbColor[2])))
        self.TxtTime:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(table.unpack(tbColor[2])))
    else
        self.TxtDay:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(table.unpack(self.tbDefaultColor[2])))
        self.TxtTime:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(table.unpack(self.tbDefaultColor[2])))
    end

    if self.DisTime then
        self:UpdatePanel()
    else
        self:ShowWeeklyCountDown(sKey)
    end

    self:ShowText(sKey)
end

--每周一 4点
function tbClass:ShowWeeklyCountDown(sKey)
    self.FunCallback = function ()
        self.DisTime = GetTimeFor4AM(GetTime(), 2)
    end
    self.FunCallback()
    self:UpdatePanel()

    self:ShowText(sKey)
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
    if not self.DisTime then return end

    if self.DisTime > GetTime() then
        local nDay, nHour, nMin, nSec = TimeDiff(self.DisTime, GetTime())
        if nDay > 0 then
            local strTime = string.format("%s%s", nDay, Text("ui.TxtTimeDay"))
            WidgetUtils.SelfHitTestInvisible(self.TxtDay)
            WidgetUtils.Collapsed(self.TxtTime)
            self.TxtDay:SetText(strTime)
        else
            local strTime = string.format("%02d:%02d:%02d", nHour, nMin, nSec)
            WidgetUtils.SelfHitTestInvisible(self.TxtTime)
            WidgetUtils.Collapsed(self.TxtDay)
            self.TxtTime:SetText(strTime)
        end
    else
        WidgetUtils.Collapsed(self.TxtDay)
        WidgetUtils.Collapsed(self.TxtTime)
        if self.FunCallback then
            self.FunCallback()
            self.FunCallback = nil
        end
    end
end

--修改文本
function tbClass:ShowText(sKey)
    if sKey then
        self.Txtnew:SetText(Text(sKey))
    end
end

return tbClass
