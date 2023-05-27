
local tbClass=Class("UMG.SubWidget")

function tbClass:Construct()
    local InputSetting =UE4.UInputSettings.GetInputSettings()
    local arrActionNames=InputSetting:GetActionNames()
    local arrAxisNames=InputSetting:GetAxisNames()
    for i = 1, arrActionNames:Length() do
        local arrActionKey = InputSetting:GetActionMappingByName(arrActionNames:Get(i))
        local KeyInputItemWidget = UE4.UWidgetBlueprintLibrary.Create(self, UE4.UClass.Load("/Game/UI/UMG/GM/Widget/uw_adingm_keyinput_item"))
        KeyInputItemWidget.AName:SetText(arrActionNames:Get(i))
        if arrActionKey~=nil then
            for x=1,arrActionKey:Length() do
                local KeyInputItemWidget_Text = UE4.UWidgetBlueprintLibrary.Create(self, UE4.UClass.Load("/Game/UI/UMG/GM/Widget/uw_adingm_keyinput_Text"))
                KeyInputItemWidget_Text.Key_Text:SetText(UE4.UKismetInputLibrary.Key_GetDisplayName(arrActionKey:Get(x).Key) )
                KeyInputItemWidget.Key:AddChild(KeyInputItemWidget_Text)
                --print(UE4.UKismetInputLibrary.Key_GetDisplayName(arrActionKey:Get(x).Key))
            end
            self.ScrollBox_KeyInput:AddChild(KeyInputItemWidget)
        end
    end

    for i = 1, arrAxisNames:Length() do
        local arrAxisKey = InputSetting:GetAxisMappingByName(arrAxisNames:Get(i))
        local KeyInputItemWidget = UE4.UWidgetBlueprintLibrary.Create(self, UE4.UClass.Load("/Game/UI/UMG/GM/Widget/uw_adingm_keyinput_item"))
        KeyInputItemWidget.AName:SetText(arrAxisNames:Get(i))
        if arrAxisKey~=nil then
            for x=1,arrAxisKey:Length() do
                local KeyInputItemWidget_Text = UE4.UWidgetBlueprintLibrary.Create(self, UE4.UClass.Load("/Game/UI/UMG/GM/Widget/uw_adingm_keyinput_Text"))
                KeyInputItemWidget_Text.Key_Text:SetText(UE4.UKismetInputLibrary.Key_GetDisplayName(arrAxisKey:Get(x).Key) )
                KeyInputItemWidget.Key:AddChild(KeyInputItemWidget_Text)
                --print(UE4.UKismetInputLibrary.Key_GetDisplayName(arrActionKey:Get(x).Key))
            end
            self.ScrollBox_KeyInput:AddChild(KeyInputItemWidget)
        end
    end


    self.CloseBtn.OnClicked:Add(self.CloseBtn,self.CloseShowKey)

end

function tbClass:CloseShowKey()
    UI.GetUI('AdinGM').KeyInput:SetVisibility(UE4.ESlateVisibility.Collapsed)
end


return tbClass