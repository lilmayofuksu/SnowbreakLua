-- ========================================================
-- @File    : umg_setup.lua
-- @Brief   : 设置
-- ========================================================

---@class tbClass : UUserWidget
---@field ListSystem UListView
---@field Switcher UWidgetSwitcher
local tbClass = Class("UMG.BaseWidget")

local PartWidget = {
    Basis = 0,
    Operation = 1,
    Sensitivity = 2,
    Sound = 3,
    Frame = 4,
    Other = 5,
    KeyStroke = 6,
    Handle = 7,
    User = 8,
    Language = 9,
    Push = 10,
    Gameplay = 11,
}

function tbClass:OnInit()
    --self.Popup:Init('SETTING SYSTEM', function() UI.Close(self) PlayerSetting.JumpTabName = nil end, 1701001)

    BtnAddEvent(self.BtnClose, function()
        UI.Close(self)
    end)

    self.ListFactory = Model.Use(self)

    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    if IsPc then
        self.tbFun = {
            {sName =  'setting.gameplay_setting', pWidget = PartWidget.Gameplay},
            {sName =  'setting.keyboard', pWidget = PartWidget.KeyStroke},
            {sName =  'setting.handle', pWidget = PartWidget.Handle},
            {sName =  'setting.frame_setting', pWidget = PartWidget.Frame}
        }
    else
        self.tbFun = {
            {sName =  'setting.basis_setting', pWidget = PartWidget.Basis},
            {sName =  'setting.operation_setting', pWidget = PartWidget.Operation},
            {sName =  'setting.sensitivity_setting', pWidget = PartWidget.Sensitivity},
            {sName =  'setting.handle', pWidget = PartWidget.Handle},
            {sName =  'setting.frame_setting', pWidget = PartWidget.Frame}
        }
    end


    self.ScrollHandle = function (_, offset)
        local pCurrent = self.Switcher:GetActiveWidget()
        if pCurrent.OuterScrollBox then
            local offsetOfEnd = pCurrent.OuterScrollBox:GetScrollOffsetOfEnd();
            if offsetOfEnd ~= 0 and offsetOfEnd ~= offset then
                WidgetUtils.SelfHitTestInvisible(self.ImgDown)
            else
                WidgetUtils.Collapsed(self.ImgDown)
            end
            return
        end
        
        if pCurrent.ListView then
            if offset and offset > 0.05 then
                WidgetUtils.SelfHitTestInvisible(self.ImgDown)
            else
                WidgetUtils.Collapsed(self.ImgDown)
            end
        end
    end

    table.insert(self.tbFun, {sName =  'setting.sounds_setting', pWidget = PartWidget.Sound})

    if Player.tbSetting and Player.tbSetting['Account'] == 0 then
        table.insert(self.tbFun, {sName =  'setting.protocolTitle', pWidget = PartWidget.User})
    end

    if Map.GetCurrentID() == 2 then --Localization.IsShowLanguageSelect()
        table.insert(self.tbFun, {sName =  'setting.language', pWidget = PartWidget.Language})
    end

    if LocalNotification.IsEnable() then
        table.insert(self.tbFun, {sName = "setting.msg_push", pWidget = PartWidget.Push})
    end
    
    table.insert(self.tbFun, {sName =  'setting.other_setting', pWidget = PartWidget.Other})
end

function tbClass:OnOpen()
    if UI.bPoping then
        return
    end

    self:DoClearListItems(self.ListSystem)
    self.ListSystem:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    
    for _, tbItem in ipairs(self.tbFun) do
        local sName = Text(string.format('%s', tbItem.sName))
        local sNameEn = Text(string.format('%s', tbItem.sName..'_en'))
        local tbParam = { tbData = tbItem, bSelect = false , fClick = function(pObj)
            self.TxtTitle:SetText(sName)
            self.TxtTitleEn:SetText(sNameEn)
            self:OnSwitch(pObj) 
        end}
        local pObj = self.ListFactory:Create(tbParam)
        if PlayerSetting.JumpTabName then
            if PlayerSetting.JumpTabName == tbItem.sName then
                self.pObj = pObj
                tbParam.bSelect = true
                self.TxtTitle:SetText(sName)
                self.TxtTitleEn:SetText(sNameEn)
            end
        else
            if self.pObj == nil then
                self.pObj = pObj
                tbParam.bSelect = true
                self.TxtTitle:SetText(sName)
                self.TxtTitleEn:SetText(sNameEn)
            end
        end
        self.ListSystem:AddItem(pObj)
    end

    if self.pObj then
        self:Active(self.pObj)
    end
    PlayerSetting.JumpTabName = nil
