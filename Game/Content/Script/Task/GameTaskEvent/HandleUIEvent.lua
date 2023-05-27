-- ========================================================
-- @File    : KillMonsterBase.lua
-- @Brief   :
-- @Author  :
-- @Date    :
-- ========================================================

---@class HandleUIEvent : GameTask_Event
local HandleUI = Class()

function HandleUI:OnTrigger()
    local Widget = UI.GetUI(self.UIName)
    if not Widget then 
        return false
    end
    if self.bClose then
        WidgetUtils.Collapsed(Widget)
    else
        WidgetUtils.Visible(Widget)
    end
    return true
end

return HandleUI
