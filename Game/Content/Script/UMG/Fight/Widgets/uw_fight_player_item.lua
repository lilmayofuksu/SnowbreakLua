-- ========================================================
-- @File    : uw_fight_player_item.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:RegisterEvent(Event.NotifyReviveCountChanged, function(Count) self:NotifyReviveCountChanged(Count);self:SetPanelKeyVisible(); end)
    self:RegisterEvent(Event.NotifyReviveTimeChange, function(Character) self:NotifyReviveTimeChange(Character);self:SetPanelKeyVisible(); end)
    self:RegisterEvent(Event.OnCharacterReviveEnd, function(Character) self:OnCharacterReviveEnd(Character);self:SetPanelKeyVisible(); end)
    self:RegisterEvent(Event.NotifySelfCharacterDie, function(Character) self:NotifySelfCharacterDie(Character);self:SetPanelKeyVisible(); end)
    self:RegisterEvent( Event.CharacterChange, function() self:SetPanelKeyVisible(); end)
    self:RegisterEvent(Event.OnInputTypeChange, function()
        local PlayerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
        if PlayerController then
            if PlayerController.LastInputGamepad then
                if self.Skill03 and self.Skill03.PanelKeyInfo then
                    WidgetUtils.Collapsed(self.Skill03.PanelKeyInfo)
                end
            end
            self:SetPanelKeyVisible()
            return
        end
        
        if self.Skill03 and self.Skill03.PanelKeyInfo then
            WidgetUtils.HitTestInvisible(self.Skill03.PanelKeyInfo)
        end
    end)
    self:SetPanelKeyVisible()
    self.IsOnlineClient = UE4.UGameLibrary.IsOnlineClient(self:GetOwningPlayer())
    WidgetUtils.Collapsed(self.PanelReviveCion)
    WidgetUtils.Collapsed(self.TxtReviveCionNum)

    self:RegisterEvent(Event.OnKeyBoardSettingChanged,function (sBindKey,pKeyName,pKeyCfg)
        if pKeyName then
            pKeyCfg = Keyboard.Get(pKeyName)
        end
        -- if not self.TxtSkillKey or not self.TxtInfoKey or not self.ImgKey_1 or not self.ImgKey then
        --     return
        -- end
        -- if sBindKey == self.SwitchKey or sBindKey == self.BackSkillKey or sBindKey == self.BackSuperSkillKey then
        if sBindKey == self.SwitchKey or sBindKey == self.BackSkillKey or sBindKey == self.BackSuperSkillKey then
            self:UpdateKeyboard(self.nIndex)
        end

    end)

    self:RegisterEvent(Event.StartRecoverBullet, function(InCharacter)
        if InCharacter == self:GetCacheCharacter() then
            self.PanelCartoon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
            self:PlayAnimation(self.Bullet_loop, 0, 0)
        end
    end)

    self:RegisterEvent(Event.StopRecoverBullet, function(InCharacter)
        if InCharacter == self:GetCacheCharacter() then
            self.PanelCartoon:SetVisibility(UE.ESlateVisibility.Collapsed)
            self:StopAnimation(self.Bullet_loop, 0, 0)
        end
    end)
    
    self.tbLights = {
        self.ImgWhiteLight1,
        self.ImgWhiteLight2,
        self.ImgWhiteLight3,
        self.ImgWhiteLight4,
        self.ImgWhiteLight5,
        self.ImgWhiteLight6,
        self.ImgWhiteLight7,
        self.ImgWhiteLight8
    }

    --[[self:RegisterEvent(Event.OnInputDeviceChange, function()
        self:UpdateKeyboard(self.nIndex)
    end)--]]
end

