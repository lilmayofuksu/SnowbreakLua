-- ========================================================
-- @File    : umg_logistics_up.lua
-- @Brief   : 后勤卡升级
-- @Author  :
-- @Date    :
-- ========================================================


local LogisUp = Class("UMG.SubWidget")
local MAX_MAT_DISPLAY_NUM = 5
LogisUp.ItemPath = "UMG/Support/LogisticsShow/Widgets/uw_Logistics_item_data"
LogisUp.bCanOnKey = false

LogisUp.QualityImg = {
    1700070,
    1700071,
    1700072,
    1700073,
}

function LogisUp:Construct()
    self.ListLevelItem:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.ListFactory = Model.Use(self)
    self.ItemFactory = Model.Use(self)

    self.pItem = Model.Use(self, self.AttrPath)
    self.Factory = Model.Use(self)
    self:OnInit()

    --- 初始化排序
    local tbSopportSortType = {
        { Option = Text('ui.item_level')},
        { Option = Text('ui.TxtRareSort')},
        { Option = Text('ui.TxtScreen14')}
    } 

    ---Sort Init
    self.tbSortParam = {}
    self.tbSortParam.tbSortInfos = {}
    self.tbSortParam.tbSortInfos[1] = {
        {
            tbSorts = ItemSort.SupportLevelSort,
            sName =  tbSopportSortType[1].Option
        },
        {
            tbSorts = ItemSort.SupportColorSort,
            sName =  tbSopportSortType[2].Option
        },
        {
            tbSorts = ItemSort.SupportExpSort,
            sName =  tbSopportSortType[3].Option
        }
    }
    self.tbCurSort = {nIdx = 1, bReverse = true}
    self.tbSortParam.nCurIdx = self.tbCurSort.nIdx
    self.tbSortParam.bReverse = self.tbCurSort.bReverse
    self.tbSortParam.fSort = function(nIdx, bReverse)
        self.tbCacheCostTbParam = self:GetSupportUpgradeItem(bReverse)
        local SupportItems = self:SortItem(nIdx, self:GetSupportItem(), bReverse)
        for _, item in pairs(SupportItems) do
            table.insert(self.tbCacheCostTbParam, item)
        end
        self.Select:Show(self.tbCacheCostTbParam, function()
            EventSystem.TriggerTarget(Logistics, "PushOrMoveTitleEvent", false)
            WidgetUtils.Collapsed(self.Select)
            self.bShowSelect = false
        end)
        self.tbCurSort.nIdx = nIdx
        self.tbCurSort.bReverse = bReverse
    end
    --- 词缀初始化
    self:InitAffixBtn()

    BtnAddEvent(self.BtnMethod, function()
        Daily.OpenByID(7)
    end)
end

function LogisUp:OnInit()
    self:RegisterEventOnTarget(
        Logistics,
        Logistics.MaterialsUnChange,
        function()
            UI.ShowTip("tip.logistic_up_lv_max...")
        end
    )

    self.BtnUp.OnClicked:Add(
        self,
        function()
            self.tbBringSys[1].OnClick()
        end)

    self.BtnBreach.OnClicked:Add(
        self,
        function()
            self.tbBringSys[2].OnClick()
        end)

    BtnAddEvent(self.BtnOneKeyLevel,function() self:OneKeySelect() end)

    self.tbBringSys = {
        {pWidget = self.PanelLevel,CallFun = function() self:OpenLevelPanel() end,OnClick = function() self:OnLvReq() end,TipWidget = 'SupportLvTip'},            -- 升级
        {pWidget = self.PanelBreach ,CallFun = function() self:OpenBreachPanel() end,OnClick = function() self:OnBreachReq() end,TipWidget = 'SupportBreachTip'},   -- 突破
        {pWidget = self.PanelMax,CallFun = function() self:OpenMaxLevelPanel() end,}          -- 突破至最高等级 
    }

    self:DoClearListItems(self.ListBreachAtt)
    self:DoClearListItems(self.ListBreachItem)
    self:DoClearListItems(self.ListLevelItem)
end

function LogisUp:OnActive(InData, _, __, Select)
    --- 播放All Enter动画
    self:PlayAnimation(self.AllEnter, 0, 1 ,UE4.EUMGSequencePlayMode.Forward, 1, false)
    self.tbMatGrid = {}
    self.tbSelectItem = self.tbSelectItem or {}
    self.bInitCostItem = false
    self.LogiCard = InData or Logistics.CulCard
    self.nCacheLevel = self.nCacheLevel or self.LogiCard:EnhanceLevel()

    --- 为了做3D Panel效果 Select挪到了外层 OnActive时传入
    self.Select = Select
    self.Select:InitScreen(self.tbSortParam)
    self.Select.TxtAllEmpty:SetText(Text('ui.TxtAllEmpty'))

    --- 初始化显示信息
    self:ShowAttrChange()
    --- 立绘
    self:CheckBanner2d()

    ---缓存等级
    self.Money:Init({Cash.MoneyType_Vigour, Cash.MoneyType_Silver, Cash.MoneyType_Gold})
    self.TextName:SetText(Text(self.LogiCard:I18N()), self.QualityImg[self.LogiCard:Color() - 1])
    SetTexture(self.ImgQuality, self.QualityImg[self.LogiCard:Color() - 1])
    SetTexture(self.ImgBreachMoney, 1600003)
    SetTexture(self.ImgMoney, 1600003)


    --- 判断进入那个子界面
    local MaxBreak = Logistics.GetBreakMax(InData)
    if self.LogiCard:EnhanceLevel()>=Logistics.GetMaxLv(InData, MaxBreak) then
        self:CheckChildSystem(3)
        return
    end

    if self.LogiCard:EnhanceLevel() >= Item.GetMaxLevel(self.LogiCard) then
        if self.LogiCard:EnhanceLevel()>Logistics.GetMaxLv(InData, MaxBreak) then
            self:CheckChildSystem(3)
            return
        end
        self:CheckChildSystem(2)
    else
        self.bInitCostItem = false
        self:CheckChildSystem(1)
    end
