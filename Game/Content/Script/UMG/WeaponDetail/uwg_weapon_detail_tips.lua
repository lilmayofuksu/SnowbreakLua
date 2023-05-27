-- ========================================================
-- @File    : WeaponDetail/uwg_weapon_detail_tips.lua
-- @Brief   : 武器详情
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function() UI.Close(self) end)
end

function tbClass:OnOpen(nWeaponID)


end

return tbClass