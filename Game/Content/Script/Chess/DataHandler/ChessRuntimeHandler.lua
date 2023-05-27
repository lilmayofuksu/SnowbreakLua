----------------------------------------------------------------------------------
-- @File    : ChessRuntimeHandler.lua
-- @Brief   : 棋盘运行时数据管理接口
-- @Author  : leiyong
-- 由于lua数据结构非常复杂，所以统一对数据的操作（包括读取和设置），方面维护和阅读
----------------------------------------------------------------------------------

---@class ChessRuntimeHandler 棋盘运行时数据管理
ChessRuntimeHandler = ChessRuntimeHandler or {}

-- 私有变量
local tbMapData = {}            -- 地图运行数据
local tbMapConfigData = {}      -- 地图配置数据    

----------------------------------------------------------------------------------
--[[
tbMapData = 
{
    PathType = 1,                                               -- 寻路类型
    CharacterScale = 1,                                         -- 角色缩放
    tbSearchTags = {}                                           -- 所有有tag的地形或者物件，加快后续查询用
    tbSearchIds = {}                                            -- 所有有id的地形或者物件，加快后续查询用
    tbCfgDataMapping = {}                                       -- 配置数据与运行数据映射，方便后面查找    
    tbRegions = {                                               -- 区域信息
        [1] = {                                                 -- 1号区域
            Position = {x,y,z}                                  -- 位置
            Rotation = 0,                                       -- 旋转
            cfg = {},                                           -- 配置数据引用
            tbGround = {                                        -- 地形
                [111] = {                                       -- 地形Id -> {数据}
                    active = true,                              -- 是否激活
                    id = 111,                                   -- 唯一id（注，该id不是配置id）
                    type = 1,                                   -- 类型1 - 地块
                    tplId = 0,                                  -- 地形配置id（注：地形是可以修改的）
                    cfg = {},                                   -- 对地形配置数据的引用
                    height = 0,                                 -- 高度偏移
                    actor = nil,                                -- 对应actor，初始化场景时赋值
                    classHandler = nil,                         -- 类别处理类
                    tbGroups = {                                -- 事件组
                        [1] = { 
                            active = true,                      -- 组是否激活
                            cfg = {},                           -- 对事件组配置数据的引用    
                        }
                    }
                }
            },
            tbObjects = {                                       -- 物件
                [1] = {                                         -- 物件Id -> {数据}
                    active = true,                              -- 是否激活
                    id = 111,                                   -- 地形id（注，该id不是配置id）
                    pos = {x,y},                                -- 格子坐标
                    tplId = 0,                                  -- 物件模板id
                    type = 2,                                   -- 类型2 - 物件
                    angle = 0,                                  -- 旋转
                    cfg = {},                                   -- 对物件配置数据的引用
                    height = 0,                                 -- 高度偏移
                    actor = nil,                                -- 对应actor，初始化场景时赋值
                    classHandler = nil,                         -- 类别处理类
                    tbGroups = {                                -- 事件组
                        [1] = { 
                            active = true,                      -- 组是否激活
                            cfg = {},                           -- 对事件组配置数据的引用    
                        }
                    }
                }
            }
        }
    }
}

--]]

--- 

--- 数据后处理
local data_post_processor = function(cfg, data)
    local tbData = cfg.tbData
    if not tbData then return end 

    -- 初始化有tag或者id的物件
    if tbData.tag and #tbData.tag > 0 then 
        table.insert(tbMapData.tbSearchTags, data)
    end

    if tbData.id and #tbData.id > 0 then 
        table.insert(tbMapData.tbSearchIds, data)
    end
    
    -- 增加数据映射
    if tbData then 
        tbMapData.tbCfgDataMapping[tbData] = data
    end

    local def = ChessClient:GetGridDef(data.tplId)
    if def and def.ClassName then 
        data.classHandler = ChessObject:RegisterClass(def.ClassName, data)
    end
end


---清空数据
function ChessRuntimeHandler:ClearAllData()
    tbMapConfigData = nil
    tbMapData = nil
end

