-- ========================================================
-- @File    : umg_riki_list.lua
-- @Brief   : 图鉴分类显示界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

-- RikiLogic.tbType = {
--     ['Role'] = 1,
--     ['Weapon'] = 2,
--     ['Support'] = 3,
--     ['Monster'] = 4,
--     ['fashion'] = 5,
--     ['Plot'] = 6,
--     ['Explore'] = 7,
--     ['Parts'] = 8,
-- }

function tbClass:Construct()
    self.Check1:SetClickMethod(UE4.EButtonClickMethod.MouseDown)
    self.Check1:SetTouchMethod(UE4.EButtonTouchMethod.Down)
    self.Check1.OnCheckStateChanged:Add(
        self,
        function(_, bChecked)
            self:UpdateList(self.nCurrentPage, self.nCurrentChildPage)
        end
    )
end

function tbClass:OnInit()
    self.Factory = Model.Use(self)

    -- 各页面设置
    self.tbPage = {}
    self.tbPage[RikiLogic.tbType.Role] = {
        pPage = self.Role,
        nIcon = 1701013,
        Type = RikiLogic.tbType.Role,
        TxtTitle = "ui.TxtHandbook3",
    }

    self.tbPage[RikiLogic.tbType.Weapon] = {
        pPage = self.Weapon,
        nIcon = 1701013,
        Type = RikiLogic.tbType.Weapon,
        TxtTitle = "ui.TxtHandbook8",
        tbChildPage = {
            {'weapon.type_1', 1},
            {'weapon.type_2', 2},
            {'weapon.type_3', 3},
            {'weapon.type_4', 4},
            {'weapon.type_5', 5},
        }
    }

    self.tbPage[RikiLogic.tbType.Support] = {
        pPage = self.Support,
        nIcon = 1701014,
        Type = RikiLogic.tbType.Support,
        TxtTitle = "ui.TxtHandbook12",
        tbChildPage = {
            {'ui.technology', 1},
            {'ui.medicalcare', 2},
            {'ui.equip', 3},
        }
    }

    self.tbPage[RikiLogic.tbType.Monster] = {
        pPage = self.Monster,
        nIcon = 1701015,
        Type = RikiLogic.tbType.Monster,
        TxtTitle = "ui.TxtHandbook11",
    }

    -- self.tbPage[RikiLogic.tbType.Fashion] = {
    --     pPage = self.Weapon,
    --     nIcon = 1701013,
    --     Type = RikiLogic.tbType.Fashion,
    --     TxtTitle = "TxtHandbook5",
    --     fClick = function(pItem)
    --         UI.Open("Arms", 0, pItem)
    --     end
    -- }

    -- self.tbPage[RikiLogic.tbType.Plot] = {
    --     pPage = self.Weapon,
    --     nIcon = 1701013,
    --     Type = RikiLogic.tbType.Weapon,
    --     TxtTitle = "TxtHandbook5",
    --     fClick = function(pItem)
    --         UI.Open("Arms", 0, pItem)
    --     end
    -- }

    self.tbPage[RikiLogic.tbType.Explore] = {
        pPage = self.Explore_1,
        nIcon = 1701013,
        Type = RikiLogic.tbType.Explore,
        TxtTitle = "ui.TxtHandbook14",
    }

    self.tbPage[RikiLogic.tbType.Parts] = {
        pPage = self.Part,
        nIcon = 1701016,
        Type = RikiLogic.tbType.Parts,
        TxtTitle = "ui.TxtHandbook25",
        tbChildPage = {
            {'ui.weapon_part_1', 1},
            {'ui.weapon_part_2', 2},
            {'ui.weapon_part_4', 4},
            {'ui.weapon_part_5', 5},
        }
    }

    self.tbSortInfo = {}
    -- 武器排序
    self.tbSortInfo[RikiLogic.tbType.Weapon] = {
        tbSort = { 
            sDesc = 'ui.TxtScreen1', 
            tbRule={
                {'ui.sort_quality', ItemSort.RikItemQualitySort},
                {'ui.sort_type', ItemSort.RikiItemDetailSort},
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
    -- 后勤排序
    self.tbSortInfo[RikiLogic.tbType.Support] = {
        tbSort = { 
            sDesc = 'ui.TxtScreen1', 
            tbRule = { 
                {'ui.TxtRareSort', ItemSort.BagSupportQualitySort}, 
                {'ui.sort_type', ItemSort.RikiItemDetailSort}, 
                {'ui.sort_team', ItemSort.RikiItemParticularSort} 
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
    -- 武器配件排序
    self.tbSortInfo[RikiLogic.tbType.Parts] = {
        tbSort = { 
            sDesc = 'ui.TxtScreen1', 
            tbRule = { 
                {'ui.sort_quality', ItemSort.RikItemQualitySort}, 
                {'ui.sort_type', ItemSort.RikiItemDetailSort}, 
                {'ui.sort_suit', ItemSort.RikiItemParticularSort}, 
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
    -- 角色排序
    self.tbSortInfo[RikiLogic.tbType.Role] = {
        tbSort = { 
            sDesc = 'ui.TxtScreen1', 
            tbRule = { 
                {'ui.sort_quality', ItemSort.RikItemQualitySort}, 
                {'ui.sort_role', ItemSort.RikiItemDetailSort}, 
            } 
        },
    
        --{sDesc:标题文字，rule:筛选类型, tbRule:筛选子项 }
        tbFilter = {
            {
                sDesc='ui.TxtScreen3',
                rule=9,
                tbRule={
                    {'weapon.type_1', 1},
                    {'weapon.type_2', 2},
                    {'weapon.type_3', 3},
                    {'weapon.type_4', 4},
                    {'weapon.type_5', 5}
                }
            },
        }
    }



    --各分页的排序设置单独保存
    self.tbCurSort = self.tbCurSort or {}
    self.tbCurSort[RikiLogic.tbType.Weapon] = self.tbCurSort[RikiLogic.tbType.Weapon] or {tbSort={1, false}}
    self.tbCurSort[RikiLogic.tbType.Support] = self.tbCurSort[RikiLogic.tbType.Support] or {tbSort={1, false}}
    self.tbCurSort[RikiLogic.tbType.Parts] = self.tbCurSort[RikiLogic.tbType.Parts] or {tbSort={1, false}}
    self.tbCurSort[RikiLogic.tbType.Role] = self.tbCurSort[RikiLogic.tbType.Role] or {tbSort={1, false}}

    self.tbSortInfo.fSort = function(nIdx, bReverse)
        self.tbCurSort[self.nCurrentPage].nSort = nIdx
        self.tbCurSort[self.nCurrentPage].bReverse = bReverse

        self:UpdateList(self.nCurrentPage, self.nCurrentChildPage)
    end

    self.tbRoleCPTCfgs = Role.GetAllOpenChapterCfg(1)

    BtnAddEvent(self.Button, function()
        if not self.nCurrentPage == RikiLogic.tbType.Weapon then
            return
        end
        
        self:OnOpen(RikiLogic.tbType.Weapon)
    end)

    BtnAddEvent(self.Button1, function()
        if not self.nCurrentPage == RikiLogic.tbType.Parts then
            return
        end
        
        self:OnOpen(RikiLogic.tbType.Parts)
    end)

    BtnAddEvent(self.BtnScreen, function()
        if not UI.IsOpen('Screen') then
            UI.Open('Screen', self.tbSortInfo[self.nCurrentPage], self.tbCurSort[self.nCurrentPage],
            function()
                self:OnOpen()
            end)
        end
    end)
end

---排序逻辑
function tbClass:Sort()
    local tbDataList = {}
    if self.nCurrentPage == RikiLogic.tbType.Explore or self.nCurrentPage == RikiLogic.tbType.Monster then
        for _, pObj in pairs(self.tbListItems) do
            table.insert(tbDataList, pObj)
        end

        for _, pObj in pairs(tbDataList) do
            pObj.Data.nTotal = #tbDataList
        end
        return tbDataList
    end

    local tbItems = {}
    for _, pObj in pairs(self.tbListItems) do
        table.insert(tbItems, pObj.Data.pItem)
    end

    local tbFilter = self.tbCurSort[self.nCurrentPage].tbFilter or {{}}
    local nSort = self.tbCurSort[self.nCurrentPage].tbSort[1] or 1
    local bReverse = self.tbCurSort[self.nCurrentPage].tbSort[2] or false
    for _, tbCfg in pairs(tbFilter) do
        tbItems = ItemSort:Filter(tbItems, tbCfg)
    end

    if self.tbSortInfo[self.nCurrentPage] and self.tbSortInfo[self.nCurrentPage].tbSort then
        tbItems = ItemSort:Sort(tbItems, self.tbSortInfo[self.nCurrentPage].tbSort.tbRule[nSort][2])
    end

    if bReverse then
        ItemSort:Reverse(tbItems)
    end

    
    for _, pItem in ipairs(tbItems) do
        local pObj = self:PhraseItem(pItem)
        if pObj then
            pObj.Data.nTotal = #tbItems
            table.insert(tbDataList, pObj)
        end
    end

    return tbDataList
end

function tbClass:OnOpen(nPage, nChildPage)
    self.nCurrentPage = nPage or self.nCurrentPage

    if self.nCurrentPage == nil then
        if RikiLogic:GetNowRoleData() then
            self.nCurrentPage = RikiLogic.tbType.Role
        else
            self.nCurrentPage = RikiLogic.tbType.Weapon
        end
    end
    self:UpdatePage(self.nCurrentPage)
    self:UpdateList(self.nCurrentPage, nChildPage)

    if self.tbCurSort[self.nCurrentPage] then
        WidgetUtils.Visible(self.BtnScreen)
    else
        WidgetUtils.Collapsed(self.BtnScreen)
    end

    self:UpdateBtn()

    PreviewScene.Enter(PreviewType.role_lvup)
    Preview.PlayCameraAnimByCfgByID(0, PreviewType.role_riki)
end

function tbClass:UpdateBtn()
    if self.nCurrentPage == RikiLogic.tbType.Weapon or self.nCurrentPage == RikiLogic.tbType.Parts then
        WidgetUtils.Visible(self.BtnWeapon)
        WidgetUtils.Visible(self.BtnPart)

        self.TextCommon:SetText(Text('ui.weapon'))
        self.TextSelected:SetText(Text('ui.weapon'))

        self.TextCommon_1:SetText(Text('ui.weapon_part'))
        self.TextSelected_1:SetText(Text('ui.weapon_part'))

        if self.nCurrentPage == RikiLogic.tbType.Weapon then
            WidgetUtils.Visible(self.Selected)
            WidgetUtils.Visible(self.Common1)
            WidgetUtils.Collapsed(self.Common)
            WidgetUtils.Collapsed(self.Selected1)
        else
            WidgetUtils.Visible(self.Selected1)
            WidgetUtils.Visible(self.Common)
            WidgetUtils.Collapsed(self.Common1)
            WidgetUtils.Collapsed(self.Selected)
        end
    else
        WidgetUtils.Collapsed(self.BtnWeapon)
        WidgetUtils.Collapsed(self.BtnPart)
    end
end

function tbClass:UpdatePage(nPage)
    local pageGroup = self.tbPage[nPage]
    if pageGroup then
        self.TxtTitle:SetText(pageGroup.TxtTitle);
    end

    local nAct,nRed,nSum = RikiLogic:GetTypeRikiNum(nPage)
    self.Num1:SetText(nAct)
    self.Num2:SetText(nSum)
end

--tbItems 是pItem list 排序后的结果  要转换成带附加信息的data才能在控件中使用
function tbClass:UpdateList(nPage, nChildPage)
    self.nCurrentPage = nPage
    self.nCurrentChildPage = nChildPage
    self:GetItemList()
    self.tbListData = self:Sort()
    if nPage == RikiLogic.tbType.Role then
        RikiLogic:SetRoleList(self.tbListData)
    end
    local pList = nil
    for _, tbInfo in pairs(self.tbPage) do
        self:DoClearListItems(tbInfo.pPage)
        if tbInfo.Type == nPage then
            pList = tbInfo.pPage
            if nPage == RikiLogic.tbType.Role or nPage == RikiLogic.tbType.Explore then
                WidgetUtils.Collapsed(self.Switcher_2)
                WidgetUtils.Visible(self.Switcher_1)
                self.Switcher_1:SetActiveWidget(tbInfo.pPage)
            else
                WidgetUtils.Collapsed(self.Switcher_1)
                WidgetUtils.Visible(self.Switcher_2)
                self.Switcher_2:SetActiveWidget(tbInfo.pPage)
            end
            
            pList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
        end
    end

    if not pList then
        return
    end

    if self.nCurrentPage == RikiLogic.tbType.Explore then
        self:PhraseExploreItem(self.tbListItems, pList)
        WidgetUtils.Collapsed(self.CanvasPanel_177)
    else
        WidgetUtils.Visible(self.CanvasPanel_177)
        for _, pObj in pairs(self.tbListData) do
            pList:AddItem(pObj)
        end
    end
end

function tbClass:GetItemList()
    self.tbListItems = {}
    local isGet = false
    if self.Check1:IsChecked() then
        isGet = true
    end
    local itemList = RikiLogic:GetTypeRikiList(self.nCurrentPage, self.nCurrentChildPage, isGet)
    for _, item in ipairs(itemList) do
        local pObj = self:GenItemObj(item)
        if pObj then
            self.tbListItems[pObj.Data.Id] = pObj
        end
    end
end

-- 把pItem对象转换成封装的data对象
function tbClass:PhraseItem(pItem)
    if self.nCurrentPage ~= RikiLogic.tbType.Monster and self.nCurrentPage ~= RikiLogic.tbType.Explore then
        for _, pObj in pairs(self.tbListItems) do
            if pItem:Id() == pObj.Data.pItem:Id() then
                return pObj
            end
        end
    end
end

--处理探索图鉴控件需要的Data数据
function tbClass:PhraseExploreItem(tbListItems, pList)
    local tbExploreList = {}
    for _,nType in pairs(FragmentStory.Type) do
        tbExploreList[nType] = { 
        ['nGet'] = 0,
        ['nTotal'] = 0,
        ['nType'] = nType
        }
    end

    for _,tbItemInfo in pairs(tbListItems or {}) do
        local tbTypeInfo = tbExploreList[tbItemInfo.Data.ExploreType]
        if tbTypeInfo then
            if tbItemInfo.Data.nGet ~= 0 then
                tbTypeInfo.nGet = tbTypeInfo.nGet + 1
            end
            tbTypeInfo.nTotal = tbTypeInfo.nTotal + 1
        end
    end

    for _,tbData in pairs(tbExploreList or {}) do
        local pObj = self.Factory:Create(tbData)
        pList:AddItem(pObj)
    end
end


---生成道具的UI对象
function tbClass:GenItemObj(item)
    local tbData = {}
    tbData.Id = item.Id
    tbData.rikiState = item.state
    if item.Type == RikiLogic.tbType.Monster then
        tbData.cfg = item
    elseif item.Type == RikiLogic.tbType.Explore then
        tbData.ExploreID = item.ExploreID
        tbData.ExploreType = item.ExploreType
    else
        tbData.pItem = me:GetDefaultItem(table.unpack(item.tbItem))
        if not tbData.pItem then
            return
        end
        tbData.pItem:AddFlag(Item.FLAG_READED)
    end

    if item.Type == RikiLogic.tbType.Role then
        for _,cfg in pairs(self.tbRoleCPTCfgs or {}) do
            if cfg.tbCharacter[1] == item.tbItem[1] and cfg.tbCharacter[2] == item.tbItem[2] and cfg.tbCharacter[3] == item.tbItem[3] and cfg.tbCharacter[4] == item.tbItem[4] then
                tbData.tbChapterCfg = cfg
                break
            end
        end
    end

    if item.Type ~= RikiLogic.tbType.Explore and item.Type ~= RikiLogic.tbType.Monster then
        if item.state == RikiLogic.tbState.Lock then
            tbData.bCanSelect = false
            tbData.pItem:AddFlag(Item.FLAG_LOCK)
        else
            tbData.bCanSelect = true
            tbData.pItem:DelFlag(Item.FLAG_LOCK)
        end
    end

    tbData.OnTouch = function()
        self:OnListItemTouched(tbData.Id)
    end

    tbData.SetSelected = function(self)
        EventSystem.TriggerTarget(self, "SET_SELECTED")
    end

    tbData.SetCanSelected = function(self)
        EventSystem.TriggerTarget(self, "SET_CANSELECTED")
    end

    tbData.SetNew = function(self)
        EventSystem.TriggerTarget(self, "SET_NEW")
    end

    tbData.PlayAnimation = function(self)
        EventSystem.TriggerTarget(self, "PLAY_ANIMATION")
    end

    tbData.OnLeft = function (nId)
        if not self.tbListData then
            return
        end

        for index, pObj in ipairs(self.tbListData) do
            if nId == pObj.Data.Id then
                local nNext = pObj
                if index == 1 then
                    nNext = self.tbListData[#self.tbListData]
                else
                    nNext = self.tbListData[index-1]
                end

                return nNext.Data
            end
        end
    end

    tbData.OnRight = function (nId)
        if not self.tbListData then
            return
        end

        for index, pObj in ipairs(self.tbListData) do
            if nId == pObj.Data.Id then
                local nNext = pObj
                if index == #self.tbListData then
                    nNext = self.tbListData[1]
                else
                    nNext = self.tbListData[index+1]
                end

                return nNext.Data
            end
        end
    end

    local nGet,nNew = RikiLogic:GetRiki(item.Id)
    tbData.nGet = nGet
    tbData.nNew = nNew
    
    return self.Factory:Create(tbData)
end

---点击道具的回调
function tbClass:OnListItemTouched(nId)
    -- self.tbListItems[nId].Data.bSelect = true
    -- self.tbListItems[nId].Data:SetSelected()

    self.nSelectedItem = nId
    self:UpdateInfo(nId)
end

---刷新侧边栏红点
function tbClass:ShowRedDot()
    -- for nPage, tbPage in pairs(self.tbPage) do
    --     tbPage.pTab.Data.bNew = tbPage.nNew > 0
    --     if not tbPage.pTab.Data.bNew then
    --         Item.SetDotState(nPage, false)
    --     end
    --     if tbPage.pTab.SubUI then
    --         --tbPage.pTab.SubUI:SetRedDot(tbPage.nNew > 0)
    --         tbPage.pTab.SubUI:SetRedDot(Item.GetDotState(nPage))
    --     end
    -- end
end

-- 点击道具跳转
function tbClass:UpdateInfo(nItemIdx)
    local nIdx = nItemIdx or self.nSelectedItem
    if not nIdx or not self.tbListItems[nIdx] then
        self.nSelectedItem = 0
        nIdx = 0
    end

    if nIdx > 0 then
        local tbData = self.tbListItems[nIdx].Data
        if self.nCurrentPage == RikiLogic.tbType.Weapon then
            UI.Open("Arms", 1, tbData.pItem, tbData.rikiState, tbData)
        elseif self.nCurrentPage == RikiLogic.tbType.Support then
            UI.Open("RikiSupportInfo", tbData)
        elseif self.nCurrentPage == RikiLogic.tbType.Explore then
             UI.Open("RikiExploreInfo", tbData)
        elseif self.nCurrentPage == RikiLogic.tbType.Parts then
            UI.Open("ItemInfo", tbData.pItem, tbData.rikiState)
        elseif self.nCurrentPage == RikiLogic.tbType.Monster then
            UI.Open("RikiMonsterInfo", tbData)
        end

    end
end



return tbClass
