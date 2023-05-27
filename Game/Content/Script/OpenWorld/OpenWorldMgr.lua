----------------------------------------------------------------------------------
-- @File    : OpenWorldMgr.lua
-- @Brief   : 开放世界数据管理 【服务器客户端共用】
----------------------------------------------------------------------------------

---@class OpenWorldMgr 条件检查
OpenWorldMgr = OpenWorldMgr or {}

-- 最多有多少个随机任务
OpenWorldMgr.MaxRandomTaskIndex = 4;

-- 最大代币数量
OpenWorldMgr.MaxMoneyCount = 0;

--- 任务组
OpenWorldMgr.TaskGroupId = 98

--- 货币id
OpenWorldMgr.MoneyId = 6

--- 任务id规划
OpenWorldMgr.TaskId = {
    CurrentWorld    = 0;               -- 保存当前开启的世界
    Main            = 2;               -- 保存主线任务进度
    Activity        = 3;               -- 保存当前活动id
    MaxMoney        = 4;               -- 保存代币掉落数量
    CompleteCount   = 5;               -- 保存完成了多少任务（主线+支线，用于计算探索度）
    Explore         = 6,               -- 记录领了哪些档次的奖励，最多31档
    MainDay         = 7,               -- 保存主线任务做到了第几天
    TaskFlag        = {10, 14};        -- 记录每个区域今天是否做过任务，按位存取，0号位是主线任务
    Daily           = {20, 40};        -- 保存每日任务id
    Random          = {50, 80};        -- 今天完成的随机任务列表
    Branch          = {100, 199};      -- 保存每个区域支线任务进度
    RegionDay       = {200, 299};      -- 保存每个区域任务做到了第几天

    -- 以下用位存储
    Patrol          = {600, 650};      -- 存储巡逻怪每日击杀情况                                     
    ObjectState     = {651, 700};      -- 记录物件状态，主要包括可破坏物和门 【针对自动生成的配置表】        
}

------------------------------------ 基础接口 -------------------------------------

--- 得到任务变量
function OpenWorldMgr.GetTaskValue(taskId)
    return me:GetAttribute(OpenWorldMgr.TaskGroupId, taskId);
end

--- 将一个数字转换为tbTaskId对于的位
function OpenWorldMgr.GetTaskBit(tbTaskId, index)
    local id = math.floor(index / 32);
    local bit = index % 32;
    local taskId = id + tbTaskId[1]
    assert(taskId <= tbTaskId[2], string.format("[ow] 任务id索引超出最大上限 %d %d %d", index, taskId, tbTaskId[2]))
    return taskId, bit;
end

--- 得到任务变量某位是否被设置
function OpenWorldMgr.GetTaskBitIsSet(tbTaskId, index)
    local taskId, bit = OpenWorldMgr.GetTaskBit(tbTaskId, index)
    local value = OpenWorldMgr.GetTaskValue(taskId)
    return GetBits(value, bit, bit) == 1;
end

--- 校正id
function OpenWorldMgr.FixTaskId(id, tb)
    local beginId = tb[1]
    local endId = tb[2]
    local taskId = id + beginId
    if taskId >= beginId and taskId <= endId then 
        return taskId
    end
end

------------------------------------ 活动全局接口 -------------------------------------
--- 判断活动是否开启
function OpenWorldMgr.IsOpen()
    return false;
end

--- 得到当前活动id
function OpenWorldMgr.GetActivityId()
    return OpenWorldMgr.GetTaskValue(OpenWorldMgr.TaskId.Activity)
end

--- 得到当前开启的世界
function OpenWorldMgr.GetCurrentWorld()
    local id = OpenWorldMgr.GetTaskValue(OpenWorldMgr.TaskId.CurrentWorld);     
    return id > 0 and id or 1;
end

--- 得到代币数量
function OpenWorldMgr.GetMoneyCount()
    return Cash.GetMoneyCount(OpenWorldMgr.MoneyId)
end

--- 得到已经完成的任务数量
function OpenWorldMgr.GetTaskCompleteCount()
    return OpenWorldMgr.GetTaskValue(OpenWorldMgr.TaskId.CompleteCount)
end

-- 得到当前活动配置
function OpenWorldMgr.GetConfig()
    local CurrentWorldId = OpenWorldMgr.GetCurrentWorld()
    return OpenWorldMgr.tbConfig[CurrentWorldId];
end

------------------------------------ 主线/支线/随机 -------------------------------------
--- 得到任务点
function OpenWorldMgr.GetPointCfg()
    local CurrentWorldId = OpenWorldMgr.GetCurrentWorld()
    return OpenWorldMgr.tbConfig[CurrentWorldId].tbPoints;