end

--- 子系统入口
function LogisUp:CheckChildSystem(InSubSys)
    for _, value in ipairs(self.tbBringSys) do
        WidgetUtils.Collapsed(value.pWidget)
    end
    WidgetUtils.SelfHitTestInvisible(self.tbBringSys[InSubSys].pWidget)
    if self.tbBringSys[InSubSys].CallFun then
        self.tbBringSys[InSubSys].CallFun()
    end
end

---Select道具排序
function LogisUp:SortItem(nIdx, tbItems, bReverse, SortUpdateItem)
    local tbSortInfo = self.tbSortParam.tbSortInfos[1][nIdx]
    local tbRes
    if SortUpdateItem then
        tbRes = ItemSort:TemplateSort(tbItems, ItemSort.UpdateItemColorSort)
    else
        tbRes = ItemSort:SelectItemSort(tbItems, tbSortInfo.tbSorts)
    end
    if bReverse and #tbRes > 1 then
        local nLeft = 1
        local nRight = #tbRes
        while (nLeft < nRight) do
            tbRes[nLeft], tbRes[nRight] = tbRes[nRight], tbRes[nLeft]
            nLeft = nLeft + 1
            nRight = nRight - 1
        end
    end
    return tbRes
end

--------------------------------------------------------
-----------------------LevelUp--------------------------

--- 升级初始化
function LogisUp:OpenLevelPanel()
    local num = 0
    for key, value in pairs (self.tbSelectItem) do
        num = num + 1
    end
    --- 道具消耗列表
    if num > 0 then
        self:UpDate()
    else
        self:ShowCostItems()
        self:ShowMoneyNum()

        self:SetOneKeyText(0)
        self.EXP:Set(self.LogiCard,0,Item.TYPE_SUPPORT)
    end
end

function LogisUp:UpDate()
    local nAddExp , nCount = self:GetCostExp()
    local CurLv = self.LogiCard:EnhanceLevel()
    local CurExp = self.LogiCard:Exp()
    local nNextLvExp = Item.GetUpgradeExpByLevel(self.LogiCard, CurLv)
    local nRemain = CurExp + nAddExp
    while nNextLvExp >0 and nRemain >= nNextLvExp and CurLv < Item.GetMaxLevel(self.LogiCard) do
        CurLv = CurLv + 1
        nRemain = nRemain - nNextLvExp
        nNextLvExp = Item.GetUpgradeExpByLevel(self.LogiCard, CurLv)
    end

    self.EXP:Set(self.LogiCard, nAddExp, Item.TYPE_SUPPORT)
    --- 重置状态
    self:ShowCostItems()
    self.ExpType = nil

    --- 计算所需通用银
    local nGold = 0
    for pItem, grid in pairs(self.tbSelectItem or {}) do
        nGold = nGold + pItem:ConsumeGold() * (grid.nNum or 0)
        if pItem:IsSupportCard() then
            local _, gold = Item.GetExpAndSilverNum(pItem)
            nGold = nGold - gold
        end
    end
    nGold = math.max(0, nGold)

    if Cash.GetMoneyCount(Cash.MoneyType_Silver)< nGold then
        -- self.TxtOneKey:SetText(Text('TxtOneCancle'))
        UI.ShowTip('tip.gold_not_enough')
    end
    self:ShowMoneyNum(nGold)

    self:SetOneKeyText(nCount)
    self.nCacheLevel = CurLv
    self:ShowAttrChange()
end

--- 显示消耗的金币数量
function LogisUp:ShowMoneyNum(InMoney)
    if not InMoney then
        self.TxtCostMoney:SetText('')
    else
        self.TxtCostMoney:SetText(InMoney)
    end

    if InMoney and InMoney > Cash.GetMoneyCount(Cash.MoneyType_Silver) then
        self.TxtCostMoney:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1,0,0,1))
        return
    end
    self.TxtCostMoney:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0,0,0,1))
end

