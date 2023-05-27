-- ========================================================
-- @File    : uw_setup_keystroke.lua
-- @Brief   : 按键设置
-- ========================================================

---@class tbClass : UUserWidget
---@field ListView UListView
local tbClass = Class("UMG.SubWidget")
local SID = PlayerSetting.SSID_KEYBOARD

local MSID = PlayerSetting.SSID_OPERATION

local ContentType = {
    Mouse        = 11,
    Sensitivity   = 12
}


function tbClass:Construct()
    self.Factory = Model.Use(self)
    self.ListView:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.ListView)

    BtnAddEvent(self.BtnReset, function()
        self:OnReset()
    end)

    self.Padding = UE4.FMargin()
    self.Padding.Left = 30
    self.Padding.Top = 0
    self.Padding.Right = 0
    self.Padding.Bottom = 0

    self.MouseSet:Set({sName = "setting.mouse_setting", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(MSID, ContentType.Mouse)
        self:ResetPart(tb, "setting.mouse_setting")
    end})

    self.Sensitivity:Set({sName = "setting.sensitivity_setting", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(MSID, ContentType.Sensitivity)
        self:ResetPart(tb, "setting.sensitivity_setting")
    end})

    self.KeyMouseSet:Set({sName = 'ui.TxtOperationSet.FightKey', pFunc = function ()
        UI.Open("MessageBox", string.format(Text("ui.TxtSetReset"), Text('ui.TxtOperationSet.FightKey')) , function ()
            self:OnReset()
        end)
    end})

    self.tbContents = {
        self.MouseSet,
        self.Sensitivity,
        self.Content1,
        self.Content2
    }

    self.tbWidgets = {}
end

function tbClass:Destruct()
    local pSubSystem = UE4.UUIGameInstanceSubsystem.Get()
    if IsValid(pSubSystem) and pSubSystem.SetMouseUpEventDispatch then
        pSubSystem:SetMouseUpEventDispatch(false)
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

    PlayerSetting.InitWidget(MSID, widget, tbCfg, nil, self.tbWidgets)
end

function tbClass:ResetPart(tbPart, sLabel)
    UI.Open("MessageBox", string.format(Text("ui.TxtSetReset"), Text(sLabel)) , function ()
        for _,v in ipairs(tbPart) do
            PlayerSetting.ResetBySIDAndType(MSID, v)
        end
        self:UpdateMouseSetting()
    end)
end

function tbClass:UpdateMouseSetting()
    WidgetUtils.CollapsedWidgets(self.tbContents)
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    for _,v in ipairs(PlayerSetting.tbOperationSort) do
        self:SwitchContent(v, IsPc)
    end
    PlayerSetting.CheckConnect(MSID, self.tbWidgets)
end


function tbClass:OnActive()
    self:Update(UE4.EKeyboardInputType.Keyboard)
    WidgetUtils.SelfHitTestInvisible(self.ListView)

    local nCheckIndex = (self.nActiveType == UE4.EKeyboardInputType.Keyboard and 0 or 1)

    self.OperatingMode:Set({ tbData = {0, 'operation_setting', {'keyboardType', 'gamepadType'}}, nCheckIndex = nCheckIndex, fOnChange = function(nIndex)
        self.nSelectIdx = nIndex
        self:Update(UE4.EKeyboardInputType.Keyboard)
    end})

    WidgetUtils.Collapsed(self.OperatingMode)

    self:UpdateMouseSetting()

    local pSubSystem = UE4.UUIGameInstanceSubsystem.Get()
    if IsValid(pSubSystem) and pSubSystem.SetMouseUpEventDispatch then
        pSubSystem:SetMouseUpEventDispatch(true)
    end
end

function tbClass:Update(nType)
    print('Update ===>', nType)

    UE4.UGameInputKeySelector.SetInputType(nType)
    self.nActiveType = nType
    self.tbAllConflictKeys = {}
    self:DoClearListItems(self.ListView)
    local Keys = UE4.UGameKeyboardLibrary.GetKeyboardCfgRows()

    for i = 1, Keys:Length() do
        local sKey = Keys:Get(i)
        local pItem = UE4.UGameKeyboardLibrary.GetKeyboardItem(sKey)

        if nType == UE4.EKeyboardInputType.Keyboard and pItem.bAllowKeyboard then
            local tbParam = {sKey = sKey, pListView = self.ListView, parent = self, nInputType = nType, onClick = function (sl)
                self:OnClickOneKey(sl)
            end,onUnSl = function (sl)
                self:OnClickOneKeyEnd(sl)
            end,index = i,KeyboardItem = pItem}
            local pObj = self.Factory:Create(tbParam)
            self.ListView:AddItem(pObj)
        end
    end


    if nType == UE4.EKeyboardInputType.Keyboard then
        WidgetUtils.Collapsed(self.XboxHandle)
        WidgetUtils.Collapsed(self.PSHandle)
    end
end

function tbClass:HideTip()
    local pUI = UI.GetUI('SetUp')
    if pUI then
        pUI:ShowKeyTip(false)
    end
end

function tbClass:OnDisable()
    self:HideTip()
    self.tbAllConflictKeys = {}


    local pSubSystem = UE4.UUIGameInstanceSubsystem.Get()
    if IsValid(pSubSystem) and pSubSystem.SetMouseUpEventDispatch then
        pSubSystem:SetMouseUpEventDispatch(false)
    end
end

function tbClass:OnReset()
    --PlayerSetting.ResetBySID(SID)
    UE4.UGameKeyboardLibrary.LoadSetting(true)
    self:OnActive()
    self:HideTip()
end

function tbClass:OnClickOneKey(sl)
    if not sl then return end;
    if self.selected then
        WidgetUtils.Collapsed(self.selected)
    end
    self.selected = sl;
    WidgetUtils.SelfHitTestInvisible(sl)
end

function tbClass:OnClickOneKeyEnd(sl)
    self.selected = nil;
    WidgetUtils.Collapsed(sl)
end

function tbClass:NotifyUpdate()
   
end

return tbClass