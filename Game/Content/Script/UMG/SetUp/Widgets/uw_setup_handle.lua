-- ========================================================
-- @File    : uw_setup_handle.lua
-- @Brief   : 手柄设置
-- ========================================================

---@class tbClass : UUserWidget

local tbClass = Class("UMG.SubWidget")

local SID = PlayerSetting.SSID_HANDLE

local ContentType = {
    Basis = 1,
    Steering = 2,
    Move = 3
}

function tbClass:Construct()
    self.Padding = UE4.FMargin()
    self.Padding.Left = 30
    self.Padding.Top = 0
    self.Padding.Right = 0
    self.Padding.Bottom = 0

    --TxtFunction_Basis
    self.HandleFunctionSet:Set({sName = "ui.TxtFunction_Basis"})

    self.TurnSet:Set({sName = "ui.TxtSteering", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Steering)
        self:ResetPart(tb, "ui.TxtSteering")
    end})

    self.MoveSet:Set({sName = 'ui.TxtMove', pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Move)
        self:ResetPart(tb, 'ui.TxtMove')
    end})

    self.tbFunc = {
        [HandleType.KEYBOARD] = function(nCurrentIndex)
            UI.Open('HandleKeyPop')
        end,
        [HandleType.DETAIL_SETTING] = function (nIndex)
            UI.Open('HandleViewPop')
        end
    }

    self.tbContents = {
        self.HandleFunctionSet,
        self.TurnSet,
        self.MoveSet,
        self.Content1,
        self.Content2,
        self.Content3
    }

    self.tbWidgets = {}
end

function tbClass:ResetPart(tbPart, sLabel)
    UI.Open("MessageBox", string.format(Text("ui.TxtSetReset"), Text(sLabel)) , function ()
        for _,v in ipairs(tbPart) do
            PlayerSetting.ResetBySIDAndType(SID, v)
        end
        self:OnActive()
    end)
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

function tbClass:AddToBasis(Widget)
    WidgetUtils.SelfHitTestInvisible(self.HandleFunctionSet)
    WidgetUtils.SelfHitTestInvisible(self.Content1)
    self.Content1:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:AddToSteering(Widget)
    WidgetUtils.SelfHitTestInvisible(self.TurnSet)
    WidgetUtils.SelfHitTestInvisible(self.Content2)
    self.Content2:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:AddToMove(Widget)
    WidgetUtils.SelfHitTestInvisible(self.MoveSet)
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
    
    if Contains(tbCfg.Category, ContentType.Basis) then
        self:AddToBasis(widget)
    elseif Contains(tbCfg.Category, ContentType.Steering) then
        self:AddToSteering(widget)
    elseif Contains(tbCfg.Category, ContentType.Move) then
        self:AddToMove(widget)
    end

    PlayerSetting.InitWidget(SID, widget, tbCfg, self.tbFunc, self.tbWidgets)
end

function tbClass:OnActive()
    WidgetUtils.CollapsedWidgets(self.tbContents)
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    for _,v in ipairs(PlayerSetting.tbHandleSort) do
        self:SwitchContent(v, IsPc)
    end
    PlayerSetting.CheckConnect(SID, self.tbWidgets)
end

return tbClass