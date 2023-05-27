-- ========================================================
-- @File    : umg_bag.lua
-- @Brief   : 仓库界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

-- 常量定义
tbClass.PAGE_WEAPON = 1 ---武器页面
tbClass.PAGE_SUPPORT = 2 ---后勤页面
tbClass.PAGE_ITEM = 3 ---道具页面
tbClass.PAGE_PART = 4 ---配件页面
tbClass.PAGE_SUPLIES = 5 ---耗材页面

tbClass.MAX_SELL_COUNT = 1000

-- 各类道具所关心的装备槽
tbClass.tbEquipSlot = {}
tbClass.tbEquipSlot[UE4.EItemType.CharacterCard] = {
    UE4.ECardSlotType.Weapon,
    UE4.ECardSlotType.SupporterCard1,
    UE4.ECardSlotType.SupporterCard2,
    UE4.ECardSlotType.SupporterCard3
}
tbClass.tbEquipSlot[UE4.EItemType.Weapon] = {
    UE4.EWeaponSlotType.Muzzle,
    UE4.EWeaponSlotType.TopGuide,
    UE4.EWeaponSlotType.Butt,
    UE4.EWeaponSlotType.Ammunition,
    UE4.EWeaponSlotType.LowerGuide
}

---初始化
function tbClass:OnInit()
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.ListFunction)
    self:DoClearListItems(self.Support_list)
    self:DoClearListItems(self.Part_list)
    self:DoClearListItems(self.Suplies_list)
    self:DoClearListItems(self.Item_list)

    -- 各页面设置
    self.tbPage = {}
    self.tbPage[self.PAGE_WEAPON] = {
        tbTypes = {UE4.EItemType.Weapon},
        nIcon = 1701013,
        sTitle = 'ui.weapon',
        bCanSell = true,
        bCanStack = false,
        sEnhance = "ui.TxtEnhanceWeapon",
        fEnhance = function(pItem)
            UI.Open("Arms", 0, pItem)
        end
    }
    self.tbPage[self.PAGE_SUPPORT] = {
        tbTypes = {UE4.EItemType.SupporterCard},
        nIcon = 1701014,
        sTitle = 'ui.supporter',
        bCanSell = true,
        bCanStack = false,
        sEnhance = "ui.TxtEnhanceSupport",
        fEnhance = function(pItem)
            FunctionRouter.CheckEx(FunctionType.Logistics, function()
                UI.Open("Logistics", pItem)
            end)
        end
    }
    self.tbPage[self.PAGE_ITEM] = {
        tbTypes = {UE4.EItemType.Useable},
        nIcon = 1701015,
        sTitle = 'ui.supplies', 
        bCanSell = false,
        bCanStack = true,
        sEnhance = "TxtUse",
        fEnhance = function(pItem)
            UI.CloseByName("ItemInfo")

            --过期道具不让用 直接回收
            if pItem:Expiration() > 0 and pItem:Expiration() <= GetTime() then
                Item.Expiration({pItem})
                return
            end

            if Item.IsMonthlyCardBox(pItem) then
                local nDay = IBLogic.GetHasMonthlyDay()
                if nDay < IBLogic.GetMonthDay() then
                    local cmd = {
                        Id = pItem:Id(),
                        Count = 1,
                    }
                    me:CallGS("Item_OpenBox", json.encode(cmd))
                    self:UseItemCallBack(pItem, 1)
                else
                    UI.ShowTip(string.format(Text("tip.ExchangeMcard.fail"), nDay))
                end
            elseif Item.IsSelectBox(pItem) == true then 
                UI.Open("ItemSelectBox",pItem)
            elseif Item.IsItemBox(pItem) == true  then
                UI.Open("PurchaseEnergy","OpenBox",pItem)
            elseif Item.IsVigorItem(pItem) or Item.IsCashBox(pItem) then
                local info = UE4.UItem.FindTemplate(pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level())
                local tbInfo = {
                    tbExchange = {
                        G = pItem:Genre(),
                        D = pItem:Detail(),
                        P = pItem:Particular(),
                        L = pItem:Level(),
                        N = pItem:Count(),
                        pTemp = info,
                        pItem = pItem,
                    },

                    tbExhcangTarget = {
                        nCashID = Cash.MoneyType_Vigour,
                        nCount = info.Param1
                    },
                }

                if Item.IsCashBox(pItem) then
                    tbInfo.tbExhcangTarget.nCashID = info.Param1
                    tbInfo.tbExhcangTarget.nCount = info.Param2
                end

                if tbInfo.tbExchange.N > 0 then
                    tbInfo.tbExchange.nMaxCount = tbInfo.tbExchange.N
                else
                    tbInfo.tbExchange.nMaxCount = 1
                end

                tbInfo.nRate = 1
                tbInfo.bMutable = true
                
                UI.Open("PurchaseExchange", tbInfo)
            else
                UI.Open("PurchaseEnergy","UseItem",pItem)
            end
        end
    }
    self.tbPage[self.PAGE_PART] = {
        tbTypes = {UE4.EItemType.WeaponParts},
        nIcon = 1701016,
        sTitle = 'ui.weapon_part',
        bCanSell = false,
        bCanStack = false
    }
    self.tbPage[self.PAGE_SUPLIES] = {
        tbTypes = {UE4.EItemType.Suplies},
        nIcon = 1701078,
        sTitle = 'ui.item',
        bCanSell = false,
        bCanStack = true
    }

    -- 标签页按钮
    local funNewTab = function(nPage)
        local tbTab = {
            nPage = nPage,
            nIcon = self.tbPage[nPage].nIcon,
            sTitle = self.tbPage[nPage].sTitle
        }
        local pObj = self.Factory:Create(tbTab)
        pObj.ParentUI = self
        self.ListFunction:AddItem(pObj)
        return pObj
    end
    self.tbPage[self.PAGE_WEAPON].pTab = funNewTab(self.PAGE_WEAPON)
    self.tbPage[self.PAGE_SUPPORT].pTab = funNewTab(self.PAGE_SUPPORT)
    self.tbPage[self.PAGE_ITEM].pTab = funNewTab(self.PAGE_ITEM)
    self.tbPage[self.PAGE_PART].pTab = funNewTab(self.PAGE_PART)
    self.tbPage[self.PAGE_SUPLIES].pTab = funNewTab(self.PAGE_SUPLIES)

    -- 排序
    self.tbSortInfo = {}
    self.tbSortInfo[self.PAGE_WEAPON] =
    {
        tbSort = { 
            sDesc = 'ui.TxtScreen1', 
            tbRule={
                {'ui.TxtRareSort', ItemSort.BagWeaponQualitySort},
                {'ui.item_level', ItemSort.BagWeaponLevelSort},
                {'ui.TxtScreen2', ItemSort.BagItemIdSort}
            }
        },
    
        --{sDesc:标题文字，rule:筛选类型, tbRule:筛选子项 }
        tbFilter = {
            { 
                sDesc='ui.TxtScreen6', 
                rule=4, 
                tbRule={
                    {'weapon.type_1', 1}, 
                    {'weapon.type_2', 2}, 
                    {'weapon.type_3', 3}, 
                    {'weapon.type_4', 4}, 
                    {'weapon.type_5', 5}
                } 
            },

            { 
                sDesc='ui.TxtScreen7', 
                rule=5, 
                tbRule={
                    {'ui.DamageType.3', 3},
                    {'ui.DamageType.4', 4}, 
                    {'ui.DamageType.5', 5}, 
                    {'ui.DamageType.6', 6}, 
                    {'ui.DamageType.7', 7}
                }
            },
        }
    }

    self.tbSortInfo[self.PAGE_SUPPORT] =
    {
        tbSort = { 
            sDesc = 'ui.TxtScreen1', 
            tbRule = { 
                {'ui.TxtRareSort', ItemSort.BagSupportQualitySort}, 
                {'ui.item_level', ItemSort.BagSupportLevelSort}, 
                {'ui.TxtScreen2', ItemSort.BagItemIdSort} 
            } 
        },
    
        --{sDesc:标题文字，rule:筛选类型, tbRule:筛选子项 }
        tbFilter = {
            { 
                sDesc='ui.TxtScreen6', 
                rule=4, 
                tbRule={
                    {'ui.technology', 1}, 
                    {'ui.medicalcare', 2}, 
                    {'ui.equip', 3}
                } 
            },
            { 
                sDesc='ui.TxtScreen8', 
                rule=6, 
                tbRule=Logistics.GetSuitSkillList() 
            },
        }
    }

    self.tbSortInfo[self.PAGE_ITEM] =
    {
        tbSort = { 
            sDesc = 'ui.TxtScreen1', 
            tbRule = { 
                {'ui.TxtRareSort', ItemSort.BagItemQualitySort},
            }
        },
    }

    self.tbSortInfo[self.PAGE_PART] =
    {
        tbSort = { 
            sDesc = 'ui.TxtScreen1', 
            tbRule = { 
                {'ui.TxtRareSort', ItemSort.BagWeaponPartQualitySort}, 
            } 
        },
    
        --{sDesc:标题文字，rule:筛选类型, tbRule:筛选子项 }
        tbFilter = {
            { 
                sDesc='ui.TxtScreen3', 
                rule=7, 
                tbRule={ 
                    {'weapon.type_1', 1},
                    {'weapon.type_2', 2},
                    {'weapon.type_3', 3},
                    {'weapon.type_4', 4},
                    {'weapon.type_5', 5},
                } 
            },
            { 
                sDesc='ui.TxtScreen9', 
                rule=4,
                tbRule={
                    {'ui.weapon_part_1', 1},
                    {'ui.weapon_part_2', 2},
                    {'ui.weapon_part_4', 4},
                    {'ui.weapon_part_5', 5},
                } 
            },
        }
    }

    self.tbSortInfo[self.PAGE_SUPLIES] = 
    {
        tbSort = { 
            sDesc = 'ui.TxtScreen1', 
            tbRule = { 
                {'ui.TxtRareSort', ItemSort.BagItemQualitySort},
            } 
        },
    
        --{sDesc:标题文字，rule:筛选类型, tbRule:筛选子项 }
        tbFilter = {
            { 
                sDesc='ui.TxtScreen6', 
                rule=8,
                tbRule={ 
                    {'ui.TxtScreen10', 1},
                    {'ui.TxtScreen11', 2},
                    {'ui.TxtScreen12', 3},
                    {'ui.TxtScreen13', 4},
                    {'ui.TxtBanType0', 5},
                } 
            },
        }
    }

    
    --各分页的排序设置单独保存
    self.tbCurSort = self.tbCurSort or {}
    self.tbCurSort[self.PAGE_WEAPON] = self.tbCurSort[self.PAGE_WEAPON] or {tbSort={1, false},tbFilter=nil}
    self.tbCurSort[self.PAGE_SUPPORT] = self.tbCurSort[self.PAGE_SUPPORT] or {tbSort={1, false},tbFilter=nil}
    self.tbCurSort[self.PAGE_ITEM] = self.tbCurSort[self.PAGE_ITEM] or {tbSort={1, false},tbFilter=nil}
    self.tbCurSort[self.PAGE_PART] = self.tbCurSort[self.PAGE_PART] or {tbSort={1, false},tbFilter=nil}
    self.tbCurSort[self.PAGE_SUPLIES] = self.tbCurSort[self.PAGE_SUPLIES] or {tbSort={1, false},tbFilter=nil}


    -- 出售
    BtnAddEvent(
        self.BtnSell,
        function()
            -- 检查是否含有可回收道具
            local bHave = false
            for nId, pListItem in pairs(self.tbListItems) do
                if
                    type(nId) == "number" and (not (self.tbItemInfo[nId] and self.tbItemInfo[nId].pEquipped)) and
                        (not pListItem.Data.pItem:HasFlag(Item.FLAG_LOCK))
                 then
                    bHave = true
                    break
                end
            end
            if not bHave then
                return UI.ShowTip("tip.sellable_not_exist")
            end
            self:SetSellPanel(true)
        end
    )


    BtnAddEvent(
        self.BtnScreen,
        function()
            if not UI.IsOpen('Screen') then
                UI.Open('Screen', self.tbSortInfo[self.nCurrentPage], self.tbCurSort[self.nCurrentPage],
                function()
                    self:OnOpen()
                end)
            end
        end
    )
    self:SetSellPanel(false)
    -- 道具信息面板
    -- self.Info:OnInit(true)
    -- self.Info.SetLock = function(pItem, bLock)
    --     me:CallGS("Item_SetLock", json.encode({ItemId = pItem:Id(), Lock = bLock}))
    -- end
