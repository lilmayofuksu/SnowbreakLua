-- ========================================================
-- @File    : umg_main.lua
-- @Brief   : 主界面
-- ========================================================

---@class tbClass : UUserWidget
---@field PanelTouch UCanvasPanel
local tbClass = Class("UMG.BaseWidget")
function tbClass:OnInit()
    self.tbCacheBtn = {
        {
            btn = self.LevelBtn, 
            fClick = function() 
                UI.Open('Dungeons')
            end,
            tip = self.New,
        },
        {
            btn = self.BtnTouchClose, 
            fClick = function() 
                WidgetUtils.Collapsed(self.PanelTouch)
                 WidgetUtils.Collapsed(self.BtnTouchClose) 
            end 
        },
        {
            btn = self.BtnTouch, 
            fClick = function() 
                WidgetUtils.SelfHitTestInvisible(self.PanelTouch) 
                WidgetUtils.Visible(self.BtnTouchClose) 
            end 
        },
        {
            btn = self.BtnTouchChange, 
            fClick = function() 
                UI.Open('ChangeRole') 
                WidgetUtils.Collapsed(self.BtnTouchClose)
                WidgetUtils.Collapsed(self.PanelTouch) 
            end 
        },
        {
            btn = self.BtnNewTask, 
            -- fClick = function() 
            --     UI.Open('NewTask') 
            -- end 
        },
        {
            btn = self.BtnSurvey, 
            fClick = function() 
                Questionnaire.OpenQuestionnaire() 
                Questionnaire.Clicking()
                self:QuestionaireRed()--刷新红点
            end,
            tip = self.Red

        },
        {
            btn = self.BtnAction, 
            fClick = function() 
                self:OnActionClick() 
            end 
        },
        {
            btn = self.BtnMission, 
            fClick = function()
                 FunctionRouter.GoTo(FunctionType.Task) 
            end,
            type = FunctionType.Task,
            tip = self.MissionNew,
            lock = self.Lock, 
            lockvisible = true,
            lockNormal = self.NormalMission,
        },
        {
            btn = self.BtnLock, 
            fClick = function()
                 FunctionRouter.GoTo(FunctionType.Task) 
            end,
        },
        --[[{
            btn = self.BtnDorm, 
            fClick = function()
                local bUnlock, tbTip = FunctionRouter.IsOpenById(FunctionType.Dorm)
                if not bUnlock then
                    UI.ShowTip(tbTip[1] or '')
                    return false
                end
                if HouseLogic then  
                    HouseLogic:LoadHouse() 
                end 
            end,
            type = FunctionType.Dorm,
            tip = self.DormRed,
            lock = self.DormLock,
            lockNormal = self.NormalDorm, 
        },]]
        {
            btn = self.BtnRole,
            fClick = function()
                FunctionRouter.GoTo(FunctionType.Role)
            end,
            type = FunctionType.Role,
            tip = self.RoleRed,
            lock = self.RoleLock,
            lockNormal = self.NormalRole,
        },
        {
            btn = self.BtnShop,
            fClick = function()
                FunctionRouter.GoTo(FunctionType.Shop)
            end,
            type = FunctionType.Shop,
            tip = self.ShopRed,
            lock = self.ShopLock,
            lockNormal = self.NormalShop,
        },
        {
            btn = self.BtnBag,
            fClick = function()
                FunctionRouter.GoTo(FunctionType.Bag)
            end,
            type = FunctionType.Bag,
            tip = self.BagRed,
            lock = self.BagLock,
            lockNormal = self.NormalBag,
        },
        {
            btn = self.BtnHandbook,
            fClick = function()
                FunctionRouter.GoTo(FunctionType.Riki)
            end,
            type = FunctionType.Riki,
            tip = self.HandbookgRed,
            lock = self.HandbookLock,
            lockNormal = self.NormalHandbook,

        },
        {
            btn = self.BtnGacha,
            fClick = function()
                FunctionRouter.GoTo(FunctionType.Welfare)
            end,
            type = FunctionType.Welfare,
            tip = self.GachaRed,
            lock = self.GachaLock,
            lockNormal = self.NormalGacha,
        },
        {
            btn = self.BtnSetting,
            fClick = function()
                FunctionRouter.GoTo(FunctionType.Setting)
            end,
            type = FunctionType.Setting,
            tip = self.NewSetting,
            lock = self.SettingLock,
        },
        ------------------------------------------
        {
            btn = self.BtnTalk,
            fClick = function()
                
            end,
        },
        {
            btn = self.BtnBP, 
            fClick = function() 
                BattlePass.OpenUI() 
            end,
            type = FunctionType.BattlePass,
            tip = self.NewBP,
            lock = self.BPLock,
            lockNormal = self.NormalBP,
        },
        {
            btn = self.BtnMall, 
            fClick = function() 
                FunctionRouter.GoTo(FunctionType.Mall)
            end,
            type = FunctionType.Mall,
            tip = self.NewBP_1,
            lock = self.MallLock,
            lockNormal = self.NormalMall,  
        },
        {
            btn = self.BtnActivityNew, 
            fClick = function() 
                FunctionRouter.GoTo(FunctionType.Activity)
            end,
            type = FunctionType.Activity,
            tip = self.NewActivity,
            lock = self.ActivityLock,
            lockNormal = self.NormalActivity,   
        },
        {
            btn = self.BtnMail, 
            fClick = function() 
                FunctionRouter.GoTo(FunctionType.Mail)
            end,
            type = FunctionType.Mail,
            tip = self.NewMail,
            lock = self.MailLock,
            lockNormal = self.NormalMail,  
        },
        {
            btn = self.BtnNotice, 
            fClick = function() 
                FunctionRouter.GoTo(FunctionType.Notice)
            end,
            type = FunctionType.Notice,
            tip = self.NewNotice,
            lock = self.NoticeLock,
            lockNormal = self.NormalNotice, 
        },
        {
            btn = self.BtnFriend, 
            fClick = function() 
                FunctionRouter.GoTo(FunctionType.Friend)
            end,
            type = FunctionType.Friend,
            tip = self.NewFriend,
            lock = self.FriendLock,
            lockNormal = self.NormalFriend, 
        },
        {
            btn = self.BtnDLC,
            fClick = function()
                DLC_Logic.CheckOpenAct()
            end
        }

    }

    ----------------------------------

    WidgetUtils.Visible(self.BtnTouch)
    WidgetUtils.Collapsed(self.BtnTouchClose)
    WidgetUtils.Visible(self.BtnNewTask)
    WidgetUtils.Collapsed(self.BtnSurvey)
    WidgetUtils.Collapsed(self.BtnDorm)
    
    self:StreamingScene({PreviewType.role_lvup, PreviewType.Dungeons, PreviewType.dlc1_main})
