-- ========================================================
-- @File    : uw_setup_handle_keylist.lua
-- @Brief   : 手柄按键设置条目
-- ========================================================
local tbClass = Class("UMG.SubWidget")


function tbClass:Construct()
    WidgetUtils.Collapsed(self.ImgWarn)
end

function tbClass:OnListItemObjectSet(InObj)
    self.Data = InObj.Data
    self.ParentUI = InObj.Data.ParentUI

    if not self.Data then return end
    local sBindKey = self.Data.sKey
    local nInputType = self.Data.nInputType

    self.sBindKey = sBindKey
    self.nInputType = nInputType

    self.sCombineAction = Gamepad.GetCombineAction(sBindKey, nInputType)

    local pDef = UE4.UGamepadLibrary.GetGamepadShowItem(sBindKey)
    if pDef and pDef.bAllowRepeat then
        self.TxtBtnNmae:SetText('*' .. Text('ui.' .. sBindKey))
    else
        self.TxtBtnNmae:SetText(Text('ui.' .. sBindKey))
    end

    self.sCacheSetKeyName = nil

    if self.Data.bTemplate then
        WidgetUtils.HitTestInvisible(self.InputKeySelector)
        self.Content:SetRenderOpacity(0.4)
    else
        WidgetUtils.Visible(self.InputKeySelector)
        self.Content:SetRenderOpacity(1)
    end


    EventSystem.Remove(self.nConflictHandle)
    self.nConflictHandle = EventSystem.OnTarget(self.Data, 'ON_CONFLICT', function(_, sReplaceKey)
        self:BindEvent(false)
        if sReplaceKey then
            local replace = UE4.UGamepadLibrary.CreateInputChord(sReplaceKey)
            self.InputKeySelector:SetSelectedKey(replace) 
        end
        self:BindEvent(true)

        self:UpdateKeyInfo()
    end)

    self:BindEvent(false)

    self.InputKeySelector:SetTextBlockVisibility(UE4.ESlateVisibility.Collapsed)

    ---获取设置的按键
    local sSave = Gamepad.GetSetting(sBindKey, nInputType)
    local pNewKey = UE4.UGamepadLibrary.CreateInputChord(sSave)

    self.InputKeySelector:SetSelectedKey(pNewKey)

    self:UpdateKeyInfo()

    self.InputKeySelector:SetAllowGamepadKeys(true)
    self.InputKeySelector:SetAllowModifierKeys(true)

   
    self:OnSelectChange(false)
    self:BindEvent(true)
end

function tbClass:BindEvent(bBind)
    if self.Data.bTemplate then 
        self.InputKeySelector.OnKeySelected:Clear()
        self.InputKeySelector.OnIsSelectingKeyChanged:Clear()
        return
    end

    if bBind then
        self.InputKeySelector.OnKeySelected:Clear()
        self.InputKeySelector.OnKeySelected:Add(self, function()  self:OnKeySelected() end)

        self.InputKeySelector.OnIsSelectingKeyChanged:Clear()
        self.InputKeySelector.OnIsSelectingKeyChanged:Add(self, function(_) self:OnIsSelectingKeyChanged() end)
    else
        self.InputKeySelector.OnKeySelected:Clear()
        self.InputKeySelector.OnIsSelectingKeyChanged:Clear()
    end
end


function tbClass:OnKeySelected()
    local sBindKey = self.sBindKey
    local nInputType = self.nInputType

    local selectKey = self.InputKeySelector.SelectedKey

    if UE4.UGamepadLibrary.IsAxis(selectKey.Key) then
        print('OnKeySelected : Axis', self:GetKeyName())
       return
    end

    local selectKeyName = self:GetKeyName()

    print('select key=======================>:', selectKeyName)
    local isSupport = UE4.UGamepadLibrary.CheckKeyIsSupport(selectKey.Key)
    if not isSupport then
        print('select key is not support :', selectKeyName)
        self.ParentUI:ShowTip(true, Text("ui.TxtKeyWarn3"))
        return
    end

    local sAction = Gamepad.GetActionNameByI18n(sBindKey)
    ---特殊检查
    if sAction == 'GamepadLB' or sAction == 'GamepadRB' then
        local bPass = Gamepad.CheckCombineConflict(sAction, nInputType, selectKeyName)
        if bPass then
            print('select key :', selectKeyName)
            return
        end
    end

    if self.sCacheSetKeyName == nil then return end

    local sConflictKey, sKeyName = UE4.UGamepadLibrary.GetGampadConflictKey(sBindKey, nInputType, selectKey)
    local bIsConflict = false

    if sConflictKey ~= '' then
        bIsConflict = true
    end
    ---键位冲突
    if bIsConflict then
        print('select key conflict :', sBindKey, selectKeyName, sConflictKey or 'nil', sKeyName or 'nil')
        local nOldKey = UE4.UGamepadLibrary.CreateInputChord(self.sCacheSetKeyName)
        UE4.UGamepadLibrary.SaveGamepadInputChord(sConflictKey, nOldKey, nInputType) 
        self.ParentUI:ShowConflictTip(sConflictKey, sKeyName, self.sCacheSetKeyName)
    end

    UE4.UGamepadLibrary.SaveGamepadInputChord(sBindKey, selectKey, nInputType) 
    self.ParentUI:UpdateBindKey()
    self:UpdateKeyInfo()
end

function tbClass:OnIsSelectingKeyChanged()
    self.sCacheSetKeyName = Gamepad.GetSetting(self.sBindKey, self.nInputType)

    local bSelect = self.InputKeySelector:GetIsSelectingKey()
    UE4.UVirtualCursorFunctionLibrary.SetIsSelectingKey(bSelect)
    self:OnSelectChange(bSelect)
    self.bConflict = false
    if bSelect then
        Audio.PlaySounds(3005)
    end

    self.ParentUI:ShowTip(false)
end


function tbClass:UpdateKeyInfo()
    WidgetUtils.Visible(self.InputKeySelector)
    local selectKeyName = self:GetKeyName()

    ---组合显示
    if self.sCombineAction then
        WidgetUtils.Collapsed(self.PanelKeyContent)
        WidgetUtils.HitTestInvisible(self.PanelComContent)

        local sDisplayName = Gamepad.GetDisplayNameByAction(self.sCombineAction)
        self.TxtBtnNmae1:SetText(Text('ui.' .. sDisplayName))

        local cfg = Keyboard.Get(selectKeyName)
        if cfg then
            SetTexture(self.ImgMouseCom, cfg.nIcon)
        end
    else
        WidgetUtils.HitTestInvisible(self.PanelKeyContent)
        WidgetUtils.Collapsed(self.PanelComContent)

        local cfg = Keyboard.Get(selectKeyName)
        if not cfg then return end
        WidgetUtils.HitTestInvisible(self.ImgMouse)
        SetTexture(self.ImgMouse, cfg.nIcon)
    end  
end

function tbClass:OnSelectChange(bSelect)
    local pSelectImg = self.sCombineAction and self.ImgComSelect or self.ImgKeySelect
    if bSelect then
        WidgetUtils.HitTestInvisible(pSelectImg)
    else
        WidgetUtils.Collapsed(pSelectImg)
    end
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nConflictHandle)
end

return tbClass