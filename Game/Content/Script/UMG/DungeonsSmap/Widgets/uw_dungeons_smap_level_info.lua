-- ========================================================
-- @File    : uw_dungeons_smap_level_info.lua
-- @Brief   : 关卡详情界面
-- ========================================================
---@class tbClass : ULuaWidget
---@field DropList UListView
---@field Conditions UWrapBox
local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
    BtnAddEvent(self.FightBtn, function() self:OnClickFight() end)
    self.DropListFactory = Model.Use(self)
    self:DoClearListItems(self.DropList)

    BtnAddEvent(self.BtnScreen, function()
        self:ShowMultipleList()
    end)

    -- BtnAddEvent(self.BtnItem, function()
    --     if self.tbRewards and #self.tbRewards > 0 then
    --         UI.Open('GainItem', self.tbRewards, nil, nil, true)
    --     end
    -- end)

    BtnAddEvent(self.BtnItemList, function ()
        self:OpenMonsterInfo()
    end)
    BtnAddEvent(self.BtnMonsterList, function ()
        self:OpenMonsterInfo()
    end)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nChangeEvent)
end

function tbClass:OnClickFight()
     local nVigor = self.tbCfg:GetConsumeVigor() 
    if Launch.GetMultiple() > 1 then
        nVigor = nVigor * Launch.GetMultiple()
    end
    
    if Cash.GetMoneyCount(Cash.MoneyType_Vigour) < nVigor then
        UI.Open("PurchaseEnergy", "Energy")
        return
    end

    if self.bMaxGuarantee then
        UI.Open("MessageBox", Text("ui.TxtSmapTip6"), function()
            WidgetUtils.Collapsed(self)
            EventSystem.Remove(self.nChangeEvent)
            UI.Open('Formation', nil, nil, self.tbCfg)
        end)
        return
    end
    WidgetUtils.Collapsed(self)
    EventSystem.Remove(self.nChangeEvent)
    UI.Open('Formation', nil, nil, self.tbCfg)
end

---显示详情
function tbClass:Show(tbCfg, bMaxGuarantee)
    EventSystem.Remove(self.nChangeEvent)
    self.nChangeEvent = EventSystem.On(Event.VigorChanged, function() self:UpdateVigor() end)
    WidgetUtils.SelfHitTestInvisible(self)
    self.tbCfg = tbCfg
    self.bMaxGuarantee = bMaxGuarantee
    ---概念图
    if tbCfg.nPictureLevel then
        SetTexture(self.ImgChapter, tbCfg.nPictureLevel)
    end
    ---名称显示
    self.Chapter:SetText(Text(tbCfg.sName))
    self.LevelName:SetText(Text(tbCfg.sFlag))
    ---推荐战力显示
    self.TxtPower:SetText(tbCfg.nRecommendPower)
    ---多倍
    self:ShowMultiple()
    ---消耗体力显示
    self:UpdateVigor()
    ---显示掉落信息
    self.DropList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.DropList)
    local bGet = self.tbCfg.IsPass and self.tbCfg:IsPass()
    self.tbRewards = {}
    WidgetUtils.SetVisibleOrCollapsed(self.BtnItem, true)
    local ff = function()
        if not tbCfg.tbShowFirstAward then return end
        ---首通奖励显示
        for _, tbInfo in ipairs(tbCfg.tbShowFirstAward) do
            local G, D, P, L, N = table.unpack(tbInfo)
            local tbParam = {G = G, D = D, P = P, L = L, N = N, bIsFirst = true, bGeted = bGet}
            table.insert(self.tbRewards, tbParam)
            local pObj = self.DropListFactory:Create(tbParam)
            self.DropList:AddItem(pObj)
        end
    end

    local fn = function()
        if not tbCfg.tbShowAward then return end
        for _, tbInfo in ipairs(tbCfg.tbShowAward) do
            local G, D, P, L, N = table.unpack(tbInfo)
            local tbParam = {G = G, D = D, P = P, L = L, N = N}
            table.insert(self.tbRewards, tbParam)
            local pObj = self.DropListFactory:Create(tbParam)
            self.DropList:AddItem(pObj)
        end
    end

    local fr = function()
        if not tbCfg.tbShowRandomAward then return end
        for _, tbInfo in ipairs(tbCfg.tbShowRandomAward) do
            local G, D, P, L, N = table.unpack(tbInfo)
            local tbParam = {G = G, D = D, P = P, L = L, N = N, dropType = Launch.nDropType.RandomDrop}
            table.insert(self.tbRewards, tbParam)
            local pObj = self.DropListFactory:Create(tbParam)
            self.DropList:AddItem(pObj)
        end
    end

    if bGet then fn() fr() ff() else ff() fn() fr() end

    self.Des:SetText(Text(self.tbCfg.sDes))
    WidgetUtils.SelfHitTestInvisible(self.PanelDesc)

    WidgetUtils.HitTestInvisible(self.PanelLevel)
    self.TxtLevelNum:SetText(UE4.ULevelLibrary.GetPresetMonsterLevelById(tbCfg.nID))

    -- 推荐战力显示
    -- if tbCfg.GetRecommendPower then
    --     WidgetUtils.HitTestInvisible(self.PanelCombat)
    --     self.TxtPower:SetText(tbCfg:GetRecommendPower())
    -- else
        WidgetUtils.Collapsed(self.PanelCombat)
    --end

    if self.PanelItem and self.PanelItem:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
        if self.tbCfg.nShowListType == 1 then   --显示怪物列表
            WidgetUtils.Collapsed(self.DropList)
            WidgetUtils.Collapsed(self.BtnItemList)
            WidgetUtils.Visible(self.BtnMonsterList)
            WidgetUtils.SelfHitTestInvisible(self.MonsterList1)
        else    --显示奖励列表
            WidgetUtils.Collapsed(self.MonsterList1)
            WidgetUtils.Collapsed(self.BtnMonsterList)
            WidgetUtils.Visible(self.BtnItemList)
            WidgetUtils.SelfHitTestInvisible(self.DropList)
        end
    end
