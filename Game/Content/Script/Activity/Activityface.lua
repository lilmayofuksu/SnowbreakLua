-- ========================================================
-- @File    : Activityface.lua
-- @Brief   : 活动预览打脸图接口
-- ========================================================
Activityface = Activityface or{
    tbActivityface  = {},           --- 配置信息
}

--task属性 group
Activityface.nGroupId        = 60        --- 活动Id 不可更改

Activityface.PopAdActivityFaceHandle = 'AD_ACTIVITY_FACE_HANDLE'
Activityface.tbPopFaceId = {} --一次登陆弹出的列表
Activityface.tbSortedFaceList = {} --一次登陆弹出的列表  排序
Activityface.DailyTime = 4 --4点
Activityface.nShowDay = 7 --7天不显示
Activityface.nVersion = 1 --版本号

Activityface.bLoginFirst = false --登陆后第一次调用

--配置信息
function Activityface.LoadConfig()
    Activityface.tbActivityface = {}
    local tbFile = LoadCsv('activity/activityface/activityface.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local nId       = tonumber(tbLine.Id) or 0;
        local nCoverage = tonumber(tbLine.Coverage) or 0
        if nId > 0 and CheckCoverage(nCoverage) then
            local tbInfo    = {
                nId             = nId,
                nSort           = tonumber(tbLine.Sort) or 9999,
                sBg             = tonumber(tbLine.Bg) or nil,
                nJump           = tonumber(tbLine.Jump) or nil,
                nCount          = tonumber(tbLine.Count) or 0,
                nLifelong      = tonumber(tbLine.IsLifelong) or 0,
                tbCondition         = Eval(tbLine.Condition) or {},
                nPopFlag    = tonumber(tbLine.nPopFlag) or 0,
                sPopName    = tbLine.sPopName,
                nCoverage = nCoverage,
            };

            tbInfo.tStarttime      = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), tbInfo, "tStarttime")
            tbInfo.tEndtime        = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), tbInfo, "tEndtime")
            tbInfo.tPopBeginTime   = ParseTime(string.sub(tbLine.PopBeginTime or '', 2, -2), tbInfo, "tPopBeginTime")
            tbInfo.tPopEndTime     = ParseTime(string.sub(tbLine.PopEndTime or '', 2, -2), tbInfo, "tPopEndTime")

            Activityface.tbActivityface[nId] = tbInfo;
        end
    end
    print('Load ../settings/activity/activityface/activityface.txt')
end

--获取配置信息
function Activityface.GetConfig(nFaceId)
    if not nFaceId then return end

    return Activityface.tbActivityface[nFaceId]
end

--获取下一个id
function Activityface.GetNextFaceId(nFaceId)
    local bGet = false
    for i,v in ipairs(Activityface.tbSortedFaceList) do
        if not nFaceId or nFaceId == 0 then
            return v.nId
        elseif v.nId == nFaceId then
            bGet = true
        elseif bGet then
            return v.nId
        end
    end
end

--检测当前活动打脸图是否需要弹出
--- 监听打脸图
function Activityface.PopCallBack()
    EventSystem.OnTarget(
        Activityface,
        Activityface.PopAdActivityFaceHandle,
        function(_, nFaceId)
            Activityface.OpenActiviyFace(nFaceId)
        end
    )
end

--- 检查活动时间(活动开始之前一次，活动开始之后每天n次)
---@param InId Interge 活动Id
---@return bCheck boolean 是否在当前活动时间内
function Activityface.CheckDateTime(InId)
    local tbConfig = Activityface.tbActivityface[InId]
    if not tbConfig then
        return false
    end

    local nNowTime = GetTime()
    local nNum = Activityface.GetPopNum(InId)
    local nDateTime = Activityface.GetPopTime(InId)
    if not IsInTime(tbConfig.tStarttime, tbConfig.tEndtime, nNowTime) then
        return false
    end

    -- 检测限制
    local bUnLock = Condition.Check(tbConfig.tbCondition)
    if not bUnLock then
        return false
    end

     --勾选了7天不弹标记
    local nFlag = Activityface.GetPopFlag(InId)
    if nFlag > 0 then
        local nDissDay = Activityface.CheckTimeDay(nDateTime, nNowTime)
        if nDissDay < Activityface.nShowDay then
            return false
        else
            Activityface.SetPopFlag(InId, false)
        end
    end

    if nNum == 0 then
        return true, 0
    elseif not IsInTime(tbConfig.tStarttime, tbConfig.tEndtime, nDateTime) then --不是在活动期间，说明是新的一期
        return true, 0
    end

    if not IsInTime(tbConfig.tPopBeginTime, tbConfig.tPopEndTime, nNowTime) or tbConfig.nCount == 0 then 
        return false
    end

    if tbConfig.nLifelong == 0 then
        local nGetDate = tonumber(os.date('%Y%m%d', nDateTime - (Activityface.DailyTime * 3600)));
        local nNowDate = tonumber(os.date('%Y%m%d', nNowTime - (Activityface.DailyTime * 3600)));
        if nGetDate ~= nNowDate then --不是当天，当天次数为0
            nNum = 0
        end
    end

    if nNum >= tbConfig.nCount then
        return false
    end
    return true, nNum