end

function tbClass:OnOpen()
    Adjust.MainRecord()
    PlayerSetting.MuteMusic(false)
    Activity.OnOpen()
    local showBanner = true

    self.Money:Init({Cash.MoneyType_Vigour, Cash.MoneyType_Silver, Cash.MoneyType_Gold})
    self.nShowCardID = PlayerSetting.GetShowCardID()

    WidgetUtils.Collapsed(self.PanelTouch)
    self:ShowChapterInfo()

    if showBanner then
        self.BtnBanner:Refresh();
    else
        WidgetUtils.Collapsed(self.BtnBanner)
        WidgetUtils.Collapsed(self.whit2_1)
        WidgetUtils.Collapsed(self.whit1_1)
        WidgetUtils.Collapsed(self.WhiteBg_1)
    end

    PreviewScene.Enter(PreviewType.main, function()  end)
    PreviewMain.ResetCamera()  
    self:ShowCard()
    self.PlayerInfo:Update()
    self:BindEvent(false)
    self:BindEvent(true)
    Questionnaire.RefreshQuestionnaire()
    SevenDay:CheckAndShowSevenDayBtn(self.BtnNewTask,self.NewTask);
    self:BindNoticeTimer(true)

    Login.OnEnterMainUI()
    UI.TryGC()

    Notice.Refresh()
    self:RefreshUI()
    if self.nUIOpenHandle then
        EventSystem.Remove(self.nUIOpenHandle)
    end

    if VigourSupply:CheckReceive() then
        WidgetUtils.HitTestInvisible(self.Energy)
    else
        WidgetUtils.Collapsed(self.Energy)
    end
end

function tbClass:RefreshUI()
    self:ShowMissionItem()
    self:ShowBtnBP()
    self:ShowBtnMall()
    self:ShowBtnDlc()

    self.tbRegister = {}
    for _, info in ipairs(self.tbCacheBtn or {}) do
        if info.btn and info.fClick and not info.bInit then
            BtnAddEvent(info.btn, info.fClick)
            info.bInit = true
        end
        self:RefreshBtnState(info)
        if info.type then
            self.tbRegister[info.type] = info
        end
    end
