-- ========================================================
-- @File    : AutoPSOGameMode.lua
-- @Brief   : 自动跑PSO模式
-- ========================================================

local tbClass = Class()

function tbClass:ReceiveBeginPlay()
    print("AutoPSOGameMode ReceiveBeginPlay");
    self.PSOSystem = UE4.UGameLibrary.GetAutoPSOSystem(self);

    UE4.Timer.Add(1, function()
        self:Begin()
    end)
end

function tbClass:Begin()
    UI.Open("Fight")
    UI.Open("AutoPSO")
    self.PSOSystem:OnMapReady()
end

function tbClass:ReceiveEndPlay()
    self.PSOSystem:OnMapExit()
    print("AutoPSOGameMode ReceiveEndPlay");
end

return tbClass