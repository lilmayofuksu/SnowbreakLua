-- ========================================================
-- @File    : ZoneTime.lua
-- @Brief   : 处理时区和时间的类
-- ========================================================

ZoneTime = ZoneTime or {}
ZoneTime.sTime1 = "202301010400"
ZoneTime.sTime2 = "202304010400"
ZoneTime.nDefaultTime1 = 1672516800  --sTime1  东8区 时间
ZoneTime.nDefaultTime2 = 1680292800  --sTime2  东8区 时间

ZoneTime.nDefaultZone = 8  --东8区

-- 缓存时间函数os.time,os.date
ZoneTime.OldTimeFunc = ZoneTime.OldTimeFunc or os.time
ZoneTime.OldDateFunc = ZoneTime.OldDateFunc or os.date

ZoneTime.Server_Zone = nil   --服务器时区
ZoneTime.Client_Zone = nil   --当前本地时区
ZoneTime.nTimeGap1 = nil   --服务器时间和当前本地时间的差值  北半球 冬令时 南半球 夏令时
ZoneTime.nTimeGap2 = nil   --服务器时间和当前本地时间的差值  北半球 夏令时 南半球 冬令时

--- 配置表转时间，先注册到这里，登陆后用服务器时区重新刷时间
ZoneTime.tbTimeKey = {}

--客户端收到时间请求标记
ZoneTime.nRecTime = 0
ZoneTime.nSendTime = 0
ZoneTime.nCDTime = 30

--设置时区时间差
function ZoneTime.SetTimeGap(nTime1, nTime2)
    local t = ZoneTime.OldTimeFunc()
    local isDst = ZoneTime.OldDateFunc("*t",t).isdst and -3600 or 0
    ZoneTime.Client_Zone = math.floor(os.difftime(t, ZoneTime.OldTimeFunc(ZoneTime.OldDateFunc("!*t", t+isDst)))/3600) -- 获得时区

    local nDefaultTime1 = ZoneTime.nDefaultTime1
    local nDefaultTime2 = ZoneTime.nDefaultTime2
    if me and me.GetServerTimeZone then
        ZoneTime.Server_Zone = math.floor(me:GetServerTimeZone() / 3600)
        nDefaultTime1 = (ZoneTime.nDefaultZone - ZoneTime.Server_Zone) * 3600 + ZoneTime.nDefaultTime1
        nDefaultTime2 = (ZoneTime.nDefaultZone - ZoneTime.Server_Zone) * 3600 + ZoneTime.nDefaultTime2
    end

    ZoneTime.nTimeGap1 = (nTime1 or nDefaultTime1) - ParseTimeNative(ZoneTime.sTime1)
    ZoneTime.nTimeGap2 = (nTime2 or nDefaultTime2) - ParseTimeNative(ZoneTime.sTime2) 
end

--重载时间函数os.time,os.date
function ZoneTime.OverrideTimeFunc()
    local NewTimeFunc = function(tbDate)
        if tbDate then
            tbDate.isdst = nil
        end
        local ret = ZoneTime.OldTimeFunc(tbDate)
        if ret then
            if ZoneTime.OldDateFunc("*t", ret).isdst then
                return ret + ZoneTime.nTimeGap2
            else
                return ret + ZoneTime.nTimeGap1
            end
        else
            return ret
        end
    end

    local NewDateFunc = function(format, time)
        if not time then time = os.time() end;
        
        if string.gsub(format, 1, 1) == "!" then
            return ZoneTime.OldDateFunc(format, time)
        else
            if time >= 1009814400 then --2002.1.1 0.0.0 认为是时间戳 否为倒计时等格式化需求
                if ZoneTime.OldDateFunc("*t",time).isdst then
                    time = time - ZoneTime.nTimeGap2
                else
                    time = time - ZoneTime.nTimeGap1
                end
            end
            return ZoneTime.OldDateFunc(format, time)
        end
    end

    os.time = NewTimeFunc
    os.date = NewDateFunc
end

--登陆后需要设置一下时间差
function ZoneTime.DoLogin()
    ZoneTime.nRecTime = 0
    ZoneTime.SetTimeGap()
    ZoneTime.OverrideTimeFunc()
    ZoneTime.DoTimeChange()
end

--需要登陆后转换的时间
---@param tbInfo table 配置表项的table
---@param sKey string 配置表需要转换的字段key 比如：StartTime,EndTime
---@param tbTime table 配置表转换的时间table数据
function ZoneTime.RegisterTimeKey(tbInfo,  sKey, tbTime)
    if not tbInfo or not sKey or not tbTime then return end

    table.insert(ZoneTime.tbTimeKey, {tbInfo = tbInfo, sKey = sKey, tbTime = tbTime})
end

--登陆后重新转换一下时间戳
function ZoneTime.DoTimeChange()
    for k,v in ipairs(ZoneTime.tbTimeKey) do
        v.tbInfo[v.sKey] = os.time(v.tbTime)
    end
end

--请求更新服务器时间差
function ZoneTime.ReqTime()
    if ZoneTime.nRecTime > 0 then
        return
    end

    if ZoneTime.nSendTime > GetTime() then
        return
    end
    
    me:CallGS("ZoneTime_ReqTime")
    ZoneTime.nSendTime = GetTime() + ZoneTime.nCDTime
end

--检查是否收到服务器时间修改
function ZoneTime.CheckReqTime()
    if ZoneTime.nDefaultZone == ZoneTime.Server_Zone then return end

    ZoneTime.ReqTime()
end

---更新时区差值
s2c.Register('ZoneTime_ChangeTime', function(tbParam)
    if not tbParam or not tbParam.nTime1 or not tbParam.nTime2 then return end

    ZoneTime.SetTimeGap(tbParam.nTime1, tbParam.nTime2)
    ZoneTime.DoTimeChange()
    ZoneTime.nRecTime = GetTime()
end)
