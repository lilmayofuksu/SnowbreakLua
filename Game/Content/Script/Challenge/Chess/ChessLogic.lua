-- ========================================================
-- @File    : Challenge/Chess/ChessLogic.lua
-- @Brief   : 棋盘活动逻辑
-- ========================================================

ChessLogic = ChessLogic or {}

ChessLogic.GID              = 12    --GID

ChessLogic.ActId            = 0     --当前开放活动ID
ChessLogic.RewardGet        = 1     --领奖情况 按位存
ChessLogic.MapEnter         = 2     --地图是否进入过
ChessLogic.OpFinish         = 202   --是否看完Op 客户端修改

ChessLogic.FightPassStart   = 10    --战斗通关次数
ChessLogic.FightPassEnd     = 98    --战斗通关次数

ChessLogic.MapDataStart     = 99    --地图数据存储
ChessLogic.MapDataEnd       = 200   --地图数据存储

ChessLogic.MapDataStrStart  = 0     --地图数据存储
ChessLogic.MapDataStrEnd    = 50    --地图数据存储

function ChessLogic.LoadConfig()
    ChessLogic.LoadTimeConf()
    ChessLogic.LoadMapConf()
end

function ChessLogic.LoadTimeConf()
    ChessLogic.tbTimeConf = {}
    local tbFile = LoadCsv('challenge/chess/chess.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local Id = tonumber(tbLine.ID) or 0
        if Id > 0 then
            local tb = {}
            tb.nId = Id
            tb.nBeginTime = ParseTime(string.sub(tbLine['BeginTime'] or '', 2, -2), tb, "nBeginTime")
            tb.nEndTime = ParseTime(string.sub(tbLine['EndTime'] or '', 2, -2), tb, "nEndTime")
            tb.sTitle = tbLine.Title
            tb.nStroy = tonumber(tbLine.Story) or 0
            ChessLogic.tbTimeConf[Id] = tb
        end
    end
    print('challenge/chess/chess.txt')
end

function ChessLogic.LoadMapConf()
    ChessLogic.tbMapConf = {}
    local tbFile = LoadCsv('challenge/chess/chess_map.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local Id = tonumber(tbLine.ID) or 0
        local MapId = tonumber(tbLine.MapId) or 0
        if Id > 0 and MapId > 0 then
            local tb = {}
            tb.nId = Id
            tb.nMapId = MapId
            tb.tbMapResource = Eval(tbLine.MapResource) or {}
            tb.sName = tbLine.Name
            tb.nOp = tonumber(tbLine.OP) or -1
            tb.nUnlockTime = ParseTime(string.sub(tbLine.UnlockTime or '', 2, -2), tb, 'nUnlockTime')
            tb.tbCondition = Eval(tbLine.Condition) or {}
            ChessLogic.tbMapConf[Id] = ChessLogic.tbMapConf[Id] or {}
            ChessLogic.tbMapConf[Id][MapId] = tb
        end
    end
    print('challenge/chess/chess_map.txt')
end

function ChessLogic.IsOpen(ActId)
    return ActId == ChessLogic.GetOpenID()
end

function ChessLogic.GetOpenID()
    return me:GetAttribute(ChessLogic.GID, ChessLogic.ActId)
end

function ChessLogic.GetTimeConf()
    local nActId = me:GetAttribute(ChessLogic.GID, ChessLogic.ActId)
    if nActId ~= 0 then
        return ChessLogic.tbTimeConf[nActId]
    else
        for _, v in ipairs(ChessLogic.tbTimeConf) do
            if IsInTime(v.nBeginTime, v.nEndTime) then
                return v
            end
        end
    end
end

function ChessLogic.GetChessModuleName(activityId)
    local tb = ChessLogic.tbMapConf[activityId]
    if tb and tb[1] and tb[1].tbMapResource then
        return tb[1].tbMapResource[1]
    end
end

function ChessLogic.GetRewardTask()
    return ChessLogic.GID, ChessLogic.MapDataStart, ChessLogic.MapDataEnd
end

function ChessLogic.GetInnerTaskStr()
    return ChessLogic.GID, ChessLogic.MapDataStrStart, ChessLogic.MapDataStrEnd
end

function ChessLogic.GetFightPassTask()
    return ChessLogic.GID, ChessLogic.FightPassStart, ChessLogic.FightPassEnd
end

function ChessLogic.GetMapConf(nId, nMapId)
    if ChessLogic.tbMapConf[nId] then
        return ChessLogic.tbMapConf[nId][nMapId]
    end
end

function ChessLogic.IsOpFinish()
    return me:GetAttribute(ChessLogic.GID, ChessLogic.OpFinish) == 1
end

function ChessLogic.SetOpFinish()
    me:SetAttribute(ChessLogic.GID, ChessLogic.OpFinish, 1)
end

function ChessLogic.CheckOpenAct()
    FunctionRouter.CheckEx(FunctionType.ChessActive, function()
        UI.ShowConnection()
        me:CallGS("ChessLogic_CheckOpenAct")
    end)
end

s2c.Register('ChessLogic_CheckOpenAct', function(tbParam)
    UI.CloseConnection()
    if tbParam and tbParam.bOpen then
        if tbParam.nId and tbParam.nBeginTime and tbParam.nEndTime then
            if not ChessLogic.tbTimeConf[tbParam.nId] then return UI.ShowTip(Text('tip.congif_err')) end
            ChessLogic.tbTimeConf[tbParam.nId].nBeginTime = tbParam.nBeginTime
            ChessLogic.tbTimeConf[tbParam.nId].nEndTime = tbParam.nEndTime
        end
        ChessLogic.EntryMainUI()
    else
        UI.ShowTip(Text("ui.TxtNotOpen"))
    end
end)

function ChessLogic.EnterMap(nId, nMapId)
    local canEnter, tip = ChessLogic.IsMapUnlock(nId, nMapId)
    if not canEnter then return UI.ShowTip(tip) end

    local cmd = {nId = nId, nMapId = nMapId}
    me:CallGS('ChessLogic_EnterMap', json.encode(cmd))
end

s2c.Register('ChessLogic_EnterMap', function(tbParam)
    local nId, nMapId = tbParam.nId, tbParam.nMapId
    local mapConf = ChessLogic.GetMapConf(nId, nMapId)
    if mapConf.nOp > 0 and not ChessLogic.IsMapEnter(nId, nMapId) then
        UI.GetUI("ChessMain"):SetShowOrHide(false)
        UE4.UUMGLibrary.PlayPlot(GetGameIns(), mapConf.nOp, {GetGameIns(), function(lication, CompleteType)
            UI.GetUI("ChessMain"):SetShowOrHide(true)
            ChessClient:LoadMapById(mapConf.tbMapResource[1], mapConf.tbMapResource[2], nId, ChessActivityType.DLC1)
            ChessLogic.CloseMainUI()
        end})
    else
        ChessClient:LoadMapById(mapConf.tbMapResource[1], mapConf.tbMapResource[2], nId, ChessActivityType.DLC1)
        ChessLogic.CloseMainUI()
    end
end)

function ChessLogic.EntryMainUI()
    Launch.SetType(LaunchType.CHESS)
    UI.Open('ChessActivity')
end

function ChessLogic.CloseMainUI()
    UI.Close('ChessActivity')
end

function ChessLogic.IsMapEnter(nId, nMapId)
    if ChessLogic.GetOpenID() ~= nId then return false end
    local val = me:GetAttribute(ChessLogic.GID, ChessLogic.MapEnter)
    return GetBits(val, nMapId, nMapId) == 1
end

function ChessLogic.IsMapPass(nId, nMapId)
    if not ChessLogic.tbMapConf[nId] or not ChessLogic.tbMapConf[nId][nMapId] then
        return false
    end
    local tbConf = ChessLogic.tbMapConf[nId][nMapId]
    return ChessReward:GetMapIsComplete(nId, ChessActivityType.DLC1, tbConf.tbMapResource[2])
end

function ChessLogic.IsMapUnlock(nId, nMapId)
    if not ChessLogic.tbMapConf[nId] or not ChessLogic.tbMapConf[nId][nMapId] then
        return false, Text('tip.congif_err')
    end
    local tbConf = ChessLogic.tbMapConf[nId][nMapId]
    if tbConf.nUnlockTime > 0 and GetTime() < tbConf.nUnlockTime then
        return false, Text('ui.TxtLockTime')
    end
    local bOk, tbLockDes = Condition.Check(tbConf.tbCondition)
    if not bOk then return false, tbLockDes[1] end
    if nMapId > 1 and not ChessLogic.IsMapPass(nId, nMapId - 1) then
        return false, Text('ui.TxtChessTips6')
    end
    return true
end

function ChessLogic._IsMapUnlock(nId, moduleName, mapId)
    if ChessLogic.GetOpenID() ~= nId then return false, Text('tip.congif_err') end
    if not ChessLogic.tbMapConf[nId] then return false, Text('tip.congif_err') end
    local tbConf = nil
    for _, mapInfo in pairs(ChessLogic.tbMapConf[nId]) do
        if mapInfo.tbMapResource[1] == moduleName and mapInfo.tbMapResource[2] == mapId then
            tbConf = mapInfo
            break
        end
    end
    if not tbConf then return false, Text('tip.congif_err') end
    return ChessLogic.IsMapUnlock(nId, tbConf.nMapId)
end

function ChessLogic.HasNew()
    local conf = ChessLogic.GetTimeConf()
    if not conf then return false end
    local tbMaps = ChessLogic.tbMapConf[conf.nId]
    if not tbMaps then return false end
    for _, mapInfo in pairs(tbMaps) do
        if ChessLogic.IsMapUnlock(conf.nId, mapInfo.nMapId) and not ChessLogic.IsMapEnter(conf.nId, mapInfo.nMapId) then
            return true
        end
    end
    return false
end


function ChessLogic.GMOpenAllMap()
    local nId = ChessLogic.GetOpenID()
    if nId == 0 then return end
    for _, mapInfo in pairs(ChessLogic.tbMapConf[nId]) do
        mapInfo.nUnlockTime = 0
    end
end

ChessLogic.LoadConfig()