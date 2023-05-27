----------------------------------------------------------------------------------
-- @File    : ChessReward.lua
-- @Brief   : 棋盘奖励相关【服务器客户端同步】
----------------------------------------------------------------------------------

---@class ChessReward 棋盘奖励相关接口
ChessReward = ChessReward or {
    tbModuleRewards = {},               -- 奖励配置相关
}

ChessReward.MaxRewardIndex = 3000;            -- 最大奖励索引
ChessReward.MaxMapId = 31                     -- 每期活动最多支持31个地图 (与_TaskRewardVar.MapComplet有关联)

--- 奖励相关变量存储分配
local _TaskRewardVar = {
    MapComplet = {0, 0};                        -- 0号变量用于存储每个地图是否已经完成,最多存储32个地图
    Reward = {1, 99};                           -- 1-99号变量用于存储奖励领取情况
    Max = 101;
}

--- 地图内部数据存储分配
local _TaskInnerVar = {
    Global = {0, 0};                     -- 0号变量用于存储活动全局数据，比如背包
    Map = {1, ChessReward.MaxMapId};     -- 1-32号变量用于存储每个地图的详细数据
    Max = 50;
}

----------------------------------------------------------------------------------
--- 接口封装
----------------------------------------------------------------------------------
---得到活动是否开启
---@param activityId 活动id
---@param activityType 活动类型
function ChessReward:IsActivityOpen(activityId, activityType)
    if activityType == ChessActivityType.DLC1 then 
        return ChessLogic.IsOpen(activityId)
    end
end

---得到活动开启的是哪个棋盘模块
function ChessReward:GetModuleName(activityId, activityType)
    if activityType == ChessActivityType.DLC1 then
        return ChessLogic.GetChessModuleName(activityId)
    end
end

---得到活动奖励task id
---@param activityId 活动id
---@param activityType 活动类型
---@return taskGroup,taskStartId,taskEndId
function ChessReward:GetActivityRewardTask(activityId, activityType)
    local taskGroup, taskStartId, taskEndId;
    if activityType == ChessActivityType.DLC1 then
        taskGroup, taskStartId, taskEndId = ChessLogic.GetRewardTask()
    end
    assert(taskEndId - taskStartId >= _TaskRewardVar.Max, "棋盘活动奖励相关任务变量分配不得少于" .. _TaskRewardVar.Max);
    return taskGroup, taskStartId, taskEndId;
end

---得到棋盘内部存储需要的task string id
---@param activityId 活动id
---@param activityType 活动类型
---@return taskStrGroup,taskStrStartId,taskStrEndId
function ChessReward:GetActivityInnerTaskStr(activityId, activityType)
    local taskGroup, taskStartId, taskEndId;
    if activityType == ChessActivityType.DLC1 then 
        taskGroup, taskStartId, taskEndId = ChessLogic.GetInnerTaskStr()
    end
    assert(taskEndId - taskStartId >= _TaskInnerVar.Max, "棋盘活动内部变量分配不得少于" .. _TaskInnerVar.Max);
    return taskGroup, taskStartId, taskEndId;
end

---得到地图是否解锁
---@param activityId 活动id
---@param activityType 活动类型
---@param mapId 地图id
function ChessReward:IsChessMapUnlock(activityId, activityType, mapId)
    local moduleName = self:GetModuleName(activityId, activityType)
    if activityType == ChessActivityType.DLC1 then 
        return ChessLogic._IsMapUnlock(activityId, moduleName, mapId)
    end
end

----------------------------------------------------------------------------------
--- rewards
----------------------------------------------------------------------------------
---是否已经领奖
---@param rewardIndex奖励索引[1-3000]
function ChessReward:IsGetReward(taskGroup, taskStartId, rewardIndex)
    assert(rewardIndex <= self.MaxRewardIndex)
    local index, bit = ChessReward:GetIndexAndBit(rewardIndex)
    local taskId = index + _TaskRewardVar.Reward[1]
    assert(taskId <= _TaskRewardVar.Reward[2])
    taskId = taskId + taskStartId
    return self:GetTaskBitValue(taskGroup, taskId, {bit, bit}) == 1;
end

---设置奖励已经领取
---@param rewardIndex奖励索引[1-3000]
function ChessReward:SetReward(taskGroup, taskStartId, rewardIndex)
    assert(rewardIndex <= self.MaxRewardIndex)
    local index, bit = ChessReward:GetIndexAndBit(rewardIndex)
    local taskId = index + _TaskRewardVar.Reward[1]
    assert(taskId <= _TaskRewardVar.Reward[2])
    taskId = taskId + taskStartId
    self:SetTaskBitValue(taskGroup, taskId, 1, {bit, bit});
end


----------------------------------------------------------------------------------
--- 收集度
----------------------------------------------------------------------------------
--- 得到收集度
---@param activityId 活动id
---@param activityType 活动类型（不同类型，对应不同manager）
---@param mapId 地图id
---@return score 收集度 [0-1000]
function ChessReward:GetScore(activityId, activityType, mapId)
    local moduleName = self:GetModuleName(activityId, activityType)
    local tbRewards = self:GetRewardsByModuleName(moduleName)
    if not tbRewards then return 0 end

    local taskGroup, taskStartId, taskEndId = self:GetActivityRewardTask(activityId, activityType)
    local score = 0;
    for _, tb in ipairs(tbRewards.tbMap[mapId] or {}) do 
        if self:IsGetReward(taskGroup, taskStartId, tb.Id) then 
            score = score + tb.Score
        end
    end
    return score;