--- 道具消耗列表
function LogisUp:ShowCostItems()
    -- 需要优化为配置的
    local tbSelectItem = {}
    local DisplayNum = MAX_MAT_DISPLAY_NUM
    for key, _ in pairs(self.tbSelectItem) do
        table.insert(tbSelectItem, key)
    end

    self:DoClearListItems(self.ListLevelItem)
    if DisplayNum < #tbSelectItem then
        DisplayNum = #tbSelectItem
    end
    for i = 1, DisplayNum do
        self:AddSelectItem(tbSelectItem[i], i)
    end
    self:AddSelectItem(nil,#self.tbSelectItem+1)
end

--- Item Panel Add Item
function LogisUp:AddSelectItem(InItem,InIdx)
    local tbParam = {
        fClick = function()
                        if self.Select then
                            self:ShowSelect()
                        end
                    end,
        pItem = InItem,
        nNum = self.tbSelectItem[InItem] and self.tbSelectItem[InItem].nNum or 0,
    }
    local NewItem = self.ListFactory:Create(tbParam)
    self.tbMatGrid[InIdx] = tbParam
    self.ListLevelItem:AddItem(NewItem)
end

function LogisUp:ShowSelect()
    if self.bShowSelect then return end
    self.bShowSelect = true
    local pSelect = self.Select
    
    if not self.bInitCostItem then
        pSelect:Show(self:GetTbParam() or {}, function()
            EventSystem.TriggerTarget(Logistics, "PushOrMoveTitleEvent", false)
            WidgetUtils.Collapsed(pSelect)
            self.bShowSelect = false
        end)
    end
    WidgetUtils.SelfHitTestInvisible(pSelect)
    EventSystem.TriggerTarget(Logistics, "PushOrMoveTitleEvent", true)
end

---获取选择道具的经验
function LogisUp:GetCostExp()
    local nAddExp = 0
    local nCount = 0
    for pItem, grid in pairs(self.tbSelectItem) do
        nAddExp = nAddExp + grid.nNum * pItem:ProvideExp()
        if pItem:IsSupportCard() then
            local exp = Item.GetExpAndSilverNum(pItem)
            nAddExp = nAddExp + exp
        end
        nCount = nCount + 1
    end
    return nAddExp,nCount
end

--- 属性刷新
function LogisUp:ShowAttrChange()
    local nAddExp , nCount = self:GetCostExp()
    local nLevel, nDestExp = Item.GetItemDestLevel(self.LogiCard:EnhanceLevel(), self.LogiCard:Exp(), nAddExp, Item.TYPE_SUPPORT, Item.GetMaxLevel(self.LogiCard))
    self:DoClearListItems(self.ListLevelAtt)

    local mainAttrList = Logistics.GetMainAttr(self.LogiCard)
    for _, mainAttr in pairs(mainAttrList) do
        local nNow = mainAttr.Attr
        local nNew = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr(mainAttr.sType, self.LogiCard, nLevel, self.LogiCard:Quality())
        local tbParam = { sName = Text(string.format("attribute.%s", mainAttr.sType)),
                            nNow = nNow,
                            nAdd = tonumber(nNew), --- tonumber(nNow),
                            ECate = mainAttr.sType,
                            bMainAttr = true,
                        }
        local NewObj = self.ItemFactory:Create(tbParam)
        if tonumber(tbParam.nNow) > 0 then
            self.ListLevelAtt:AddItem(NewObj)
        end
    end
end

--- 检查自己是否在材料列表
--- 只选择1级的后勤卡
function LogisUp:CheckSelf(InItems)
    local tbCost = {}
    for _, value in ipairs(InItems) do
        if value:EnhanceLevel() == 1 and 
        not(value:HasFlag(Item.FLAG_LOCK)) and
        not(value:HasFlag(Item.FLAG_USE)) and
        not (value:Id() == self.LogiCard:Id())then
            table.insert(tbCost,value)
        end
    end
    return tbCost
end

--- 转化到Select面板所需结构
--- @param InItem UItem
--- @return table
function LogisUp:GetSelectItem(InItem)
    local tbParam = {
        pItem = InItem,
        nNum = self.tbSelectItem[InItem] and self.tbSelectItem[InItem].nNum or 0,
        nHaveNum = 1,
        bCanStack = InItem:CanStack(),
        fAdd = function(item, n)
            if self.tbSelectItem[item] then
                if not item:CanStack() then
                    if self.tbSelectItem[item] then
                        return self:SubItem(item, n)
                    end
                end 
            end
            return self:AddItem(item, n)
        end,
        fSub = function(item, n) return self:SubItem(item, n) end,
    }
    return tbParam
end

--- 获取所有后勤卡,并转换成Select面板需要结构的table
function LogisUp:GetSupportItem()
    local tbCost = self:CheckSelf(Logistics.GetAllSupportCards())
    local tbRet = {}
    for _, pItem in ipairs(tbCost) do
        table.insert(tbRet, self:GetSelectItem(pItem))
    end
    return tbRet
end

--- 获取所有后勤狗粮道具,并转换成Select面板需要结构的table
function LogisUp:GetSupportUpgradeItem(bReverse)
    local tbCost = self:SortItem(2, Logistics.GetSupportUpdateItems(), bReverse, true)
    local tbRet = {}
    for _, pItem in ipairs(tbCost) do
        table.insert(tbRet, self:GetSelectItem(pItem))
    end
    return tbRet
end

--- 获取Select面板所有显示的内容
function LogisUp:GetTbParam()
    local tbCost = self:GetSupportUpgradeItem(self.tbCurSort.bReverse)
    local tbItem = self:SortItem(self.tbCurSort.nIdx, self:GetSupportItem(), self.tbCurSort.bReverse)
    for _, item in pairs(tbItem) do
        table.insert(tbCost, item)
    end
    return tbCost
end

function LogisUp:AddItem(pItem,nNum)
    if not self:CanAddItem(pItem,nNum, true) then
        return false
    end
    self.ExpType = RoleCard.ExpState.ExpAdd
    --- 判断当前点击材料是否已经被选中
    for _, value in ipairs(self.tbSelectItem) do
        if not pItem:CanStack() and pItem:Id() == value:Id() then
            return false
        end
    end
    self:UpdateSelectMat(pItem,nNum)
    return true
end

function LogisUp:SubItem(pItem,nNum)
    if not self:CanAddItem(pItem,nNum) then
        return false
    end
    self:UpdateSelectMat(pItem,nNum)
    self.ExpType = RoleCard.ExpState.ExpSub
    return true
end

function LogisUp:CanAddItem(pItem,nNum,AddItem)
    local nGold,nExp = 0,0
    for item, grid in pairs(self.tbSelectItem or {}) do
        if pItem ~= item then
            nGold = nGold + grid.nNum * item:ConsumeGold()
            nExp = nExp + grid.nNum * item:ProvideExp()
        end
    end

    local  nMaxLevel = Item.GetMaxLevel(self.LogiCard)
    nGold = nGold + nNum * pItem:ConsumeGold()
    nExp = nExp + nNum * pItem:ProvideExp()

    local nLevel,nDestExp = Item.GetItemDestLevel(self.LogiCard:EnhanceLevel(),self.LogiCard:Exp(),nExp, Item.TYPE_SUPPORT, nMaxLevel)
    if AddItem and nLevel >=nMaxLevel and self.nCacheLevel == nLevel then
        UI.ShowTip('tip.logistic max limit')
        return false
    end
    self.nCacheLevel = nLevel
    return true
end

function LogisUp:UpdateSelectMat(pItem, nNum, IgnoreUpdate)
    local grid = nil
    local bAdd = self.tbSelectItem[pItem] == nil
    if bAdd then
        grid = self:GetEmptyGrid()
        if grid == nil then
            return
        end
        self.tbSelectItem[pItem] = grid
        grid.pItem = pItem
        grid.nNum = 1
        
    else
        if pItem:IsSupportCard() then
            grid = self.tbSelectItem[pItem]
            self.tbSelectItem[pItem] = nil
            grid.nNum = 0
            EventSystem.TriggerTarget(grid,"ON_DATA_CHANGE")
            grid.pItem = nil
        else
            grid = self.tbSelectItem[pItem]
            self.tbSelectItem[pItem] = grid
            grid.nNum = grid.nNum + 1
            EventSystem.TriggerTarget(grid,"ON_DATA_CHANGE")
        end
    end
    if grid == nil then return end

    if nNum<= 0 then
        grid.nNum = 0
        self.tbSelectItem[pItem] = nil
        grid.pItem = nil
        self:ReArrange()
    else
        grid.nNum = nNum
        EventSystem.TriggerTarget(grid,"ON_DATA_CHANGE")
    end
    if IgnoreUpdate then return end
    self:UpDate()
end

function LogisUp:ReArrange()
    local tb = {}
    for i = 1, MAX_MAT_DISPLAY_NUM do
        local grid = self.tbMatGrid[i]
        if grid.pItem and self.tbSelectItem[grid.pItem] then
            table.insert(tb,{pItem = grid.pItem,nNum = grid.nNum or 0})
        end
        grid.pItem = nil
        grid.nNum = 0
    end

    for i = 1, MAX_MAT_DISPLAY_NUM do
        local grid = self.tbMatGrid[i]
        local tbCache = tb[i]

        grid.pItem = tbCache and tbCache.pItem or nil
        grid.nNum = tbCache and tbCache.nNum or 0

        if grid.pItem then
            self.tbSelectItem[grid.pItem] = grid
        end
        EventSystem.TriggerTarget(grid,'ON_DATA_CHANGE')
    end
end

function LogisUp:GetEmptyGrid()
    for _, grid in ipairs(self.tbMatGrid or {}) do
        if grid.nNum <= 0 then
            return grid
        end
    end
end

--------------------------------------------------------
-----------------------一键操作--------------------------
function LogisUp:OneKeySelect()

    local bClear = false
    for _, value in pairs(self.tbSelectItem) do
        if value.pItem then
            value.pItem = nil
            value.nNum = 0
            bClear = true
        end
    end

    if bClear then
        self.tbSelectItem = {}
        self.TxtOneKey:SetText(Text('TxtOneKey'))
        for i = 1, MAX_MAT_DISPLAY_NUM do
            local grid = self.tbMatGrid[i]
            grid.pItem = nil
            grid.nNum = 0
            EventSystem.TriggerTarget(grid, 'ON_DATA_CHANGE')
        end
        self:TryShowSelect()
        self:UpDate()
        return
    end

    self.tbSelectItem = {}
    self.bOneKey = true
    --- 已经排序的所有可消耗道具
    local AllCost = self:CheckSelf(Logistics.GetSecgradeByGDPL(3))
    --- 获取符合条件的材料
    local function GetCanCost(tbParam)
        local tbCanStackCost = {}
        local tbNoCanStackCost = {}
        for _, value in ipairs(tbParam) do
            --- 通用道具材料
            if value:IsSupplies() then
                table.insert(tbCanStackCost,value)
            end
            --- 品质为R(Color == 3)的后勤卡进入材料列表
            if value:Color() < 4 and value:EnhanceLevel() == 1 then
                table.insert(tbNoCanStackCost,value)
            end
        end
        if #tbCanStackCost>0 then
            return tbCanStackCost
        else
            return tbNoCanStackCost
        end
    end

    if #GetCanCost(AllCost) == 0 then
        UI.ShowTip(Text('tip.once_materal_not_enough'))
        return
    end

    --- 模拟升级的数据需求(等级，经验和金币)
    local CurMaxLv = Item.GetMaxLevel(self.LogiCard)
    local  CurLv = self.LogiCard:EnhanceLevel()
    local CurMoney = Cash.GetMoneyCount(Cash.MoneyType_Silver)
    local nNeedExp = 0
    while CurMaxLv > CurLv do
        nNeedExp = nNeedExp + Item.GetExp(Item.TYPE_SUPPORT,CurLv)
        CurLv = CurLv + 1
    end
    
    --- 减去当前已有的经验值
    nNeedExp = nNeedExp - self.LogiCard:Exp()

    --- 等级经验模拟
    local tbCostMat = {}
    
    local nTarExp = nNeedExp
    for index, value in ipairs(GetCanCost(AllCost)) do
        local nCount = 0
        
        while nTarExp>0 and value:Count()>nCount and CurMoney - value:ConsumeGold() > 0 do
            nCount = nCount + 1
            nTarExp = nTarExp - (value:ProvideExp())
            CurMoney = CurMoney - value:ConsumeGold()
        end

        if nCount >= 1 then
            table.insert(tbCostMat,{value,nCount})
        end
    end

    if #tbCostMat <= 0 then
        self.tbSelectItem = {}
        self:TryShowSelect()
        self:UpDate()
        UI.ShowTip('tip.gold_not_enough')
        return
    end

    for _, value in pairs(tbCostMat) do
        self:UpdateSelectMat(value[1], value[2], true)
    end

    self.TxtOneKey:SetText(Text('TxtOneCancle'))
    self:UpDate()

    self:TryShowSelect()
end

function LogisUp:SetOneKeyText(InSelect)
    if InSelect == 0 then
        self.TxtOneKey:SetText(Text('TxtOneKey'))
        return
    end
    self.TxtOneKey:SetText(Text('TxtOneCancle'))
end

---重新生成才材料数据
function LogisUp:TryShowSelect()
    if not self.bShowSelect then return end
    self.tbCacheCostTbParam = self:GetTbParam() or {}
    local pSelect = self.Select
    pSelect:Show(self.tbCacheCostTbParam, function()
        EventSystem.TriggerTarget(Logistics, "PushOrMoveTitleEvent", false)
        WidgetUtils.Collapsed(pSelect)
        self.bShowSelect = false
    end)
end
--------------------------------------------------------
------------------------Break---------------------------
--- 突破初始化
function LogisUp:OpenBreachPanel()
    self:BreachCost()
    self:BreachAttrList(self.LogiCard)
    self:BreachTxtDes(self.LogiCard)
    self:SetStar(self.LogiCard:Break(),'s_')
    self.TxtArmsBreach:SetText(Text("break"))
    local BreakLimit = Item.GetBreakDemandLevel(self.LogiCard, self.LogiCard:Break() + 1)
    if me:Level() < BreakLimit then
        WidgetUtils.SelfHitTestInvisible(self.PanelTips)
        self.TextBlock_146:SetText(string.format(Text("ui.TxtUserLevelLimit"), BreakLimit))
    end
end

function LogisUp:BreachCost()
    self.nBreakCostMonsy = 0
    -- 需要优化为配置的
    local Items = RBreak.GetBreakMat(self.LogiCard)
    self:DoClearListItems(self.ListBreachItem)
    
    for index, value in ipairs(Items) do
        local nNow = me:GetItemCount(value[1], value[2], value[3], value[4])
        local pTemplate = UE4.UItem.FindTemplate(value[1], value[2], value[3], value[4])
        local tbParam ={
                        G = value[1],
                        D = value[2],
                        P = value[3],
                        L = value[4],
                        N = value[5],
                        nNeedNum = value[5],
                        nNum = nNow,}
        local NewItem = self.Factory:Create(tbParam)
        self.nBreakCostMonsy = self.nBreakCostMonsy + pTemplate.ConsumeGold*value[5]
        self.ListBreachItem:AddItem(NewItem)
    end
    self:BreachMoney(self.nBreakCostMonsy)
end

function LogisUp:BreachTxtDes(InSupportCard)
    --- 等级描述
    self.TxtLevelLimit:SetText("TxtLevelLimit")
    self.TxtNum:SetText(InSupportCard:EnhanceLevel())
    local nMaxLv = Logistics.GetMaxLv(InSupportCard, InSupportCard:Quality()+1)
    self.TxtAddNum:SetText(nMaxLv)
end

function LogisUp:BreachAttrList(InSupportCard)
    self:DoClearListItems(self.ListBreachAtt)
    local subAttr = Logistics.GetSubAttr(InSupportCard)
    if subAttr then
        local nNow = subAttr.Attr
        local nNew = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr(subAttr.sType, InSupportCard, InSupportCard:EnhanceLevel(), InSupportCard:Break() + 2)
        if tonumber(nNow) > 0 then
            local tbParam = { 
                sName = Text(string.format("attribute.%s",subAttr.sType)), 
                nNow = nNow, 
                nAdd = tonumber(nNew), -- - tonumber(nNow),
                ECate = subAttr.sType,
                IsPercent = subAttr.IsPercent,
                bSubAttr = true,}
            local NewObj = self.ItemFactory:Create(tbParam)
            self.ListBreachAtt:AddItem(NewObj)
        end
    end
end

function LogisUp:BreachMoney(InMoney)
    if not InMoney or InMoney == 0  then
        self.TxtBreachMoney:SetText('')
    else
        self.TxtBreachMoney:SetText(InMoney)
    end
    if InMoney and InMoney > Cash.GetMoneyCount(Cash.MoneyType_Silver) then
        self.TxtBreachMoney:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1,0,0,1))
    else
        self.TxtBreachMoney:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0,0,0,1))
    end