end

--- 是不是主线任务
function OpenWorldMgr.IsTaskMain(taskId)
    local cfg = OpenWorldMgr.GetTaskCfg(taskId)
    return cfg and cfg.Category == 1;
end

--- 是不是支线任务
function OpenWorldMgr.IsTaskBranch(taskId)
    local cfg = OpenWorldMgr.GetTaskCfg(taskId)
    return cfg and cfg.Category == 2;
end

--- 是不是随机任务
function OpenWorldMgr.IsTaskRandom(taskId)
    local cfg = OpenWorldMgr.GetTaskCfg(taskId)
    return cfg and cfg.Category == 3;
end

--- 得到任务是否符合天数限制
function OpenWorldMgr.CheckTaskDay(taskId)
    local cfg = OpenWorldMgr.GetTaskCfg(taskId)
    if not cfg then return false end

    if cfg.Category == 1 then 
        local flag = OpenWorldMgr.GetMainTaskFlag()
        local day = OpenWorldMgr.GetMainDay();
        if flag then 
            return cfg.Day <= day;
        end
        return cfg.Day <= (day + 1);

    elseif cfg.Category == 2 then 
        local flag = OpenWorldMgr.GetBranchTaskFlag(cfg.RegionId)
        local day = OpenWorldMgr.GetRegionBranchDay(cfg.RegionId)
        if flag then 
            return cfg.Day <= day;
        end
        return cfg.Day <= (day + 1);
    end 

    return true;
end

--- 得到区域支线任务是否解锁
function OpenWorldMgr.IsUnlockRegion(regionId)
    local config = OpenWorldMgr.GetConfig()
    local task = config.tbUnlockRegion[regionId]
    if task and task > 0 then 
        return OpenWorldMgr.IsTaskComplete(task);
    end
    return true;
end

--- 得到区域随机任务是否解锁
function OpenWorldMgr.IsUnlockRegionRandom(regionId)
    local config = OpenWorldMgr.GetConfig()
    local task = config.tbBranchMaxTaskID[regionId]
    if task and task > 0 then 
        return OpenWorldMgr.IsTaskComplete(task);
    end
    return false;
end

--- 得到主线任务做到了第几天
function OpenWorldMgr.GetMainDay()
    local taskId = OpenWorldMgr.TaskId.RegionDay[1];
    return OpenWorldMgr.GetTaskValue(taskId);
end

--- 得到指定区域支线任务做到了第几天
function OpenWorldMgr.GetRegionBranchDay(regionId)
    local taskId = OpenWorldMgr.TaskId.RegionDay[1] + regionId;
    return OpenWorldMgr.GetTaskValue(taskId);
end

--- 得到今日是否完成过主线任务
function OpenWorldMgr.GetMainTaskFlag()
    return OpenWorldMgr.GetTaskBitIsSet(OpenWorldMgr.TaskId.TaskFlag, 0)
end

--- 得到今日是否完成过指定区域的支线任务
function OpenWorldMgr.GetBranchTaskFlag(regionId)
    return OpenWorldMgr.GetTaskBitIsSet(OpenWorldMgr.TaskId.TaskFlag, regionId)
end


------------------------------------ 活动场景接口 -------------------------------------
--- 得到传送点是否解锁
function OpenWorldMgr.IsUnlockTransPoint(pointName)
    local config = OpenWorldMgr.GetConfig()
    local task = config.tbUnlockTrans[pointName]
    if task and task > 0 then 
        return OpenWorldMgr.IsTaskComplete(task);
    end
    return true;
end

--- 是不是传送点
function OpenWorldMgr.IsTransPoint(pointName)
    local ok = string.find(pointName, "point_trans_");
    return ok;
end

--- 得到物件(箱子)对应的奖励
function OpenWorldMgr.GetObjectReward(objectUId)
    local config = OpenWorldMgr.GetConfig()
    local tb = config.tbObjects[objectUId]
    return tb and tb.tbItems;
end

--- 得到场景物件的唯一id
function OpenWorldMgr.GetObjectIdByName(nameId)
    local config = OpenWorldMgr.GetConfig()
    local id = config.tbObjectsName2Id[nameId];
    if not id then 
        print("[ow] can not find nameId", nameId);
    end
    print("GetObjectIdByName", nameId, id);
    return id
end

--- 判断巡逻怪是否可以刷新
function OpenWorldMgr.CheckTaskPatrolOK(id)
    return not OpenWorldMgr.GetTaskBitIsSet(OpenWorldMgr.TaskId.Patrol, id)
