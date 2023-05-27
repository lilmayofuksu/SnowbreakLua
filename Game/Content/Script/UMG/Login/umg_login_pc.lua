-- ========================================================
-- @File    : umg_login_pc.lua
-- @Brief   : 登录界面
-- ========================================================
---@class tbClass
---@field Content UCanvasPanel
---@field InputAccount UEditableTextBox
local tbClass = Class("UMG.BaseWidget")
local tbLoginState = {
    InitSdk = 1,
    RequstLoginParam = 2,
    RecvLoginParam = 3,
    SelectServerList = 4,
    RequestServerAddr = 5,
    ConnectServer = 6,
    RequestLogin = 7,
    LocalDebugLogin = 8
}

tbClass.CurrState = 1

function tbClass:SetDebugLogin(tbServerAddr)
    self.debugAddr = tbServerAddr.sAddr
    self.debugPort = tbServerAddr.nPort
    if UE4.UUserSetting.GetString('LoginToken') == '' then
        self.CurrState = tbLoginState.InitSdk
    else
        self.CurrState = tbLoginState.LocalDebugLogin
    end
end

function tbClass:SetState(state)
    self.CurrState = state
    if state == tbLoginState.InitSdk then
        WidgetUtils.Visible(self.LoginBtn)
    elseif state == tbLoginState.RequstLoginParam then
        UE4.UGameLibrary.RequestLoginParameter("")
        WidgetUtils.Collapsed(self.LoginBtn)
    elseif state == tbLoginState.RecvLoginParam then
        WidgetUtils.Visible(self.LoginBtn)
        if not WITH_XGSDK then
            WidgetUtils.Visible(self.BtnNewAccount);
            WidgetUtils.Visible(self.InputAccount);
            WidgetUtils.Visible(self.BtnServer);
        end
    elseif state == tbLoginState.RequestServerAddr then
        Login.DownloadServer(function(bSucc, errKey) 
            if bSucc then
                self:SetState(tbLoginState.ConnectServer)
            else
                if errKey then
                    UI.ShowMessage(errKey)
                else
                    UI.ShowMessage('tip.Expect_Next_Version')
                end
                self:SetState(tbLoginState.RecvLoginParam)
            end
        end)
        WidgetUtils.Collapsed(self.LoginBtn)
    elseif state == tbLoginState.ConnectServer then
        self:ConnectToServer()
    elseif state == tbLoginState.RequestLogin then
        me:Login(self.tbLoginParam.sProvider, self.tbLoginParam.sToken);
    end
end

function tbClass:OnInit()
    BtnAddEvent(self.BtnServer, function() self:DisplayServer() end)
    BtnAddEvent(self.LoginBtn, function()
        if not Login.CheckNetwork() then return end

        if not Login.CheckTestProtocol() then return end
        print("LoginState:", self.CurrState)
        if self.CurrState == tbLoginState.InitSdk then
            self:SetState(tbLoginState.RequstLoginParam)
        elseif self.CurrState == tbLoginState.RecvLoginParam then
            self:SetState(tbLoginState.RequestServerAddr)
        elseif self.CurrState == tbLoginState.LocalDebugLogin then
            self:ConnectToServer()
        end
    end)
    BtnAddEvent(self.BtnNewAccount, function()
        local sToken =  string.format("Tgame_%d", GetTime())
        UE4.UUserSetting.SetString('LoginToken', sToken)
        self.tbLoginParam.sToken = sToken          
    end)
    BtnAddEvent(self.BtnNotice, function()
       UI.Open('LoginInfo')
    end)

    WidgetUtils.Visible(self.BtnClose)
    BtnAddEvent(self.BtnClose, function()
        UE4.UGameLibrary.RequestExit();
    end)

    WidgetUtils.Collapsed(self.BtnNotice)
   self.nServerNotifyHandle =  EventSystem.OnTarget(Login, 'ON_SERVER_MAINTAIN', function()
        if not UI.IsOpen('LoginInfo') then
            UI.Open('LoginInfo')
        end
    end)

    self.InputAccount.OnTextCommitted:Add(self, function(_, str)
        UE4.UUserSetting.SetString('LoginToken', str)
        self.tbLoginParam = self.tbLoginParam or {}
        self.tbLoginParam.sProvider = "development"
        self.tbLoginParam.sToken = str
    end)

    self.InputAccount:SetText(UE4.UUserSetting.GetString('LoginToken'))
    self:BindEvent(true)

    print("umg_login_pc", Login.IsOversea())
    if Login.IsOversea() then
        WidgetUtils.Hidden(self.BtnAge)
    else
        BtnAddEvent(self.BtnAge, function() UI.Open('LoginAge') end)
    end
    BtnAddEvent(self.BtnScan, function()
        if not Login.CheckNetwork() then return end
        UE4.UGameLibrary.RequestLoginParameter(json.encode({loginType="0", appName=Text('ui.TxtGameName')}))
    end)
    if string.find(UE4.UGameLibrary.GetChannelId(), "bili") then
        WidgetUtils.Hidden(self.BtnScan)
    end

    WidgetUtils.Visible(self.BtnLogOut)
    BtnAddEvent(self.BtnLogOut, function()
        if not Login.CheckNetwork() then return end
        UI.OpenMessageBox(false, Text('ui.TxtCancellation'), function()
            UE4.UGameLibrary.RequestLogout()
        end, function()
        end);
    end)

    BtnAddEvent(self.BtnSelectServer, function() UI.Open("OverseaAreaList") end)
    --上报初始化事件
    --DataPost.PostEvent("device.connect", "game/initlogin", "", "pc_event")

    if Login.IsOversea() then
        WidgetUtils.Visible(self.BtnLanguage)
        BtnAddEvent(self.BtnLanguage, function() UI.Open('Language', 1)  end)
    else
        WidgetUtils.Collapsed(self.BtnLanguage)
    end
