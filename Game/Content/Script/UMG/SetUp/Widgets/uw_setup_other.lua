-- ========================================================
-- @File    : uw_setup_other.lua
-- @Brief   : 设置
-- ========================================================

local tbClass = Class("UMG.SubWidget")
local SID = PlayerSetting.SSID_OTHER

local ContentType = {
    Misc        = 50
}

function tbClass:Construct()
    self.Padding = UE4.FMargin()
    self.Padding.Left = 30
    self.Padding.Top = 0
    self.Padding.Right = 0
    self.Padding.Bottom = 0

    self.tbWidgets = {}

    self.tbContents = {
        self.OtherSet,
        self.Content1
    }

    BtnAddEvent(self.BtnReset, function()
        self:OnReset()
    end)

    self.OtherSet:Set({sName = "ui.TxtOperationSet.Misc", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Misc)
        self:ResetPart(tb, "ui.TxtOperationSet.Misc")
    end})

    self.tbFunction = {
        [OtherType.CUSTOMER_SERVICE] = function ()
            Login.CustomerService()
        end,
        [OtherType.EXCHANGE] = function ()
            UI.Open('exchange')
        end,
        [OtherType.BACK_TO_LOGIN] = function ()
            if me then
                if not IsMobile() and string.find(UE4.UGameLibrary.GetChannelId(), "bili") then
                    me:Logout()
                else
                    me:Logout(true)
                end
            end
            GoToLoginLevel()
        end
    }
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

function tbClass:AddToMisc(Widget)
    WidgetUtils.SelfHitTestInvisible(self.OtherSet)
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

    if Contains(tbCfg.Category, ContentType.Misc) then
        self:AddToMisc(widget)
    end

    PlayerSetting.InitWidget(SID, widget, tbCfg, self.tbFunction, self.tbWidgets)
end

function tbClass:ResetPart(tbPart, sLabel)
    UI.Open("MessageBox", string.format(Text("ui.TxtSetReset"), Text(sLabel)) , function ()
        for _,v in ipairs(tbPart) do
            PlayerSetting.ResetBySIDAndType(SID, v)
            if v == OtherType.UI_SAFE_ZONE_SCALE then
                self:ResetUISafe()
            end
        end
        self:OnActive()
    end)
end

function tbClass:OnActive()
    WidgetUtils.CollapsedWidgets(self.tbContents)
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    for _,v in ipairs(PlayerSetting.tbOtherSort) do
        --兑换码
        if v.Type == OtherType.EXCHANGE then
            if not Player.tbSetting or Player.tbSetting['GiftCode'] ~= 1 then
                self:SwitchContent(v, IsPc)
            end
        else
            self:SwitchContent(v, IsPc)
        end
    end
    PlayerSetting.CheckConnect(SID, self.tbWidgets)
end

function tbClass:OnReset()
    PlayerSetting.ResetBySID(SID)
    self:OnActive()
    for _, nType in pairs(OtherType) do
        local value = PlayerSetting.Get(SID, nType)
        SettingEvent.Trigger(SID, nType, value)
    end
    self:ResetUISafe()
end

function tbClass:ResetUISafe()
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    if not IsPc and self.tbWidgets[OtherType.UI_SAFE_ZONE_SCALE] then
        self.tbWidgets[OtherType.UI_SAFE_ZONE_SCALE]:OnReset();
    end
end

return tbClass