end

--判定数据版本号
function Activityface.CheckVersion()
    local nCurVersion = me:GetAttribute(Activityface.nGroupId, 0)
    if string.len(nCurVersion) == 10  then --时间戳
        return false
    end

    return nCurVersion == Activityface.nVersion
end

--获取上次登陆弹出的时间
---@return Interge 时间戳
function Activityface.GetPopTime(nId)
    if not nId or nId <= 0 or nId > 65535 then return 99999999 end

    --上一个版本的时间记录
    if not Activityface.CheckVersion() then
        return me:GetAttribute(Activityface.nGroupId, 0)
    end

    local nTaskValue = me:GetAttribute(Activityface.nGroupId, nId)
    local nParseTime = GetBits(nTaskValue, 6, 30)*10000 + 400
    if not Activityface.CheckVersion() then --修改过程，兼容老的数据，不直接报错
        return 0
    end

    local l = string.len(nParseTime) --修改过程，兼容老的数据，不直接报错
    if l < 8 then
        return 0
    end

    return ParseTime(nParseTime)
end

--task存储 时间 和 次数
--时间为年月日时(21122704  21年12月27日4点)
--次数 最大30次
--获取当前弹出次数
---@param nId Interge 活动Id
function Activityface.GetPopNum(nId)
    if not nId or nId <= 0 or nId > 65535 then return 99 end

    local nTaskValue = me:GetAttribute(Activityface.nGroupId, nId)
    if not Activityface.CheckVersion() then
        return nTaskValue
    end

    return GetBits(nTaskValue, 1, 5)
end

--设置当前弹出次数
---@param nId Interge 活动Id
function Activityface.SetPopNum(nId, nVal)
    if not nId or nId <= 0 or nId > 65535 then return 9999 end

    if nVal == 0 then
        me:CallGS("ActivityFace_Update", json.encode({nType = 2, nId = nId}))
    else
        me:CallGS("ActivityFace_Update", json.encode({nType = 1, nId = nId}))
    end
end

--获取弹出标记
---@param nId Interge 活动Id
function Activityface.GetPopFlag(nId)
    if not nId or nId <= 0 or nId > 65535 then return 0 end

    local nTaskValue = me:GetAttribute(Activityface.nGroupId, nId)
    return GetBits(nTaskValue, 0, 0)
end

--设置7天不弹出标记
---@param nId Interge 活动Id
function Activityface.SetPopFlag(nId, bFlag)
    if not nId or nId <= 0 or nId > 65535 then return end

    local nFlag = Activityface.GetPopFlag(nId)
    if nFlag > 0 and bFlag then
        local nDateTime = Activityface.GetPopTime(nId)
        local nDissDay = Activityface.CheckTimeDay(nDateTime, GetTime())
        if nDissDay < Activityface.nShowDay then
            return
        end
    elseif nFlag == 0 and not bFlag then
        return
    end

    me:CallGS("ActivityFace_Update", json.encode({nType = 3, nId = nId, bFlag = bFlag}))
end

--- 交互操作回调
function Activityface.UpDataCallBack(InId)
    --- 活动Id
    if InId and Activityface.tbActivityface[InId] then
       -- Activityface.TagActivityface(cmd)
        --- 分别检测打脸图Id的弹出次数，只要两个计数没达到则会继续计数操作
        local nNextId = Activityface.GetNextFaceId(InId)
        if  not Activityface.tbPopFaceId[InId] or not Activityface.CheckDateTime(InId) then
            return Activityface.UpDataCallBack(nNextId)
        end

        Activityface.tbPopFaceId[InId] = nil
        Activityface.OnOpen(InId)
    else
        Activity.OnOpen()
    end
