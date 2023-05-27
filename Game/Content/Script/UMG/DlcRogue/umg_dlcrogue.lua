-- ========================================================
-- @File    : umg_dlcrogue.lua
-- @Brief   : 小肉鸽活动界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListMap)
end

function tbClass:OnInit()
    self:DoClearListItems(self.ListMap)
    BtnAddEvent(self.BtnRole, function ()
        UI.Open("Role", 1, nil, RogueLogic.GetAllCharacter(), true)
    end)

    BtnAddEvent(self.BtnClose, function ()
        self.BuffBar:CloseTip()
        WidgetUtils.Collapsed(self.BtnClose)
    end)

    BtnAddEvent(self.BtnRoleUp, function ()
        if self.CloseDetailCountDown and self.CloseDetailCountDown > 0 then
            ---增益buff显示倒计时
            self.CloseDetailCountDown = 5
        else
            if self:IsAnimationPlaying(self.Back) then
                self:UnbindAllFromAnimationFinished(self.Back)
                self:StopAnimation(self.Back)
            end
            WidgetUtils.HitTestInvisible(self.PanelBuffDetail)
            self:PlayAnimation(self.Appear)
            self.CloseDetailCountDown = 5
        end
    end)

    self.BtnTpis:InitHelpImages(28)

    BtnAddEvent(self.BtnTask, function ()
        UI.Open("DlcRogueAward")
    end)

    BtnAddEvent(self.BtnReset, function ()
        UI.Open("MessageBox", Text("rogue.TxtResetWarn"), RogueLogic.ResetRogue)
    end)

    BtnAddEvent(self.BtnBuffBag, function ()
        UI.Open("DlcRogueBuffBag")
    end)

    self.Factory = Model.Use(self)
end

function tbClass:CloseDetail()
    self:UnbindAllFromAnimationFinished(self.Back)
    self:BindToAnimationFinished(self.Back, {self, function()
        self:UnbindAllFromAnimationFinished(self.Back)
        WidgetUtils.Collapsed(self.PanelBuffDetail)
    end})
    self:PlayAnimation(self.Back)
end

function tbClass:OnOpen()
    RogueLogic.UpdateData()
    Launch.SetType(LaunchType.DLC1_ROGUE)

    me:CallGS("RogueLogic_EnterRogue")

    self.Money:Init({9})
    WidgetUtils.Collapsed(self.BtnClose)
    WidgetUtils.Collapsed(self.LevelInfo)

    self.CloseDetailCountDown = 5
    WidgetUtils.HitTestInvisible(self.PanelBuffDetail)

    ---剩余时间
    local _, cfg = RogueLogic.GetActivitieID()
    if cfg then
        local time = GetTime()
        if cfg.nEndTime > time then
            local nDay = math.max(TimeDiff(cfg.nEndTime, time), 1)
            self.TxtTime:SetText(nDay)
        end
    end

    if RogueLogic.CheckRedDot() then
        WidgetUtils.HitTestInvisible(self.New1)
    else
        WidgetUtils.Collapsed(self.New1)
    end

    self:UpdatePanel()
    self:PlayAnimation(self.AllEnter)
    self:UpdateDailyBuffAndRole()
end

function tbClass:UpdateDailyBuffAndRole()
    WidgetUtils.Collapsed(self.PanelUpRole)
    RogueLogic.FetchDailyBuff(function()
        WidgetUtils.SelfHitTestInvisible(self.PanelUpRole)
        if RogueLogic.DayRole then
            self:UpdateDayRole(RogueLogic.DayRole)
        end
        if RogueLogic.DayBuff then
            self:UpdateDayBuff(RogueLogic.DayBuff)
        end
    end)
end

---数据改变时更新
function tbClass:UpdatePanel()
    local BaseInfo = RogueLogic.GetBaseInfo()
    ---刷新行动次数
    self.TxtNum1:SetText(BaseInfo.nAvaActTimes)
    self.TxtNum2:SetText(BaseInfo.nUpperActTimes)
    ---刷新地图线路
    self:UpdateMapPanel()

    ---刷新buff列表
    self.BuffBar:UpdatePanel(RogueLogic.GetBuffAndGoodsBuff(), nil, true, function(bShow)
        if bShow then
            WidgetUtils.Visible(self.BtnClose)
        else
            WidgetUtils.Collapsed(self.BtnClose)
        end
    end)

    if RogueLogic.CheckRedDot() then
        WidgetUtils.HitTestInvisible(self.New1)
    else
        WidgetUtils.Collapsed(self.New1)
    end
end

