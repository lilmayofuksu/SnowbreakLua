-- ========================================================
-- @File    : Reconnect.lua
-- @Brief   : Lua数据层
-- @Usage   : 用于断线重连处理
-- ========================================================

---数据模型基类
---@class Reconnect
Reconnect = Reconnect or {};
local MaxReconnectCount = 3;
Reconnect.isConnectBreaken = false
Reconnect.isShowReconnectBox = false

EventSystem.On(Event.ConnectBreaken, function(nReconnectCount)
    Reconnect.SetConnectBreaken(true)
    Reconnect.OnShowReconnectUMG(nReconnectCount)
end)

EventSystem.On(Event.ReconnectSuccess, function()
    Reconnect.OnReconnectSuccess()    
end)
EventSystem.On(Event.ReloginFail, function()
    UI.CloseConnection()
    Reconnect.isShowReconnectBox = true
    if Online.GetOnlineState() >= Online.STATUS_ENTER then
        Player.DSError = "tip.relogin_fail"
    end

    UI.OpenByType("MessageBox", UE4.EUIType.Top, Text("tip.relogin_fail"), 
        function() Reconnect.isShowReconnectBox = false; Reconnect.GotoLoginLevel() end, 
        function() Reconnect.isShowReconnectBox = false; Reconnect.GotoLoginLevel() end)
end)
EventSystem.On(Event.ReloginSuccess, function()
    Reconnect.SetConnectBreaken(false)
    UI.CloseConnection()
end)
---显示断线重连界面
---@param nReconnectCount UE4.int32 重连次数
function Reconnect.OnShowReconnectUMG(nReconnectCount)
    if not me then return end
    UI.CloseConnection()
    Reconnect.isShowReconnectBox = true    
    Reconnect.ReleaseFightInput()
    if me:IsOfflineLogin() then return end
    if nReconnectCount == 0 then
        UI.OpenByType("MessageBox", UE4.EUIType.Top, Text("tip.connect_break"), function() Reconnect.isShowReconnectBox = false; Reconnect.Reconnect() end, function() Reconnect.isShowReconnectBox = false; Reconnect.GotoLoginLevel() end)
    elseif nReconnectCount < MaxReconnectCount then
        UI.OpenByType("MessageBox", UE4.EUIType.Top, Text("tip.reconnect_fail"), function() Reconnect.isShowReconnectBox = false; Reconnect.Reconnect() end, function() Reconnect.isShowReconnectBox = false; Reconnect.GotoLoginLevel() end)
    else
        UI.OpenByType("MessageBox", UE4.EUIType.Top, Text("tip.reconnect_fail_over"), function() Reconnect.isShowReconnectBox = false; Reconnect.GotoLoginLevel() end, function() Reconnect.isShowReconnectBox = false; Reconnect.GotoLoginLevel() end)
    end
end

---断线重连
function Reconnect.Reconnect()
    UI.ShowConnection()
    me:Reconnect()
end
---重连成功，重新登录
function Reconnect.OnReconnectSuccess()
    --UI.CloseConnection()
    me:Relogin()
end

---重连超时，返回登录界面
function Reconnect.GotoLoginLevel(sKey)
    print("Reconnect.GotoLoginLevel", "OnlineState ", Online.GetOnlineState())
    if Online.GetOnlineState() >= Online.STATUS_ENTER then
        UE4.UAccount.ClearOthers(1)
        Online.ClearAll()
        Player.DSError = sKey
    end
    me:Logout()
    GoToLoginLevel()
end

--是否检查连接状态
function Reconnect.CanCheckConnectState()
    local sGameMode = Map.GetGameMode()
    if sGameMode == "BP_GameBaseMode" or sGameMode == "BP_DungeonGameModeBase"  or sGameMode == "BP_GameMode_Plot" then
        return 0
    end
    return 1
end

function Reconnect.SetConnectBreaken(bBreak)
    Reconnect.isConnectBreaken = bBreak
    Reconnect.SendSettleInfoCount = 0