function tbClass:SetPanelKeyVisible()
    if not IsMobile() then return end

    local PlayerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
    if not PlayerController then return end
    
    if PlayerController.LastInputGamepad then
        WidgetUtils.HitTestInvisible(self.PanelKey)
        WidgetUtils.HitTestInvisible(self.PanelKey2)
    else
        WidgetUtils.Hidden(self.PanelKey)
        WidgetUtils.Hidden(self.PanelKey2)
    end

    local character = self:GetCacheCharacter();
    if not character then return -1, -1 end
    local Controller = character:GetCharacterController()
    if not Controller then return -1, -1 end
    local AllCharacter = Controller:GetPlayerCharacters()
    local Count = AllCharacter:Num()
    if Count <= 1 then return -1, -1 end
    local Up = -1
    local Down = -1
    for i = 1, Count do
        local tmp = AllCharacter:Get(i)
        if tmp:IsCurrentCharacter() then
            if self.nIndex == i then
                WidgetUtils.Hidden(self.PanelKey2)
            end
            break
        end
    end
end

function tbClass:OnDestruct()
    UE4.Timer.Cancel(self.timerId or 0)
    self:RemoveRegisterEvent()
end

function tbClass:NotifyReviveCountChanged(Count)
    self:UpdateReviveCount()
    self:UpdateUIShow()
end

function tbClass:NotifyReviveTimeChange(Character)
    local character = self:GetCacheCharacter()
    if not character or character ~= Character then 
        return 
    end

    self:NotifyUpdateUseReviveCD(true)
    self:UpdateUIShow()
end

function tbClass:OnCharacterReviveEnd(Character)
    local ch = self:GetCacheCharacter()
    if not ch then return end 

    if ch == Character then
        --WidgetUtils.HitTestInvisible(self.PanelRevive)
        --self:PlayAnimFromAnimation(self.Revive) 
        self:Set(Character, Character:IsCurrentCharacter())
    else 
        self:UpdateUIShow()
    end
end

function tbClass:K2_OnCustomUmgAnimFinished(AnimName)
    if AnimName == "Revive" then
        --WidgetUtils.Collapsed(self.PanelRevive)
    elseif AnimName == "CdNumber" then
        for i,v in ipairs(self.tbLights) do
            WidgetUtils.Collapsed(v)
        end
    end
end

function tbClass:GetUpAndDownIndex()
    local character = self:GetCacheCharacter();
    if not character then return -1, -1 end
    local Controller = character:GetCharacterController()
    if not Controller then return -1, -1 end
    local AllCharacter = Controller:GetPlayerCharacters()
    local Count = AllCharacter:Num()
    if Count <= 1 then return -1, -1 end
    local Up = -1
    local Down = -1
    for i = 1, Count do
        local tmp = AllCharacter:Get(i)
        if not tmp:IsCurrentCharacter() then
            Up = i
            break
        end
    end
    if Count <= 2 then return Up, Down end
    for i = Count, 1, -1 do
        local tmp = AllCharacter:Get(i)
        if not tmp:IsCurrentCharacter() then
            Down = i
            break
        end
    end
    return Up, Down
end

function tbClass:NotifyRefreshCharacter()
    if not self.KeyBtn then return end
    local Up, Down = self:GetUpAndDownIndex()
    if Up == self.nIndex then
        self.KeyBtn:GamepadReplaceKey("TxtKeyBackSuperSkillCombo")
    elseif Down == self.nIndex then
        self.KeyBtn:GamepadReplaceKey("TxtKeyBackSkillCombo")
    else
        self.KeyBtn:GamepadReplaceKey(nil)
    end
    self.KeyBtn:UpdateKeyShow(self.BackSkillKey)
end
function tbClass:NotifyDataChange()
    local character = self:GetCacheCharacter();
    local card = character:K2_GetPlayerMember()
    if card then 
        SetTexture(self.Role, card:Icon())
    end

    if not self.IsOnlineClient or not self.PanelReviveCion then return end 

    if character:IsAlive() then 
        WidgetUtils.Collapsed(self.PanelReviveCion)
        return
    end
    --WidgetUtils.SelfHitTestInvisible(self.PanelReviveCion)

    self:UpdateReviveCount();
    self:UpdateUIShow()
end

