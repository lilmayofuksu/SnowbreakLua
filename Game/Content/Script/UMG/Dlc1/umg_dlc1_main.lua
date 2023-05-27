-- ========================================================
-- @File    : umg_dlc1_main.lua
-- @Brief   : dlc1主界面
-- ========================================================

local tbClass = Class('UMG.BaseWidget')

tbClass.tbEntryBtnInfo = {
    {EnName = 'Story', sName = 'TxtDLC1Name', nIcon = 1701135, sDes = 'TxtDLC1NameMark'},
    {EnName = 'Try', sName = 'TxtDLC1Try', nIcon = 1701134, sDes = 'TxtDLC1TryMark'},
    {EnName = 'Refresh', sName = 'TxtDLC1Refresh', nIcon = 1701136, sDes = 'TxtDLC1RefreshMark'},
    {EnName = 'Chess', sName = 'TxtDLC1Chess', nIcon = 1701137, sDes = 'TxtDLC1ChessMark'},
    {EnName = 'Defense', sName = 'TxtDLC1Defense', nIcon = 1701138, sDes = 'TxtDLC1DefenseMark'},
    {EnName = 'Roguelike', sName = 'TxtDLC1Roguelike', nIcon = 1701139, sDes = 'TxtDLC1RoguelikeMark'}
}

tbClass.tbBallRotator = {
    {{0, 0, 0}, {0, 0, 0}}, {{60, 60, 60}, {60, 60, 60}}, {{120, 120, 120}, {120, 120, 120}},
    {{180, 180, 180}, {180, 180, 180}}, {{240, 240, 240}, {240, 240, 240}}, {{300, 300, 300}, {300, 300, 300}}
}

function tbClass:OnInit()
    BtnAddEvent(self.BtnStory, function() self:ClickStory() end)
    BtnAddEvent(self.BtnTry, function() self:ClickTry() end)
    BtnAddEvent(self.BtnRefresh, function() self:ClickRefresh() end)
    BtnAddEvent(self.BtnChess, function() self:ClickChess() end)
    BtnAddEvent(self.BtnDefense, function() self:ClickDefense() end)
    BtnAddEvent(self.BtnRoguelike, function() self:ClickRougelike() end)

    BtnAddEvent(self.BtnShop, function() UI.Open('Dlc1Shop') end)
    BtnAddEvent(self.BtnMission, function() UI.Open('Dlc1Award') end)
end

function tbClass:OnOpen()
    PreviewScene.Enter(PreviewType.dlc1_main)
    Preview.PlayCameraAnimByCfgByID(Preview.COMMONID, PreviewType.dlc1_main)
    self:LoadModel()
    self.tbConf = DLC_Logic.GetCurConf()
    if not self.tbConf then return end

    if self.TimerIdx then
        UE4.Timer.Cancel(self.TimerIdx)
        self.TimerIdx = nil
    end
    self:UpdateTime()
    self:UpdateRed()
    WidgetUtils.Collapsed(self.BtnMask)
end

