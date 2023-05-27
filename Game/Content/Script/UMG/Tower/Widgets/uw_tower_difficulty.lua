-- ========================================================
-- @File    : uw_tower_difficulty.lua
-- @Brief   : 爬塔难度选择界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.SelectedDiff = 1
    for i = 1, 3 do
        if self["BtnZone"..i] then
            BtnAddEvent(self["BtnZone"..i], function ()
                self.SelectedDiff = i
                self:UpdatePanel()
            end)
        end
        if ClimbTowerLogic.tbDiffConf[i] then
            local str = ClimbTowerLogic.tbDiffConf[i].Level1 .. "-" .. ClimbTowerLogic.tbDiffConf[i].Level2
            self["TxtNum"..i]:SetText(str)
            self["TxtNumSelected"..i]:SetText(str)
        end
    end
    BtnAddEvent(self.BtnClose, function ()
        local ui = UI.GetUI("Tower")
        if ui and ui:IsOpen() then
            ui.tbModeItem[1].UpdateSelect(1)
            WidgetUtils.Collapsed(self)
        end
    end)
    BtnAddEvent(self.BtnOK, function ()
        Text("TowerDifficultyTips")
        UI.Open(
            "MessageBox", 
            Text("ui.TxtDungeonsTowerTip3", Text("ui.TxtDungeonsTowerDifficulty"..self.SelectedDiff)),
            function()
                ClimbTowerLogic.SetLevelDiff(self.SelectedDiff) 
            end,
            nil, nil, nil, nil, nil, nil,
            Text("ui.TowerDifficultyTips")
        )
    end)
    self:UpdatePanel()
end

function tbClass:UpdatePanel()
    for i = 1, 3 do
        if self.SelectedDiff == i then
            WidgetUtils.HitTestInvisible(self["Selected"..i])
        else
            WidgetUtils.Collapsed(self["Selected"..i])
        end
    end
end

return tbClass
