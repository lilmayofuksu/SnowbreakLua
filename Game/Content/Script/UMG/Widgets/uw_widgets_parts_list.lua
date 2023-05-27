-- ========================================================
-- @File    : uw_widgets_parts_list.lua
-- @Brief   : 武器配件展示条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClick,
        function()

            if self.tbData.rikiState or self.tbData.bCanSelect == nil then
                self.tbData.OnTouch()
                return
            end

            if self.tbData.bLock == false then
                UI.ShowTip("ui.ItemLock")
            elseif not self.tbData.bCanSelect then
                UI.ShowTip("tip.ItemEquiped")
                return
            end
            self.tbData.OnTouch()
        end
    )
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nSelectEvent)
    EventSystem.Remove(self.nCanSelectEvent)
    EventSystem.Remove(self.nSellEvent)
    EventSystem.Remove(self.nNewEvent)
    EventSystem.Remove(self.nPlayAnimation)
    EventSystem.Remove(self.nLockEvent)
end

--[[
    {Data:{pItem, bSelect}}
]]
---被添加时初始化
---@param pObj table
function tbClass:OnListItemObjectSet(pObj)
    WidgetUtils.Collapsed(self.New)
    EventSystem.Remove(self.nSelectEvent)
    self.nSelectEvent =
        EventSystem.OnTarget(
        pObj.Data,
        "SET_SELECTED",
        function()
            self:Selected()
        end
    )
    EventSystem.Remove(self.nCanSelectEvent)
    self.nCanSelectEvent =
        EventSystem.OnTarget(
        pObj.Data,
        "SET_CANSELECTED",
        function()
            self:CanSelected()
        end
    )
    EventSystem.Remove(self.nSellEvent)
    self.nSellEvent =
        EventSystem.OnTarget(
        pObj.Data,
        "SET_SELL",
        function()
            self:SetSell()
        end
    )
    EventSystem.Remove(self.nNewEvent)
    self.nNewEvent =
        EventSystem.OnTarget(
        pObj.Data,
        "SET_NEW",
        function()
            self:SetNew()
        end
    )
    EventSystem.Remove(self.nPlayAnimation)
    self.nPlayAnimation =
        EventSystem.OnTarget(
        pObj.Data,
        "PLAY_ANIMATION",
        function()
            self:PlayAnimation(self.AllEnter)
        end
    )
    EventSystem.Remove(self.nLockEvent)
    self.nLockEvent =
        EventSystem.OnTarget(
        pObj.Data,
        "SET_LOCK",
        function()
            self:SetLocked()
        end
    )
    self.tbData = pObj.Data

    self:CanSelected()
    self:Selected()
    self:SetSell()
    WidgetUtils.Collapsed(self.TxtTip)
    WidgetUtils.Collapsed(self.PanelLock)
    WidgetUtils.HitTestInvisible(self.PanelType)

    if self.tbData.bEquip and self.tbData.bEquip == true then
        WidgetUtils.HitTestInvisible(self.EquipNode)
    else
        WidgetUtils.Collapsed(self.EquipNode)
    end

    local g, d, p, l
    local pItem = self.tbData.pItem
    if pItem then
        g, d, p, l = pItem:Genre(), pItem:Detail(), pItem:Particular(), pItem:Level()
        SetTexture(self.Icon, pItem:Icon())
        SetTexture(self.ImgQuality, Item.ItemListColorIcon[pItem:Color()])
    else
        if self.tbData.gdpl == nil then
            WidgetUtils.Collapsed(self.Icon)
            WidgetUtils.Collapsed(self.ImgQuality)
            WidgetUtils.Collapsed(self.Lock)
            WidgetUtils.SelfHitTestInvisible(self.TxtTip)
            WidgetUtils.SelfHitTestInvisible(self.PanelType)
            SetTexture(self.ImgType, Item.WeaponTypeIcon[self.tbData.nType])
        else
            WidgetUtils.SelfHitTestInvisible(self.Icon)
            g, d, p, l = table.unpack(self.tbData.gdpl)
            local pTemplate = UE4.UItem.FindTemplate(g, d, p, l)
            if not pTemplate then
                return
            end
            WidgetUtils.SelfHitTestInvisible(self.ImgQuality)
            SetTexture(self.Icon, pTemplate.Icon)
            SetTexture(self.ImgQuality, Item.ItemListColorIcon[pTemplate.Color])
    
           if WeaponPart.GetPart(g, d, p, l) == nil then
                WidgetUtils.HitTestInvisible(self.PanelLock)
           end
        end
    end
    self.g, self.d, self.p, self.l = g, d, p, l

    if g and d and p and l then
        local nType =  WeaponPart.GetAllowWeaponType(WeaponPart.GetPartConfigByGDPL(g, d, p, l))
        SetTexture(self.ImgType, Item.WeaponTypeIcon[nType])
        self:SetLocked()
        self:SetNew()
    end
end

function tbClass:Selected()
    if self.tbData.bSelect then
        WidgetUtils.Visible(self.PanelSelect)
    else
        WidgetUtils.Hidden(self.PanelSelect)
    end
end

function tbClass:CanSelected()
    if self.tbData.bCanSelect == nil or self.tbData.bCanSelect then
        WidgetUtils.Collapsed(self.PanelNot)
    else
        WidgetUtils.HitTestInvisible(self.PanelNot)
    end
end

function tbClass:SetSell()
    if self.tbData.bSell then
        WidgetUtils.Visible(self.PanelSell)
    else
        WidgetUtils.Hidden(self.PanelSell)
    end
end

function tbClass:SetLocked()
    if self.tbData.pItem and self.tbData.pItem:HasFlag(Item.FLAG_LOCK) then
        WidgetUtils.Visible(self.Lock)
    else
        WidgetUtils.Hidden(self.Lock)
    end
end

function tbClass:SetNew()
    if self.tbData.pItem then
        if WeaponPart.IsRead(self.tbData.pItem) then
            WidgetUtils.Collapsed(self.New)
        else
            WidgetUtils.HitTestInvisible(self.New)
        end
    else
        WidgetUtils.Collapsed(self.New)
    end
end

return tbClass
