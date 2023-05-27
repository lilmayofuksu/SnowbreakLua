-- ========================================================
-- @File    : uw_setup_uisafe.lua
-- @Brief   : 设置
-- ========================================================

local tbClass = Class("UMG.SubWidget")


function tbClass:Construct()
    self.nMaxValue = self.SliderTurn.MaxValue

   BtnAddEvent(self.BtnMinus, function()
    local nNow = self.SliderTurn:GetValue()
    local nNew = math.max(0, nNow - 1)
    self:RefreshUI(nNew, true)
   end)

   BtnAddEvent(self.BtnPlus, function()
        local nNow = self.SliderTurn:GetValue()
        local nNew = math.min(self.nMaxValue, nNow + 1)
        self:RefreshUI(nNew, true)
   end)

   self.SliderTurn.OnValueChanged:Add(self, function(_, nValue)
        self:RefreshUI(nValue, true)
   end)
end

function tbClass:OnActive()

    if UE4.UUIGameInstanceSubsystem.IsOpenSafeZone() == false then
        WidgetUtils.Collapsed(self)
        return
    else
        WidgetUtils.SelfHitTestInvisible(self)
    end

    local nValue = PlayerSetting.GetOne(PlayerSetting.SSID_OTHER, OtherType.UI_SAFE_ZONE_SCALE)

    ---没有设置过
    if nValue == -1 then
        nValue = UE4.UUIGameInstanceSubsystem.GetSafeZoneDefaultValue()
    end

    if nValue < 0 then
        nValue = 0
    end

    self:RefreshUI(nValue, false)
end

function tbClass:RefreshUI(nValue, bUpdate)
    nValue = math.floor(nValue)
    self.Percent:SetPercent(nValue / self.nMaxValue)
    self.SliderTurn:SetValue(nValue)
    self.TxtNum:SetText(nValue)
   
    if bUpdate then
        PlayerSetting.Set(PlayerSetting.SSID_OTHER, OtherType.UI_SAFE_ZONE_SCALE, {nValue})
        UE4.UScreenMatchingSettings.UpdateZoomSafetyZone()
    end
end


function tbClass:OnReset()
    PlayerSetting.ResetBySIDAndType(PlayerSetting.SSID_OTHER, OtherType.UI_SAFE_ZONE_SCALE)
    self:OnActive()
    UE4.UScreenMatchingSettings.UpdateZoomSafetyZone()
end

return tbClass