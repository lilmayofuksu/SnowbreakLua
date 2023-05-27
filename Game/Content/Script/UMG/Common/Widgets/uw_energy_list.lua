-- ========================================================
-- @File    : uw_energy_list.lua
-- @Brief   : 体力置换列表
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSeleted, function()
        if self.Data and self.Data.fCustomEvent then
            self.Data.fCustomEvent()
        end
    end)

    self.ExpirationTimer = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({
        self, function() if self.Data then self:SetExpiration() end end
    }, 1, true);
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nSelectEvent)
    EventSystem.Remove(self.nSetNumEvent)
    if self.ExpirationTimer then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.ExpirationTimer);
    end
end

function tbClass:OnListItemObjectSet(pObj)
    local tbData = pObj.Data
    self.Data = tbData
    self:SetLimit()
    self:SetNum()
    self:SetExpiration()
    self:SetSelected()
    self.Item:Display({
        nCashType = tbData.nCashType,
        G = tbData.G,
        D = tbData.D,
        P = tbData.P,
        L = tbData.L
    })

    EventSystem.Remove(self.nSetExpirationEvent)
    self.nSetExpirationEvent = EventSystem.OnTarget(self.Data, "SET_EXPIRATION",
                                                    function()
        self:SetExpiration()
    end)
    EventSystem.Remove(self.nSetNumEvent)
    self.nSetNumEvent = EventSystem.OnTarget(self.Data, "SET_NUM",
                                             function() self:SetNum() end)
    EventSystem.Remove(self.nSelectEvent)
    self.nSelectEvent = EventSystem.OnTarget(self.Data, "SET_SELECTED",
                                             function()
        self:SetNum();
        self:SetSelected()
    end)
end

function tbClass:SetLimit()
    if not self.Data.tbLimit then
        WidgetUtils.Collapsed(self.LimitToday)
        return
    end
    WidgetUtils.Visible(self.LimitToday)
    self.TxtLimitNum:SetText(table.concat(self.Data.tbLimit, "/"))
end

function tbClass:SetNum()
    if not self.Data.tbNum then
        WidgetUtils.Collapsed(self.TxtNum)
        return
    end
    WidgetUtils.Visible(self.TxtNum)
    self.TxtNum1:SetText(tostring(self.Data.tbNum[1]))
    self.TxtNum2:SetText(tostring(self.Data.tbNum[2]))
    if self.Data.tbNum[2] < self.Data.tbNum[1] then
        self.TxtNum2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#ee4735'))
    else
        self.TxtNum2:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#000000'))
    end
end

function tbClass:SetExpiration()
    local nTime = GetTime()
    WidgetUtils.Visible(self.TxtTime)

    if self.Data.tbLimit then
        WidgetUtils.Collapsed(self.TxtTime)
        return
    end

    if not self.Data.nExpiration then
        self.TxtTime:SetText(Text('ui.TxtPurchaseTip2'))
        self.TxtTime:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#111125'))
        return
    else
        self.TxtTime:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColorFromHex('#f04928'))
    end

    if self.Data.nExpiration > nTime then
        local nDay, nHour, nMin, nSec = TimeDiff(self.Data.nExpiration, nTime)
        if nDay > 0 then
            self.TxtTime:SetText(string.format(Text('ui.TxtNoticeSDay'), nDay))
        else
            self.TxtTime:SetText(string.format('%02d:%02d:%02d', nHour, nMin, nSec))
        end
    else
        self.TxtTime:SetText(Text("ui.expirated"))
    end
end

function tbClass:SetSelected()
    if self.Data.bSelected then
        WidgetUtils.Visible(self.Selected)
    else
        WidgetUtils.Collapsed(self.Selected)
    end
end

return tbClass
