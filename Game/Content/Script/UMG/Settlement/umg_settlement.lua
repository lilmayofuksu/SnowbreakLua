-- ========================================================
-- @File    : umg_settlement.lua
-- @Brief   : 关卡结算界面
-- ========================================================

---@class tbClass : ULuaWidget
---@field AwardList UListView
---@field Cards UWrapBox
local tbClass = Class("UMG.BaseWidget")

tbClass.BossPath = "/Game/UI/UMG/Settlement/Widgets/uw_settlement_boss.uw_settlement_boss_C"
tbClass.InfoPath = "/Game/UI/UMG/Settlement/Widgets/uw_settlement_info.uw_settlement_info_C"
tbClass.OnlinePath = "/Game/UI/UMG/Settlement/Widgets/uw_settlement_online.uw_settlement_online_C"
tbClass.RecordPath = "/Game/UI/UMG/Settlement/Widgets/uw_settlement_record.uw_settlement_record_C"
tbClass.RoundPath = "/Game/UI/UMG/Settlement/Widgets/uw_settlement_round.uw_settlement_round_C"
tbClass.ScorePath = "/Game/UI/UMG/Settlement/Widgets/uw_settlement_score.uw_settlement_score_C"

function tbClass:OnInit()
    BtnAddEvent(self.ExitBtn, function() Launch.End() end)
    BtnAddEvent(self.AgainBtn, function() self:DoAgainBtn() end)
    BtnAddEvent(self.NextBtn, function() Launch.Next() end)
    self.ListFactory = Model.Use(self)
    self:DoClearListItems(self.RoleCurr)
    self:DoClearListItems(self.ListItem)
    self:DoClearListItems(self.AwardList)
    self.LastConsoleVar = 100
end

