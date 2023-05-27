local uw_fight_level_skillintro = Class("UMG.SubWidget")

uw_fight_level_skillintro.CurrentIndex = 1
uw_fight_level_skillintro.MaxIndex = 3
uw_fight_level_skillintro.RoleId = 1
uw_fight_level_skillintro.TabKeyHandle = nil
function uw_fight_level_skillintro:Construct()
    self.ListFactory = Model.Use(self)
end

function uw_fight_level_skillintro:Init(Index, Max, RoleId,KeyName)
    if not self.FightUI then
        self.FightUI = UI.GetUI("Fight")
    end

    BtnAddEvent(self.BtnChange, function() self:BtnChangeClick() end)
    print("uw_fight_level_skillintro Init:", self, Index, Max, RoleId)
    self:SetData(Index, Max, RoleId,KeyName)

    self.FightUI:UnbindFromAnimationFinished(
        self.FightUI.TaskOff,
        { self, uw_fight_level_skillintro.PostTaskOffFinish })
    self.FightUI:UnbindFromAnimationStarted(
        self.FightUI.TaskOn,
        { self, uw_fight_level_skillintro.PreTaskOnStart })
    self.FightUI:BindToAnimationEvent(
        self.FightUI.TaskOff,
        { self, uw_fight_level_skillintro.PostTaskOffFinish },
        UE4.EWidgetAnimationEvent.Finished
    )
    self.FightUI:BindToAnimationEvent(
        self.FightUI.TaskOn,
        { self, uw_fight_level_skillintro.PreTaskOnStart },
        UE4.EWidgetAnimationEvent.Started
    )
    if self.TabKeyHandle ~= nil then
        EventSystem.Remove(self.TabKeyHandle)
    end

    self:RegisterEvent(Event.OnKeyBoardSettingChanged,function (sBindKey,pKeyName,pKeyCfg)
        if pKeyName then
            pKeyCfg = Keyboard.Get(pKeyName)
        end

        if sBindKey == 'Txttipstab' then
            self:UpdateKeyboard()
        end
    end)

    self:UpdateKeyboard()

    if Max == 1 or IsMobile() then
        WidgetUtils.Collapsed(self.PanelKeystorke)
    else
        WidgetUtils.Visible(self.PanelKeystorke)
        print("uw_fight_level_skillintro Tabkey visible 0")
        self.TabKeyHandle = EventSystem.On(Event.PCKeyboardEvent,
        function(key, type)
            -- print("uw_fight_level_skillintro Tabkey visible 1", key)
            if key == UE4.EPCKeyboardType.SwitchSkillIntro then
                -- print("uw_fight_level_skillintro Tabkey visible 2")
                self:BtnChangeClick()
            end
        end)
    end
end

function uw_fight_level_skillintro:UpdateKeyboard()
    --[[local key = UE4.UGameKeyboardLibrary.GetInputChord('Txttipstab')
    local keyName = UE4.UGameKeyboardLibrary.GetInputChordShowName(key)
    local cfg = Keyboard.Get(keyName)
    --self.TxtKeystorke1:SetText(string.format(Text("ui.Txttipstab_fight"), keyname))
    self:SetKeyboardName(cfg,keyName,self.ImgKey,self.TxtKeystorke1)
    WidgetUtils.Collapsed(self.TxtAdd)
    WidgetUtils.Collapsed(self.ImgKeyAdd)
    Keyboard:ShowCombinedKeyTxt(key,self.TxtKeystorke,self.TxtAdd_1)]]

    self.KeyBtn:UpdateKeyShow('Txttipstab')
end

-- function uw_fight_level_skillintro:SetKeyboardName(cfg, keyName, Img, Txt)
--     if not Img or not Txt then return end
--     if cfg and cfg.nIcon > 0 then
--         WidgetUtils.Collapsed(Txt)
--         WidgetUtils.SelfHitTestInvisible(Img)
--         SetTexture(Img, cfg.nIcon)
--         WidgetUtils.SelfHitTestInvisible(self.KeyStore)
--         WidgetUtils.Collapsed(self.HandleKey)
--     else
--         WidgetUtils.Collapsed(Img)
--         WidgetUtils.SelfHitTestInvisible(Txt)
--         Txt:SetText(cfg and cfg.sName or keyName)

--         WidgetUtils.SelfHitTestInvisible(self.HandleKey)
--         WidgetUtils.Collapsed(self.KeyStore)
--     end
-- end

