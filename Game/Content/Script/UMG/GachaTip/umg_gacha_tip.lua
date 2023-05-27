-- ========================================================
-- @File    : umg_gacha_tip.lua
-- @Brief   : 抽奖提示
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnCancel, function() UI.Close(self) end)
    BtnAddEvent(self.BtnSelect, function() self:SetTipCheck(Gacha.SetIsTip(not Gacha.GetIsTip())) end)
    BtnAddEvent(self.BtnConfirm, function() if self.fConfirm then self.fConfirm() end UI.Close(self) end)
end

function tbClass:OnOpen(nId, nTime, fConfirm)
    if not nId or not nTime then UI.Close(self) return end

    self.nId = nId
    self.nTime = nTime
    self.fConfirm = fConfirm
    local tbCfg = Gacha.GetCfg(nId)
    if not tbCfg then return end

    if nTime == 10 then
        self.TxtCost:SetText(Text(string.format('gacha.%s_ten', tbCfg.sDes)))
    end
    if nTime == 1 then
        self.TxtCost:SetText(Text(string.format('gacha.%s_one', tbCfg.sDes)))
    end
    
    self:SetTipCheck(Gacha.GetIsTip())
    WidgetUtils.SelfHitTestInvisible(self.PanelCost)
    if tbCfg then
        local bCan, tbGDPL = tbCfg:CheckCost(self.nTime)
        local g, d, p, l, n = table.unpack(tbGDPL)
        self.Item:Display({ G = g, D = d, P = p, L = l, N = n, bForceShowNum = false})
    end
end

function tbClass:SetTipCheck(bTip)
    if bTip then
        WidgetUtils.Collapsed(self.Check)
    else
        WidgetUtils.HitTestInvisible(self.Check)
    end
end

return tbClass