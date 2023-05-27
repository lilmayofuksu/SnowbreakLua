-- ========================================================
-- @File    :
-- @Brief   :
-- @Author  : 
-- @DATE    : 
-- ========================================================
local tbClass = Class("UMG.BaseWidget")
local MaxSettingLevel = 4

function tbClass:OnInit()
    BtnAddEvent(self.BtnBegin, function() self:SelectRoot(1) end)
    BtnAddEvent(self.BtnState, function() self:SelectRoot(2) end)
    BtnAddEvent(self.ButtonBegin, function() self:OnBtnClickBegin() end)
    BtnAddEvent(self.ButtonLast, function() self:OnBtnClickLast() end)
    BtnAddEvent(self.ShowOrHide, function() self:OnBtnClickShowOrHide() end)
    BtnAddEvent(self.BtnPause, function() self:OnBtnClickPause() end)
    
    for i = 1, MaxSettingLevel do 
        BtnAddEvent(self["Setting" .. i], function() self:SelectSetting(i) end)
    end

    RuntimeState.ChangeInputMode(true)

    self.OwnerActor = UE4.UUMGLibrary.FindActorByName(self, "MyAutoPSO") 
    if self.OwnerActor then 
        self.OwnerActor.OnPSOStateChanged:Add(self, function() self:UpdatePSOState() end)
        self.OwnerActor.MaxPreivewCount = 200;
    end
    self.PSOSystem = UE4.UGameLibrary.GetAutoPSOSystem(self:GetOwningPlayer());
    
    self:UpdatePSOState()
    if not IsSetPSOFPSCommand then 
        IsSetPSOFPSCommand = true;
        UE4.UKismetSystemLibrary.ExecuteConsoleCommand(self, "stat fps")
        UE4.UKismetSystemLibrary.ExecuteConsoleCommand(self, "stat unit")
    end
end

function tbClass:OnOpen()
    if self.PSOSystem.Runtime.IsRunning then 
        if self.OwnerActor then 
            self.OwnerActor:Begin()
        end
        self:SetFPS()
        self:SelectRoot(2)

        if (UE4.UUserSetting.GetInt('AutoPSO_UIShow', 0) == 1) then 
            self:OnBtnClickShowOrHide();
        end
    else 
        self:SelectRoot(1)
        self:SelectSetting(1)
    end
end

function tbClass:OnClose()
    if self.OwnerActor then 
        self.OwnerActor.OnPSOStateChanged:Remove(self)
    end
    UE4.UUserSetting.SetInt('AutoPSO_UIShow', WidgetUtils.IsVisible(self.PanelData) and 0 or 1)
    UE4.UUserSetting.Save()
end

function tbClass:Tick()
    if WidgetUtils.IsVisible(self.PanelState) and self.PSOSystem then 
        self.TxtPercent:SetText(string.format("%0.2f%%", self.PSOSystem:GetCurrentPercent() * 100) )
    else 
        self.TxtPercent:SetText("")
    end
end

function tbClass:SelectRoot(index) 
    if index == 1 then 
        WidgetUtils.Collapsed(self.PanelState) 
        WidgetUtils.Visible(self.PanelBegin)
        self.BtnBegin:SetBackgroundColor(UE.FLinearColor(0, 1, 0, 1))
        self.BtnState:SetBackgroundColor(UE.FLinearColor(1, 1, 1, 1))
    else 
        WidgetUtils.Visible(self.PanelState) 
        WidgetUtils.Collapsed(self.PanelBegin)
        self.BtnBegin:SetBackgroundColor(UE.FLinearColor(1, 1, 1, 1))
        self.BtnState:SetBackgroundColor(UE.FLinearColor(0, 1, 0, 1))
    end
end

function tbClass:SelectSetting(index)
    self.GraphicLevel = index
    for i = 1, MaxSettingLevel do 
        if i == index then 
            self["Setting" .. i]:SetBackgroundColor(UE.FLinearColor(0, 1, 0, 1))
        else 
            self["Setting" .. i]:SetBackgroundColor(UE.FLinearColor(1, 1, 1, 1))
        end
    end
end

