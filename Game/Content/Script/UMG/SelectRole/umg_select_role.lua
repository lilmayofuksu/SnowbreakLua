-- ========================================================
-- @File    : umg_select_role.lua
-- @Brief   : 面板角色选择
-- ========================================================
---@class tbClass : ULuaWidget
---@field LeftList UListView
local tbClass= Class("UMG.BaseWidget")

function tbClass:Construct()
    self.LeftList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

function tbClass:OnInit()
    self.ListFactory = Model.Use(self)

    self.SelType = {
        { Option = Text('ui.TxtRareSort')   },
        { Option = Text('ui.sort_get')  },
        { Option = Text('ui.TxtLvSort')     },
        
    }
    local tbSortParam = {}
     tbSortParam.tbSortInfos = {}
     tbSortParam.tbSortInfos[1] = {
        {
            tbSorts = ItemSort.WeaponColorSort,
            sName =  self.SelType[1].Option
        },
         {
            tbSorts = ItemSort.TemplateIdSort,
            sName = self.SelType[2].Option
        },
    }
     self.tbCurSort = {nIdx = 1, bReverse = false}
     tbSortParam.fSort = function(nIdx, bReverse)
        self.tbCurSort = {nIdx = nIdx, bReverse = bReverse}
        self:ShowListView()
     end 

     self.tbSortInfo = tbSortParam.tbSortInfos
     self.SortRole:Init(tbSortParam)


     BtnAddEvent(self.BackBtn, function()
        UI.Close(self)
    
     end)
end

function tbClass:OnOpen(nIndex)
    self.nIndex = nIndex
    self:ShowListView()
    self.LeftList:NavigateToIndex(self.nSelectIdx or 0)

    PreviewScene.Enter(PreviewType.main)
    PreviewMain.LoadBG(function()
        PreviewMain.SetBlurBgVisible(true) 
    end, true)
end


function tbClass:OnSelectChange(param, bForce)
    if self.Current == param and not bForce then return end
    if self.Current then
        self.Current.bSelect = false
        EventSystem.TriggerTarget(self.Current, "SET_SELECTED", false)
    end

    self.Current = param
    if self.Current then
        self.Current.bSelect = true
        EventSystem.TriggerTarget(self.Current, "SET_SELECTED", true)
    end

    self:ShowDetail(true)
end


---显示
function tbClass:ShowDetail(bShowEffect)
    if not self.Current or not self.nIndex then return end
    local nNewId = self.Current.pCard:Id()
    local pOldCard = me:GetShowItem(self.nIndex)
    BtnClearEvent(self.BtnChange)

    if pOldCard and nNewId == pOldCard:Id() then
        self.TxtTouchChange:SetText('disboard')
        self.TxtTouchChange2:SetText('disboard')
        WidgetUtils.Visible(self.BtnChange)
        BtnAddEvent(self.BtnChange, function() self:DoSetNone()  end)
    else
        local bSet = (self:IsShowByID(nNewId) == 1)
        if bSet then
            WidgetUtils.Collapsed(self.BtnChange)
        else
            if me:GetShowItem(self.nIndex) ~= nil then
                self.TxtTouchChange:SetText("TxtChange")
                self.TxtTouchChange2:SetText('TxtChange')
            else
                self.TxtTouchChange:SetText('TxtSet')
                self.TxtTouchChange2:SetText('TxtSet')
            end

            WidgetUtils.Visible(self.BtnChange)
            BtnAddEvent(self.BtnChange, function() self:DoChange() end) 
        end
    end
    self.pCard = self.Current.pCard
    PreviewMain.LoadCard(nNewId, function()
        if bShowEffect then
            if Preview.GetModel() and self.SpawnEmit then
                local loc = Preview.GetModel():K2_GetActorLocation()
                UE4.UGameLibrary.SpawnEmitterAtLocation(GetGameIns(), self.SpawnEmit, loc, UE4.FRotator(0, 0, 0), UE4.FVector(1, 1, 1))
            end
        end
    end)
end


function tbClass:DoChange()
    if not self.pCard then return end
    PlayerSetting.Req_ChangeAccountShowCard(self.pCard:Id(), self.nIndex)
end

function tbClass:DoSetNone()
    PlayerSetting.Req_ChangeAccountShowCard(-1, self.nIndex)
end

---是否被设置
function tbClass:IsShowByID(nId)
    for i = 1, 3 do
        local pItem = me:GetShowItem(i)
        if pItem and pItem:Id() == nId then
            return 1
        end
    end
    return 0
end


function tbClass:ShowListView()
    if not self.LeftList then return end
    if not self.tbCurSort then return end

    self:DoClearListItems(self.LeftList)
    local tbCard = me:GetCharacterCards():ToTable()

    local tbSetCard = {}
    local tbOtherCard = {}
    for _, c in ipairs(tbCard) do
        if self:IsShowByID(c:Id()) == 1 then
            table.insert(tbSetCard, c)
        else
            table.insert(tbOtherCard, c)
        end
    end

    
    local tbSortInfo = self.tbSortInfo[1][self.tbCurSort.nIdx or 1]
    local tbSortOtherCard = ItemSort:Sort(tbOtherCard, tbSortInfo.tbSorts or {})
    local tbSortSetCard = ItemSort:Sort(tbSetCard, tbSortInfo.tbSorts or {})

    local fReverse = function(tb)
        local tmp = {}
        for i = 1, #tb do
            tmp[i] = table.remove(tb)
        end
        return tmp
    end

    ---反转
    if self.tbCurSort.bReverse then
       tbSortOtherCard = fReverse(tbSortOtherCard)
       tbSortSetCard = fReverse(tbSortSetCard)
    end

    local tbDisplayCard = {}


    for _, c in ipairs(tbSortSetCard) do
        table.insert(tbDisplayCard, c)
    end
    for _, c in ipairs(tbSortOtherCard) do
        table.insert(tbDisplayCard, c)
    end

    local pNowCard = nil

    if self.Current then
        pNowCard = self.Current.pCard
    else
        pNowCard = me:GetShowItem(self.nIndex)
    end

    local tbSet = {}
    for i = 1, 3 do
        local pItem = me:GetShowItem(i)
        if pItem then
            tbSet[pItem] = 1
        end
    end

    for nIdx, pCard in ipairs(tbDisplayCard or {}) do
        local bSelect = (pCard == pNowCard)
        local tbParam = {pCard = pCard, bSelect = bSelect, bSet = tbSet[pCard] ~= nil, fClick = function(pa) self:OnSelectChange(pa.Data, false)  end}
        local pObj = self.ListFactory:Create(tbParam)
        self.LeftList:AddItem(pObj)
        if  bSelect then
            self.Current = tbParam
            self.nSelectIdx = nIdx
        end

        if self.Current == nil then
            self.Current = tbParam
            self.nSelectIdx = nIdx
        end
    end

    if self.Current then
        self:OnSelectChange(self.Current, true)
    end
end

return tbClass