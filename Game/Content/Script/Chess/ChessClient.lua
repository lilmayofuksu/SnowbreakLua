----------------------------------------------------------------------------------
-- @File    : ChessClient.lua
-- @Brief   : 棋盘客户端相关 【客户端】
-- 客户端流程控制相关
----------------------------------------------------------------------------------

require "Chess.ChessConfig"
require "Chess.ChessReward"
require "Chess.ChessData"
require "Chess.ChessTools"
require "Chess.ChessEditor"
require "Chess.ChessEvent"
require "Chess.Object.ChessObject"
require "Chess.Task.ChessTask"
require "Chess.Task.ChessTaskCondition"
require "Chess.Task.ChessTaskEventAction"
require "Chess.Task.ChessTaskCompleteCondition"
require "Chess.DataHandler.ChessConfigHandler"
require "Chess.DataHandler.ChessRuntimeHandler"

---@class ChessClient 棋盘客户端相关接口
ChessClient = ChessClient or {}

-- 棋盘活动类型
ChessActivityType = {}
ChessActivityType.DLC1          = 1 -- dlc1

ChessClient.GID                 = 12    -- GID
ChessClient.CurrentActType      = 201   -- 记录当前活动类型

----------------------------------------------------------------------------------

function ChessClient.GetCurActType()
    return me:GetAttribute(ChessClient.GID, ChessClient.CurrentActType)
end

--- 设置游戏模式
function ChessClient:SetGameMode(gameMode)
    self.gameMode = gameMode
end

---清空所有数据
function ChessClient:ClearAllData()
    self.mapBuilder = nil
    self.gameMode = nil
    ChessConfigHandler:ClearAllData()
    ChessRuntimeHandler:ClearAllData()
    ChessData:ClearAllData()
end

-- 返回上次进入地图
function ChessClient:ReturnMap(pCall)
    self.bReturn = true
    if self.nextModuleName and self.nextMapId and self.activityId and self.activityType then
        self:LoadMapById(self.nextModuleName, self.nextMapId, self.activityId, self.activityType, pCall)
    end
    self.bReturn, self.bFightReturn = false, false
end

--- 通过模块ID和地图ID 加载3D地图
---@param moduleName 模块名
---@param mapId 地图id
---@param activityId 活动id
---@param activityType 活动类型（不同类型对应不同的manager）
function ChessClient:LoadMapById(moduleName, mapId, activityId, activityType, pCall)
    self.activityId = activityId
    self.activityType = activityType
    self.mapId = mapId
    local tbMapData;
    local tbMapList = ChessConfig:GetMapListByModuleName(moduleName)
    for _, tb in ipairs(tbMapList) do 
        if tb.Id == mapId then 
            tbMapData = tb;
            break
        end
    end
    if not tbMapData then return ChessTools:ShowTip("map data is null.", true) end

    local artMapId = ChessConfig:GetArtMapId(moduleName, mapId)
    if artMapId <= 0 then 
        artMapId = Map.ChessMapId
    end

    if Map.GetCurrentID() == artMapId then 
        self:LoadMapByMapData(moduleName, tbMapData, mapId)
        if pCall then pCall() end
    else 
        self.nextModuleName = moduleName
        self.nextMapId = mapId
        if not self.bFightReturn then
            UI.SnapShoot()
        end
        Map.Open(artMapId, nil, pCall)
    end
end

