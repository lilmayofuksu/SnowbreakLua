-- ========================================================
-- @File    : uw_setup_user.lua
-- @Brief   : 设置
-- ========================================================

local tbClass = Class("UMG.SubWidget")
local SID = PlayerSetting.SSID_OTHER

local ContentType = {
    PopUp        = 51,
    Account   = 52
}

function tbClass:Construct()
    self.Padding = UE4.FMargin()
    self.Padding.Left = 30
    self.Padding.Top = 0
    self.Padding.Right = 0
    self.Padding.Bottom = 0

    self.tbWidgets = {}

    BtnAddEvent(self.BtnReset, function()
        self:OnReset()
    end)

    self.tbContents = {
        self.NoticeSet,
        self.OverseasSet,
        self.Content1,
        self.Content2
    }

    self.NoticeSet:Set({sName = "ui.TxtOperationSet.PopUp"})

    self.OverseasSet:Set({sName = "ui.TxtOperationSet.Account"})

    local pFunc = function (tbCfg)
        if tbCfg.bExternal then
            if tbCfg.nType == OtherType.LOGOUT and Login.IsOversea() then
                Login.bReturnEntry = true
                UE4.UGameLibrary.OpenUserCenter()
                return
            end

            if tbCfg.nType == OtherType.LOGOUT and string.find(UE4.UGameLibrary.GetChannelId(), "bili") then
                local sInfo = json.encode({{role_name = me:Nick(), server_name = "-", level = tostring(me:Level()) or "", time = os.date('%Y-%m-%d', me:CreateTime()) }})
                UE4.UGameLibrary.LogOut(sInfo)
                return
            end

            UE4.UKismetSystemLibrary.LaunchURL(Text(tbCfg.sUrl))
            return
        end
        UI.Open("Agreement", tbCfg)
    end

    local pBindFunc = function (tbParam)
        if self == nil then return end        
        local sSeasunPName = self.sSeasunPlatform or "mail"
        print("pBindFunc: " .. tostring(tbParam.sPlatform or ""))  
        if tbParam.sPlatform ~= sSeasunPName and not self:IsBindedPlatform(sSeasunPName) then
            UI.ShowMessage("ui.TxtOperationSet.Account_Desc")
            return
        end

        if self:IsBindedPlatform(tbParam.sPlatform) then 
            UI.ShowMessage("ui.TxtOperationSet.AccountTip1")            
            return
        end

        self:BindPlatform(tbParam.sPlatform)            
    end

    self.tbFunction = {
        [OtherType.GAMEPLAYAAGREE] = pFunc,
        [OtherType.PRIVACY] = pFunc,
        [OtherType.SDKLIST] = pFunc,
        [OtherType.LOGOUT] = pFunc,

        [OtherType.SEASUN] = pBindFunc,
        [OtherType.TWITTER] = pBindFunc,
        [OtherType.APPLE] = pBindFunc,
        [OtherType.FACEBOOK] = pBindFunc,
        [OtherType.GOOGLE] = pBindFunc
    }

    -- --------------------account bind ---------------------
    self.bIsOversea = Login.IsOversea() or false  
    -- print("self.bIsOversea is " .. tostring(self.bIsOversea))    
    -- BtnAddEvent(self.BtnPrompt, function ()
    --     if WidgetUtils.IsVisible(self.PanelDetail) then
    --         WidgetUtils.Collapsed(self.PanelDetail)
    --     else
    --         WidgetUtils.Visible(self.PanelDetail)
    --     end
    -- end)   
    if not self.bIsOversea then     
        self.tbBindCfg = {}
        self.tbSdkAccount = {}
    else 
        UE4.UGameLibrary.GetSdkAccountInfo()                
        self.nHandleSdkGetAccount = EventSystem.On(Event.OnGetSdkAccountInfo, function(retJson)
            print("SDK AccountInfo:", retJson)
            if self == nil then return end
            self.tbSdkAccount = {}
            local tbRet = json.decode(retJson) or {}
            local tbRetAccount = tbRet.bindAccountTypes or {}
            for _, _v in pairs(tbRetAccount) do 
                self.tbSdkAccount[_v or "none"] = true
            end
        end)
        self.nHandleBindAccountSuccess = EventSystem.On(Event.SdkBindAccountSuccess, function()
            print("SDK Bind Account Success.")
            if self then self:BindNotify(true) end
            UE4.UGameLibrary.GetSdkAccountInfo()
        end)
        self.nHandleBindAccountFail = EventSystem.On(Event.SdkBindAccountFail, function(ret)
            print("SDK Bind Account Fail.", ret)
            if self then self:BindNotify(false) end
            UI.ShowMessage(tostring(ret))
        end)
    end