end

--- 立绘
function LogisUp:CheckBanner2d()
    EventSystem.TriggerTarget(Logistics, "SetSupportTexture", self.LogiCard)
end

--------------------------------------------------------
-----------------------MaxLevel---------------------------


--- 最高等级显示初始化
function LogisUp:OpenMaxLevelPanel()
    --- 等级描述
    self.EXPMAX_1:Set(self.LogiCard, 0,Item.TYPE_SUPPORT)
    self.EXPMAX:Set(self.LogiCard, 0,Item.TYPE_SUPPORT)
    --- 等级属性
    self:MaxLvAttrs(self.LogiCard)
    --- 星级属性
    self:SetStar(self.LogiCard:Break(),'maxs')
    
end

--- 最大等级属性展示
function LogisUp:MaxLvAttrs(InSupportCard)
    WidgetUtils.Collapsed(self.Attr1_1)
    WidgetUtils.Collapsed(self.SubAttr1_1)
    WidgetUtils.Collapsed(self.Attr1)
    WidgetUtils.Collapsed(self.SubAttr1)
    WidgetUtils.Collapsed(self.Attr2_1)
    WidgetUtils.Collapsed(self.SubAttr2_1)
    WidgetUtils.Collapsed(self.Attr2)
    WidgetUtils.Collapsed(self.SubAttr2)
    local MainAttrList = Logistics.GetMainAttr(InSupportCard)
    local SubAttr = Logistics.GetSubAttr(InSupportCard)
    for _, MainAttr in pairs(MainAttrList) do
        local tbMainParam = {
            sName = Text(string.format('attribute.%s',MainAttr.sType)),
            nNow = MainAttr.Attr,
            ECate = MainAttr.sType,
            bMainAttr = true,
        }
        if self["Attr".._] then
            self["Attr".._]:Display(tbMainParam)
        end
        if self["Attr".._.."_1"] then
            self["Attr".._.."_1"]:Display(tbMainParam)
        end
        WidgetUtils.HitTestInvisible(self["Attr".._.."_1"])
        WidgetUtils.HitTestInvisible(self["Attr".._])
    end

    if SubAttr then
        local tbSubParam = {
            sName = Text(string.format('attribute.%s',SubAttr.sType)),
            nNow = SubAttr.Attr,
            ECate = SubAttr.sType,
            IsPercent = SubAttr.IsPercent,
            bSubAttr = true,
        }
        self.SubAttr1_1:Display(tbSubParam)
        self.SubAttr1:Display(tbSubParam)
        WidgetUtils.HitTestInvisible(self.SubAttr1)
        WidgetUtils.HitTestInvisible(self.SubAttr1_1)
    end
    self:UpdateAffixPanel(InSupportCard)
