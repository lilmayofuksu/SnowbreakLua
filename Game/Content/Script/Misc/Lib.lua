-- ========================================================
-- @File    : Lib.lua
-- @Brief   : 纯lua通用函数算法库
-- @Author  : Leo Zhao
-- @Date    : 2019-08-26
-- ========================================================

---模拟继承
---@param Base table|userdata 父类
---@return table 子类
function Inherit(Base)
    local Type = type(Base)
    if Type ~= "table" and Type ~= "userdata" then
        error("Inherit bad parameter #1, table or userdata required")
    end

    local Sub = {Super = Base}
    setmetatable(
        Sub,
        {
            __index = function(t, k)
                return rawget(t, k) or t.Super[k]
            end
        }
    )

    return Sub
end

---计算table中元素数目
---@param tbVar table 表
---@return integer 表内一级元素数量
function CountTB(tbVar)
    local nCount = 0
    for _1, _2 in pairs(tbVar) do
        nCount = nCount + 1
    end
    return nCount
end

---判断是否是Array表
---@param tb any 需要判断的表
---@param bStrict boolean 是否不允许出现nil
---@return boolean 是否是Array表
---@return integer 长度
function IsArray(tb, bStrict)
    if type(tb) ~= "table" then
        return false, 1
    end

    local nMaxIdx = 0

    for k, v in pairs(tb) do
        if type(k) ~= "number" then
            return false, 1
        else
            nMaxIdx = math.max(nMaxIdx, k)
        end
    end

    if bStrict then
        for i = 1, nMaxIdx do
            if not tb[nMaxIdx] then
                return false, nMaxIdx
            end
        end
    end

    return true, nMaxIdx
end

---复制，请仅用于数值类型的复制
---@param v any 需要复制的变量
---@return any 返回深层拷贝后的值
function Copy(v)
    if type(v) ~= "table" then
        return v
    end

    local t = {}
    for key, value in pairs(v) do
        t[key] = Copy(value)
    end

    return t
end