---刷新地图线路
function tbClass:UpdateMapPanel()
    local BaseInfo = RogueLogic.GetBaseInfo()
    local nMapID = BaseInfo.nMapID
    local nowPage = math.floor(BaseInfo.nCurNode / 10000)
    local tbNode = RogueLogic.tbMapCfg[nMapID]
    if not tbNode then return end
    local tbdata = {}
    local Rindex = 0
    local ProgressIndex = 0
    local lastID = nil
    for _, info in pairs(tbNode) do
        if not info.tbNext or #info.tbNext==0 then
            lastID = info.nID
        end
        if info.nPage == nowPage then
            local index = info.nX
            tbdata[index] = tbdata[index] or {}
            tbdata[index][info.nY] = info
            if index > Rindex then
                Rindex = index
            end
            if info.nID == BaseInfo.nCurNode then
                ProgressIndex = index
            end
        end
    end

    --如果节点全部完成 有任务没完成 显示重置红点
    local bShowRed = false
    if lastID and RogueLogic.CheckNodeComplete(nMapID, lastID) then
        local _, cfg = RogueLogic.GetActivitieID()
        if cfg then
            for _, ID in ipairs(cfg.TaskList) do
                if Achievement.CheckAchievementReward(ID, true) == Achievement.STATUS_NOT then
                    bShowRed = true
                    break
                end
            end
        end
    end
    if bShowRed then
        WidgetUtils.HitTestInvisible(self.New2)
    else
        WidgetUtils.Collapsed(self.New2)
    end

    if nowPage ~= RogueLogic.MaxPage then
        local NextNode = tbNode[(nowPage+1)*10000 + 1]
        if NextNode then
            Rindex = Rindex + 1
            tbdata[Rindex] = {}
            tbdata[Rindex][1] = NextNode
        end

        WidgetUtils.Collapsed(self.MapOver)
        WidgetUtils.SelfHitTestInvisible(self.OverNode)
        self.OverNode:Show(tbdata, Rindex)
    else
        WidgetUtils.Collapsed(self.OverNode)
        WidgetUtils.SelfHitTestInvisible(self.MapOver)
        self.MapOver:Show(tbdata, Rindex)
    end

    self:DoClearListItems(self.ListMap)
    for nX in pairs(tbdata) do
        if nX == 0 then
            self.StartNode:UpdateState(tbdata[nX])
        elseif nX == 1 then
            self.Map1:Show(tbdata, nX)
        elseif nX ~= Rindex then
            local data = {tbdata, nX}
            local pObj = self.Factory:Create(data)
            self.ListMap:AddItem(pObj)
        end
    end

    self.DetailUpdate = 2
    self.FunUpdateScrollOffset = function ()
        if self.MapScrollBox then
            local OffsetOfEnd = self.MapScrollBox:GetScrollOffsetOfEnd()
            self.MapScrollBox:SetScrollOffset(Lerp(0, OffsetOfEnd, (ProgressIndex+0.5)/(Rindex+1)))
        end
    end
end

---刷新每日增益角色
function tbClass:UpdateDayRole(tbRole)
    local tbCharacter = {}
    for _, v in pairs(tbRole) do
        local Item = me:GetDefaultItem(table.unpack(v.tbGDPL))
        table.insert(tbCharacter, Item)
    end
    for i = 1, 3 do
        local widget = self["RoleHead"..i]
        if widget then
            if tbCharacter[i] then
                WidgetUtils.SelfHitTestInvisible(widget)
                widget:Show(tbCharacter[i], tbCharacter)
            else
                WidgetUtils.Collapsed(widget)
            end
        end
    end
end

---刷新每日刷新的增益buff
function tbClass:UpdateDayBuff(tbbuff)
    for i = 1, 3 do
        local TxtBuff = self["TxtDayUpBuff"..i]
        if TxtBuff then
            if tbbuff[i] then
                WidgetUtils.HitTestInvisible(TxtBuff)
                if tbbuff[i].nType == 1 then
                    TxtBuff:SetText(Text(tbbuff[i].sDescribe))
                else
                    TxtBuff:SetText(Text(tbbuff[i].sDescribe))
                    --TxtBuff:SetText(Text(tbbuff[i].sDescribe, tbbuff[i].nPercent))
                end
            else
                WidgetUtils.Collapsed(TxtBuff)
            end
        end
    end
end

---位置更新
function tbClass:Tick(MyGeometry, InDeltaTime)
    if self.MapScrollBox then
        self.Target = self.MapScrollBox:GetScrollOffset()
        self.Current = UE4.UKismetMathLibrary.FInterpTo(self.Current, self.Target, InDeltaTime, 10)
        self.BG:SetRenderTranslation(UE4.FVector2D(-self.Current * 0.01, 0))
    end
    if self.CloseDetailCountDown then
        self.CloseDetailCountDown = self.CloseDetailCountDown - InDeltaTime
        if self.CloseDetailCountDown <= 0 then
            self.CloseDetailCountDown = nil
            self:CloseDetail()
        end
    end

    if self.DetailUpdate then
        self.DetailUpdate = self.DetailUpdate -1
        if self.DetailUpdate <= 0 then
            if self.FunUpdateScrollOffset then
                self.FunUpdateScrollOffset()
                self.FunUpdateScrollOffset = nil
            end
            self.DetailUpdate = nil
        end
    end
end

function tbClass:ShowLevelInfo()
    local cfg = RogueLevel.Get(RogueLevel.GetLevelID())
    if cfg then
        if not self.LevelInfo then
            self.LevelInfo = WidgetUtils.AddChildToPanel(self.Panel, "/Game/UI/UMG/Common/Widgets/uw_level_info.uw_level_info_C", 30)
        end
        if self.LevelInfo then
            WidgetUtils.SelfHitTestInvisible(self.LevelInfo)
            self.LevelInfo:Show(cfg)
        end
    end
end

function tbClass:OnClose()
    EventSystem.RemoveAllByTargetName(RogueLogic, RogueLogic.MoveToNext)
end

return tbClass
