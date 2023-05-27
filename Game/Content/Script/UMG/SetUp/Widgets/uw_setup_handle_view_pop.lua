---@class tbClass : UUserWidget
local tbClass = Class("UMG.BaseWidget")

local SID = PlayerSetting.SSID_HANDLE

local ContentType = {
    Gun = 4,
    Function = 5,
    Aim = 6
}

function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function ()
        UI.Close(self)
    end)

    self.GunSet:Set({sName = "ui.TxtGunSet", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Gun)
        self:ResetPart(tb, "ui.TxtGunSet")
    end})

    self.FunctionSet:Set({sName = "ui.TxtFunctionSet", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Function)
        self:ResetPart(tb, "ui.TxtFunctionSet")
    end})

    self.AimSet:Set({sName = "ui.TxtAimSet", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Aim)
        self:ResetPart(tb, "ui.TxtAimSet")
    end})

    self.tbWidgets = {}

    self.tbContents = {
        self.GunSet,
        self.FunctionSet,
        self.AimSet,
        self.Content1,
        self.Content2,
        self.Content3
    }

    self.tbFunc = {
        [HandleType.CORNER] = function (nValue, nType)
            self:UpdateLine(nValue, nType)
            self:UpdateCircle(nValue, nType)
        end,
        [HandleType.EXTERNAL_THRESHOLD] = function (nValue, nType)
            self:UpdateLine(nValue, nType)
            self:UpdateCircle(nValue, nType)
        end,
        [HandleType.RESPONSE_CURVE] = function (nValue, nType)
            self:UpdateLine(nValue, nType)
        end
    }

    self.LineStart = self.Line:GetSplinePointAtIndex(0)
    self.LineMiddle = self.Line:GetSplinePointAtIndex(1)
    self.LineEnd = self.Line:GetSplinePointAtIndex(2)

    if self.OuterScrollBox then
        WidgetUtils.SelfHitTestInvisible(self.ImgDown)
        self.ScrollHandle = function (_, offset)
            if self.OuterScrollBox then
                local offsetOfEnd = self.OuterScrollBox:GetScrollOffsetOfEnd();
                if offsetOfEnd ~= 0 and offsetOfEnd ~= offset then
                    WidgetUtils.SelfHitTestInvisible(self.ImgDown)
                else
                    WidgetUtils.Collapsed(self.ImgDown)
                end
                return
            end
        end
        self.OuterScrollBox.OnUserScrolled:Add(self, self.ScrollHandle)
    end
end

function tbClass:UpdateLine(nValue, nType)
    local corner = PlayerSetting.Get(SID, HandleType.CORNER)[1] / 100
    local external_threshold = PlayerSetting.Get(SID, HandleType.EXTERNAL_THRESHOLD)[1] / 100
    local response_curve = PlayerSetting.Get(SID, HandleType.RESPONSE_CURVE)[1] / 30

    if nType == HandleType.CORNER then
        corner = nValue / 100
    elseif nType == HandleType.EXTERNAL_THRESHOLD then
        external_threshold = nValue / 100
    elseif nType == HandleType.RESPONSE_CURVE then
        response_curve = nValue / 30
    end

    local arg1 = 1 - corner
    local arg2 = 1 - external_threshold
    local arg3 = 1 - external_threshold * arg1
    local mix = arg1 * arg2

    self.LineStart.Location = UE4.FVector2D(413 * corner, 210)
    self.LineStart.Direction = UE4.FVector2D(920 * response_curve, 200 * response_curve) * mix

    self.LineMiddle.Location = UE4.FVector2D(413 * arg3, 0)
    self.LineMiddle.Direction = UE4.FVector2D(0, 0)

    self.LineEnd.Location = UE4.FVector2D(self.LineMiddle.Location.x * 2 - self.LineStart.Location.x, -210)
    self.LineEnd.Direction = UE4.FVector2D(920 * response_curve, 200 * response_curve) * mix

    self.Line:ChangeSplinePointAtIndex(self.LineStart, 0, false)
    self.Line:ChangeSplinePointAtIndex(self.LineMiddle, 1, false)
    self.Line:ChangeSplinePointAtIndex(self.LineEnd, 2, true)
end

function tbClass:UpdateCircle(nValue, nType)
    local corner = PlayerSetting.Get(SID, HandleType.CORNER)[1] / 100
    local external_threshold = PlayerSetting.Get(SID, HandleType.EXTERNAL_THRESHOLD)[1] / 100

    if nType == HandleType.CORNER then
        corner = nValue / 100
    elseif nType == HandleType.EXTERNAL_THRESHOLD then
        external_threshold = nValue / 100
    end

    local Mat = self.Img1:GetDynamicMaterial()
    if Mat then
        Mat:SetScalarParameterValue("Circle2Radius", 1 - external_threshold)
        Mat:SetScalarParameterValue("Circle3Radius", corner)
    end
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

function tbClass:AddToAim(Widget)
    WidgetUtils.SelfHitTestInvisible(self.AimSet)
    WidgetUtils.SelfHitTestInvisible(self.Content3)
    self.Content3:AddChildToWrapBox(Widget)
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
    elseif Contains(tbCfg.Category, ContentType.Aim) then
        self:AddToAim(widget)
    end

    PlayerSetting.InitWidget(SID, widget, tbCfg, self.tbFunc, self.tbWidgets)
end

function tbClass:ResetPart(tbPart, sLabel)
    UI.Open("MessageBox", string.format(Text("ui.TxtSetReset"), Text(sLabel)) , function ()
        for _,v in ipairs(tbPart) do
            PlayerSetting.ResetBySIDAndType(SID, v)
        end
        self:UpdateUI()
    end)
end

function tbClass:OnReset()
    PlayerSetting.ResetBySID(SID)
    self:UpdateUI()
    for _, nType in pairs(OtherType) do
        local value = PlayerSetting.Get(SID, nType)
        SettingEvent.Trigger(SID, nType, value)
    end
end

function tbClass:OnOpen()
    self:UpdateUI()
    self:UpdateLine()
    self:UpdateCircle()
end

function tbClass:UpdateUI()
    WidgetUtils.CollapsedWidgets(self.tbContents)
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    for _,v in ipairs(PlayerSetting.tbHandleSort) do
        self:SwitchContent(v, IsPc)
    end
    PlayerSetting.CheckConnect(SID, self.tbWidgets)
end

function tbClass:OnClose()
end

return tbClass