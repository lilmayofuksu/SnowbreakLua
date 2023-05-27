-- ========================================================
-- @File    : uw_arms_up_lvup.lua
-- @Brief   : 武器升级
-- ========================================================

---显示材料格子数
local DEFAULT_GRID_NUM = 6
local nShowGridNum = 0

---@class tbClass
---@field pWeapon UWeaponItem
---@field ListLevelItem UListView 材料列表
---@field TxtCostMoney UTextBlock
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.bInitScreen = false
    BtnAddEvent(self.BtnUp, function() self:DoLvUp() end)
    BtnAddEvent(self.BtnOneKey, function() 
        if self.bOneKey then
           local bs =  self:OneKeySelect()
           if not bs then return end
        else
            self:OneKeyCancel()
        end
        self.bOneKey = not self.bOneKey
        self:UpdateOneKeyState()
    end)
    self.ListLevelItem:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.ListFactory = Model.Use(self)

    local nIcon, _, _ = Cash.GetMoneyInfo(Cash.MoneyType_Silver)
    SetTexture(self.ImgMoney, nIcon)

    BtnAddEvent(self.BtnMethod, function()
        Daily.OpenByID(3)
    end)
 end

 function tbClass:OnDestruct()
 end


 function tbClass:OnActive(pWeapon, pParent, nReason)
    ---从养成界面跳转到关卡界面，再直接跳转回来，还是保留这部分道具；如果跳转到关卡后，进入关卡战斗，会清掉这部分道具选择
    if nReason == 1 and self.pWeapon == pWeapon then
        return
    end

     self.pWeapon = pWeapon
     self.pParent = pParent
     if not self.pWeapon then return end

    self:InitSort()
    
    self.bOneKey = true
    self:UpdateOneKeyState()
    
    ---缓存材料格子数据
    self.tbMatGrid = {}
    self.tbSelectItem = {}
    self:InitCostGrid()

    self:Update()
    ---缓存等级
    self.nCacheLevel = self.pWeapon:EnhanceLevel()
 end

 function tbClass:InitSort()
    self.bShowSelect = false
    ---排序处理
    self.tbCurSort = {nIdx = 1, bReverse = true}
    -- 排序
    self.tbSortParam = {}
    self.tbSortParam.tbSortInfos = {}
    self.tbSortParam.tbSortInfos[1] = {
       {
           tbSorts = ItemSort.WeaponLevelSort,
           sName = "ui.item_level"
       },
       {
           tbSorts = ItemSort.WeaponColorSort,
           sName = "ui.TxtRareSort"
       },
       {
           tbSorts = ItemSort.WeaponExpSort,
           sName = "ui.TxtScreen14"
       },
      
   }

    self.tbSortParam.fSort = function(nIdx, bReverse)
        self.tbCurSort = {nIdx = nIdx, bReverse = bReverse}
        self:UpdateSelectInfo()
    end

    self.tbSortParam.bReverse = true
    self.tbSortInfo = self.tbSortParam.tbSortInfos
 end

 ---添加一个新的格子
 function tbClass:AddNewGrid()
    local nIndex = nShowGridNum + 1
    local tbParam = {
        fClick = function() if not self.bShowSelect then self:ShowSelect() end  end,
        pItem = nil,
        nNum = 0,
        nGridIndex = nIndex,
    }
    local pObj = self.ListFactory:Create(tbParam)
    self.tbMatGrid[nIndex] = tbParam
    self.ListLevelItem:AddItem(pObj)
    nShowGridNum = nIndex
    return tbParam
 end


 ---移除多余的格子
 function tbClass:RemoveOneGrid()
    local nIndex = nShowGridNum
    local pObj = self.ListLevelItem:GetItemAt(nIndex - 1)
    if pObj then
        self.ListLevelItem:RemoveItem(pObj)
    end
    self.tbMatGrid[nIndex] = nil
    nShowGridNum = nShowGridNum - 1
 end

 ---材料格子初始化
 function tbClass:InitCostGrid()
    self:DoClearListItems(self.ListLevelItem)
    nShowGridNum = 0
    for i = 1, DEFAULT_GRID_NUM do
        self:AddNewGrid()
    end
 end

 ---更新OneKey State
 function tbClass:UpdateOneKeyState()
    local sTxt = self.bOneKey and 'TxtOneKey' or 'TxtOneCancle'
    self.TxtOneKey:SetText(sTxt)
 end

