-- ========================================================
-- @File    : uw_fight_skill_keybtn.lua
-- @Brief   : 按键显示
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.nEventID = EventSystem.On(Event.OnInputTypeChange, function()
        self:UpdateKeyShow(self.sKey)
    end)
end

function tbClass:GamepadReplaceKey(sReplaceKey)
    self.sReplaceKey = sReplaceKey
end

function tbClass:UpdateKeyShow(sKey)
    if not sKey then return end
    self.sKey = sKey

    WidgetUtils.Collapsed(self.KeyBtn)
    WidgetUtils.Collapsed(self.HandleBtn)

    local PlayerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
    if PlayerController and PlayerController.LastInputGamepad then
        self:ShowGamepad(sKey)
        return
    end
    
    self:ShowKeyboard(sKey)
end

function tbClass:ShowKeyboard(sKey)
    WidgetUtils.Collapsed(self.ImgKeyAdd)
    WidgetUtils.Collapsed(self.TxtAdd)

    local key1 = UE4.UGameKeyboardLibrary.GetInputChordByType(sKey, UE.EKeyboardInputType.Keyboard)
    local keyName1 = UE4.UGameKeyboardLibrary.GetInputChordShowName(key1)
    local cfg = Keyboard.Get(keyName1)
    if cfg then
        if cfg and cfg.nIcon > 0 then
            WidgetUtils.HitTestInvisible(self.HandleBtn)
            WidgetUtils.Collapsed(self.TxtSkillKey1)

            WidgetUtils.SelfHitTestInvisible(self.ImgKey)

            SetTexture(self.ImgKey,cfg.nIcon)
        else
            WidgetUtils.HitTestInvisible(self.KeyBtn)
            WidgetUtils.Collapsed(self.ImgKey)
            WidgetUtils.SelfHitTestInvisible(self.TxtSkillKey1)
            self.TxtSkillKey1:SetText(cfg and cfg.sName or '')
        end

        Keyboard:ShowCombinedKeyTxt(key1,self.TxtSkillKey, self.TxtAdd_1)
    end
end

function tbClass:ShowGamepad(sKey)
    if self.sReplaceKey then
        sKey = self.sReplaceKey
    end

    local nType = Gamepad.GetActiveInputType()
    WidgetUtils.HitTestInvisible(self.HandleBtn)

    local fSet = function(action, pImg)
        local sDisplayName = Gamepad.GetDisplayNameByAction(action)
        local sSettingKey = Gamepad.GetSetting(sDisplayName, nType)
        if sSettingKey then
            local cfg = Keyboard.Get(sSettingKey)
            if cfg then
                SetTexture(pImg, cfg.nIcon)
            end
        end
    end

    local sAction = Gamepad.GetActionNameByI18n(sKey)
    if sAction == nil then return end

    local combinCfg = Gamepad.GetCombineKey(sAction)

    print('UpdateKeyShow ShowGamepad: ************* ', sKey, sAction, combinCfg)

    if combinCfg then
        local action1 = combinCfg[1]
        local action2 = combinCfg[2]

        if not action1 or not action2 then return end

        WidgetUtils.HitTestInvisible(self.ImgKey)
        WidgetUtils.HitTestInvisible(self.TxtAdd)
        WidgetUtils.HitTestInvisible(self.ImgKeyAdd)

        fSet(action1, self.ImgKey)
        fSet(action2, self.ImgKeyAdd)

    else
        local sCombineAction = Gamepad.GetCombineAction(sKey, nType)
        if sCombineAction then

            fSet(sCombineAction, self.ImgKey)
            WidgetUtils.HitTestInvisible(self.ImgKey)
            WidgetUtils.HitTestInvisible(self.TxtAdd)
        else
            WidgetUtils.Collapsed(self.TxtAdd)
            WidgetUtils.Collapsed(self.ImgKey)
        end

        local sSaveKey = Gamepad.GetSetting(sKey, nType)
        if sSaveKey then
            local keyCfg = Keyboard.Get(sSaveKey)
            if keyCfg then
                SetTexture(self.ImgKeyAdd, keyCfg.nIcon)
                WidgetUtils.HitTestInvisible(self.ImgKeyAdd)
            end
        end
    end
    LaunchLog.SetGamepadUsed(true)
end

function tbClass:OnDestruct()
    if self.nEventID then
        EventSystem.Remove(self.nEventID)
    end 
end


return tbClass
