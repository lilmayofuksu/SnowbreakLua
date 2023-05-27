-- ========================================================
-- @File    : umg_formation.lua
-- @Brief   : 阵容界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.BaseWidget")

tbClass.tbFormationType = {
    {1, 2, 3, 4, 5},                --普通编队编号
    {6},                            --爬塔活动大楼编队编号
    {7, 8},                         --爬塔活动基座编队编号
    {Formation.TRIAL_INDEX},        -- 试玩队伍
    {Online.TeamId},                -- 联机编队
    {RogueLogic.TeamId},            -- 肉鸽编队(不在服务器存储编队数据)
    {DefendLogic.TeamId},           -- 死斗编队
}

function tbClass:OnInit()
    self:DoClearListItems(self.LeftBtns2)
    self.FightBtn.OnClicked:Add(self, function() 
        self:ClearTimer()
        self.nTimer = UE4.Timer.Add(0.2, function()
            self.nTimer = nil
            self:PreDoFight()
        end)
    end)
    self.BreakCheck.OnCheckStateChanged:Add(
         self,
         function(_, bChecked)
            if bChecked then
                WidgetUtils.SelfHitTestInvisible(self.CheckMark_2)
                WidgetUtils.SelfHitTestInvisible(self.F0.InfoPop)
                WidgetUtils.SelfHitTestInvisible(self.F1.InfoPop)
                WidgetUtils.SelfHitTestInvisible(self.F2.InfoPop)
                WidgetUtils.Collapsed(self.Backgroud_2)
            else
                WidgetUtils.SelfHitTestInvisible(self.Backgroud_2)
                WidgetUtils.Collapsed(self.CheckMark_2)
                WidgetUtils.Collapsed(self.F0.InfoPop)
                WidgetUtils.Collapsed(self.F1.InfoPop)
                WidgetUtils.Collapsed(self.F2.InfoPop)
            end
         end
        )
    --self.BreakCheck:SetVisibility(FunctionRouter.IsOpenById(25) and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
---UI打开
function tbClass:OnOpen(nLevelID, bOnline, tbLevelCfg)

    if not UI.bPoping then  -- 保存打开界面时的launchtype 放置各种跳转返回后launchtype不对
        self.LastLaunchType = Launch.GetType()
    else
        Launch.SetType(self.LastLaunchType)
    end

    Preview.Destroy()
    -- PreviewScene.Reset()
    -- print("Preview.Destroy PreviewScene.Reset")
    if not tbLevelCfg then
        local nID = Launch.GetLevelID()
        if Formation.CacheParam[nID] then
            tbLevelCfg = Formation.CacheParam[nID]
        end
    else
        Formation.CacheParam[tbLevelCfg.nID or 0] = tbLevelCfg
    end

    Formation.bTrial = false
    self.bOnline = bOnline or self.bOnline
    self.nLevelID = nLevelID or Launch.GetLevelID()
    self.LevelCfg = tbLevelCfg or self.LevelCfg

    if Launch.GetType() == LaunchType.ONLINE and Online.GetOnlineId() > 0 and not nLevelID and not bOnline then --换角色后回调处理
        if Formation.GetCurLineupIndex() == self.tbFormationType[5][1] then
            self.bOnline = true
            Formation.Req_UpdateLineup(Online.TeamId, function() end)
        end
    end

    Preview.PlayCameraAnimByCfgByID(Preview.COMMONID, PreviewType.formation)
    Formation.SpawnActor(self)

    if self.bOnline then --联机界面
        self:ShowOnline()
    else
        self:ShowNormal(nLevelID)
    end
    if self.LevelCfg then
        WidgetUtils.SelfHitTestInvisible(self.TxtName)
        if Launch.GetType() == LaunchType.BOSS then
            self.TxtName:SetText(Text(Localization.GetMonsterName(self.LevelCfg.nBossID)))
        else
            self.TxtName:SetText(GetLevelName(self.LevelCfg))
        end
    else
        WidgetUtils.Collapsed(self.TxtName)
    end
    self:UpdatePower()
    --WidgetUtils.SetVisibleOrCollapsed(self.BreakCheck, FunctionRouter.IsOpenById(FunctionType.ProLevel) and not self.bOnline)
    WidgetUtils.Collapsed(self.BreakCheck)

    self:UpdateStarInfo(tbLevelCfg)
end

function tbClass:UpdateStarInfo(tbLevelCfg)
    if Launch.GetType() ~= LaunchType.CHAPTER then
        WidgetUtils.Collapsed(self.Conditions)
        return
    end

    local tbStarInfo = tbLevelCfg.DidGotStars and tbLevelCfg:DidGotStars() or {}
    if #tbStarInfo < 1 then
        WidgetUtils.Collapsed(self.Conditions)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.Conditions)
    local ret = Formation.CheckStarConditionResult(tbLevelCfg)

    for i = 0, #tbLevelCfg.tbStarCondition - 1 do
        local pItem = self.PanelStar:GetChildAt(i)
        if pItem then
            local pPro = UE4.ULevelStarTaskManager.GetStarTaskProperty(tbLevelCfg.nID, i)
            pItem:SetInfo(pPro.Description, tbStarInfo[i] or ret[i+1])
            WidgetUtils.SelfHitTestInvisible(pItem)
        end
    end