end

--- 星级展示
---@param nStar  interge 需要展示的Intem
function LogisUp:SetStar(nStar,InPreStr)
    for i = 1, 6 do
        local pw = self[InPreStr .. i]
        if pw then
            WidgetUtils.Collapsed(pw.ImgStarOff)
            WidgetUtils.Collapsed(pw.ImgStarNext)
            WidgetUtils.Collapsed(pw.ImgStar)
            if i <= nStar then
                WidgetUtils.SelfHitTestInvisible(pw.ImgStar)
            elseif i == nStar + 1 then
                WidgetUtils.SelfHitTestInvisible(pw.ImgStarNext)
            else
                WidgetUtils.SelfHitTestInvisible(pw.ImgStarOff)
            end
        end
    end
end
--------------------------------------------------------
------------------------词缀部分-------------------------

---初始化词缀点击事件
function LogisUp:InitAffixBtn()
    BtnAddEvent(self.Btn1, function()
        self:SetAffixBtnState(1)
    end)

    BtnAddEvent(self.Btn2, function()
        self:SetAffixBtnState(2)
    end)

    BtnAddEvent(self.BtnAffix, function()
        if self.OpenAffixPanel == 1 then
            if self.nAffixMatNeedNum > self.nAffixMatHaveNum then
                UI.ShowTip("tip.not_material_for_break")
                return
            end
            Logistics.Req_ResetAffix(self.LogiCard, self.affixCostCfg, function()
                self:UpdateAffixPanel(self.LogiCard)
                self:SetAffixBtnState()
                self.TxtArmsBreach_1:SetText(Text("TxtAffixSelect"))
            end)
        elseif self.OpenAffixPanel == 2 then
            if not self.SelectAffix then
                return
            end

            if self.SelectAffix == 1 then
                Logistics.Req_SelectAffix(self.LogiCard, false, function()
                    self:UpdateAffixPanel(self.LogiCard)
                    UI.ShowTip(Text('tip.refineFinish'))
                    self.SelectAffix = nil
                    self.TxtArmsBreach_1:SetText(Text("TxtClear"))
                end)
            elseif self.SelectAffix == 2 then
                Logistics.Req_SelectAffix(self.LogiCard, true, function()
                    self:UpdateAffixPanel(self.LogiCard)
                    UI.ShowTip(Text('tip.refineFinish'))
                    self.SelectAffix = nil
                    self.TxtArmsBreach_1:SetText(Text("TxtClear"))
                end)
            end
        end
    end)

    self.check1.OnCheckStateChanged:Add(
        self,
        function(_, isChecked)
            if isChecked then
                self:SetAffixBtnState(1)
            else
                self:SetAffixBtnState(3)
            end
        end
    )

    self.check2.OnCheckStateChanged:Add(
        self,
        function(_, isChecked)
            if isChecked then
                self:SetAffixBtnState(2)
            else
                self:SetAffixBtnState(3)
            end
        end
    )
