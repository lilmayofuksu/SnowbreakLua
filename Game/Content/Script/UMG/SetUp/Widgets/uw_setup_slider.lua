-- ========================================================
-- @File    : uw_setup_slider.lua
-- @Brief   : 设置
-- ========================================================
---@class tbClass : UUserWidget
---@field SliderTurn USlider
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.SliderTurn.OnValueChanged:Add(self, function(InTarget, Value)
        self.nValue = math.ceil(Value)
        self:Update()
    end)

    BtnAddEvent(self.BtnMinus, function ()
        --- reduce
        if self.disable then return end
        self.nValue = math.ceil(math.max(self.SliderTurn.MinValue, self.nValue - 1))
        self:Update()
    end)

    BtnAddEvent(self.BtnPlus, function ()
        --- add
        if self.disable then return end
        self.nValue = math.ceil(math.min(self.nMaxNum, self.nValue + 1))
        self:Update()
    end)

    BtnAddEvent(self.BtnReset, function()
        if self.disable then return end
        PlayerSetting.ResetBySIDAndType(self.nSID, self.nType)
        self.nValue = PlayerSetting.GetOne(self.nSID, self.nType) or self.nMaxNum
        self.nValue = math.ceil(self.nValue)
        self:Update()
    end)

    BtnAddEvent(self.BtnMute, function()
        ---静音
        self.bMute = not self.bMute 
        self:SetSoundType(self.bMute)
        PlayerSetting.Set(self.nSID, self.nType, {self.nValue, self.bMute and 1 or 0})
        SettingEvent.Trigger(self.nSID, self.nType, PlayerSetting.Get(self.nSID, self.nType))
    end)

    BtnAddEvent(self.BtnPrompt, function ()
        if self.TipsVisible then
            WidgetUtils.Collapsed(self.PanelDetail)
        else
            WidgetUtils.Visible(self.PanelDetail)
        end
    end)

    self.CanvasPanel_172:SetRenderOpacity(1)
    self.TxtSliderName:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))

    self:RegisterEvent(Event.MouseButtonUp, function() 
        self.TipsVisible = WidgetUtils.IsVisible(self.PanelDetail)
        WidgetUtils.Collapsed(self.PanelDetail)
    end)
end

function tbClass:OnDestruct()
    self:RemoveRegisterEvent()
    self.SliderTurn.OnValueChanged:Clear()
    BtnClearEvent(self.BtnMinus)
    BtnClearEvent(self.BtnPlus)
    BtnClearEvent(self.BtnReset)
    BtnClearEvent(self.BtnMute)
    BtnClearEvent(self.BtnPrompt)
end

function tbClass:Update()
    self.TxtNum:SetText(self.nValue)
    self.SliderTurn:SetValue(self.nValue) 
    if self.nSID == PlayerSetting.SSID_SOUND then
        PlayerSetting.Set(self.nSID, self.nType, {self.nValue, self.bMute and 1 or 0})
        SettingEvent.Trigger(self.nSID, self.nType, PlayerSetting.Get(self.nSID, self.nType))
    elseif self.nSID == PlayerSetting.SSID_FRAME then
        PlayerSetting.SetFrameCheck(self.nType, self.nValue)
    else
        PlayerSetting.Set(self.nSID, self.nType, {self.nValue})
    end
    self.Percent:SetPercent(self:GetPercent())
    if self.fOnChange then self.fOnChange(self.nValue, self.nType) end
end

function tbClass:GetPercent()
    return (self.nValue - self.nMinNum) / (self.nMaxNum - self.nMinNum)
end


function tbClass:Init(nSID, nType, nMin, nMax, sTip, fOnChange)
    self.nMaxNum = 50
    self.nMinNum = nMin
    if nSID == PlayerSetting.SSID_SOUND then
        self.nMaxNum = UE4.UUMGLibrary.GetSliderMax(nSID)
    else
        self.nMaxNum = nMax
    end
    self.SliderTurn:SetMaxValue(self.nMaxNum)
    self.SliderTurn:SetMinValue(self.nMinNum)

    self.nSID = nSID
    self.nType = nType
    self.TxtSliderName:SetText(Text(PlayerSetting.GetShowName(nSID, nType)))
    if self.nSID == PlayerSetting.SSID_SOUND then
        WidgetUtils.Visible(self.BtnMute)
        WidgetUtils.Collapsed(self.BtnReset)
        local tbValue = PlayerSetting.Get(nSID, nType) or {self.nMaxNum, 0}
        self.nValue = tbValue[1]
        local bMute = (tbValue[2] or 0) == 1 and  true or false
        self:SetSoundType(bMute)
    elseif self.nSID == PlayerSetting.SSID_FRAME then
        WidgetUtils.Collapsed(self.BtnMute)
        WidgetUtils.Visible(self.BtnReset)
        self.nValue = PlayerSetting.GetFrameCheckIndex(nType)
    else
        WidgetUtils.Collapsed(self.BtnMute)
        WidgetUtils.Visible(self.BtnReset)
        self.nValue = PlayerSetting.GetOne(nSID, nType)
    end

    self.nValue = math.ceil(self.nValue)
    self.SliderTurn:SetValue(self.nValue)
    self.TxtNum:SetText(self.nValue)
    self.Percent:SetPercent(self:GetPercent())
    self.Tip = sTip
    self.fOnChange = fOnChange

    self.Tip = sTip
    if self.TxtDetail then
        self.TxtDetail:SetText(Text(self.Tip))
    end
    if self.Tip then
        WidgetUtils.SelfHitTestInvisible(self.PanelPrompt)
        WidgetUtils.Visible(self.BtnPrompt)
    else
        WidgetUtils.Collapsed(self.BtnPrompt)
    end
end

function tbClass:Disable(bVal)
    if bVal then
        WidgetUtils.HitTestInvisible(self.CanvasPanel_172)
        self.CanvasPanel_172:SetRenderOpacity(0.4)
        self.TxtSliderName:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 0.4))
    else
        self.CanvasPanel_172:SetRenderOpacity(1)
        self.TxtSliderName:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 1, 1, 1))
        WidgetUtils.SelfHitTestInvisible(self.CanvasPanel_172)
    end
    self.disable = bVal
end

function tbClass:SetSoundType(bMute)
    self.bMute = bMute
    if bMute then
        WidgetUtils.HitTestInvisible(self.DisableMute)
        WidgetUtils.HitTestInvisible(self.BtnDisabel)
        --WidgetUtils.HitTestInvisible(self.SliderTurn) -- 静音了并不影响调节
        WidgetUtils.Collapsed(self.BtnNormal)
        self:SetInValidColor()
    else
        WidgetUtils.Collapsed(self.DisableMute)
        WidgetUtils.Collapsed(self.BtnDisabel)
        WidgetUtils.HitTestInvisible(self.BtnNormal)
        self:SetValidColor()
        --WidgetUtils.Visible(self.SliderTurn)   
    end
end

return tbClass