end

function tbClass:GetTeamRuleID()
    return self.LevelCfg and self.LevelCfg.nTeamRuleID or nil
end

function tbClass:ShowNormal(nLevelID)
    WidgetUtils.Collapsed(self.Online)
    Chapter.bReqEnter = false
    Formation.bReqUpdate = false

    self.nLevelID = nLevelID or Launch.GetLevelID()
    self.FightBtn:SetVisibility(UE4.ESlateVisibility.Visible)

    self.LINEUPINDEX = self.tbFormationType[1]

    if not GuideLogic.IsCanEditFormation() then
        self.LINEUPMAX = 1
        WidgetUtils.Collapsed(self.LeftBtns)
    elseif self:GetTeamRuleID() ~= nil then
        WidgetUtils.Collapsed(self.LeftBtns)
        self.LINEUPMAX = 1
    elseif Launch.GetType() == LaunchType.DLC1_ROGUE then
        self.LINEUPINDEX = self.tbFormationType[6]
        WidgetUtils.Collapsed(self.LeftBtns)
        self.LINEUPMAX = 1
    elseif Launch.GetType() == LaunchType.DEFEND then
        self.LINEUPINDEX = self.tbFormationType[7]
        WidgetUtils.Collapsed(self.LeftBtns)
        self.LINEUPMAX = 1
    else
        self.LINEUPMAX = #self.LINEUPINDEX
        WidgetUtils.Visible(self.LeftBtns)
    end

    --重写返回事件
    self.Title:SetCustomEvent(function()
        Formation.Req_UpdateLineup(self.CurLineupIndex, function()
            UI.CloseTop()
            if Launch.GetType() == LaunchType.CHESS then
                ChessClient:ReturnMap()
            end
        end)
    end,
    function() Formation.Req_UpdateLineup(self.CurLineupIndex, function() UI.OpenMainUI() end) end)
    ---更新按钮
    self.Bts = {}
    for i = 1, self.LeftBtns:GetChildrenCount() do
        local Bt = self.LeftBtns:GetChildAt(i - 1)
        if Bt then
            if i <= self.LINEUPMAX then
                Bt:Init(function(...) self:ApplyChangeLineup(...) end, "0" .. i, self.LINEUPINDEX[i])
                if self.LINEUPINDEX[i] == self.CurLineupIndex then
                    Bt:SetState(BtnState.Select)
                    self.SelectBtn = Bt
                else
                    Bt:SetState(BtnState.Normal)
                end
                self.Bts[self.LINEUPINDEX[i]] = Bt
            else
                WidgetUtils.Collapsed(Bt)
            end
        end

    end
    PreviewScene.Enter(PreviewType.formation, function()
        self:OnLevelLoadFinish()
        self:UpdateFormationTips()
    end)
end

---地图加载完毕
function tbClass:OnLevelLoadFinish()
    local nTeamID = Formation.GetCurLineupIndex()
    if nTeamID < self.LINEUPINDEX[1] or nTeamID > self.LINEUPINDEX[self.LINEUPMAX] then
        nTeamID = self.LINEUPINDEX[1]
    end
    ---队伍规则读取
    local nTeamRuleID = self:GetTeamRuleID()
    if nTeamRuleID then
        Formation.bTrial = true
        nTeamID = Formation.TRIAL_INDEX
        TeamRule.CreateRule(nTeamRuleID)
    end

    self:ChangeLineup(nTeamID)
end

function tbClass:ClearTimer()
    if self == nil then return end
    if self.nTimer then
        UE4.Timer.Cancel(self.nTimer)
        self.nTimer = nil
    end
end

