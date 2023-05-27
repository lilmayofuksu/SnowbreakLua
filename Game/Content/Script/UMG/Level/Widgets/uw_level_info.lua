-- ========================================================
-- @File    : uw_level_info.lua
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

    BtnAddEvent(self.BtnClose, function()
        if self.tbFunc then self.tbFunc() end
        if self.funcReturn then self.funcReturn() end
        WidgetUtils.Collapsed(self)
        EventSystem.Remove(self.nChangeEvent)
    end)
    BtnAddEvent(self.FightBtn, function() self:OnClickFight() end)
    self.DropListFactory = self.DropListFactory or Model.Use(self)

    BtnAddEvent(self.BtnScreen, function()
        self:ShowMultipleList()
    end)

    BtnAddEvent(self.BtnItem, function()
        -- if self.tbRewards and #self.tbRewards > 0 then
        --     UI.Open('GainItem', self.tbRewards, nil, nil, true)
        -- end
        self:OpenMonsterInfo()
    end)

    BtnAddEvent(self.BtnItemList, function ()
        self:OpenMonsterInfo()
    end)
    BtnAddEvent(self.BtnMonsterList, function ()
        self:OpenMonsterInfo()
    end)

    for i = 1, 3 do
        BtnAddEvent(self["BtnBuff"..i], function()
            self:UpdateTowereventBuff(i)
        end)
    end

    BtnAddEvent(self.BtnClean, function()
        self:DoOpenMopup()
    end)

    BtnAddEvent(self.BtnMonsterBuffName, function ()
        self:OpenMonsterInfo()
    end)
end

function tbClass:OpenMonsterInfo()
    if not self.tbCfg then return end
    UI.Open("LevelMonster", self.tbRewards, self.tbCfg.tbMonster)
    -- WidgetUtils.SelfHitTestInvisible(self.MonsterInfo)
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nChangeEvent)
end

---进入关卡
function tbClass:OnClickFight()
    local bUnLock, sLockDes = Condition.Check(self.tbCfg.tbCondition)
    if bUnLock == false then
        UI.ShowTip(sLockDes[1])
        return
    end

    if self.needVigor and Cash.GetMoneyCount(Cash.MoneyType_Vigour) < self.needVigor then
        UI.Open("PurchaseEnergy", "Energy")
        return
    end

    if Launch.GetType() == LaunchType.CHAPTER then
        if Chapter.IsPlot() then
            Launch.Start()
        else
            UI.Open("Formation", nil, nil, self.tbCfg)
        end
    elseif Launch.GetType() == LaunchType.ROLE then
        self:ShowRoleBreakFull()
        local canFight, msg = Role.CanFight()
        if not canFight then
            UI.ShowTip(msg)
            return
        end
        if Role.IsPlot() then
            Launch.Start()
        else
            UI.Open("Formation", nil, nil, self.tbCfg)
        end
    elseif Launch.GetType() == LaunchType.TOWER then
        UI.Open("FormationTower")
    else
        UI.Open("Formation", nil, nil, self.tbCfg)
    end

    WidgetUtils.Collapsed(self)
end

