-- ========================================================
-- @File    : Error.lua
-- @Brief   : 错误处理
-- ========================================================
---@class Error
Error = Error or {tbHandle = {}}

---@param nErrCode integer
---@param pArgs UE4.TArray
---@return boolean
function Error.Handled(nErrCode, pArgs)
    local funHandle = Error.tbHandle[nErrCode]
    if not funHandle then return false; end

    local tbArgs = {}
    if pArgs then
        for i = 1, pArgs:Length() do
            table.insert(tbArgs, pArgs:Get(i))
        end
    end

    local ret = funHandle(table.unpack(tbArgs))
    if ret == nil then
        ret = true
    end
    return ret
end

---服务器维护处理
Error.tbHandle[208] = function()
    EventSystem.TriggerTarget(Login, 'ON_SERVER_MAINTAIN')
end


---尚未取得测试资格！
Error.tbHandle[307] = function()
    UI.ShowTip('tip.login_not_invited')
end

---未登录或登录异常！
Error.tbHandle[301] = function()
    if UI.IsOpen("Login") then
        return false
    end
    UI.OpenMessageBox(false,
        Text('error.LoginNeed'),
        function()
            GoToLoginLevel()
            me:Clear()
        end,
        "Hide"
    )
    return true
end

---找不到服务
Error.tbHandle[201] = function()
    UI.CloseConnection()
    if UI.IsOpen("Login") then
        return false
    end
    UI.OpenMessageBox(false,
        Text('error.MissServerLoginNeed'),
        function()
            GoToLoginLevel()
            me:Clear()
        end,
        "Hide"
    )
    return true
end

---账号冻结
Error.tbHandle[306] = function(nBanType, nBanExpr)
    UI.OpenMessageBox(false,
        Text("ui.TxtBanMsg"),
        function()
            if Login.IsOversea() then
                Login.CustomerService()
            else
                UE4.UKismetSystemLibrary.LaunchURL("https://www.project-snow.com")
            end
        end,
        function()
            UE4.UGameLibrary.QuitGameWithLog("Ban Exit Game")
        end,
        false, nil, nil,
        Text("ui.TxtComplain"),
        Text("ui.TxtExitGame"),
        string.format(Text("ui.TxtBanMsgTips"), Text("ui.TxtBanType" .. nBanType), os.date("%Y/%m/%d %H:%M", nBanExpr))
    )
end