---通过地图配置数据加载3D地图
---@param moduleName 模块名
---@param tbMapConfigData 配置数据
---@param mapId 地图id
---@param initRegionId 初始区域ID
function ChessClient:LoadMapByMapData(moduleName, tbMapConfigData, mapId, initRegionId)
    print("LoadMapByMapData", moduleName, mapId, initRegionId)
    if not moduleName then return end
    EventSystem.Trigger(Event.NotifyBeginLoad3DChess)
    self.mapBuilder = self.gameMode.MapBuilder;
    self.tbMapConfigData = tbMapConfigData
    self.moduleName = moduleName
    self.mapId = mapId
    ChessData:SetMapId(moduleName, mapId, self.activityId, self.activityType)
    ChessConfigHandler:InitData(tbMapConfigData)
    ChessRuntimeHandler:InitData(tbMapConfigData)
    ChessClient:OpenUI()
    ChessTask:InitData()

    -- 初始化区域信息
    local tbRegionParam = {}
    if not initRegionId then 
        local regionId, gridId, rotate = ChessData:GetPlayerPos()
        if regionId > 0 then 
            initRegionId = regionId
            local posX, posY = ChessTools:GridIdToXY(gridId)
            tbRegionParam = {posX = posX, posY = posY, rotate = rotate}
        else 
            initRegionId = 1
        end
    end

    -- 基础设置
    self.gameMode:ResetMap(moduleName);
    self.gameMode.FogManager:ClearAll();
    self.gameMode.PathFindingType = ChessRuntimeHandler:GetPathType()
    self.gameMode.PlayerController:SetScale(ChessRuntimeHandler:GetCharacterScale())
    self.gameMode.HasEvent = false;
    
    -- 构建3D逻辑地图
    local regionCount = ChessRuntimeHandler:GetRegionCount()
    for regionId = 1, regionCount do 
        local tbRegion = ChessRuntimeHandler:GetRegionData(regionId);
        local x, y, z = table.unpack(ChessRuntimeHandler:GetRegionPosition(tbRegion))
        local location = UE4.FVector(x or 0, y or 0, z or 0) * 100;
        local rotation = ChessRuntimeHandler:GetRegionRotation(tbRegion)
        local regionActor = self.mapBuilder:CreateRegion(regionId, location, rotation)
        
        ChessRuntimeHandler:ForeachRegionGround(tbRegion, function(id, tbGroundData)
            local x, y = ChessTools:GridIdToXY(id)
            local objId = ChessRuntimeHandler:GetGroundCfgId(tbGroundData)
            local height = ChessRuntimeHandler:GetGroundHeight(tbGroundData)
            local actor = regionActor:SetRegionGround(id, x, y, objId, height, 1)
            ChessRuntimeHandler:SetGroundActor(tbGroundData, actor)
        end) 
        
        ChessRuntimeHandler:ForeachRegionObject(tbRegion, function(id, tbObjectData)
            local x, y = ChessRuntimeHandler:GetObjectPosition(tbObjectData)
            local tplId = ChessRuntimeHandler:GetObjectCfgId(tbObjectData)
            local angle = ChessRuntimeHandler:GetObjectRotation(tbObjectData)
            local height = ChessRuntimeHandler:GetObjectHeight(tbObjectData)
            local actor = regionActor:SetRegionObject(id, x, y, tplId, angle, height, 1)
            ChessRuntimeHandler:SetObjectActor(tbObjectData, actor)
            if tbObjectData.classHandler and tbObjectData.classHandler.CanReward and tbObjectData.classHandler:CanReward() == false then
                if tbObjectData.cfg.tbData.id then
                    ChessData:SetObjectIsUsed(tbObjectData.cfg.tbData.id[1])
                end
                ChessRuntimeHandler:SetTargetActive(tbObjectData, false)
            end
        end) 
        
        local min = ChessRuntimeHandler:GetRegionMinPos(tbRegion)
        local max = ChessRuntimeHandler:GetRegionMaxPos(tbRegion)
        regionActor:SetRegionSize(min.x, min.y, max.x, max.y)
        for i = 1, ChessData.RegionMaxViewTaskIndex do 
            local value = ChessData:GetRegionViewValue(regionId, i)
            if value == 0 then -- 此处有漏洞，如果刚好在0，0点有个迷雾，这里会判断失效
                break;
            end
            local gridMin = GetBits(value, 0, 15)
            local gridMax = GetBits(value, 16, 31)
            local minX, minY = ChessTools:GridIdToXY(gridMin);
            local maxX, maxY = ChessTools:GridIdToXY(gridMax)
            regionActor:AddViewRegion(minX, minY, maxX, maxY);
        end
        regionActor:UpdatePathFinding()

        ChessRuntimeHandler:ForeachRegionObject(tbRegion, function(id, tbObjectData)
            if tbObjectData.actor and tbObjectData.actor:HasTag("ShowOutline") and not regionActor:CheckObjectUnderFog(tbObjectData.actor) then
                UE4.UPostProcessUtils.AddExplosive(tbObjectData.actor)
            end
        end) 
        -- regionActor:RefreshFog()
    end

    -- 构建3D美术地图
    -- local tbArtDef = ChessConfig:GetArtMap(moduleName, mapId) 
    -- for _, data in ipairs(tbArtDef.art_list or {}) do 
    --     local path = tbArtDef.art_ids[data.id]
    --     local location = UE4.FVector(table.unpack(data.pos))
    --     local rotator = UE4.FRotator(table.unpack(data.rotate))
    --     local scale = UE4.FVector(table.unpack(data.scale))
    --     self.mapBuilder:SpawnArtActor(path, location, rotator, scale)
    -- end

    self.gameMode.CameraFollow:ResetCamera()

    local tbParam = ChessConfig:GetModuleParams(moduleName)
    self.gameMode.PlayerController.RunGridCount = tbParam.RunGridCount or 3
    self.gameMode.PlayerController.MaxRunSpeed = tbParam.MaxRunSpeed or 300
    self.gameMode.PlayerController.MaxWalkSpeed = tbParam.MaxWalkSpeed or 150

    ChessEvent:SetMapData(tbMapConfigData)
    if ChessData:GetIsFirstEntry() then 
        ChessData:SetIsFirstEntry()
        ChessTask:OnGameInit()
        ChessEvent:OnGameInit()
        ChessRuntimeHandler:OnFirstEntry()
    end
    ChessEvent:OnGameStart()
    UE.Timer.NextFrame(function()
        self:GotoRegion(initRegionId, tbRegionParam)
    end)

    -- 检测奖励配置
    ChessReward:GetRewardsByModuleName(moduleName)