function tbClass:OnClose()
    Formation.SaveLineup_Handle = nil
    Formation.Clear()
    self.tbLevelConf = nil
    if WidgetUtils.IsVisible(self.Online) then
        self.Online:OnClose()
    end
    TeamRule.Clear()
    TeamRule.Save(self.nLevelID)
    self:ClearTimer()
end

function tbClass:OnDisable()
    self.SelectBtn = nil
    Formation.Clear()
    if WidgetUtils.IsVisible(self.Online) then
        self.Online:OnDisable()
    end
end

function tbClass:PreDoFight()
    local bLimit0 , sMsg0 = self.F0:GetLimitInfo()
    if bLimit0 then UI.ShowTip(sMsg0) return end

    local bLimit1 , sMsg1 = self.F1:GetLimitInfo()
    if bLimit1 then UI.ShowTip(sMsg1) return end

    local bLimit2 , sMsg2 = self.F2:GetLimitInfo()
    if bLimit2 then UI.ShowTip(sMsg2) return end
    if Formation.bReqUpdate then
        return
    end
    Formation.bReqUpdate = true

    if Launch.GetType() == LaunchType.OPENWORLD then
        self:EnterLevel()
        Formation.bReqUpdate = false
        return
    end
    Formation.Req_UpdateLineup(self.CurLineupIndex, function()
        self:EnterLevel()
        Formation.bReqUpdate = false
    end)
end

---进入关卡
function tbClass:EnterLevel()
    local canFight, msg = Formation.CanFight()
    print('EnterLevel', canFight, msg)
    if not canFight then
        UI.ShowTip(msg)
        return
    end
    print("Launch.Start")
    Launch.Start()
end

---应用队伍数据
function tbClass:ApplyChangeLineup(InLineupIndex)
    Formation.Req_UpdateLineup(self.CurLineupIndex, function() self:ChangeLineup(InLineupIndex) end)
end

---队伍选择改变
function tbClass:ChangeLineup(InLineupIndex)
    self.CurLineupIndex = InLineupIndex
    Formation.SetCurLineupIndex(InLineupIndex)
    local NewBtn = self.Bts[InLineupIndex]
    if self.SelectBtn then self.SelectBtn:SetState(BtnState.Normal) end
    self.SelectBtn = NewBtn
    if self.SelectBtn then self.SelectBtn:SetState(BtnState.Select) end
    self.F0:Init()
    self.F1:Init()
    self.F2:Init()
    self:UpdatePower()
    self:UpdateFormationTips()
    self:UpdateStarInfo(self.LevelCfg)
end

---更新UI位置  与角色保持一致
function tbClass:Tick(MyGeometry, InDeltaTime)
    if self.bOnline then
        self.Online:Tick(InDeltaTime)
        return
    end

    self.TickTime = self.TickTime or 10
    if self.TickTime > 0 then
        self.TickTime = self.TickTime - 0.1
    else
        return
    end

    self.F0:UpdatePos()
    self.F1:UpdatePos()
    self.F2:UpdatePos()
end

---设置编队是否能编辑
---@param bEdit boolean 是否能编辑
function tbClass:SetCanEditFormation(bEdit)
    self.F0:SetCanEditFormation(bEdit)
    self.F1:SetCanEditFormation(bEdit)
    self.F2:SetCanEditFormation(bEdit)
end

-----------------------联机编队显示
---主要显示
function tbClass:ShowOnline()
    if self.Online == nil then
        self.Online = WidgetUtils.AddChildToPanel(self.RootContent, '/Game/UI/UMG/Formation/Widgets/uw_formation_online.uw_formation_online_C', 0)
    end

    if self.Online then
        WidgetUtils.Collapsed(self.LeftBtns)
        WidgetUtils.Collapsed(self.FightBtn)
    
        WidgetUtils.Collapsed(self.Player2)
        WidgetUtils.Collapsed(self.Player3)
    
        WidgetUtils.Collapsed(self.BreakCheck)
    
        WidgetUtils.SelfHitTestInvisible(self.Online)
    
        Online.CheckFormationInUI(Online.TeamId)
    
        self.Online:OnOpen(self.tbFormationType[5][1])
    
        self.Title:SetCustomEvent(function(bBreak) Online.DoExitRoom( function() self:DoBackEvent() end, self.Online:GetMatchCheckState(), bBreak) end,
         function() Online.DoExitRoom(nil,  self.Online:GetMatchCheckState()) end)
        PreviewScene.Enter(PreviewType.formation, function()
            --Preview.SetLightDir(UE4.FRotator(0, -42, 0))
            self:UpdateFormationTips()
        end)
    end