end

function tbClass:OnClose()
    PlayerSetting.Save()
     if self.keyTimer then
        UE4.Timer.Cancel(self.keyTimer)
    end
end

function tbClass:OnSwitch(pObj)
    if self.pObj ~= pObj then
        if self.pObj then
            self.pObj.pUI:OnSelectChange(false)
        end
        self.pObj = pObj
        if self.pObj then
            self.pObj.pUI:OnSelectChange(true)
            self:Active(self.pObj)
        end
    end
end

function tbClass:Active(pObj)
    local pWidget = pObj.Data.tbData.pWidget
    if pWidget then
        local pCurrent = self.Switcher:GetActiveWidget()
        if pCurrent and pCurrent.OnDisable then
            pCurrent:OnDisable()
        end

        
        self.Switcher:SetActiveWidgetIndex(pWidget)
        self.CurrentIndex = pWidget
        pCurrent = self.Switcher:GetActiveWidget()
        -- 操作界面不显示重置按钮
        if self.CurrentIndex == PartWidget.Operation then
            WidgetUtils.Collapsed(self.BtnReset)
        else
            WidgetUtils.Visible(self.BtnReset)
        end

        if pCurrent.OnActive then
            pCurrent:OnActive();
        end

        UE4.Timer.Add(0.1,function ()
            self:UpdateScrollEvent()
        end)

        
    end
end

function tbClass:TryRefreshFrame()
    if self.CurrentIndex == PartWidget.Frame then
        local pCurrent = self.Switcher:GetActiveWidget()
        pCurrent:Update()
    end
end

function tbClass:UpdateScrollEvent()
    local pCurrent = self.Switcher:GetActiveWidget()
    WidgetUtils.Collapsed(self.ImgDown)

    if pCurrent.OuterScrollBox then
        if  pCurrent.OuterScrollBox:GetScrollOffset() ~= pCurrent.OuterScrollBox:GetScrollOffsetOfEnd() then
            WidgetUtils.SelfHitTestInvisible(self.ImgDown)
            pCurrent.OuterScrollBox.OnUserScrolled:Remove(self, self.ScrollHandle)
            pCurrent.OuterScrollBox.OnUserScrolled:Add(
                self,
                self.ScrollHandle
            )
        end
        return
    end

    if pCurrent.ListView then
        WidgetUtils.SelfHitTestInvisible(self.ImgDown)
        pCurrent.ListView.OnCustListViewScrolled:Remove(self, self.ScrollHandle)
        pCurrent.ListView.OnCustListViewScrolled:Add(
            self,
            self.ScrollHandle
        )
    end

    
end

function tbClass:ShowKeyTip(bShow, sTip,needTimer)
    if bShow then
        if self.keyTimer then
            UE4.Timer.Cancel(self.keyTimer)
        end
        if needTimer then
            self.keyTimer = UE4.Timer.Add(5, function()
                if self then
                    self:ShowKeyTip(false)
                end
            end)
        end
        WidgetUtils.HitTestInvisible(self.PanelWarn)
        if sTip then
            WidgetUtils.HitTestInvisible(self.TxtDetail)
            self.TxtDetail:SetText(sTip)
            WidgetUtils.Collapsed(self.TxtChoose)
        else
            WidgetUtils.Collapsed(self.TxtDetail)

            local nInputType =  UE4.UGameInputKeySelector.GetInputType()
            if nInputType == UE4.EKeyboardInputType.Keyboard then
                self.TxtChoose:SetText('ui.TxtKeyWarn2')
            else
                self.TxtChoose:SetText('ui.TxtKeyWarn4')
            end

            WidgetUtils.HitTestInvisible(self.TxtChoose)
        end
    else
        WidgetUtils.Collapsed(self.PanelWarn)
    end
end

return tbClass