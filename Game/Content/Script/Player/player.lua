-- ========================================================
-- @File    : player.lua
-- @Brief   : 账号相关接口
-- ========================================================

Player = {
    tbLevelCfg = {},
    tbNameCfg = {},
    tbMultipleCfg = {},
    tbMoppingUpCfg = {},
    tbSetting = {},
    tbRenameCfg = {},
}

---获取取名消耗配置
---@param nTimes number 取名次数
function Player.GetRenameCfg(nTimes)
    local cfg = Player.tbRenameCfg[nTimes]
    if not cfg then
        return Player.tbRenameCfg[#Player.tbRenameCfg]
    end
    return cfg
end


--- 随机一个名字
function Player.RandomName()
    local nFst = math.random(#Player.tbNameCfg.tbFstName)
    local nSec = math.random(#Player.tbNameCfg.tbSecName)
    local sFst = Player.tbNameCfg.tbFstName[nFst]
    local sSec = Player.tbNameCfg.tbSecName[nSec]
    return sFst .. sSec
end

---获得对应等级需要的经验值
---@param nLevel Interger 账号等级
---@return Integer 最大经验值
function Player.GetMaxExp(nLevel)
    return Player.tbLevelCfg[nLevel] and Player.tbLevelCfg[nLevel].nMaxExp or 0
end

---获得对应等级好友上限
---@param nLevel Interger 账号等级
---@return Integer 好友上限
function Player.GetMaxFriends(nLevel)
    return Player.tbLevelCfg[nLevel] and Player.tbLevelCfg[nLevel].nMaxFriends or 0
end

---获得对应等级体力上限
---@param nLevel Interger 账号等级
---@return Integer 好友上限
function Player.GetMaxVigor(nLevel)
    return Player.tbLevelCfg[nLevel] and Player.tbLevelCfg[nLevel].nMaxVigor or 0
end

---获取关卡类型的倍率列表
---@return table 倍率列表
function Player.GetMultipleList(nLaunchType)
    if not nLaunchType then return end

    return Player.tbMultipleCfg[nLaunchType]
end

---获取关卡类型的倍率配置
function Player.GetMultipleConfig(nLaunchType, nMultiple)
    local tbList = Player.GetMultipleList(nLaunchType)
    if not tbList then return end

    for i,v in ipairs(tbList) do
        if nMultiple and v.nMultiple == nMultiple then
            return v
        end
    end
end

---获取关卡类型的扫荡配置
---@return table 扫荡配置
function Player.GetMoppingUpConfig(nLaunchType)
    if not nLaunchType then return end

    return Player.tbMoppingUpCfg[nLaunchType]
end

--根据服务器参数判定
function Player.IsOversea()
    return Player.tbSetting.LANGUAGE ~= 'zh_CN'
end

---获取最大名字长度
function Player.GetMaxNameNum()
    return 12
end

---检查输入
function Player.CheckInputName(sInput)
    if sInput == nil or sInput == '' then
        return false, 'ui.TxtEditNameTip'
    end
    local nMax = Player.GetMaxNameNum()
    local nLength = TextLength(sInput)
    if  nLength > nMax then
        return false, string.format('ui.TxtEditSignatureTip5', nMax)
    end
    if Login.IsOversea() == false then
        local nFindIdx = string.find(sInput, ' ')
        if nFindIdx then
            return false, 'tip.402'
        end

        local bMatch = UE4.UGameLibrary.RegexMatch(sInput, "^[\\u30A1-\\u30FF\\u3041-\\u309F\\u4E00-\\u9FA5A-Za-z0-9]+$")
        if not bMatch then
            return false, 'tip.402'
        end
    end
    return true
end

-----------------------------
EventSystem.On(Event.LevelUp, function(nNewLevel, nOldLevel)
    UE4.UGameLibrary.ReportLevelUp();
end)

EventSystem.On(Event.Kickout, function(sMsg)
    --删除关卡结算事件
    Launch.PreEnd()
    if sMsg and #sMsg > 0 then
        Online.AllowAutoConnection = false;
        Reconnect.ReleaseFightInput()
        UE4.UUMGLibrary.PausePlot()

        if Online.GetOnlineState() > Online.STATUS_ENTER and Map.GetCurrentID() ~= 2 then --联机里?
           if Map.GetCurrentID ~= 2 then
                local Controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
                if Controller then
                    Controller:ClearAllKeyboardInput()
                end
            end
            Player.DSError = 'tip.' .. sMsg
        end

        UI.OpenByType("MessageBox", UE4.EUIType.Top, Text('tip.' .. sMsg), function() Player.DSError = nil; GoToLoginLevel() end, 'Hide');
    else
        GoToLoginLevel();
    end
    UE4.UGameLibrary.RequestLogout()
end)

EventSystem.On(Event.LogOutCallBack, function(code, sData)
    print('=================>', code, sData)
end)

---加载等级设置
local function LoadLevelConfig()
    local tbFile = LoadCsv("player/levels.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nLevel = tonumber(tbLine.Level)
        if nLevel then
            local tbInfo = {
                nMaxExp = tonumber(tbLine.MaxExp),
                nMaxVigor = tonumber(tbLine.MaxVigor),
                nMaxFriends = tonumber(tbLine.MaxFriends),
                nFunctionID = tonumber(tbLine.FunctionID),
                nGainVigor = tonumber(tbLine.GainVigor) or 0,
            }
            Player.tbLevelCfg[nLevel] = tbInfo
        end
    end
    print("Load ../settings/palyer/levels.txt")
end

---加载随机命名表
local function LoadNameConfig()
    local tbFile = LoadCsv("player/name.txt", 1)
    Player.tbNameCfg.tbFstName = {}
    Player.tbNameCfg.tbSecName = {}
    for _, tbLine in ipairs(tbFile) do
        local sFst = tbLine.FstName
        local sSec = tbLine.SecName
        if sFst and #sFst > 0 then table.insert(Player.tbNameCfg.tbFstName, sFst) end
        if sSec and #sSec > 0 then table.insert(Player.tbNameCfg.tbSecName, sSec) end
    end
end

---加载多倍收益配置表
function Player.LoadMultipleIncome()
    local tbFile = LoadCsv("player/multipleincome.txt", 1)
    Player.tbMultipleCfg = {}
    for _, tbLine in ipairs(tbFile) do
        local nLevelType       = tonumber(tbLine.LevelType)
        local nMultiple       = tonumber(tbLine.Multiple)
        if nLevelType and nMultiple then
            local tbData = Player.tbMultipleCfg[nLevelType]
            if not tbData then 
                Player.tbMultipleCfg[nLevelType] = {}
                tbData = Player.tbMultipleCfg[nLevelType]
            end

            local tbInfo = {}
            tbInfo.nLevelType = nLevelType
            tbInfo.nMultiple = nMultiple
            tbInfo.tbCondition = Eval(tbLine.Condition) or {},
            table.insert(tbData, tbInfo)
        end
    end

    for _, tbData in pairs(Player.tbMultipleCfg) do
        table.sort(tbData, function (l, r) return l.nMultiple < r.nMultiple; end);
    end
end

---加载扫荡配置表
function Player.LoadMoppingUp()
    local tbFile = LoadCsv("player/moppingup.txt", 1)
    Player.tbMoppingUpCfg = {}
    for _, tbLine in ipairs(tbFile) do
        local nLevelType       = tonumber(tbLine.LevelType)
        local nMultiple       = tonumber(tbLine.Multiple)
        if nLevelType and nMultiple then
            local tbInfo = {}
            tbInfo.nLevelType = nLevelType
            tbInfo.nMultiple = nMultiple
            tbInfo.tbCondition = Eval(tbLine.Condition) or {}
            Player.tbMoppingUpCfg[nLevelType] = tbInfo
        end
    end
end

---加载重命名消耗表
function Player.LoadRenameCfg()
    local tbFile = LoadCsv("player/rename.txt", 1)
    Player.tbRenameCfg = Player.tbRenameCfg or {}
    for _, tbLine in ipairs(tbFile) do
        local nTimes      = tonumber(tbLine.Times)
        if nTimes then
            Player.tbRenameCfg[nTimes] = {
                nType = tonumber(tbLine.Type) or 2,
                nNum = tonumber(tbLine.Num) or 0,
            }
        end
    end
end

local function LoadConfig()
    LoadLevelConfig()
    LoadNameConfig()
    Player.LoadMultipleIncome()
    Player.LoadMoppingUp()
    Player.LoadRenameCfg()
end

LoadConfig()

--- 每日状态更新的回调
s2c.Register(
    "Player_OnDaily",
    function()
        EventSystem.Trigger(Event.ServerNextDay)
        Sign.tbSignState = {}
    end
)

s2c.Register('SettingControl',function(tbParam)
    Player.tbSetting = tbParam
end)

EventSystem.On(Event.Rename, function(err)
    if not err or err ~= 0 then return end
    if not me or me:Id() == 0 then return end
    
    if me:GetAttribute(99, 6) == 0 and UE4.UGameLibrary.SDKRename then --第一次起名
        UE4.UGameLibrary.SDKRename()
        print("Player First Rename")
    end
end)
