local tbClass = Class("UMG.SubWidget")

local SID = PlayerSetting.SSID_OPERATION

local ContentType = {
    Mouse        = 11,
    Sensitivity   = 12
}

function tbClass:Construct()

    self.Padding = UE4.FMargin()
    self.Padding.Left = 30
    self.Padding.Top = 0
    self.Padding.Right = 0
    self.Padding.Bottom = 0

    self.MouseSet:Set({sName = "setting.mouse_setting", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Mouse)
        self:ResetPart(tb)
    end})

    self.Sensitivity:Set({sName = "setting.sensitivity_setting", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Sensitivity)
        self:ResetPart(tb)
    end})

    self.tbContents = {
        self.MouseSet,
        self.Sensitivity,
        self.Content1,
        self.Content2
    }

    self.tbWidgets = {}
end

function tbClass:GetWidget(tbCfg)
    local pWidget = self.tbWidgets[tbCfg.Type]
    if tbCfg then
        if not pWidget then
            pWidget = LoadWidget(PlayerSetting.tbClassType[tbCfg.ClassType])
            if pWidget then
                self.tbWidgets[tbCfg.Type] = pWidget
            end
        end
    end
    return pWidget
end

function tbClass:Align(Widget)
    local slot = UE4.UWidgetLayoutLibrary.SlotAsWrapBoxSlot(Widget)
    slot:SetPadding(self.Padding)
    slot:SetFillEmptySpace(true)
end

function tbClass:AddToMouse(Widget)
    WidgetUtils.SelfHitTestInvisible(self.MouseSet)
    WidgetUtils.SelfHitTestInvisible(self.Content1)
    self.Content1:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:AddToSensitivity(Widget)
    WidgetUtils.SelfHitTestInvisible(self.Sensitivity)
    WidgetUtils.SelfHitTestInvisible(self.Content2)
    self.Content2:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:SwitchContent(tbCfg, isPc)
    if not PlayerSetting.IsPageContent(tbCfg, isPc, ContentType) then return end
    local widget = self:GetWidget(tbCfg)
    
    if Contains(tbCfg.Category, ContentType.Mouse) then
        self:AddToMouse(widget)
    elseif Contains(tbCfg.Category, ContentType.Sensitivity) then
        self:AddToSensitivity(widget)
    end

    PlayerSetting.InitWidget(SID, widget, tbCfg, nil, self.tbWidgets)
end

function tbClass:ResetPart(tbPart)
    for _,v in ipairs(tbPart) do
        PlayerSetting.ResetBySIDAndType(SID, v)
    end
    self:OnActive()
end

function tbClass:OnActive()
    WidgetUtils.CollapsedWidgets(self.tbContents)
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    for _,v in ipairs(PlayerSetting.tbOperationSort) do
        self:SwitchContent(v, IsPc)
    end
    PlayerSetting.CheckConnect(SID, self.tbWidgets)
end

return tbClass