end

function tbClass:RefreshBtnState(btnInfo)
    if not btnInfo then return end
    if btnInfo.type then
        local runtimeInfo = FunctionRouter.GetRuntimeInfo(btnInfo.type)
        if runtimeInfo then
            if btnInfo.tip then
                if runtimeInfo.nReddotNum > 0 then
                    WidgetUtils.HitTestInvisible(btnInfo.tip)
                else
                    WidgetUtils.Collapsed(btnInfo.tip)
                end
            end

            if btnInfo.lock then
                local nAlpha = 1
                if runtimeInfo.bUnlock then
                    WidgetUtils.Collapsed(btnInfo.lock)
                else
                    if btnInfo.lockvisible then
                        WidgetUtils.Visible(btnInfo.lock)
                    else
                        WidgetUtils.HitTestInvisible(btnInfo.lock)
                    end
                    nAlpha = 0.4
                end
                if btnInfo.lockNormal then
                    btnInfo.lockNormal:SetRenderOpacity(nAlpha)
                end
            end
        end
    end
end

function tbClass:OnDisable()
    self:Clear()
    PreviewMain.HiddenCard(true)
    PreviewMain.ActiveGyro(false)
end

function tbClass:OnClose()
    self:Clear()
    PreviewMain.DestroyCard()
end

function tbClass:OnChildOpen(child)
    PreviewMain.ActiveGyro(false)
end

function tbClass:OnChildClose(child)
    if self:GetTopChild() == nil then
        PreviewMain.ActiveGyro(true)
    end
end

function tbClass:OnActionClick()
    if self.bPlayCameraAnim then return end
    local pCard = me:GetItem(self.nShowCardID)
    if not pCard then return end
    local pTemplate = UE4.UItemLibrary.GetCharacterAtrributeTemplate(pCard:TemplateId())
    local nID = pTemplate.ID % 100
    self.bPlayCameraAnim = true
    EventSystem.TriggerToCpp(Event.PreviewModelUIEvent, UE4.EUIWidgetAnimType.Main, UE4.EPreviewModelUIEventType.PlayerTouch)
    Preview.PlayCameraAnimByCallback(self.nShowCardID, PreviewType.main .. '_show_' .. nID, function() self.bPlayCameraAnim = false end, false)
end

function tbClass:BindNoticeTimer(bAdd)
    local Interval = 30
    if self.NoticeTimer then  UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.NoticeTimer) self.NoticeTimer = nil end
    if bAdd then
        self.NoticeTimer = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self,function() Notice.Refresh() end }, Interval, true)
    end
end

function tbClass:ShowCard()
   -- if not self:IsOpen() then return end 
    
    PreviewMain.LoadBG(function()
        PreviewMain.ActiveGyro(true)
        PreviewMain.SetBlurBgVisible(false)
        PreviewMain.EnabledBGTick(true)
        PreviewMain.HideEffect(false)
    end, true)

    PreviewMain.SetBgVisble(true)

    if Login.bFirstEnterMainUI then  
        PreviewMain.LoadCard(self.nShowCardID,function() 
            EventSystem.TriggerToCpp(Event.PreviewModelUIEvent,UE4.EUIWidgetAnimType.Main,UE4.EPreviewModelUIEventType.EnterMain_FirstTime)
            
        end )
    else
        PreviewMain.LoadCard(self.nShowCardID, function()
            
        end)
    end
end

function tbClass:UpdateGyroCard()
    local pBG = PreviewMain.GetBG()
    if pBG then
        local pCard = Preview.GetModel(PreviewType.main)
        if pCard then
            pBG:SetCharacter(pCard)
        end
    end
end