end

--再次压入返回按钮事件
function tbClass:DoBackEvent()
    self.Title:SetCustomEvent(function(bBreak) Online.DoExitRoom( function() self:DoBackEvent() end, self.Online:GetMatchCheckState(), bBreak) end)
end

--更新联机房间 信息
function tbClass:UpdateOnline(nState, nParam1, nParam2, nParam3, nParam4)
    if IsValid(self.Online) and WidgetUtils.IsVisible(self.Online) then
        self.Online:UpdateRoomInfo(nState, nParam1, nParam2, nParam3, nParam4)
    end
end

--被踢 返回界面
function tbClass:DoKickOut(bFlag)
    local popEvent = self.Title:Pop()
    if popEvent then popEvent(bFlag) end
end

function tbClass:UpdatePower()
    WidgetUtils.Collapsed(self.RightUp)
    -- if not self.LevelCfg or not self.LevelCfg.GetRecommendPower then
    --     WidgetUtils.Collapsed(self.RightUp)
    --     return
    -- end
    -- WidgetUtils.SelfHitTestInvisible(self.RightUp)
    -- local recommendPorwer = self.LevelCfg:GetRecommendPower()
    -- self.TxtRecommendPower:SetText(recommendPorwer)
    -- local Lineup = Formation.GetLineup(Formation.GetCurLineupIndex())
    -- local teamPower = 0
    -- if Lineup then
    --     local cards = Lineup:GetCards()
    --     for i = 1, cards:Length() do
    --         teamPower = teamPower + Item.Zhanli_CardTotal(cards:Get(i))
    --     end
    -- end
    -- self.TxtPower:SetText(math.ceil(teamPower))
    -- if not Launch.CheckLevelMutipleOpen() and recommendPorwer > teamPower * 1.1 then
    --     WidgetUtils.SelfHitTestInvisible(self.Combat)
    -- else
    --     WidgetUtils.Collapsed(self.Combat)
    -- end
end

function tbClass:UpdateFormationTips()
    WidgetUtils.Collapsed(self.Combat)
    -- if Launch.GetType() == LaunchType.DLC1_ROGUE or self.bOnline then
    --     WidgetUtils.Collapsed(self.Combat)
    --     return
    -- end
    -- local msg = Formation.CheckStarCondition(self.LevelCfg) -- or self:CheckRecommendLevel()
    -- if not msg then
    --     WidgetUtils.Collapsed(self.Combat)
    -- else
    --     WidgetUtils.SelfHitTestInvisible(self.Combat)
    --     self.TxtCombatDeficiency:SetText(msg)
    -- end
end

function tbClass:CheckRecommendLevel()
    if not self.LevelCfg or not self.LevelCfg.GetRecommendPowerId or self.LevelCfg.nTeamRuleID then return end
    local powerId = self.LevelCfg:GetRecommendPowerId()
    local tbRecommendFormation = ItemPower.tbRecommandPower[powerId]
    if not tbRecommendFormation then return end
    local Lineup = Formation.GetLineup(Formation.GetCurLineupIndex())

    local cardLevelAvg, weaponLevelAvg, supportLevelAvg = 0, 0, 0
    for _, member in pairs(Lineup.tbMember) do
        if not member:IsNone() then
            local pCard = member:GetCard()
            cardLevelAvg = cardLevelAvg + pCard:EnhanceLevel()

            local pWeapon = pCard:GetSlotWeapon()
            if pWeapon then
                weaponLevelAvg = weaponLevelAvg + pWeapon:EnhanceLevel()
            end

            local supporterCards = pCard:GetSupporterCards()
            for i = 1, supporterCards:Length() do
                local pSupporterCard = supporterCards:Get(i)
                supportLevelAvg = supportLevelAvg + pSupporterCard:EnhanceLevel()
            end
        end
    end
    local supportNum = 0
    for _, num in ipairs(tbRecommendFormation.tbSupportNum) do supportNum = supportNum + num end

    cardLevelAvg = cardLevelAvg / tbRecommendFormation.nCardNum
    weaponLevelAvg = weaponLevelAvg / tbRecommendFormation.nCardNum
    supportLevelAvg = supportNum == 0 and 0 or (supportLevelAvg / supportNum)
    if cardLevelAvg + weaponLevelAvg + supportLevelAvg + 5 < tbRecommendFormation.nCardLevel + tbRecommendFormation.nWeaponLevel + tbRecommendFormation.nSupportLevel then
        return Text('star.starfalse5')
    end
end

return tbClass
