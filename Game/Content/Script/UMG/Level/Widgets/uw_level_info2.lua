-- ========================================================
-- @File    : uw_level_info2.lua
-- @Brief   : 关卡详情界面
-- ========================================================
---@class tbClass : ULuaWidget
---@field DropList UListView
---@field Conditions UWrapBox
local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
    self:DoClearListItems(self.List)
    self:DoClearListItems(self.MonsterList)
    self:DoClearListItems(self.DropList)

    BtnAddEvent(self.FightBtn, function() self:OnClickFight() end)
    BtnAddEvent(self.BtnItem, function() end)
    BtnAddEvent(self.BtnItemList, function() self:OpenMonsterInfo() end)
    BtnAddEvent(self.BtnMonsterList, function() self:OpenMonsterInfo() end)
    BtnAddEvent(self.BtnReset, function() DefendLogic.ClearFightData() end)

    self.DropListFactory = Model.Use(self)
    self.infoSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Infos)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nChangeEvent)
end

---进入关卡
function tbClass:OnClickFight()
    local bUnLock, sLockDes = Condition.Check(self.tbCfg.tbCondition)
    if bUnLock == false then
        if sLockDes and sLockDes[1] then UI.ShowTip(sLockDes[1]) end
        return
    end

    if self.needVigor and Cash.GetMoneyCount(Cash.MoneyType_Vigour) < self.needVigor then
        UI.Open("PurchaseEnergy", "Energy")
        return
    end

    if Launch.GetType() == LaunchType.ONLINE then
        Online.CraeteRoom(Online.GetOnlineId(), Online.TeamId, true)
    elseif Launch.GetType() == LaunchType.DEFEND then
        if DefendLogic.IsInFight() then
            Formation.SetCurLineupIndex(DefendLogic.TeamId)
            Launch.Start()
        else
            UI.Open("Formation", nil, nil, self.tbCfg)
            WidgetUtils.Collapsed(self)
        end
    else
        UI.Open("Formation", nil, nil, self.tbCfg)
        WidgetUtils.Collapsed(self)
    end
end

---显示详情
--funcOnline 联机的回调
function tbClass:Show(tbCfg, funcOnline)
    EventSystem.Remove(self.nChangeEvent)
    self.nChangeEvent = EventSystem.On(Event.VigorChanged, function() self:UpdateVigor() end)
    WidgetUtils.SelfHitTestInvisible(self)
    WidgetUtils.Visible(self.BtnClose)
    self.tbCfg = tbCfg
    self.tbFunc = funcOnline

    --清空联机关卡缓存
    if not funcOnline then Online.ClearAll() end

    ---概念图
    if tbCfg.nPictureLevel then
        SetTexture(self.ImgChapter, tbCfg.nPictureLevel)
    end

    if tbCfg.nPictureBoss then
        WidgetUtils.HitTestInvisible(self.Boss)
        SetTexture(self.ImgBoss, tbCfg.nPictureBoss)
    else
        WidgetUtils.Collapsed(self.Boss)
    end

    ---名称显示
    if tbCfg.sName then
        self.Chapter:SetText(GetLevelName(tbCfg))
    end

    ---挑战次数显示
    if self.tbCfg.GetPassTime then
        self.TxtNum:SetText(self.tbCfg:GetPassTime())
    end
    if self.TxtTarget then
        self.TxtTarget:SetText(9999)
    end

    if self.infoSlot then
        local size = self.infoSlot:GetSize()
        self.infoSlot:SetSize(UE.FVector2D(800, size.Y))
    end

    WidgetUtils.Collapsed(self.PanelLevel)

    if self.tbCfg.nType == ChapterLevelType.Online or funcOnline then --联机
        self:OnlineShow(tbCfg)
    elseif Launch.GetType() == LaunchType.DEFEND then -- 防御活动
        self:DefendShow()
    end

    self.Money:Init({Cash.MoneyType_Gold, Cash.MoneyType_Silver, Cash.MoneyType_Vigour})

    self:PlayAnimation(self.AllEnter)
    self:UpdateVigor()

    if self.PanelItem and self.PanelItem:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
        if self.tbCfg.nShowListType == 1 then   --显示怪物列表
            WidgetUtils.Collapsed(self.DropList)
            WidgetUtils.Collapsed(self.BtnItemList)
            WidgetUtils.Visible(self.BtnMonsterList)
            WidgetUtils.SelfHitTestInvisible(self.MonsterList1)
            self:UpdatePanelItem()
        else    --显示奖励列表
            WidgetUtils.Collapsed(self.MonsterList1)
            WidgetUtils.Collapsed(self.BtnMonsterList)
            WidgetUtils.Visible(self.BtnItemList)
            WidgetUtils.SelfHitTestInvisible(self.DropList)
        end
    end
