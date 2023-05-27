-- ========================================================
-- @File    : uw_dungeonsboss_reward.lua
-- @Brief   : boss挑战奖励条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:DoClearListItems(self.ListItem)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data
    if not self.tbParam then return end

    self.Factory = self.Factory or Model.Use(self)

    if self.tbParam.Integral then
        self.TxtLevel:SetText(self.tbParam.Integral)
        self.TxtLevel_1:SetText(self.tbParam.Integral)
    end

    self:DoClearListItems(self.ListItem)
    if self.tbParam.tbAward then
        for _, v in pairs(self.tbParam.tbAward) do
            local tbParam = {G = v[1], D = v[2], P = v[3], L = v[4], N = v[5] or 1}
            local pObj = self.Factory:Create(tbParam)
            self.ListItem:AddItem(pObj)
        end
    end

    if (self.tbParam.Mileage or self.tbParam.funGet) and self.tbParam.Integral then
        if self.tbParam.isReceive then
            WidgetUtils.Collapsed(self.PanelGain)
            WidgetUtils.Collapsed(self.PanelLock)
            WidgetUtils.Collapsed(self.WhiteBg)
            WidgetUtils.Collapsed(self.Level)
            WidgetUtils.HitTestInvisible(self.Level2)
            WidgetUtils.HitTestInvisible(self.PanelCompleted)
        else
            WidgetUtils.Collapsed(self.Level2)
            WidgetUtils.HitTestInvisible(self.WhiteBg)
            WidgetUtils.HitTestInvisible(self.Level)
            if self.tbParam.isComplete then
                WidgetUtils.Collapsed(self.PanelCompleted)
                WidgetUtils.Collapsed(self.PanelLock)
                WidgetUtils.SelfHitTestInvisible(self.PanelGain)
                BtnClearEvent(self.BtnGot)
                BtnAddEvent(self.BtnGot, function()
                    if self.tbParam.funGet then
                        self.tbParam.funGet()
                    else
                        BossLogic.GetReward(self.tbParam.Mileage)
                    end
                end)
            else
                WidgetUtils.Collapsed(self.PanelGain)
                WidgetUtils.Collapsed(self.PanelCompleted)
                WidgetUtils.SelfHitTestInvisible(self.PanelLock)
                BtnClearEvent(self.BtnLock)
                BtnAddEvent(self.BtnLock, function() UI.ShowTip(Text("ui.TxtNotAchieve")) end)
            end
        end
    end
end

return tbClass