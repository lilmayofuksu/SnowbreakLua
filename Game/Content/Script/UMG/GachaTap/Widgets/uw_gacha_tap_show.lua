-- ========================================================
-- @File    : uw_gacha_tap_show.lua
-- @Brief   : 抽奖结果展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Set(g, d, p, l)
    local pTemplate = UE4.UItem.FindTemplate(g, d, p, l)
    
    local nActiveIndex = 0

    if g == 1 then
        if pTemplate.Color == 5 then
            nActiveIndex = 1
        else
            nActiveIndex = 0
        end
    else
        nActiveIndex = 2
    end

    self.Switcher:SetActiveWidgetIndex(nActiveIndex)

    local pShowWidget = self.Switcher:GetActiveWidget()

    if pShowWidget then
        WidgetUtils.HitTestInvisible(pShowWidget)
        pShowWidget:Set(pTemplate)

        self.pShowWidget = pShowWidget
    end
end

function tbClass:PlayInfo(fCallback)
    if self.pShowWidget then
        self.pShowWidget:PlayInfo(fCallback)
    end
end


function tbClass:PlayShow(fCallback)
    if self.pShowWidget then
        self.pShowWidget:PlayShow(fCallback)
    end
end

function tbClass:PlayClose(fCallback)
    if self.pShowWidget then
        self.pShowWidget:PlayClose(fCallback)
    end
end

return tbClass