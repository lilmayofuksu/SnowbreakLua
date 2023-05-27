-- ========================================================
-- @File    : uw_account_role.lua
-- @Brief   : 关卡角色
-- ========================================================
local tbClass = Class("UMG.SubWidget")
---@param pCard UCharacterCard
---@field Percent UImage
function tbClass:Set(pCard, nAdd, nOnlineId)
    if nOnlineId then
        WidgetUtils.SelfHitTestInvisible(self)
        local pCard = pCard or me:GetCharacterCard(PlayerSetting.GetShowCardID())
        SetTexture(self.ImgIcon, pCard:Icon())
        self.TxtLv:SetText(me:Level())
        local cfg = OnlineLevel.GetConfig(nOnlineId)


        -- self.TxtAdd:SetText())
        self.TxtAdd:SetNumAnimation(0, cfg and cfg.nPlayerExp or 0, '+' .. (cfg and cfg.nPlayerExp or 0), "+{0}")

        local nNow = me:Exp()
        local nMax = Player.GetMaxExp(me:Level()) or 1
        local nPercent = nNow / nMax
        self.Percent:SetPercent(nPercent);
        return
    end

    if pCard then
        WidgetUtils.SelfHitTestInvisible(self)
    else
        WidgetUtils.Collapsed(self)
        return
    end
    SetTexture(self.ImgIcon, pCard:Icon())
    WidgetUtils.Collapsed(self.Image_196)

    if pCard:IsTrial() then
        WidgetUtils.Collapsed(self.HorizontalBox_117)
    else
        -- self.TxtAdd:SetText('+' .. nAdd)
        self.TxtAdd:SetNumAnimation(0, nAdd, '+' .. nAdd, "+{0}")
    end
    if Launch.ExpData then
        local tbOldExp = Launch.ExpData.CardExp[string.format("%d-%d-%d-%d", pCard:Genre(), pCard:Detail(), pCard:Particular(), pCard:Level())]
        if not tbOldExp then
            local nPercent = pCard:Exp() / Item.GetUpgradeExp(pCard)
            self.TxtLv:SetText(pCard:EnhanceLevel())
            self.Percent:SetPercent(nPercent);
            return
        end
        self.TxtLv:SetText(tbOldExp.nLevel)
        self:SetBarPercent(pCard, tbOldExp, tbOldExp.nLevel)
    else
        self.TxtLv:SetText(pCard:EnhanceLevel())
        local nPercent = pCard:Exp() / Item.GetUpgradeExp(pCard)
        self.Percent:SetPercent(nPercent);
    end
end

function tbClass:SetBarPercent(pCard, tbOldExp, nOldLevel)
    local TotalTime = 0
    local nOldPercent = tbOldExp.nNow / tbOldExp.nMax
    self.Percent:SetPercent(nOldPercent);
    local nNowPercent = pCard:Exp() / Item.GetUpgradeExp(pCard)
    local ExpDelta = nNowPercent - nOldPercent + pCard:EnhanceLevel() - tbOldExp.nLevel
    UE4.Timer.Add(0.8, function()
        self.TimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                if TotalTime >= 1 then
                    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
                    self.Percent:SetPercent(nNowPercent);
                    return
                end
                TotalTime = TotalTime + 0.01
                nOldPercent =  ExpDelta * 0.01 + nOldPercent
                if nOldPercent > 1 then
                    nOldPercent = nOldPercent - 1
                    nOldLevel = nOldLevel + 1
                    self.TxtLv:SetText(nOldLevel)
                end
                self.Percent:SetPercent(nOldPercent);
            end
        },
        0.01,
        true)
    end)

end

return tbClass