end

---打开界面
---@param nPage integer 表示打开哪个页面，默认打开第一个
function tbClass:OnOpen(nPage)
    self:SetSellPanel(false)
    UI.CloseByName("ItemInfo")

    self:GetItemList()
    self:ShowRedDot()
    self:OpenPage(self.nCurrentPage or nPage or self.PAGE_WEAPON)

    self:CheckItemExpiration()
    UI.TryGC()
end

function tbClass:OnClose()
    self:UpdatePageItem(self.nCurrentPage)
    if self.nGetBoxItemEvent then
        EventSystem.Remove(self.nGetBoxItemEvent)
        self.nGetBoxItemEvent = nil
    end
    if self.nServerErrorEvent then
        EventSystem.Remove(self.nServerErrorEvent)
        self.nServerErrorEvent = nil
    end
end

--检查过期道具
function tbClass:CheckItemExpiration()
    local tbExpirationList = {}
    local function GetExpirationItem(tbItemList)
        for _, pItem in ipairs(tbItemList) do
            if pItem:Expiration() > 0 and pItem:Expiration() <= GetTime() then
                table.insert(tbExpirationList, pItem)
            end
        end
    end

    local tbList = self.tbItemList[self.PAGE_ITEM]
    if next(tbList) then
        GetExpirationItem(tbList)
    end
    tbList = self.tbItemList[self.PAGE_SUPLIES]
    if next(tbList) then
        GetExpirationItem(tbList)
    end

    if next(tbExpirationList) == nil then
        return
    end

    Item.Expiration(tbExpirationList)