---临时显示章节进度信息
function tbClass:ShowChapterInfo()
    local cfg, levelCfg = Chapter.GetMaxProceedLevel()
    if cfg then
        if Localization.GetCurrentLanguage() == 'zh_CN' then
            self.TxtFightName:SetText(Text(cfg.sPreName) .. ' ' .. Text(cfg.sName))
        else
            self.TxtFightName:SetText(Text(cfg.sPreName))
        end
        local nStarNum , nGetStarNum = Chapter.GetChapterStarInfo(true,cfg.nDifficult, cfg.nID)
        local nPlotNum,nGetPlotNum = Chapter.GetChapterPlotInfo(true,cfg.nDifficult , cfg.nID)
        if (nStarNum + nPlotNum) == 0 then
            WidgetUtils.Collapsed(self.PanelLevel1)
            WidgetUtils.Collapsed(self.BarLevel)
        else
            WidgetUtils.HitTestInvisible(self.PanelLevel1)
            WidgetUtils.HitTestInvisible(self.BarLevel)
            local nPercent = (nGetStarNum + nGetPlotNum) / (nStarNum + nPlotNum)
            self.BarLevel:SetPercent(nPercent)
            self.TxtProgress1:SetText(math.ceil(nPercent * 100))
        end

        if levelCfg then
            self.TxtFightLevel:SetText(GetLevelName(levelCfg))
            self.TxtDifficulty:SetText(Text( cfg.nDifficult == 2 and 'ui.TxtHard' or 'ui.TxtNormal'))
        end
    end
end

function tbClass:Clear()
    self:BindEvent(false)
    self:BindNoticeTimer(false)
    self:ClearDlcTimer()
end

--- 注册回调事件
function tbClass:BindEvent(bBind)
    if bBind then
        self.nHandleSyncMail = EventSystem.On(Event.SyncMail, function()
            self:RefreshRedInfo(FunctionType.Mail)
        end)

        local funcFlushFriendDot = function()
            self:RefreshRedInfo(FunctionType.Friend)
        end
        self.nHandleNewFriendReq = EventSystem.On(Event.OnNewFriendRequest, funcFlushFriendDot)
        self.nHandleNewFriend = EventSystem.On(Event.OnNewFriend, funcFlushFriendDot)
        self.nHandleDelFriend = EventSystem.On(Event.OnDelFriend, funcFlushFriendDot)
        self.nHandleNewFriendVigor = EventSystem.On(Event.OnNotifyFriendVigor, funcFlushFriendDot)
        self.nHandleLevelUp = EventSystem.On(Event.LevelUp, function()
                for nID , _ in pairs(self.tbRegister or {}) do
                    self:RefreshRedInfo(nID)
                end
        end)

        ---注册问卷事件
        self.nQuestionaireHandle = EventSystem.On(Event.ShowQuestionaire, function(bShow)
            if bShow then
                self:QuestionaireRed()
                WidgetUtils.Visible(self.BtnSurvey)
            else
                WidgetUtils.Collapsed(self.BtnSurvey)
            end
        end)
    else
        EventSystem.Remove(self.nHandleSyncMail)
        EventSystem.Remove(self.nHandleNewFriendReq)
        EventSystem.Remove(self.nHandleNewFriend)
        EventSystem.Remove(self.nHandleDelFriend)
        EventSystem.Remove(self.nHandleNewFriendVigor)
        EventSystem.Remove(self.nHandleLevelUp)
        EventSystem.Remove(self.nQuestionaireHandle)
    end
end

---刷新红点信息
function tbClass:RefreshRedInfo(nFunID)
    if self.tbRegister and self.tbRegister[nFunID] then
        local tbInfo =  self.tbRegister[nFunID]
        self:RefreshBtnState(tbInfo)
    end
end

---刷新问卷红点
function tbClass:QuestionaireRed()
    if Questionnaire.isClickBefore() then 
        WidgetUtils.Collapsed(self.Red)
    else
        WidgetUtils.SelfHitTestInvisible(self.Red)
    end
end


