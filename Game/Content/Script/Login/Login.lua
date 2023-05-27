-- ========================================================
-- @File    : Login.lua
-- @Brief   : 登录
-- ========================================================

Login = Login or { tbServer = {}, bOffLine = false, tbCurrent = nil ,bFirstEnterMainUI = true, nHandleSdkCallback = nil}

--海外区域列表
Login.tbAreaList = {"ui.TxtAreaUS", "ui.TxtAreaEU", "ui.TxtAreaAS", "ui.TxtAreaHK" } --{"America", "Europe", "Asia", "HK" }
-- 跟上面区域一一对应
local tbAreaKey = {"america", "europe", "asia", "hk"}
--区域对应服务器地址列表
Login.tbUrlList = {}
Login.tbContentList = {}
Login.bFirstEnterMainUI = true
require 'Login.LoginBG'

--登陆界面logo
Login.nLogoImage = 1008000

function Login.IsUseSpecialServer()
    return UE4.UGameLibrary.GetGameIni_Bool("Distribution", "UseSpecialServer", false);
end

--是否海外版本
function Login.IsOversea()
    return UE4.UGameLibrary.GetGameIni_Bool("Distribution", "Oversea", false);
end

---检查网络情况
function Login.CheckNetwork()
    local bAvailable = UE4.UGameLibrary.IsNetworkAvailable()
    if bAvailable then return true end
    UI.OpenMessageBox(false, Text('tip.NetError'), function() end, function() end);
    return false
end


--设置第一次进入主界面状态
function Login.OnEnterMainUI()
    Login.bFirstEnterMainUI = false
end

--重置第一次进入主界面状态
function Login.OnResetEnterMainUI()
    Login.bFirstEnterMainUI = true
end



---设置当前服务器
function Login.SetServer(server)
    Login.tbCurrent = server
    Login.OnSetServer(server)
end

---获取当前服务器配置
function Login.GetServer()
    return Login.tbCurrent;
end

---获取服务器配置
function Login.GetServers()
    local bUseServer = Login.IsUseSpecialServer()
    if bUseServer then
        return Login.GetServer()
    end
    return Login.tbServer;
end

--获取区域列表
function Login.GetAreaList()
    local sUrls = UE4.TArray(UE4.FString)
    UE4.UGameLibrary.GetGameIni_ArrayString("Distribution", "Server", "", sUrls)
    if sUrls:Length() == 0 then return "" end
    if #Login.tbUrlList == 0 and sUrls:Length() >0 then
        for i = 1, sUrls:Length() do
            local tbInfo =  Eval(sUrls:Get(i))
            Login.tbUrlList[tbInfo[1]] = tbInfo[2]
        end
    end
    --服务器列表顺序如下国服 美服 欧洲 亚服 港服
    --国内只读第一个，海外从第二个开始
    if Login.IsOversea() then
        local sSelectStr = Login.GetAreaLastSelected()
        local sKey = Login.FindAreaKey(sSelectStr)
        return Login.tbUrlList[sKey]
    else
        return Login.tbUrlList['mainland']
    end
end

function Login.InitContent()
    local sUrls = UE4.TArray(UE4.FString)
    UE4.UGameLibrary.GetGameIni_ArrayString("Distribution", "ContentServer", "", sUrls)
    if sUrls:Length() == 0 then return "" end
    if #Login.tbContentList == 0 and sUrls:Length() >0 then
        for i = 1, sUrls:Length() do
            local tbInfo =  Eval(sUrls:Get(i))
            Login.tbContentList[tbInfo[1]] = tbInfo[2]
            print("InitContent", tbInfo[1], tbInfo[2])
        end
    end
end

function Login.SetContent(areaKey)
    local key = Login.FindAreaKey(areaKey)
    print("SetContent", key, Login.tbContentList[key])
    if key and areaKey then
        Login.ContentUrl = Login.tbContentList[key]
    end
end

