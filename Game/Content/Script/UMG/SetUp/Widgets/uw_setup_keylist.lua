-- ========================================================
-- @File    : uw_setup_keylist.lua
-- @Brief   : 按键设置条目
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(InObj)
    self.Data = InObj.Data
    self.nInputType = self.Data.nInputType
    self.sBindKey = InObj.Data.sKey
    self.InputKeySelector:SetTextBlockVisibility(UE4.ESlateVisibility.Collapsed)
    ---@type FInputChord
    local pKeyPre = UE4.UGameKeyboardLibrary.GetInputChordByType(self.sBindKey, self.nInputType)

    self.InputKeySelector.OnKeySelected:Clear()
    --if not string.find(self.sBindKey,'BackSuperSkill') then
        self.InputKeySelector:SetSelectedKey(pKeyPre)
    --end

    if self.Data.KeyboardItem and (self.Data.KeyboardItem.bAllowCombinedKey) then
        self.TxtBtnNmae:SetText('*'..Text('ui.' .. self.sBindKey))
    else
        self.TxtBtnNmae:SetText(Text('ui.' .. self.sBindKey))
    end

    local bGamepad =  self.nInputType ~= UE4.EKeyboardInputType.Keyboard

    self.InputKeySelector:SetAllowGamepadKeys(bGamepad)
    self.InputKeySelector:SetAllowModifierKeys(not bGamepad)

    local SetKeyFunc = function (_, pKey)
        self:SetUIClickEnable(true)
        local isSupport = UE4.UGameKeyboardLibrary.CheckInSupportKeyList(pKey)
        if not isSupport then
            local pUI = UI.GetUI('SetUp')
            if pUI then
                pUI:ShowKeyTip(true,Text("ui.TxtKeyWarn3") or "禁止设置此按键",true)
            end
            return
        end

        if UE4.UGameKeyboardLibrary.CheckIsCombinedKey(pKey) and not UE4.UGameKeyboardLibrary.CheckItemAllowCombinedKey(self.sBindKey) then
            local pUI = UI.GetUI('SetUp')
            if pUI then
                pUI:ShowKeyTip(true,Text("ui.TxtKeyWarn5") or "此按键不能设为组合键",true)
            end
            return
        end

        local bGamepad = (self.nInputType ~= UE4.EKeyboardInputType.Keyboard)

        local sConflictKey, sKeyName = UE4.UGameKeyboardLibrary.GetConflictKey(self.sBindKey, pKey)
        local bsConflict = sConflictKey ~= ''
        UE4.UGameKeyboardLibrary.SaveInputChord(self.sBindKey, pKey, self.nInputType)
        
        if bsConflict then
            local pUI = UI.GetUI('SetUp')
            if pUI then
                local pItem = UE4.UGameKeyboardLibrary.GetKeyboardItem(sConflictKey)
                InObj.Data.parent.tbAllConflictKeys[sConflictKey] = true;
                pUI:ShowKeyTip(true, Text('ui.TxtKeyWarn1', Keyboard.GetKeyName(sKeyName), Text('ui.' .. pItem.I18n)))
            end
        else
            if UE4.UGameKeyboardLibrary.GetInputChordShowName(pKey) == 'None' then
                local pUI = UI.GetUI('SetUp')
                if pUI then
                    pUI:ShowKeyTip(true, Text('ui.TxtKeyWarn1', Keyboard.GetKeyName(UE4.UGameKeyboardLibrary.GetInputChordShowName(pKeyPre)), Text('ui.' .. self.sBindKey)))
                end
            end
        end

        if not self.Data.parent or not self.Data.pListView then
            return
        end

        if bsConflict then
            self.Data.pListView:RegenerateAllEntries()
        else
            self:SetKeyName()
        end

        if bGamepad then
            self.Data.parent:NotifyUpdate()
        end
    end

    --if not string.find(self.sBindKey,'BackSuperSkill') then
        self.InputKeySelector.OnKeySelected:Add(self, SetKeyFunc)
    --end

    self.InputKeySelector.OnIsSelectingKeyChanged:Clear()
    --if not string.find(self.sBindKey,'BackSuperSkill') then
        self.InputKeySelector.OnIsSelectingKeyChanged:Add(self, function(_)
            --[[local nowSl = InObj.Data.getSl()
            print("触发key:::OnIsSelectingKeyChanged--",nowSl)
            if nowSl then-- and nowSl ~= self.ImgFrameSl 
                return
            end--]] 

            local bSelect = self.InputKeySelector:GetIsSelectingKey()


            self:OnSelectChange(bSelect)
            local pUI = UI.GetUI('SetUp')
            if pUI then
                pUI:ShowKeyTip(bSelect)
            end
            if bSelect then
                self:ShowImgWarn(false)
                --self:SetUIClickEnable(false)
                InObj.Data.parent.tbAllConflictKeys[self.sBindKey] = nil;

                --[[self.SetHandle = EventSystem.On("MouseButtonUpWithKey",function (Chord)
                    print("触发key:::",Chord)
                    SetKeyFunc(0,Chord)
                    EventSystem.Remove(self.SetHandle)
                self.SetHandle = nil
                end)--]]
            end
            if InObj.Data.onClick and bSelect then
                Audio.PlaySounds(3005)
                InObj.Data.onClick(self.ImgFrameSl);
            elseif InObj.Data.onUnSl and not bSelect then
                InObj.Data.onUnSl(self.ImgFrameSl);
            end
        end)
    --end

    self:OnSelectChange(false,true)


    if InObj.Data.parent and InObj.Data.parent.tbAllConflictKeys[self.sBindKey] then
        self:ShowImgWarn(true)
    else
        self:ShowImgWarn(false)
    end

    WidgetUtils.SelfHitTestInvisible(self.PanelImg)
    WidgetUtils.Collapsed(self.TxtAdd)
    WidgetUtils.Collapsed(self.ImgMouse1)