---显示详情
--funcOnline 联机的回调
function tbClass:Show(tbCfg, funcOnline, funcReturn)
    self.DropListFactory = self.DropListFactory or Model.Use(self)

    self.funcReturn = funcReturn
    self.Title:SetCustomEvent(function()
        WidgetUtils.Collapsed(self)
        if funcReturn then funcReturn() end
    end)

    EventSystem.Remove(self.nChangeEvent)
    self.nChangeEvent = EventSystem.On(Event.VigorChanged, function() self:UpdateVigor()  self:UpdateConsume() end)
    WidgetUtils.SelfHitTestInvisible(self)
    WidgetUtils.Visible(self.BtnClose)
    self.tbCfg = tbCfg
    self.tbFunc = funcOnline
    if not funcOnline then--清空联机关卡缓存
        Online.ClearAll()
    end

    ---概念图
    if tbCfg.nPictureLevel then
        SetTexture(self.ImgChapter, tbCfg.nPictureLevel)
    end

    if tbCfg.nPictureBoss and Launch.GetType() ~= LaunchType.DLC1_CHAPTER then
        WidgetUtils.HitTestInvisible(self.Boss)
        SetTexture(self.ImgBoss, tbCfg.nPictureBoss)
    else
        WidgetUtils.Collapsed(self.Boss)
    end

    ---名称显示
    if Launch.GetType() == LaunchType.DLC1_CHAPTER and DLC_Chapter.GetChapterID() == 1 then
        self.Chapter:SetText(Text(tbCfg.sFlag))
        WidgetUtils.Collapsed(self.LevelName)
    else
        if tbCfg.sName then
            self.Chapter:SetText(GetLevelName(tbCfg))
        else
            WidgetUtils.Collapsed(self.Chapter)
        end
        if tbCfg.sFlag and self.LevelName then
            self.LevelName:SetText(Text(tbCfg.sFlag))
        else
            WidgetUtils.Collapsed(self.LevelName)
        end
    end

    ---挑战次数显示
    if self.tbCfg.GetPassTime then
        self.TxtNum:SetText(self.tbCfg:GetPassTime())
    end
    if self.TxtTarget then
        self.TxtTarget:SetText(9999)
    end

    -- 推荐战力显示
    -- if self.tbCfg.GetRecommendPower then
    --     WidgetUtils.SelfHitTestInvisible(self.PanelCombat)
    --     self.TxtPower:SetText(self.tbCfg:GetRecommendPower())
    -- else
        WidgetUtils.Collapsed(self.PanelCombat)
    --end

    --推荐等级显示
    if Launch.GetType() == LaunchType.CHAPTER or Launch.GetType() == LaunchType.ROLE or Launch.GetType() == LaunchType.DLC1_CHAPTER or Launch.GetType() == LaunchType.TOWEREVENT then
        WidgetUtils.SelfHitTestInvisible(self.PanelLevel)
        self.TxtLevelNum:SetText(UE4.ULevelLibrary.GetPresetMonsterLevelById(self.tbCfg.nID))
    elseif Launch.GetType() == LaunchType.TOWER then
        WidgetUtils.SelfHitTestInvisible(self.PanelLevel)
        local str = UE4.ULevelLibrary.GetPresetMonsterLevelById(self.tbCfg.nID)
        if ClimbTowerLogic.IsAdvanced() then
            local cfg = ClimbTowerLogic.GetLevelCfg()
            local diff = ClimbTowerLogic.GetLevelDiff()
            if cfg and cfg.tbMonsterLevel and cfg.tbMonsterLevel[diff] then
                str = math.min(cfg.tbMonsterLevel[diff], 80)
            end
        end
        self.TxtLevelNum:SetText(str)
    else
        WidgetUtils.Collapsed(self.PanelLevel)
    end
    ---显示掉落信息
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
    end

    ---剧情关卡
    if self.tbCfg.nType == ChapterLevelType.PLOT then
        WidgetUtils.Collapsed(self.PanelDesc)
        WidgetUtils.Collapsed(self.Conditions)
        WidgetUtils.SelfHitTestInvisible(self.PanelMiddle)
    elseif self.tbCfg.nType == ChapterLevelType.RANDOM then
        WidgetUtils.Collapsed(self.PanelItem)
        WidgetUtils.Collapsed(self.PanelChallenge)
        WidgetUtils.Collapsed(self.PanelMiddle)
        WidgetUtils.Collapsed(self.Chapter)
        WidgetUtils.SelfHitTestInvisible(self.PanelDesc)
        WidgetUtils.SelfHitTestInvisible(self.PanelMonsters)
        self:UpdateTowerMonsters()
        self.TxtLevelDesc:SetText(Text("TxtLevelBuff"))
        if self.tbCfg.TowerLayer then
            local tbAward = ClimbTowerLogic.GetLayerTbAward(self.tbCfg.TowerType, self.tbCfg.TowerLayer)
            if tbAward.tbStarCount and tbAward.tbStarCount[3] then
                local TowerNowStar = ClimbTowerLogic.GetLayerStar(self.tbCfg.TowerType, self.tbCfg.TowerLayer)
                local TowerStarNum = tbAward.tbStarCount[3]
                if TowerNowStar >= TowerStarNum then
                    WidgetUtils.Collapsed(self.StarNormal)
                    WidgetUtils.HitTestInvisible(self.StarCompleted)
                    self.TxtNum_2:SetText(TowerNowStar.."/"..TowerStarNum)
                else
                    WidgetUtils.Collapsed(self.StarCompleted)
                    WidgetUtils.HitTestInvisible(self.StarNormal)
                    self.TxtNum_1:SetText(TowerNowStar.."/"..TowerStarNum)
                end
            end
            local realLayer = self.tbCfg.TowerLayer
            if self.tbCfg.TowerType == 2 then
                realLayer = realLayer + #ClimbTowerLogic.GetAllLayerTbLevel(1)
            end

            self.LevelName:SetText(Text("climbtower.name", realLayer))
        end
        local levelcfg = ClimbTowerLogic.GetLevelCfg()
        if levelcfg and levelcfg.sBuffDesc then
            self.Des:SetText(Text(levelcfg.sBuffDesc))
        end
    elseif self.tbCfg.nType == ChapterLevelType.Challenge then
        WidgetUtils.Collapsed(self.PanelDesc)
        WidgetUtils.Collapsed(self.PanelMiddle)
        WidgetUtils.Collapsed(self.PanelItem)
        WidgetUtils.Collapsed(self.Chapter)
        WidgetUtils.SelfHitTestInvisible(self.PanelChallenge)
        self.Records:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
        self.Records:ClearChildren()
        for _, v in ipairs(LevelRecordLogic.GetTeamData(tbCfg.nID)) do
            local Widget = LoadWidget("/Game/UI/UMG/Level/Widgets/uw_level_item_challenge.uw_level_item_challenge_C")
            if Widget then
                self.Records:AddChild(Widget)
                Widget:Init(v)
            end
        end
    elseif Launch.GetType() == LaunchType.ROLE then --角色碎片本
        WidgetUtils.Collapsed(self.PanelMiddle)
        WidgetUtils.Collapsed(self.PanelExpend)
        WidgetUtils.SelfHitTestInvisible(self.PanelDesc)
        WidgetUtils.SelfHitTestInvisible(self.PanelDeplete)

        self.Des:SetText(Text(self.tbCfg.sDes))
        self.TxtLevelDesc:SetText("TxtRoleLevelInfo")
    elseif Launch.GetType() == LaunchType.TOWEREVENT then -- 爬塔-战术考核
        WidgetUtils.Collapsed(self.PanelMiddle)
        WidgetUtils.SelfHitTestInvisible(self.PanelTowerevent)
        for i = 1, 3 do
            local id = self.tbCfg.tbBuffID[i]
            if id then
                WidgetUtils.Visible(self["BtnBuff"..i])
                self["TxtNormalName"..i]:SetText(Localization.GetSkillName(id))
                self["TxtSelectName"..i]:SetText(Localization.GetSkillName(id))
            else
                WidgetUtils.Collapsed(self["BtnBuff"..i])
            end
        end
        self:UpdateTowereventBuff(1)
    elseif Launch.GetType() == LaunchType.DLC1_CHAPTER then -- dlc1副本
        if DLC_Chapter.GetChapterID() == 1 then
            WidgetUtils.Collapsed(self.PanelDesc)
            WidgetUtils.SelfHitTestInvisible(self.PanelMiddle)
            --[[
                    星级目标
            ]]
            WidgetUtils.SelfHitTestInvisible(self.Conditions)
            local sInfo = DLC_Chapter.GetLevelStarCfg(self.tbCfg.nID)
            local ArrayPro = UE4.ULevelStarTaskManager.GetInfoByCondition(sInfo)
            for i = 1, self.Conditions:GetChildrenCount() do
                WidgetUtils.Collapsed(self.Conditions:GetChildAt(i - 1))
            end
            local tbStarInfo = self.tbCfg:DidGotStars()

            for i = 1, ArrayPro:Length() do
                local pItem = self.Conditions:GetChildAt(i - 1)
                if pItem then
                    local pPro = ArrayPro:Get(i)
                    pItem:SetInfo(pPro.Description, tbStarInfo[i-1])
                    WidgetUtils.SelfHitTestInvisible(pItem)
                end
            end
        else
            WidgetUtils.SelfHitTestInvisible(self.PanelDesc)
            WidgetUtils.Collapsed(self.PanelMiddle)
            local cfg = DLCLevel.Get(DLC_Chapter.GetLevelID())
            if cfg and cfg.sDes then
                self.Des:SetText(Text(cfg.sDes))
            end
        end
    elseif Launch.GetType() == LaunchType.DLC1_ROGUE then
        WidgetUtils.Collapsed(self.PanelMiddle)
        WidgetUtils.Collapsed(self.PanelExpend)
        WidgetUtils.Collapsed(self.Conditions)
        WidgetUtils.SelfHitTestInvisible(self.PanelDesc)
        self.Des:SetText(Text("rogue.TxtLevelDesc"))
        local _, MBuff = RogueLogic.GetTbMonsterBuffID()
        if MBuff then
            WidgetUtils.SelfHitTestInvisible(self.PanelMonsterBuff)
            self.TxtMonsterBuffName:SetText(Text(MBuff.sName))
        else
            WidgetUtils.Collapsed(self.PanelMonsterBuff)
        end
    else
        WidgetUtils.Collapsed(self.PanelDesc)
        WidgetUtils.SelfHitTestInvisible(self.PanelMiddle)
        --[[
                星级目标
        ]]
        WidgetUtils.SelfHitTestInvisible(self.Conditions)
        for i = 1, self.Conditions:GetChildrenCount() do
            WidgetUtils.Collapsed(self.Conditions:GetChildAt(i - 1))
        end
        local tbStarInfo = self.tbCfg:DidGotStars()
        for i = 0, #tbCfg.tbStarCondition - 1 do
            local pItem = self.Conditions:GetChildAt(i)
            if pItem then
                local pPro = UE4.ULevelStarTaskManager.GetStarTaskProperty(self.tbCfg.nID, i)
                pItem:SetInfo(pPro.Description, tbStarInfo[i])
                WidgetUtils.SelfHitTestInvisible(pItem)
            end
        end
    end
    if Launch.GetType() == LaunchType.ROLE then --角色碎片本
        WidgetUtils.SelfHitTestInvisible(self.Money)
        self.Money:Init({Role.MoneyID, Cash.MoneyType_Vigour})
    elseif Launch.GetType() == LaunchType.DLC1_ROGUE then
        WidgetUtils.Collapsed(self.Money)
    else
        WidgetUtils.SelfHitTestInvisible(self.Money)
        self.Money:Init({Cash.MoneyType_Gold, Cash.MoneyType_Silver, Cash.MoneyType_Vigour})
    end
    self:PlayAnimation(self.AllEnter)
    self:ShowMultiple()
    self:ShowMopup()
    self:UpdateVigor()
    self:UpdateConsume()

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