function tbClass:UpdateSystemState()
    local fun = function(widget, info)
        if not widget then return end
        SetTexture(widget.ImgIcon, info.nIcon)
        widget.TxtEN:SetText(info.EnName)
        widget.TxtTitle:SetText(Text('ui.' .. info.sName))
        widget.TxtMark:SetText(Text('ui.'..info.sDes))

        SetTexture(widget.ImgIcon_1, info.nIcon)
        widget.TxtEN:SetText(info.TxtEN_1)
        widget.TxtTitle_1:SetText(Text('ui.' .. info.sName))
        widget.TxtMark_1:SetText(Text('ui.'..info.sDes))
    end

    local conf = DLC_Chapter.tbChapter[1]
    self.tbEntryBtnInfo[1].bUnlock = DLC_Chapter.CheckChapterOpen(1)
    self.tbEntryBtnInfo[1].tbTimeInfo = {conf.OpenTime, conf.CloseTime}

    self.tbEntryBtnInfo[2].bUnlock = Activity.IsOpen(12)
    conf = Activity.GetActivityConfig(12)
    self.tbEntryBtnInfo[2].tbTimeInfo = conf ~= nil and {conf.nStartTime, conf.nEndTime} or nil

    conf = DLC_Chapter.tbChapter[2]
    self.tbEntryBtnInfo[3].bUnlock = DLC_Chapter.CheckChapterOpen(2)
    self.tbEntryBtnInfo[3].tbTimeInfo = {conf.OpenTime, conf.CloseTime}

    conf = ChessLogic.tbTimeConf[1]
    self.tbEntryBtnInfo[4].bUnlock = conf ~= nil and FunctionRouter.IsOpenById(FunctionType.ChessActive)
    self.tbEntryBtnInfo[4].tbTimeInfo = conf ~= nil and {conf.nBeginTime, conf.nEndTime} or nil

    conf = DefendLogic.GetOpenConf()
    self.tbEntryBtnInfo[5].bUnlock = conf ~= nil and FunctionRouter.IsOpenById(FunctionType.Defend)
    self.tbEntryBtnInfo[5].tbTimeInfo = {DefendLogic.GetSpecialTime('DefenseMainDlc1')}

    self.tbEntryBtnInfo[6].bUnlock = RogueLogic.GetActivitieID() > 0
    local startTime, endTime
    for i = 1, 2 do
        local tbCfg = RogueLogic.tbActivitiesCfg[i]
        if tbCfg then
            if not startTime or tbCfg.nStartTime < startTime then startTime = tbCfg.nStartTime end
            if not endTime or tbCfg.nEndTime > endTime then endTime = tbCfg.nEndTime end
        end
    end
    self.tbEntryBtnInfo[6].tbTimeInfo = {startTime, endTime}

    for _, info in ipairs(self.tbEntryBtnInfo) do
        fun(self['Common'..info.EnName], info)
        fun(self['Over'..info.EnName], info)
        fun(self['Common'..info.EnName..'2'], info)

        local bOver = info.tbTimeInfo and (GetTime() > info.tbTimeInfo[2]) or false
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self['Lock'..info.EnName], not bOver and not info.bUnlock)
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self['Over'..info.EnName], bOver)
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self['Common'..info.EnName], not bOver and info.bUnlock)

        WidgetUtils.Collapsed(self['Over'..info.EnName].TxtTime)
        WidgetUtils.Collapsed(self['Over'..info.EnName].TxtTime_1)
        WidgetUtils.SelfHitTestInvisible(self['Over'..info.EnName].TxtOver)
        WidgetUtils.SelfHitTestInvisible(self['Over'..info.EnName].TxtOver_1)

        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self['Txt'..info.EnName..'Lock'], info.bUnlock and info.tbTimeInfo)
    end
end

function tbClass:UpdateTime()
    if not self.tbConf then return end
    self:UpdateSystemState()

    if self.tbConf.nEndTime > GetTime() then
        local nDay, nHour, nMin, nSec = TimeDiff(self.tbConf.nEndTime, GetTime())
        if nDay > 0 then
            WidgetUtils.SelfHitTestInvisible(self.TxtDay)
            WidgetUtils.Collapsed(self.TxtTime)
            self.TxtDay:SetText(string.format("%s%s", nDay, Text("ui.TxtTimeDay")))
        else
            local strTime = string.format("%02d:%02d:%02d", nHour, nMin, nSec)
            WidgetUtils.SelfHitTestInvisible(self.TxtTime)
            WidgetUtils.Collapsed(self.TxtDay)
            self.TxtTime:SetText(strTime)
        end
    else
        WidgetUtils.Collapsed(self.TxtDay)
        WidgetUtils.Collapsed(self.TxtTime)
    end

    local funGetTimeStr = function(Time)
        local nDay, nHour, nMin, nSec = TimeDiff(Time, GetTime())
        if nDay > 0 then
            return string.format("%s%s", nDay, Text("ui.TxtTimeDay"))
        else
            return string.format("%02d:%02d:%02d", nHour, nMin, nSec)
        end
    end

    local now = GetTime()
    for _, info in ipairs(self.tbEntryBtnInfo) do
        if info.tbTimeInfo then
            local TimeStr
            if now < info.tbTimeInfo[1] then
                TimeStr = Text('ui.RemainingTime') .. funGetTimeStr(info.tbTimeInfo[1])
            elseif now < info.tbTimeInfo[2] then
                TimeStr = Text('ui.RemainingTime') .. funGetTimeStr(info.tbTimeInfo[2])
            end
            if TimeStr then
                self['Common'..info.EnName].TxtTime:SetText(TimeStr)
                self['Common'..info.EnName].TxtTime_1:SetText(TimeStr)
                self['Common'..info.EnName..'2'].TxtTime:SetText(TimeStr)
                self['Common'..info.EnName..'2'].TxtTime_1:SetText(TimeStr)
                self['Txt'..info.EnName..'Lock']:SetText(TimeStr)
            end
        else
            WidgetUtils.Collapsed(self['Common'..info.EnName].TxtTime)
            WidgetUtils.Collapsed(self['Over'..info.EnName].TxtTime)
            WidgetUtils.Collapsed(self['Common'..info.EnName..'2'].TxtTime)
            WidgetUtils.Collapsed(self['Common'..info.EnName].TxtTime_1)
            WidgetUtils.Collapsed(self['Over'..info.EnName].TxtTime_1)
            WidgetUtils.Collapsed(self['Common'..info.EnName..'2'].TxtTime_1)
            WidgetUtils.Collapsed(self['Txt'..info.EnName..'Lock'])
        end
    end

    self.TimerIdx = UE4.Timer.Add(1, function() self:UpdateTime() end)
