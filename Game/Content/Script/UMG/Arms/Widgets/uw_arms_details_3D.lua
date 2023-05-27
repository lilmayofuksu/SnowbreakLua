-- ========================================================
-- @File    : uw_arms_details_3D.lua
-- @Brief   : 武器详情显示界面
-- ========================================================

---@class tbClass
---@field MainAttr UListView
---@field SubAttr UListView
---@field ImgNum1 UImage
---@field ImgNum2 UImage
local tbClass = Class("UMG.SubWidget")


function tbClass:Construct()
    self.MainAttr:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

function tbClass:Set(pWeapon, nForm)
    self.pWeapon = pWeapon
    self.nForm = nForm
    if not self.pWeapon then
        return
    end
    self.ListFactory = Model.Use(self)
    self:ShowDetails()
end

---UI数据刷新
function tbClass:ShowDetails()
    if not self.pWeapon then return end

    self.Basic:UpdatePanel(self.pWeapon, self.nForm)

    if self.nForm then
        WidgetUtils.Collapsed(self.Partslock)
    else
        WidgetUtils.Visible(self.Partslock)
    end

    self:ShowRangeInfo()

    self.Atktype:ShowSubAttr(self.pWeapon)


    ---属性显示
    local showAttr = function(pContent, tbAttr)
        self:DoClearListItems(pContent)
        for _, nType in ipairs(tbAttr) do
            local sKey = UE4.UUMGLibrary.GetEnumValueAsString("EWeaponAttributeType", nType)
            local nValue = Weapon.ConvertDes(nType, UE4.UItemLibrary.GetWeaponAbilityValueToStr(nType, self.pWeapon))
            local tbParam = {sKey = sKey, sPreWord = Text("attribute." .. sKey), nIcon = Resource.GetAttrPaint(sKey), nNum = nValue}
            local pObj = self.ListFactory:Create(tbParam)
            pContent:AddItem(pObj)
        end
    end
    showAttr(self.MainAttr, Weapon.tbShowAttr)

    self.Partslock:Set(self.pWeapon, false)
    self:PlayAnimation(self.AllEnter)
end

---显示射程信息
function tbClass:ShowRangeInfo()
    local nDis1, nDis2 = Weapon.GetDamageDisValue(self.pWeapon)
    self.TxtNum1:SetText(math.ceil(nDis1 / 100) .. Text('ui.TxtDisUnit'))
    self.TxtNum2:SetText(math.ceil(nDis2 / 100) .. Text('ui.TxtDisUnit'))

    local nWidth, nHigh = 480 , 80

    local n1 = nDis1 / nDis2 * nWidth
    local n2 = nWidth - n1
    local n3 = math.sqrt(nHigh * nHigh + n2 * n2)

    self.ImgNum1:SetBrushSize(UE4.FVector2D(n1, 2))

    local pSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ImgNum2)
    if pSlot then
        pSlot:SetSize(UE4.FVector2D(n3, 2))
        pSlot:SetPosition(UE4.FVector2D(n1, -80))
    end

    local nAngle = 180 * math.acos(nHigh / n3) / 3.14
    self.ImgNum2:SetRenderTransformAngle(90 - nAngle)
end

return tbClass
