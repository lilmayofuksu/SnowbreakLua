-- ========================================================
-- @File    : uw_arms_part.lua
-- @Brief   : 武器配件
-- ========================================================
---@class tbClass
---@field MainAttr UListView
local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
    self.MainAttr:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.tbShow = {
        {UE4.EWeaponSlotType.Muzzle, self.Barrel},
        {UE4.EWeaponSlotType.TopGuide, self.Sight},
        {UE4.EWeaponSlotType.Butt, nil},
        {UE4.EWeaponSlotType.Ammunition, self.Clip},
        {UE4.EWeaponSlotType.LowerGuide, self.Grip},
    }
    self.ListFactory = Model.Use(self)

    self.Check.OnCheckStateChanged:Add(self, function(_, bCheck)
        if bCheck then
            WidgetUtils.HitTestInvisible(self.CheckMark)
        else
            WidgetUtils.Collapsed(self.CheckMark)
        end
        Weapon.SetShowDefaultPart(self.pWeapon, bCheck)
    end)
end

function tbClass:OnDestruct()
    self:OnDisable()
end

function tbClass:OnActive(pWeapon)
    self.pWeapon = pWeapon
    if not self.pWeapon then return end

    local bDefaultPart = Weapon.IsShowDefaultPart(pWeapon)
    self.Check:SetIsChecked(bDefaultPart)
    if bDefaultPart then
        WidgetUtils.HitTestInvisible(self.CheckMark)
    else
        WidgetUtils.Collapsed(self.CheckMark)
    end


    local tbLimit = Weapon.GetWeaponPartsLimit(self.pWeapon) or {}
    for nIdx, tbInfo in ipairs(self.tbShow) do
        local nType = tbInfo[1]
        local Widget = tbInfo[2]
        local bLimit = (tbLimit[nIdx] == 0)
        if (not bLimit) and Widget then
            WidgetUtils.SelfHitTestInvisible(Widget)
            local Slot = self.pWeapon:GetWeaponSlot(nType)
            Widget:Init(Slot, nType, pWeapon , function(t) UI.Open("ArmspartsItem", self.pWeapon, t) end )
        else
            WidgetUtils.Collapsed(Widget)
        end
    end

    ---属性显示
   
    local tbAttr = Weapon.GetPartAttr(self.pWeapon)

    if next(tbAttr) == nil then
        WidgetUtils.Collapsed(self.AttrContent)
    else
        WidgetUtils.HitTestInvisible(self.AttrContent)
        self:DoClearListItems(self.MainAttr)
        local nAddNum = 0
        for sKey, nValue in pairs(tbAttr) do
            local sDes = WeaponPart.ConvertType(sKey, nValue)
            local tbParam = {sDes = "attribute." .. sKey, nValue = sDes, nIcon = Resource.GetAttrPaint(sKey), nFlag = 1}
            local pObj = self.ListFactory:Create(tbParam)
            self.MainAttr:AddItem(pObj)
            nAddNum = nAddNum + 1
        end

        for i = nAddNum + 1, 9 do
            local tbParam = {nFlag = 2}
            local pObj = self.ListFactory:Create(tbParam)
            self.MainAttr:AddItem(pObj)
        end
    end

    Preview.PlayCameraAnimByCallback(self.pWeapon:Id(), PreviewType.weapon_info)

    self.pFloor = UE4.UUMGLibrary.FindActorByName(self, 'entry_db_sm01_22')
    self:ToggleLine(false)

    for i = 1, 4 do
        local pImg = self['Rarity0' .. i]
        if pImg then
            Color.SetQuality(pImg, self.pWeapon:Color())
        end
    end
end

function tbClass:OnDisable()
    self:ToggleLine(true)
    if IsValid(self.BGActor) then
        self.BGActor:K2_DestroyActor()
        self.BGActor = nil
    end
    self.pFloor = nil
end

function tbClass:ToggleLine(bShow)
    if self.pFloor and self.pFloor.StaticMeshComponent then
        local nValue = bShow and 1 or 0
        self.pFloor.StaticMeshComponent:SetScalarParameterValueOnMaterials('Grid', nValue)
    end
end

return tbClass
