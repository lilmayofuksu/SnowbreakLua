-- ========================================================
-- @File    : uw_setup_sound.lua
-- @Brief   : 设置
-- ========================================================

local tbClass = Class("UMG.SubWidget")

local SID = PlayerSetting.SSID_SOUND

local ContentType = {
    Sound        = 30
}

function tbClass:Construct()

    self.tbClassType = {
        [0] = "/Game/UI/UMG/SetUp/Widgets/uw_setup_option_item.uw_setup_option_item_C",
        [1] = "/Game/UI/UMG/SetUp/Widgets/uw_setup_opition_choose.uw_setup_opition_choose_C",
        [2] = "/Game/UI/UMG/SetUp/Widgets/uw_setup_slider.uw_setup_slider_C"
    }

    self.Padding = UE4.FMargin()
    self.Padding.Left = 30
    self.Padding.Top = 0
    self.Padding.Right = 0
    self.Padding.Bottom = 0

    self.tbWidgets = {}

    BtnAddEvent(self.BtnReset, function()
        self:OnReset()
    end)

    self.SoundSet:Set({sName = "ui.TxtOperationSet.Volume", pFunc = function ()
        local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Sound)
        self:ResetPart(tb, "ui.TxtOperationSet.Volume")
    end})
end

function tbClass:GetWidget(tbCfg)
    local pWidget = self.tbWidgets[tbCfg.Type]
    if tbCfg then
        if not pWidget then
            pWidget = LoadWidget(self.tbClassType[tbCfg.ClassType])
            if pWidget then
                local nValue = PlayerSetting.GetOne(SID, tbCfg.Type) or 0
                self.tbWidgets[tbCfg.Type] = pWidget
            end
        end
    end
    return pWidget
end

function tbClass:InitWidget(Widget, tbCfg)
    if tbCfg.ClassType < 2 then
        local tb = tbCfg.Items or {'close', 'open'}
        local nValue = PlayerSetting.GetOne(SID, tbCfg.Type) or 0
        local check = tbCfg.Multi and nValue or math.min(nValue, #tb) 
        Widget:Set({ tbData = {0, tbCfg.Name, tb}, nCheckIndex = check, fOnChange = function(nIndex)
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
            PlayerSetting.Set(SID, tbCfg.Type, {nIndex})
        end, bMulti = tbCfg.Multi, tip = tbCfg.BanTip})
    else
        local nMin, nMax = PlayerSetting.GetSliderRange(SID, tbCfg.Type)
        Widget:Init(SID, tbCfg.Type, nMin, nMax, tbCfg.BanTip)
    end
end

function tbClass:IsPageContent(tbCfg, isPc)
    local bVisable = not tbCfg.Hidden
    if tbCfg.Platform ~= 0 then
        if isPc then
            bVisable = bVisable and tbCfg.Platform == 1
        else
            bVisable = bVisable and tbCfg.Platform == 2
        end
    end

    local ret = false;
    for _,v in pairs(ContentType) do
        ret = ret or Contains(tbCfg.Category, v)
    end
    return bVisable and ret
end

function tbClass:AddToSound(Widget)
    self.Content1:AddChildToWrapBox(Widget)
    local slot = UE4.UWidgetLayoutLibrary.SlotAsWrapBoxSlot(Widget)
    slot:SetPadding(self.Padding)
    slot:SetFillEmptySpace(true)
end

function tbClass:SwitchContent(tbCfg, isPc)
    if not self:IsPageContent(tbCfg, isPc) then return end
    local widget = self:GetWidget(tbCfg)
    
    if Contains(tbCfg.Category, ContentType.Sound) then
        self:AddToSound(widget)
    end

    self:InitWidget(widget, tbCfg)
end

function tbClass:ResetPart(tbPart, sLabel)
    UI.Open("MessageBox", string.format(Text("ui.TxtSetReset"), Text(sLabel)) , function ()
        for _,v in ipairs(tbPart) do
            PlayerSetting.ResetBySIDAndType(SID, v)
        end
        self:OnActive()
    end)
end

function tbClass:CheckConnect()
    for _,v in ipairs(PlayerSetting.tbSoundSort) do
        if v.Connect then
            local nValue = PlayerSetting.GetOne(SID, v.Type)
            for k,tb in pairs(v.Connect) do
                if self.tbWidgets[k] then
                    local bDisable = false
                    for _,v in ipairs(tb) do
                        bDisable = bDisable or (v == nValue)
                    end
                    self.tbWidgets[k]:Disable(bDisable)
                    WidgetUtils.SelfHitTestInvisible(self.tbWidgets[k].ImgItem)
                end
            end
        end
    end
end

function tbClass:OnActive()
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    for _,v in ipairs(PlayerSetting.tbSoundSort) do
        self:SwitchContent(v, IsPc)
    end
    self:CheckConnect()
end

function tbClass:OnReset()
    PlayerSetting.ResetBySID(SID)
    self:OnActive()
    for _, nType in pairs(SoundType) do
        local value = PlayerSetting.Get(SID, nType)
        SettingEvent.Trigger(SID, nType, value)
    end
end

return tbClass