end

function tbClass:OnOpen()
    WidgetUtils.Collapsed(self.UID)
    WidgetUtils.Collapsed(self.DebugNode)
    WidgetUtils.Collapsed(self.LoginBtn)
    WidgetUtils.Collapsed(self.BtnServer)
    WidgetUtils.Collapsed(self.InputAccount)
    WidgetUtils.Collapsed(self.BtnNewAccount)

    self:ShowVersion()

    --self:DownloadServer(function() end)
    self:ShowOverseaInfo()
    self:OverseaMask()
    Localization.CheckLanguageTip()
    if WITH_XGSDK then
        self.DelayId = UE4.Timer.Add(2, function()
            if self.CurrState < tbLoginState.RequstLoginParam then
                self:SetState(tbLoginState.RequstLoginParam)
            end
        end)
        self:SetState(tbLoginState.InitSdk)
    else
        self:SetState(tbLoginState.RecvLoginParam)
        self.tbLoginParam = {sProvider = 'development', sToken = UE4.UUserSetting.GetString('LoginToken')}
    end
    DSAutoTestAgent.OpenAutoAgent(self)
    self:ShowDSError()
end

function tbClass:OverseaMask()
    local bOversea = Login.IsOversea()
    if bOversea then
        WidgetUtils.Collapsed(self.ISBN)
    else
        WidgetUtils.HitTestInvisible(self.ISBN)
    end
end

function tbClass:OnClose()
    self:BindEvent(false)
    EventSystem.Remove(self.nServerNotifyHandle)
    UE4.UUserSetting.Save()
    if self.DelayId then
        UE4.Timer.Cancel(self.DelayId)
    end
end

function tbClass:BindEvent(bBind)
    if bBind then
        -- 注册登录信息准备完成事件
        self.nHandleLoginParamReady = EventSystem.On(Event.LoginParamReady, function(bSucc, vParam)
            if bSucc then
                print('LOGIN_PARAM_READY', vParam.Provider, vParam.Token);
                self.tbLoginParam = { sProvider = vParam.Provider, sToken = vParam.Token };
                self:SetState(tbLoginState.RecvLoginParam)
            else
                UI.ShowMessage('tip.LoginError')
                self:SetState(tbLoginState.InitSdk)
            end
        end)

        --- 注册连接回调
        self.nHandleConnectResult = EventSystem.On(Event.ConnectResult, function(bSucc)
            if bSucc then
                UI.ShowConnection()
                if self.tbLoginParam then -- 指定服务器，这里已经获取到Token，接下来取UID
                    me:Login(self.tbLoginParam.sProvider, self.tbLoginParam.sToken);
                else -- 正常流程应该永远走不到这里
                    self:SetState(tbLoginState.InitSdk)
                end
            else
                UI.CloseConnection()
                UI.OpenMessageBox(false, Text('ui.FailedToConnectServer'), function()
                    self:SetState(tbLoginState.RecvLoginParam)
                end, function()
                    self:SetState(tbLoginState.RecvLoginParam)
                end);
            end
        end)

        --- 注册登录回调
        self.nHandleLogined = EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
            UI.CloseConnection()
            if IsValid(self) then
                WidgetUtils.Visible(self.LoginBtn)
            end

            if not me:IsLogined() then return end

            --上报进入游戏事件
            local extJson = string.format("{\"ue_deviceid\":\"%s\"}", UE4.UBiDataRecord.GetDeviceID())
            UE4.UGameLibrary.ReportEnterGame(extJson);
            UE4.UUMGLibrary.Login();
            Formation.InitLineup()
            DataPost.StartGetRTL()

            if GuideLogic.IsCanMapGuide() then
                GuideLogic.BeginMapGuide(bNeedRename)
            else
                local fGo = function() UE4.UUMGLibrary.Login() GoToMainLevel() end
                if bNeedRename then UI.CloseAll() UI.Open('Bename', fGo) else fGo() end
            end
        end)

        self.nHandleLoginFail = EventSystem.On(Event.LoginFail, function(sErr, pArgs)
            sErr = sErr or 'Error'

            UI.CloseConnection()

            if Error.Handled(sErr, pArgs) then
                self:SetState(tbLoginState.InitSdk)
                return
            end


            UI.OpenMessageBox(false, Text('error.' .. sErr), function()
                self:SetState(tbLoginState.InitSdk)
            end, function()
                self:SetState(tbLoginState.InitSdk)
            end);
        end)

        self.nHandleSdkLogout = EventSystem.On(Event.OnSdkLogout, function(code)
            self.tbLoginParam = nil;
            self:SetState(tbLoginState.RequstLoginParam)
        end)
    else
        EventSystem.Remove(self.nHandleLoginParamReady)
        EventSystem.Remove(self.nHandleConnectResult)
        EventSystem.Remove(self.nHandleLogined)
        EventSystem.Remove(self.nHandleLoginFail)
        EventSystem.Remove(self.nHandleSdkLogout)
    end
