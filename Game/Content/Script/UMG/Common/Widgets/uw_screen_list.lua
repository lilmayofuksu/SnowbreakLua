-- ========================================================
-- @File    : uw_screen_list.lua
-- @Brief   : 筛选框列表
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
end

function tbClass:OnDestruct()
    
end

function tbClass:GetSortState(pObj, nIndex)
    local nState = 0
    if pObj.tbCurSort and pObj.tbCurSort[1] == nIndex then
        if pObj.tbCurSort[2] then
            nState = 1
        else
            nState = 2
        end
    end
    return nState
end

function tbClass:GetFilterState(pObj, nIndex)
    local nState = 0
    if pObj.tbCurFilter then
        for _, tb in ipairs(pObj.tbCurFilter) do
            if tb[1] == pObj.Data.rule and tb[2] == nIndex then
                nState = 1
                break
            end
        end
    end

    return nState
end

function tbClass:OnListItemObjectSet(pObj)
    self.SortList:ClearChildren()
    self.ParentUI = pObj.ParentUI
    self.tbList = {}
    pObj.UI = self
    self.Data = pObj.Data
    self.nPage = pObj.nPage --菜单索引  0是排序  筛选可以有多项 从1开始
    if self.Data.sDesc and self.TxtLevelSelect then
        self.TxtLevelSelect:SetText(self.Data.sDesc)
    end

    if self.Data.tbRule and self.SortList then
        if self.nPage ~= 0 then
            --筛选规则 需要添加一个全选的子项
            table.insert(self.tbList, self:AddTab({idx=0, rule=self.Data.rule, sDesc='ui.TxtScreen4', info=0, state=self:GetFilterState(pObj, 0)}))
        end

        for idx, tb in ipairs(self.Data.tbRule) do
            if self.nPage ~= 0 then
                table.insert(self.tbList, self:AddTab({idx=idx, rule=self.Data.rule, sDesc=tb[1], info=tb[2], state=self:GetFilterState(pObj, tb[2])}))
            else
                table.insert(self.tbList, self:AddTab({idx=idx, rule=self.Data.rule, sDesc=tb[1], info=tb[2], state=self:GetSortState(pObj, idx)})) 
            end
        end
    end
end

function tbClass:OnChildClick(nIndex, data)
    if self.ParentUI and self.ParentUI.OnTabClick then
        self.ParentUI:OnTabClick( self.nPage, nIndex, data)
    end
end

function tbClass:AddTab(tbInfo)
    tbInfo.ParentUI = self
    local pWidget = LoadWidget("/Game/UI/UMG/Common/Widgets/uw_screen_item.uw_screen_item_C")
    self.SortList:AddChildToWrapBox(pWidget)
    pWidget:Display(tbInfo)

    return pWidget
end

return tbClass