----------------------------------------------------------------------------------
---初始化运行时数据
---@param tbMapConfigData 地图配置数据
function ChessRuntimeHandler:InitData(_tbMapConfigData)
    tbMapData = {tbRegions = {}, tbSearchTags = {}, tbSearchIds = {}, tbCfgDataMapping = {}}
    tbMapConfigData = _tbMapConfigData
    tbMapData.PathType = tbMapConfigData.tbData.PathType
    tbMapData.CharacterScale = tbMapConfigData.tbData.CharacterScale

    -- 初始化区域
    for regionId, tbRegion in ipairs(tbMapConfigData.tbData.tbRegions) do 
        local tb = {tbGround = {}, tbObjects = {}, cfg = tbRegion}
        tb.minPos = {x = tbRegion.RangeX.min, y = tbRegion.RangeY.min}
        tb.maxPos = {x = tbRegion.RangeX.max, y = tbRegion.RangeY.max}
        tb.Position = {table.unpack(tbRegion.Position or {})}
        tb.Rotation = tbRegion.Rotation
        tbMapData.tbRegions[regionId] = tb

        -- 初始化地形
        -- 此处id是string
        for id, cfg in pairs(tbRegion.tbGround) do 
            local tbData = {}
            tbData.active = true
            tbData.cfg = cfg
            tbData.id = id
            tbData.tplId = cfg.objectId
            tbData.isGround = true;
            tbData.regionId = regionId
            tbData.height = cfg.tbData and cfg.tbData.height
            if cfg.tbData and cfg.tbData.tbGroups then 
                tbData.tbGroups = {}
                for i, v in ipairs(cfg.tbData.tbGroups) do 
                    tbData.tbGroups[i] = {active = true, cfg = v}
                end
            end
            if cfg.tbData and cfg.tbData.id and #cfg.tbData.id > 0 then 
                tbData.active = ChessData:GetObjectIsActive(cfg.tbData.id[1])
            end
            tb.tbGround[id] = tbData
            data_post_processor(cfg, tbData)
        end

        -- 初始化物件
        for id, cfg in pairs(tbRegion.tbObjects) do 
            local tbData = {}
            tbData.active = true
            tbData.id = id
            tbData.regionId = regionId
            tbData.pos = {table.unpack(cfg.pos)}
            tbData.isObject = true
            tbData.tplId = cfg.tpl
            tbData.angle = cfg.tbData and cfg.tbData.angle
            tbData.cfg = cfg
            tbData.height = cfg.tbData and cfg.tbData.height
            if cfg.tbData and cfg.tbData.tbGroups then 
                tbData.tbGroups = {}
                for i, v in ipairs(cfg.tbData.tbGroups) do 
                    tbData.tbGroups[i] = {active = true, cfg = v}
                end
            end
            if cfg.tbData and cfg.tbData.id and #cfg.tbData.id > 0 then 
                local index = cfg.tbData.id[1]
                tbData.active = ChessData:GetObjectIsActive(index)
                local gridId = ChessData:GetObjectPosition(index)
                if gridId then 
                    tbData.pos = {ChessTools:GridIdToXY(gridId)}
                end
            end
            tb.tbObjects[id] = tbData
            data_post_processor(cfg, tbData)
        end
        
    end
end

--- 首次进入
function ChessRuntimeHandler:OnFirstEntry()
    for regionId, tbRegion in ipairs(tbMapData.tbRegions) do 
        for id, tb in pairs(tbRegion.tbGround) do 
            if tb.cfg.tbData and tb.cfg.tbData.hide then 
                self:SetTargetActive(tb, false)
            end
        end
        for id, tb in pairs(tbRegion.tbObjects) do 
            if tb.cfg.tbData and tb.cfg.tbData.hide then 
                self:SetTargetActive(tb, false)
            end
        end
    end
end

---游戏初始化
function ChessRuntimeHandler:OnGameInit()
    for regionId, tbRegion in ipairs(tbMapData.tbRegions) do 
        for id, tb in pairs(tbRegion.tbGround) do 
            if tb.classHandler and tb.classHandler.OnGameInit then 
                tb.classHandler:OnGameInit()
            end
        end
        for id, tb in pairs(tbRegion.tbObjects) do 
            if tb.classHandler and tb.classHandler.OnGameInit then 
                tb.classHandler:OnGameInit()
            end
        end
    end