end


function Reconnect.ReleaseFightInput()
    if Reconnect.CanCheckConnectState() == 1 then 
        return
    end
    UE4.UUMGLibrary.ReleaseInput()
    UE4.ULevelLibrary.FlushPressedKeys(GetGameIns())
end



-- ========================================================



Reconnect.REQ_DealLevelSettlement = 'Chapter_DealLevelSettlement'
Reconnect.tbSettleInfo = {
    sCmd = nil,
    tbParam = nil
}
Reconnect.SettleInfoTimerHandle = nil
Reconnect.SendSettleInfoCount = 0

Reconnect.Guide_SetMemberByLineup1 = nil


---发送结算请求
---@param sCmd string cmd
---@param sParam string 结算参数
function Reconnect.Send_SettleInfo(sCmd, tbParam)
    if sCmd and tbParam then
        Reconnect.ClearSettleInfo()

        Reconnect.tbSettleInfo.sCmd = sCmd
        Reconnect.tbSettleInfo.tbParam = tbParam
        Reconnect.SettleInfoTimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({GetGameIns(), Reconnect.Tick_SettleInfo}, 2, true)
    end

    if Reconnect.tbSettleInfo.sCmd and Reconnect.tbSettleInfo.tbParam then        
        me:CallGS(Reconnect.REQ_DealLevelSettlement, json.encode(Reconnect.tbSettleInfo))
    end
end



function Reconnect.Tick_SettleInfo()
    if Reconnect.isConnectBreaken == true then --已经知道断线了
        return
    end

    Reconnect.SendSettleInfoCount = Reconnect.SendSettleInfoCount + 1
    if Reconnect.SendSettleInfoCount > 5 then -- 发送了5次还没收到消息，强制断线
        me:BreakConnect()
        return
    end

    if Reconnect.Guide_SetMemberByLineup1 ~= nil then
        Reconnect.Guide_SetMemberByLineup1()
        return
    end

    if Reconnect.tbSettleInfo and Reconnect.tbSettleInfo.sCmd and Reconnect.tbSettleInfo.tbParam then        --重发结算数据
        me:CallGS(Reconnect.REQ_DealLevelSettlement, json.encode(Reconnect.tbSettleInfo))
    else
        Reconnect.ClearSettleInfo()
    end
end

---接收结算结果
---@param sParam string 返回参数
function Reconnect.Received_SettleInfo(tbParam)
    local sCmd = tbParam.sCmd
    local tbSettleParam = tbParam.tbParam
    if sCmd and Reconnect.tbSettleInfo.sCmd then        
        s2c.Dispatch(sCmd, json.encode(tbSettleParam))
    end
    Reconnect.ClearSettleInfo()
end

---清除结算缓存信息
function Reconnect.ClearSettleInfo()
    if Reconnect.SettleInfoTimerHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(GetGameIns(), Reconnect.SettleInfoTimerHandle)
        Reconnect.SettleInfoTimerHandle = nil
    end
    Reconnect.Guide_SetMemberByLineup1 = nil

    Reconnect.tbSettleInfo.sCmd = nil
    Reconnect.tbSettleInfo.tbParam = nil    
    Reconnect.SetConnectBreaken(false)
end


---x新手关断线重复发送设置队伍消息
function Reconnect.SetMemberByLineup1(Fun, Callback)
    if Fun == nil then
        return
    end

    Reconnect.SettleInfoTimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({GetGameIns(), Reconnect.Tick_SettleInfo}, 2, true)
    Reconnect.Guide_SetMemberByLineup1 = Fun
    Reconnect.Guide_SetMemberByLineup1()
end


---注册结算的回调
s2c.Register(Reconnect.REQ_DealLevelSettlement, function(tbRet)    
    Reconnect.Received_SettleInfo(tbRet)
end
)
-- EventSystem.On(
--     Event.OnWorldFinishDestroy,
--     function()
--         Reconnect.ClearSettleInfo()
-- end)
