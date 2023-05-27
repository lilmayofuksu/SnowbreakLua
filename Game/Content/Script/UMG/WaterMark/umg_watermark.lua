-- ========================================================
-- @File    : umg_watermark.lua
-- @Brief   : 水印界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    if me and me:Id() ~= 0 then
        self.TxtID:SetText("ID:" .. me:Id())
    else
        self.TxtID:SetText("")
    end
end

return tbClass