end

---得到道具列表
function tbClass:GetItemList()
    local pList = UE4.TArray(UE4.UItem)
    me:GetItems(pList)

    self.tbItemList = {}
    self.tbItemInfo = {}
    self.tbListItems = {}

    local tbTypeList = {}
    for i = 1, pList:Length() do
        local pItem = pList:Get(i)
        if not pItem:IsTrial() then
            local tbSlots = self.tbEquipSlot[pItem.Type]
            if tbSlots then
                for _, nSlot in ipairs(tbSlots) do
                    local pEquip = pItem:GetSlotItem(nSlot)
                    if pEquip then
                        self.tbItemInfo[pEquip:Id()] = self.tbItemInfo[pEquip:Id()] or {}
                        self.tbItemInfo[pEquip:Id()].pEquipped = pItem
                    end
                end
            end
            tbTypeList[pItem.Type] = tbTypeList[pItem.Type] or {}
            table.insert(tbTypeList[pItem.Type], pItem)
        end
    end

    for nPage, tbPage in pairs(self.tbPage) do
        self.tbItemList[nPage] = self.tbItemList[nPage] or {}
        tbPage.nNew = 0
        for _, nType in ipairs(tbPage.tbTypes) do
            local tbItems = tbTypeList[nType]
            if tbItems then
                for _, pItem in ipairs(tbItems) do
                    if not pItem:HasFlag(Item.FLAG_READED) then
                        tbPage.nNew = tbPage.nNew + 1
                    end
                    table.insert(self.tbItemList[nPage], pItem)

                    if Item.IsBanItem({pItem:Genre(), pItem:Detail(), pItem:Particular(), pItem:Level()}) then
                        UI.ShowTip("error.ItemClose")
                    end
                end
            end
        end
    end