---更新UI显示信息
 function tbClass:Update()
    ---增加经验显示
    local nAddExp, nGold, nCount = self:CalcSelectExp()

    self.EXP:Set(self.pWeapon, math.floor(nAddExp))

    local nSilver = Cash.GetMoneyCount(Cash.MoneyType_Silver)
    if nSilver < nGold then
        Color.SetTextColor(self.TxtCostMoney, 'FF0000FF')
    else
        Color.SetTextColor(self.TxtCostMoney, '03061FFF')
    end

    self.TxtCostMoney:SetText(nGold)

    WidgetUtils.Collapsed(self.TxtNumber)
    self.TxtNumber:SetText(nCount)

    if nCount <=0 then
        self.nCacheLevel = self.pWeapon:EnhanceLevel()
    end

    local nLevel, nDestExp = Item.GetItemDestLevel(self.pWeapon:EnhanceLevel(), self.pWeapon:Exp(), nAddExp, Item.TYPE_WEAPON, Item.GetMaxLevel(self.pWeapon))

    local sNow = UE4.UItemLibrary.GetWeaponAbilityValueToStr(UE4.EWeaponAttributeType.Attack, self.pWeapon)
    local sNew = UE4.UItemLibrary.GetWeaponAbilityValueToStr(UE4.EWeaponAttributeType.Attack, self.pWeapon, nLevel)

    ---霰弹枪
    if self.pWeapon:Detail() == 3 then
        WidgetUtils.HitTestInvisible(self.IText_Num)
        local nLaunch = TackleDecimal(tonumber(UE4.UItemLibrary.GetCharacterCardAbilityValueByStr('BulletLaunchCount', self.pWeapon)))
        sNow = TackleDecimal(tonumber(sNow)) * nLaunch
        sNew = TackleDecimal(tonumber(sNew)) * nLaunch
    end 

    sNew = nLevel > self.pWeapon:EnhanceLevel() and sNew or nil

    local sKey = UE4.UUMGLibrary.GetEnumValueAsString("EWeaponAttributeType", UE4.EWeaponAttributeType.Attack)
    local IconId = Resource.GetAttrPaint(sKey)
    self.MainAtt:SetWeaponAttr(IconId , Text(string.format("attribute.%s", sKey)), sNow, sNew)

    self.Partslock:Set(self.pWeapon, true)
 end

 ---显示选择材料界面
 function tbClass:ShowSelect()
    self.bShowSelect = true
    local pSelect = self.pParent:ShowSelect()
    if pSelect then
        if not self.bInitScreen and pSelect.Screen then
            pSelect.Screen:Init(self.tbSortParam)
            pSelect.TxtAllEmpty:SetText(Text('ui.TxtAllEmpty'))
            self.bInitScreen = true
            WidgetUtils.SelfHitTestInvisible(pSelect.Screen)
        end

        WidgetUtils.SelfHitTestInvisible(pSelect)
        self.tbCacheCostTbParam = self:GetTbParam() or {}
        pSelect:Show(self.tbCacheCostTbParam, function()
            self:CloseSelect()
        end)

        UI.Call2('Arms', 'PushEvent', function()
            self:CloseSelect()
        end)
    end
 end

 ---关闭材料选择界面
 function tbClass:CloseSelect()
    UI.Call2('Arms', 'ClearPushEvent')
    self.pParent:CloseSelect()
    self.bShowSelect = false
 end


 ---刷新选择
 function tbClass:UpdateSelectInfo()
    if self.bShowSelect then self:ShowSelect() end
 end

 ---添加消耗处理
 function tbClass:AddItem(pItem, nNum)
    if not self:Check(pItem, nNum) then return false end
    self:UpdateSelectMat(pItem, nNum)
    return true
 end

 ---减少消耗处理
 function tbClass:SubItem(pItem, nNum)
    self:UpdateSelectMat(pItem, nNum)
 end

 ---获取消耗材料
 function tbClass:GetTbParam()
    local tbSortInfo = self.tbSortInfo[1][self.tbCurSort.nIdx or 1]
    tbSortInfo.bReverse = self.tbCurSort.bReverse or false

    local tbCost = Weapon.GetSecgradeByGDPL(self.pWeapon, false, tbSortInfo)

    local tbRet = {}
    for _, pItem in ipairs(tbCost) do
        table.insert(tbRet, {
            pItem = pItem,
            nNum = self.tbSelectItem[pItem] and self.tbSelectItem[pItem].nNum or 0 or 0,
            bCanStack = pItem:CanStack(),
            fAdd = function(item, n) return self:AddItem(item, n)  end,
            fSub = function(item, n) self:SubItem(item, n) end,
        })
    end
    return tbRet
 end

 ---计算选择了的经验
 function tbClass:CalcSelectExp()
    local nAddExp = 0
    local nCount = 0
    local nGold = 0

    for pItem, grid in pairs(self.tbSelectItem or {}) do
        local nProvideExp , nConsumeGold = self:CalcExpGold(pItem)
        nAddExp = nAddExp + grid.nNum * nProvideExp
        nCount = nCount + 1
        nGold = nGold + nConsumeGold * (grid.nNum or 0)
    end
    nGold = math.max(0, nGold)
    return nAddExp, nGold, nCount
 end

 function tbClass:CalcExpGold(pItem)
    if not pItem then return 0, 0 end
    local nAddExp, nGold = pItem:ProvideExp(), pItem:ConsumeGold()
    if pItem:IsWeapon() then
        local exp, gold = Item.GetExpAndSilverNum(pItem)
        nAddExp = nAddExp + exp
        nGold = nGold - gold
    end
    return nAddExp, nGold
 end


 ---检查
 function tbClass:Check(pItem, nNum)
    local nAddExp, nGold, nCount = self:CalcSelectExp()
    local nMaxLevel = Item.GetMaxLevel(self.pWeapon)
    local nPreLevel, nPreDestExp = Item.GetItemDestLevel(self.pWeapon:EnhanceLevel(), self.pWeapon:Exp(), nAddExp, Item.TYPE_WEAPON, nMaxLevel)
    if nPreLevel >= nMaxLevel then  UI.ShowTip('tip.weapon_max_level') return false end
    return true
 end

 ---更新材料格子显示
 function tbClass:UpdateSelectMat(pItem, nNum)
    local grid = nil
    local bAdd = self.tbSelectItem[pItem] == nil
    if bAdd then
        grid = self:GetEmptyGrid()
        if grid == nil then  return end
        self.tbSelectItem[pItem] = grid
        grid.pItem = pItem
    else
        grid = self.tbSelectItem[pItem]
    end
    if grid == nil then return end
    if nNum <= 0 then
        grid.nNum = 0;
        self.tbSelectItem[pItem] = nil
        grid.pItem = nil
        ---重新排列格子
        self:ReArrange()
    else
        grid.nNum = nNum
        EventSystem.TriggerTarget(grid, 'ON_DATA_CHANGE')
    end
    self:Update()
 end

 ---重新排列
 function tbClass:ReArrange()
    local tb = {}
    for i = 1, nShowGridNum do
       local grid = self.tbMatGrid[i]
        if grid.pItem then table.insert(tb, {pItem = grid.pItem, nNum = grid.nNum or 0 }) end
        grid.pItem = nil
        grid.nNum = 0
    end

    local nEmptyNum = 0
    
    for i = 1, nShowGridNum do
        local grid = self.tbMatGrid[i]
        local tbCache = tb[i]
        grid.pItem = tbCache and tbCache.pItem or nil
        grid.nNum = tbCache and tbCache.nNum or 0
        if grid.pItem then
            self.tbSelectItem[grid.pItem] = grid
        end
        if grid.nNum <= 0 then
            nEmptyNum = nEmptyNum + 1
        end
        EventSystem.TriggerTarget(grid, 'ON_DATA_CHANGE')
     end

     if nEmptyNum > 1 and nShowGridNum > DEFAULT_GRID_NUM then
        self:RemoveOneGrid()
     end
 end

 ---获取一个空闲的格子
 function tbClass:GetEmptyGrid()
    local nLeftNum = 0
    local retGrid = nil
    for _, grid in ipairs(self.tbMatGrid or {}) do
        if grid.nNum <= 0 then
            retGrid = retGrid or grid
            nLeftNum = nLeftNum + 1
        end
    end
    if nLeftNum < 2 then
        local tbParam = self:AddNewGrid()
        if not retGrid then retGrid = tbParam end
    end
    return retGrid
 end

 ---一键取消
 function tbClass:OneKeyCancel()
    self.tbSelectItem = {}
    
    for i = 1, nShowGridNum do
        local grid = self.tbMatGrid[i]
        grid.pItem = nil
        grid.nNum = 0
        EventSystem.TriggerTarget(grid, 'ON_DATA_CHANGE')
    end

    
    while(nShowGridNum > DEFAULT_GRID_NUM)
    do
        self:RemoveOneGrid()
    end

    self:UpdateSelectInfo()
    self:Update()
 end

 ---一键选择
 function tbClass:OneKeySelect()
    local tbAllCost = Weapon.GetSecgradeByGDPL(self.pWeapon, true, nil)
    ---材料不足提示
    if #tbAllCost <= 0 then UI.ShowTip('tip.once_materal_not_enough') return false end
    local fillSelect = self:Fill(tbAllCost) or {}
    local nFillNum = #fillSelect
    if nFillNum <= 0 then UI.ShowTip('tip.gold_not_enough') return false end
    self.tbSelectItem = {}
     local nOldNum = nShowGridNum

     if nOldNum < nFillNum then
        for i = nOldNum, nFillNum do
            self:AddNewGrid()
        end
    end

     ---先清空
     for i = 1, nShowGridNum do
        local grid = self.tbMatGrid[i]
        grid.pItem = nil
        grid.nNum = 0
     end


     for i = 1, nShowGridNum do
        local grid = self.tbMatGrid[i]
        local tbInfo = fillSelect[i]
        if tbInfo == nil then break end
        grid.pItem = tbInfo.pItem
        self.tbSelectItem[tbInfo.pItem] = grid
        grid.nNum = tbInfo.nNum
     end

     for i = 1, nShowGridNum do
        local grid = self.tbMatGrid[i]
        EventSystem.TriggerTarget(grid, 'ON_DATA_CHANGE')
     end

     self:UpdateSelectInfo()
     self:Update()
     return true
 end

 function tbClass:Fill(tbAllCost)
    table.sort(tbAllCost, function(a, b)  if  a:Color() ~= b:Color() then  return a:Color() > b:Color()  end  return a:Id() < b:Id() end)
    local nMaxLevel = Item.GetMaxLevel(self.pWeapon)
    local nHaveGold = Cash.GetMoneyCount(Cash.MoneyType_Silver)

    local tbSelect = {}
    local nExp , nGold, nMinLeftExp , nMinLeftIndex = 0, 0 , 0 , 0

    for idx, pItem in ipairs(tbAllCost) do
        local nCount = pItem:Count()
        for i = 1, nCount do
            ---金币足够
            local nProvideExp , nConsumeGold = self:CalcExpGold(pItem)

            local nNewExp, nNewGold = nExp + nProvideExp, nGold + nConsumeGold
            if nHaveGold < nNewGold then
                break
            end
            local nLevel, nDestExp = Item.GetItemDestLevel(self.pWeapon:EnhanceLevel(), self.pWeapon:Exp(), nNewExp, Item.TYPE_WEAPON, nMaxLevel)
            if nLevel >= nMaxLevel and nDestExp > 0 then
                if nMinLeftExp > nDestExp or nMinLeftExp == 0 then
                    nMinLeftExp = nDestExp
                    nMinLeftIndex = idx
                end
                break
            end
            nGold = nNewGold
            nExp = nNewExp
            tbSelect[pItem] = i
            self.nCacheLevel = nLevel
        end
    end

    local minItem = tbAllCost[nMinLeftIndex]
    if minItem then
        local nProvideExp , nConsumeGold = self:CalcExpGold(minItem)
        local nNewExp, nNewGold = nExp + nProvideExp, nGold + nConsumeGold
        ---金币足够
        if nHaveGold > nNewGold then
            tbSelect[minItem] = tbSelect[minItem] or 0
            if minItem:Count() >= tbSelect[minItem] then
                tbSelect[minItem] = tbSelect[minItem] + 1
            end
        end
    end

    local tbRet = {}
    for pItem, nNum in pairs(tbSelect) do
        table.insert(tbRet, {pItem = pItem, nNum = nNum})
    end
    table.sort(tbRet, function(a, b) return a.pItem:Color() > b.pItem:Color() end)

    return tbRet
 end

 ---请求升级
