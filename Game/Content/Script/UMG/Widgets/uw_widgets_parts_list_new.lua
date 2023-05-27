-- ========================================================
-- @File    : uw_widgets_parts_list_new.lua
-- @Brief   : 武器配件展示条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClick,  function() self.tbData.OnTouch() end )
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nSelectEvent)
    EventSystem.Remove(self.nNewEvent)
    EventSystem.Remove(self.nPlayAnimation)
end

---被添加时初始化
---@param pObj table
function tbClass:OnListItemObjectSet(pObj)
    self.tbData = pObj.Data
    if not self.tbData then return end

    if self.tbData.nFlag == 2 then
        WidgetUtils.SelfHitTestInvisible(self.PanelNot)
        WidgetUtils.Collapsed(self.Content)
        return
    else
        WidgetUtils.Collapsed(self.PanelNot)
        WidgetUtils.SelfHitTestInvisible(self.Content)
    end

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

    self:Selected()
    self:SetLocked()

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
        SetTexture(self.ImgQuality, Item.ItemIconColorIcon[pItem:Color()])
    else
        if self.tbData.nFlag == 0 then
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
            SetTexture(self.ImgQuality, Item.ItemIconColorIcon[pTemplate.Color])
    
           if WeaponPart.GetPart(g, d, p, l) == nil then
                WidgetUtils.HitTestInvisible(self.PanelLock)
           end
        end
    end
    self.g, self.d, self.p, self.l = g, d, p, l

    if g and d and p and l then
        local nType = WeaponPart.GetAllowWeaponType(WeaponPart.GetPartConfigByGDPL(g, d, p, l))
        SetTexture(self.ImgType, Item.WeaponTypeIcon[nType])
        self:SetLocked()
        self:SetNew()
    end
end

function tbClass:Selected()
    if self.tbData.bSelect then
        WidgetUtils.Visible(self.PanelSelect)
        self:PlayAnimationForward(self.SelectAnim)
    else
        WidgetUtils.Hidden(self.PanelSelect)
        self:PlayAnimationReverse(self.SelectAnim)
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