end

function tbClass:UpdateRed()
    WidgetUtils.Collapsed(self.NewShop)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.NewMission, DLC_Logic.HasCanGetMission())
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.CommonStory.New, DLC_Chapter.GetNewDotState())
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.CommonTry.New, GachaTry.HasNew(12))
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.CommonRefresh.New, DLC_Logic.CheckFirst('dlc1refresh'))
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.CommonChess.New, ChessLogic.HasNew())
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.CommonDefense.New, DLC_Logic.CheckFirst('dlc1defense') or DefendLogic.CanGetReward())
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.CommonRoguelike.New, DLC_Logic.CheckFirst('dlc1rouge') or RogueLogic.CheckRedDot())
end

function tbClass:OnClose()
    if self.TimerIdx then
        UE4.Timer.Cancel(self.TimerIdx)
        self.TimerIdx = nil
    end
    if self.RotateTimerIdx then
        UE4.Timer.Cancel(self.RotateTimerIdx)
        self.RotateTimerIdx = nil
    end
    self:ClearModel()
    WidgetUtils.Collapsed(self.BtnMask)
end

function tbClass:OnDisable()
    if self.TimerIdx then
        UE4.Timer.Cancel(self.TimerIdx)
        self.TimerIdx = nil
    end
    if self.RotateTimerIdx then
        UE4.Timer.Cancel(self.RotateTimerIdx)
        self.RotateTimerIdx = nil
    end
    UE4.Timer.Add(0.15, function() self:ClearModel() end)
    WidgetUtils.Collapsed(self.BtnMask)
end

function tbClass:LoadModel()
    if not self.ModelActor then
        local ActorClass = UE4.UClass.Load("/Game/UI/UMG/DLC1/Widgets/BP_PreviewDLC1_Ball.BP_PreviewDLC1_Ball_C")
        self.ModelActor = GetGameIns():GetWorld():SpawnActor(ActorClass)
        self.ModelActor:SetActorScale3D(UE4.FVector(0.18, 0.18, 0.18))
        self.ModelActor:K2_SetActorLocation(UE4.FVector(4, -2, 163))
        self.uw_dlc1_rotate:SetModel(self.ModelActor)
    end
end

function tbClass:ClearModel()
    if self.ModelActor and IsValid(self.ModelActor) then
        self.ModelActor:ClearSequence()
        self.ModelActor:K2_DestroyActor()
    end
    self.ModelActor = nil
    PreviewScene.HiddenAll()
    PreviewScene.Reset()
end

function tbClass:ForceRotate(idx, canEnter, msg, pCall)
    if self.RotateTimerIdx or self.ModelActor.bRotateTo then return end
    local x, y, z = table.unpack(self.tbBallRotator[idx][1])
    local x2, y2, z2 = table.unpack(self.tbBallRotator[idx][2])
    Audio.PlaySounds(3047)
    self.ModelActor:StartForceRotateTo(UE4.FRotator(x, y, z), UE4.FRotator(x2, y2, z2), canEnter)

    if canEnter and pCall then
        self.RotateTimerIdx = UE4.Timer.Add(1.7, function()
            self.RotateTimerIdx = nil
            pCall()
        end)
        UE4.Timer.Add(2, function()
            local ui = UI.GetTop()
            if ui and ui.sName == 'dlc1main' then
                WidgetUtils.Collapsed(self.BtnMask)
                WidgetUtils.SelfHitTestInvisible(ui)
            end
        end)
    elseif msg and msg ~= '' then
        UI.ShowMessage(Text(msg))
    end
    if canEnter and pCall then
        self.ModelActor:PlaySequence()
        WidgetUtils.Visible(self.BtnMask)
        WidgetUtils.Collapsed(self)
        UE4.Timer.Add(0.8, function() Audio.PlaySounds(3048) end)
    end
