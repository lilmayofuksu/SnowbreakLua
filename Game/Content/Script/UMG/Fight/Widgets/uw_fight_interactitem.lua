local uw_fight_interactitem = Class("UMG.SubWidget")

function uw_fight_interactitem:Construct()
    self:RegisterEvent(Event.OnKeyBoardSettingChanged,function (sBindKey,pKeyName,pKeyCfg)
        if pKeyName then
            pKeyCfg = Keyboard.Get(pKeyName)
        end
        if self.sBindKey == 'TxtKeyUse' then
            --[[if pKeyCfg and pKeyCfg.nIcon > 0 then
                WidgetUtils.Collapsed(self.TxtKey)
                WidgetUtils.SelfHitTestInvisible(self.ImgKey)
                SetTexture(self.ImgKey,pKeyCfg.nIcon)
            else
                WidgetUtils.Collapsed(self.ImgKey)
                WidgetUtils.SelfHitTestInvisible(self.TxtKey)
                self.TxtKey:SetText(pKeyCfg and pKeyCfg.sName or pKeyName)
            end--]]
            self:UpdateKeyShow()
        end
    end)

    --[[self:RegisterEvent(Event.OnInputDeviceChange, function()
        self:UpdateKeyShow()
    end)--]]
end

function uw_fight_interactitem:UpdateKeyShow()
    --[[local key1 = UE4.UGameKeyboardLibrary.GetInputChord('TxtKeyUse')
    local keyName1 = UE4.UGameKeyboardLibrary.GetInputChordShowName(key1)
    local cfg = Keyboard.Get(keyName1)
    if cfg and cfg.nIcon > 0 then
        WidgetUtils.Collapsed(self.TxtKey)
        WidgetUtils.SelfHitTestInvisible(self.ImgKey)
        SetTexture(self.ImgKey,cfg.nIcon)
    else
        WidgetUtils.Collapsed(self.ImgKey)
        WidgetUtils.SelfHitTestInvisible(self.TxtKey)
        self.TxtKey:SetText(cfg and cfg.sName or keyName)
    end]]
    self.KeyBtn:UpdateKeyShow('TxtKeyUse')
end

return uw_fight_interactitem