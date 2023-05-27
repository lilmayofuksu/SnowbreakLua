-- ========================================================
-- @File    : umg_common_screen.lua
-- @Brief  : 排序筛选
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.SortList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

function tbClass:OnInit()
    BtnAddEvent(
        self.BtnSubmit,
        function()
            UI.Close(self)
        end
    )

    BtnAddEvent(
        self.BtnOk,
        function()
            self.tbOld.tbSort = self.tbCond.tbSort
            self.tbOld.tbFilter = self.tbCond.tbFilter
            UI.Close(self)
        end
    )
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.SortList)
end

--[[
    --菜单项
    tbParam = {
        tbSort = { 
            sDesc = 'ui.TxtScreen1', 
            tbRule = { 
                {'ui.sort_quality', ItemSort.BagItemQualitySort},
                {'ui.TxtScreen6', ItemSort.BagItemTypeSort},
            } 
        },
    
        --{sDesc:标题文字，rule:筛选类型, tbRule:筛选子项 }
        tbFilter = {
            { 
                sDesc='ui.TxtScreen3', 
                rule=8,
                tbRule={ 
                    {'weapon.type_1', 1},
                    {'weapon.type_2', 2},
                    {'weapon.type_3', 3},
                    {'weapon.type_4', 4},
                    {'weapon.type_5', 5},
                } 
            },
        }
    }
    -- 可选参数 选中的菜单状态
    tbSort:排序参数(选中项索引，是否逆序) tbFilter:筛选参数({规则索引,筛选条件})
    tbFilter = {tbSort={1, false}, tbFilter={{2,1},{3,2224}}}
]]--
function tbClass:OnOpen(tbParam, tbCond, funClose)
    self.tbOld = tbCond
    self.tbCond = tbCond and Copy(tbCond) or {}
    self.tbMenu = tbParam
    --没有设置筛选项时使用默认项
    if not self.tbCond.tbSort and self.tbMenu.tbSort then
        self.tbCond.tbSort = {1, self.tbMenu.tbSort.tbRule[1][2]}
    end


    if not self.tbCond.tbFilter and self.tbMenu.tbFilter then
        self.tbCond.tbFilter = {}
        for index, tb in ipairs(self.tbMenu.tbFilter) do
            self.tbCond.tbFilter[index] = {{tb.rule, 0}}
        end
    end
    self:UpdateSortList()
    self.FunClose = funClose
end

function tbClass:SetDefaultFilter(nPage)
    if not self.tbCond.tbFilter[nPage] or not next(self.tbCond.tbFilter[nPage]) then
        if self.tbMenu.tbFilter[nPage] then
            self.tbCond.tbFilter[nPage] = {{self.tbMenu.tbFilter[nPage].rule, 0}}
        end
    end
end

function tbClass:UpdateSortList()
    self.tbList = self.tbList or {}

    local function CheckTab(tbList, tb)
        local bFind = false
        for _, info in ipairs(tbList) do
            for index, value in ipairs(info) do
                if value == tb[index] and index == #info then
                    bFind = true
                    return bFind
                end
            end
        end

        return bFind
    end

    if not next(self.tbList) then
        self:DoClearListItems(self.SortList)
        if self.tbMenu.tbSort then
            table.insert(self.tbList, self:AddTab(self.tbMenu.tbSort, 0))
        end

        if self.tbMenu.tbFilter then
            for idx, tbInfo in ipairs(self.tbMenu.tbFilter) do
                table.insert(self.tbList, self:AddTab(tbInfo, idx))
            end
        end
    else
        if self.tbMenu.tbSort and self.tbCond.tbSort and self.tbList[1] and self.tbList[1].UI and self.tbList[1].UI.tbList then
            for index, ui in ipairs(self.tbList[1].UI and self.tbList[1].UI.tbList) do
                if index ~= self.tbCond.tbSort[1] then
                    ui:SetState(0)
                elseif self.tbCond.tbSort[2] == true then
                    ui:SetState(1)
                else
                    ui:SetState(2)
                end
            end
        end

        local nAdd = 1
        if not self.tbMenu.tbSort then
            nAdd = 0
        end

        if self.tbCond.tbFilter then
            for i, tbFilter in ipairs(self.tbCond.tbFilter) do
                if self.tbList[i+nAdd] and self.tbList[i+nAdd].UI and self.tbList[i+nAdd].UI.tbList then
                    for v, ui in ipairs(self.tbList[i+nAdd].UI.tbList) do
                        if CheckTab(tbFilter, {ui.Data.rule, ui.Data.info}) then
                            ui:SetState(1)
                        else
                            ui:SetState(0)
                        end
                    end
                end
            end
        end
    end
end


-- 标签页按钮
function tbClass:AddTab(tbInfo, nPage)
    local pObj = self.Factory:Create(tbInfo)
    pObj.ParentUI = self
    pObj.nPage = nPage -- 菜单索引  0是排序  筛选可以有多项 从1开始
    if nPage == 0 then
        pObj.tbCurSort = self.tbCond.tbSort
    else
        pObj.tbCurFilter = self.tbCond.tbFilter and self.tbCond.tbFilter[nPage]
    end
    self.SortList:AddItem(pObj)

    return pObj
end

--管理tab页显示状态
-- page是第几页  0是排序页  从1开始是筛选页  可以有多项
-- index 是点中的按钮索引  3个按钮对应不同状态
-- data是按钮绑定的参数  排序和筛选参数类型不同 分开处理 
function tbClass:OnTabClick(nPage, nIndex, data)
    --排序规则只能单选 
    if nPage == 0 then
        self:SetSort(nIndex, data)
    else--筛选规则可以多选
        self:SetFilter(nPage, nIndex, data)
    end

    self:UpdateSortList()
end

function tbClass:SetSort(nIndex, data)
    if nIndex == 0 then
        self.tbCond.tbSort = {data.idx, false}
    elseif nIndex == 1 then
        self.tbCond.tbSort = {data.idx, false}
    elseif nIndex == 2 then
        self.tbCond.tbSort = {data.idx, true}
    end
end

--筛选规则  点中全选 要取消其他子项的选中  如果有全选 点中其他子项要删除全选。。。
function tbClass:SetFilter(nPage, nIndex, data)
    self.tbCond.tbFilter = self.tbCond.tbFilter or {}
    self.tbCond.tbFilter[nPage] = self.tbCond.tbFilter[nPage] or {}

    --全选
    if data.info == 0 then
        if nIndex == 0 then
            self.tbCond.tbFilter[nPage] = {{data.rule, data.info}}
        else
            self.tbCond.tbFilter[nPage] = nil
        end
    else
        local bFind = false
        --删除选中的子项
        for idx, tb in ipairs(self.tbCond.tbFilter[nPage]) do
            if tb[1] == data.rule and tb[2] == data.info then
                bFind = true
                if nIndex ~= 0 then
                    table.remove(self.tbCond.tbFilter[nPage], idx)
                end
                break
            end
        end

        --添加子项 删除全选
        if not bFind and nIndex == 0 then
            table.insert(self.tbCond.tbFilter[nPage], {data.rule, data.info})
            for idx, tb in ipairs(self.tbCond.tbFilter[nPage]) do
                if tb[2] == 0 then
                    table.remove(self.tbCond.tbFilter[nPage], idx)
                    break
                end
            end
        end
    end

    self:SetDefaultFilter(nPage)
end

function tbClass:OnClose()
    if self.FunClose then
        self.FunClose()
    end
end

return tbClass
