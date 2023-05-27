-- ========================================================
-- @File    : uw_dungeonsboss_score.lua
-- @Brief   : boss挑战奖励领取界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListScore)
    BtnAddEvent(self.BtnQuick, function() BossLogic.OneClicReward() end)
    self.Popup:SetFunClose(function ()
        UI.Close(self)
    end)
end

function tbClass:OnOpen()
    self:Show()
end

function tbClass:Show()
    self.Factory = self.Factory or Model.Use(self)
    self.TxtNum:SetText(BossLogic.GetTotalIntegral())
    self.ListScore:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    self:UpdateList()
    self.ListScore:PlayAnimation(0);
end

function tbClass:UpdateList()
    local AvailableNum = 0  ---可领取的数量
    self:DoClearListItems(self.ListScore)
    if not BossLogic.tbAwardCfg then return end
    local integral = BossLogic.GetTotalIntegral()
    for i, info in pairs(BossLogic.tbAwardCfg) do
        local cfg = {}
        cfg.Mileage = i
        cfg.Integral = info.nScoreCount
        cfg.isReceive = BossLogic.IsReceive(i)
        cfg.isComplete = integral >= info.nScoreCount
        cfg.tbAward = info.tbScoreAward
        local pObj = self.Factory:Create(cfg)
        self.ListScore:AddItem(pObj)
        if cfg.isComplete and not cfg.isReceive then
            AvailableNum = AvailableNum + 1
        end
    end
    if AvailableNum > 0 then
        WidgetUtils.Visible(self.BtnQuick)
    else
        WidgetUtils.Collapsed(self.BtnQuick)
    end
end

return tbClass