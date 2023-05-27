----------------------------------------------------------------------------------
-- @File    : OpenWorldConfig.lua
-- @Brief   : 开放世界数据加载 【服务器客户端共用】
----------------------------------------------------------------------------------

---@class OpenWorldMgr 
OpenWorldMgr = OpenWorldMgr or {}

--- 最大区域ID 【涉及到任务变量存储，一旦上线，不允许发生变化】
--- 与OpenWorldMgr.TaskId的任务ID分配息息相关
OpenWorldMgr.MaxRegionID = 99

----------------------------------- 加载配置表 ------------------------------------

--- 加载场景物件
function OpenWorldMgr.LoadObjectsCfg(path)
    local tbFile = LoadCsv(path, 1);
    local tbObjects = {}
    local tbName2Id = {}
    for _, tbLine in ipairs(tbFile) do 
        local nId = tonumber(tbLine.Id) or 0;
        if nId > 0 then 
            local tb = {}
            tb.nId = nId
            tb.tbItems = Eval(tbLine.Items);
            tb.NameId = tbLine.NameId
            tbObjects[nId] = tb
            tbName2Id[tb.NameId] = nId
        end
    end
    print("load", path)
    return tbObjects, tbName2Id;
end 

--- 加载探索度奖励
function OpenWorldMgr.LoadExploreAward(path)
    if not OpenWorldClient then path = "../settings/" .. path end

    local tbFile = LoadCsv(path, 1);
    local tbAwards = {}
    for _, tbLine in ipairs(tbFile) do 
        local nId = tonumber(tbLine.Id) or 0;
        if nId > 0 then 
            local tb = {}
            tb.id = nId
            tb.tbItems = Eval(tbLine.Items)
            table.insert(tbAwards, tb)
        end
    end
    print("load", path)
    return tbAwards;
end

--- 加载导出点
function OpenWorldMgr.LoadPointsCfg(path)
    local sPoint = OpenWorldMgr.LoadFile(path)
    local tbPoints = Eval(sPoint);
    tbPoints.GetPositionPercent = function(self, posName, posValue)
        local pos = posValue or self.points[posName].pos;
        if not pos then 
            return {0.5, 0.5}
        end
        local x = pos[1] - self.points.point_left_bottom.pos[1];
        local y = pos[2] - self.points.point_left_bottom.pos[2];
        local sizeX = self.points.point_right_top.pos[1] - self.points.point_left_bottom.pos[1]
        local sizeY = self.points.point_right_top.pos[2] - self.points.point_left_bottom.pos[2]
        return {x / sizeX, 1 - y / sizeY};
    end
    return tbPoints;
end

--- 加载debug点信息
function OpenWorldMgr.LoadMapDebugData(levelName)
    local path = string.format("openworld/%s/%s_debug_map.txt", levelName, levelName)
    local sPoint = OpenWorldMgr.LoadFile(path)
    local tbPoints = Eval(sPoint)
    return tbPoints
end

--- 加载npc等级配置
function OpenWorldMgr.LoadNpcLevels(path)
    if not OpenWorldClient then path = "../settings/" .. path end
    local tbFile = LoadCsv(path, 1);
    local tbLevels = {}
    for _, tbLine in ipairs(tbFile) do 
        local nId = tonumber(tbLine.PlayerLevel) or 0;
        if nId > 0 then 
            local tb = {}
            tb.id = nId
            tb.NpcLevel = tonumber(tbLine.NpcLevel) or 0
            tbLevels[nId] = tb;
        end
    end
    print("load", path)
    return tbLevels;
end

--- 加载npc配置（权重）
function OpenWorldMgr.LoadNpcConfig(path)
    if not OpenWorldClient then path = "../settings/" .. path end

    local tbFile = LoadCsv(path, 1);
    local tbNpcs = {}
    for _, tbLine in ipairs(tbFile) do 
        local nId = tonumber(tbLine.NpcId) or 0;
        if nId > 0 then 
            local tb = {}
            tb.id = nId
            tb.Weight = tonumber(tbLine.Weight) or 0
            tbNpcs[nId] = tb;
        end
    end
    print("load", path)
    return tbNpcs;
end

--- 计算npc死亡后代币掉落范围
function OpenWorldMgr.GetWorldNpcDropConfig(tbNpcs)
    local totalWeight = 0;
    for _, tb in ipairs(tbNpcs) do 
        local npcId = tb[1];
        local cfg = OpenWorldMgr.tbNpcConfig[npcId];
        if cfg then
            local value = cfg.Weight * tb[2]
            totalWeight = totalWeight + value;
        else 
            print("--------------------------------------------------- error")
            print("[openworld] can not find npc weight:", npcId)
        end
    end

    local tbRet = {}
    for _, tb in ipairs(tbNpcs) do 
        local npcId = tb[1];
        local cfg = OpenWorldMgr.tbNpcConfig[npcId];
        local value = (cfg and cfg.Weight or 0) / totalWeight * OpenWorldMgr.MaxMapMoney;
        local range = value * OpenWorldMgr.MoneyDropRandom;
        local min = math.floor(value + 0.5) - math.floor(range + 0.5)
        local max = math.floor(value + 0.5) + math.floor(range + 0.5)
        tbRet[npcId] = {value = value, range = {min, max}}
    --   print("npc drop cfg", npcId, value, min, max)
    end

    return tbRet;
end

--- 文件加载
function OpenWorldMgr.LoadFile(path)
    print("load", path)
    if OpenWorldClient then 
        return LoadSetting(path)
    else 
        path = "../settings/" .. path
        local file = io.open(path, "r")
        if not file then 
            error("can not open file " .. path)
        end
        local content = file:read("*a");
        file:close()
        return content
    end
end