end

--- 回调
function Activityface.OnOpen(nFaceId)
    EventSystem.TriggerTarget(
        Activityface,
        Activityface.PopAdActivityFaceHandle,
        nFaceId
    )
end

-- 检查是否会有弹出界面
---@param bOpen bool 是否打开界面
function Activityface.CheckOpen(bOpen)
    if not Activityface.bLoginFirst  then
        Activityface.tbPopFaceId = {}
        Activityface.FilterPopList()
        Activityface.bLoginFirst = true
    end

    for key,v in pairs(Activityface.tbPopFaceId) do
        if bOpen then
            Activityface.tbPopFaceId[key] = nil
            EventSystem.Trigger(Event.ActivityFace, key)
        end
        return true
    end

    return false
end

--筛选需要弹出的列表
function Activityface.FilterPopList()
    Activityface.tbSortedFaceList = {}
    for key,v in pairs(Activityface.tbActivityface) do
        local bCheck, nNum = Activityface.CheckDateTime(key)
        if Activity.IsOpen(key) and bCheck then
            Activityface.tbPopFaceId[key] = key
            table.insert(Activityface.tbSortedFaceList, v)
        end
    end

    table.sort(Activityface.tbSortedFaceList, function(a, b)
        if a.nSort == b.nSort then
            return a.nId < b.nId
        end
        return a.nSort < b.nSort
    end)
end

-- 打开打脸图
function Activityface.OpenActiviyFace(nFaceId)
    if not nFaceId then return end

    Activityface.SetPopNum(nFaceId, 1)
end

function Activityface._OnInit()
    Activityface.LoadConfig()
    Activityface.PopCallBack()

    EventSystem.On(
        Event.ActivityFace,
        function(nFaceId)
            Activityface.OpenActiviyFace(nFaceId)
    end)
end

--计数两个时间差值
function Activityface.CheckTimeDay(nBegin, nEnd)
    if not nBegin or not nEnd then return end

    if nBegin > nEnd then
        local temp = nBegin
        nBegin = nEnd
        nEnd = temp
    end

    if nBegin <= 0 then
        return Activityface.nShowDay+1
    end

    nBegin = nBegin - (Activityface.DailyTime * 3600)
    nEnd = nEnd - (Activityface.DailyTime * 3600)
    local tbBegin = os.date("*t", nBegin)
    local tbEnd = os.date("*t", nEnd)
     local num1 = os.time({ year = tbBegin.year, month=tbBegin.month, day=tbBegin.day })
    local num2 = os.time({ year = tbEnd.year, month=tbEnd.month, day=tbEnd.day })

    return math.abs(num2 - num1) / (3600*24)
end

Activityface._OnInit()

EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    if bReconnected then return end
    Activityface.bLoginFirst = false
end)

s2c.Register('ActivityFace_Update',function(tbParam)
    if not tbParam or not tbParam.nId then 
        local nNextId = Activityface.GetNextFaceId(tbParam and tbParam.nFaceId)
        Activityface.UpDataCallBack(nNextId)
        return
    end

    local sName = "ActiviyFace"
    local tbConfig = Activityface.GetConfig(tbParam.nId)
    if not tbConfig then 
        local nNextId = Activityface.GetNextFaceId(tbParam and tbParam.nFaceId)
        Activityface.UpDataCallBack(nNextId)
        return 
    end

    if tbConfig.sPopName then
        sName = tbConfig.sPopName
        --检查活动
        if not Activity.IsOpen(tbParam.nId) then
            local nNextId = Activityface.GetNextFaceId(tbParam and tbParam.nId)
            Activityface.UpDataCallBack(nNextId)
            return
        end
    end

    local tbCmd = {nActivityId = tbParam.nId}
    if tbParam.nType == 1 then
        UI.Open(sName, tbCmd)
    elseif tbParam.nType == 3 then
        local sUI = UI.GetUI(sName)
        if sUI and sUI:IsOpen() and sUI.ShowCheckFlag then
            sUI:ShowCheckFlag()
        end
    end
end);

return Activityface