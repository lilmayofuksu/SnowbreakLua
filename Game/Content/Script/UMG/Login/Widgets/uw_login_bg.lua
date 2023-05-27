-- ========================================================
-- @File    : uw_login_bg.lua
-- @Brief   : 服务器条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    local info = LoginBG.GetBGInfo()
    if not info then return end

    local widgetInfo = info.widget
    if not widgetInfo then return end

    local nShowType = widgetInfo[1]
    if not nShowType then return end

    self.Switcher:SetActiveWidgetIndex(nShowType - 1)

    local pShowWidget = self.Switcher:GetActiveWidget()
    if not pShowWidget then return end
    WidgetUtils.HitTestInvisible(pShowWidget)
    pShowWidget:Show(widgetInfo)

    if (info.music and info.music ~= "") then 
        UE4.UWwiseLibrary.SetStateGroup(info.music)
    end        
end

return tbClass