end

---刷新词缀界面
function LogisUp:UpdateAffixPanel(InSupportCard)
    self.affix3Value = InSupportCard:GetAffix(3)
    self.affix4Value = InSupportCard:GetAffix(4)
    if self.affix3Value:Length() <= 0 and self.affix3Value:Get(1) ~= 0 and self.affix3Value:Get(2) ~= 0 then
        WidgetUtils.Collapsed(self.PanelAddItem)
        WidgetUtils.Collapsed(self.PanelChange)
        return
    end
    self:UpdateAffixResetMat(InSupportCard)
    self.txtinfo:SetText(Logistics.GetAffixShowNameByTarray(self.affix3Value))
    if self.affix4Value and self.affix4Value:Length() > 0 and self.affix4Value:Get(1) ~= 0 and self.affix4Value:Get(2) ~= 0 then
        self.OpenAffixPanel = 2
        self:SetAffixPanelState(2)
        self.txtinfo_2:SetText(Logistics.GetAffixShowNameByTarray(self.affix4Value))
        self.txtinfo_5:SetText(Logistics.GetAffixShowNameByTarray(self.affix4Value))
        self.txtinfo_3:SetText(Logistics.GetAffixShowNameByTarray(self.affix3Value))
        self.txtinfo_4:SetText(Logistics.GetAffixShowNameByTarray(self.affix3Value))
    else
        self.OpenAffixPanel = 1
        self:SetAffixPanelState(1)
    end