function OpenWorldMgr.ShowError(msg)
    if printf_t then 
        printf_t(msg)
    else 
        error(msg)
    end
end

function OpenWorldMgr.LoadWorldCfg(worldName)
    local path = string.format("openworld/%s_task.txt", worldName) 
    local pointPath = string.format("openworld/%s_points.txt", worldName) 
    local pathObjects = string.format("openworld/%s_objects.txt", worldName)

    if not OpenWorldClient then 
        path = "../settings/" .. path
        pathObjects = "../settings/" .. pathObjects
    end

    local tbFile = LoadCsv(path, 1);
    local tbRet = {
        tbData = {},                                        -- 任务id->任务数据
        tbMainId = {}, tbBranchId = {}, tbRandomId = {},    -- 主线，支线，随机任务id
        tbRegion = {},                                      -- 存储区域信息，每个区域分别有哪些主线、支线、随机任务
        tbUnlockRegion = {},                                -- 区域支线任务解锁信息
        tbUnlockTrans = {},                                 -- 传送点解锁信息
        tbBranchMaxTaskID = {},                             -- 存储每个区域最后一个任务ID
    }

    for _, tbLine in ipairs(tbFile) do 
        local nId = tonumber(tbLine.Id) or 0;
        if nId > 0 then 
            local tb = {
                Id = nId;
                Day = tonumber(tbLine.Day) or 0;
                Category = tonumber(tbLine.Category) or 0;
                RegionId = tonumber(tbLine.RegionId) or 0;
                Type = tonumber(tbLine.Type) or 0;  
                ResPath = tbLine.ResPath;
                LevelLogic = tbLine.LevelLogic;
                Cmd = Eval(tbLine.Cmd);
                DropId = tonumber(tbLine.DropId) or 0;     
                Desc = tbLine.Desc;
                PointName = tbLine.PointName;
            }
            if not (tb.RegionId >= 0 and tb.RegionId <= OpenWorldMgr.MaxRegionID) then 
                OpenWorldMgr.ShowError("请注意：开放世界区域ID必须处于[0-99]之间，涉及到数据存储，不能动")
            end
            
            tbRet.tbData[nId] = tb;
            local tbRegion = tbRet.tbRegion[tb.RegionId] or {tbMainId = {}, tbBranchId = {}, tbRandomId = {}}
            tbRet.tbRegion[tb.RegionId] = tbRegion
            if tb.Category == 1 then 
                tbRet.tbMainId[#tbRet.tbMainId + 1] = nId
                table.insert(tbRegion.tbMainId, nId)
            elseif tb.Category == 2 then 
                tbRet.tbBranchId[#tbRet.tbBranchId + 1] = nId
                table.insert(tbRegion.tbBranchId, nId)

                -- 存储区域最大支线任务id，用于判断支线随机任务是否解锁
                -- 如果未来任务支持跳转解锁，则此处需要优化
                local maxId = tbRet.tbBranchMaxTaskID[tb.RegionId];
                tbRet.tbBranchMaxTaskID[tb.RegionId] = math.max(maxId or 0, tb.Id)

            elseif tb.Category == 3 then 
                tbRet.tbRandomId[#tbRet.tbRandomId + 1] = nId
                table.insert(tbRegion.tbRandomId, nId)
            end

            for key, value in pairs(tb.Cmd or {}) do 
                if key == "unlock_region" then 
                    for _, id in ipairs(value) do 
                        tbRet.tbUnlockRegion[id] = nId
                    end
                elseif key == "unlock_trans" then 
                    tbRet.tbUnlockTrans[value] = nId
                end
            end
        end
    end

    -- 用于计算探索度: 主线 + 支线 任务总数
    tbRet.maxTaskCount = #tbRet.tbMainId + #tbRet.tbBranchId

    -- 导出点
    tbRet.tbPoints = OpenWorldMgr.LoadPointsCfg(pointPath);

    -- 场景对象加载奖励加载
    tbRet.tbObjects, tbRet.tbObjectsName2Id = OpenWorldMgr.LoadObjectsCfg(pathObjects)

    -- npc掉落权重计算
    tbRet.tbNpcDropCfg = OpenWorldMgr.GetWorldNpcDropConfig(tbRet.tbPoints.npcs)

    return tbRet
end

function OpenWorldMgr.LoadCfg()
    local self = OpenWorldMgr

    -- 加载全局配置
    local str = OpenWorldMgr.LoadFile("openworld/task_global.txt")
    local cfg = Eval(str)
    OpenWorldMgr.MaxRandomTaskIndex = cfg.RandomDailyTaskCount
    OpenWorldMgr.MaxMapMoney = cfg.MaxMapMoney
    OpenWorldMgr.MaxDailyMoney = cfg.MaxDailyMoney
    OpenWorldMgr.MoneyDropRandom = cfg.MoneyDropRandom
    OpenWorldMgr.tbDebugTaskIds = cfg.DebugTaskIds;

    -- 加载npc掉落权重配置
    self.tbNpcConfig = OpenWorldMgr.LoadNpcConfig("openworld/npcs.txt")

    -- 加载npc等级配置表
    self.tbNpcLevels = OpenWorldMgr.LoadNpcLevels("openworld/npc_level.txt")

    self.tbConfig = {}
    self.tbConfig[1] = self.LoadWorldCfg("owlevel_01/owlevel_01")

    -- 探索度奖励
    self.tbExploreAward = self.LoadExploreAward("openworld/explore_award.txt");
 
    print("OpenWorldMgr Config", OpenWorldMgr.MaxRandomTaskIndex, 
        OpenWorldMgr.MaxMapMoney, OpenWorldMgr.MaxDailyMoney)
end

OpenWorldMgr.LoadCfg()
----------------------------------------------------------------------------------