end

function tbClass:DefendShow()
    if self.infoSlot then
        local size = self.infoSlot:GetSize()
        self.infoSlot:SetSize(UE.FVector2D(1000, size.Y))
    end
    WidgetUtils.SelfHitTestInvisible(self.PanelLevel)
    self.TxtLevelNum:SetText(self.tbCfg.nRecommendLevel)
    self.TxtLevelDesc:SetText('TxtDefenseTip5')
    WidgetUtils.Collapsed(self.BtnClose)
    WidgetUtils.Collapsed(self.PanelItem)
    WidgetUtils.Collapsed(self.PanelChallenge)
    WidgetUtils.Collapsed(self.PanelMiddle)
    WidgetUtils.Collapsed(self.PanelExpend)
    WidgetUtils.Collapsed(self.PanelDeplete)
    WidgetUtils.Collapsed(self.StarNormal)
    WidgetUtils.SelfHitTestInvisible(self.Chapter)
    WidgetUtils.SelfHitTestInvisible(self.PanelDesc)
    WidgetUtils.SelfHitTestInvisible(self.PanelMonsters)
    WidgetUtils.SelfHitTestInvisible(self.Boss)
    WidgetUtils.Visible(self.BtnMonsterList)

    WidgetUtils.SelfHitTestInvisible(self.PanelDefense)

    self:DoClearListItems(self.MonsterList)
    local tbLevelConf = DefendLogic.GetLevelConf(DefendLogic.GetIDAndDiff())
    local levelOrder = DefendLogic.GetLevelOrderConf(DefendLogic.GetIDAndDiff())
    if levelOrder then
        self.Des:SetText(Text(levelOrder.sBuffDesc))
    end
    if tbLevelConf and tbLevelConf.tbMonster then
        self.MonsterList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
        for _, info in ipairs(tbLevelConf.tbMonster) do
            local cfg = {ID = info[1]}
            cfg.FunClick = function()
                local ui = UI.GetUI(DefendLogic.sUI)
                if ui and ui:IsOpen() then
                    ui:ShowMonInfo()
                end
            end
            local pObj = self.DropListFactory:Create(cfg)
            self.MonsterList:AddItem(pObj)
        end
    else
        WidgetUtils.Collapsed(self.MonsterList)
    end

    if DefendLogic.IsInFight() then
        self.TxtActionStart:SetText('Defense_Continue_Level')
    else
        self.TxtActionStart:SetText('TxtActionStart')
    end
end

---显示联机关卡详情
function tbClass:OnlineShow(tbCfg)
    WidgetUtils.SelfHitTestInvisible(self.PanelOnline)
    WidgetUtils.Collapsed(self.PanelMonsters)
    WidgetUtils.Collapsed(self.PanelDesc)
    WidgetUtils.Collapsed(self.PanelTop)

    WidgetUtils.Collapsed(self.MonsterList1)

    if tbCfg.sName then
        --self.LevelName:SetText(Text(tbCfg.sName))
    end

    --玩法详情
    if tbCfg.sIntro then
        self.TxtFightDetail:SetContent(Text(tbCfg.sIntro))
    end

    --上阵
    self:ShowGainRole(tbCfg)
    --怪物信息
    -- self.MonsterList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    -- self:DoClearListItems(self.MonsterList)
    -- local tbMonsterInfo = Online.GetAllLevelMonster(tbCfg.nId)
    -- if not tbMonsterInfo then return end

    -- for _, info in ipairs(tbMonsterInfo) do
    --     local pObj = self.DropListFactory:Create(info)
    --     self.MonsterList:AddItem(pObj)
    -- end

    WidgetUtils.Collapsed(self.PanelItem)

    ---显示掉落信息 暂时隐藏
    -- self.DropList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    -- self:DoClearListItems(self.DropList)

    -- self.tbRewards = {}
    -- local tbFirstList,tbDropList, tbRandomList = Online.GetAllLevelDrop(tbCfg.nId)
    -- local addDropItemFunc = function(tbList, bFirst, bRandom)
    --     if not tbList or #tbList == 0 then return end
    --     for _, tbInfo in ipairs(tbList) do
    --         local G, D, P, L, N = table.unpack(tbInfo)
    --         local tbParam = {G = G, D = D, P = P, L = L, N = N, bIsFirst = bFirst}
    --         if bRandom then tbParam.dropType = Launch.nDropType.RandomDrop end
    --         local pObj = self.DropListFactory:Create(tbParam)
    --         self.DropList:AddItem(pObj)
    --         table.insert(self.tbRewards, tbInfo)
    --     end
    -- end

    -- addDropItemFunc(tbFirstList, true)
    -- addDropItemFunc(tbDropList)
    -- addDropItemFunc(tbRandomList, false, true)