end

--- 游戏开始 
function ChessRuntimeHandler:OnGameStart()
    for regionId, tbRegion in ipairs(tbMapData.tbRegions) do 
        for id, tb in pairs(tbRegion.tbGround) do 
            if tb.classHandler and tb.classHandler.OnGameStart then 
                tb.classHandler:OnGameStart()
            end
        end
        for id, tb in pairs(tbRegion.tbObjects) do 
            if tb.classHandler and tb.classHandler.OnGameStart then 
                tb.classHandler:OnGameStart()
            end
        end
    end
end

----------------------------------------------------------------------------------
--- get
----------------------------------------------------------------------------------
---得到寻路类型
function ChessRuntimeHandler:GetPathType() return tbMapData.PathType end

---得到角色缩放倍数
function ChessRuntimeHandler:GetCharacterScale() return tbMapData.CharacterScale end

---得到区域数量
function ChessRuntimeHandler:GetRegionCount() return #tbMapData.tbRegions end 

---得到区域数据
---@param index 区域索引
---@return 区域数据tbRegion
function ChessRuntimeHandler:GetRegionData(index) return tbMapData.tbRegions[index] end

---得到区域位置
---@param tbRegion 区域数据
function ChessRuntimeHandler:GetRegionPosition(tbRegion) return tbRegion.Position end

---得到区域旋转
---@param tbRegion 区域数据
function ChessRuntimeHandler:GetRegionRotation(tbRegion) return tbRegion.Rotation end

---得到区域最小坐标
---@param tbRegion 区域数据
function ChessRuntimeHandler:GetRegionMinPos(tbRegion) return tbRegion.minPos end 

---得到区域最大坐标
---@param tbRegion 区域数据
function ChessRuntimeHandler:GetRegionMaxPos(tbRegion) return tbRegion.maxPos end 

---遍历区域内每个地形块
---@param tbRegion 区域数据
---@param pFunc 遍历回调(地块id, 地块数据)
function ChessRuntimeHandler:ForeachRegionGround(tbRegion, pFunc) 
    for id, tbData in pairs(tbRegion.tbGround) do 
        pFunc(id, tbData)
    end
end

---得到地块是否激活
---@param tbGroundData 地形数据
function ChessRuntimeHandler:GetGroundActive(tbGroundData) return tbGroundData.active end

---得到地块高度
---@param tbGroundData 地形数据
function ChessRuntimeHandler:GetGroundHeight(tbGroundData) return tbGroundData.height or 0 end

---得到地块模板id
---@param tbGroundData 地形数据
function ChessRuntimeHandler:GetGroundCfgId(tbGroundData) return tbGroundData.tplId end

---得到地块Actor
---@param tbGroundData 地形数据
function ChessRuntimeHandler:GetGroundActor(tbGroundData) return tbGroundData.actor end

---遍历区域内每个物件
---@param tbRegion 区域数据
---@param pFunc 遍历回调(物件id, 物件数据)
function ChessRuntimeHandler:ForeachRegionObject(tbRegion, pFunc) 
    for id, tbData in pairs(tbRegion.tbObjects) do 
        pFunc(id, tbData)
    end
end

--- 得到区域内物件
---@param regionId 区域Id
---@param objectId 物件Id
function ChessRuntimeHandler:GetRegionObject(regionId, objectId)
    local tbData = self:GetRegionData(regionId)
    return tbData.tbObjects[objectId]
end

---得到物件是否激活
---@param tbObjectData 物件数据
function ChessRuntimeHandler:GetObjectActive(tbObjectData) return tbObjectData.active end

---得到物件高度
---@param tbObjectData 物件数据
function ChessRuntimeHandler:GetObjectHeight(tbObjectData) return tbObjectData.height or 0 end

---得到物件模板id
---@param tbObjectData 物件数据
function ChessRuntimeHandler:GetObjectCfgId(tbObjectData) return tbObjectData.cfg.tpl end