end

--- 得到巡逻怪代币掉落范围
function OpenWorldMgr.GetPatrolDropRange(npcTplId)
    local cfg = OpenWorldMgr.GetConfig()
    local npcCfg = cfg.tbNpcDropCfg[npcTplId] 
    return npcCfg and npcCfg.range;
end

--- 得到物件状态
function OpenWorldMgr.GetObjectState(objectId)
    print("GetObjectState", objectId);
    return OpenWorldMgr.GetTaskBitIsSet(OpenWorldMgr.TaskId.ObjectState, objectId)
end


------------------------------------ 活动奖励接口 -------------------------------------
--- 得到探索度
function OpenWorldMgr.GetTaskCompleteProgress()
    local count = OpenWorldMgr.GetTaskCompleteCount();
    local config = OpenWorldMgr.GetConfig()
    if config and config.maxTaskCount > 0 then 
        return count / config.maxTaskCount * 100;
    end
    return 0;
end

--- 得到探索度奖励
function OpenWorldMgr.GetAllExploreAward()
    return OpenWorldMgr.tbExploreAward
end 

--- 得到指定档次的探索度奖励是否已经领取
function OpenWorldMgr.CheckExploreAwardOK(awardIdx)
    local tbAwards = OpenWorldMgr.GetAllExploreAward()
    if awardIdx <= 0 or awardIdx > #tbAwards or awardIdx > 30 then
        return false 
    end
    local value = OpenWorldMgr.GetTaskValue(OpenWorldMgr.TaskId.Explore);
    return GetBits(value, awardIdx, awardIdx) == 1
end

--- 得到指定档次的探索度奖励是否可以领取
function OpenWorldMgr.CheckExploreAwardState(awardIdx)
    local tbAwards = OpenWorldMgr.GetAllExploreAward()
    local tb = tbAwards[awardIdx]
    if not tb or awardIdx > 30 then return false end

    local rate = OpenWorldMgr.GetTaskCompleteProgress();
    return rate >= tb.id;
end


------------------------------------ 活动任务接口 -------------------------------------
--- 得到任务配置
function OpenWorldMgr.GetTaskCfg(taskId)
    if taskId and taskId > 0 then
        local CurrentWorldId = OpenWorldMgr.GetCurrentWorld()
        return OpenWorldMgr.tbConfig[CurrentWorldId].tbData[taskId]
    end
end

--- 得到当前任务列表
function OpenWorldMgr.GetCurrentTaskIds()
    local self = OpenWorldMgr
    local tbTaskIds = {}

    if RunFromEntry or OpenWorldServer then
        for i = self.TaskId.Daily[1], self.TaskId.Daily[2] do 
            local value = me:GetAttribute(self.TaskGroupId, i);
            if value > 0 then
                table.insert(tbTaskIds, value)
            else 
                break
            end
        end
    else 
        for _, id in ipairs(OpenWorldMgr.tbDebugTaskIds) do 
            table.insert(tbTaskIds, id)
        end
    end
    return tbTaskIds
end

--- 检查任务是否完成
function OpenWorldMgr.IsTaskComplete(taskId)
    local self = OpenWorldMgr
    local cfg = self.GetTaskCfg(taskId);
    -- 如果是主线
    if cfg.Category == 1 then 
        local mainTask = self.GetTaskValue(self.TaskId.Main)
        return mainTask >= taskId;
    -- 如果是支线
    elseif cfg.Category == 2 then 
        local index = self.TaskId.Branch[1] + cfg.RegionId
        if index <= self.TaskId.Branch[2] then
            return self.GetTaskValue(index) >= taskId;
        else 
            error("region id out of range: " .. cfg.RegionId)
        end
    -- 如果是随机
    elseif cfg.Category == 3 then 
        local id = OpenWorldMgr.TaskId.Random[1]
        while id <= OpenWorldMgr.TaskId.Random[2] do 
            if me:GetAttribute(OpenWorldMgr.TaskGroupId, id) == taskId then
                return true
            end
            id = id + 1
        end
        return id >= OpenWorldMgr.TaskId.Random[2];
    end
    return true
end

--- 得到Npc等级
function OpenWorldMgr.GetNpcLevel()
    local level = me:Level();
    if level <= 0 then return 0 end

    local tb = OpenWorldMgr.tbNpcLevels[level];
    if tb then return tb.NpcLevel end
    OpenWorldMgr.ShowError("get npc level error. can not find levelId " .. level)
    return 0;
end