end

--刷新标签页道具红点
function tbClass:UpdateTabRedDot(nPage)
    nPage = nPage or self.nCurrentPage
    if not nPage or not self.tbItemList[nPage] then
        return
    end

    local tbItem = {}
    for _, pItem in ipairs(self.tbItemList[nPage]) do
        if not pItem:HasFlag(Item.FLAG_READED) then
            table.insert(tbItem, pItem:Id())
        end
    end

    if #tbItem <= 0 then
        return
    end

    me:CallGS("Item_CleanRed", json.encode(tbItem))
end

---刷新侧边栏红点
function tbClass:ShowRedDot()
    for nPage, tbPage in pairs(self.tbPage) do
        if tbPage.pTab.SubUI then
            tbPage.pTab.SubUI:SetRedDot(Item.GetDotState(nPage))
        end
    end
end

function tbClass:GetFilterItems()
    local nSort = self.tbCurSort[self.nCurrentPage].tbSort[1]
    local bReverse = self.tbCurSort[self.nCurrentPage].tbSort[2]
    local tbFilter = self.tbCurSort[self.nCurrentPage].tbFilter or {{}}
    if self.bSellMode then
        bReverse = true
    end

    local tbItems = Copy(self.tbItemList[self.nCurrentPage])
    for _, tbCfg in pairs(tbFilter) do
        tbItems = ItemSort:Filter(tbItems, tbCfg)
    end

    if self.tbSortInfo[self.nCurrentPage] and self.tbSortInfo[self.nCurrentPage].tbSort then
        tbItems = ItemSort:Sort(tbItems, self.tbSortInfo[self.nCurrentPage].tbSort.tbRule[nSort][2])
    end

    if bReverse then
        ItemSort:Reverse(tbItems)
    end

    return tbItems
end

function tbClass:UpdatePageItem(nPage)
    if not nPage or not self.tbItemList[nPage] then
        return
    end

    local tbList = {}
    for _, pItem in ipairs(self.tbItemList[nPage]) do
        if not pItem:HasFlag(Item.FLAG_READED) then
            table.insert(tbList, pItem:Id())
        end
    end

    if #tbList <= 0 then
        return
    end
    Item.Read(tbList)

    Item.SetDotState(nPage, false)
end

