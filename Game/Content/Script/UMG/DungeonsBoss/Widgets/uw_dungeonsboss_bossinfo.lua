-- ========================================================
-- @File    : uw_dungeonsboss_bossinfo.lua
-- @Brief   : boss信息
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.FightBtn, function()
        if self.funcOnClickFight then
            self.funcOnClickFight()
        end
    end)

    BtnAddEvent(self.Button, function()
        if self.funcOnClickInfo then
            self.funcOnClickInfo()
        end
    end)

    BtnAddEvent(self.BtnReset, function()
        UI.Open("MessageBox", Text("bossentries.Replace"), BossLogic.Reset)
    end)
end

return tbClass
