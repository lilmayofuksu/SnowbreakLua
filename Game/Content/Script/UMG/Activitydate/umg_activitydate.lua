-- ========================================================
-- @File    : umg_activitydate.lua
-- @Brief   : 日签活动界面
-- ========================================================


local tbActivityDay = Class("UMG.BaseWidget")
tbActivityDay.FinishSignDay="SIGN_FINISH_DAY"

function tbActivityDay:Construct()
    self.pDayItem = self.pDayItem or Model.Use(self)
    self.ListDate:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.ListEmpty:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)

    BtnAddEvent(self.BtnClose, function()
        self:OnClose()
        if UI.IsOpen("SignDay") then
            UI.CloseByName("SignDay")
            Activity.OnOpen()
        elseif self.bPopMain then
            UI.Close(self)
            Activity.OnOpen()
        end
    end)
    BtnAddEvent(self.BtnClose_1, function()
        self:OnClose()
        if UI.IsOpen("SignDay") then
            UI.CloseByName("SignDay")
            Activity.OnOpen()
        elseif self.bPopMain then
            UI.Close(self)
            Activity.OnOpen()
        end
    end)
    BtnAddEvent(self.BtnMonth, function()
        IBLogic.GotoMall(IBLogic.Tab_IBMonth)
    end)
end

function tbActivityDay:OnOpen(tbParam)
    self.pDayItem = self.pDayItem or Model.Use(self)

    if tbParam and tbParam.nActivityId then
        self.nActiveId = tbParam.nActivityId
    end

    if tbParam and tbParam.fRefreshFun then --是否主界面弹出显示
        self.bPopMain = false
    else
        self.bPopMain = true
    end

    self:AddDayItem()
    self:UpdatePanelItem()
    self:DateTitle()

    --- 没签到自动签到
    if Sign.GetSginDayStatus(self.nActiveId) < 2 then
        self:SendReqSignDay()
    end

    if self.TxtDes then
        self.TxtDes:SetText(Text("activity.refreshtime"))
    end
    self:RetainTime()
end

--刷新月卡奖励
function tbActivityDay:UpdatePanelItem()
    ---暂时全部隐藏
    if true then
        WidgetUtils.Collapsed(self.BtnMonth)
        WidgetUtils.Collapsed(self.PanelItem)
        WidgetUtils.Collapsed(self.Activated)
        return
    end

    local cfg = Cash.GetMoneyCfgInfo(Cash.MoneyType_Gold)
    if not cfg then
        WidgetUtils.Collapsed(self.BtnMonth)
        WidgetUtils.Collapsed(self.PanelItem)
        return
    end

    SetTexture(self.ImgItem, cfg.nIcon)
    self.TxtNum:SetText(IBLogic.GetMonthSignAward())
    self.TxtItemName:SetText(Text("activity.vipReward"))

    if IBLogic.GetMonthCardTime() > GetTime() then  --拥有月卡
        WidgetUtils.Collapsed(self.NotActive)
        WidgetUtils.Collapsed(self.BtnMonth)
        WidgetUtils.HitTestInvisible(self.Activated)
        if Sign.GetSginDayStatus(self.nActiveId) < 2 then
            WidgetUtils.Collapsed(self.PanelReceived)
        else
            WidgetUtils.HitTestInvisible(self.PanelReceived)
        end
    else
        WidgetUtils.Collapsed(self.PanelReceived)
        WidgetUtils.Collapsed(self.Activated)
        WidgetUtils.Visible(self.BtnMonth)
        WidgetUtils.HitTestInvisible(self.NotActive)
    end
end

function tbActivityDay:AddDayItem()
    self:DoClearListItems(self.ListDate)
    self:DoClearListItems(self.ListEmpty)
    local function Id()
        if type(self.nActiveId)=='table' then
            return self.nActiveId
        end
        if type(self.nActiveId)=='number' then
            return self.nActiveId
        end
    end

    local tbInfo = Sign.GetSignConfig(Id())
    if not tbInfo then return end

    local nSignDay = Sign.GetSginTag(Id())
    for index=1,Sign.GetMonthDayNum() do
        local tbRewardInfo = tbInfo[index]
        local Rewards = tbRewardInfo.tbReward
        local tbParam = {
            G = Rewards[1][1],
            D = Rewards[1][2],
            P = Rewards[1][3],
            L = Rewards[1][4],
            N = Rewards[1][5],
            pItem = nil,
            Name = "",
            bTag = (index <= nSignDay) and 1 or 0,
            nData = index
        }

        local pDay =self.pDayItem:Create(tbParam)
        self.ListDate:AddItem(pDay)
    end

    --铺满35个格子
    for index=1,35 do
        local tbParam = {
            nIndex = index,
            bHide = (index <= Sign.GetMonthDayNum()) and true or false,
        }
        local pDay =self.pDayItem:Create(tbParam)
        self.ListEmpty:AddItem(pDay)
    end
end

function tbActivityDay:DateTitle()
    local time = GetTime()
    if tonumber(os.date("%d", time)) == 1 and tonumber(os.date("%H", time)) < 4 then   --如果是1号且没超过凌晨四点 算上一个月的签到
        time = time - 14400 --减去四个小时
    end
    local date = tonumber(os.date("%m", time))
    local sDate = Text("ui.Month_"..date)
    self.TxtMonth:SetText(sDate)
end

--- 签到标记
function tbActivityDay:SetSignTxt(InDate)
    if self.TxtSign then
        self.TxtSign:SetText(Text("activity.sign"))
        if Activity.tbSignDayTag[InDate]>=1 then
            self.TxtSign:SetText(Text("activity.signed"))
        end
    end
end


--- 发送日签请求
function tbActivityDay:SendReqSignDay()
    Sign.Req_SignDay(
        {
            Id = self.nActiveId,
        },
        function(InData)
            if not self.pDayItem then return end 
            print('sign finish')
            self:AddDayItem()
            self:UpdatePanelItem()
            --UI.ShowTip("tip.sign_day_ok")
            --self:SetSignTxt(tonumber(os.date('%d')))
        end
    )
end

--- 日签奖励
---@param InItem UE4.UItem 道具
function tbActivityDay:ShowRewardItem(InItem,InNum)
    if InItem then
        self.TxtItemName:SetText(Text(InItem.I18N))
    end
    if InNum and InNum>=1 then
        self.TxtNum:SetText(InNum)
    end
end

--- 关闭当前模板
function tbActivityDay:OnClose()
    WidgetUtils.Hidden(self)
end

--- 日签倒计时刷新
function tbActivityDay:RetainTime()
    if not self.TxtTime then
        return
    end
    local time = GetTime()
    if not self.RefreshTime then
        if tonumber(os.date('%H', time)) < 4 then
            self.RefreshTime = ParseBriefTime("040001") --今天4点刷新
        else
            self.RefreshTime = ParseBriefTime("040001") + 86400 --明天4点刷新
        end
    end
    local seconds = self.RefreshTime - time
    if seconds > 0 then
        local hour = math.floor(seconds / 3600)
        local min = math.floor((seconds % 3600) / 60)
        local sec = math.floor(seconds % 3600 % 60)
        self.TxtTime:SetText(string.format("%02d:%02d:%02d", hour, min, sec))
    else
        self.RefreshTime = ParseBriefTime("040001") + 86400 --明天4点刷新
    end
end

function tbActivityDay:Tick(MyGeometry, InDeltaTime)
    if not self.detime then self.detime = 0 end
    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end
    self.detime = 0

    self:RetainTime()
end

return tbActivityDay
