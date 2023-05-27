-- ========================================================
-- @File    : umg_dungeons_online.lua
-- @Brief   : 联机选关界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.ShowList = Online.GetAllOpenList()

    self.AWARD_btn.OnClicked:Clear()
    self.AWARD_btn.OnClicked:Add(self, function()
        self:ClickStarNode()
    end)
end

--打开界面
function tbClass:OnOpen()
    PreviewScene.PlayDungeonsSeq(4, UI.bPoping)

    --设置当前关卡类型
    Launch.SetType(LaunchType.ONLINE)
    --设置当前编队编号
    Formation.SetCurLineupIndex(Online.TeamId)
    --检查编队
    Online.CheckFormation(Online.TeamId)

    self:ShowMain()
    self:ShowStarNode()
    self.Time:ShowWeeklyCountDown("TxtOnlineRefresh")
    self:PlayAnimation(self.AllEnter)
end

--显示主要界面
function tbClass:ShowMain()
    --主界面5个模式页面
    for i=1,5 do
        local pItem = self['Item'..i]
        local tbConfig = self.ShowList[i]
        pItem:OnOpen(tbConfig)
    end
    WidgetUtils.Collapsed(self.Info)
end

--显示积分奖励
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

--点击积分奖励
function tbClass:ClickStarNode()
    if WidgetUtils.IsVisible(self.Info) then
        WidgetUtils.Collapsed(self.Info)
    end

    if not UI.IsOpen("DungeonsOnlineReward") then
        UI.CloseByName("DungeonsMode")
        UI.Open("DungeonsOnlineReward", function() self:ShowMode() end)
    else
        UI.CloseByName("DungeonsOnlineReward")
        self:ShowMode()
    end
end

--显示关卡信息 暂时废弃
function tbClass:ShowLevelInfo(tbConfig)
    if UI.IsOpen("DungeonsOnlineReward") then
        UI.CloseByName("DungeonsOnlineReward")
    end
    
    -- local tbLevelInfo = Online.GetConfig(tbConfig.nId)
    -- if not WidgetUtils.IsVisible(self.Info) and tbLevelInfo then
    --     UI.CloseByName("DungeonsMode")
    --     --关卡信息会清理联机当前关卡数据
    --     self.Info:Show(tbLevelInfo, function() self:ShowMode() end )
    --     WidgetUtils.SelfHitTestInvisible(self.Info)
    --     --设置当前联机关卡信息
    --     Online.SetOnlineId(tbConfig.nId)
    -- else
    --     WidgetUtils.Collapsed(self.Info)
    --     self:ShowMode()
    -- end
end

--主动显示下面模式选择
function tbClass:ShowMode()
    EventSystem.Trigger(Event.UIOpen, self)
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

return tbClass