end

function tbClass:UpdateVigor()
    if not self.TxtCurrencyNum or not self.tbCfg then return end

    local nVigor = self.tbCfg:GetConsumeVigor()
    if Launch.GetMultiple() > 1 then
        nVigor = nVigor * Launch.GetMultiple()
    end

    self.TxtCurrencyNum:SetText(nVigor)
    if Cash.GetMoneyCount(Cash.MoneyType_Vigour) >= nVigor then
        self.TxtCurrencyNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
    else
        self.TxtCurrencyNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#aa3131'))
    end
end


----显示多倍
function tbClass:ShowMultiple()
    self.nSelectMultiple = 1
    Launch.SetMultiple(self.nSelectMultiple)

    --条件判定
    if not Launch.CheckLevelMutipleOpen() then
        WidgetUtils.Collapsed(self.PanelMultiple)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.PanelMultiple)

    self:ShowMultipleList(true)
    if self.TextCurrent then
        self.TextCurrent:SetText(string.format("x%d", self.nSelectMultiple))
    end
end

----点击选择倍数
function tbClass:ClickMultipleNumber(nMultiple)
    if not Launch.CheckLevelMutipleOpen() then
        UI.ShowTip("error.multiple_not_open")
        return
    end

    local tbMul = Player.GetMultipleConfig(Launch.GetType(), nMultiple)
    if not tbMul then
        UI.ShowTip("error.multiple_not_support")
        return
    end

    Launch.SetMultiple(nMultiple)
    self.nSelectMultiple = nMultiple
    if self.TextCurrent then
        self.TextCurrent:SetText(string.format("x%d", self.nSelectMultiple))
    end

    self:UpdateVigor()
end

----显示倍数列表
function tbClass:ShowMultipleList(bClose)
    self:DoClearListItems(self.ListScreen)
    if not bClose and not WidgetUtils.IsVisible(self.ListScreen) then
        local tbList = Player.GetMultipleList(Launch.GetType())
        if not tbList or #tbList == 0 then return end

        --显示列表
        for i=#tbList,1, -1 do
            local v = tbList[i]
            local tbParam = {tbConfig = v, bSelected =  (self.nSelectMultiple == v.nMultiple)}
            tbParam.OnClick = function()
                self:ClickMultipleNumber(v.nMultiple)
                WidgetUtils.Collapsed(self.ListScreen)
            end

            local pObj = self.DropListFactory:Create(tbParam)
            self.ListScreen:AddItem(pObj)
        end
        WidgetUtils.SelfHitTestInvisible(self.ListScreen)
    else
        WidgetUtils.Collapsed(self.ListScreen)
    end
end

function tbClass:OpenMonsterInfo()
    UI.Open("LevelMonster", self.tbRewards, self.tbCfg.tbMonster)
    -- WidgetUtils.SelfHitTestInvisible(self.MonsterInfo)
end

function tbClass:SetbMaxGuarantee(bMaxGuarantee)
    self.bMaxGuarantee = bMaxGuarantee
end

return tbClass
