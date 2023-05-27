local tbClass = Class("UMG.SubWidget")

local SID = PlayerSetting.SSID_OPERATION

local ContentType = {
    Function   = 2
}

function tbClass:Construct()

    self.Padding = UE4.FMargin()
    self.Padding.Left = 30
    self.Padding.Top = 0
    self.Padding.Right = 0
    self.Padding.Bottom = 0

    self.FunctionSet:Set({sName = "ui.TxtFunction_Basis", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Function)
        self:ResetPart(tb, "ui.TxtFunction_Basis")
    end})

    self.tbContents = {
        self.FunctionSet,
        self.Content1
    }

    self.tbFunc = {
        [OperationType.QUICK_SUPPORT_SUPERSKILL_LEAVE] = function(nCurrentIndex, tbCfg)
            UI.Open("MessageBox", string.format(Text("setting.Quick_Burst_Hint"), Text("setting.Quick_Burst_Set"..(nCurrentIndex + 1))) , function ()
                PlayerSetting.Set(SID, tbCfg.Type, {nCurrentIndex})
                RoleCard.SetAllRoleLeave(nCurrentIndex, nil)
                self:OnActive()
            end, function ()
                self:OnActive()
            end)
        end
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

function tbClass:AddToFunction(Widget)
    WidgetUtils.SelfHitTestInvisible(self.FunctionSet)
    WidgetUtils.SelfHitTestInvisible(self.Content1)
    self.Content1:AddChildToWrapBox(Widget)
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
    
    if Contains(tbCfg.Category, ContentType.Function) then
        local widget = self:GetWidget(tbCfg)
        self:AddToFunction(widget)
    end

    PlayerSetting.InitWidget(SID, widget, tbCfg, self.tbFunc, self.tbWidgets)
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
    WidgetUtils.CollapsedWidgets(self.tbContents)
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    for _,v in ipairs(PlayerSetting.tbOperationSort) do
        self:SwitchContent(v, IsPc)
    end
    PlayerSetting.CheckConnect(SID, self.tbWidgets)
end

return tbClass