end

---显示掉落信息
function tbClass:ShowDrop(tbCfg)
    if self.DropList then
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
                local pObj = self.DropListFactory:Create(tbParam)
                table.insert(self.tbRewards, tbParam)
                self.DropList:AddItem(pObj)
            end
        end

        local fn = function()
            if not tbCfg.tbShowAward then return end
            for _, tbInfo in ipairs(tbCfg.tbShowAward) do
                local G, D, P, L, N = table.unpack(tbInfo)
                local tbParam = {G = G, D = D, P = P, L = L, N = N}
                local pObj = self.DropListFactory:Create(tbParam)
                table.insert(self.tbRewards, tbParam)
                self.DropList:AddItem(pObj)
            end
        end

        local fr = function()
            if not tbCfg.tbShowRandomAward then return end
            for _, tbInfo in ipairs(tbCfg.tbShowRandomAward) do
                local G, D, P, L, N = table.unpack(tbInfo)
                local tbParam = {G = G, D = D, P = P, L = L, N = N, dropType = Launch.nDropType.RandomDrop}
                local pObj = self.DropListFactory:Create(tbParam)
                table.insert(self.tbRewards, tbParam)
                self.DropList:AddItem(pObj)
            end
        end

        if bGet then fn() fr() ff() else ff() fn() fr() end
    end
end

---消耗体力显示
function tbClass:UpdateVigor()
    if not self.tbCfg or not self.TxtCurrencyNum then return end

    local vigor
    if self.tbCfg.tbConsumeVigor then
        vigor = (self.tbCfg.tbConsumeVigor[1] or 0) + (self.tbCfg.tbConsumeVigor[2] or 0)
    elseif self.tbCfg.nConsumeVigor then
        vigor = self.tbCfg.nConsumeVigor
    end
    if not vigor then return end

    WidgetUtils.SelfHitTestInvisible(self.PanelExpend)
    self.TxtCurrencyNum:SetText(vigor)
    if Cash.GetMoneyCount(Cash.MoneyType_Vigour) >= vigor then
        self.TxtCurrencyNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
    else
        self.TxtCurrencyNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#aa3131'))
    end
    self.needVigor = vigor

    if self.tbCfg.nType == ChapterLevelType.Online or self.tbFunc then --联机
        if vigor == 0 then
            WidgetUtils.Collapsed(self.PanelExpend)
        end
    end
end

--联机显示上阵加成角色
function tbClass:ShowGainRole(tbCfg)
    Online.SetWeekBuff()
    if not tbCfg then 
        WidgetUtils.Collapsed(self.TxtRoleUp)
        WidgetUtils.Collapsed(self.ListRoleUp)
        return 
    end

    WidgetUtils.SelfHitTestInvisible(self.ListRoleUp)

    self.ListRoleUp:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.ListRoleUp)
    local tbRoles = Online.GetWeekGainRole(tbCfg) or {}
    for _, info in ipairs(tbRoles) do
        local itemTemp = UE4.UItem.FindTemplate(1, info[1], info[2], 1)
        if itemTemp then
            local data = {
                nIcon = itemTemp.Icon,
                bGray = false,
                FunClick = function() UI.Open("ItemInfo", 1, info[1], info[2], 1) end
            }

            local pObj = self.DropListFactory:Create(data)
            self.ListRoleUp:AddItem(pObj)
        end
    end

    WidgetUtils.SelfHitTestInvisible(self.TxtRoleUp)
    self.TxtRoleUp:SetText(string.format(Text("ui.TxtRoleUp1"), tbCfg.nGainRoleRate))
end

--刷新怪物列表和奖励列表
function tbClass:UpdatePanelItem()
    self.MonsterList1:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.MonsterList1)
    for _, info in pairs(self.tbCfg.tbMonster or {}) do
        local data = {
            ID = info[1],
            Level = info[2],
            FunClick = function ()
                self:OpenMonsterInfo()
            end
        }
        local pObj = self.DropListFactory:Create(data)
        self.MonsterList1:AddItem(pObj)
    end
end

function tbClass:OpenMonsterInfo()
    UI.Open("LevelMonster", self.tbRewards, self.tbCfg.tbMonster)
    -- WidgetUtils.SelfHitTestInvisible(self.MonsterInfo)
end


return tbClass
