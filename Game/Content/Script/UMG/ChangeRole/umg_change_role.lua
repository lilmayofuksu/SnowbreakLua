-- ========================================================
-- @File    : umg_change_role.lua
-- @Brief   : 面板角色选择
-- ========================================================
---@class tbClass : ULuaWidget
---@field LeftList UListView
local tbClass= Class("UMG.BaseWidget")

function tbClass:OnInit()

    BtnAddEvent(self.BackBtn, function() UI.Close(self) end)

    BtnAddEvent(self.BtnChange, function() self:DoChange()  end)

    self.LeftList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.ListFactory = Model.Use(self)
    self.Factory = Model.Use(self)
end

function tbClass:OnOpen()
    self.nShowCardID = PlayerSetting.GetShowCardID()

    self.CurrentObj = nil

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


    self:ShowListView()
    self:ShowDetail(true)
    PreviewScene.Enter(PreviewType.main)
    PreviewMain.LoadBG(function()
        PreviewMain.SetBlurBgVisible(true) 
    end, true)
end

function tbClass:OnClose()
    PreviewMain.LoadCard(PlayerSetting.GetShowCardID(), function()
        if Preview.GetModel() and self.SpawnEmit then
            local loc = Preview.GetModel():K2_GetActorLocation()
            UE4.UGameLibrary.SpawnEmitterAtLocation(GetGameIns(), self.SpawnEmit, loc, UE4.FRotator(0, 0, 0), UE4.FVector(1, 1, 1))
        end
    end)
    PreviewMain.SetBlurBgVisible(false)
end

function tbClass:OnSelectChange(pObj)
    if self.CurrentObj == pObj then return end
    if self.CurrentObj then
        self.CurrentObj.Data.bSelect = false
        EventSystem.TriggerTarget(self.CurrentObj.Data, "SET_SELECTED", false)
    end

    self.CurrentObj = pObj
    if self.CurrentObj then
        self.CurrentObj.Data.bSelect = true
        EventSystem.TriggerTarget(self.CurrentObj.Data, "SET_SELECTED", true)
    end

    self:ShowDetail(true)
    -- self:UpdateSkinList(self.CurrentObj.Data.pCard:Id())
end

---显示
function tbClass:ShowDetail(bShowEffect)
    if not self.CurrentObj then return end
    local nNewId = self.CurrentObj.Data.pCard:Id()
    -- local nSkinId = self.CurSelectItem.Data.Skin:Id()
    if nNewId == self.nShowCardID then
        WidgetUtils.Collapsed(self.BtnChange)
    else
        WidgetUtils.Visible(self.BtnChange) 
    end

    -- if self.CurrentSkin ~= nSkinId then
    --     self.TxtTouchChange:SetText("TxtFashionTip4")
    -- else
    --     self.TxtTouchChange:SetText("TxtDialogueConfirm")
    -- end

    PreviewMain.LoadCard(nNewId, function()
        if bShowEffect then
            if Preview.GetModel() and self.SpawnEmit then
                local loc = Preview.GetModel():K2_GetActorLocation()
                UE4.UGameLibrary.SpawnEmitterAtLocation(GetGameIns(), self.SpawnEmit, loc, UE4.FRotator(0, 0, 0), UE4.FVector(1, 1, 1))
            end
        end
    end)
end

---@param blift true 上升 false 下降
function tbClass:ShowListView()
    if not self.LeftList then return end

    if not self.tbCurSort then return end

    self:DoClearListItems(self.LeftList)
    local tbCard = me:GetCharacterCards():ToTable()
    local tbSortInfo = self.tbSortInfo[1][self.tbCurSort.nIdx or 1]

    local tbSortCard = ItemSort:Sort(tbCard, tbSortInfo.tbSorts or {})

    if self.tbCurSort.bReverse then
        local tmp = {}
        for i = 1, #tbSortCard do
            tmp[i] = table.remove(tbSortCard)
        end
        tbSortCard = tmp
    end

    local nSelectID = self.nShowCardID

    if self.CurrentObj then
        nSelectID = self.CurrentObj.Data.pCard:Id()
    end


    for _, pCard in ipairs(tbSortCard or {}) do
        local bSelect = false
        if pCard:Id() == nSelectID then
            bSelect = true
        end

        local tbParam = {pCard = pCard, bSelect = bSelect, fClick = function(o)
            self:OnSelectChange(o)
        end}

        local pObj = self.ListFactory:Create(tbParam)
        self.LeftList:AddItem(pObj)

        if bSelect then
            self.CurrentObj = pObj
        end
    end

    local nJumpIdx = 0

    if self.CurrentObj then
        nJumpIdx = self.LeftList:GetIndexForItem(self.CurrentObj)
    end

    self.LeftList:NavigateToIndex(nJumpIdx or 0)
    self.LeftList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    -- self:UpdateSkinList(nSelectID)