function tbClass:OnBtnClickBegin()
    local cfg = self.PSOSystem.Config
    cfg.QualityLevel = self.GraphicLevel
    cfg.AutoNextQuality = self.CheckBox_AutoNext:GetCheckedState() == 1

    cfg.TraversalAllAsset = self.CheckBox_AllAsset:GetCheckedState() == 1
    cfg.AssetBeginIndex = tonumber(self.InputAllAsset:GetText())

    cfg.TraversalAllSkill = self.CheckBox_AllSkill:GetCheckedState() == 1
    cfg.SkillBeginIndex = tonumber(self.InputAllSkill:GetText())

    cfg.TraversalAllMap = self.CheckBox_AllMap:GetCheckedState() == 1
    cfg.MapBeginIndex = tonumber(self.InputAllMap:GetText())


    self.PSOSystem:Begin();
    if self.OwnerActor then 
        self.OwnerActor:Begin()
    end
    self:SelectRoot(2)
    self:UpdatePSOState()
    self:SetFPS()
end

function tbClass:OnBtnClickLast()
    self:SelectSetting(UE4.UUserSetting.GetInt('AutoPSO_GraphicLevel', 1))
    self.CheckBox_AutoNext:SetCheckedState(UE4.UUserSetting.GetInt('AutoPSO_AutoNext', 1));
    self.CheckBox_AllAsset:SetCheckedState(UE4.UUserSetting.GetInt('AutoPSO_AllAsset', 1));
    self.CheckBox_AllSkill:SetCheckedState(UE4.UUserSetting.GetInt('AutoPSO_AllSkill', 1));
    self.CheckBox_AllMap:SetCheckedState(UE4.UUserSetting.GetInt('AutoPSO_AllMap', 1));

    self.InputAllAsset:SetText(tostring(UE4.UUserSetting.GetInt('AutoPSO_AssetIndex', 0)));
    self.InputAllSkill:SetText(tostring(UE4.UUserSetting.GetInt('AutoPSO_SkillIndex', 0)));
    self.InputAllMap:SetText(tostring(UE4.UUserSetting.GetInt('AutoPSO_MapIndex', 0)));
end

function tbClass:UpdatePSOState()
    local runtime = self.PSOSystem.Runtime;
    self.TxtTitle:SetText("Graphic" .. runtime.CurrentQualityLevel)
    self.AssetProgress:SetText(self:GetProgress(runtime.CurrentAssetIndex, runtime.TotalAssetCount))    
    self.AssetCount:SetText(string.format("%d / %d", runtime.CurrentAssetIndex, runtime.TotalAssetCount))

    self.SkillProgress:SetText(self:GetProgress(runtime.CurrentActorIndex, runtime.TotalActorCount))    
    self.SkillCount:SetText(string.format("%d / %d", runtime.CurrentActorIndex, runtime.TotalActorCount))

    self.MapProgress:SetText(self:GetProgress(runtime.CurrentMapIndex, runtime.TotalMapCount))    
    self.MapCount:SetText(string.format("%d / %d", runtime.CurrentMapIndex, runtime.TotalMapCount))

    self.TxtPause:SetText(runtime.IsPause and "Continue" or "Pause");
end

function tbClass:SetFPS() 
    -- 60帧 和 无敌
    UE4.UKismetSystemLibrary.ExecuteConsoleCommand(self, "t.maxFPS 60")
    local GMPlayerCharacters = self:GetOwningPlayer():GetPlayerCharacters():ToTable()
    for index, value in ipairs(GMPlayerCharacters) do
        local Location = UE4.FVector(0,0,0)
        UE4.UModifier.MakeModifier(3301001, value.Ability, value.Ability, value.Ability, nil, Location, Location)
    end
end

function tbClass:GetProgress(cur, max)
    if max <= 0 then return "--" end
    return string.format("%0.2f%%", cur / max * 100) 
end

function tbClass:OnBtnClickShowOrHide()
    if WidgetUtils.IsVisible(self.PanelData) then 
        WidgetUtils.Collapsed(self.PanelData);
        self.TxtShowOrHide:SetText("Show");
    else 
        WidgetUtils.Visible(self.PanelData);
        self.TxtShowOrHide:SetText("Hide");
    end
end

function tbClass:OnBtnClickPause()
    local runtime = self.PSOSystem.Runtime;
    self.PSOSystem:Pause(not runtime.IsPause);
    self.TxtPause:SetText(runtime.IsPause and "Continue" or "Pause");
end



return tbClass;