end

-- 加载 art 地图
function ChessClient:LoadArtMap()
    local mapId = ChessConfig:GetArtMapId(self.moduleName, self.mapId)
    if mapId <= 0 then return end

    if Map.GetCurrentID() == mapId then return end
    Map.Open(mapId)
end

--- 打开相关UI
function ChessClient:OpenUI()
    if not UI.IsOpen("ChessMain") then 
        UI.Open("ChessMain")
    end

    if GM.IsOpenUI() then 
        if not UI.IsOpen("ChessMap") then 
            UI.Open("ChessMap")
        end

        if ChessEditor and ChessEditor:CheckHasData() then 
            UI.GetUI("ChessMap"):HideChessMap()
        end
    end
end

--- 前往区域
function ChessClient:GotoRegion(regionId, tbParam)
    if not regionId then return end
    self.gameMode.PlayerController:ResetChessState()
    local region = self.gameMode.MapBuilder:FindRegion(regionId);
    if not region and regionId > 1 then 
        return self:GotoRegion(1)
    end
    local character = self.gameMode.PlayerController:GetCurrentChar()
    local hasInitPos = false
    if tbParam and tbParam.posX then 
        local actor = region:FindGroundActor(tbParam.posX, tbParam.posY)
        if actor then 
            hasInitPos = true;
            region:AddPlayer(character, actor)
            character:K2_SetActorRotation(UE4.FRotator(0, tbParam.rotate or 0, 0))
        end
    end
    if not hasInitPos then 
        local actors = region:FindAllActorsByConfigTag("start") 
        if actors:Length() > 0 then 
            region:AddPlayer(character, actors:Get(1))
        end
    end
    ChessEvent:OnEntryRegion(regionId)
    ChessClient:UpdateRegionPathFinding()
    self.gameMode.CameraFollow:RefreshCameraRange(ChessRuntimeHandler:GetRegionMinPos(tbParam), ChessRuntimeHandler:GetRegionMaxPos(tbParam))
    if self.gameMode.FogManager then
        self.gameMode.FogManager:InitFog()
    end
end

function ChessClient:StopMovementImmediately()
    self.gameMode.PlayerController:StopMovementImmediately()
end

--- 得到当前区域ID
function ChessClient:CurrentRegionId()
    return self:GetPlayerCharacter():GetRegionId()
end

--- 在区域内部传送
function ChessClient:TransferInRegion(actor)
    local region = self.gameMode.MapBuilder:FindRegion(self:CurrentRegionId());
    if not region then 
        print("TransferInRegion", self:CurrentRegionId(), debug.traceback());
        return 
    end
    self.gameMode.PlayerController:ResetChessState()
    local character = self.gameMode.PlayerController:GetCurrentChar()
    region:AddPlayer(character, actor)
end

--- 是不是UI模式，UI模式下场景不可互动
function ChessClient:SetIsUIMode(value)
    self.gameMode.PlayerController.IsUIMode = value
end

--- 是不是特殊移动模式 特殊移动模式先走过去在弹Tips
function ChessClient:SetShowTipsAfterMoveTo(value)
    self.gameMode.PlayerController.ShowTipsAfterMoveTo = value
end

--- 设置当前正在交互的Actor 
function ChessClient:SetInteractionActor(actor)
    self.gameMode.PlayerController.InteractionActor = actor