function tbClass:OnOpen()
    -- 结算界面是3D的，所以在打开结算界面时强制设置GlobalInvalidation
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(GetGameIns(), "Slate.EnableGlobalInvalidation 0")

    self:ExhaleMouse(true);
    WidgetUtils.Collapsed(self.CanvasPanel_1)  --self.AgainBtn
    WidgetUtils.Collapsed(self.CanvasPanel_2) --self.NextBtn
    WidgetUtils.Collapsed(self.number)
    WidgetUtils.Collapsed(self.PanelExpend)
    WidgetUtils.Collapsed(self.PanelExpend2)
    WidgetUtils.Collapsed(self.Num)
    self.TxtLevelName:SetText("")
    Launch.SetPlayAgain()

    local nType = Launch.GetType()
    local cfg = nil
    local bCanNext = false
    self.needVigor = nil
    if nType == LaunchType.CHAPTER then
        cfg = ChapterLevel.Get(Chapter.GetLevelID())
        WidgetUtils.SelfHitTestInvisible(self.number)
        self.number:SetText(GetLevelName(cfg))
        self.TxtLevelName:SetText(Text(cfg.sFlag))
        local nNextID = Chapter.GetNextLevelID()
        bCanNext = (nNextID and nNextID > 0)
        self.TxtCurrencyNum:SetText(cfg.tbConsumeVigor[2] or 0)
    elseif nType == LaunchType.DLC1_CHAPTER then
        cfg = DLCLevel.Get(DLC_Chapter.GetLevelID())
        self.TxtLevelName:SetText(GetLevelName(cfg))
        local nNextID = DLC_Chapter.GetNextLevelID()
        bCanNext = (nNextID and nNextID > 0)
        self.TxtCurrencyNum:SetText(cfg.tbConsumeVigor[2] or 0)
    elseif nType == LaunchType.TOWER then
        local nLevelID = ClimbTowerLogic.GetLevelCfg().nLevelID
        cfg = TowerLevel.Get(nLevelID)
        self.TxtLevelName:SetText(Text("climbtower.name", ClimbTowerLogic.GetNowLayer()))
        local nNextID = Chapter.GetNextLevelID()
        bCanNext = (nNextID and nNextID > 0)
        self.TxtCurrencyNum:SetText(cfg.tbConsumeVigor[2] or 0)
    elseif nType == LaunchType.DAILY then
        cfg = DailyLevel.Get(Daily.GetLevelID())
        local nNextID = Daily.GetNextLevelID()
        bCanNext = (nNextID and nNextID > 0)
        self:ShowDailyAgainBtn(cfg)
    elseif nType == LaunchType.ROLE then
        cfg = RoleLevel.Get(Role.GetLevelID())
    elseif nType == LaunchType.DEFEND then
        cfg = DefendLogic.GetLevelConf(DefendLogic.GetIDAndDiff())
    end
    self:ShowCardInfo(cfg, nType)

    if bCanNext then
        WidgetUtils.SelfHitTestInvisible(self.CanvasPanel_2) --self.NextBtn
    end

    if nType == LaunchType.BOSS then
        WidgetUtils.Collapsed(self.Normal.PanelStar)
        WidgetUtils.Collapsed(self.PanelItem)
        WidgetUtils.Collapsed(self.AccountInfo)
        WidgetUtils.Collapsed(self.Normal.PanelRole)
        self.Boss = WidgetUtils.AddChildToPanel(self.CanvasPanel_118, self.BossPath)
        WidgetUtils.Visible(self.Boss.PanelBoss)
        self:ShowPanelBoss()
    elseif nType == LaunchType.DAILY then
        WidgetUtils.Collapsed(self.Normal.PanelStar)
        self.InfoTxt  = WidgetUtils.AddChildToPanel(self.CanvasPanel_118, self.InfoPath)
        WidgetUtils.SelfHitTestInvisible(self.InfoTxt.PanelInfo)
        local tbCfg = DailyLevel.Get(Daily.GetLevelID())
        if tbCfg then
            WidgetUtils.SelfHitTestInvisible(self.number)
            self.InfoTxt.TxtContent:SetText(Text(tbCfg.sDes))
            self.number:SetText(GetLevelName(tbCfg))
            self.TxtLevelName:SetText(Text(tbCfg.sFlag))
        end
        self:ShowAwardItems()
    elseif nType == LaunchType.ROLE then
        WidgetUtils.Collapsed(self.Normal.PanelStar)
        WidgetUtils.Visible(self.PanelItem)
        self:ShowAwardItems()
    elseif nType == LaunchType.ONLINE then
        WidgetUtils.Collapsed(self.Normal.PanelStar)
        WidgetUtils.Collapsed(self.PanelItem)
        self.Online = WidgetUtils.AddChildToPanel(self.CanvasPanel_118, self.OnlinePath)
        WidgetUtils.Visible(self.Online.PanelOnline)
        self:ShowPanelOnline()
        if UE4.AGameTaskActor.GetGameTaskActor(GetGameIns()):GetFightLog_LevelFinishType() == 1 then 
            --WidgetUtils.Visible(self.PanelItem)
            --self:ShowAwardItems()
            EventSystem.TriggerTarget(
                Survey,
                Survey.PRE_SURVEY_EVENT,
                Survey.ONLINE,
                Online.GetOnlineLevelId()
            )
        end
    elseif nType == LaunchType.DEFEND then
        WidgetUtils.Collapsed(self.Normal.PanelStar)
        WidgetUtils.Collapsed(self.PanelItem)
        self.Round = WidgetUtils.AddChildToPanel(self.CanvasPanel_118, self.RoundPath)
        WidgetUtils.Visible(self.Round.PanelRound)
        self:ShowDefendPnl()
    elseif nType == LaunchType.DLC1_CHAPTER then
        WidgetUtils.Visible(self.Normal.PanelStar)
        WidgetUtils.Visible(self.PanelItem)

        if cfg and #cfg.tbStarCondition > 0 then
            WidgetUtils.HitTestInvisible(self.Normal.StarContent)
            self:ShowStarInfo()
        else
            WidgetUtils.Collapsed(self.Normal.StarContent)
        end
        self:ShowAwardItems()
    else
        if cfg and cfg.nType == ChapterLevelType.Challenge then
            WidgetUtils.Collapsed(self.Normal.PanelStar)
            WidgetUtils.Collapsed(self.PanelItem)
            self.Record = WidgetUtils.AddChildToPanel(self.CanvasPanel_118, self.RecordPath)
            self.Record.Records:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
            self:ShowPanelRecord(cfg.nID)
        else
            WidgetUtils.Visible(self.Normal.PanelStar)
            WidgetUtils.Visible(self.PanelItem)

            if cfg and #cfg.tbStarCondition > 0 then
                WidgetUtils.HitTestInvisible(self.Normal.StarContent)
                self:ShowStarInfo()
            else
                WidgetUtils.Collapsed(self.Normal.StarContent)
            end
            self:ShowAwardItems()
        end
    end

    -- 抓背景帧
    local ConsoleName = "r.SeparateTranslucencyScreenPercentage"
    self.LastConsoleVar = UE4.UGraphicsSettingManager.GetFloatConsoleVariable(ConsoleName)
    UE4.UGraphicsSettingManager.SetConsoleVariable(self, ConsoleName, "100")
    self.SceneBack:DoCapture()
    -- 延迟一帧隐藏场景，渲染是异步的，如果当前帧hide object，会抓不到东西
    UE4.Timer.Add(0, function()
        UE4.ULevelLibrary.HideAllObject(GetGameIns())
        local BPTaskActor = UE4.AGameTaskActor.GetGameTaskActor(self)
        if BPTaskActor then
            --BPTaskActor:DestroySequenceActor() --[[  ]]
        end
    end)
    
