-- ========================================================
-- @File	: Data/DataPost.lua
-- @Brief	: 蓝鲸数据上报
-- ========================================================

DataPost = DataPost or {};

function DataPost.PostEvent(sMsgType, sEventId, sEventVal, sEventDes)
    local mapParam = UE4.TMap(UE4.FString, UE4.FString)
    mapParam:Add("msgType", sMsgType)
    sEventId = sEventId or ""
    sEventVal = sEventVal or ""
    sEventDes = sEventDes or ""
    mapParam:Add("channel", UE4.UGameLibrary.GetChannelId())
    mapParam:Add("appVersion", UE4.UGameLibrary.GetGameIni_String("Distribution", "Version", "1.0"))

    if me ~= nil and me:Id() ~= 0 then
        mapParam:Add("roleId", me:Id())
        mapParam:Add("accountId", me:AccountId())
        mapParam:Add("roleName", me:Nick())
        mapParam:Add("server", me:GetAreaID())
        mapParam:Add("serverName", 'INVALID_SNAME')
        mapParam:Add("zoneName", 'INVALID_SNAME')
        mapParam:Add("zone", me:GetAreaID())
        mapParam:Add("roleLevel", me:Level())

        mapParam:Add("channel", me:Channel())
        mapParam:Add("roleType", 'manager')
    end
    print("Datapost postevent:", sMsgType, sEventId)
    UE4.UBiDataRecord.AddBiEventFromParam(sEventId, sEventVal, mapParam)
end

--上报Customevent数据
--eventID:str; eventDesc:str; eventVal:int; eventBodyJson:str(满足json格式的字符串)
function DataPost.XGEvent(eventID, eventDesc, eventVal, eventBodyJson)
    UE4.UGameLibrary.ReportXGEvent(eventID, eventDesc or "", eventVal or 0, eventBodyJson or "{}")
end

function DataPost.RecordUE4Device()
    local eventJson = string.format("{\"ue_deviceid\":\"%s\"}", UE4.UBiDataRecord.GetDeviceID())
    local lst_v = Split(UE4.UGameLibrary.GetGameIni_String("Distribution", "Version", "0"), '%.')
    local nVersion = tonumber(Concat_str(lst_v))

    DataPost.XGEvent("game/record_ue4_device", "Device Get by UE", nVersion, eventJson)
end


--心跳数据
function DataPost.HeartBeat()
    if IsMobile() then return end --只PC
    DataPost.PostEvent('device.heartbeat', 'game/heartbeat', '', 'game_pc')
    DataPost.HeartBeatHandle = UE4.Timer.Add(60,
        function ()
            DataPost.HeartBeat()
        end
    )
end

function DataPost.StopHeartBeat()
    if DataPost.HeartBeatHandle then UE4.Timer.Cancel(DataPost.HeartBeatHandle) end
    DataPost.HeartBeatHandle = nil
end


--服务器往返延迟
function DataPost.StartGetRTL()
    print('GET_RTL', DataPost.RTLHandle)
    if not DataPost.RTLHandle or DataPost.RTLHandle == 0 then
        DataPost.RTLHandle = UE4.Timer.Add(5, DataPost.GetRTL)
    end
end

function DataPost.GetRTL()
    if me and me:Id() ~= 0 then
        DataPost.start_ms = UE4.UGameLibrary.GetNowMillisecond()
        me:CallGS("GET_RTL", json.encode({start = DataPost.start_ms}))
    end

    DataPost.RTLHandle = UE4.Timer.Add(300, DataPost.GetRTL)-- 5min
end

function DataPost.StopGetRTL()
    if DataPost.RTLHandle then UE4.Timer.Cancel(DataPost.RTLHandle) end
    DataPost.RTLHandle = nil
end

function DataPost.OnGetRTL(tbParam)
    DataPost.end_ms = UE4.UGameLibrary.GetNowMillisecond()
    local latency = DataPost.end_ms - tbParam.start
    local online = tbParam.online or 0
    me:CallGS("Record_RTL", json.encode({rtl = latency, online = online}))
    local eventJson = string.format("{\"latency\":\"%d\",\"onlinetime\":\"%d\"}", latency, online)
    local lst_v = Split(UE4.UGameLibrary.GetGameIni_String("Distribution", "Version", "0"), '%.')
    local nVersion = tonumber(Concat_str(lst_v))
    DataPost.XGEvent("game/latency", "Round Trip Latency", nVersion, eventJson)
end

--DataPost.GetRTL()

--注册回调
s2c.Register("ON_GET_RTL", DataPost.OnGetRTL)