end

function tbClass:GetWidget(tbCfg)
    local pWidget = self.tbWidgets[tbCfg.Type]
    if tbCfg then
        if not pWidget then
            pWidget = LoadWidget(PlayerSetting.tbClassType[tbCfg.ClassType])
            if pWidget then
                local nValue = PlayerSetting.GetOne(SID, tbCfg.Type) or 0
                self.tbWidgets[tbCfg.Type] = pWidget
            end
        end
    end
    return pWidget
end

function tbClass:AddToPopUp(Widget)
    WidgetUtils.SelfHitTestInvisible(self.NoticeSet)
    WidgetUtils.SelfHitTestInvisible(self.Content1)
    self.Content1:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:AddToAccount(Widget)
    WidgetUtils.SelfHitTestInvisible(self.OverseasSet)
    WidgetUtils.SelfHitTestInvisible(self.Content2)
    self.Content2:AddChildToWrapBox(Widget)
    self:Align(Widget)
end

function tbClass:Align(Widget)
    local slot = UE4.UWidgetLayoutLibrary.SlotAsWrapBoxSlot(Widget)
    slot:SetPadding(self.Padding)
    slot:SetFillEmptySpace(true)
end

function tbClass:SwitchContent(tbCfg, isPc)
    if not PlayerSetting.IsPageContent(tbCfg, isPc, ContentType) then return end

    if isPc and tbCfg.Type == OtherType.LOGOUT and string.find(UE4.UGameLibrary.GetChannelId(), "bili") then
        return
    end

    local widget = self:GetWidget(tbCfg)
    
    if Contains(tbCfg.Category, ContentType.PopUp) then
        self:AddToPopUp(widget)
    end

    if Contains(tbCfg.Category, ContentType.Account) then
        self:AddToAccount(widget)
    end

    PlayerSetting.InitWidget(SID, widget, tbCfg, self.tbFunction, self.tbWidgets)

    if tbCfg.Oversea == 1 then 
        if not self.bIsOversea then 
            WidgetUtils.Collapsed(widget)
        elseif not IsIOS() and tbCfg.Type == OtherType.APPLE then
            WidgetUtils.Collapsed(widget)
        end
        if tbCfg.Type == OtherType.SEASUN then
            self.sSeasunPlatform = tbCfg.Items[3] or "mail"
        end
    end
end

function tbClass:OnReset()
    PlayerSetting.ResetBySID(SID)
    self:OnActive()
    for _, nType in pairs(OtherType) do
        local value = PlayerSetting.Get(SID, nType)
        SettingEvent.Trigger(SID, nType, value)
    end
end

function tbClass:OnDestruct()
    if self.bIsOversea then 
        EventSystem.Remove(self.nHandleSdkGetAccount)
        EventSystem.Remove(self.nHandleBindAccountSuccess)
        EventSystem.Remove(self.nHandleBindAccountFail)
    end
end

function tbClass:OnActive()
    WidgetUtils.CollapsedWidgets(self.tbContents)
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    for _,v in ipairs(PlayerSetting.tbOtherSort) do
        self:SwitchContent(v, IsPc)
    end
    PlayerSetting.CheckConnect(SID, self.tbWidgets)
end

-- function tbClass:OnReset()
--     PlayerSetting.ResetBySID(SID)
--     self:OnActive()
-- end

function tbClass:IsBindedPlatform(sPlatform)    
    if self.bIsOversea and self.tbSdkAccount then 
        if self.tbSdkAccount[sPlatform] then 
            return true
        else
            local tbGoogle = {["google"] = "googleplay", ["googleplay"] = "google"}
            if tbGoogle[sPlatform] and self.tbSdkAccount[tbGoogle[sPlatform]] then 
                return true            
            end
        end
    end
    return false
end

function tbClass:BindPlatform(sPlatform)
    print("begin bind: " .. (sPlatform or "no platform"))
    UE4.UGameLibrary.BindAccount(sPlatform)
end

function tbClass:BindNotify(bSuccess)
    if bSuccess then
        UI.ShowMessage("ui.TxtOperationSet.AccountTip2")
    else 
        --UI.ShowMessage("ui.TxtOperationSet.AccountTip3")
    end
end

return tbClass