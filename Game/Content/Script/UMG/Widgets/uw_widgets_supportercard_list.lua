-- ========================================================
-- @File    : uw_widgets_supportercard_list.lua
-- @Brief   : 后勤卡列表元素
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(
        self.BtnClick,
        function()
            if self.tbData.rikiState ~= nil or self.tbData.bCanSelect == nil or self.tbData.bCanSelect then
                self.tbData.OnTouch()
            elseif self.tbData.bLock == false then
                UI.ShowTip("ui.ItemLock")
            else
                UI.ShowTip("tip.ItemEquiped")
            end
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
    self:SetNew()

    local pItem = self.tbData.pItem
    if self.tbData.rikiState then
        WidgetUtils.Collapsed(self.PanelLevel)
    else
        self.Level:SetText(pItem:EnhanceLevel())
    end

    
    SetTexture(self.ImgType, Item.SupportTypeIcon[pItem:Detail()])
    if Item.IsBreakMax(pItem) then
        SetTexture(self.Icon, pItem:IconBreak())
    else
        SetTexture(self.Icon, pItem:Icon())
    end
    self:SetStar(pItem:Quality())
    SetTexture(self.ImgQuality, Item.ItemListColorIcon[pItem:Color()])
    self:SetLocked()

    if self.tbData.pEquipped then
        WidgetUtils.Visible(self.PanelUse)
        if self.tbData.pEquipped:Icon() > 0 then
            SetTexture(self.ImgHead, self.tbData.pEquipped:Icon())
        end
    else
        WidgetUtils.Hidden(self.PanelUse)
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
        if self.tbData.bBag then
            WidgetUtils.Collapsed(self.Image_2)
        else
            WidgetUtils.HitTestInvisible(self.Image_2)
        end
    end
end

function tbClass:SetSell()
    if self.tbData.bSell then
        WidgetUtils.Visible(self.PanelSell)
    else
        WidgetUtils.Hidden(self.PanelSell)
    end
end

function tbClass:SetStar(nStar)
    for i = 1, 5 do
        if i <= nStar then
            WidgetUtils.Visible(self["Star" .. i])
        else
            WidgetUtils.Hidden(self["Star" .. i])
        end
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
    if self.tbData.pItem:HasFlag(Item.FLAG_READED) then
        WidgetUtils.Collapsed(self.New)
    else
        WidgetUtils.Visible(self.New)
    end
end

return tbClass