---打开页面
---@param nPage integer 要打开的页面下标
function tbClass:OpenPage(nPage)
    self.nSelectedItem = self.nSelectedItem or 0
    if nPage then
        if self.nCurrentPage ~= nPage then
            self.nSelectedItem = 0
            self:UpdatePageItem(self.nCurrentPage)
        end
        self.nCurrentPage = nPage
    elseif not self.nCurrentPage then
        self.nCurrentPage = self.PAGE_WEAPON
    end

    Item.SetDotState(self.nCurrentPage, false)
    self:ShowRedDot()

    local tbPage = self.tbPage[self.nCurrentPage]
    self.Switcher:SetActiveWidgetIndex(self.nCurrentPage - 1)

    local tbItems = self:GetFilterItems()
    self:UpdateList(self.nCurrentPage, tbItems)

    for page, info in pairs(self.tbPage) do
        if info.pTab.SubUI then
            if page == self.nCurrentPage then
                info.pTab.bChecked = true
                info.pTab.SubUI:SetChecked(true)
            else
                info.pTab.bChecked = false
                info.pTab.SubUI:SetChecked(false)
            end
        else--首次打开子项尚未初始化
            if page == self.nCurrentPage then
                info.pTab.bChecked = true
            end
        end
    end

    local tbMenu = self.tbSortInfo[self.nCurrentPage]
    if not tbMenu.tbFilter and (not tbMenu.tbSort or #tbMenu.tbSort.tbRule <= 1) then
        WidgetUtils.Collapsed(self.BtnScreen)
    else
        WidgetUtils.Visible(self.BtnScreen)
    end

    self:UpdateBottom()

    if (not self.bSellMode) and tbPage.bCanSell then
        WidgetUtils.Visible(self.BtnSell)
    else
        WidgetUtils.Collapsed(self.BtnSell)
    end
end

--
function tbClass:UpdatePage()
    if self.nCurrentPage then
        local tbItems = self:GetFilterItems(self.tbCurSort[self.nCurrentPage].tbSort[2])
        self:UpdateList(self.nCurrentPage, tbItems)
    end
end

-- 设置回收面板
function tbClass:SetSellPanel(bOpen)
    self.bSellMode = bOpen

    for nPage, tbPage in pairs(self.tbPage) do
        if nPage ~= self.nCurrentPage then
            self.tbPage[nPage].pTab.Data.bDisbale = bOpen
            if self.tbPage[nPage].pTab.SubUI then
                self.tbPage[nPage].pTab.SubUI:SetDisbale(bOpen)
            end
        end
    end

    if bOpen then
        if self.Sell == nil then
            self.Sell = WidgetUtils.AddChildToPanel(self.NodeContent, '/Game/UI/UMG/Bag/Widgets/uw_bag_sell.uw_bag_sell_C', 3)
            if self.Sell then
                BtnAddEvent(
                    self.Sell.BtnReturn,
                    function()
                        self:SetSellPanel(false)
                    end
                )
                BtnAddEvent(
                    self.Sell.BtnSellOut,
                    function()
                        if self:SellOut() then
                            self:SetSellPanel(false)
                        end
                    end
                )

                self.Sell.SellAddByColor = function(nColor)
                    for nId, pListItem in pairs(self.tbListItems) do
                        if type(nId) == "number" and (not pListItem.Data.bSell) and self:GetSellCount() < self.MAX_SELL_COUNT and
                        pListItem.Data.bCanSelect and pListItem.Data.pItem:Color() <= nColor then
                            self:SellAdd(nId, 1)
                        end
                    end
                    self:UpdateSellPanel()
                end
                self.Sell.SellRemoveByColor = function(nColor)
                    for nId, pListItem in pairs(self.tbListItems) do
                        if type(nId) == "number" and pListItem.Data.bSell and pListItem.Data.bCanSelect and
                                (pListItem.Data.pItem:Color() <= nColor) then
                            self:SellRemove(nId, 1)
                        end
                    end
                    self:UpdateSellPanel()
                end
                self.Sell.SellInc = function()
                    for nId, tbItem in pairs(self.tbSelledList) do
                        if tbItem.nCount < tbItem.pItem:Count() then
                            tbItem.nCount = tbItem.nCount + 1
                            self:UpdateSellPanel()
                        end
                        break
                    end
                end
                self.Sell.SellDec = function()
                    for nId, tbItem in pairs(self.tbSelledList) do
                        if tbItem.nCount > 1 then
                            tbItem.nCount = tbItem.nCount - 1
                            self:UpdateSellPanel()
                        end
                        break
                    end
                end
                self.Sell.SellMax = function()
                    for nId, tbItem in pairs(self.tbSelledList) do
                        tbItem.nCount = tbItem.pItem:Count()
                        self:UpdateSellPanel()
                        break
                    end
                end
                self.Sell.BtnSellReturn = function()
                    self:SetSellPanel(false)
                end
            end
        end
        if not self.Sell then return end

        self:OpenPage(self.nCurrentPage, true)
        --WidgetUtils.Collapsed(self.Info)
        WidgetUtils.SelfHitTestInvisible(self.Sell)
        self.Sell:Set(self.tbPage[self.nCurrentPage].bCanStack)
        self.Sell:ResetCheck()
        self.tbSelledList = {}
        --self:SellAdd(self.nSelectedItem, 1)
        if self.tbListItems and self.tbListItems[self.nSelectedItem] then
            self.tbListItems[self.nSelectedItem].Data.bSelect = false
            self.tbListItems[self.nSelectedItem].Data:SetSelected()
        end
        self.nSelectedItemBak = self.nSelectedItem
        self.nSelectedItem = -1

        --窗口缩小 
        local pSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Switcher)
        local off = pSlot:GetOffsets()
        off.Bottom = 327
        pSlot:SetOffsets(off)

    else
        if not self.tbListItems then
            self.nSelectedItem = 0
        else
            self.nSelectedItem = self.nSelectedItemBak or 0
            self:OpenPage(self.nCurrentPage)
            if self.tbListItems[self.nSelectedItem] then
                local pUI = self.tbListItems[self.nSelectedItem].pSubUI
                if pUI then
                    pUI:Selected(true)
                end
                self.tbListItems[self.nSelectedItem].Data.bSelect = true
                self.tbListItems[self.nSelectedItem].Data:SetSelected()
            end

            self:SellClear()
        end

        --窗口恢复正常大小
        local pSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Switcher)
        local off = pSlot:GetOffsets()
        off.Bottom = 145
        pSlot:SetOffsets(off)

        --WidgetUtils.Visible(self.Info)
        WidgetUtils.Collapsed(self.Sell)
    end

    -- 将被装备的道具置灰
    if self.tbItemInfo then
        for nId, pListItem in pairs(self.tbListItems) do
            if
                (type(nId) == "number" and pListItem.Data.pItem:HasFlag(Item.FLAG_LOCK)) or
                    (self.tbItemInfo[nId] and self.tbItemInfo[nId].pEquipped)
             then
                if type(nId) == "number" and pListItem.Data.pItem:HasFlag(Item.FLAG_LOCK) then
                    pListItem.Data.bLock = (not self.bSellMode)
                end
                pListItem.Data.bCanSelect = (not self.bSellMode)
                pListItem.Data:SetCanSelected()
                if nId == self.nSelectedItem then
                    self:SellRemove(nId)
                end
            end
        end
    end

    if bOpen then
        self:UpdateSellPanel()
    end

    self:UpdateBottom()