---部分btn不显示
function tbClass:CollapsedBtn()
    WidgetUtils.Collapsed(self.FightBtn)
    WidgetUtils.Collapsed(self.FightMany)
    WidgetUtils.Collapsed(self.BtnStory)
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

    if Launch.GetMultiple() > 1 then
        vigor = vigor * Launch.GetMultiple()
    end

    self.TxtCurrencyNum:SetText(vigor)
    if Cash.GetMoneyCount(Cash.MoneyType_Vigour) >= vigor then
        self.TxtCurrencyNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
    else
        self.TxtCurrencyNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#aa3131'))
    end
    self.needVigor = vigor
end

---消耗记忆嵌片显示
function tbClass:UpdateConsume()
    if Launch.GetType() ~= LaunchType.ROLE then --角色碎片本
        return
    end

    self.TxtCurrencyNum_1:SetText(self.tbCfg.nConsume * Launch.GetMultiple())
    if Cash.GetMoneyCount(Role.MoneyID) >= self.tbCfg.nConsume * Launch.GetMultiple() then
        self.TxtCurrencyNum_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
    else
        self.TxtCurrencyNum_1:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#aa3131'))
    end

    if self.tbCfg.tbConsumeVigor then
        local vigor = (self.tbCfg.tbConsumeVigor[1] or 0) + (self.tbCfg.tbConsumeVigor[2] or 0)
        vigor = vigor  * Launch.GetMultiple()
        self.TxtCurrencyNum_2:SetText(vigor)
        if Cash.GetMoneyCount(Cash.MoneyType_Vigour) >= vigor then
            self.TxtCurrencyNum_2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
        else
            self.TxtCurrencyNum_2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#aa3131'))
        end
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
        --UI.ShowTip()
        return
    end

    local tbMul = Player.GetMultipleConfig(Launch.GetType(), nMultiple)
    if not tbMul then 
       -- UI.ShowTip()
        return
    end

    Launch.SetMultiple(nMultiple)
    self.nSelectMultiple = nMultiple
    if self.TextCurrent then
        self.TextCurrent:SetText(string.format("x%d", self.nSelectMultiple))
    end

    self:UpdateVigor()
    self:UpdateConsume()