end

---刷新词缀材料
function LogisUp:UpdateAffixResetMat(InSupportCard)
    local sGDPL = string.format("%s-%s-%s-%s", InSupportCard:Genre(), InSupportCard:Detail(), InSupportCard:Particular(), InSupportCard:Level())
    local cfg = Logistics.tbLogiData[sGDPL].AffixCost
    self.affixCostCfg = cfg
    self.nAffixMatNeedNum = cfg[5]
    self.nAffixMatHaveNum = me:GetItemCount(cfg[1], cfg[2], cfg[3], cfg[4])
    self.Itemadd:Display({ G = cfg[1], D = cfg[2], P = cfg[3], L = cfg[4], nNeedNum = self.nAffixMatNeedNum, nNum = self.nAffixMatHaveNum})
end

---词缀界面切换
---@param InState 词缀界面状态
function LogisUp:SetAffixPanelState(InState)
    if InState == 1 then
        WidgetUtils.SelfHitTestInvisible(self.PanelAddItem)
        WidgetUtils.Collapsed(self.PanelChange)
        -- self.txtinfo_1:SetText(string.format("%d/%d", self.nAffixMatHaveNum, self.nAffixMatNeedNum))
    elseif InState == 2 then
        WidgetUtils.SelfHitTestInvisible(self.PanelChange)
        WidgetUtils.Collapsed(self.PanelAddItem)
    end
end

function LogisUp:SetAffixBtnState(SelectBefore)
    if SelectBefore == 1 then
        WidgetUtils.SelfHitTestInvisible(self.Selected1)
        WidgetUtils.Collapsed(self.Selected2)
        WidgetUtils.SelfHitTestInvisible(self.InfoBg2)
        WidgetUtils.Collapsed(self.InfoBg1)
        WidgetUtils.Collapsed(self.txtinfo_3)
        WidgetUtils.SelfHitTestInvisible(self.txtinfo_2)
        WidgetUtils.Collapsed(self.Image_19)
        WidgetUtils.SelfHitTestInvisible(self.Image_17)
        self.Check1:SetIsChecked(true)
        self.Check2:SetIsChecked(false)
        self.SelectAffix = 1
    elseif SelectBefore == 2 then
        WidgetUtils.SelfHitTestInvisible(self.Selected2)
        WidgetUtils.Collapsed(self.Selected1)
        WidgetUtils.SelfHitTestInvisible(self.InfoBg1)
        WidgetUtils.Collapsed(self.InfoBg2)
        WidgetUtils.Collapsed(self.txtinfo_2)
        WidgetUtils.SelfHitTestInvisible(self.txtinfo_3)
        WidgetUtils.Collapsed(self.Image_17)
        WidgetUtils.SelfHitTestInvisible(self.Image_19)
        self.Check1:SetIsChecked(false)
        self.Check2:SetIsChecked(true)
        self.SelectAffix = 2
    else
        WidgetUtils.Collapsed(self.Selected1)
        WidgetUtils.Collapsed(self.Selected2)
        WidgetUtils.SelfHitTestInvisible(self.txtinfo_2)
        WidgetUtils.SelfHitTestInvisible(self.txtinfo_3)
        WidgetUtils.SelfHitTestInvisible(self.Image_17)
        WidgetUtils.SelfHitTestInvisible(self.Image_19)
        WidgetUtils.SelfHitTestInvisible(self.InfoBg2)
        WidgetUtils.SelfHitTestInvisible(self.InfoBg1)
        self.Check1:SetIsChecked(false)
        self.Check2:SetIsChecked(false)
    end
