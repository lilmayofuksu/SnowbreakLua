-- ========================================================
-- @File    : uw_fight_fragmentstory_box.lua
-- @Brief   : 战斗界面碎片化剧情按钮
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_fragmentstory_box = Class("UMG.SubWidget")

function uw_fight_fragmentstory_box:BindExitInteractEvent()
    self.TxtUse:SetText(Text('ui.TxtInteractCheck'))
    self:RegisterEvent(
        Event.EndOverlapFragmentstory,
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

function uw_fight_fragmentstory_box:TriggerInteract()
    if self.ItemOwner then
        local subsytem = UE4.UUMGLibrary.GetFightUMGSubsystem(GetGameIns());
        subsytem:ApplyOpen(UE4.EUIDialogueType.FragmentStory, self.ItemOwner.FragmentId);

        EventSystem.Trigger(Event.OnFragmentStroyInteractFinish, self.ItemOwner.FragmentId)
        self.ItemOwner:SetActive(false)
        self:RemoveFromList()
    end
end

function uw_fight_fragmentstory_box:BindKeyBoardOnSettingChange()
    self:RegisterEvent(Event.OnKeyBoardSettingChanged,function (sBindKey,pKeyName,pKeyCfg)
        if sBindKey == 'TxtKeyUse' then
            self:UpdateKeyShow()
        end
    end)
end

function uw_fight_fragmentstory_box:UpdateKeyShow()
    self.KeyBtn:UpdateKeyShow('TxtKeyUse')
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
end

return uw_fight_fragmentstory_box