end

----显示倍数列表
function tbClass:ShowMultipleList(bClose)
    self:DoClearListItems(self.ListScreen)
    if not bClose and not WidgetUtils.IsVisible(self.ListScreen) then
        local tbList = Player.GetMultipleList(Launch.GetType())
        if not tbList or #tbList == 0 then return end

        local tbConfig = nil
        if Launch.GetType() == LaunchType.ROLE then --角色碎片本
            tbConfig = RoleLevel.Get(Role.GetLevelID())
        end

        for i=#tbList,1, -1 do
            local v = tbList[i]
            if not tbConfig or not tbConfig.nNum or tbConfig.nNum < 0 or v.nMultiple <= tbConfig.nNum then
                local tbParam = {tbConfig = v, bSelected =  (self.nSelectMultiple == v.nMultiple)}
                tbParam.OnClick = function()
                    self:ClickMultipleNumber(v.nMultiple)
                    WidgetUtils.Collapsed(self.ListScreen)
                end

                local pObj = self.DropListFactory:Create(tbParam)
                self.ListScreen:AddItem(pObj) 
            end
        end
        WidgetUtils.SelfHitTestInvisible(self.ListScreen)
    else
        WidgetUtils.Collapsed(self.ListScreen)
    end
end

--爬塔-战术考核的buff选择
function tbClass:UpdateTowereventBuff(index)
    if not self.tbCfg or not self.tbCfg.tbBuffID then
        return
    end
    for i = 1, 3 do
        if i == index then
            WidgetUtils.Collapsed(self["PanelCommon"..i])
            WidgetUtils.HitTestInvisible(self["PanelSelect"..i])
        else
            WidgetUtils.Collapsed(self["PanelSelect"..i])
            WidgetUtils.HitTestInvisible(self["PanelCommon"..i])
        end
    end
    local buffid = self.tbCfg.tbBuffID[index]
    self.TxtBuffdesc:SetContent(Localization.GetSkillDesc(buffid))
