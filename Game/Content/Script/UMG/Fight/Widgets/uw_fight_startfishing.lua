-- ========================================================
-- @File    : uw_fight_openshop.lua
-- @Brief   : 战斗界面互动按钮
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:UpdateKeyShow()
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
    end--]]

    self.KeyBtn:UpdateKeyShow('TxtKeyUse')
end

function tbClass:BindKeyBoardOnSettingChange()
    self:RegisterEvent(Event.OnKeyBoardSettingChanged,function (sBindKey,pKeyName,pKeyCfg)
        if sBindKey == 'TxtKeyUse' then
            self:UpdateKeyShow()
        end
    end)
end

function tbClass:BindExitInteractEvent()
    self:RegisterEvent(
        Event.EndOverlapInteractionPoint,
        function(InFishPoint)
            if InFishPoint == self.ItemOwner then
                self:RemoveFromList()
            end
        end
    )

    --[[self:RegisterEvent(Event.OnInputDeviceChange, function()
        self:UpdateKeyShow()
    end)--]]
end

function tbClass:TriggerInteract(PlayerController)
    print('===========>开始钓鱼')
end

return tbClass
