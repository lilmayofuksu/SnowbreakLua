-- ========================================================
-- @File    : umg_open_world_fadein.lua
-- @Brief   : 开放世界淡入淡出
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    print("open world player fadein")
end

function tbClass:OnOpen(bFadein)
    print("onopen world player fadein")
    self:PlayAnimation(self.FadeIn, 0, 1, bFadein and UE4.EUMGSequencePlayMode.Forward or UE4.EUMGSequencePlayMode.Reverse, 1, false)
    UE4.Timer.Add(1, function()
        if UI.IsOpen(self.sName) then
            UI.Close(self)
        end
    end)
end

function tbClass:OnClose()
    
end

return tbClass