function Login.GetContent()
    if Login.IsOversea() or Login.ContentUrl then
        return Login.ContentUrl
    else 
        Login.ContentUrl = Login.tbContentList['mainland']
        return Login.ContentUrl
    end
end

function Login.FindAreaKey(SelectStr)
    for i,v in ipairs(Login.tbAreaList) do
        if v == SelectStr then
             return tbAreaKey[i]
        end
     end
end

--获取区域列表
function Login.GetShowAreaList()
    local tbShow = {}
    for i,v in ipairs(Login.tbAreaList) do
       if Login.tbUrlList[tbAreaKey[i]] then
            table.insert(tbShow, {v, Login.tbUrlList[v] or ""})
       end
    end
    return tbShow, Login.GetAreaLastSelected()
end

---请求服务器信息
function Login.DownloadServer(fCallback)
    local bUseServer = Login.IsUseSpecialServer()
    if bUseServer then
        local sVersion = UE4.UGameLibrary.GetGameIni_String("/Script/EngineSettings.GeneralProjectSettings", "ProjectVersion", "");
        local sUrl = Login.GetAreaList()
        if not sUrl or sUrl == "" then
            fCallback(false, 'ui.TxtLoginSelect')
            return
        end

        sUrl = string.format('%s&version=%s', sUrl, sVersion)
        UI.ShowConnection()
        Download(sUrl, function(bSucc, sServerInfo)
            print('server ret:', sServerInfo)
            UI.CloseConnection()
            local tbServerInfo = json.decode(sServerInfo) or {}
            if type(tbServerInfo) == "table" and #tbServerInfo > 0 then
                local server = tbServerInfo[1]
                Login.SetServer({
                    sName = server['platform'] or 'xgsdk',
                    sAddr = server['host'],
                    nPort = server['port'],
                });
                fCallback(true);
            else
                Login.SetServer(nil);
                fCallback(false);
            end
        end)
    else
        local lastSelectedServer = Login.GetServerLastSelected()
        for i=#Login.tbServer,1,-1 do
            local server = Login.tbServer[i]
            if i == 1 or (server['sName'] or 'xgsdk') == lastSelectedServer then
                Login.SetServer(server);
                break;
            end
        end
        fCallback(true, #Login.tbServer);
    end
end

---记载服务器配置
function Login.Load()
    local tbFile = LoadCsv("servers.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local tbInfo = {
            sName = tbLine.name or '',
            sAddr = tbLine.addr,
            nPort = tonumber(tbLine.port),
        }
        table.insert(Login.tbServer, tbInfo)
    end
    -- sdk 防沉迷的事件回调通知
    -- retCode 始终都是200
    -- retMsg "1" 强制下线
    if Login.nHandleSdkCallback then
        EventSystem.Remove(Login.nHandleSdkCallback)
    end
    Login.nHandleSdkCallback = EventSystem.On(Event.AntiAddiction, function(retCode, retMsg)
        if retMsg == "1" then
            UE4.UGameLibrary.RequestExit();
        end
    end)
    if Login.ConfimCloseHander then
        EventSystem.Remove(Login.ConfimCloseHander)
    end
    Login.ConfimCloseHander = EventSystem.On(Event.ConfimCloseApp, function(retCode, retMsg)
        UI.OpenExitUI()
    end)
    Login.InitContent()
    Login.nHandleLoginParamReady = EventSystem.On(Event.LoginParamReady, function(bSucc, vParam)
        if Login.bReturnEntry then
            GoToLoginLevel()
            Login.bReturnEntry = false
        end
    end)
end

function Login.GetServerLastSelected()
    return UE4.UUserSetting.GetString('PlayerSetting_ServerLastSelected', '')
end

function Login.SetServerLastSelected(str)
    UE4.UUserSetting.SetString('PlayerSetting_ServerLastSelected', str or 'xgsdk')
end

function Login.GetAreaLastSelected()
    return UE4.UUserSetting.GetString('PlayerSetting_AreaLastSelected', '')
end

function Login.SetAreaLastSelected(str)
    UE4.UUserSetting.SetString('PlayerSetting_AreaLastSelected', str or '')
end

function Login.OnSetServer(server)
    if not server or not server['sName'] then
        return
    end
    Login.SetServerLastSelected(server['sName'])
    local ui = UI.GetUI('login')
    if ui and ui.UpdateServerName then
        ui:UpdateServerName(server['sName'])
    end
end

function Login.CheckTestProtocol(pCallBack)
    -- local bOk = UE4.UUserSetting.GetBool('ProtocolAgree')
    -- if not bOk then
    --     UI.Open('TestProtocol', pCallBack)
    -- else
    --    if pCallBack then pCallBack() end
    -- end
    -- return bOk

    -- 提审屏蔽
    if pCallBack then pCallBack() end
    return true
end

--是否弹窗选择区域
function Login.CheckOverseaPopArea()
    if not Login.IsOversea() then return end

    local sUI = UI.GetUI("login")
    if sUI and sUI:IsOpen() then
        return sUI:ShowAreaList()
    end
end

--设置login界面文字
function Login.OnSetArea(server)
    if not server or not server['sName'] then
        return
    end
    Login.SetContent(server['sName'])
    Login.SetAreaLastSelected(server['sName'])
    local ui = UI.GetUI('login')
    if ui and ui.ShowOverseaServer then
        ui:ShowOverseaServer(server['sName'])
    end
end

--重置下载标记
function Login.ResetDownloadFlag()
    local ui = UI.GetUI('login')
    if ui and ui.ResetLoginInfo then
        ui:ResetLoginInfo()
    end
end

function Login.CustomerService()
    if string.find(UE4.UGameLibrary.GetChannelId(), "bili") then
        local biliUrl = 'https://bilibiligame.aihelpcn.net/webchatv4/#/appKey/BILIBILIGAME_app_1a6990f3b1cd43b8a043e35668ab607d/domain/bilibiligame.aihelpcn.net/appId/bilibiligame_platform_39d418738fd10c47828f973fcbb0c73d/?entranceId=E001&language=zh_CN&appName=%E5%85%B6%E4%BB%96%E6%B8%B8%E6%88%8F&sdkVersion=4.2.0'
        UE4.UKismetSystemLibrary.LaunchURL(biliUrl)
        return
    end

    local tbPlayerInfo = {}
    tbPlayerInfo.role_id = tostring(me:Id())
    tbPlayerInfo.area = tostring(me:GetAreaID())
    tbPlayerInfo.role_name = me:Nick()
    tbPlayerInfo.account = me:AccountId()
    tbPlayerInfo.avatar = ""
    tbPlayerInfo.level = me:Level() or ""
    tbPlayerInfo.channel = me:Channel()
    tbPlayerInfo.server = ""

    local sData = json.encode(tbPlayerInfo)
    local key = Login.IsOversea() and "qwertyuiop123456" or "abcdefg123456788"
    local sEncrypt = UE4.UGMLibrary.JsonEncrypt(key, sData);

    local sTimestamp = tostring(GetTime()) --os.time()
    local sNonce = sTimestamp .. me:Id()
    local sort = UE4.UGMLibrary.DictionaryOrder(sTimestamp, Login.IsOversea() and 'zxcvbnbg123456788' or '31C3eQJQeXQBwN8BMY69BK9b4HV1JF' , sNonce)
    local sSignature = UE4.UGMLibrary.SignatureEncrypt(sort)

    local areaKey = Localization.GetCurrentAreaKey()
    local domain_name = Login.IsOversea() and 'gm-mobile.amazingseasun.com' or 'gm-mobile.xoyo.com'
    local sFormat = "http://%s/app/h5/home?encrypt_data=%s&key=".. areaKey .."&signature=%s&timestamp=%s&nonce=%s"
    local sUrl = string.format(sFormat, domain_name, sEncrypt, sSignature, sTimestamp, sNonce);
    UE4.UKismetSystemLibrary.LaunchURL(sUrl)
end

Login.Load()