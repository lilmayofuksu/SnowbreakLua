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

function tbClass:BindExitInteractEvent()
    self:RegisterEvent(
        Event.EndOverlapRandomShop,
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

function tbClass:BindKeyBoardOnSettingChange()
    self:RegisterEvent(Event.OnKeyBoardSettingChanged,function (sBindKey,pKeyName,pKeyCfg)
        if sBindKey == 'TxtKeyUse' then
            self:UpdateKeyShow()
        end
    end)
end

function tbClass:TriggerInteract(PlayerController)
    if self.ItemOwner then
        local uiName = self.ItemOwner.tbParams.uiName
        print("uw_fight_openshop", uiName)
        -- 已经打开，避免重复打开，内存暴涨！！！
        if UI.IsOpen(uiName) then
            return
        end
        UE4.UUMGLibrary.ReleaseInput()--清除战斗界面操作
        UI.Open(uiName);

        -- 播放商店打开动画
        if not self.ItemOwner:GetIsOpen() then
            self.ItemOwner:SetIsOpen(true, true);
        end

        if self.ItemOwner then
            EventSystem.Trigger(Event.NotifyBufferShopHideTip,self.ItemOwner:GetShopId())
            self.ItemOwner.bShowTip = false;
        end

        -- self:RemoveFromList()
    end
end

return tbClass
