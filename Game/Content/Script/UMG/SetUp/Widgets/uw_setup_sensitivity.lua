local tbClass = Class("UMG.SubWidget")

local SID = PlayerSetting.SSID_OPERATION

local ContentType = {
    Camera              = 7,
    Fire                = 8,
    GyroscopeScale      = 9,
    GyroscopeFire       = 10,
    TurnMode            = 6,
}

function tbClass:Construct()

    self.Padding = UE4.FMargin()
    self.Padding.Left = 30
    self.Padding.Top = 0
    self.Padding.Right = 0
    self.Padding.Bottom = 0

    self.TxtAllSensitivity:Set({sName = "ui.TxtAllSensitivity"})

    self.Camera:Set({sName = "ui.TxtCamera_sensitivity", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Camera)
        self:ResetPart(tb, "ui.TxtCamera_sensitivity")
    end})

    self.Fire:Set({sName = "ui.TxtFire_sensitivity", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Fire)
        self:ResetPart(tb, "ui.TxtFire_sensitivity")
    end})

    self.GyroscopeFire:Set({sName = "ui.TxtGyroscopefire_sensitivity", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.GyroscopeFire)
        self:ResetPart(tb, "ui.TxtGyroscopefire_sensitivity")
    end})

    self.TxtTurnMode:Set({sName = "ui.TxtTurnMode", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.TurnMode)
        self:ResetPart(tb, "ui.TxtTurnMode")
    end})

    self.gyroscope_scale:Set({sName = "ui.gyroscope_scale", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.GyroscopeScale)
        self:ResetPart(tb, "ui.gyroscope_scale")
    end})

    self.tbContents = {
        self.Camera,
        self.Fire,
        self.GyroscopeFire,
        self.TxtTurnMode,
        self.gyroscope_scale,
        self.Content1,
        self.Content2,
        self.Content3,
        self.Content4,
        self.Content6
    }


    self:InitGrop()

    self.tbWidgets = {}
end

function tbClass:InitGrop()
    WidgetUtils.Hidden(self.GropType.Check4)
    WidgetUtils.Hidden(self.GropType.Check5)
    self.GropType.TxtCheck1:SetText(Text('setting.low'))
    self.GropType.TxtCheck1_1:SetText(Text('setting.low'))
    self.GropType.TxtCheck2:SetText(Text('setting.middle'))
    self.GropType.TxtCheck2_1:SetText(Text('setting.middle'))
    self.GropType.TxtCheck3:SetText(Text('setting.high'))
    self.GropType.TxtCheck3_1:SetText(Text('setting.high'))

    self.GropType.TxtCheck6:SetText(Text('setting.custom'))
    self.GropType.TxtCheck6_1:SetText(Text('setting.custom'))

    self.GropType.OnStateChangedEvent:Add(self, function(_, nIndex)
        local nLevel = nIndex + 1
        local nCurLevel = PlayerSetting.GetOne(SID, OperationType.SENSITIVITY)
        if nCurLevel == nLevel then return end
        PlayerSetting.Set(SID, OperationType.SENSITIVITY, {nLevel})
        self:LoadStandard(OperationType.SENSITIVITY, nLevel)
    end)
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

