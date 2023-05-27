-- ========================================================
-- @File    : umg_asklanguage.lua
-- @Brief   : 语言切换
-- ========================================================
---@class tbClass UUserWidget
local tbClass = Class("UMG.BaseWidget")

---@class OpenType 打开类型
local OpenType = {}
OpenType.Language   = 1
OpenType.Voice      = 2

function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function() 
        self:ToggleLanOption()
        self:ToggleVoiceOption()
    end)
    BtnAddEvent(self.BtnOK, function() self:DoConfirm() end)
    BtnAddEvent(self.BtnNo, function() UI.Close(self) end)
    BtnAddEvent(self.BtnLanSelect, function()
        self:ToggleLanOption()
    end)

    self.LanOption.OnOptionSelectChange:Add(self, function(_, nIndex)
       self.nLanSelectIndex = nIndex + 1
       self:ToggleLanOption()
       self:UpdateSelectLan()
    end)

    BtnAddEvent(self.BtnVioSelect, function()
        self:ToggleVoiceOption()
    end)

    self.LanOption_1.OnOptionSelectChange:Add(self, function(_, nIndex)
       self.nVoiceSelectIndex = nIndex + 1
       self:ToggleVoiceOption()
       self:UpdateSelectVoice()
    end)

    self.nLanSelectIndex = 1
    self.nVoiceSelectIndex = 1
end

---@param nType OpenType
---@param bAsk 登陆界面询问
function tbClass:OnOpen(nType, bAsk)
    self.bLoginAsk = bAsk
    self:ShowLanguage()
    self:ShowVoice()
end

--显示语言
function tbClass:ShowLanguage()
    WidgetUtils.Collapsed(self.PanelLanList)
    WidgetUtils.SelfHitTestInvisible(self.SelectLanguage)

    local tbLanguage = Localization.GetLanguages() or {}
    local tbLanguageImgs = Localization.GetLanguageImgs() or {}
    local sLanguage = Localization.GetCurrentLanguage()

    local array = UE4.TArray('')
    for nIdx, sLan in ipairs(tbLanguage) do
        array:Add(Text('setting.'.. sLan))
        if sLan == sLanguage then
            self.nLanSelectIndex = nIdx
        end
    end
    self.LanOption:SetOption(array, self.nLanSelectIndex - 1)
    self:UpdateSelectLan()

    for nIdx, nIcon in ipairs(tbLanguageImgs) do
        local pChild = self.LanOption.OptionContent:GetChildAt(nIdx - 1)
        if pChild then
            SetTexture(pChild.ImgLanguage, tonumber(nIcon))
            SetTexture(pChild.ImgLanguage1, tonumber(nIcon))

            WidgetUtils.Collapsed(pChild.TxtSwitch)
            WidgetUtils.Collapsed(pChild.TxtSwitch1)
        end
    end
end

function tbClass:ToggleLanOption()
    if self.bShowLan then
        WidgetUtils.Collapsed(self.PanelLanList)
        self.bShowLan = false
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelLanList)
        self.bShowLan = true
    end
end

function tbClass:UpdateSelectLan()
    if self.nLanSelectIndex then
        local tbLan = Localization.GetLanguageImgs() or {}
        local sLan = tbLan[self.nLanSelectIndex]
        if sLan then
            SetTexture(self.ImgLanguage, tonumber(sLan))
        end
    end
end

function tbClass:DoConfirm()
    if self.nLanSelectIndex then
        local tbLan = Localization.GetLanguages() or {}
        Localization.SwitchLanguage(tbLan[self.nLanSelectIndex])
        if self.bLoginAsk then
            --打点
            Adjust.DoRecord("h62u6i");
        end
    end

    if self.nVoiceSelectIndex then
        local tbVoice = Localization.GetVoices() or {}
        Localization.SetCurrentVoiceLanguage(tbVoice[self.nVoiceSelectIndex])
    end

    UI.Close(self)
end

--显示语音
function tbClass:ShowVoice()
    WidgetUtils.Collapsed(self.PanelVoiList)
    WidgetUtils.SelfHitTestInvisible(self.SelectVoice)

    local tbVoice = Localization.GetVoices() or {}
    local tbVoiceImgs = Localization.GetVoiceImgs() or {}
    local sVoice = Localization.GetCurrentVoiceLanguage()

    local array = UE4.TArray('')
    for nIdx, sLan in ipairs(tbVoice) do
        array:Add(Text('setting.'.. sLan))
        if sLan == sVoice then
            self.nVoiceSelectIndex = nIdx
        end
    end
    self.LanOption_1:SetOption(array, self.nVoiceSelectIndex - 1)
    self:UpdateSelectVoice()

    for nIdx, nIcon in ipairs(tbVoiceImgs) do
        local pChild = self.LanOption_1.OptionContent:GetChildAt(nIdx - 1)
        if pChild then
            SetTexture(pChild.ImgLanguage, tonumber(nIcon))
            SetTexture(pChild.ImgLanguage1, tonumber(nIcon))

            WidgetUtils.Collapsed(pChild.TxtSwitch)
            WidgetUtils.Collapsed(pChild.TxtSwitch1)
        end
    end
end

function tbClass:ToggleVoiceOption()
    if self.bShowVoice then
        WidgetUtils.Collapsed(self.PanelVoiList)
        self.bShowVoice = false
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelVoiList)
        self.bShowVoice = true
    end
end

function tbClass:UpdateSelectVoice()
    if self.nVoiceSelectIndex then
        local tbVoice = Localization.GetVoiceImgs() or {}
        local sVoice = tbVoice[self.nVoiceSelectIndex]
        if sVoice then
            SetTexture(self.ImgVoice, tonumber(sVoice))
        end
    end
end

return tbClass