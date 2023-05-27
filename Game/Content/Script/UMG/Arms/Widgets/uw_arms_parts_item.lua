-- ========================================================
-- @File    : uw_arms_parts_item.lua
-- @Brief   : 武器配件
-- ========================================================
---@class tbClass
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSelect, function()if self.Click then self.Click(self.Type) end end)
end

---初始化
function tbClass:Init(InPart, InType, pWeapon, InClick)
    self.Click = InClick
    self.Type = InType

    local ShowName = Text("ui.weapon_part_" .. InType)
    if not InPart then
        WidgetUtils.Collapsed(self.HaveNode)
        WidgetUtils.HitTestInvisible(self.NotHave)
    else
        WidgetUtils.HitTestInvisible(self.HaveNode)
        WidgetUtils.Collapsed(self.NotHave)
        ShowName = Text(InPart:I18N())
    end
    self.TxtShadow:SetText(ShowName)
    self.TxtName1:SetText(ShowName)
    self.TxtName0:SetText(ShowName)
    SetTexture(self.Image, WeaponPart.GetTypeIcon(InType), true)

    local bNew = Weapon.CheckSlotRed(pWeapon, InType)
    if bNew then
        WidgetUtils.HitTestInvisible(self.New)
    else
        WidgetUtils.Collapsed(self.New)
    end
    
end
return tbClass