function tbClass:InitWidget(SID, Widget, tbCfg, tbFunc, tbWidgets)
    if tbCfg.ClassType < 2 then
        local tb = tbCfg.Items or {'close', 'open'}
        local nValue = PlayerSetting.GetOne(SID, tbCfg.Type) or 0
        local check = tbCfg.Multi and nValue or math.min(nValue, #tb - 1)
        Widget:Set({ tbData = {0, tbCfg.Name, tb}, nCheckIndex = check, fOnChange = function(nIndex)
            if tbCfg.Connect then
                for k,tb in pairs(tbCfg.Connect) do
                    if tbWidgets[k] then
                        local bDisable = false
                        for _,v in ipairs(tb) do
                            bDisable = bDisable or (v == nIndex)
                        end
                        if tbWidgets[k].Disable then
                            tbWidgets[k]:Disable(bDisable)
                        end
                    end
                end
            end
            PlayerSetting.Set(SID, tbCfg.Type, {nIndex})
            self:CheckLevelUpdata(tbCfg.Type, nIndex)
            if tbFunc and tbFunc[tbCfg.Type] then
                tbFunc[tbCfg.Type](nIndex)
            end
        end, bMulti = tbCfg.Multi, tip = tbCfg.BanTip})
    elseif tbCfg.ClassType == 2 then
        local nMin, nMax = PlayerSetting.GetSliderRange(SID, tbCfg.Type)
        Widget:Init(SID, tbCfg.Type, nMin, nMax, tbCfg.BanTip, function ()
            self:CheckLevelUpdata(tbCfg.Type, nIndex)
        end)
    elseif (tbCfg.ClassType == 3 or tbCfg.ClassType == 5) and tbFunc then
        local text = tbCfg.Items and tbCfg.Items[1] or tbCfg.Name
        local icon = tbCfg.Items and tbCfg.Items[2] or nil
        local platform = tbCfg.Items and tbCfg.Items[3] or nil

        Widget:Set({Cfg = {sName = tbCfg.Name, sText = text, sUrl = tbCfg.Url, bExternal = tbCfg.External, nIconId = icon, sPlatform = platform}, pFunc = tbFunc[tbCfg.Type]})
    elseif tbCfg.ClassType == 4 then
        Widget:OnActive()
    end
end

function tbClass:CheckLevelUpdata(nType, nValue)
    local tbCfg = PlayerSetting.tbOperationCfg[nType]
    if tbCfg.Reference == OperationType.SENSITIVITY then
        local nLevel = PlayerSetting.GetOne(SID, OperationType.SENSITIVITY) or 3
        if nLevel <= #tbCfg.Standard and tbCfg.Standard[nLevel] == nValue then
            return
        end
        self.GropType:Select(5) --Custom
    end
end

function tbClass:Align(Widget)
    local slot = UE4.UWidgetLayoutLibrary.SlotAsWrapBoxSlot(Widget)
    slot:SetPadding(self.Padding)
    slot:SetFillEmptySpace(true)
end

function tbClass:AddToCamera(Widget)
    WidgetUtils.SelfHitTestInvisible(self.Camera)
    WidgetUtils.SelfHitTestInvisible(self.Content2)
    self.Content2:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:AddToFire(Widget)
    WidgetUtils.SelfHitTestInvisible(self.Fire)
    WidgetUtils.SelfHitTestInvisible(self.Content3)
    self.Content3:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:AddToGyroscopeFire(Widget)
    WidgetUtils.SelfHitTestInvisible(self.GyroscopeFire)
    WidgetUtils.SelfHitTestInvisible(self.Content6)
    self.Content6:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:AddToGyroscopeScale(Widget)
    WidgetUtils.SelfHitTestInvisible(self.gyroscope_scale)
    WidgetUtils.SelfHitTestInvisible(self.Content4)
    self.Content4:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:AddToTurnMode(Widget)
    WidgetUtils.SelfHitTestInvisible(self.TxtTurnMode)
    WidgetUtils.SelfHitTestInvisible(self.Content1)
    self.Content1:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:SwitchContent(tbCfg, isPc)
    if not PlayerSetting.IsPageContent(tbCfg, isPc, ContentType) then return end
    local widget = self:GetWidget(tbCfg)
    
    if Contains(tbCfg.Category, ContentType.Camera) then
        self:AddToCamera(widget)
    elseif Contains(tbCfg.Category, ContentType.Fire) then
        self:AddToFire(widget)
    elseif Contains(tbCfg.Category, ContentType.GyroscopeFire) then
        self:AddToGyroscopeFire(widget)
    elseif Contains(tbCfg.Category, ContentType.TurnMode) then
        self:AddToTurnMode(widget)
    elseif Contains(tbCfg.Category, ContentType.GyroscopeScale) then
        self:AddToGyroscopeScale(widget)
    end

    self:InitWidget(SID, widget, tbCfg, nil, self.tbWidgets)
end

function tbClass:ResetPart(tbPart, sLabel)
    UI.Open("MessageBox", string.format(Text("ui.TxtSetReset"), Text(sLabel)) , function ()
        for _,v in ipairs(tbPart) do
            PlayerSetting.ResetBySIDAndType(SID, v)
        end
        self:OnActive()
    end)
end

function tbClass:LoadStandard(nType, nIndex)
    for _,v in ipairs(PlayerSetting.tbOperationSort) do
        if v.Reference and v.Standard and v.Reference == nType and nIndex <= #v.Standard then
            PlayerSetting.Set(SID, v.Type, {v.Standard[nIndex]})
        end
    end
    self:Update()
end

function tbClass:OnActive()
    local nLevel = PlayerSetting.GetOne(SID, OperationType.SENSITIVITY) or 3
    self.GropType:Select(nLevel - 1)
    self:LoadStandard(OperationType.SENSITIVITY, nLevel)
end

function tbClass:Update()
    WidgetUtils.CollapsedWidgets(self.tbContents)
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    for _,v in ipairs(PlayerSetting.tbOperationSort) do
        self:SwitchContent(v, IsPc)
    end
    PlayerSetting.CheckConnect(SID, self.tbWidgets)
end

return tbClass