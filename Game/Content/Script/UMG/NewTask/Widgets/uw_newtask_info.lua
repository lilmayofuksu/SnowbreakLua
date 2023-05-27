-- ========================================================
-- @File    : umg_newtask_info.lua
-- @Brief   : 介绍图按钮widget
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnInfo, function ()
        if self.FunClick then
            self.FunClick()
        end
    end)
end

function tbClass:SetBtnListener(func)
    self.FunClick = func
end

function tbClass:InitHelpImages(id)
    if not Activity.CheckOpen(id) then
        WidgetUtils.Collapsed(self)
        return
    end

    self.FunClick = function ()
        UI.Open("HelpImages", id)
    end
end

return tbClass