function uw_fight_level_skillintro:OnDestruct()
    print("uw_fight_level_skillintro OnDestruct")
    EventSystem.Remove(self.TabKeyHandle)

    if self.EventOnInputTypeChange then
        EventSystem.Remove(self.EventOnInputTypeChange)
    end 

    if self.EventOnKeyBoardSettingChanged then
        EventSystem.Remove(self.EventOnKeyBoardSettingChanged)
    end 
end

function uw_fight_level_skillintro:PreTaskOnStart()
    print("uw_fight_level_skillintro:PreTaskOnStart")
    WidgetUtils.SelfHitTestInvisible(self)
end

function uw_fight_level_skillintro:PostTaskOffFinish()
    print("uw_fight_level_skillintro:PostTaskOffFinish")
    WidgetUtils.Collapsed(self)
end

function uw_fight_level_skillintro:SetData(Index, Max, RoleId,KeyName)
    self.CurrentIndex = Index
    self.MaxIndex = Max
    self.RoleId = RoleId
    self.KeyNameForSkillIntro = KeyName
    local Id = self.RoleId * 1000 + self.CurrentIndex * 100
    local SkillIntroConf = GachaTry.GetSkillIntroConf(Id)
    if SkillIntroConf then
        self:DoClearListItems(self.TxtType)
        print("uw_fight_level_skillintro Id:", Id, "SkillIntroConf:", SkillIntroConf)
        local SkillId = SkillIntroConf.nSkillId
        local SkillTag = RoleCard.GetSkillTagID(SkillId)
        for _, TagID in ipairs(SkillTag) do
            local pObj = self.ListFactory:Create({nID = TagID})
            self.TxtType:AddItem(pObj)
        end
    end

    if self.MaxIndex <= 1 then
        WidgetUtils.Collapsed(self.BtnChange)
        print("uw_fight_level_skillintro MaxIndex:", self.MaxIndex)
    else
        print("uw_fight_level_skillintro MaxIndex:", self.MaxIndex)
        WidgetUtils.Visible(self.BtnChange)
    end

    local Title = Localization.GetSkillIntroName(Id)
    local Desc = Localization.GetSkillIntroDesc(Id)
    if KeyName then
        if IsMobile() then
            Desc = string.format(Desc,Text('ui.'..KeyName))
        else
            local key1 = UE4.UGameKeyboardLibrary.GetInputChord(KeyName)
            local keyName1 = UE4.UGameKeyboardLibrary.GetInputChordShowName(key1)
            local cfg1 = Keyboard.Get(keyName1)
            if cfg1 and cfg1.sName then
                Desc = string.format(Desc,Text(cfg1.sName))
            end
        end

        if not self.EventOnInputTypeChange then
            self.EventOnInputTypeChange = EventSystem.On(Event.OnInputTypeChange, function()
                self:SetData(self.CurrentIndex,self.MaxIndex,self.RoleId,self.KeyNameForSkillIntro)
            end)
        end

        if not self.EventOnKeyBoardSettingChanged then        
            self.EventOnKeyBoardSettingChanged = EventSystem.On(Event.OnKeyBoardSettingChanged,function (sBindKey,pKeyName,pKeyCfg)
                if sBindKey == self.KeyNameForSkillIntro then
                    self:SetData(self.CurrentIndex,self.MaxIndex,self.RoleId,self.KeyNameForSkillIntro)
                end
            end)
        end
    end
    self:ShowIntro(Title, Desc)
end

function uw_fight_level_skillintro:ShowIntro(Title, Desc)
    self.TxtName:SetContent(Title)
    self.SkillTxt:SetContent(Desc)
end

function uw_fight_level_skillintro:SwapShowIcon(ShowInfo)
    if ShowInfo then
        WidgetUtils.Collapsed(self.ImgSkill)
        WidgetUtils.SelfHitTestInvisible(self.ImgTips)
    else
        WidgetUtils.Collapsed(self.ImgTips)
        WidgetUtils.SelfHitTestInvisible(self.ImgSkill)
    end
end

function uw_fight_level_skillintro:BtnChangeClick()
    self:SetData(self.CurrentIndex % self.MaxIndex + 1, self.MaxIndex, self.RoleId)
    self:PlayAnimFromAnimation(self.Change)
end

return uw_fight_level_skillintro
