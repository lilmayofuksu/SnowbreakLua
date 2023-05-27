-- ========================================================
-- @File    : uw_setup_operation.lua
-- @Brief   : 设置
-- ========================================================
---@class tbClass : UUserWidget
---@field Content UWrapBox
local tbClass = Class("UMG.SubWidget")

local SID = PlayerSetting.SSID_OPERATION

local ContentType = {
    Fight        = 3,
    Aim          = 4
}

function tbClass:Construct()
    self.Padding = UE4.FMargin()
    self.Padding.Left = 30
    self.Padding.Top = 0
    self.Padding.Right = 0
    self.Padding.Bottom = 0


    self.FightSet:Set({sName = "ui.TxtOperationSet.Fight"})

    self.AimSet:Set({sName = "ui.TxtOperationSet.Aim", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Aim)
        self:ResetPart(tb, "ui.TxtOperationSet.Aim")
    end})

    BtnAddEvent(self.BtnCustomize, function ()
        UI.Open('Customize')
    end)

    local tbActions = {
        self.Action1,
        self.Action2,
        self.Action3
    }
    local nCheckIndex = math.max(PlayerSetting.GetOne(SID, OperationType.ACTION_MODE), 1)
    local nImgIndex = 1003032
    for i,v in ipairs(tbActions) do
        v:Set({ sName = 'ui.TxtSetAction'..i, sDetail = 'ui.TxtSetActionDetail'..i, nIndex = i, bSelected = nCheckIndex == i, nImg = nImgIndex + i, fOnChange = function (nIndex)
            local tbCfg = PlayerSetting.tbOperationCfg[OperationType.ACTION_MODE]
            if tbCfg.Connect then
                for k,tb in pairs(tbCfg.Connect) do
                    if self.tbWidgets[k] then
                        local bDisable = false
                        for _,v in ipairs(tb) do
                            bDisable = bDisable or (v == nIndex)
                        end
                        self.tbWidgets[k]:Disable(bDisable)
                    end
                end
            end
        end})
    end

    self.tbContents = {
        self.FightSet,
        self.AimSet,
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

function tbClass:AddToFight(Widget)
    WidgetUtils.SelfHitTestInvisible(self.FightSet)
    WidgetUtils.SelfHitTestInvisible(self.Content1)
    self.Content1:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:AddToAim(Widget)
    WidgetUtils.SelfHitTestInvisible(self.AimSet)
    WidgetUtils.SelfHitTestInvisible(self.Content2)
    self.Content2:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:SwitchContent(tbCfg, isPc)
    if not PlayerSetting.IsPageContent(tbCfg, isPc, ContentType) then return end
    local widget = self:GetWidget(tbCfg)
    if Contains(tbCfg.Category, ContentType.Fight) then
        self:AddToFight(widget)
    elseif Contains(tbCfg.Category, ContentType.Aim) then
        self:AddToAim(widget)
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
    WidgetUtils.CollapsedWidgets(self.tbContents)
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    for _,v in ipairs(PlayerSetting.tbOperationSort) do
        self:SwitchContent(v, IsPc)
    end
    PlayerSetting.CheckConnect(SID, self.tbWidgets)
end

return tbClass