end

--爬塔界面刷新怪物列表
function tbClass:UpdateTowerMonsters()
    self.MonsterList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.MonsterList)

    local FunClick = function ()
        UI.Open("TowerArea")
    end
    BtnClearEvent(self.BtnMonsters)
    BtnAddEvent(self.BtnMonsters, FunClick)

    local TbLevelID = ClimbTowerLogic.GetNowTbLevelID()
    local data = {}
    local tbMonsterInfo = {}
    for _, ID in pairs(TbLevelID) do
        local cfg = ClimbTowerLogic.GetLevelInfo(ID)
        if cfg and cfg.tbMonster then
            for _, tbInfo in pairs(cfg.tbMonster) do
                for _, info in pairs(tbInfo) do
                    if not data[info] then
                        table.insert(tbMonsterInfo, info)
                        data[info] = true
                    end
                end
            end
        end
    end

    for _, info in pairs(tbMonsterInfo) do
        local data = {
            ID = info,
            -- Level = info[2],
            FunClick = FunClick
        }
        local pObj = self.DropListFactory:Create(data)
        self.MonsterList:AddItem(pObj)
    end
end

--刷新怪物列表和奖励列表
function tbClass:UpdatePanelItem()
    self.MonsterList1:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.MonsterList1)
    for _, info in pairs(self.tbCfg.tbMonster or {}) do
        local data = {
            ID = info,
            -- Level = info[2],
            FunClick = function ()
                self:OpenMonsterInfo()
            end
        }
        local pObj = self.DropListFactory:Create(data)
        self.MonsterList1:AddItem(pObj)
    end
end

----显示扫荡
function tbClass:ShowMopup()
    self.nSelectMopup = 1

    --条件判定
    if not Launch.CheckLevelMutipleOpen(true) then
        WidgetUtils.Collapsed(self.BtnClean)
        return
    end

    if not Player.GetMoppingUpConfig(Launch.GetType()) then
        WidgetUtils.Collapsed(self.BtnClean)
        return
    end

    WidgetUtils.Visible(self.BtnClean)
end

--点击扫荡
function tbClass:DoOpenMopup()
    if Launch.GetType() == LaunchType.ROLE then --角色碎片本
        local canFight, msg = Role.CanFight()
        if not canFight then
            UI.ShowTip(msg)
            return
        end
    end

    if self.needVigor and Cash.GetMoneyCount(Cash.MoneyType_Vigour) < self.needVigor then
        UI.Open("PurchaseEnergy", "Energy")
        return
    end

    self:ShowRoleBreakFull()

    UI.Open("MopupStart", self.tbCfg)
end

--提示天启满
function tbClass:ShowRoleBreakFull()
    if Launch.GetType() ~= LaunchType.ROLE then --角色碎片本
        return
    end

    local tbRoleCfg = Role.GetNowChapterCfg()
    if not tbRoleCfg then return end

    local tbRole = RoleCard.GetItem({tbRoleCfg.tbCharacter[1], tbRoleCfg.tbCharacter[2], tbRoleCfg.tbCharacter[3], tbRoleCfg.tbCharacter[4]})
    if not tbRole then return end

    if RBreak.IsLimit(tbRole) then
        UI.ShowTip("ui.TxtCleanRoleBreak")
    end
end

return tbClass
