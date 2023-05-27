-- ========================================================
-- @File    : uw_dungeonsonline_activity.lua
-- @Brief   : 联机界面 关卡界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")
function tbClass:Construct()
    self:DoClearListItems(self.DropList)
    self.DropListFactory = Model.Use(self)

    BtnAddEvent(self.AWARD_btn, function()
        self:ClickStarNode()
    end)

    BtnAddEvent(self.FightBtn, function()
        self:OnClickOne()
    end)

    BtnAddEvent(self.BtnTpis.BtnInfo, function()
        if self.tbConfig and self.tbConfig.nHelpImgId > 0 then
            UI.Open("HelpImages", self.tbConfig.nHelpImgId)
        end
    end)
end

function tbClass:OnClose()
    self.tbConfig = nil
end

--打开界面
function tbClass:OnOpen(tbConfig)
    WidgetUtils.Collapsed(self.Money)
    WidgetUtils.Collapsed(self.MonsterInfo)

    self.tbConfig = tbConfig or self.tbConfig
    if not self.tbConfig  and Online.GetPopId() > 0 then
        self.tbConfig = Online.GetConfig(Online.GetPopId())
        --设置当前关卡类型
        Launch.SetType(LaunchType.ONLINE)
        --设置当前编队编号
        Formation.SetCurLineupIndex(Online.TeamId)
        --检查编队
        Online.CheckFormation(Online.TeamId)
    end

    if not self.tbConfig then 
        self:ShowEmpty()
        return
    end

    if Launch.GetType() ~= LaunchType.ONLINE or Online.GetOnlineId() ~= self.tbConfig.nId then
        Launch.SetType(LaunchType.ONLINE)
        Online.SetOnlineId(self.tbConfig.nId)
    end

    self.tbConfig = tbConfig or self.tbConfig
    self:ShowMain(self.tbConfig)

    Online.CheckPopInfo(self.tbConfig)
end

--显示空
function tbClass:ShowEmpty()
    WidgetUtils.Collapsed(self.BtnNode1)
    WidgetUtils.Collapsed(self.BtnNode2)
    WidgetUtils.Collapsed(self.BtnNode3)
    WidgetUtils.Collapsed(self.BtnNode4)
    WidgetUtils.Collapsed(self.BtnNode5)
    WidgetUtils.Collapsed(self.StarNode)

    WidgetUtils.Collapsed(self.Time)
    WidgetUtils.Collapsed(self.PanelRight)
    WidgetUtils.Collapsed(self.BtnTpis)
end

--显示主要界面
function tbClass:ShowMain(tbConfig)
    WidgetUtils.SelfHitTestInvisible(self.TxtTime)
    self.Time:ShowWeeklyCountDown("TxtOnlineRefresh")

    WidgetUtils.SelfHitTestInvisible(self.StarNode)
    WidgetUtils.SelfHitTestInvisible(self.PanelRight)
    WidgetUtils.Visible(self.BtnTpis)


    --玩法详情
    if tbConfig.sIntro and self.TxtFightDetail then
        self.TxtFightDetail:SetContent(Text(tbConfig.sIntro))
    end

    self:ShowMapName()
    self:ShowStarNode()
    self:ShowLevelInfo()
end

--显示左边轮换的地图类型名字
function tbClass:ShowMapName()
    local tbMaps = Online.GetRotationLevels() or {}
    for i=1,#tbMaps do
        local tbInfo = tbMaps and tbMaps[i]
        local tbName = "BtnNode"..i
        if tbInfo then
            WidgetUtils.SelfHitTestInvisible(self[tbName])
            local iconName = "ImgBtn"..i
            local txtName = "TxtOnlineLevel"..i
            if tbInfo[1] then
                self[txtName]:SetText(tbInfo[1])
            else
                self[txtName]:SetText("")
            end

            self[tbName]:SetDesaturate(tbInfo[3] and tbInfo[3] or false);

            if tbInfo[2] and self[iconName] then
                SetTexture(self[iconName], tbInfo[2])
            end
        else
            WidgetUtils.Collapsed(self[tbName])
        end
    end