---table子表(只支持数值索引型table)
---@param tbOrg table 原表
---@param nStart integer 包含该数据的起始index
---@param nEnd integer 包含该数据的结束index
---@return table 返回子表
function table.Sub(tbOrg, nStart, nEnd)
	nStart = nStart or 1
	nEnd = nEnd or #tbOrg
	nEnd = math.min(#tbOrg, nEnd)
	if nEnd < 0 then
		nEnd = #tbOrg + 1 + nEnd
	end

	if nStart > nEnd then return {} end
	local tbSub = {}
	for i = nStart, nEnd do
		table.insert(tbSub, tbOrg[i])
	end
	return tbSub
end

---连接两个Array
---@param tbHead table 出现在结果前面的table
---@param tbTail table 出现在结果后面的table
---@return table 返回连接后的array
function Concat(tbHead, tbTail)
    local bHeadOK, nHead = IsArray(tbHead, true)
    local bTailOK, nTail = IsArray(tbTail, true)

    if not bHeadOK then
        error("Concat #1 is not an array table")
    elseif not bTailOK then
        error("Concat #2 is not an array table")
    else
        local t = Copy(tbHead)
        for i = 1, nTail do
            t[i + nHead] = Copy(tbTail[i])
        end
        return t
    end
end

---串联array中所有元素至一个字符串, 从第一个不为空字符的元素开始
---@param tbList table 需要串联的数组
---@param SEP any 分隔符(默认无分割)
---@return string 返回串联后的字符串
function Concat_str(tbList, sSEP)
    local sep = sSEP or ""
    if type(tbList) ~= "table" then return tbList end
    local res = tostring(tbList[1])
    res = ''
    for _, v in pairs(tbList) do
        if res == '' then 
            res = v
        else
            res = res .. sep .. tostring(v)
        end
    end
    return res
end

---判断table是否包含某个元素
---@param tbArray table 数组
---@param elem any 需要查table中是否存在的元素
---@return boolean 是否包含该元素
function Contains(tbArray, elem)
    if type(tbArray) ~= 'table' then
        return false
    end
    for _, v in pairs(tbArray) do
        if v == elem then 
            return true
        end
    end
    return false
end

---合并Map
---@param tbHigh table 优先级高的
---@param tbLow table 优先级低的
---@return table 合并后的Table
function Merge(tbHigh, tbLow)
    if type(tbHigh) ~= "table" or type(tbLow) ~= "table" then
        error("Merge must be tables")
    end

    local t = Copy(tbHigh)
    for k, v in pairs(tbLow) do
        if not t[k] then
            t[k] = Copy(v)
        end
    end
    return t
end

---合并同类项，仅针对list
---@param tbList table<number, V> | V[]
---@param fCompare fun(a:V, b:V):number 比较两个元素的大小，相同返回0，a > b返回正数，反之返回负数
---@param fMerge fun(a:V, b:V):V 合并两个元素的方法
---@return table<number, V> | V[] 合并后的链表，，每个元素为两者的拷贝
function MergeSimilarList(tbList, fCompare, fMerge)
    local list = Copy(tbList)
    table.sort(
        list,
        function(a, b)
            return fCompare(a, b) > 0
        end
    )
    local tbResult = {}
    local nIdx = 0
    for _, V in ipairs(list) do
        if nIdx == 0 or fCompare(tbResult[nIdx], V) ~= 0 then
            table.insert(tbResult, V)
            nIdx = nIdx + 1
        else
            tbResult[nIdx] = fMerge(tbResult[nIdx], V)
        end
    end
    return tbResult
end

---洗牌
---@param t table 需要洗牌的数组
function Shuffle(t)
    local bOK, nCount = IsArray(t, true)
    if not bOK then
        error("Shuffle must on array table")
    end

    for i = 1, nCount - 1 do
        local j = math.random(i, nCount)
        t[j], t[i] = t[i], t[j]
    end
end

-- 字串切分
function Split(sData, sDelim)
    if type(sData) ~= "string" or #sData <= 0 then
        return {}
    end

    local tRet = {}
    local sPat = "(.-)" .. sDelim
    local nPos = 0
    local nLen = string.len(sData)

    while nPos <= nLen do
        local nStart, nEnd, sGet = string.find(sData, sPat, nPos)
        if not nStart then
            table.insert(tRet, string.sub(sData, nPos))
            break
        else
            table.insert(tRet, sGet)
            nPos = nEnd + 1
        end
    end

    return tRet
end

function SplitAsNumberTab(sData, sDelim)
    if type(sData) ~= "string" or #sData <= 0 then
        return {}
    end

    local tRet = {}
    local sPat = "(.-)" .. sDelim
    local nPos = 0
    local nLen = string.len(sData)

    while nPos <= nLen do
        local nStart, nEnd, sGet = string.find(sData, sPat, nPos)
        if not nStart then
            table.insert(tRet, tonumber(string.sub(sData, nPos)) or 0)
            break
        else
            table.insert(tRet, tonumber(sGet) or 0)
            nPos = nEnd + 1
        end
    end

    return tRet
end

--普通字符串转Patterns(lua6.4.1)
--给特殊符号添加转义字符使pattern能被正则方法识别
function Str2Pattern(sOrg)
    local magicChars = { '%^', '%%', '%.', '%$', '%(', '%)', '%[', '%]', '%*', '%+', '%-', '%?' }
    local sNew = sOrg
    for _, char in pairs(magicChars) do
        sNew = string.gsub(sNew, char, '%' .. char)
    end
    return sNew
end

---运行代码. string to value
---@param s string Lua代码
---@return any 代码的返回
function Eval(s)
    return assert(load("return " .. (s or "")))()
end

---调试输出变量，使用json.encode
---@param v any 变量
function Dump(v)
    local DoDump

    DoDump = function(vData, tbOut, sIntend)
        local sType = type(vData)
        local sIntendNext = sIntend .. "  "

        if sType == "table" then
            table.insert(tbOut, "{")
            for vKey, vVal in pairs(vData) do
                local tbInner = {}
                DoDump(vVal, tbInner, sIntendNext)
                table.insert(tbOut, sIntendNext .. vKey .. " : " .. table.concat(tbInner, "\n") .. ",")
            end
            table.insert(tbOut, sIntend .. "}")
        elseif sType == "string" then
            return table.insert(tbOut, vData)
        else
            return table.insert(tbOut, tostring(vData))
        end
    end

    local tbLines = {"\n------------ Dump start -------------"}
    DoDump(v, tbLines, "")

    table.insert(tbLines, "------------ Dump End ---------------")
    print(table.concat(tbLines, "\n"), debug.traceback())
end

---调用，防止unpack中断
---@param f function 需要调用的函数
---@param v any 调用使用到的参数
---@return any 返回调用函数本身的返回
function Call(f, v)
    if type(f) ~= "function" then
        error("Call #1 must be function!")
    end

    local bArray, nCount = IsArray(v, false)
    if not bArray then
        return f(v)
    else
        if nCount == 0 then
            return f(v)
        elseif nCount == 1 then
            return f(v[1])
        elseif nCount == 2 then
            return f(v[1], v[2])
        elseif nCount == 3 then
            return f(v[1], v[2], v[3])
        elseif nCount == 4 then
            return f(v[1], v[2], v[3], v[4])
        elseif nCount == 5 then
            return f(v[1], v[2], v[3], v[4], v[5])
        elseif nCount == 6 then
            return f(v[1], v[2], v[3], v[4], v[5], v[6])
        elseif nCount == 7 then
            return f(v[1], v[2], v[3], v[4], v[5], v[6], v[7])
        elseif nCount == 8 then
            return f(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
        elseif nCount == 9 then
            return f(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9])
        else
            error("Too many parameters for Call")
        end
    end
end

---取得当前时间
---@return number Unix时间戳
function GetTime()
    if not me then return os.time() end
    local nTime = me:Now()
    return nTime == 0 and os.time() or nTime
end

---取得编辑器/游戏运行时间
---@return float 单位秒
function GetAccurateRealTime()
    local n, f = UE4.UGameplayStatics.GetAccurateRealTime(GetGameIns())
    return n + f;
end

---日期时间转时间截，YYYYmmdd[HH[MM[SS]]]
---@param s string|number 时间字面表示
---@param tbInfo table 为读取配置表使用(日常游戏中行为不用)，配置表项的table
---@param sKey string 为读取配置表使用(日常游戏中行为不用)，配置表转换的字段key
---@return integer 时间戳
function ParseTime(s, tbInfo, sKey)
    if not s or string.len(s) <= 0 then
        return -1
    elseif not tonumber(s) then
        error("#1 must be datetime string YYYYmmdd[HH[MM[SS]]] like 20160101, 201601010200 etc.")
    end

    local l = string.len(s)
    if l < 8 then
        error("#1 must at least YYYYmmdd")
    end

    local tb = {
        year = tonumber(string.sub(s, 1, 4)),
        month = tonumber(string.sub(s, 5, 6)),
        day = tonumber(string.sub(s, 7, 8)),
        hour = 0,
        min = 0,
        sec = 0
    }

    if l >= 10 then
        tb.hour = tonumber(string.sub(s, 9, 10))
    end
    if l >= 12 then
        tb.min = tonumber(string.sub(s, 11, 12))
    end
    if l >= 14 then
        tb.sec = tonumber(string.sub(s, 13, 14))
    end

    -- 如果还没有登陆，就先缓存起来，登陆之后，刷成服务器时间
    if (not me or not me:IsLogined()) and tbInfo and sKey then
        ZoneTime.RegisterTimeKey(tbInfo,  sKey, tb)
    end

    return os.time(tb)
end

---把形如060200 060259只有时分秒的时间格式转换成包含年月日(当日)的时间截
---@param date string|number 时分秒的字面表示
---@return integer 时间戳
function ParseBriefTime(date)
    local szDate = "0000"
    if date and tonumber(date) then
        szDate = tostring(date)
    end
    local timestr = os.date("%Y%m%d", GetTime()) .. szDate
    return ParseTime(timestr)
end

---判断是否在活动时间内
---@param nStart integer 开始时间Unix时间
---@param nEnd integer 结束Unix时间
---@return boolean 是否在指定时间内
function IsInTime(nStart, nEnd, nNow)
    nNow = nNow or GetTime()
    return (nStart == -1 or nNow >= nStart) and (nEnd == -1 or nNow < nEnd)
end

---计算时间差，以天、时、分、秒的形式返回,如果一个参数都没有则返回空
---@param nTimeA integer Unix时间A
---@param nTimeB integer Unix时间B，比时间点A大或小都行
---@return integer 天
---@return integer 时
---@return integer 分
---@return integer 秒
function TimeDiff(nTimeA, nTimeB)
    if not (nTimeA or nTimeB) then
        return
    end

    local nAfter = nTimeA or 0
    local nBefore = nTimeB or 0
    if nAfter < nBefore then
        nAfter, nBefore = nBefore, nAfter
    end

    local nSec = nAfter - nBefore
    local nDay = math.modf(nSec / (3600 * 24))
    nSec = nSec - (nDay * 3600 * 24)
    local nHour = math.modf(nSec / 3600)
    nSec = nSec - (nHour * 3600)
    local nMin = math.modf(nSec / 60)
    nSec = nSec - (nMin * 60)

    return nDay, nHour, nMin, nSec
end

---获取nTime的下一个(天周月)4点的时间戳
---@param nTime integer Unix时间
---@param nType integer  0 当天的4点  1第二天  2每周一  3每月1号
---@param nAdd integer 增加几天
---@return integer 时间戳
function GetTimeFor4AM(nTime, nType, nAdd)
    nTime = nTime  or GetTime()
    nAdd = nAdd or 0

    local nRefreshTime = 4
    local nDisDay = 0
    local isBefore4 = tonumber(os.date('%H', nTime)) < nRefreshTime
    if nType == 0 then
        return ParseBriefTime("0400")
    elseif nType == 1 then
        if not isBefore4 then
            nDisDay = 1
        end
    elseif nType == 2 then
        local nWeekDay = tonumber(os.date("%w", nTime))
        local nHour = tonumber(os.date("%H", nTime))
        if nWeekDay == 0 then
            nDisDay = 1
        elseif nWeekDay == 1 and nHour < 4 then
            nDisDay = 0
        else
            nDisDay = 8 - nWeekDay
        end
    elseif nType == 3 then
        if tonumber(os.date('%d', nTime)) ~= 1 or not isBefore4 then
            local year  = tonumber(os.date("%Y",nTime))
            local month = tonumber(os.date("%m",nTime))
            if month == 12 then
                year = year + 1
                month = 1
            else
                month = month + 1
            end
            local timestr = tostring(year)..string.format("%02d", month).."010400"
            return ParseTime(timestr) + 86400 * (nDisDay + nAdd)
        end
    else
        return 0
    end

    return ParseBriefTime("0400") + 86400 * (nDisDay + nAdd)
end

---解析配置文件的路径类型
---@param str 原始数据
---@return string[] 返回文件夹列表
function ParsePath(str)
    if not str then
        return {}
    end
    return Split(str, "/")
end

---加载配置表
---@param sPath 文件路径，相对于Content/Settings
---@param nHeader 表头所在行，从0开始
---@return table 数据
function LoadCsv(sPath, nHeader)
    nHeader = nHeader + 1

    local sContent = LoadSetting(sPath)
    if not sContent or sContent == "" then
        return {}
    end

    local tbLine = Split(sContent, "\n")
    local nCount = #tbLine
    if nCount <= nHeader then
        return {}
    end

    local tbKey = Split(tbLine[nHeader], "\t")
    local tbData = {}

    for i = nHeader + 1, nCount do
        local sLine = tbLine[i]
        if (string.len(string.gsub(sLine, " |\t", ""))) > 0 then
            local tbVal = Split(sLine, "\t")
            local tbAtt = {}

            for nCol, sVal in ipairs(tbVal) do
                if tbKey[nCol] then
                    if sVal == "" then
                        tbAtt[tbKey[nCol]] = nil
                    else
                        tbAtt[tbKey[nCol]] = sVal
                    end
                end
            end

            if CountTB(tbAtt) > 0 then
                table.insert(tbData, tbAtt)
            end
        end
    end

    return tbData
end

---解析与等级相关参数，格式可为两种
---@param Data any 支持常量值（如 `123`，`'123'`）或插值，格式：`{{level, value}, ...}`
---@param Level int 等级
---@return number 返回该等级的值
function GetLevelValue(Data, Level)
    if type(Data) == "string" then
        Data = assert(load("return " .. (Data or "")))()
        return GetLevelValue(Data, Level)
    elseif type(Data) == "number" then
        return Data
    elseif type(Data) == "table" then
        table.sort(
            Data,
            function(l, r)
                return l[1] < r[1]
            end
        )

        local LastLevel = 0
        local LastValue = 0

        for _, One in ipairs(Data) do
            if One[1] == Level then
                return One[2]
            elseif One[1] > Level then
                return LastValue + (One[2] - LastValue) * (Level - LastLevel) * 0.1 / (One[1] - LastLevel)
            else
                LastLevel = One[1]
                LastValue = One[2]
            end
        end

        return LastValue
    else
        return 0
    end
end

---移除table中的元素根据键
---@param tbl table
---@param key type(key) 要移除的键
function RemoveElementByKey(tbl, key)
    local tmp = {}
    for i in pairs(tbl) do
        table.insert(tmp, i)
    end
    local newTbl = {}
    local i = 1
    while i <= #tmp do
        local val = tmp[i]
        if val == key then
            table.remove(tmp, i)
        else
            newTbl[val] = tbl[val]
            i = i + 1
        end
    end
    return newTbl
end

---获取本地字串
---@param key string 本地化字串配置的Key
---@param v any 需要格式化时，格式化的第一个参数
---@vararg{} @其他格式化参数
function Text(key, v, ...)
    local sData = Localization.Get(key)
    if v then
        if string.find(sData, "{1}") then
            local ParamArray = UE4.TArray(UE4.FString)
            local tbParam = {v, ...}
            for i = 1, #tbParam do
                ParamArray:Add(tostring(tbParam[i]))
            end
            return UE4.UAbilityLibrary.FormatDescribe(sData, ParamArray)
        else
            return string.format(sData, v, ...)
        end
    else
        return tostring(sData)
    end
end

---根据当前语言获取多语言对象中的内容
---@param sContent string 多语言内容，为json格式，默认读取"default"
---@return string
function LocalContent(sContent)
    local tbContent = nil
    local bSucc = pcall(function() tbContent = json.decode(sContent) end)
    if not (bSucc and tbContent and type(tbContent) == "table") then
        return Text(sContent)
    end

    return Text(tbContent[Localization.GetCurrentLanguage()] or tbContent['default'])
end

---计算文本长度,不同于计算字符串长度，会正确计算变长编码的字符个数
---@param strString string 字符串
---@return integer 返回文本长度
function TextLength(strString)
    if not strString then return 0 end
    local str       = strString
    local lenInByte = #str
    local width     = 0
    local i         = 1;
    while i <= lenInByte do
        local curByte   = string.byte(str, i)
        local byteCount = 1;
        if curByte > 0 and curByte <= 127 then
            byteCount = 1
            width     = width + 1;
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2   
            width     = width + 2;
        elseif curByte >= 224 and curByte <= 239 then
            byteCount = 3 
            width     = width + 2;
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4  
            width     = width + 2;
        end
        i = i + byteCount;
    end
    return width;
end

---截断文本
---@param str string
---@param nLen integer
function CutOffText(str, nLen)
    if not str or not nLen then return str end
    local lenInByte = #str
    local width     = 0
    local i         = 1;
    while i <= lenInByte do
        local curByte   = string.byte(str, i)
        local byteCount = 1;
        local addWidth = 0
        if curByte > 0 and curByte <= 127 then
            byteCount = 1
            addWidth = 1
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2   
            addWidth = 2
        elseif curByte >= 224 and curByte <= 239 then
            byteCount = 3 
            addWidth = 2
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4  
            addWidth = 2
        end

        if width + addWidth > nLen then
            break
        end
        width = width + addWidth
        i = i + byteCount;
    end
    return string.sub(str, 1, i -1);
end

---获取技能名称
---@param nSkillId int 技能ID
---@return string 技能名称
function SkillName(nSkillId)
    if not nSkillId or not (nSkillId > 0) then
        print("nSkillId error ")
        return
    end
    return Localization.GetSkillName(nSkillId)
end

--- 获取QTE技能名
function SkillQTEName(nSkillId)
    if not nSkillId or not (nSkillId > 0) then
        print("nSkillId error ")
        return
    end
    return Localization.GetQTESkillName(nSkillId)
end

function SkillQTEDesc(nSkillId)
    if not nSkillId or not (nSkillId > 0) then
        print("nSkillId error ")
        return
    end
    return Localization.GetQTESkillDesc(nSkillId)
end

---获取技能描述
---@param nSkillId integer 技能ID
---@param arrEnchantIDs TArray<int32> 脊椎点技能ID(可为nil)
---@param InLevel integer 技能等级
---@return string 技能描述
function SkillDesc(nSkillId, arrEnchantIDs, InLevel)
    if not nSkillId or not (nSkillId > 0) then
        print("nSkillId error ")
        return
    end
    -- local tbValue = {}

    local sDesc = Localization.GetSkillDesc(nSkillId)
    local strValueArr = Localization.GetSkillValue(nSkillId)
    if strValueArr then
        local tbParams = UE4.TArray(UE4.FString)
        for subValue in string.gmatch(strValueArr, "%b{}") do
            tbParams:Add(subValue);
        end
        return UE4.UAbilityLibrary.GetSkillDescribe(sDesc , tbParams, InLevel or 1)

        -- local OutValue = UE4.UAbilityLibrary.GetSkillValueForArray(tbParams, InLevel or 1)
        -- if OutValue then
        --     for i = 1, OutValue:Length() do
        --         -- if OutValue:Get(i).bNumber then
        --         --     table.insert(tbValue, tostring(OutValue:Get(i).Value))
        --         -- else
        --             table.insert(tbValue, tostring(OutValue:Get(i).StrValue))
        --         -- end
        --     end
        -- end
    end
    -- local sDesc = Localization.GetSkillDesc(nSkillId)
    -- local pFunc = function()
    --     if #tbValue > 0 then
    --         sDesc = string.format(sDesc, table.unpack(tbValue))
    --     end
    -- end
    -- xpcall(pFunc, function(szErr)
    --     print(string.format("Lua error message 得到技能描述失败，可能需要策划同学看下，技能ID=%d, 错误详情:%s - %s", nSkillId, szErr, debug.traceback()));
    -- end);
    return sDesc
end

function GetLevelName(tbLevelConf)
    if not tbLevelConf then return end
    if tbLevelConf.GetName then return tbLevelConf:GetName() end
    return Text(tbLevelConf.sName)
end

---线性插值
---@param nFrom number 起始值
---@param nTo number 结束值
---@param nPercent number 比例
---@return number 中间值
function Lerp(nFrom, nTo, nPercent)
    return nFrom + (nTo - nFrom) * nPercent
end

---数值处理
---@param nValue float
function TackleDecimal(nValue)
    local a, b = math.modf(nValue)
    if b <= 0 then
        return a
    end
    return nValue
end

--- 数值单位处理
---@param nVlaue number 数值
---@param InUnit string 等单位符号
function TackleDecimalUnit(nVlaue,InUnit,nprecision)
    if not InUnit then
        return math.floor(nVlaue)
    end

    if InUnit == '%' then
        if nprecision then
            local  sType = tostring('%.'..nprecision..'f')
            return string.format(sType, nVlaue)..'%'
        end
        return nVlaue..'%'
    end

    if type(InUnit) == 'number' then
        return string.format('%.'..InUnit..'f', nVlaue)
    end
end

---获得一个32位数中指定位段(0~31)所表示的整数
---@param nInt integer 整数32位
---@param nBegin integer 开始位
---@param nEnd integer 结束位
---@return integer 返回指定位段表示的整数
function GetBits(nInt, nBegin, nEnd)
    if (nBegin > nEnd) then
        local _ = nBegin
        nBegin = nEnd
        nEnd = _
    end
    if (nBegin < 0) or (nEnd >= 32) then
        return 0
    end
    nInt = nInt % (1 << (nEnd + 1))
    nInt = nInt / (1 << nBegin)
    return math.floor(nInt)
end

---在一个32位数中的指定位段(0~31)设置指定整数
---@param nInt integer 整数32位
---@param nBits integer 设置的整数
---@param nBegin integer 开始位
---@param nEnd integer 结束位
---@return integer 返回设置后32位的数
function SetBits(nInt, nBits, nBegin, nEnd)
    if not nBits or not nInt then
        return
    end

    if (nBegin > nEnd) then
        local _ = nBegin
        nBegin = nEnd
        nEnd = _
    end

    nBits = nBits % (1 << (nEnd - nBegin + 1))
    nBits = nBits * (1 << nBegin)
    nInt = nInt % (1 << nBegin) + nInt - nInt % (1 << (nEnd + 1))
    nInt = nInt + nBits
    return nInt
end

--- 比较两个列表，即长度一样且各元素一样
---@param tbA table 第一个列表
---@param tbB table 第二个列表
function CompareList(tbA, tbB)
    if tbA == tbB then
        return true
    end
    local nLen = #tbA
    if nLen ~= #tbB then
        return false
    end
    for i = 1, nLen do
        if tbA[i] ~= tbB[i] then
            return false
        end
    end
    return true
end

---得到文件名
function GetFileNameByPath(path, s)
    if not path then return "" end
    local name = path
    s = s or "/"
    local start = string.find(string.reverse(path), string.reverse(s or "/"))
    if start then 
        name = string.sub(path, string.len(path) - start + 2)
    end
    return name
end

---
--- print log with format
--- @param formatString string
---
function printf(formatString, ...)
    print(string.format(formatString, ...))
end

---
--- print error with format
--- @param formatString string
function printf_e(formatString, ...)
    error(string.format(formatString, ...))
end

--- print msg and traceback
--- @param formatString string
function printf_t(formatString, ...)
    local msg = string.format(formatString, ...);
    local trace = debug.traceback();
    print(msg .. '\n' .. trace)
end

--- 安全调用一个函数
function SafeCall(pFunc)
    xpcall(pFunc, function(szErr)
        print(debug.traceback(szErr));
    end);
end

--取得国际化数字显示
function NumberToString(value)
    if Localization.GetCurrentLanguage() == "zh_CN" then
        if not Login.IsOversea() then
            return tostring(value)
        end
    end

    local num = tonumber(value)
    if not num then return tostring(value) end

    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

---超过nReLen的字符用省略号替换
---@param sText string 字符串
---@param nReLen integer 限制的中文字符长度(英文数字为1 其他中文等为2)
---@return string 返回文本
function ReplaceEllipsis(sText, nReLen)
    if not sText then return sText end

    nReLen = nReLen or 0
    local nLen = 0
    local nSlen = #sText
    local idx = 1
    local nShow = nSlen
    while (idx <= nSlen) do
        local byte = string.byte(sText, idx)
        if nLen < nReLen then
            nShow = idx
        end

        if byte < 128 then
            idx = idx + 1
            nLen = nLen + 1
        elseif byte > 191 and byte < 224 then
            idx = idx + 2
            nLen = nLen + 2
        elseif byte > 223 and byte < 240 then
            idx = idx + 3
            nLen = nLen + 2
        elseif byte > 239 then
            idx = idx + 4
            nLen = nLen + 2
        end
    end

    if nReLen >= nLen then
        return sText
    end

    return (string.sub(sText, 1, nShow-1) .. "...")
end

--检测区域版本
---@param nCoverage integer  标记
---@return bool 参数为空或者匹配时为真
function CheckCoverage(nCoverage)
    if not nCoverage or nCoverage == 0 then
        return true
    elseif nCoverage == 1 and not Login.IsOversea() then
        return true
    elseif nCoverage == 2 and Login.IsOversea() then
        return true
    end

    return false
end

---检测当前网络模式是否是standalone
function CheckStandalone()
    if IsEditor and not UE4.UGameLibrary.IsStandalone(GetGameIns()) then 
        UE4.UGMLibrary.ShowDialog("引擎启动方式错误！", "游戏运行异常，该场景不支持联机，\n请将网络模式修改为【运行Standalone】");
        return false;
    end
    return true
end

--原生转换 有时区问题 一般功能请用ParseTime
---日期时间转时间截，YYYYmmdd[HH[MM[SS]]] 
---@param s string|number 时间字面表示
---@return integer 时间戳
function ParseTimeNative(s)
    if not s or string.len(s) <= 0 then
        return -1
    elseif not tonumber(s) then
        error("#1 must be datetime string YYYYmmdd[HH[MM[SS]]] like 20160101, 201601010200 etc.")
    end

    local l = string.len(s)
    if l < 8 then
        error("#1 must at least YYYYmmdd")
    end

    local tb = {
        year = tonumber(string.sub(s, 1, 4)),
        month = tonumber(string.sub(s, 5, 6)),
        day = tonumber(string.sub(s, 7, 8)),
        hour = 0,
        min = 0,
        sec = 0
    }

    if l >= 10 then
        tb.hour = tonumber(string.sub(s, 9, 10))
    end
    if l >= 12 then
        tb.min = tonumber(string.sub(s, 11, 12))
    end
    if l >= 14 then
        tb.sec = tonumber(string.sub(s, 13, 14))
    end

    return ZoneTime.OldTimeFunc and ZoneTime.OldTimeFunc(tb) or os.time(tb)
end