end

---服务器列表展示
function tbClass:DisplayServer()
    print("DisplayServer", self.DebugNode)
    if not self.DebugNode then
        self.DebugNode = LoadWidget('/Game/UI/UMG/Login/Widgets/uw_login_debug.uw_login_debug_C')
        if self.DebugNode then
            self.DebugContent:AddChild(self.DebugNode)
            local pSlot = UE4.UWidgetLayoutLibrary.SlotAsOverlaySlot(self.DebugNode)
            if pSlot then
                pSlot:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Fill)
                pSlot:SetVerticalAlignment(UE4.EVerticalAlignment.HAlign_Fill)
            end
        end
    end
    WidgetUtils.SelfHitTestInvisible(self.DebugNode)
end

---连接服务器
function tbClass:ConnectToServer()
    local tbServerInfo = Login.GetServer()

    ---没有服务器显示登陆按钮/提示信息
    if not tbServerInfo then
        WidgetUtils.Visible(self.LoginBtn)
        UI.CloseConnection()
        return
    end

    local sAddr, nPort = tbServerInfo.sAddr, tbServerInfo.nPort
    if self.debugAddr and self.debugPort then
        sAddr = self.debugAddr
        nPort = self.debugPort
    end
    print('server info :', sAddr, nPort, tbServerInfo.sName)
    UI.ShowConnection()
    me:Connect(sAddr, nPort)
end

function tbClass:UpdateServerName(str)
    if self.loginin_1 then
        self.loginin_1:SetText(str or 'xgsdk')
    end
end

function tbClass:ShowBtnServer()
    WidgetUtils.Visible(self.BtnServer)
    WidgetUtils.Visible(self.InputAccount)
end

function tbClass:RefreshText()
    print('login refresh text')
    UE4.UUMGLibrary.RefreshText(self)
    local sSelectStr = Login.GetAreaLastSelected()
    if sSelectStr then
        self:ShowOverseaServer(sSelectStr)
    end

    --刷新登陆界面logo
    self.logo:SetBrushResourceObject(nil)
    self.Logoshadow:SetBrushResourceObject(nil)
    SetTexture(self.logo, Login.nLogoImage)
    SetTexture(self.Logoshadow, Login.nLogoImage)
end

----海外区域信息
function tbClass:ShowOverseaInfo()
    if not Login.IsOversea() then
        self:ShowServerListBtn(false)
        return
    end

    self:ShowServerListBtn(true)
    self:ShowAreaList()
end

----区域列表展示 海外按钮
function tbClass:ShowAreaList()
    if not Login.IsOversea() then
        return
    end

    --第一次没选择自动弹出
    local sSelectStr = Login.GetAreaLastSelected()
    if sSelectStr and sSelectStr ~= "" then
        self:ShowOverseaServer(sSelectStr)
        Login.SetContent(sSelectStr)
        return
    end

    --打点
    Adjust.DoRecord("g8xb8s");
    
    self:ShowOverseaServer("")
    UI.Open("OverseaAreaList")
    return true
end

--显示海外区域列表文本
function tbClass:ShowOverseaServer(str)
    if self.Area and Login.IsOversea() then
        str = str or "ui.TxtLoginSelect"
        if str == "" then
            str = "ui.TxtLoginSelect"
        end

        self.Area:SetText(Text(str))
    end
end

--显示服务器列表按钮
function tbClass:ShowServerListBtn(bShow)
    if bShow and Login.IsOversea() then
        WidgetUtils.Visible(self.BtnSelectServer)
    else
        WidgetUtils.Collapsed(self.BtnSelectServer)
    end
end

--重置登陆按钮信息
function tbClass:ResetLoginInfo()
    WidgetUtils.Visible(self.LoginBtn)
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    DSAutoTestAgent.Tick(self, InDeltaTime)
end

--显示版本号
function tbClass:ShowVersion()
    local version = UE4.UGameLibrary.GetGameIni_String("Distribution", "Version", "0");
    self.version:SetText("W" .. version)
end    

function tbClass:ShowDSError()
    if not Player.DSError then return end
    UI.OpenByType("MessageBox", UE4.EUIType.Top, Text(Player.DSError), function() Player.DSError = nil end, 'Hide');
end

return tbClass
