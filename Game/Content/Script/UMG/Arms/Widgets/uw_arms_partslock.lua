-- ========================================================
-- @File    : uw_arms_partslock.lua
-- @Brief   : 武器特殊配件
-- ========================================================

---@class tbClass
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnInfo, function() if self.partInfo then UI.Open("ItemInfo", table.unpack(self.partInfo)) end end)
end
---@param pWeapon UWeaponItem
function tbClass:Set(pWeapon, bShowDefault)
    WidgetUtils.Collapsed(self.Lock)
    WidgetUtils.Collapsed(self.Unclock)
    WidgetUtils.Collapsed(self.Empty)
    WidgetUtils.Collapsed(self.Icon)
    WidgetUtils.Collapsed(self.BtnInfo)

    self.pWeapon = pWeapon
    self.partInfo = Weapon.GetMaxLvPart(self.pWeapon)
    if self.partInfo then
        WidgetUtils.Visible(self.BtnInfo)
        WidgetUtils.HitTestInvisible(self.Icon)
        local g, d, p, l = table.unpack(self.partInfo)
        local partTemplate = UE4.UItemLibrary.GetItemTemplateByGDPL(g, d, p, l)
        SetTexture(self.Icon, partTemplate.Icon)

        local gdpl = string.format('%s-%s-%s-%s', self.pWeapon:Genre(), self.pWeapon:Detail(), self.pWeapon:Particular(), self.pWeapon:Level())
        local tbInfo = json.decode(me:GetStrAttribute(Weapon.PART_LOCK_GID, Weapon.PART_LOCK_SID)) or {}
        if tbInfo[gdpl] then
            WidgetUtils.HitTestInvisible(self.Unclock)
        else
            WidgetUtils.HitTestInvisible(self.Lock)
        end
    else
        if bShowDefault then
            WidgetUtils.HitTestInvisible(self.Empty)
        else
            WidgetUtils.Collapsed(self.Empty)
        end
    end
end

return tbClass