end

---得到地图是否已经通过
---@param activityId 活动id
---@param activityType 活动类型（不同类型，对应不同manager）
---@param mapId 地图id
---@return bool
function ChessReward:GetMapIsComplete(activityId, activityType, mapId)
    assert(mapId <= self.MaxMapId)
    local taskGroup, taskStartId, taskEndId = self:GetActivityRewardTask(activityId, activityType)
    local taskId = taskStartId + _TaskRewardVar.MapComplet[1]
    return self:GetTaskBitValue(taskGroup, taskId, {mapId, mapId}) == 1;
end

---设置地图已经通过
---@param activityId 活动id
---@param activityType 活动类型（不同类型，对应不同manager）
---@param mapId 地图id
function ChessReward:SetMapIsComplete(activityId, activityType, mapId)
    assert(mapId <= self.MaxMapId)
    local taskGroup, taskStartId, taskEndId = self:GetActivityRewardTask(activityId, activityType)
    local taskId = taskStartId + _TaskRewardVar.MapComplet[1]
    self:SetTaskBitValue(taskGroup, taskId, 1, {mapId, mapId});
    me:SyncChanged()
end


----------------------------------------------------------------------------------
--- 数据 存储 && 获取
----------------------------------------------------------------------------------
function ChessReward:GetIndexAndBit(value)
    local index = math.floor(value / 32);
    local bit = value % 32;
    return index, bit;
end

--- 得到任务变量
function ChessReward:GetTaskValue(taskGroup, taskId)
    return me:GetAttribute(taskGroup, taskId)
end 

--- 设置任务变量
function ChessReward:SetTaskValue(taskGroup, taskId, value)
    if not ChessClient then
        me:SetAttribute(taskGroup, taskId, value)
    end
end

--- 得到任务变量
function ChessReward:GetTaskBitValue(taskGroup, taskId, tbBit)
    local value = self:GetTaskValue(taskGroup, taskId)
    local bitStart, bitEnd = tbBit[1], tbBit[2]
    return GetBits(value, bitStart, bitEnd);
end

--- 设置任务变量
function ChessReward:SetTaskBitValue(taskGroup, taskId, value, tbBit)
    local taskValue = self:GetTaskValue(taskGroup, taskId)
    local bitStart, bitEnd = tbBit[1], tbBit[2]
    taskValue = SetBits(taskValue, value, bitStart, bitEnd)
    self:SetTaskValue(taskGroup, taskId, taskValue)
end


----------------------------------------------------------------------------------
--- 得到奖励配置
----------------------------------------------------------------------------------
---发放客户端奖励
function ChessReward:AppplyGetClientReward(moduleName, rewardIndex)
    local tbRewards = self:GetRewardsByModuleName(moduleName)
    local reward = tbRewards.tbList[rewardIndex]
    if not reward then return end

    if reward.Object and #reward.Object > 0 then 
        for _, data in ipairs(reward.Object) do 
            ChessData:AddItemCount(data[1], data[2] or 1)
        end
    end
end

--- 得到模块下奖励配置
---@param moduleName 模块名
function ChessReward:GetRewardsByModuleName(moduleName)
    if not moduleName then return end 

    local tbDef = self.tbModuleRewards[moduleName]
    if not tbDef then 
        tbDef = {tbList = {}, tbMap = {}}
        local path = string.format("chess/%s/rewards.txt", moduleName)
        if not UE4 then 
            path = "../settings/" .. path
        end
        local tbFile = LoadCsv(path, 1) or {};
        for _, tbLine in ipairs(tbFile) do 
            local Id = tonumber(tbLine.Id or "") or 0
            if Id > 0 then 
                assert(Id <= self.MaxRewardIndex, "由于数据存储限制，Id不能超过" .. self.MaxRewardIndex);
                local tb = {}
                tb.Id = Id
                tb.GDPL = Eval(tbLine.GDPL) or {}
                tb.Object = Eval(tbLine.Object) or {}
                tb.MapId = tonumber(tbLine.Map) or 0;
                tb.Score = tonumber(tbLine.Score) or 0
                tb.Name = tbLine.Nul
                tbDef.tbList[Id] = tb

                tbDef.tbMap[tb.MapId] = tbDef.tbMap[tb.MapId] or {}
                table.insert(tbDef.tbMap[tb.MapId], tb)
            end
        end

        for mapId, list in pairs(tbDef.tbMap) do 
            local score = 0;
            for _, tb in ipairs(list) do 
                score = score + tb.Score
            end
            if score ~= 1000 then 
                local errmsg = string.format("棋盘奖励配置异常，请发送以下信息到大群：\n\n模块:%s 地图Id:%d 配置的探索度为%d，需要让总数等于1000。", moduleName, mapId, score)
                if UE4 then 
                    UE4.UGMLibrary.ShowDialog("棋盘活动奖励配置表异常", errmsg);
                else
                    assert(false, errmsg) 
                end
            end
        end
        self.tbModuleRewards[moduleName] = tbDef
    end
    return tbDef
end

----------------------------------------------------------------------------------