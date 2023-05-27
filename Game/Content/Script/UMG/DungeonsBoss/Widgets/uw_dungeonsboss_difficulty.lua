-- ========================================================
-- @File    : uw_dungeonsboss_difficulty.lua
-- @Brief   : boss挑战难度选择条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnDiff, function()
        if self.funClick then
            self.funClick()
        end
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data

    if not self.tbParam then return end
    self.tbParam.SetSelect = function(_, isSelect)
        if isSelect then
            WidgetUtils.HitTestInvisible(self.PanelSelect)
        else
            WidgetUtils.Collapsed(self.PanelSelect)
        end
    end
    self.funClick = self.tbParam.UpdateSelect

    local bLock = self.tbParam.index > me:GetAttribute(BossLogic.GID, BossLogic.DiffRecordID) + 1
    self.PanelLock:SetVisibility(bLock and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Collapsed)

    if self.tbParam.cfg then
        self.TxtNormalName:SetText(Text("bossentries.Diff", self.tbParam.cfg[1], self.tbParam.cfg[2]))
        self.TxtSelectName:SetText(Text("bossentries.Diff", self.tbParam.cfg[1], self.tbParam.cfg[2]))
    end
    if BossLogic.GetNowDifficulty() ~= self.tbParam.index then
        WidgetUtils.Collapsed(self.PanelSelect)
    else
        WidgetUtils.HitTestInvisible(self.PanelSelect)
    end
end

return tbClass
