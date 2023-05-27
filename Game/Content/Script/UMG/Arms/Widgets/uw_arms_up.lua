-- ========================================================
-- @File    : uw_arms_up.lua
-- @Brief   : 武器升级
-- ========================================================

---@class tbClass
---@field pWeapon UWeaponItem
---@field Switcher UWidgetSwitcher
local tbClass = Class("UMG.SubWidget")
 
function tbClass:OnActive(pWeapon, _, _, nReason)
    self.pWeapon = pWeapon
    if not self.pWeapon then return end
    self:AutoPage(nReason)
    Weapon.PreviewShow(self.pWeapon)
    Preview.PlayCameraAnimByCallback(self.pWeapon:Id(), PreviewType.weapon_lvup, nil)
    self:PlayAnimation(self.AllEnter)
end

function tbClass:AutoPage(nReason)
    local bMaxLevel = Weapon.IsMaxLevel(self.pWeapon)
    local bBreakMax = Item.IsBreakMax(self.pWeapon)
    local nPage = 0
    if bMaxLevel and bBreakMax then
        nPage = 2
    elseif bMaxLevel and not bBreakMax then
        nPage = 1
    else
        nPage = 0
    end

    if self.nPage == nPage then
        return
    end

    self.nPage = nPage

    self.Switcher:SetActiveWidgetIndex(nPage)

    local pPage = self.Switcher:GetWidgetAtIndex(nPage)
    if pPage then
        pPage:OnActive(self.pWeapon, self, nReason)
        WidgetUtils.PlayEnterAnimation(pPage)
    end
    
    self:CloseSelect()
end
 
 function tbClass:OnDisable()
     self.nPage = -1
     if UI.IsOpen('ItemInfo') then
         UI.Close('ItemInfo')
     end
 end

 function tbClass:ShowSelect()
    if self.Select == nil then
        self.Select = WidgetUtils.AddChildToPanel(self.Content, '/Game/UI/UMG/Widgets/uw_widgets_selectscreen.uw_widgets_selectscreen_C', 5)
    end
    return self.Select
 end

 function tbClass:CloseSelect()
    WidgetUtils.Collapsed(self.Select)
 end

 function tbClass:GetWidgetByPage(nPage)
    return self.Switcher:GetWidgetAtIndex(nPage)
 end

return tbClass