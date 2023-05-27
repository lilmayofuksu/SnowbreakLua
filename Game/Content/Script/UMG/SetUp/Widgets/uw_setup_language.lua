-- ========================================================
-- @File    : uw_setup_language.lua
-- @Brief   : 语言设置
-- ========================================================

---@class tbClass : UUserWidget
local tbClass = Class("UMG.SubWidget")

local SID = PlayerSetting.SSID_LANGUAGE

local ContentType = {
   Lang = 1
}

function tbClass:Construct()
   self.Padding = UE4.FMargin()
   self.Padding.Left = 30
   self.Padding.Top = 0
   self.Padding.Right = 0
   self.Padding.Bottom = 0

   BtnAddEvent(self.BtnManage, function ()
      UI.Open("LanguageManage")
   end)

   BtnAddEvent(self.BtnReset, function()
        self:OnReset()
   end)
   WidgetUtils.Collapsed(self.BtnReset)

   self.tbWidgets = {}

   self.LanguageSet:Set({sName = "ui.TxtOperationSet.Multilingual", pFunc = function ()
      local tb = PlayerSetting.GetTypesByCategory(SID, ContentType.Lang)
      self:ResetPart(tb, "ui.TxtOperationSet.Multilingual")
  end})

   local tbIndex = Login.IsOversea() and {1, 2, 3} or {1, 2}
   self.tbFunc = {
      [LanguageType.VOICE] = function(nCurrentIndex) 
         print('change voice:', nCurrentIndex)
         local nLanguageIndex = tbIndex[nCurrentIndex + 1] or 1
         Localization.SetCurrentVoiceLanguage(Localization.GetVoiceLanguage(nLanguageIndex))
         Localization.NotifyLanSetting(3, Localization.GetVoiceLanguage(nLanguageIndex))
      end,
      [LanguageType.LANGUAGE] = function (nIndex)
         local tbLan = Localization.GetLanguages()
         PlayerSetting.JumpTabName = 'setting.language'
         Localization.SwitchLanguage(tbLan[nIndex + 1])
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

function tbClass:Align(Widget)
   local slot = UE4.UWidgetLayoutLibrary.SlotAsWrapBoxSlot(Widget)
   slot:SetPadding(self.Padding)
   slot:SetFillEmptySpace(true)
end

function tbClass:AddToLang(Widget)
   self.Content1:AddChildToWrapBox(Widget)
   self:Align(Widget)
end

function tbClass:SwitchContent(tbCfg, isPc)
   if not PlayerSetting.IsPageContent(tbCfg, isPc, ContentType) then return end
   local widget = self:GetWidget(tbCfg)

   if Contains(tbCfg.Category, ContentType.Lang) then
       self:AddToLang(widget)
   end

   if tbCfg.Type == LanguageType.LANGUAGE or tbCfg.Type == LanguageType.VOICE then
      local tb = tbCfg.Items or {'close', 'open'}
      local check = 0;
      -- 海外语言适配
      if tbCfg.Type == LanguageType.LANGUAGE then
         local tbLang = Localization.GetLanguages()
         local curLang = Localization.GetCurrentLanguage()
         for index, value in ipairs(tbLang) do
             if value == curLang then
                 check = index - 1
             end
         end
         if not Login.IsOversea() then
            -- 国内语言选项只留简体中文
            tb = {tbCfg.Items[1]}
         end
      elseif tbCfg.Type == LanguageType.VOICE then
         local curVoice = Localization.GetCurrentVoiceLanguage()
         local tbVoice = Localization.tbVoiceLanguage
         tb = Login.IsOversea() and Localization.tbOverseaVoiceImgs or Localization.tbVoiceImgs

         for index, value in ipairs(tbVoice) do
            if value == curVoice then
               check = index - 1
            end
         end
      end
      widget:Set({ tbData = {0, tbCfg.Name, tb}, nCheckIndex = check, fOnChange = function(nIndex)
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
         if self.tbFunc[tbCfg.Type] then
            self.tbFunc[tbCfg.Type](nIndex)
         end
      end, bMulti = tbCfg.Multi, tip = tbCfg.BanTip, bImg = true})
      return
   end

   PlayerSetting.InitWidget(SID, widget, tbCfg, self.tbFunc, self.tbWidgets)
end

function tbClass:ResetPart(tbPart, sLabel)
   UI.Open("MessageBox", string.format(Text("ui.TxtSetReset"), Text(sLabel)) , function ()
      for _,v in ipairs(tbPart) do
         PlayerSetting.ResetBySIDAndType(SID, v)
         if self.tbFunc[v] then
           self.tbFunc[v](PlayerSetting.Get(SID, v)[1])
         end
      end
      self:OnActive()
  end)
end
 
function tbClass:OnActive()
   self:LoadVoice()
   local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
   for _,v in ipairs(PlayerSetting.tbLangSort) do
        self:SwitchContent(v, IsPc)
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
 end

 function tbClass:LoadVoice()
   local tbVoiceSave = PlayerSetting.Get(SID, SoundType.LANGUAGE)
   local tbIndex = Login.IsOversea() and {1, 2, 3} or {1, 2}

   local nVoiceIdx = 0
   if type(tbVoiceSave) == "table" then 
      local nLen = #tbVoiceSave
      if nLen > 1 then 
         nVoiceIdx = tbVoiceSave[2] or 0
         if (type(nVoiceIdx) ~= "number") then       
            nVoiceIdx = 0
         end
      elseif nLen > 0 then 
         local nKey = tbVoiceSave[1] or 0
         local bFind = false
         for k, v in ipairs(tbIndex) do 
            if (not bFind) and (nKey + 1 == v) then 
               nVoiceIdx = k
               bFind = true
            end
         end
      end
   end

   if (nVoiceIdx < 0 or nVoiceIdx >= #tbIndex) then
      print('try to fixed voice:', nVoiceIdx)
      if self.tbFunc[LanguageType.VOICE] then
         self.tbFunc[LanguageType.VOICE](0)
      end
   end
 end

return tbClass