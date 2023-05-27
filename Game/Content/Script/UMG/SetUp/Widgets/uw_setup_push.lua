-- ========================================================
-- @File    : uw_setup_push.lua
-- @Brief   : 推送设置
-- ========================================================
local tbClass = Class("UMG.SubWidget")

local SID = PlayerSetting.SSID_NOTIFICATION

local ContentType = {
    Push        = 70,
}

function tbClass:Construct()
    self.Padding = UE4.FMargin()
    self.Padding.Left = 30
    self.Padding.Top = 0
    self.Padding.Right = 0
    self.Padding.Bottom = 0

    self.tbWidgets = {}

    BtnAddEvent(self.BtnReset, function()
        self:OnReset()
    end)

    self.tbContents = {
        self.PushSet,
        self.Content1
    }

    self.PushSet:Set({sName = "ui.TxtMsgPush", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Push)
        self:ResetPart(tb, "ui.TxtMsgPush")
    end})
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

function tbClass:AddToPush(Widget)
    WidgetUtils.SelfHitTestInvisible(self.PushSet)
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
    
    if Contains(tbCfg.Category, ContentType.Push) then
        self:AddToPush(widget)
    end

    PlayerSetting.InitWidget(SID, widget, tbCfg, self.tbFunction, self.tbWidgets)
end

function tbClass:ResetPart(tbPart, sLabel)
    UI.Open("MessageBox", string.format(Text("ui.TxtSetReset"), Text(sLabel)) , function ()
        for _,v in ipairs(tbPart) do
            PlayerSetting.ResetBySIDAndType(SID, v)
        end
        self:OnActive()
    end)
end

function tbClass:OnReset()
    PlayerSetting.ResetBySID(SID)
    self:OnActive()
    for _, nType in pairs(OtherType) do
        local value = PlayerSetting.Get(SID, nType)
        SettingEvent.Trigger(SID, nType, value)
    end
end

function tbClass:OnActive()
    WidgetUtils.CollapsedWidgets(self.tbContents)
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    for _,v in ipairs(PlayerSetting.tbNoticeSort) do
        self:SwitchContent(v, IsPc)
    end
    PlayerSetting.CheckConnect(SID, self.tbWidgets)

    -- local nCheckIndex = 0
    -- if LocalNotification.GameNotification("ENERGY_RECOVER"):IsEnable() then
    --     nCheckIndex = 1
    -- end
    -- self.strength:Set({
    --     tbData = {0, 'energy_full', {'close', 'open'}},
    --     nCheckIndex = nCheckIndex,
    --     fOnChange = function(nIndex)
    --         LocalNotification.GameNotification("ENERGY_RECOVER"):SetEnable(nIndex > 0)
    --     end
    -- })

end

return tbClass