end

--显示StartNode
function tbClass:ShowStarNode()
    local nCurPoint = Online.GetWeeklyPoint()
    local nMaxPoint = Online.GetMaxPoint()

    if nCurPoint > nMaxPoint then
        nCurPoint = nMaxPoint 
    end

    self.TxtStarNum:SetText(nCurPoint)
    self.TxtStarNumTotal:SetText(nMaxPoint)

    if nMaxPoint == 0 then
        nMaxPoint = 1
    end

    local nFloat = nCurPoint / nMaxPoint
    local Mat = self.ImgBar:GetDynamicMaterial()
    if Mat then
        Mat:SetScalarParameterValue("Percent", nFloat)
    end

    local fAngle = nFloat * 360
    if nFloat > 0.5 then
        fAngle = fAngle - 360
    end
    self.ImgNode2:SetRenderTransformAngle(fAngle-0.1);

    WidgetUtils.Collapsed(self.ExpBar)
    self:ShowAwardFlag()
end

-----外部调用 服务器回调等
--获取奖励刷新
function tbClass:OnReceiveUpdate(tbParam)
    if tbParam and tbParam.tbAwardList and #tbParam.tbAwardList > 0 then
        local tbAllList = {}
        local tbMapList = {}
        for i,v in ipairs(tbParam.tbAwardList) do
            for j,info in ipairs(v) do
                local strId = string.format("%d-%d-%d-%d", info[1], info[2], info[3], info[4])
                if tbMapList[strId] then
                    local getInfo = tbMapList[strId]
                    getInfo[5] = getInfo[5] + info[5] or 0
                else
                    info[5] = info[5] or 0
                    tbMapList[strId] = info
                end
            end
        end

        for _,v in pairs(tbMapList) do
            table.insert(tbAllList, v)
        end

        if #tbAllList > 0 then
            Item.Gain(tbAllList)
        end

        self:ShowAwardFlag()
    end

    local tbRewardUI = UI.GetUI("DungeonsOnlineReward")
    if tbRewardUI and tbRewardUI:IsOpen() then
        local tbReward = Online.GetAwardConfig()
        tbRewardUI:ShowMain(tbReward)
    end
end

--刷新奖励红点
function tbClass:ShowAwardFlag()
    if not Online.CheckAllAward() then
        WidgetUtils.SelfHitTestInvisible(self.New)
    else
        WidgetUtils.Collapsed(self.New)
    end
end

--点击积分奖励
function tbClass:ClickStarNode()
    if WidgetUtils.IsVisible(self.PanelRight) then
        WidgetUtils.Collapsed(self.PanelRight)
    end

    if not UI.IsOpen("DungeonsOnlineReward") then
        UI.Open("DungeonsOnlineReward", function() WidgetUtils.SelfHitTestInvisible(self.PanelRight) end)
    else
        UI.CloseByName("DungeonsOnlineReward")
        WidgetUtils.SelfHitTestInvisible(self.PanelRight)
    end
end

--进入编队界面
function tbClass:OnClickOne()
    local bUnLock, sLockDes = Condition.Check(self.tbConfig.tbCondition)
    if bUnLock == false then
        UI.ShowTip(sLockDes[1])
        return
    end

    if self.needVigor and Cash.GetMoneyCount(Cash.MoneyType_Vigour) < self.needVigor then
        UI.Open("PurchaseEnergy", "Energy")
        return
    end

    Online.CraeteRoom(Online.GetOnlineId(), Online.TeamId)
    WidgetUtils.Collapsed(self)
end

--显示关卡信息
function tbClass:ShowLevelInfo()
    self.Info:Show(self.tbConfig, function()  end)
end

return tbClass
