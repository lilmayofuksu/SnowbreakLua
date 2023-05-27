-- ========================================================
-- @File    : uw_dorm_furnitureitem.lua
-- @Brief   : 家具互动按钮
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
        self.TxtKey:SetText(cfg and cfg.sName or keyName1)
    end--]]
    
    if self.ItemOwner then
        self.ItemOwner.InteractWidgetInstance = self
    end
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
        Event.EndOverlapFurniture,
        function(InBox)
            if InBox == self.ItemOwner then
                self:RemoveFromList()
            end
        end
    )

    self:RegisterEvent(
        Event.EndConstantlyInteract,
        function(StopByKeyboard)
            if StopByKeyboard then
                self:UpdateText(true)
            else
                WidgetUtils.Visible(self)
            end
        end)
    
    self:RegisterEvent(
        Event.StartConstantlyInteract,
        function(StopByKeyboard)
            if StopByKeyboard then
                self:UpdateText(false)
            else
                WidgetUtils.Collapsed(self)
            end
        end)

    --[[self:RegisterEvent(Event.OnInputDeviceChange, function()
        self:UpdateKeyShow()
    end)--]]
end

function tbClass:UpdateText(Interactable)
    if Interactable then
        self.TxtUse_1:SetText(Text(self.InteractText))
    else
        self.TxtUse_1:SetText(Text(self.StopInteractText))
    end
end

function tbClass:TriggerInteract()
    local PlayerController = self:GetOwningPlayer():Cast(UE4.AHousePlayerController)
    if PlayerController then
        local ui = UI.GetUI("Dorm")
        if ui then
            ui:StopMove()
        end
        PlayerController:TryInteract()
    end
end

return tbClass
