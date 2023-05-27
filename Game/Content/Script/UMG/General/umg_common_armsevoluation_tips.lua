-- ========================================================
-- @File    : umg_common_armsevoluation_tips.lua
-- @Brief   : 武器进化成功提示界面
-- ========================================================
---@class tbClass
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function() UI.Close(self)  end)
end

function tbClass:OnOpen(pWeapon, fClose)
    Audio.PlaySounds(3014)
    self.pWeapon = pWeapon
    self.Skill:Set(pWeapon)
    self.fClose = fClose
end

function tbClass:OnClose()
    if self.fClose then
        self.fClose()
    end
end

return tbClass
