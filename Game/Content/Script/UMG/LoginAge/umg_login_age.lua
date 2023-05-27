-- ========================================================
-- @File    : umg_login_age.lua
-- @Brief   : 登录提示
-- ========================================================
---@class tbClass
local tbClass = Class("UMG.BaseWidget")


function tbClass:OnInit()
    BtnAddEvent(self.BtnOK, function() UI.Close(self) end)
    BtnAddEvent(self.BtnClose, function() UI.Close(self) end)
end

return tbClass