end

function tbClass:ClickStory()
    local bUnlock, tbMsg = DLC_Chapter.CheckChapterOpen(1)
    local msg = 'ui.TxtNotOpen'
    if tbMsg and tbMsg[1] then msg = tbMsg[1] end
    self:ForceRotate(2, bUnlock, msg, function()
        DLC_Chapter.SetChapterID(1)
        UI.Open("Dlc1Story", 1)
    end)
end

function tbClass:ClickTry()
    local bUnlock, tbMsg = Activity.IsOpen(12)
    local msg = 'ui.TxtNotOpen'
    if tbMsg and tbMsg[1] then msg = tbMsg[1] end
    self:ForceRotate(2, bUnlock, msg, function() Activity.OpenActicity(12) end)
end

function tbClass:ClickRefresh()
    local bUnlock, tbMsg = DLC_Chapter.CheckChapterOpen(1)
    local msg = 'ui.TxtNotOpen'
    if tbMsg and tbMsg[1] then msg = tbMsg[1] end
    self:ForceRotate(2, bUnlock, msg, function()
        DLC_Chapter.SetChapterID(1)
        UI.Open("Dlc1Refresh", 2)
        DLC_Logic.SetFirstCheck('dlc1refresh')
    end)
end

function tbClass:ClickChess()
    local conf = ChessLogic.tbTimeConf[1]
    local msg, bUnlock, tbMsg = 'ui.TxtNotOpen', false, {}
    if not conf or GetTime() < conf.nBeginTime then
        msg = 'ui.TxtNotOpen'
    elseif GetTime() > conf.nEndTime then
        msg = 'ui.TxtDLC1Over'
    else
        bUnlock, tbMsg = FunctionRouter.IsOpenById(FunctionType.ChessActive)
        if not bUnlock then msg = tbMsg[1] end
    end
    self:ForceRotate(4, bUnlock, msg, function() ChessLogic.CheckOpenAct() end)
end

function tbClass:ClickDefense()
    local startTime, endTime = DefendLogic.GetSpecialTime('DefenseMainDlc1')
    local bUnlock = IsInTime(startTime, endTime)
    local msg = nil
    if not bUnlock then
        if GetTime() < startTime then msg = 'ui.TxtNotOpen'
        elseif GetTime() > endTime then msg = 'ui.TxtDLC1Over' end
    else
        bUnlock, msg = FunctionRouter.IsOpenById(FunctionType.Defend)
        if not bUnlock then msg = msg[1] end
    end
    self:ForceRotate(5, bUnlock, msg, function()
        DefendLogic.CheckOpenAct()
        DLC_Logic.SetFirstCheck('dlc1defense')
    end)
end

function tbClass:ClickRougelike()
    local bUnlock = RogueLogic.GetActivitieID() > 0
    local msg = nil
    if GetTime() < self.tbEntryBtnInfo[6].tbTimeInfo[1] then
        msg = 'ui.TxtNotOpen'
        bUnlock = false
    elseif GetTime() > self.tbEntryBtnInfo[6].tbTimeInfo[2] then
        msg = 'ui.TxtDLC1Over'
        bUnlock = false
    end
    self:ForceRotate(6, bUnlock, msg, function ()
        local ntime = tonumber(me:GetStrAttribute(RogueLogic.nGID, RogueLogic.nOpenStoryID)) or 0
        local cfg = DLC_Logic.GetCurConf()
        if cfg then
            if IsInTime(cfg.nEnterStartTime, cfg.nCloseEndTime, ntime) then
                UI.Open("DlcRogue")
            else
                Launch.SetType(LaunchType.DLC1_ROGUE)
                RogueLevel.SetLevelID(RogueLogic.nPlotLevelID)
                Launch.Start()
            end
        end
        DLC_Logic.SetFirstCheck('dlc1rouge')
    end)
end

return tbClass