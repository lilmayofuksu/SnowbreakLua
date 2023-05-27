-- ========================================================
-- @File    : uw_account_leven.lua
-- @Brief   : 关卡角色
-- ========================================================
local tbClass = Class("UMG.SubWidget")

---@param pCard UCharacterCard
function tbClass:Construct()
    self.TxtLevel:SetText(me:Level())
    local nNow = me:Exp()
    local nMax = Player.GetMaxExp(me:Level()) or 1
    if Launch.ExpData then
        self.TxtExp:SetNumAnimation(Launch.ExpData.PlayerExp.nNow, nNow, nNow .. '/' .. nMax, "{0}/{1}", Launch.ExpData.PlayerExp.nMax, nMax)
        local tbPlayerOldExp = Launch.ExpData.PlayerExp
        local TotalTime = 0
        local nOldPercent = tbPlayerOldExp.nNow / tbPlayerOldExp.nMax
        local nNowPercent = nNow / nMax
        local ExpDelta = tbPlayerOldExp.nMax == nMax and nNowPercent - nOldPercent or nNowPercent - nOldPercent + 1
        self.Exp:SetPercent(nOldPercent);
        UE4.Timer.Add(0.8, function()
            self.TimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                function()
                    if TotalTime >= 1 then
                        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
                        self.Exp:SetPercent(nNowPercent);
                        return
                    end
                    TotalTime = TotalTime + 0.01
                    nOldPercent =  ExpDelta * 0.01 + nOldPercent
                    if nOldPercent > 1 then
                        nOldPercent = nOldPercent - 1
                    end
                    self.Exp:SetPercent(nOldPercent);
                end
            },
            0.01,
            true)
        end)
    else
        self.TxtExp:SetText(nNow .. '/' .. nMax)
        self.Exp:SetPercent(nNow / nMax)
        return
    end

end

return tbClass