--右下角任务单条显示
function tbClass:ShowMissionItem()
    self:ShowMissionRed()
    local tbShowConfig = Achievement.GetMainMapShowUI()
    if not tbShowConfig or not FunctionRouter.IsOpenById(FunctionType.Task) then
        WidgetUtils.Collapsed(self.Image_126)
        WidgetUtils.Collapsed(self.PanelGuide)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.Image_126)
    WidgetUtils.SelfHitTestInvisible(self.PanelGuide)
    BtnClearEvent(self.BtnGuide)

    if not FunctionRouter.IsOpenById(FunctionType.TaskBranch) then
        WidgetUtils.Collapsed(self.Completed)
        WidgetUtils.SelfHitTestInvisible(self.Normal)
        self.TextBlock_175:SetText(Text("ui.TxtMissionLock"))
        return
    end

    local txtPanel = nil
    local nState = Achievement.CheckAchievementReward(tbShowConfig)
    
    if nState == 0 and tbShowConfig.nGroup == Achievement.GROUP_ExtraReward then
        nState = Achievement.STATUS_CAN
    end

    if nState == Achievement.STATUS_CAN then
        WidgetUtils.Collapsed(self.Normal)
        WidgetUtils.SelfHitTestInvisible(self.Completed)
        txtPanel = self.TextBlock_2
        BtnAddEvent(self.BtnGuide, function() FunctionRouter.GoTo(FunctionType.Task, Achievement.GROUP_BranchLine) end)
    else
        WidgetUtils.Collapsed(self.Completed)
        WidgetUtils.SelfHitTestInvisible(self.Normal)
        txtPanel = self.TextBlock_175
        BtnAddEvent(self.BtnGuide, function() Achievement.GoToUI(tbShowConfig) end)
    end

    if txtPanel and tbShowConfig.nGroup == Achievement.GROUP_ExtraReward then
        txtPanel:SetText(string.format("%s%s",Text('ui.TxtMainMission'), Text(tbShowConfig.sName)))
    elseif txtPanel then
        local sShowText = Achievement.GeDescribe(tbShowConfig)
        txtPanel:SetText(ReplaceEllipsis(sShowText, 46)) --这里限制24个中文字符
    end
end

--右下角任务红点
function tbClass:ShowMissionRed()
    if FunctionRouter.IsOpenById(FunctionType.Task) then
        WidgetUtils.Collapsed(self.Lock)
        local tbCfg = FunctionRouter.Get(FunctionType.Task)
        if tbCfg and FunctionRouter.IsShowRedDot(tbCfg) then
            WidgetUtils.Visible(self.MissionNew)
        else
            WidgetUtils.Collapsed(self.MissionNew)
        end
    else
        WidgetUtils.Visible(self.Lock)
        WidgetUtils.Collapsed(self.MissionNew)
        WidgetUtils.Collapsed(self.Image_126)
        WidgetUtils.Collapsed(self.PanelGuide)
    end
end

--bp通行证
function tbClass:ShowBtnBP()
    local tbConfig = BattlePass.GetMeConfig()
    if not tbConfig then
        WidgetUtils.Collapsed(self.BtnBP)
        return
    end

    WidgetUtils.Visible(self.BtnBP)
    self:ShowBtnRed(FunctionType.BattlePass, self.NewBP)
end

--商区区域红点
function tbClass:ShowBtnRed(nId, btn)
    if FunctionRouter.IsOpenById(nId) then
        local tbCfg = FunctionRouter.Get(nId)
        if tbCfg and FunctionRouter.IsShowRedDot(tbCfg) then
            WidgetUtils.Visible(btn)
        else
            WidgetUtils.Collapsed(btn)
        end
    else
        WidgetUtils.Collapsed(btn)
    end
end

--商城
function tbClass:ShowBtnMall()
    if not IBLogic.tbIbShopList or not next(IBLogic.tbIbShopList) then
        WidgetUtils.Collapsed(self.BtnMall)
        WidgetUtils.Collapsed(self.Discount)
        return
    end

    WidgetUtils.Visible(self.BtnMall)
    self:ShowBtnRed(FunctionType.Mall, self.NewBP_1)

    local nDay = 0
    if IBLogic.GetMonthCardTime() > GetTime()  then
        nDay = TimeDiff(IBLogic.GetMonthCardTime(), GetTime())
    end

    if nDay > 0 and nDay <= 3 then
        WidgetUtils.SelfHitTestInvisible(self.Discount)
    else
        WidgetUtils.Collapsed(self.Discount)
    end
end

function tbClass:ShowBtnDlc()
    local tbConf = DLC_Logic.GetCurConf()
    if tbConf and IsInTime(tbConf.nEnterStartTime, tbConf.nCloseEndTime) then
        WidgetUtils.Visible(self.BtnDLC)
        self.TextBlock_82:SetText(Text(tbConf.sDes))
        local leftDay = TimeDiff(tbConf.nCloseEndTime, GetTime())
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.TipTime, leftDay <= 7)
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.Img4_26, leftDay <= 3)
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.Img4_27, leftDay <= 7)
        if not self.DlcTimer then
            self.DlcTimer = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self,function() self:ShowBtnDlc() end}, 10, true)
        end
    else
        WidgetUtils.Collapsed(self.BtnDLC)
        self:ClearDlcTimer()
    end
end

function tbClass:ClearDlcTimer()
    if self.DlcTimer then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.DlcTimer)
        self.DlcTimer = nil
    end
end

return tbClass
