-- ========================================================
-- @File    : umg_common_clean_start.lua
-- @Brief  : 扫荡界面
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    BtnAddEvent(self.BG.BtnClose, function()  UI.Close(self) end)

    BtnAddEvent(self.BtnReduce, function()  self:ChangeNum(0) end)
    BtnAddEvent(self.BtnAdd, function()  self:ChangeNum(1) end)
    BtnAddEvent(self.BtnMax, function()  self:ChangeNum(2) end)

    BtnAddEvent(self.BtnOK, function()  self:DoMopup() end)

    self.DropListFactory = Model.Use(self)
end

---打开时的回调
function tbClass:OnOpen(tbLevelInfo)
    if not tbLevelInfo then
        UI.Close(self)
        return
    end

    local tbMopup = Player.GetMoppingUpConfig(Launch.GetType())
    if not tbMopup then 
        UI.Close(self)
        return
    end

    self.tbLevelInfo = tbLevelInfo
    self.nSelectIdx = 1
    self.nMaxMopup = tbMopup.nMultiple or LaunchType.MaxMopup

    --显示限制次数
    self:ShowCount()
    --显示代币
    self:ShowConsume()
    --显示奖励
    self:ShowDrop()
    self:ChangeNum()

    EventSystem.Remove(self.nChangeEvent)
    self.nChangeEvent = EventSystem.On(Event.VigorChanged, function() self:ShowConsume() end)
end

function tbClass:OnClose()
    self.tbLevelInfo = nil
    EventSystem.Remove(self.nChangeEvent)
    self.nChangeEvent = nil
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nChangeEvent)
    self.nChangeEvent = nil
end

--次数
function tbClass:ShowCount()
    if not self.tbLevelInfo then 
        WidgetUtils.Collapsed(self.Challenge)
        return
    end

    if self.tbLevelInfo.nNum and self.tbLevelInfo.nNum > 0 then
        WidgetUtils.SelfHitTestInvisible(self.Challenge)
        local passNum = Role.GetLevelPassNum(self.tbLevelInfo.nID)
        self.TxtTNum:SetText(string.format("%d/%d", self.tbLevelInfo.nNum - passNum, self.tbLevelInfo.nNum))
    else
        WidgetUtils.Collapsed(self.Challenge)
    end
end

--消耗
function tbClass:ShowConsume()
    WidgetUtils.Collapsed(self.Expend1)
    WidgetUtils.Collapsed(self.Expend2)

    if not self.tbLevelInfo then
        return
    end

    local vigor
    if self.tbLevelInfo.tbConsumeVigor then
        vigor = (self.tbLevelInfo.tbConsumeVigor[1] or 0) + (self.tbLevelInfo.tbConsumeVigor[2] or 0)
    elseif self.tbLevelInfo.nConsumeVigor then 
        vigor = self.tbLevelInfo.nConsumeVigor
    end
    if not vigor then return end

    if self.nSelectIdx > 1 and self.nSelectIdx <= self.nMaxMopup then
        vigor = vigor * self.nSelectIdx
    end
    self.needVigor = vigor

    WidgetUtils.SelfHitTestInvisible(self.Expend1)
    self.TxtCurrencyNum1:SetText(vigor)
    if Cash.GetMoneyCount(Cash.MoneyType_Vigour) >= vigor then
        self.TxtCurrencyNum1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#000000'))
    else
        self.TxtCurrencyNum1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#ee4735'))
    end

    if Launch.GetType() == LaunchType.ROLE then --角色碎片本
        WidgetUtils.SelfHitTestInvisible(self.Expend2)
        self.TxtCurrencyNum2:SetText(self.tbLevelInfo.nConsume * self.nSelectIdx)
        if Cash.GetMoneyCount(Role.MoneyID) >= self.tbLevelInfo.nConsume * self.nSelectIdx then
            self.TxtCurrencyNum2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#000000'))
        else
            self.TxtCurrencyNum2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#ee4735'))
        end
    end
end