---得到物件坐标
---@param tbObjectData 物件数据
---@return x,y
function ChessRuntimeHandler:GetObjectPosition(tbObjectData) return table.unpack(tbObjectData.pos) end

---得到物件旋转
---@param tbObjectData 物件数据
function ChessRuntimeHandler:GetObjectRotation(tbObjectData) return tbObjectData.angle end

---得到地块Actor
---@param tbObjectData 物件数据
function ChessRuntimeHandler:GetObjectActor(tbObjectData) return tbObjectData.actor end

---通过配置数据得到运行时数据
---@param cfgData 配置数据（地形或者物件的 tbData）
---@return tbTargetData 目标数据
function ChessRuntimeHandler:GetRuntimeDataByCfgData(cfgData) return tbMapData.tbCfgDataMapping[cfgData] end

---得到目标显示状态
---@param tbTargetData 目标数据(通过FindTargetByTagAndId得出的结果，可能是tbGroundData，也可能是tbObjectData)
---@param state 0，1，2
function ChessRuntimeHandler:GetTargetShowState(tbTargetData) 
    if tbTargetData.cfg.tbData then 
        local tbId = tbTargetData.cfg.tbData.id;
        if tbId and #tbId > 0 then 
            return ChessData:GetObjectShowState(tbId[1])
        end
    end
    return 0;
end