end

function tbClass:OnClose()
    UE4.UGraphicsSettingManager.SetConsoleVariable(self, "r.SeparateTranslucencyScreenPercentage", tostring(self.LastConsoleVar))
    --self:ExhaleMouse(false)
    self.needVigor = nil
    if self.AwardTimer then
        UE4.Timer.Cancel(self.AwardTimer)
        self.AwardTimer = nil
    end
end

---显示升级信息
function tbClass:ShowCardInfo(cfg, nType)
    -- if nType == LaunchType.ONLINE then
    --     local nId = Online.GetOnlineLevelId()
    --     for i = 1, 3 do
    --         local pCardItem = self.Cards:GetChildAt(i - 1)
    --         pCardItem:Set(nil, nil, i == 1 and nId or nil)
    --     end
    --     return  
    -- end

    local nRoleExp = 0
    if cfg and cfg.nRoleExp then
        nRoleExp = cfg.nRoleExp
        if Launch.GetMultiple() > 1 then
            nRoleExp = nRoleExp * Launch.GetMultiple()
        end
    end
    local GameState = UE4.UGameplayStatics.GetGameState(self:GetOwningPlayerPawn())
    if GameState then
        local Cards = GameState:GetTeamCards()
        for i = 1, 3 do
            local pCardItem = self.Normal.Cards:GetChildAt(i - 1)
            if i <= Cards:Length() then
                pCardItem:Set(Cards:Get(i), nRoleExp)
            else
                pCardItem:Set(nil)
            end
        end
    end
end

---显示星级目标信息
function tbClass:ShowStarInfo()
    local pSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE4.ULevelStarTaskManager)
    if not pSubSys then
        WidgetUtils.Collapsed(self.Normal.StarContent)
        return
    end
    local Infos = pSubSys:GetStarTaskProperties()
    for i = 1, Infos:Length() do
        local pItem = Infos:Get(i)
        local pWidget = self.Normal.StarContent:GetChildAt(i - 1)
        if pWidget then
            pWidget:Set(pItem.bFinished, pItem.Description, pItem.CurrentState)
            pWidget.CanvasPanel_0:SetRenderOpacity(0)
        end
    end
end

---依次播放动画
function tbClass:PlayStarInfoAnim()
    local Index = 0
    local pWidget = self.Normal.StarContent:GetChildAt(Index)
    if pWidget then
        pWidget:PlayAnimation(pWidget.EnterAnim)
    end
    Index = Index + 1

    self.AnimTimer = UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
            if Index >= 3 then
                UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.AnimTimer)
                return
            end
            local pWidget = self.Normal.StarContent:GetChildAt(Index)
            if pWidget then
                pWidget:PlayAnimation(pWidget.EnterAnim)
            end
            Index = Index + 1
        end
        },
        0.5,
        true
    )
end

