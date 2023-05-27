local tbClass = Class("UMG.SubWidget")

local SID = PlayerSetting.SSID_OPERATION

local ContentType = {
    Gun        = 1,
    Function   = 13
}

function tbClass:Construct()

    self.Padding = UE4.FMargin()
    self.Padding.Left = 30
    self.Padding.Top = 0
    self.Padding.Right = 0
    self.Padding.Bottom = 0

    self.GunSet:Set({sName = "ui.TxtGun_Basis", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Gun)
        self:ResetPart(tb, "ui.TxtGun_Basis")
    end})

    self.FunctionSet:Set({sName = "ui.TxtFunction_Basis", pFunc =  function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Function)
        self:ResetPart(tb, "ui.TxtFunction_Basis")
    end})

    self.tbContents = {
        self.GunSet,
        self.FunctionSet,
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
                local nValue = PlayerSetting.GetOne(SID, tbCfg.Type) or 0
                self.tbWidgets[tbCfg.Type] = pWidget
            end
        end
    end
    return pWidget
end

function tbClass:AddToGun(Widget)
    WidgetUtils.SelfHitTestInvisible(self.GunSet)
    WidgetUtils.SelfHitTestInvisible(self.Content1)
    self.Content1:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:AddToFunction(Widget)
    WidgetUtils.SelfHitTestInvisible(self.FunctionSet)
    WidgetUtils.SelfHitTestInvisible(self.Content2)
    self.Content2:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:Align(Widget)
    local slot = UE4.UWidgetLayoutLibrary.SlotAsWrapBoxSlot(Widget)
    slot:SetPadding(self.Padding)
    slot:SetFillEmptySpace(true)
end

function tbClass:SwitchContent(tbCfg, isPc)
    if not PlayerSetting.IsPageContent(tbCfg, isPc, ContentType) then return end
    local widget = self:GetWidget(tbCfg)
    
    if Contains(tbCfg.Category, ContentType.Gun) then
        self:AddToGun(widget)
    elseif Contains(tbCfg.Category, ContentType.Function) then
        self:AddToFunction(widget)
    end

    PlayerSetting.InitWidget(SID, widget, tbCfg, nil, self.tbWidgets)
end

function tbClass:ResetPart(tbPart, sLabel)
    UI.Open("MessageBox", string.format(Text("ui.TxtSetReset"), Text(sLabel)) , function ()
        for _,v in ipairs(tbPart) do
            PlayerSetting.ResetBySIDAndType(SID, v)
        end
        self:OnActive()
    end)
end

function tbClass:OnActive()
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    for _,v in ipairs(PlayerSetting.tbOperationSort) do
        self:SwitchContent(v, IsPc)
    end
    PlayerSetting.CheckConnect(SID, self.tbWidgets)
end

return tbClass