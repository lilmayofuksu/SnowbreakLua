-- ========================================================
-- @File    : umg_scan.lua
-- @Brief   : 扫码界面
-- ========================================================
---@class tbClass
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(
        self.BtnClose,
        function()
            UI.Close(self)
        end
    )
end

function tbClass:OnOpen()
end

return tbClass
