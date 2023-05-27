-- ========================================================
-- @File    : uw_widgets_weapon_list.lua
-- @Brief   : 武器展示条目
-- ========================================================
local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
    BtnAddEvent(
        self.BtnClick,
        function()
            if self.tbData.rikiState or self.tbData.bCanSelect == nil or self.tbData.bCanSelect then
                if self.tbData.OnTouch then
                    self.tbData.OnTouch()
                end
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
    if self.TimerBind then
        UE4.Timer.Cancel(self.TimerBind)
        self.TimerBind = nil
    end
end

function tbClass:Display(tbData)
    EventSystem.Remove(self.nSelectEvent)
    EventSystem.Remove(self.nCanSelectEvent)
    EventSystem.Remove(self.nSellEvent)
    EventSystem.Remove(self.nNewEvent)
    EventSystem.Remove(self.nPlayAnimation)

    self.tbData = tbData
    self:Selected(true)
    self:SetSell()
    self:SetNew()

    local pItem = self.tbData.pItem
    self:SetLevel(pItem:EnhanceLevel())
    --self:SetStar(pItem:Quality())
    self:SetIcon(pItem:Icon(), pItem:Color(), pItem:Detail())
    self:SetParts(pItem)
    self:SetLocked()
    WidgetUtils.Collapsed(self.PanelUse)
end

function tbClass:DisplayByGDPL(G, D, P, L, Level, tbPart)
    EventSystem.Remove(self.nSelectEvent)
    EventSystem.Remove(self.nCanSelectEvent)
    EventSystem.Remove(self.nSellEvent)
    EventSystem.Remove(self.nNewEvent)
    EventSystem.Remove(self.nPlayAnimation)

    self.tbData = {}
    WidgetUtils.Collapsed(self.PanelSelect)
    WidgetUtils.Collapsed(self.PanelSell)
    WidgetUtils.Collapsed(self.New)
    WidgetUtils.Collapsed(self.PanelUse)
    WidgetUtils.Collapsed(self.Lock)

    local weaponInfo = UE4.UItem.FindTemplate(G, D, P, L)
    if not weaponInfo then return end
    self:SetLevel(Level)
    self:SetIcon(weaponInfo.Icon, weaponInfo.Color, D)
    Weapon.ShowPartInfoByGDPL({G, D, P, L}, self, tbPart)
    self:SetParts()
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
    self:Selected(true)
    self:SetSell()
    self:SetNew()

    local pItem = self.tbData.pItem
    self:SetLevel(pItem:EnhanceLevel())
    self:SetIcon(pItem:Icon(), pItem:Color(), pItem:Detail(), self.tbData.uiType)
    self:SetParts(pItem)
    self:SetLocked()

    if self.tbData.pEquipped then
        WidgetUtils.HitTestInvisible(self.PanelUse)
        if self.tbData.pEquipped:Icon() > 0 then
            SetTexture(self.ImgHead, self.tbData.pEquipped:Icon())
        end
    else
        WidgetUtils.Collapsed(self.PanelUse)
    end
end

function tbClass:Selected(bFirst)
    if self.tbData.bSelect then
        WidgetUtils.Visible(self.PanelSelect)
        self:PlayAnimation(self.Repeat, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
        if self.Select then
            self:PlayAnimation(self.Select, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
        end
    else
        if self.Select then
            self:StopAnimation(self.Repeat)
            local fun = function ()
                WidgetUtils.Collapsed(self.PanelSelect)
                self.TimerBind = nil
            end
            if bFirst then
                self:PlayAnimationReverse(self.Select)
                self:SetAnimationCurrentTime(self.Select, self.Select:GetStartTime())
                fun()
            else
                local time = math.abs(self.Select:GetEndTime() - self.Select:GetStartTime())
                self.TimerBind = UE4.Timer.Add(time, fun)
                self:PlayAnimation(self.Select, 0, 1, UE4.EUMGSequencePlayMode.Reverse, 1, false)
            end
        else
            WidgetUtils.Collapsed(self.PanelSelect)
            self:StopAnimation(self.Repeat)
        end
    end
end

function tbClass:SetLevel(Level)
    Level = Level or 1
    if self.tbData.rikiState then
        WidgetUtils.Collapsed(self.PanelLevel)
        return
    end
    
    self.TxtLvNum:SetText(Level)
    if self.TxtNum2 then
        self.TxtNum2:SetText(Level)
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
        WidgetUtils.HitTestInvisible(self.PanelSell)
    else
        WidgetUtils.Collapsed(self.PanelSell)
    end
end

---显示配件信息
function tbClass:SetParts(pWeapon)
    if not pWeapon then
        WidgetUtils.Collapsed(self.PanelParts)
        return
    end
    Weapon.ShowPartInfo(pWeapon, self)
end

function tbClass:SetStar(nStar)
    for i = 1, 5 do
        if i <= nStar then
            WidgetUtils.Visible(self["Star" .. i])
        else
            WidgetUtils.Collapsed(self["Star" .. i])
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
    if Weapon.IsRead(self.tbData.pItem) then
        WidgetUtils.Collapsed(self.New)
    else
        WidgetUtils.HitTestInvisible(self.New)
    end
end

function tbClass:SetIcon(Icon, Color, Detail, uiType)
    SetTexture(self.ImgType, Item.WeaponTypeIcon[Detail])
    SetTexture(self.Icon, Icon)
    if uiType == "role" then
        SetTexture(self.ImgQuality, Weapon.WeaponColor[Color])
    else
        SetTexture(self.ImgQuality, Item.ItemListColorIcon[Color])
    end
    if self.ImgRoleselect then
        SetTexture(self.ImgRoleselect, Icon)
    end
    if self.Logo then
        SetTexture(self.Logo, Icon)
    end
    if self.ImgQuality2 then
        SetTexture(self.ImgQuality2, Item.RoleColor2[Color])
    end
    if self.QualityBg then
        SetTexture(self.QualityBg, Item.WeaponColorIcon[Color])
    end
end

return tbClass