function tbClass:DoLvUp()
    if not self.pWeapon then return end
    if Weapon.IsMaxLevel(self.pWeapon) then UI.ShowTip("tip.weapon_max_level") return end

    ---缓存升级前的等级
    self.nOldLevel = self.pWeapon:EnhanceLevel()

    --[[
        在武器升级的时候，如果放入稀有度较高的武器（金色、紫色）或者经过了强化的武器，点击升级的时候，会出现一个弹窗，让玩家进行二次确认
        选择经过了强化的武器
        提示：所选武器已强化，是否确定使用所选武器作为材料消耗？
        选择金色/紫色武器
        提示：所选武器稀有度较高，是否确定使用所选武器作为材料消耗？
        选择金色/紫色且经过了强化的武器
        提示：所选武器已强化、稀有度较高，是否确定使用所选武器作为材料消耗？

    ]]

    local bUp = false
    local bRare = false
    local tbMat = {}

    for _, grid in pairs(self.tbSelectItem or {}) do
        local pItem = grid.pItem
        if pItem then
            if pItem:IsWeapon() then
                if pItem:EnhanceLevel() > 1 then
                    bUp = true
                end
    
                if pItem:Color() > 3 then
                    bRare = true
                end
            end
            table.insert(tbMat, { Id = pItem:Id(), Num = grid.nNum or 0 })
        end
     end

    if #tbMat <= 0 then UI.ShowTip("tip.material_not_enough") return end

    local sTip = ''
    if bUp and bRare then
        sTip = 'ui.TxtArmsUpgradeConfirm3'
    elseif bUp then
        sTip = 'ui.TxtArmsUpgradeConfirm1'
    elseif bRare then
        sTip = 'ui.TxtArmsUpgradeConfirm2'
    end

    local fUp = function()
        print('Weapon LevelUp Req')
        Weapon.Req_Upgrade(self.pWeapon, tbMat)
    end

    if sTip ~= '' then
        UI.OpenMessageBox(false, Text(sTip), function()
            fUp()
        end, function()
        end)
    else
        fUp()
    end
end

function tbClass:OnRsp(bMaxUnLock)
    print('Weapon LevelUp OnRsp', bMaxUnLock)
    local nNewLevel = self.pWeapon:EnhanceLevel()
    ---等级发生变化
    if self.nOldLevel ~= nNewLevel then
        UI.Open("WeaponLvUp", self.pWeapon, self.nOldLevel, function()
            if bMaxUnLock then
                UI.Open('ArmsUnlockTip', Weapon.GetMaxLvPart(self.pWeapon))
            end

        end)  
    else
        UI.ShowTip('tip.weapon_level_up')
    end
    self.tbSelectItem = {}
    for i = 1, nShowGridNum do
        local grid = self.tbMatGrid[i]
        grid.pItem = nil
        grid.nNum = 0
        EventSystem.TriggerTarget(grid, 'ON_DATA_CHANGE')
     end
    self:UpdateSelectInfo()
    self:Update()
    self.bOneKey = true
    self:UpdateOneKeyState()
    self.pParent:AutoPage()
end

return tbClass