end


---通知改变角色
function tbClass:DoChange()
    if not self.CurrentObj or not self.CurrentObj.Data or not self.CurrentObj.Data.pCard then return end
    -- if self.CurSelectItem and self.CurSelectItem.Data.Skin:Id() ~= self.CurrentSkin then
    --     local pSkin = self.CurSelectItem.Data.Skin
    --     if pSkin then
    --         Fashion.ChangeSkinReq(
    --             self.CurrentObj.Data.pCard,
    --             pSkin,
    --             function()
    --                 self.CurrentSkin = self.CurSelectItem.Data.Skin:Id()
    --                 self:EquipItem()
    --             end
    --         )
    --     end
    -- else
    --     PlayerSetting.Req_ChangeRole(self.CurrentObj.Data.pCard:Id())
    -- end
    PlayerSetting.Req_ChangeRole(self.CurrentObj.Data.pCard:Id())
end

-----------------------------------------------------------------
---时装相关
function tbClass:UpdateSkinList(SelectId)
    local pRole = me:GetItem(SelectId)
    if not pRole or not pRole:IsCharacterCard() then
        return
    end
    local tbOwnSkin = Fashion.GetCharacterSkins(pRole)
    local pCurrentSkin = pRole:GetSlotItem(5)
  
    if not pCurrentSkin or not pCurrentSkin:IsCharacterSkin() then return end
    self.CurrentSkin = pCurrentSkin:Id()
    table.sort(tbOwnSkin, function(a, b)
        if a:Level() < b:Level() then
            return true
        else
            return false
        end
    end)
    self:DoClearListItems(self.ListFashion)
    for _, v in pairs(tbOwnSkin) do
        local tbParam = {
            Index = v:Level(),
            Equip = pCurrentSkin:Level(),
            Skin = v,
            HaveSkin = true,
            bShow = pCurrentSkin:Level() == v.Level,
            Click = function(InItem)
                self:OnSelectSkin(InItem)
            end,
            SetEquipItem = function(InItem)
                self:SetEquipItem(InItem)
            end,
        }
        local tbItem = self.Factory:Create(tbParam)
        self.ListFashion:AddItem(tbItem)

        if v:Id() == self.CurrentSkin then
            self.CurSelectItem = tbItem
        end
    end
    self:ShowDetail(true)
end

---选择皮肤
function tbClass:OnSelectSkin(SkinItem)
    if self.CurSelectItem == SkinItem or not SkinItem then
        return
    end
    if self.CurSelectItem and self.CurSelectItem.OnSelect then
        self.CurSelectItem:OnSelect(false)
    end
    if SkinItem and SkinItem.OnSelect then
        SkinItem:OnSelect(true)
    end
    self.CurSelectItem = SkinItem
    local pItem = SkinItem.Data.Skin
    if pItem then
        Preview.UpdateCharacterSkin(pItem:AppearID())
        if Preview.GetModel() and self.SpawnEmit then
            local loc = Preview.GetModel():K2_GetActorLocation()
            UE4.UGameLibrary.SpawnEmitterAtLocation(GetGameIns(), self.SpawnEmit, loc, UE4.FRotator(0, 0, 0), UE4.FVector(1, 1, 1))
        end
    end
    
    self:ShowDetail(true)
end

function tbClass:EquipItem()
    if self.CurEquipItemSkin and self.CurEquipItemSkin.UpdateEquipState then
        self.CurEquipItemSkin:UpdateEquipState(false)
    end

    self.CurEquipItemSkin = self.CurSelectItem
    if self.CurEquipItemSkin and self.CurEquipItemSkin.UpdateEquipState then
        self.CurEquipItemSkin:UpdateEquipState(true)
    end
    self:ShowDetail(true)
end

function tbClass:SetEquipItem(InItem)
    self.CurEquipItemSkin = InItem
end

return tbClass