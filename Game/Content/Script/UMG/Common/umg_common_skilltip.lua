-- ========================================================
-- @File    : umg_common_skilltip.lua
-- @Brief   : 词条解释
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnOK, function ()
        UI.Close(self)
    end)
end

function tbClass:OnOpen(sName, sDescribe)
    self.TxtTitle:SetText(Text(sName))
    self.TxtContent:SetContent(Text(sDescribe))
end

return tbClass