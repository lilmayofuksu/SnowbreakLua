-- ========================================================
-- @File    : Condition.lua
-- @Brief   : 条件判断
-- ========================================================
---@class Condition
Condition  = Condition or {tbCheckFun = {}, tbTaskFun={}}

Condition.ACCOUNT_LEVEL  = 1 ---账号等级
Condition.PRE_LEVEL      = 2 ---前置关卡
Condition.ACTIVE_ITEM    = 3 ---获得道具
Condition.DAILY_PRE_LEVEL= 4 ---日常前置关卡
Condition.ONLINE_TIMES   = 5 ---联机关卡参加次数
Condition.ROLE_LEVEL     = 6 ---指定角色的等级
Condition.ROLE_NERVE_STATE   = 7 ---指定角色的神经激活情况
Condition.LOGIN_DAYS     = 8 ---玩家累计登陆天数
Condition.LEVEL_SPECIAL_OPEN     = 9 ---指定关卡的功能开发 :当前关卡通关后开启，未通关则只有当前关卡开启


---条件核对 
---@param tbCondition table 条件 {1, 10}
function Condition.Check(tbCondition, bAllResule)
    if tbCondition == nil or #tbCondition == 0 then return true end
    local bOk = true
    local tbLockDes = {}
    local tbAllResule = {}
    for _, tbInfo in ipairs(tbCondition) do
        local nType = tbInfo[1]
        if Condition.tbCheckFun[nType] then
            local bPass, sDes = Condition.tbCheckFun[nType](table.unpack(tbInfo, 2, #tbInfo))
            bOk = bPass and bOk
            if not bPass then
                table.insert(tbLockDes, sDes)
            end
            if bAllResule then table.insert(tbAllResule, bPass) end
        end
    end
    return bOk, tbLockDes, tbAllResule
end

---单个条件核对 
function Condition.CheckCondition(con)
    if con == nil or #con == 0 then return true end
    local nType = con[1]
    if Condition.tbCheckFun[nType] then
        return Condition.tbCheckFun[nType](table.unpack(con, 2, #con))
    end
    return false
end

---返回task
---@param tbCondition table 条件 {1, 10}
function Condition.GetTask(tbCondition)
    if tbCondition == nil or #tbCondition == 0 then return end
    for _, tbInfo in ipairs(tbCondition) do
        local nType = tbInfo[1]
        if Condition.tbTaskFun[nType] then
            return Condition.tbTaskFun[nType](table.unpack(tbInfo, 2, #tbInfo))
        end
    end
end

---账号等级
local function CheckAccountLevel(nLevel)
    return me:Level() >= nLevel , string.format(Text('chapter.condition_' .. Condition.ACCOUNT_LEVEL), nLevel)
end
Condition.tbCheckFun[Condition.ACCOUNT_LEVEL] = CheckAccountLevel

---前置关卡是否通关
local function CheckPreLevelPass(nLevelID)
    --- 联机模式无法进行检查采用,默认通过
    if me == nil then
        return true;
    end
    local nPassTime = me:GetAttribute(Launch.GPASSID, nLevelID) or 0
    local str = "chapter.level_"
    if Launch.GetType() == LaunchType.ROLE then
        str = "role.level_"
    elseif Launch.GetType() == LaunchType.DLC1_CHAPTER then
        str = "chapter.Dlc1_levelname_"
    end

    local name = ""
    if Launch.GetType() ~= LaunchType.DLC1_CHAPTER then
        name = string.gsub(Text(str .. nLevelID), '_', '-')
        if nLevelID >= 20000 and nLevelID < 29999 then
            name = Text('ui.TxtHard') .. name
        end
    else
        name = Text(str .. nLevelID)
    end

    return nPassTime > 0 , string.format(Text('chapter.condition_' .. Condition.PRE_LEVEL), name)
end
Condition.tbCheckFun[Condition.PRE_LEVEL] = CheckPreLevelPass

---是否拥有道具
local function CheckActiveItem(g, d, p, l)
    if not g or not d or not p or not l then
        return false, Text("ui.TxtNotOpen")
    end
    local iteminfo = UE4.UItem.FindTemplate(g, d, p, l)
    return me:GetItemCount(g, d, p, l) > 0, Text('ui.TxtRoleLock', Text(iteminfo.I18N))
end
Condition.tbCheckFun[Condition.ACTIVE_ITEM] = CheckActiveItem

---日常前置关卡是否通关
local function CheckDailyPreLevelPass(nLevelID)
    local nPassTime = me:GetAttribute(Launch.GPASSID, nLevelID) or 0
    local str = "chapter.level_"
    return nPassTime > 0 , string.format(Text('chapter.condition_' .. Condition.DAILY_PRE_LEVEL), Text(str .. nLevelID))
end
Condition.tbCheckFun[Condition.DAILY_PRE_LEVEL] = CheckDailyPreLevelPass

---联机关卡参加次数
local function CheckOnline(nTimes)
    return Online.GetFightNum() >= nTimes
end
Condition.tbCheckFun[Condition.ONLINE_TIMES] = CheckOnline


---指定角色等级判断
local function CheckRoleLevel(g, d, p, l, nLevel)
    if not g or not d or not p or not l or not nLevel then return false end
    local all = me:GetItemsByGDPL(g, d, p, l)
    if all:Length() <= 0 then return false end
    local pItem = all:Get(1)
    if not pItem then return false end
    return pItem:EnhanceLevel() >= nLevel, string.format(Text("ui.TxtRoleLevel"), nLevel)
end
Condition.tbCheckFun[Condition.ROLE_LEVEL] = CheckRoleLevel

---判断特定角色的神经激活情况
local function CheckRoleNerveState(g, d, p, l, x)
    if not g or not d or not p or not l or not x then return false end
    local all = me:GetItemsByGDPL(g, d, p, l)
    if all:Length() <= 0 then return false end
    local pItem = all:Get(1)
    if not pItem then return false end
    local allNode = pItem:GetAllActiveSpineNode(true)
    return allNode:Length() >= x, string.format(Text("ui.TxtRoleSpine"), x)
end
Condition.tbCheckFun[Condition.ROLE_NERVE_STATE] = CheckRoleNerveState

---判断玩家登陆天数
local function CheckLoginDays(nDays)
    local nLogin = me:GetAttribute(99, 3) or 0
    return nLogin >= nDays
end
Condition.tbCheckFun[Condition.LOGIN_DAYS] = CheckLoginDays

---特殊关卡对应功能开放判断
local function CheckSpecialLevel(nLevelID)
    if not nLevelID or not me then return false end
    local nPassTime = me:GetAttribute(Launch.GPASSID, nLevelID) or 0
    ---通关则开放
    if nPassTime > 0 then return true end

    return (nLevelID == Launch.GetLevelID())
end
Condition.tbCheckFun[Condition.LEVEL_SPECIAL_OPEN] = CheckSpecialLevel


------------针对DS接口
---特殊关卡对应功能开放判断
local function GetSpecialLevel(nLevelID)
    if type(nLevelID) ~=  "number" or nLevelID <= 0 then return end
    return Launch.GPASSID, nLevelID
end
Condition.tbTaskFun[Condition.LEVEL_SPECIAL_OPEN] = GetSpecialLevel