---显示奖励列表
function tbClass:ShowAwardItems()
    -- print("ShowAwardItems traceback:",debug.traceback())
    local tbAward = Launch.tbAward
    -- 联机奖励
    if Launch.GetType() == LaunchType.ONLINE then tbAward = Online.GetDropList() end
    if not tbAward then return end
    self:DoClearListItems(self.AwardList)
    self.AwardList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    for idx, tbInfo in ipairs(tbAward) do
        local tbParam = { nIdx = idx, tbAward = tbInfo, bShow =(#tbAward > 1)  }
        local pObj = self.ListFactory:Create(tbParam)
        self.AwardList:AddItem(pObj)
    end

    if self.AwardTimer then
        UE4.Timer.Cancel(self.AwardTimer)
        self.AwardTimer = nil
    end

   self.AwardTimer = UE4.Timer.Add(3, function()
        if self.AwardTimer then
            self.AwardTimer = nil
        end
        if self.AwardList then
            self.AwardList:RequestRefresh()
        end
    end)
end

-- 显示联机积分奖励
function tbClass:ShowPanelScore()
    local state = UE4.UGameLibrary.GetPlayerState(self:GetOwningPlayer())
    local point = state and state:GetMultiLevelPoint() or 0
    self.TxtNum:SetText(point);
end

-- 显示联机增益积分奖励(新)
function tbClass:ShowPanelOnline()
    local state = UE4.UGameLibrary.GetPlayerState(self:GetOwningPlayer())
    local point = state and state:GetMultiLevelPoint() or 0

    local tbConfig = Online.GetConfig(Online.GetOnlineId())
    local findCard = function(tbParam, tbPickCard)
        if not tbParam or not  tbPickCard then return end
        for _, member in ipairs(tbPickCard) do
            if member and #member >= 4 and 1 == member[1] and tbParam[1] == member[2] and tbParam[2] == member[3] then
                return true
            end
        end
    end

    self.Online.ListRoleUp:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.Online.ListRoleUp)
    
    local nFindNum = 0
    local nGainRoleRate = 0
    if tbConfig then
        nGainRoleRate = tbConfig.nGainRoleRate
        local tbRoles = Online.GetWeekGainRole(tbConfig) or {}
        local tbPickCard = Online.GetPickCard() or {}
        for _, info in ipairs(tbRoles) do
            local itemTemp = UE4.UItem.FindTemplate(1, info[1], info[2], 1)
            if itemTemp then
                local nRet = findCard(info, tbPickCard)
                local data = {
                    nIcon = itemTemp.Icon,
                    bGray = not nRet,
                    FunClick = function() UI.Open("ItemInfo", 1, info[1], info[2], 1) end
                }

                if nRet then
                    nFindNum = nFindNum + 1
                end

                local pObj = self.ListFactory:Create(data)
                self.Online.ListRoleUp:AddItem(pObj)
            end
        end
    end

    self.Online.TxtRoleUp:SetText(string.format(Text("ui.TxtRoleUp"), nFindNum * nGainRoleRate))
    local nAllScore = math.floor(point * (1+nFindNum * nGainRoleRate * 0.01))
    self.Online.RedirectTextBlock_76:SetText(string.format(Text("ui.TxtGetOnlinePoint"), nAllScore))
end

---显示挑战关卡阵容记录
function tbClass:ShowPanelRecord(nID)
    --当前记录
    local time = Launch.GetLatelyTime()
    local min = math.floor(time / 60)
    local sec = math.ceil(time % 3600 % 60)
    self.Record.TxtTime:SetText(string.format("%02d:%02d", min, sec))

    self:DoClearListItems(self.Record.ListItem)
    local Lineup = Formation.GetCurrentLineup()
    if Lineup then
        for _, v in pairs(Lineup:GetMembers()) do
            local card = v:GetCard()
            if card then
                local tbParam = {G = card:Genre(), D = card:Detail(), P = card:Particular(), L = card:Level(), fCustomEvent = function() end}
                local pObj = self.ListFactory:Create(tbParam)
                self.Record.ListItem:AddItem(pObj)
            end
        end
    end

    --历史记录
    self.Record.Records:ClearChildren()
    for _, v in ipairs(LevelRecordLogic.GetTeamData(nID)) do
        local Widget = LoadWidget("/Game/UI/UMG/Level/Widgets/uw_level_item_challenge.uw_level_item_challenge_C")
        if Widget then
            self.Record.Records:AddChild(Widget)
            Widget:Init(v)
            if v.lately and tonumber(v.lately) > 0 then
                Widget:ShowPoit()
            end
        end
    end
end

function tbClass:ShowPanelBoss()
    WidgetUtils.HitTestInvisible(self.Boss.InfoBoss)
    local BossId = BossLogic.GetBossLevelCfg(BossLogic.GetBossLevelID()).nBossID
    -- print("ShowPanelBoss id:", BossId)
    self.Boss.TxtBossName:SetText(Localization.GetMonsterName(BossId))
    -- print("ShowPanelBoss name:", Localization.GetMonsterName(BossId))
    --self.TxtBossName:SetText(Text("monster."..boosid.."_name"))
    self.Boss.Monster:UpdateIcom(BossId)

    local nowIntegral = BossLogic.GetNowIntegral()
    self.Boss.TxtBossScore:SetText(nowIntegral)
    local tbTeam = Formation.GetCurrentLineup()
    self:DoClearListItems(self.Boss.RoleCurr)
    if tbTeam then
        local Cards = tbTeam:GetCards()
        for i = 1, Cards:Length() do
            local card = Cards:Get(i)
            local tbParam = {G = card:Genre(), D = card:Detail(), P = card:Particular(), L = card:Level(), fCustomEvent = function() end}
            local pObj = self.ListFactory:Create(tbParam)
            self.Boss.RoleCurr:AddItem(pObj)
        end
    end
    self.Boss.TxtTime1:SetText(self:FormatBossLevelTime(BossLogic.FinishTime))

    local history = BossLogic.GetMaxIntegral()
    if history > 0 then
        WidgetUtils.HitTestInvisible(self.Boss.PanelBossList)
        self.Boss.TxtBestScore:SetText(history)
        local info = {}
        local tbrole = BossLogic.GetMaxIntegralLineup()
        for i = 1, 3 do
            if tbrole[i] > 0 then
                local card = me:GetItem(tbrole[i])
                if card then
                    info["member"..i] = {card:Genre(), card:Detail(), card:Particular(), card:Level()}
                end
            end
        end
        self.Boss.RecordBoss:Init(info)
        self.Boss.TxtTime2:SetText(self:FormatBossLevelTime(BossLogic.GetLevelFinishTime()))
    else
        WidgetUtils.Collapsed(self.Boss.PanelBossList)
    end

    if not UI.IsOpen("MessageBox") then
        if nowIntegral > history then
            UI.Open("MessageBox", Text("bossentries.save", nowIntegral),
            function() BossLogic.Req_LevelSettlement(true) end,
            function() BossLogic.Req_LevelSettlement(false) end)
        else
            BossLogic.Req_LevelSettlement(false)
        end
    end
end

function tbClass:FormatBossLevelTime(nTotalSeconds)
    if not nTotalSeconds or nTotalSeconds <= 0 then
        return 0
    end
    local nHours = math.floor(nTotalSeconds/3600)
    local nMinutes = math.floor(nTotalSeconds%3600/60)
    local nSeconds = nTotalSeconds%60
    return string.format("%d:%d:%d", nHours, nMinutes, nSeconds)
end

function tbClass:ShowDefendPnl()
    self.Round.TxtRound:SetText(DefendLogic.GetCurWave() - 1)
    WidgetUtils.Collapsed(self.Round.PanelRoundStar)
end

function tbClass:ExhaleMouse(bShow)
    RuntimeState.ChangeInputMode(bShow)
end

--每日本显示重复挑战
function tbClass:ShowDailyAgainBtn(tbCfg)
    if not Launch.CheckLevelMutipleOpen() then
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.CanvasPanel_1) -- AgainBtn
    WidgetUtils.SelfHitTestInvisible(self.PanelExpend2)
    -- WidgetUtils.SelfHitTestInvisible(self.Num)

    -- self.Num:SetText(string.format("X%d", Launch.GetMultiple()))
    self.TextAgain:SetText(string.format("%sX%d", Text("ui.BtnSettlement1") ,Launch.GetMultiple()))
    self:UpdateVigor(tbCfg)
