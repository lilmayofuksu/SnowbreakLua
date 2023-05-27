-- ========================================================
-- @File    : uw_fight_open_machine.lua
-- @Brief   : 战斗界面互动按钮
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_open_machine = Class("UMG.SubWidget")

function uw_fight_open_machine:UpdateKeyShow()
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

function uw_fight_open_machine:BindExitInteractEvent()
    self:RegisterEvent(
        Event.EndOverlapInteractionPoint,
        function(InBox)
            if InBox == self.ItemOwner then
                self:RemoveFromList()
            end
        end
    )

    --[[self:RegisterEvent(Event.OnInputDeviceChange, function()
        self:UpdateKeyShow()
    end)--]]
end

function uw_fight_open_machine:BindKeyBoardOnSettingChange()
    self:RegisterEvent(Event.OnKeyBoardSettingChanged,function (sBindKey,pKeyName,pKeyCfg)
        if sBindKey == 'TxtKeyUse' then
            self:UpdateKeyShow()
        end
    end)
end

function uw_fight_open_machine:TriggerInteract(PlayerController)
    print('=============>启动数据交换')
    self.ItemOwner:TryInteract(PlayerController);
end

return uw_fight_open_machine