end

function tbClass:GetSellCount()
    local nCount = 0
    for _, tbItem in pairs(self.tbSelledList or {}) do
        nCount = nCount + tbItem.nCount
    end
    return nCount
end

--- 添加要回收的物品
---@param nId integer 物品的id
function tbClass:SellAdd(nId, nCount)
    if self.tbSelledList[nId] then
        self.tbSelledList[nId].nCount = self.tbSelledList[nId].nCount + nCount
    else
        self.tbSelledList[nId] = {
            pItem = self.tbListItems[nId].Data.pItem,
            nCount = nCount
        }
        self.tbListItems[nId].Data.bSell = true
        self.tbListItems[nId].Data:SetSell()
    end
end

--- 减少要回收的物品
---@param nId integer 物品的id
function tbClass:SellDec(nId, nCount)
    self.tbSelledList[nId].nCount = self.tbSelledList[nId].nCount - nCount
    if self.tbSelledList[nId].nCount <= 0 then
        self:SellRemove(nId)
    end
end

--- 移除要回收的物品
---@param nId integer 物品的id
function tbClass:SellRemove(nId)
    if not nId then
        return
    end
    self.tbSelledList[nId] = nil
    if not self.tbListItems[nId] then
        return
    end
    self.tbListItems[nId].Data.bSell = false
    self.tbListItems[nId].Data:SetSell()
end

---清空回收选中
function tbClass:SellClear()
    for nId, _ in pairs(self.tbSelledList or {}) do
        self:SellRemove(nId)
    end
end

---刷新出售面板
function tbClass:UpdateSellPanel()
    local tbRecycle = {}
    local nCount = 0
    for _, tbItem in pairs(self.tbSelledList or {}) do
        table.insert(tbRecycle, tbItem)
        nCount = nCount + tbItem.nCount
    end
    local tbReward = ItemRecycle.CalcRewards(tbRecycle) or {}

    --空槽位填充
    if #tbReward < 9 then
        for i=1, 9 - #tbReward do
            table.insert(tbReward, {0,0,0,0,0})
        end
    end
    if self.Sell then
        self.Sell:Set(self.tbPage[self.nCurrentPage].bCanStack, tbReward, nCount)
    end
end

---回收物品
---@return boolean 返回是否回收成功
function tbClass:SellOut()
    local tbRecycle = {}
    for _, tbItem in pairs(self.tbSelledList or {}) do
        table.insert(tbRecycle, {nId = tbItem.pItem:Id(), nCount = tbItem.nCount})
    end
    if #tbRecycle == 0 then
        UI.ShowTip("tip.SelectSellItem")
        return false
    end
    me:CallGS("Item_Recycle", json.encode({tbItems = tbRecycle}))
    return true
end

