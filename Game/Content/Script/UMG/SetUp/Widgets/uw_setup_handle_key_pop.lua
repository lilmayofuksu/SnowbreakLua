-- ========================================================
-- @File    : uw_setup_handle_key_pop.lua
-- @Brief   : 手柄键位设置界面
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function () UI.Close(self) end)
    BtnAddEvent(self.BtnReset, function()
        Gamepad.CustomReset()
        self:ShowCustomKey()
    end)

    BtnAddEvent(self.BtnPrint, function()
        for _, sKey in ipairs(self.tbCommonData.tbKeys or {}) do
            local sSave = Gamepad.GetSetting(sKey, self.nInputType)
            print('set key :', Gamepad.GetActionNameByI18n(sKey), sSave)
        end
    end)

    WidgetUtils.SelfHitTestInvisible(self.ImgDown)
    self.ListView.OnCustListViewScrolled:Add(self, function(_, offset)
        if offset and offset > 0.05 then
            WidgetUtils.SelfHitTestInvisible(self.ImgDown)
        else
            WidgetUtils.Collapsed(self.ImgDown)
        end
    end)
end

function tbClass:OnOpen()
    local tbOption = {}
    ---自定义
    table.insert(tbOption, 'controler_model_custom')

    ---默认设置
    for i = 1, Gamepad.nHandDefaultCount do
        table.insert(tbOption, 'controler_model' .. i)
    end
    local nSaveIdx = Gamepad.GetSaveHandType() or 0

    self.HandleChoose:Set({ tbData = {0, 'handle_keyboard', tbOption}, nCheckIndex = nSaveIdx, fOnChange = function(nIndex)
        self:ShowPanel(nIndex + 1)

    end, bMulti = false, tip = ''})

    self:GatherCommonData()

    self:UpdateByType(Gamepad.GetActiveInputType())
end

function tbClass:UpdateByType(nType)
    if not nType then return end

    UE4.UVirtualCursorFunctionLibrary.SetIsSelectingKey(false)
    self.nInputType = nType

    local nSaveIdx = Gamepad.GetSaveHandType() or 0

    print('hand save idx :', self.nInputType, nSaveIdx)

    self:ShowPanel(nSaveIdx + 1)

    self:ShowTip(false)
end

function tbClass:GatherCommonData()
    self.tbCommonData = {tbKeys = {}, }

    local Keys = UE4.UGamepadLibrary.GetGamepadCfgRows(nil, false)
    for i = 1, Keys:Length() do
        local sKey = Keys:Get(i)
        table.insert(self.tbCommonData.tbKeys, sKey)
    end
end

function tbClass:GetInfo()
    return self.nInputType, self.nShowIdx
end


function tbClass:ShowPanel(nIdx)
    WidgetUtils.Collapsed(self.BtnReset)
    WidgetUtils.Collapsed(self.BtnPrint)

    self.nShowIdx = nIdx

    Gamepad.SaveHandData(self.nShowIdx - 1)

    print('show panel ', nIdx)
    if nIdx == 1 then
        self:ShowCustomKey()
        self.TxtTips:SetText(Text('setting.controler_model_custom_Desc'))
    else
        self.TxtTips:SetText(Text(string.format('setting.controler_model%s_Desc', nIdx - 1)))
        self:ShowDefaultKey()
    end
end

---显示默认配置
function tbClass:ShowDefaultKey()
    self:UpdateBindKey()
    

    WidgetUtils.HitTestInvisible(self.ImgDown)
    WidgetUtils.Visible(self.ListView)
    self.Factory = self.Factory or Model.Use(self)

    local nType = self.nInputType

    UE4.UGameInputKeySelector.SetInputType(nType)
  
    self:DoClearListItems(self.ListView)

    self.ListView:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)

    self.tbCacheBindKey2Data = {}
    
    for _, sKey in ipairs(self.tbCommonData.tbKeys or {}) do
        local tbParam = {sKey = sKey, nInputType = nType, ParentUI = self, bConflict = false, bTemplate = true}
        local pObj = self.Factory:Create(tbParam)
        self.ListView:AddItem(pObj)
    end
    self:UpdateBindKey()

    WidgetUtils.Collapsed(self.BtnReset)
    WidgetUtils.Collapsed(self.BtnPrint)
end

---显示自定义按键
function tbClass:ShowCustomKey()
    WidgetUtils.HitTestInvisible(self.ImgDown)
    WidgetUtils.Visible(self.ListView)
    self.Factory = self.Factory or Model.Use(self)

    local nType = self.nInputType

    UE4.UGameInputKeySelector.SetInputType(nType)
    self:DoClearListItems(self.ListView)

    self.ListView:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)

    self.tbCacheBindKey2Data = {}
    
    for _, sKey in ipairs(self.tbCommonData.tbKeys or {}) do
        local tbParam = {sKey = sKey, nInputType = nType, ParentUI = self, bConflict = false}
        local pObj = self.Factory:Create(tbParam)
        self.ListView:AddItem(pObj)
        self.tbCacheBindKey2Data[sKey] = tbParam
    end
    self:UpdateBindKey()

    if UE4.UGMLibrary.IsEditor() then
        WidgetUtils.Visible(self.BtnReset)
        WidgetUtils.Visible(self.BtnPrint)
    end
end

function tbClass:ShowConflictTip(sConflictKey, sKeyName, sReplaceKey)
    self:ShowTip(true, Text('ui.TxtHandleWarn', Text('ui.' .. sConflictKey)))

    local pConflictData = self.tbCacheBindKey2Data[sConflictKey]
    if pConflictData then
        pConflictData.bConflict = true
        EventSystem.TriggerTarget(pConflictData, 'ON_CONFLICT', sReplaceKey)
    end
end

function tbClass:ShowTip(bShow, sTip)
    WidgetUtils.Collapsed(self.TxtChoose)
    WidgetUtils.Collapsed(self.TxtHandleKeyTips)
    if bShow then
        print('show tip :', sTip)
        WidgetUtils.HitTestInvisible(self.PanelWarn)
        WidgetUtils.HitTestInvisible(self.TxtHandleWarn)
        self.TxtHandleWarn:SetText(sTip)
    else
        WidgetUtils.Hidden(self.PanelWarn)
    end
end

function tbClass:UpdateBindKey()
    local nIdx = self.nShowIdx - 1
    local nType = self.nInputType

    Gamepad.UpdateCacheKey(nType, nIdx)

    if nType == UE4.EKeyboardInputType.PS4 then
        WidgetUtils.Collapsed(self.XboxHandle)
        WidgetUtils.HitTestInvisible(self.PsHandle)
        self.PsHandle:DisplayKey(nType, nIdx)
    elseif nType == UE4.EKeyboardInputType.XBox360 then
        WidgetUtils.HitTestInvisible(self.XboxHandle)
        WidgetUtils.Collapsed(self.PsHandle)
        self.XboxHandle:DisplayKey(nType, nIdx)
    end
end


function tbClass:OnClose()
    ---应用按键设置
   Gamepad.SaveHandData(self.nShowIdx - 1)
   PlayerSetting.SaveKeyboardBind()
   UE4.UGamepadLibrary.UseGamepadSetting()
   UE4.UVirtualCursorFunctionLibrary.SetIsSelectingKey(false)
end

return tbClass