----------------------------------------------------------------------------------
--- find 格子数据查询
----------------------------------------------------------------------------------
---通过tag或者id查找对应的地形或者物件
---@param tbTag tag列表
---@param tbId id列表
---@return tbList目标列表
function ChessRuntimeHandler:FindTargetByTagAndId(tbTag, tbId)
    local tbHash = {}
    if tbTag and #tbTag > 0 then 
        for _, tb in ipairs(tbMapData.tbSearchTags) do 
            if ChessTools:Check_tb1_contain_tb2(tbTag, tb.cfg.tbData.tag) then 
                tbHash[tb] = true
            end
        end
    end

    if tbId and #tbId > 0 then 
        for _, tb in ipairs(tbMapData.tbSearchIds) do 
            if ChessTools:Check_tb1_contain_tb2(tbId, tb.cfg.tbData.id) then 
                tbHash[tb] = true
            end
        end
    end

    local tbList = {}
    for tb, v in pairs(tbHash) do 
        tbList[#tbList + 1] = tb
    end
    return tbList
end

---通过格子id查找地形数据
---@param tbGridId 格子列表
---@return tbList目标列表
function ChessRuntimeHandler:FindGroundDataByGridId(tbGridId)
    if not tbGridId then return {} end
    local tbHash = {}
    for _, tb in ipairs(tbGridId) do 
        local regionId, gridId = tb[1], tb[2]
        local tbRegion = self:GetRegionData(regionId)
        local tbData = tbRegion.tbGround[gridId];
        tbHash[tbData] = true
    end

    local tbList = {}
    for tb, v in pairs(tbHash) do 
        tbList[#tbList + 1] = tb
    end
    return tbList
end

---通过actor找数据
---@param actor 对象
function ChessRuntimeHandler:FindTargetByActor(actor)
    local regionId = actor:GetRegionId()
    local uid = actor:GetUID()
    local isGround = actor.IsGround
    local tbRegion = self:GetRegionData(regionId)
    if not tbRegion or uid == 0 then return end
    return isGround and tbRegion.tbGround[tostring(uid)] or tbRegion.tbObjects[uid]
end

--- 得到地图中所有含有指定tag的物件
---@param tagName
function ChessRuntimeHandler:FindObjectsByTagName(tagName)
    local tbCache = {}
    local contain = function(tplId)
        local ret = tbCache[tplId]
        if ret ~= nil then return ret end 

        local tbDef = ChessClient:GetGridDef(tplId)
        if tbDef and ChessTools:Contain(tbDef.Tags, tagName) then 
            tbCache[tplId] = true 
        else 
            tbCache[tplId] = false 
        end
        return tbCache[tplId]
    end

    local tbObjects = {}
    for regionId, tbRegion in ipairs(tbMapData.tbRegions) do 
        for id, tb in pairs(tbRegion.tbObjects) do 
            if contain(tb.cfg.tpl) then 
                table.insert(tbObjects, tb)
            end
        end
    end
    return tbObjects;
end

--- 得到地面上的物件列表
---@param tbGroundData 地面数据
function ChessRuntimeHandler:FindObjectsInGround(tbGroundData)
    local tbList = {}
    if not tbGroundData then return tbList end

    local objects = tbGroundData.actor.Objects
    if not objects or objects:Length() == 0 then 
        return tbList
    end

    for i = 1, objects:Length() do 
        local actor = objects:Get(i);
        local data = self:FindTargetByActor(actor)
        if data then 
            table.insert(tbList, data)
        end
    end

    return tbList;
end

--- 对地面上的每个物件执行回调
---@param tbGroundData 地面数据
function ChessRuntimeHandler:ForeachObjectInGround(tbGroundData, pFunc)
    local tbObjectDatas = ChessRuntimeHandler:FindObjectsInGround(tbGroundData)
    for i = 1, #tbObjectDatas do 
        pFunc(tbObjectDatas[i])
    end
end

--- 得到Actor占用的所有地面
function ChessRuntimeHandler:GetActorAllGroundData(tbObjectData)
    local regionActor = ChessClient:GetRegionActor(tbObjectData.regionId)
    local allGround = regionActor:GetActorAllGround(tbObjectData.actor)
    local tbList = {}
    for i = 1, allGround:Length() do 
        local actor = allGround:Get(i)
        if actor then 
            local data = ChessRuntimeHandler:FindTargetByActor(actor)
            if data then 
                table.insert(tbList, data)
            end
        end
    end
    return tbList
end

----------------------------------------------------------------------------------
--- set
----------------------------------------------------------------------------------
---设置地形对应的Actor
---@param tbGroundData 地形数据
---@param actor 引擎Actor
function ChessRuntimeHandler:SetGroundActor(tbGroundData, actor) 
    tbGroundData.actor = actor 
    if not tbGroundData.active then 
        actor:SetActiveState(false);
    end
end

---设置物件对应的Actor
---@param tbObjectData 物件数据
---@param actor 引擎Actor
function ChessRuntimeHandler:SetObjectActor(tbObjectData, actor) 
    if not actor then return end
    tbObjectData.actor = actor 
    if not tbObjectData.active then 
        actor:SetActiveState(false);
    end

    local tplId = tbObjectData.cfg.tpl
    local tbCfg = ChessClient:GetGridDef(tplId)
    if not tbCfg then return end

    if #tbCfg.State0 > 0 then 
        local state = self:GetTargetShowState(tbObjectData)
        local tbState = tbCfg["State" .. state] 
        for _, tb in ipairs(tbState) do 
            ChessTools:SetActorMaterialParam(actor, tb.type, tb.mat, tb.name, tb.value, tb.value, 0, tb.delay)
        end
    end

    if tbObjectData.active and tbCfg.ParticleId > 0 then 
        local cfg = ChessClient:GetParticleDef(tbCfg.ParticleId)
        if cfg then 
            local localtion = actor:K2_GetActorLocation() + UE.FVector(cfg.Offset[1] or 0, cfg.Offset[2] or 0, cfg.Offset[3] or 0)
            local rotate = UE4.FRotator(0,0,0)
            actor:AttachEffect(cfg.Path, localtion, rotate)
        else
            UE.UUMGLibrary.LogError("特效id不存在，无法挂载到actor上：" .. tbCfg.ParticleId)
        end
    end
end

---设置目标隐藏或者显示
---@param tbTargetData 目标数据(通过FindTargetByTagAndId得出的结果，可能是tbGroundData，也可能是tbObjectData)
---@param active true/false
function ChessRuntimeHandler:SetTargetActive(tbTargetData, active) 
    if tbTargetData.classHandler then
        if tbTargetData.classHandler.CanReward and active then
            if not tbTargetData.classHandler:CanReward() then
                return
            end
        end

        if tbTargetData.classHandler.OnObjectAppear and active then
            tbTargetData.classHandler:OnObjectAppear()
        end
    end

    if tbTargetData.active ~= active then 
        tbTargetData.active = active
        tbTargetData.actor:SetActiveState(active);

        if tbTargetData.actor.BindingNpc then
            tbTargetData.actor.BindingNpc:SetActiveState(active);
        end

        if tbTargetData.cfg.tbData then 
            local tbId = tbTargetData.cfg.tbData.id;
            if tbId and #tbId > 0 then 
                ChessData:SetObjectIsActive(tbId[1], active)
            end
        end
        return true
    end
end

---设置目标已经被使用
---@param tbTargetData 目标数据(通过FindTargetByTagAndId得出的结果，可能是tbGroundData，也可能是tbObjectData)
---@param value true/false
function ChessRuntimeHandler:SetTargetIsUsed(tbTargetData) 
    if tbTargetData.cfg.tbData then 
        local tbId = tbTargetData.cfg.tbData.id;
        if tbId and #tbId > 0 then 
            ChessData:SetObjectIsUsed(tbId[1])
        end
    end
end

---设置物件位置
---@param tbTargetData 目标数据(通过FindTargetByTagAndId得出的结果，可能是tbGroundData，也可能是tbObjectData)
---@param region 区域id
---@param gridId 格子id，不能跨区域设置位置
function ChessRuntimeHandler:SetTargetPosition(tbTargetData, regionId, gridId)
    -- 只能设置物件的位置
    if tbTargetData.isObject then 
        local x, y = ChessTools:GridIdToXY(gridId)
        tbTargetData.pos = {x,y};
        tbTargetData.actor:SetObjectPosition(x, y)

        if tbTargetData.cfg.tbData then 
            local tbId = tbTargetData.cfg.tbData.id;
            if tbId and #tbId > 0 then 
                ChessData:SetObjectPosition(tbId[1], gridId)
            end
        end
        return true;
    end
end

---设置目标显示状态
---@param tbTargetData 目标数据(通过FindTargetByTagAndId得出的结果，可能是tbGroundData，也可能是tbObjectData)
---@param state 0，1，2
function ChessRuntimeHandler:SetTargetShowState(tbTargetData, state) 
    if tbTargetData.cfg.tbData then 
        local tbId = tbTargetData.cfg.tbData.id;
        if tbId and #tbId > 0 then 
            ChessData:SetObjectShowState(tbId[1], state)
            return true;
        end
    end
end

----------------------------------------------------------------------------------

--- 重置地图（奖励不重置）
function ChessRuntimeHandler:ResetMap()
    -- 重置玩家数据
    ChessData:ResetPlayerData()

    -- 背包是所有地图通用的，如何清空呢？
    -- 清空道具
    for _, data in ipairs(ChessClient:GetItemDef().tbList) do 
        ChessData:ResetItem(data.Id)
    end
    
    -- -- 清空迷雾
    -- for regionId, tbRegion in ipairs(tbMapData.tbRegions) do 
    --     ChessData:ResetRegionView(regionId)
    -- end

    -- 清空物件信息
    for index, tb in ipairs(tbMapConfigData.tbData.tbObjectIdDef) do  
        ChessData:ResetObjectData(index)
    end

    -- 清空事件信息
    for index, tb in ipairs(tbMapConfigData.tbData.tbEventDef) do  
        ChessData:ResetEventData(index)
    end

    -- 清空任务变量
    for _, tb in ipairs(tbMapConfigData.tbData.tbTaskVarDef) do  
        ChessData:SetMapTaskVar(tb.id, 0)
    end

    -- 清空任务完成情况
    for _, tb in ipairs(tbMapConfigData.tbData.tbTaskDef) do 
        ChessData:SetMapTaskIsComplete(tb.tbArg.id, 0)
    end
    
    -- 清空任务列表
    ChessData:SetCurrentTaskIds({})

    ChessClient:WriteOperationLog(4)
    -- 重现加载地图
    ChessClient:LoadMapById(ChessClient.moduleName, ChessData.mapId, ChessClient.activityId, ChessClient.activityType)
end

----------------------------------------------------------------------------------