function tbClass:SetKeyboardName(cfg,keyName, Img, Txt)
    if not Img or not Txt then return end
    if cfg and cfg.nIcon > 0 then
        WidgetUtils.Collapsed(Txt)        
        WidgetUtils.SelfHitTestInvisible(Img)                
        SetTexture(Img, cfg.nIcon) 
    else
        WidgetUtils.Collapsed(Img)
        WidgetUtils.SelfHitTestInvisible(Txt)
        Txt:SetText(cfg and cfg.sName or keyName)
    end
end

function tbClass:UpdateKeyboard(InIndex)

    if not self.SwitchKey then
        self.nIndex = InIndex
        if InIndex then
            self.SwitchKey = "TxtKeySwitch" .. InIndex
            self.BackSkillKey = "TxtKeyBackSkill" .. InIndex
            self.BackSuperSkillKey = "TxtKeyBackSuperSkill" .. InIndex
        end
    end

    -- local key1 = UE4.UGameKeyboardLibrary.GetInputChord(self.SwitchKey)
    -- local keyName1 = UE4.UGameKeyboardLibrary.GetInputChordShowName(key1)
    -- local cfg1 = Keyboard.Get(keyName1)
    -- self:SetKeyboardName(cfg1,keyName1, self.ImgKey, self.TxtInfoKey)

    if self.KeyBtn1 then
        self.KeyBtn1:UpdateKeyShow(self.SwitchKey)
    end

    --[[local key2 = UE4.UGameKeyboardLibrary.GetInputChord(self.BackSkillKey)
    local keyName2 = UE4.UGameKeyboardLibrary.GetInputChordShowName(key2)
    local cfg2 = Keyboard.Get(keyName2)
    self:SetKeyboardName(cfg2,keyName2, self.ImgKey_1, self.TxtSkillKey1)
    Keyboard:ShowCombinedKeyTxt(key2,self.TxtSkillKey,self.TxtAdd_1)]]

    if self.KeyBtn then
        self.KeyBtn:UpdateKeyShow(self.BackSkillKey)
    end

    if self.Skill03 and self.Skill03.KeyBtn then
        --[[local key3 = UE4.UGameKeyboardLibrary.GetInputChord(self.BackSuperSkillKey)
        local keyName3 = UE4.UGameKeyboardLibrary.GetInputChordShowName(key3)
        local cfg3 = Keyboard.Get(keyName3)
        self:SetKeyboardName(cfg3,keyName3, self.Skill03.ImgKey, self.Skill03.TxtInfoKey1)
        Keyboard:ShowCombinedKeyTxt(key3,self.Skill03.TxtInfoKey,self.Skill03.TxtAdd_1)--]]

        self.Skill03.KeyBtn:UpdateKeyShow(self.BackSuperSkillKey)
    end
    self:UpdateSkillShow();
end

function tbClass:NotifyClick(BtnType)
    local PlayerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
    if PlayerController then PlayerController:RefreshOnBeginTouch() end
    if BtnType ~= UE4.EPlayerBtnType.Normal then return end

    if not self.IsOnlineClient or not self.PanelReviveCion then return end 
    local character = self:GetCacheCharacter();
    if not character then return end 

    local isAlive = character:IsAlive()
    if isAlive then return end

    local player = self:GetOwningPlayer();
    local count = player:GetReviveCount();
    if count <= 0 then 
        UI.ShowMessage('ui.TxtOnlineEvent12');
        return 
    end

    if not character:CanUseReviveCoin() then return end 
    if not isAlive then 
        player:Server_ApplyUseReviveCoin(character)
    end
end

function tbClass:UpdateReviveCount()
    WidgetUtils.Collapsed(self.TxtReviveCionNum)
    -- local character = self:GetCacheCharacter()
    -- if not character then return end 

    -- local player = self:GetOwningPlayer();
    -- local count = player:GetReviveCount();
    -- if count > 0 then 
    --     self.TxtReviveCionNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0.5, 1, 1, 1))
    -- else 
    --     self.TxtReviveCionNum:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0.887923, 0.887923, 0.887923, 1))
    -- end
    -- self.TxtReviveCionNum:SetText(string.format("%d", count))
end