--显示掉落奖励
function tbClass:ShowDrop()
    if not self.tbLevelInfo then
        WidgetUtils.Collapsed(self.List)
        return
    end

    WidgetUtils.Visible(self.List)
    self.List:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.List)

    self.tbRewards = {}
    local fn = function()
        if not self.tbLevelInfo.tbShowAward then return end
        for _, tbInfo in ipairs(self.tbLevelInfo.tbShowAward) do
            local G, D, P, L, N = table.unpack(tbInfo)
            local tbParam = {G = G, D = D, P = P, L = L, N = N}
            table.insert(self.tbRewards, tbParam)
            local pObj = self.DropListFactory:Create(tbParam)
            self.List:AddItem(pObj)
        end
    end

    local fr = function()
        if not self.tbLevelInfo.tbShowRandomAward then return end
        for _, tbInfo in ipairs(self.tbLevelInfo.tbShowRandomAward) do
            local G, D, P, L, N = table.unpack(tbInfo)
            local tbParam = {G = G, D = D, P = P, L = L, N = N, dropType = Launch.nDropType.RandomDrop}
            table.insert(self.tbRewards, tbParam)
            local pObj = self.DropListFactory:Create(tbParam)
            self.List:AddItem(pObj)
        end
    end

    fn() 
    fr()
end

function tbClass:ChangeNum(nFlag)
    if nFlag == 2 then
        self.nSelectIdx = self.nMaxMopup
        local vigor = 0
        if self.tbLevelInfo.tbConsumeVigor then
            vigor = (self.tbLevelInfo.tbConsumeVigor[1] or 0) + (self.tbLevelInfo.tbConsumeVigor[2] or 0)
        elseif self.tbLevelInfo.nConsumeVigor then 
            vigor = self.tbLevelInfo.nConsumeVigor
        end

        if vigor > 0 then
            self.nSelectIdx = math.floor(Cash.GetMoneyCount(Cash.MoneyType_Vigour) / vigor) - 1
            if self.nSelectIdx > self.nMaxMopup then
                self.nSelectIdx = self.nMaxMopup
            end
        end        
    end

    if nFlag == 0 then
        self.nSelectIdx = self.nSelectIdx - 1
        if self.nSelectIdx <= 0 then
            self.nSelectIdx = 1
            UI.ShowTip("tip.MinFightCount")
            return
        end
    elseif nFlag == 1 or nFlag == 2 then
        self.nSelectIdx = self.nSelectIdx + 1
        if self.nSelectIdx > self.nMaxMopup then
            self.nSelectIdx = self.nMaxMopup
            if nFlag ~= 2 then
                UI.ShowTip("tip.MaxFightCount")
                return
            end
        end

        if self.tbLevelInfo.nNum >= 0 then
            local nLeftNum = self.tbLevelInfo.nNum - Role.GetLevelPassNum(self.tbLevelInfo.nID)
            if self.nSelectIdx > nLeftNum then
                self.nSelectIdx = nLeftNum
                if nFlag ~= 2 then
                    UI.ShowTip("role.limit_2")
                    return
                end
            end
        end

        if Launch.GetType() == LaunchType.ROLE and self.tbLevelInfo.nConsume > 0 then 
            local num = Cash.GetMoneyCount(Role.MoneyID)
            local nLeftNum = math.floor(num / self.tbLevelInfo.nConsume)
            if self.nSelectIdx > nLeftNum then
                self.nSelectIdx = nLeftNum
                if nFlag ~= 2 then
                    UI.ShowTip("role.limit_1")
                    return
                end
            end
        end
    end

    if self.nSelectIdx <= 0 then
        self.nSelectIdx = 1
    elseif self.nSelectIdx > self.nMaxMopup then
        self.nSelectIdx = self.nMaxMopup
    end

    self.TextNum:SetText(self.nSelectIdx)
    self:ShowConsume()
end

--扫
function tbClass:DoMopup()
    if not self.tbLevelInfo then 
        return 
    end

    if Launch.GetType() == LaunchType.ROLE then
        local num = Cash.GetMoneyCount(Role.MoneyID)
        if num < self.tbLevelInfo.nConsume * self.nSelectIdx then
            return false, Text("role.limit_1")
        end
    end

    if self.tbLevelInfo.nNum >= 0 and Role.GetLevelPassNum(self.tbLevelInfo.nID) + self.nSelectIdx > self.tbLevelInfo.nNum then
        return false, Text("role.limit_2")
    end

    if self.needVigor and Cash.GetMoneyCount(Cash.MoneyType_Vigour) < self.needVigor then
        UI.Open("PurchaseEnergy", "Energy")
        return
    end

    local tbParam = {
        nLevel = me:Level(),
        nExp = me:Exp(),
    }

    Role.Req_LevelMopup(self.tbLevelInfo.nID, self.nSelectIdx)
    UI.Close(self)
end

return tbClass