end

--- 是否正在交互中
function ChessClient:CheckInteraction()
    return self:GetPlayerCharacter():CheckInteraction()
end

function ChessClient:SetDataDirty()
    self.gameMode.ChessDataDirty = true;
end

----------------------------------------------------------------------------------
--- 得到区域信息，默认当前
function ChessClient:GetRegionData(id)
    id = id or self:CurrentRegionId()
    return self.tbMapConfigData.tbData.tbRegions[id]
end

--- 得到主角角色 
function ChessClient:GetPlayerCharacter()
    return self.gameMode.PlayerController:GetCurrentChar();
end

--- 得到主角控制器
function ChessClient:GetPlayerController()
    return self.gameMode.PlayerController;
end

--- 得到当前区域Actor 
function ChessClient:GetRegionActor(id)
    id = id or self:CurrentRegionId()
    return self.gameMode.MapBuilder:FindRegion(id);
end

--- 得到当前所有道具定义
function ChessClient:GetItemDef() 
    return ChessConfig:GetItemDefineByModuleName(self.moduleName) 
end

--- 查找物件
function ChessClient:GetObjectByTypeId(regionId, type, id)
    local tbRegion = self:GetRegionData(regionId)
    if tbRegion then 
        if type == "grid" then 
            return tbRegion.tbGround[id]
        elseif type == "object" then 
            return tbRegion.tbObjects[id]
        end
    end
end

--- 更新区域导航寻路
function ChessClient:UpdateRegionPathFinding(id)
    id = id or self:CurrentRegionId()
    local regionActor = self.mapBuilder:FindRegion(id) 
    if regionActor then 
        regionActor:UpdatePathFinding()
    end
end

--- 得到格子定义
function ChessClient:GetGridDef(id)
    local tbGrids = ChessConfig:GetGridDefineByModuleName(self.moduleName)
    return tbGrids.tbId2Data[id] 
end

-- 得到特效定义
function ChessClient:GetParticleDef(id)
    local tbDef = ChessConfig:GetParticleDefineByModuleName(self.moduleName)
    return id and tbDef.tbId2Data[id] or nil
end

-- 得到动画定义
function ChessClient:GetSequenceDef(id)
    local tbDef = ChessConfig:GetSequenceDefineByModuleName(self.moduleName)
    return tbDef.tbId2Data[id]
end

-- 得到npc定义
function ChessClient:GetNpcDef(id)
    local tbDef = ChessConfig:GetNpcDefineByModuleName(self.moduleName)
    return tbDef.tbId2Data[id]
end

--- 通知战斗结束
function ChessClient:NotifyFightSuccess(tbParam)
    local regionId = tbParam.regionId
    local objId = tbParam.id
    local type = tbParam.type
    local tbRegion = ChessRuntimeHandler:GetRegionData(regionId)
    if not tbRegion then return end
    local target = type == 1 and tbRegion.tbGround[objId] or tbRegion.tbObjects[objId]
    if target then 
        ChessObject:HideObject(target)
        ChessObject:NotifyObjectComplete(target)
        ChessClient:SetDataDirty()
    end
end

function ChessClient:PlayCameraShow(InTarget)
    if self.gameMode.CameraFollow then
        self.gameMode.CameraFollow:SetCameraShowTarget(InTarget)
    end
end

function ChessClient:GetLockControl()
    if self.gameMode.CameraFollow then
        return self.gameMode.CameraFollow:GetLockControl()
    end
end

function ChessClient:SetLockControl(bLock)
    if self.gameMode.CameraFollow then
        return self.gameMode.CameraFollow:SetLockControl(bLock)
    end
end
----------------------------------------------------------------------------------
--- 得到关卡id
function ChessClient.GetLevelID()
    return ChessClient.LevelId
end

function ChessClient.GetFightID()
    return ChessClient.FightId
end

--- 开始战斗
function ChessClient:BeginFight(fightId, tbParam)
    Launch.SetType(LaunchType.CHESS)
    local cfg = ChessConfig:GetFightDefineByMoudleName(self.moduleName).tbId2Data[fightId]
    assert(cfg, string.format("关卡id=%d不存在", fightId))
    self.LevelId = cfg.nLevelId
    self.FightId = fightId
    self.FightParam = tbParam
    Map.Open(2, nil, function()
        UI.Open("Formation", cfg.nLevelId, false, cfg)
    end)
end