end

---消耗体力显示
function tbClass:UpdateVigor(tbCfg)
    if not tbCfg or not self.TxtCurrencyNum2 then return end 

    local vigor
    if tbCfg.tbConsumeVigor then
        vigor = (tbCfg.tbConsumeVigor[1] or 0) + (tbCfg.tbConsumeVigor[2] or 0)
    elseif tbCfg.nConsumeVigor then 
        vigor = tbCfg.nConsumeVigor
    end
    if not vigor then return end

    if Launch.GetMultiple() > 1 then
        vigor = vigor * Launch.GetMultiple()
    end

    self.TxtCurrencyNum2:SetText(vigor)
    local _color = self.AgainBtn.ColorAndOpacity
    local defaultBGColor = UE4.UUMGLibrary.GetSlateColor(_color.R, _color.G, _color.B, 1.0)
    if Cash.GetMoneyCount(Cash.MoneyType_Vigour) >= vigor then
        self.TxtCurrencyNum2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
    else
        defaultBGColor = UE4.UUMGLibrary.GetSlateColor(_color.R, _color.G, _color.B, 0.5)
        self.TxtCurrencyNum2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#aa3131'))
    end
    self.AgainBtn:SetColorAndOpacity(defaultBGColor)
    self.needVigor = vigor
end

function tbClass:DoAgainBtn()
    Launch.Again()
end

function tbClass:CanEsc()
    return false
end

return tbClass