end

--------------------------------------------------------
------------------------跳转部分-------------------------
function LogisUp:GoToDaily()
    Launch.SetType(LaunchType.DAILY)
    Daily.SetID(7)
    Daily.SetChapterID(5)
    UI.Open("DungeonsSmap", 7)
end

--------------------------------------------------------
------------------------c2s-----------------------------
--- 升级req
function LogisUp:OnLvReq()
    self.nOldLevel = self.LogiCard:EnhanceLevel()
    local tbMat = {}
    for _, grid in pairs(self.tbSelectItem or {}) do
        table.insert(tbMat, {
            Id = grid.pItem:Id(),
            Num = grid.nNum or 0
        })
    end

    local nGold = 0
    for item, grid in pairs(self.tbSelectItem or {}) do
        nGold = grid.pItem:ConsumeGold() * grid.nNum + nGold
    end

    if nGold>Cash.GetMoneyCount(Cash.MoneyType_Silver) then
        UI.ShowTip("tip.gold_not_enough")
        return false
    end

    if #tbMat <= 0 then
        UI.ShowTip("tip.material_not_enough")
        return
    end

    if self.LogiCard:EnhanceLevel() >= Item.GetMaxLevel(self.LogiCard) then
        UI.ShowTip("tip.logistic_lv_limit_max")
        return
    end

    if self.LogiCard:EnhanceLevel() < Item.GetMaxLevel(self.LogiCard) then
        Logistics.Req_UpLogistics(
            self.LogiCard,
            tbMat,
            function()
                self.TxtOneKey:SetText(Text('TxtOneKey'))

                local nNewLevel = self.LogiCard:EnhanceLevel()
                self.EXP:Set(self.LogiCard, 0,Item.TYPE_SUPPORT)
                self:SetOneKeyText(0)
                ---等级发生变化提示
                if self.nOldLevel ~= nNewLevel then
                    UI.Open(self.tbBringSys[1].TipWidget, self.LogiCard, self.nOldLevel)
                    Audio.PlaySounds(3014)
                    -- UI.ShowTip('ui.UpdataLv_Ok')    
                else
                    UI.ShowTip('ui.UpdataLv_Ok')
                end

                self.tbSelectItem = {}
                for i = 1, MAX_MAT_DISPLAY_NUM do
                    local grid = self.tbMatGrid[i]
                    grid.pItem = nil
                    grid.nNum = 0
                    EventSystem.TriggerTarget(grid, 'ON_DATA_CHANGE')
                end

                self:TryShowSelect()
                self:ShowAttrChange()

                local MaxBreak = Logistics.GetBreakMax(self.LogiCard)
                if self.LogiCard:EnhanceLevel() >= Item.GetMaxLevel(self.LogiCard) then
                    if self.Select:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
                        EventSystem.TriggerTarget(Logistics, "PushOrMoveTitleEvent", false)
                        WidgetUtils.Collapsed(self.Select)
                    end
                    if self.LogiCard:EnhanceLevel()>=Logistics.GetMaxLv(self.LogiCard, MaxBreak) then
                        self:CheckChildSystem(3)
                        return
                    end
                    self:CheckChildSystem(2)
                    return
                end
                self.tbBringSys[1].CallFun()
            end
        )
    else
        if not Item.GetBreakMaterials(self.LogiCard) then
            UI.ShowTip("tip.logistics up Limit.")
            return
        end
        UI.CloseByName("LogiUp", nil, true)
        UI.Open("LogiBreak", self.LogiCard)
    end
end

---- 突破
function LogisUp:OnBreachReq()
    local CanBreak, Des = Item.CanBreak(self.LogiCard)
    if not CanBreak then
        UI.ShowTip(Des or "tip.BadParam")
        self:BreachMoney()
        return
    end
    Logistics.Req_BreakLogistics(
        self.LogiCard,
        function()
            self.tbMatGrid = {}
            self.tbSelectItem = {}
            self.bInitCostItem = false
            self.bShowSelect = false
            self.nBreakCostMonsy = 0
            self:CheckChildSystem(1)
            self.tbBringSys[1].CallFun()
            self:CheckBanner2d()
            UI.ShowTip("tip.logistic break ok")
            UI.Open(self.tbBringSys[2].TipWidget, self.LogiCard)
            Audio.PlaySounds(3014)
        end
    )
end

function LogisUp:OnDisable()
    Logistics.tbConsumes = {}
    -- self.tbSelectItem = {}
    -- self.bShowSelect = false
    if UI.IsOpen('ItemInfo') then
        UI.Close('ItemInfo')
    end
end

function LogisUp:OnDestruct()
    self:RemoveRegisterEvent()
end

return LogisUp