--C++ 通知复活CD转好了
function tbClass:NotifyReviveCdOK()
    self:UpdateUIShow()    
end

-- 更新UI显示
function tbClass:UpdateUIShow()
    self:UpdateStyle(self:GetStyle());
end

-- 得到界面状态
function tbClass:GetStyle()
    local character = self:GetCacheCharacter()
    if not character then return -1 end 

    local player = self:GetOwningPlayer();
    local count = player:GetReviveCount();

    -- 0 - 角色存活
    if character:IsAlive() then return 0 end 

    if count > 0 then 
        -- 1 - 角色死亡，有复活币，并且复活币CD已经好了
        if character:GetUseReviveCoinRemainTime() <= 0 then 
            return 1 
        
        -- 2 - 角色死亡，有复活币，但是复活币CD没有转好
        else 
            return 2
        end
    -- 3 - 角色死亡，没有复活币
    else 
        return 3;
    end
    return 4;
end

-- 更新界面状态
function tbClass:UpdateStyle(style)
    WidgetUtils.Collapsed(self.TxtReviveCD)
    WidgetUtils.Collapsed(self.TxtReviveCD1)
    WidgetUtils.Collapsed(self.PanelIcon)
    WidgetUtils.Collapsed(self.PanelReviveCion)
    -- if not self.IsOnlineClient or not self.PanelReviveCion then return end

    -- if style == 0 or style == 3 then 
    --     WidgetUtils.Collapsed(self.PanelReviveCion)
    -- elseif style == 1 then 
    --     WidgetUtils.Collapsed(self.TxtReviveCD)
    --     WidgetUtils.Collapsed(self.TxtReviveCD1)
    --     WidgetUtils.SelfHitTestInvisible(self.PanelIcon)
    --     WidgetUtils.SelfHitTestInvisible(self.PanelReviveCion)
    -- elseif style == 2 then 
    --     WidgetUtils.Collapsed(self.PanelIcon)
    --     WidgetUtils.SelfHitTestInvisible(self.TxtReviveCD)
    --     WidgetUtils.SelfHitTestInvisible(self.TxtReviveCD1)
    --     WidgetUtils.SelfHitTestInvisible(self.PanelReviveCion)
    --     self.TxtReviveCD:SetText("")
    --     self:NotifyUpdateUseReviveCD(true)
    -- else 
    --     print("UpdateStyle error", style);
    -- end
end

function tbClass:OnChargeTimesChange(InCurrentTimes, InMaxTimes)
    if InMaxTimes <= 1 then return end
    if not self.LastChargeTime then self.LastChargeTime = 8 end
    if InCurrentTimes > self.LastChargeTime then
        local v = self.tbLights[self.LastChargeTime + 1]
        if not v then return end

        WidgetUtils.SelfHitTestInvisible(v)
        self:PlayAnimFromAnimation(self.CdNumber, 0, 1, UE4.EUMGSequencePlayMode.Forward)
    end
    self.LastChargeTime = InCurrentTimes
end 

function tbClass:OnAnimationFinished(InAnim)
    if InAnim == self.CdNumber then
        for i,v in ipairs(self.tbLights) do
            WidgetUtils.Collapsed(v)
        end
    end
end

function tbClass:UpdateSkillShow()
    local UIFight = UI.GetUI("fight")
    if UIFight then
        if UIFight:GetPartShow(UE4.EFightWidgetPart.QTESkill) then
            WidgetUtils.SelfHitTestInvisible(self.PanelSkill)
        else
            WidgetUtils.Collapsed(self.PanelSkill)
        end
        if UIFight:GetPartShow(UE4.EFightWidgetPart.SuperSkill) then
            self.Skill03:SetVisibility(self.SuperSkillType)
        else
            WidgetUtils.Collapsed(self.Skill03)
        end
    end
end

function tbClass:NotifySelfCharacterDie(Character)
    local ch = self:GetCacheCharacter()
    if not ch or ch ~= Character then 
        return 
    end
    self:UpdateReviveCount()
    self:UpdateUIShow()
end

return tbClass
