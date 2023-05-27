-- ========================================================
-- @File    : umg_common_armslevel_tips.lua
-- @Brief   : 武器升级
-- ========================================================
---@class tbClass
---@field ListArmsLevelAtt UListView
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.ListFactory = Model.Use(self)
    self.ListArmsLevelAtt:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

function tbClass:OnOpen(pWeapon, nOldLevel, fCloseCallback)
    self.fCloseCallback = fCloseCallback
    Audio.PlaySounds(3014)
    self.pWeapon = pWeapon
    SetTexture(self.ImgArms1, pWeapon:Icon())

    -- self.TxtLevelNum:SetText(string.format("%s/%s", pWeapon:EnhanceLevel(), Item.GetMaxLevel(pWeapon)))
    self.TxtLevelNum:SetText(string.format("%s", pWeapon:EnhanceLevel()))

    self:DoClearListItems(self.ListArmsLevelAtt)

    local tbShowAttr = {UE4.EWeaponAttributeType.Attack}

    for _, nType in ipairs(tbShowAttr) do
        local Type = UE4.UUMGLibrary.GetEnumValueAsString("EWeaponAttributeType", nType)
        local nNow = UE4.UItemLibrary.GetWeaponAbilityValueToStr(nType, self.pWeapon, nOldLevel)
        local nNew = UE4.UItemLibrary.GetWeaponAbilityValueToStr(nType, self.pWeapon, self.pWeapon:EnhanceLevel())
        local tbParam = {
            sName = Text(string.format("attribute.%s", "Attack")),
            ECate = Type,
            nNow = nNow,
            nAdd = nNew
        }
        local NewObj = self.ListFactory:Create(tbParam)
        self.ListArmsLevelAtt:AddItem(NewObj)
    end
end

function tbClass:OnClose()
    if self.fCloseCallback then
        self.fCloseCallback()
    end
end

return tbClass