-- 请求进入关卡
function ChessClient.Req_EnterLevel(activityId, activityType, fightId)
    if ChessClient.bReqEnter then return end
    local levelcfg = ChessConfig:GetFightDefineByMoudleName(ChessClient.moduleName).tbId2Data[fightId]
    if not levelcfg then return end
    local levelid = string.format('%d-%d-%d', activityType, activityId, levelcfg.nLevelId)

    local tbLog = {}
    tbLog['LevelEnter'] = LaunchLog.LogLevelEnter(LaunchType.CHESS, levelid)

    ChessClient.bReqEnter = true
    local cmd = {activityId = activityId, activityType = activityType, moduleName = ChessClient.moduleName,
    fightId = fightId, nTeamID = Formation.GetCurLineupIndex(), tbLog = tbLog}
    me:CallGS('Chess_EnterLevel', json.encode(cmd))
end

---注册进入关卡的回调
s2c.Register('Chess_EnterLevel', function(tbRet)
    ChessClient.bReqEnter = false
    ChessClient.nSeed = tbRet.nSeed
    Launch.Response('Chess_EnterLevel')
end)

-- 请求结算关卡
function ChessClient.Req_LevelSettlement(activityId, activityType, fightId)
    local levelcfg = ChessConfig:GetFightDefineByMoudleName(ChessClient.moduleName).tbId2Data[fightId]
    local levelid = string.format('%d-%d-%d', activityType, activityId, levelcfg.nLevelId)

    local tbLog = {}
    tbLog['LevelFinish'] = LaunchLog.LogLevel(LaunchType.CHESS, ChessClient.nextMapId, levelid)
    tbLog['FightRecont'] = LaunchLog.LogFightRecont()
    local cmd = {activityId = activityId, activityType = activityType, moduleName = ChessClient.moduleName,
    fightId = fightId, nSeed = ChessClient.nSeed, tbLog = tbLog}
    UI.ShowConnection()
    Reconnect.Send_SettleInfo('Chess_LevelSettlement', cmd)
end

---注册结算回调
s2c.Register('Chess_LevelSettlement', function(tbAward)
    UI.CloseConnection()
    Launch.Response('Chess_LevelSettlement', tbAward)
end)

-- 失败
function ChessClient.Req_LevelFail(activityId, activityType, fightId)
    local levelcfg = ChessConfig:GetFightDefineByMoudleName(ChessClient.moduleName).tbId2Data[fightId]
    local levelid = string.format('%d-%d-%d', activityType, activityId, levelcfg.nLevelId)
    local tbLog = {}
    tbLog['LevelFinish'] = LaunchLog.LogLevel(LaunchType.CHESS, ChessClient.nextMapId, levelid)
    tbLog['FightRecont'] = LaunchLog.LogFightRecont()
    local cmd = {
        activityId = activityId, activityType = activityType, fightId = fightId,
        moduleName = ChessClient.moduleName, tbLog = tbLog
    }
    me:CallGS('Chess_LevelFail', json.encode(cmd))
end

function ChessClient:WriteOperationLog(InType, ExParam)
    if not InType or InType == 0 then
        return
    end
    local tbLog = {}
    table.insert(tbLog, self.activityType or 0)
    table.insert(tbLog, self.activityId or 0)
    table.insert(tbLog, ChessData.mapId or 0)
    table.insert(tbLog, InType or 0)
    table.insert(tbLog, ChessReward:GetScore(ChessClient.activityId, ChessClient.activityType, ChessData.mapId) or 0)
    local character = self:GetPlayerCharacter()
    if character and character.CurrentGroundActor then
        local posX = character.CurrentGroundActor.posX
        local posY = character.CurrentGroundActor.posY
        table.insert(tbLog, string.format("%d,%d", posX, posY))
    else
        table.insert(tbLog, "NULL")
    end
    table.insert(tbLog, ExParam or "NULL")
    -- tbLog['ActivityType'] = self.activityType
    -- tbLog['ActivityId'] = self.activityId
    -- tbLog['ChessMapID'] = ChessData.mapId
    -- tbLog['ChessActionType'] = InType
    -- tbLog['MapProgress'] = ChessReward:GetScore(ChessClient.activityId, ChessClient.activityType, ChessData.mapId)
    -- tbLog['ResetID'] = string.format("%d,%d", posX, posY)
    -- tbLog['Extend'] = ExParam
    me:CallGS('chess.client_operation_log', json.encode(tbLog))
end

--- end
----------------------------------------------------------------------------------