---刷新道具列表
function tbClass:UpdateList(nPage, tbItems)
    local pList = self.Switcher:GetActiveWidget().list
    self:DoClearListItems(pList)
    pList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    if #tbItems <= 0 then
        WidgetUtils.Collapsed(pList)
        WidgetUtils.Visible(self.PanelNoItem)
        self.tbListItems = {}
        return
    else
        WidgetUtils.Visible(pList)
        WidgetUtils.Collapsed(self.PanelNoItem)
    end

    local tbItemData = {}
    for idx, pItem in ipairs(tbItems) do
        local tbInfo = self.tbItemInfo[pItem:Id()]
        local tbData = {
            pItem = pItem,
            pEquipped = tbInfo and tbInfo.pEquipped or nil,
        }
        if self.tbListItems and self.tbListItems[pItem:Id()] then
            tbData.bSell = self.tbListItems[pItem:Id()].Data.bSell
        end


        table.insert(tbItemData, tbData)
    end

    self.tbListItems = {}
    local nAniCount = 0
    local nIntervalTime = 0.05
    for _, tbData in ipairs(tbItemData) do
        local pObj = self:GenItemObj(tbData)
        pObj.Data.bBag = true
        if tbData.pItem:HasFlag(Item.FLAG_LOCK) or tbData.pEquipped then
            if tbData.pItem:HasFlag(Item.FLAG_LOCK) then
                pObj.Data.bLock = (not self.bSellMode)
            end
            pObj.Data.bCanSelect = (not self.bSellMode)
            pObj.Data:SetCanSelected()
        end

        local nId = tbData.pItem:Id()
        if self.nSelectedItem == nId then
            pObj.Data.bSelect = true
            self.nSelectedItem = nId
        end
        pList:AddItem(pObj)
        self.tbListItems[nId] = pObj
        self.tbListItems.length = (self.tbListItems.length or 0) + 1

        -- PlayAnimation
        if nAniCount < 30 then
            nAniCount = nAniCount + 1
            UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                {
                    self,
                    function()
                        pObj.Data:PlayAnimation()
                    end
                },
                nIntervalTime * nAniCount,
                false
            )
        end
    end
end

-- 刷新底栏
function tbClass:UpdateBottom()
    local tbPage = self.tbPage[self.nCurrentPage]
    local fEnhance = (tbPage and tbPage.fEnhance) or nil
    -- local fUse = (tbPage and tbPage.fUse) or nil
    local nItemCount = self.tbListItems and self.tbListItems.length or 0

    if (not self.bSellMode) and (nItemCount > 0) then
        WidgetUtils.Visible(self.BtnSell)
    else
        WidgetUtils.Collapsed(self.BtnSell)
    end

    -- if self.bSellMode then
    --     WidgetUtils.Visible(self.BtnSellReturn)
    -- else
    --     WidgetUtils.Collapsed(self.BtnSellReturn)
    -- end

    -- if fEnhance and (not self.bSellMode) and (nItemCount > 0) then
    --     self.TxtUse:SetText(tbPage.sEnhance)
    --     WidgetUtils.Visible(self.BtnUse)
    -- else
    --     WidgetUtils.Collapsed(self.BtnUse)
    -- end

    -- if fUse and (not self.bSellMode) and (nItemCount > 0) then
    --     self.TxtUse:SetText(tbPage.sUse)
    --     WidgetUtils.Visible(self.BtnUse)
    -- else
    --     WidgetUtils.Collapsed(self.BtnUse)
    -- end

    if self.bSellMode and (nItemCount > 0) then
        WidgetUtils.Visible(self.BtnSellOut)
    else
        WidgetUtils.Collapsed(self.BtnSellOut)
    end
end

---生成道具的UI对象
function tbClass:GenItemObj(tbItemData)
    local tbData = {}
    tbData.pItem = tbItemData.pItem
    tbData.pEquipped = tbItemData.pEquipped
    tbData.bCanSelect = true
    tbData.bSell = tbItemData.bSell
    tbData.OnTouch = function()
        local nId = tbItemData.pItem:Id()
        if self.bSellMode then
            self:OnListItemTouchedSell(nId)
        else
            self:OnListItemTouched(nId)
        end

        if not tbItemData.pItem:HasFlag(Item.FLAG_READED) then
            Item.Read({tbItemData.pItem:Id()})

            tbData:SetNew()
            self.tbPage[self.nCurrentPage].nNew = self.tbPage[self.nCurrentPage].nNew - 1

            if self.tbPage[self.nCurrentPage].nNew <= 0 then
                Item.SetDotState(self.nCurrentPage, false)
            end

            self:ShowRedDot()
        end
    end

    tbData.SetSelected = function(self)
        EventSystem.TriggerTarget(self, "SET_SELECTED")
    end

    tbData.SetCanSelected = function(self)
        EventSystem.TriggerTarget(self, "SET_CANSELECTED")
    end

    tbData.SetSell = function(self)
        EventSystem.TriggerTarget(self, "SET_SELL")
    end

    tbData.SetNew = function(self)
        EventSystem.TriggerTarget(self, "SET_NEW")
    end

    tbData.PlayAnimation = function(self)
        EventSystem.TriggerTarget(self, "PLAY_ANIMATION")
    end

    tbData.SetLock = function(self)
        EventSystem.TriggerTarget(self, "SET_LOCK")
    end

    

    return self.Factory:Create(tbData)