end

function tbClass:SetKeyName()
    --local nowValid = UE4.UGameKeyboardLibrary.CheckInputValid(self.InputKeySelector.SelectedKey)
    --不支持的键位不会显示，但是有些键位是空值，也有FInputChord(默认结构，非valid但非空,keyName为None)，此时也需要更
    if self.InputKeySelector and self.InputKeySelector.SelectedKey and (not UE4.UGameKeyboardLibrary.CheckInSupportKeyList(self.InputKeySelector.SelectedKey)) then
        WidgetUtils.Collapsed(self.ImgMouse)
        WidgetUtils.HitTestInvisible(self.TxtKey)
        WidgetUtils.Collapsed(self.OverLay1)
        WidgetUtils.Collapsed(self.OverLay)
        WidgetUtils.Collapsed(self.TxtAddKey)
        self.TxtKey1:SetText('')
        self.TxtKey:SetText('')
        --[[if string.find(self.sBindKey,'BackSuperSkill') then
            self.TxtKey1:SetText(Text('ui.TxtBackSuperSkill'))
        end]]
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.OverLay)
    WidgetUtils.Collapsed(self.TxtAddKey)
    WidgetUtils.Collapsed(self.OverLay1)

    local sKeyShowName = self:GetKeyName()
    self.sCacheKeyShowName = sKeyShowName
    local cfg = Keyboard.Get(sKeyShowName)

    if cfg then
        if cfg.nIcon > 0 then
            WidgetUtils.SelfHitTestInvisible(self.ImgMouse)
            SetTexture(self.ImgMouse, cfg.nIcon)
            WidgetUtils.Collapsed(self.TxtKey)
            WidgetUtils.Collapsed(self.ImgInPut)
        else
            WidgetUtils.Collapsed(self.ImgMouse)
            WidgetUtils.HitTestInvisible(self.TxtKey)
            self.TxtKey:SetText(Text(cfg.sName))
            if sKeyShowName ~= 'None' then
                WidgetUtils.SelfHitTestInvisible(self.ImgInPut)
            else
                WidgetUtils.Collapsed(self.ImgInPut)
            end
        end
    else
        WidgetUtils.Collapsed(self.ImgInPut)
        WidgetUtils.Collapsed(self.ImgMouse)
        WidgetUtils.HitTestInvisible(self.TxtKey)
        self.TxtKey:SetText('')
    end

    local SelectedChord = self.InputKeySelector.SelectedKey
    if SelectedChord and (SelectedChord.bShift or SelectedChord.bAlt or SelectedChord.bCtrl) then
        WidgetUtils.SelfHitTestInvisible(self.TxtAddKey)
        WidgetUtils.SelfHitTestInvisible(self.OverLay1)

        local cfg = nil;
        if SelectedChord.bShift then
            cfg = Keyboard.Get('Shift')
        end
        if SelectedChord.bAlt then
            cfg = Keyboard.Get('Alt')
        end
        if SelectedChord.bCtrl then
            cfg = Keyboard.Get('Control')
        end
        if cfg then
           self.TxtKey1:SetText(Text(cfg.sName))
           if sKeyShowName ~= 'None' then
                WidgetUtils.SelfHitTestInvisible(self.ImgInPut1)
            else
                WidgetUtils.Collapsed(self.ImgInPut1)
            end
        end
    end
end

--updateUI:是否更新键位名字显示
function tbClass:OnSelectChange(bSelect,updateUI)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.ImgBgSl)
    else
        WidgetUtils.Collapsed(self.ImgBgSl)
    end
    if updateUI then
        self:SetKeyName()
    end

    if bSelect then
        self:SetUIClickEnable(false)
    else
        self:SetUIClickEnable(true)
    end
end

function tbClass:ShowImgWarn(bShow)
    if bShow then
        WidgetUtils.SelfHitTestInvisible(self.ImgWarn)
    else
        WidgetUtils.Collapsed(self.ImgWarn)
    end
end

function tbClass:SetUIClickEnable( bShow )
    --RuntimeState.ChangeInputMode(bShow)

    local SetUpUI = UI.GetUI('SetUp')
    if SetUpUI then
        if not bShow then
            WidgetUtils.HitTestInvisible(SetUpUI)
        else
            WidgetUtils.SelfHitTestInvisible(SetUpUI)
        end
    end
end

return tbClass