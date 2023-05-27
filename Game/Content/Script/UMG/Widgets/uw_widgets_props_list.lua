-- ========================================================
-- @File    : uw_widgets_props_list.lua
-- @Brief   : 普通物品展示条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

tbClass.tbTimeColor = 
{
    {3600*12, 1005005},
    {3600*3, 1005006},
    {0, 1005007},
    {-1, 1005004},
}
tbClass.nSpiltDay = 24*3600

function tbClass:Construct()
    BtnAddEvent(
        self.BtnClick,
        function()
            if self.tbData.bCanSelect == nil or self.tbData.bCanSelect then
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

    if self.TimerHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
    end
    self.TimerHandle = nil
end

---被添加时初始化
---@param pObj table@{Data:{pItem, bSelect, bSell}
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
    self:SetLocked()

    local pItem = self.tbData.pItem
    SetTexture(self.Icon, pItem:Icon())
    self:SetNum(pItem:Count())
    SetTexture(self.ImgQuality, Item.ItemListColorIcon[pItem:Color()])
    if pItem:Genre() == UE4.EItemType.Suplies and pItem:Detail() == 4 then
        WidgetUtils.HitTestInvisible(self.PanelPiece)
        SetTexture(self.ImgPiece, pItem:EXIcon())
    else
        WidgetUtils.Collapsed(self.PanelPiece)
    end

    if self.tbData.pItem:Color() == 0 then
        print(self.tbData.pItem:Genre(), self.tbData.pItem:Detail(), self.tbData.pItem:Particular(), self.tbData.pItem:Level())
    end
    self:OnShowQuality(self.tbData.pItem:Color())

    self.nId = self.tbData.pItem:Id()
    self:OnShowTime(self.nId)

    self.TimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                self:OnShowTime(self.nId)
            end
        },
        0.5,
        true
    )
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

function tbClass:SetNum(nNum)
    if nNum then
        WidgetUtils.Visible(self.TxtNum)
        self.TxtNum:SetText(tostring(self.tbData.pItem:Count()))
    else
        WidgetUtils.Hidden(self.TxtNum)
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

function tbClass:OnShowQuality(InColor)
    -- print('InColor',InColor)
    if not InColor or not Color.tbShadowHex[InColor] then
        print("error InColor", InColor)
        -- print(debug.traceback())
        return
    end

    local  HexColor = Color.tbShadowHex[InColor]
    self.ImgPieceQuality:SetColorAndOpacity(UE4.FLinearColor(HexColor.R,HexColor.G,HexColor.B,HexColor.A))
end

function tbClass:OnShowTime(nId)
    local pItem = me:GetItem(nId)

    if not pItem or pItem:Expiration() <= 0 then
        WidgetUtils.Collapsed(self.PanelLimitTime)
        return
    end

    WidgetUtils.Visible(self.PanelLimitTime)
    WidgetUtils.Collapsed(self.PanelDate)
    WidgetUtils.Visible(self.PanelTime)
    local nLast = pItem:Expiration() - GetTime()
    if nLast < self.nSpiltDay then
        if nLast < 0 then
            nLast = 0
        end
        local sTime = string.format("%02d:%02d:%02d", math.floor(nLast/3600), math.floor(nLast%3600/60), math.floor(nLast%60))
        self.TxtTime:SetText(sTime)
    else
        local sData = string.format(Text('ui.TxtDungeonsTowerTime0'), math.floor(nLast/3600/24))
        self.TxtTime:SetText(sData)
    end

    for _, tbInfo in ipairs(self.tbTimeColor) do
        if nLast > tbInfo[1] or tbInfo[1] < 0 then
            SetTexture(self.ImgTimeBG, tbInfo[2])
            break
        end
    end
end

return tbClass