end

---点击道具的回调
function tbClass:OnListItemTouched(nId)
    -- if self.nSelectedItem == nId then
    --     return
    -- end

    if self.nSelectedItem ~= 0 and self.tbListItems[self.nSelectedItem] then
        self.tbListItems[self.nSelectedItem].Data.bSelect = false
        self.tbListItems[self.nSelectedItem].Data:SetSelected()   
    end
    self.tbListItems[nId].Data.bSelect = true
    self.tbListItems[nId].Data:SetSelected()

    self.nSelectedItem = nId
    self:UpdateInfo(self.nCurrentPage)
end

---回收模式下点击道具的回调
function tbClass:OnListItemTouchedSell(nId)
    if self.tbPage[self.nCurrentPage].bCanStack then
        self:SellClear()
    end
    if self.tbSelledList[nId] then
        self:SellRemove(nId)
    else
        if self:GetSellCount() >= self.MAX_SELL_COUNT then
            return
        end
        self:SellAdd(nId, 1)
    end
    self:UpdateSellPanel()
end

---刷新右侧面板
---@param nPage integer 页面下标，对应tbClass.PAGE_常量定义
---@param nItemIdx integer 对应self.tbListItems的下标，缺省则显示当前选中的Item
function tbClass:UpdateInfo(nPage, nItemIdx)
    local nIdx = nItemIdx or self.nSelectedItem
    if not nIdx or not self.tbListItems[nIdx] then
        self.nSelectedItem = 0
        nIdx = 0
    end

    if nIdx > 0 then
        --WidgetUtils.Visible(self.Info)
        --self.Info:OnOpen(self.tbListItems[nIdx].Data.pItem)
        local tbPage = self.tbPage[self.nCurrentPage]
        local tbEnhance = nil
        if tbPage then
            tbEnhance = {fEnhance=tbPage.fEnhance, sEnhance=tbPage.sEnhance}
        end

        UI.Open('ItemInfo',self.tbListItems[nIdx].Data.pItem, tbEnhance)
        local ui = UI.GetUI("ItemInfo")
        if not ui then
            return
        end

        ui.SetLock = function(pItem, bLock)
            me:CallGS("Item_SetLock", json.encode({ItemId = pItem:Id(), Lock = bLock}))
        end
    end
end

---道具锁定状态变更
function tbClass:OnItemLocked(nItemId)
    local pListItem = self.tbListItems[nItemId]
    if pListItem then
        pListItem.Data:SetLock()
    end
end

---道具回收服务器返回后的回调
function tbClass:OnRecycleEnd()
    self.nSelectedItem = 0
    self:OnOpen(self.nCurrentPage)
end


--服务器 Item::Use 中先使用道具（调用Lua的onUse）再扣减数量
--客户端收到onUse中的回包时还没同步到最新数据
function tbClass:UseItemCallBack(pItem, nUseCount)
    UI.ShowConnection()
    self.nServerErrorEvent =
        EventSystem.On(
        Event.ShowPlayerMessage,
        function()
            UI.CloseConnection()
        end,
        true
    )

    if pItem:Count() > nUseCount then
        self.nGetBoxItemEvent = 
            EventSystem.On(
            Event.GetBoxItem,
            function(InItem)
                UI.CloseConnection()
                EventSystem.Remove(self.nServerErrorEvent)
                EventSystem.Remove(self.nGetBoxItemEvent)
                self.nGetBoxItemEvent = nil
                self.nServerErrorEvent = nil

                local BagUI = UI.GetUI("Bag")

                if BagUI then
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {
                        BagUI,
                        function()
                            local BagUI = UI.GetUI("Bag")
                            if BagUI then
                                BagUI:UpdatePage()
                            end
                        end
                    },
                    0.05,
                    false
                    )
                end
            end,
            true
        )
    else
        self.nGetBoxItemEvent = 
            EventSystem.On(
            Event.GetBoxItem,
            function(InItem)
                UI.CloseConnection()
                EventSystem.Remove(self.nServerErrorEvent)
                EventSystem.Remove(self.nGetBoxItemEvent)
                self.nGetBoxItemEvent = nil
                self.nServerErrorEvent = nil

                local BagUI = UI.GetUI("Bag")
                if BagUI then
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {
                        BagUI,
                        function()
                            local BagUI = UI.GetUI("Bag")
                            if BagUI then
                                BagUI:OnRecycleEnd()
                            end
                        end
                    },
                    0.05,
                    false
                    )
                end
            end,
            true
        )
    end
end

EventSystem.On(Event.LanguageChange, function(bReconnected, bNeedRename)
    if bReconnected then return end
    --切换语言 缓存的信息重新取一遍
    self.tbSortInfo[self.PAGE_SUPPORT].tbFilter[2].tbRule = Logistics.GetSuitSkillList()
end)

return tbClass
