-- ========================================================
-- @File    : uw_widgets_role.lua
-- @Brief   : 角色，武器排序筛选
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    -- body
end

function tbClass:Init(tbParam)
    self.fSort = tbParam.fSort
    self.tbInfo = tbParam
    self.nCurrentIdx = tbParam.nCurIdx or 1
    self:OnClear()
    

    self:SetMode(1)

    BtnAddEvent(
        self.BtnScreen,
        function()
            if self.bOpenPanel then
                self:ShowSortList(false)
                self.bOpenPanel = false
            else
                self:ShowSortList(true)
                self.bOpenPanel = true
            end
        end
    )

    self:ShowSortList(false)

    BtnAddEvent(
        self.BtnSort,
        function()
            self:Reverse()
        end
    )

    if self.BGBtn then
        BtnAddEvent(
            self.BGBtn, 
            function() 
                self:ShowSortList(false)
                self.bOpenPanel = false 
            end)
    end
end



function tbClass:SetMode(nMode, nSort, bReverse)
    self.nMode = nMode
    nSort = nSort or self.nCurrentIdx
    nSort = nSort or 1

    self:DoClearListItems(self.ListScreen)
    self.tbSortData = {}
    for nIdx, tbData in ipairs(self.tbInfo.tbSortInfos[nMode]) do
        local objData = self:GenSortObj(nIdx, Text(tbData.sName), nIdx == (self.tbInfo.nCurIdx or 1))
        self.Factory = self.Factory or Model.Use(self)
        self.ListScreen:AddItem(self.Factory:Create(objData))
        table.insert(self.tbSortData, objData)
    end

    if self.TextCurrent then
        self.TextCurrent:SetText(self.tbSortData[nSort].sName)
    end

    if bReverse then
        self.ImgSort:SetRenderScale(UE4.FVector2D(1, -1))
    else
        self.ImgSort:SetRenderScale(UE4.FVector2D(1, 1))
    end

    self.bReverse = bReverse
    self:Sort(nSort, true)
end

function tbClass:GenSortObj(nIdx, sName, bSelect)
    local tbData = {}
    tbData.nIdx = nIdx
    tbData.sName = sName
    tbData.bSelect = bSelect
    tbData.OnTouch = function()
        self:Sort(nIdx)
        self:ShowSortList(false)
        self.bOpenPanel = false
        if self.TextCurrent then
            self.TextCurrent:SetText(tbData.sName)
        end
    end
    return tbData
end

function tbClass:Sort(nIdx, bNoSort)
    if self.nCurrentIdx == nIdx then  return end

    if self.nCurrentIdx then
        local pOldData = self.tbSortData[self.nCurrentIdx]
        if pOldData then
            pOldData.bSelect = false
            EventSystem.TriggerTarget(pOldData, 'ON_SELECT_CHANGE')
        end
    end

    local pNewData =  self.tbSortData[nIdx]
    if pNewData then
        pNewData.bSelect = true
        EventSystem.TriggerTarget(pNewData, 'ON_SELECT_CHANGE')
    end

    self.nCurrentIdx = nIdx
    if not bNoSort then
        self.fSort(nIdx, self.bReverse)
    end
end

function tbClass:Reverse()
    if self.bReverse then
        self.fSort(self.nCurrentIdx, false)
        self.bReverse = false
        self.ImgSort:SetRenderScale(UE4.FVector2D(1, 1))
    else
        self.fSort(self.nCurrentIdx, true)
        self.bReverse = true
        self.ImgSort:SetRenderScale(UE4.FVector2D(1, -1))
    end
end

function tbClass:ShowSortList(InShow)
    if InShow then
        WidgetUtils.Visible(self.ListScreen)
        if self.BGBtn then
           WidgetUtils.Visible(self.BGBtn)
        end
    else
        WidgetUtils.Hidden(self.ListScreen)
        if self.BGBtn then
            WidgetUtils.Hidden(self.BGBtn)
         end
    end
end


function tbClass:OnDisable()
    self:OnClear()
end

function tbClass:OnClear()
    BtnClearEvent(self.BtnScreen)
    BtnClearEvent(self.BtnSort)
    if self.BGBtn then
        BtnClearEvent(self.BGBtn)
    end
end

--- 清除缓存
function tbClass:OnDestruct()
    DestroyListObj(self.ListScreen)
end

return tbClass
