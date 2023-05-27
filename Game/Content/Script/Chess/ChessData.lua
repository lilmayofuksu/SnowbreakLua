----------------------------------------------------------------------------------
-- @File    : ChessData.lua
-- @Brief   : 棋盘数据管理 【服务器与客户端共用】
----------------------------------------------------------------------------------

---@class ChessData 棋盘数据管理
ChessData = ChessData or {}

--[[
在开发时，可以选择模式：
    单机模式 - 本地改了立即起效，并且数据存储在本地
    联机模式 - 本地改了需要同步配置表到服务器重启，数据存储在远端

之所以用TaskStr来存储棋盘数据，是为了保证存档数据的完整性。
如果用TaskId，在弱网模式下，可能会出现部分数据丢失的情况
如果活动TaskStr数据量太大，需要考虑分开存储：
活动全局数据用一个变量，比如背包
每个地图分别用变量。
--]]

--[[

需要测试中途卡掉进程，会不会存档之类的

--]]


ChessData.RegionMaxViewTaskIndex = 30;      -- 每个区域最多存储30个视野变量
ChessData.MaxItemIndex = 200;              -- 最大道具索引
ChessData.MaxRewardIndex = ChessReward.MaxRewardIndex;            -- 最大奖励索引

--- 地图内 object 数据存储分配(0-31位)
local _BitObject = {
    gridId          = {0, 15},      -- 所在格子坐标
    hasPos          = {16, 16},     -- 是否设置过坐标
    active          = {17, 17},     -- 是否显示/隐藏
    interaction     = {18, 21},     -- 交互次数，最多存储15次
    used            = {22, 22},     -- 物件是否已经使用（如机关已经开启，宝箱已经打开等）
    state           = {23, 24},     -- 物件显示状态，最大存储3 （如灯笼的打开或者关闭）
    count           = {25, 25},     -- 物件完成次数
}

--- 地图内 event 数据存储分配(0-31位)
local _BitEvent = {
    count           = {0, 7},       -- 事件发送次数
}

--- 地图内 player 数据存储分配(0-31位)
local _BitPlayer = {
    gridId          = {0, 15},      -- 所在格子坐标
    regionId        = {16, 19},     -- 所在区域
    rotate          = {20, 28},     -- 旋转
    init            = {29, 29},     -- 是否首次进入场景
    complete        = {30, 30},     -- 地图是否完成
}

--- 地图变量分配
local _MapVar = {
    player          = 0,                -- 第0个变量用来存储 地图内玩家信息，比如位置 旋转等
    object          = {10, 100},        -- 其中分配了90个变量 用于存储物件
    event           = {101, 130},       -- 其中分配了30个变量 用于存储事件
    view            = {200, 440},       -- 其中分配了240个变量，用于存储视野（每个变量可以存储一个矩形视野范围），每个Region分配了30个变量
    task            = {501, 600},       -- 分配了100个变量，用于存储地图中任务是否已经完成，按位记录，任务id范围[1-3000]
    taskVar         = {601, 800},       -- 分配了200个变量，用于存储地图中任务变量值（如果有全局任务变量的需求，记得用GlobalVar）
    taskCur         = {801, 900},       -- 分配了100个变量，用于存储当前正在进行的任务列表
    items           = {901, 1100},      -- 分配了200个变量，用于存储道具
}

--- 道具数据存储分别
local _BitItem = {
    count           = {0, 15},          -- 数量最多不能超过65535
}

--- 地图全局数据存储 (比如背包中道具，奖励领取情况等等)
local _GlobalVar = {
    mapComplete     = 0,                -- 0号变量用于存储地图完成情况
    items           = {1, 1000},        -- 分配了1000个变量，用于存储活动中获得的各种物品，物品id不能超过1000 (全局道具，暂未使用)
    reward          = {1001, 1100},     -- 分配了100个变量，用于存储奖励发放，按位记录，配置表id范围[1-3000]

    -- 如果地图A会影响地图B，那么就添加全局任务变量 （也可以通过判断道具有无来实现）
}

----------------------------------------------------------------------------------
--- 初始化
function ChessData:Init()
    EventSystem.On(Event.Shutdown, function()
        if not RunFromEntry then 
            ChessData:Save()
        end
    end)
end

--- 清空所有数据
function ChessData:ClearAllData()
    self.tbSave = nil
    self.moduleName = nil
    self.mapId = nil
end

----------------------------------------------------------------------------------
--- 得到变量id
function ChessData:GetMapTaskId(type, index)
    local v = _MapVar[type]
    if _G.type(v) == "number" then 
        return v;
    end
    local min, max = v[1], v[2]
    local range = max - min
    if not (index >= 0 and index <= range) then 
        assert(false, string.format("地图变量超出范围,mapid=%d, type=%s, index=%d, range=%d", self.mapId, type, index, range))
    end
    return min + index;
end

--- 得到任务变量
---@param mapId 地图索引，如果是活动全局数据，则mapId为0
function ChessData:GetTaskValue(mapId, taskId)
    local tb = self.tbSave[mapId] 
    if not tb then 
        tb = {}
        self.tbSave[mapId] = tb
    end
    return tb[taskId] or 0;
end 

--- 设置任务变量
---@param mapId 地图索引，如果是活动全局数据，则mapId为0
function ChessData:SetTaskValue(mapId, taskId, value)
    local tb = self.tbSave[mapId] 
    if not tb then 
        tb = {}
        self.tbSave[mapId] = tb
    end

    if value ~= 0 then 
        tb[taskId] = value
    else 
        tb[taskId] = nil
    end 
end

--- 得到任务变量
function ChessData:GetTaskBitValue(mapId, taskId, tbBit)
    local value = self:GetTaskValue(mapId, taskId)
    local bitStart, bitEnd = tbBit[1], tbBit[2]
    return GetBits(value, bitStart, bitEnd);
end

--- 设置任务变量
function ChessData:SetTaskBitValue(mapId, taskId, value, tbBit)
    local taskValue = self:GetTaskValue(mapId, taskId)
    local bitStart, bitEnd = tbBit[1], tbBit[2]
    taskValue = SetBits(taskValue, value, bitStart, bitEnd)
    self:SetTaskValue(mapId, taskId, taskValue)
end

--- 模块名
function ChessData:SetModuleName(moduleName)
    local tbMapList = ChessConfig:GetMapListByModuleName(moduleName)
    self.tbSave = {}
    self.tbSave[0] = self:LoadSave(moduleName, 0)
    for _, tb in ipairs(tbMapList) do 
        assert(tb.Id <= ChessReward.MaxMapId, "由于数据存储需要，地图id不能超过".. ChessReward.MaxMapId)
        self.tbSave[tb.Id] = self:LoadSave(moduleName, tb.Id)
    end
end

--- 设置当前地图id
function ChessData:SetMapId(moduleName, mapId, activityId, activityType)
    self.activityId = activityId
    self.activityType = activityType

    if self.moduleName ~= moduleName then 
        self:SetModuleName(moduleName)
    end
    self.mapId = mapId
    self.moduleName = moduleName;
end

--- 保存
function ChessData:Save()
    local tbMapId = {}
    if self.moduleName and self.tbSave then 
        for mapId, tb in pairs(self.tbSave) do 
            table.insert(tbMapId, mapId)
            self:SaveData(self.moduleName, mapId, tb)
        end
    end
    if RunFromEntry then
        ChessData:C2S_OnMapSave(tbMapId)
    end
end

--- debug 清空存档
function ChessData:Debug_ClearCurrentMapSave()
    self.tbSave = {}
    self:Save()
end

--- 重置玩家数据
function ChessData:ResetPlayerData()
    local taskId = self:GetMapTaskId("player")
    self:SetTaskValue(self.mapId, taskId, 0)
end

----------------------------------------------------------------------------------
---- get
----------------------------------------------------------------------------------
--- 得到物件是否显示
function ChessData:GetObjectIsActive(objectIndex)
    local taskId = self:GetMapTaskId("object", objectIndex)
    return self:GetTaskBitValue(self.mapId, taskId, _BitObject.active) == 0
end

--- 得到物件位置
function ChessData:GetObjectPosition(objectIndex)
    local taskId = self:GetMapTaskId("object", objectIndex)
    local has = self:GetTaskBitValue(self.mapId, taskId, _BitObject.hasPos)
    if has == 0 then return end
    return self:GetTaskBitValue(self.mapId, taskId, _BitObject.gridId)
end

--- 得到物件交互次数
function ChessData:GetObjectInteractionCount(objectIndex)
    local taskId = self:GetMapTaskId("object", objectIndex)
    return self:GetTaskBitValue(self.mapId, taskId, _BitObject.interaction)
end

--- 得到物件是否已经使用
function ChessData:GetObjectIsUsed(objectIndex)
    local taskId = self:GetMapTaskId("object", objectIndex)
    return self:GetTaskBitValue(self.mapId, taskId, _BitObject.used)
end

--- 得到物件显示状态
function ChessData:GetObjectShowState(objectIndex)
    local taskId = self:GetMapTaskId("object", objectIndex)
    return self:GetTaskBitValue(self.mapId, taskId, _BitObject.state)
end

--- 得到物件完成次数
function ChessData:GetObjectCompleteCount(objectIndex)
    local taskId = self:GetMapTaskId("object", objectIndex)
    return self:GetTaskBitValue(self.mapId, taskId, _BitObject.count)
end


--- 得到玩家位置
function ChessData:GetPlayerPos()
    local taskId = self:GetMapTaskId("player")
    local regionId = self:GetTaskBitValue(self.mapId, taskId, _BitPlayer.regionId)
    local gridId = self:GetTaskBitValue(self.mapId, taskId, _BitPlayer.gridId)
    local rotate = self:GetTaskBitValue(self.mapId, taskId, _BitPlayer.rotate)
    return regionId, gridId, rotate 
end

--- 得到是否首次进入场景
function ChessData:GetIsFirstEntry()
    local taskId = self:GetMapTaskId("player")
    return self:GetTaskBitValue(self.mapId, taskId, _BitPlayer.init) == 0
end

--- 得到事件发送次数
function ChessData:GetEventSendCount(eventIndex)
    local taskId = self:GetMapTaskId("event", eventIndex)
    return self:GetTaskBitValue(self.mapId, taskId, _BitEvent.count)
end

--- 得到区域视野值
---@param regionIndex 区域索引，取值范围[1-8]
---@param taskIndex 变量索引，取值[1 - RegionMaxViewTaskIndex]
function ChessData:GetRegionViewValue(regionIndex, taskIndex)
    local index = (regionIndex - 1) * self.RegionMaxViewTaskIndex + (taskIndex - 1)
    local taskId = self:GetMapTaskId("view", index)
    return self:GetTaskValue(self.mapId, taskId)
end

----------------------------------------------------------------------------------
--- set
----------------------------------------------------------------------------------
--- 设置物件是否显示
function ChessData:SetObjectIsActive(objectIndex, active)
    local taskId = self:GetMapTaskId("object", objectIndex)
    self:SetTaskBitValue(self.mapId, taskId, active and 0 or 1, _BitObject.active)
end

--- 设置物件位置 
function ChessData:SetObjectPosition(objectIndex, gridId)
    local taskId = self:GetMapTaskId("object", objectIndex)
    self:SetTaskBitValue(self.mapId, taskId, gridId, _BitObject.gridId)
    self:SetTaskBitValue(self.mapId, taskId, 1, _BitObject.hasPos)
end

--- 增加物件交互次数
function ChessData:AddObjectInteractionCount(objectIndex)
    local taskId = self:GetMapTaskId("object", objectIndex)
    local value = self:GetTaskBitValue(self.mapId, taskId, _BitObject.interaction)
    if value < 15 then -- 最多存储15次，因为只申请了4位
        self:SetTaskBitValue(self.mapId, taskId, value + 1, _BitObject.interaction)
    end
end

--- 得到物件是否已经使用
function ChessData:SetObjectIsUsed(objectIndex)
    local taskId = self:GetMapTaskId("object", objectIndex)
    self:SetTaskBitValue(self.mapId, taskId, 1, _BitObject.used)
end

--- 设置物件显示状态
function ChessData:SetObjectShowState(objectIndex, state)
    local taskId = self:GetMapTaskId("object", objectIndex)
    self:SetTaskBitValue(self.mapId, taskId, state, _BitObject.state)
end

--- 设置物件显示状态
function ChessData:SetObjectCompleteCount(objectIndex, isComplete)
    local taskId = self:GetMapTaskId("object", objectIndex)
    self:SetTaskBitValue(self.mapId, taskId, isComplete and 1 or 0, _BitObject.count)
end


--- 清空物件所有信息
function ChessData:ResetObjectData(objectIndex)
    local taskId = self:GetMapTaskId("object", objectIndex)
    self:SetTaskValue(self.mapId, taskId, 0)
end

--- 设置玩家位置
function ChessData:SetPlayerPos(regionId, gridId, rotateZ)
    local taskId = self:GetMapTaskId("player")
    self:SetTaskBitValue(self.mapId, taskId, regionId, _BitPlayer.regionId)
    self:SetTaskBitValue(self.mapId, taskId, gridId, _BitPlayer.gridId)
    self:SetTaskBitValue(self.mapId, taskId, rotateZ, _BitPlayer.rotate)
end

--- 设置首次进入地图
function ChessData:SetIsFirstEntry()
    local taskId = self:GetMapTaskId("player")
    self:SetTaskBitValue(self.mapId, taskId, 1, _BitPlayer.init)
end

--- 增加事件发送次数
function ChessData:AddEventSendCount(eventIndex)
    local taskId = self:GetMapTaskId("event", eventIndex)
    local value = self:GetTaskBitValue(self.mapId, taskId, _BitEvent.count);
    if value >= 120 then return end
    self:SetTaskBitValue(self.mapId, taskId, value + 1, _BitEvent.count)
end

--- 清空所有事件信息
function ChessData:ResetEventData(eventIndex)
    local taskId = self:GetMapTaskId("event", eventIndex)
    self:SetTaskValue(self.mapId, taskId, 0)
end

--- 设置区域视野值
---@param regionIndex 区域索引，取值范围[1-8]
---@param taskIndex 索引，取值[1 - RegionMaxViewTaskIndex]
---@param value 变量值 前16位存矩形左下角坐标，后16位存储矩形右上角坐标
function ChessData:SetRegionViewValue(regionIndex, taskIndex, value)
    local index = (regionIndex - 1) * self.RegionMaxViewTaskIndex + (taskIndex - 1)
    local taskId = self:GetMapTaskId("view", index)
    return self:SetTaskValue(self.mapId, taskId, value)
end

--- 重置区域视野变量
---@param regionIndex 区域索引，取值范围[1-8]
function ChessData:ResetRegionView(regionIndex)
    for i = 1, self.RegionMaxViewTaskIndex do 
        local value = self:GetRegionViewValue(regionIndex, i) 
        if value ~= 0 then 
            self:SetRegionViewValue(regionIndex, i, 0);
        end
    end
end

----------------------------------------------------------------------------------
--- task
----------------------------------------------------------------------------------
--- 得到任务是否已经完成
function ChessData:GetMapTaskIsComplete(taskIndex)
    local index, bit = ChessReward:GetIndexAndBit(taskIndex)
    local taskId = self:GetMapTaskId("task", index)
    return self:GetTaskBitValue(self.mapId, taskId, {bit, bit}) == 1
end

--- 设置任务是否已经完成
function ChessData:SetMapTaskIsComplete(taskIndex, value)
    value = value or 1
    local index, bit = ChessReward:GetIndexAndBit(taskIndex)
    local taskId = self:GetMapTaskId("task", index)
    return self:SetTaskBitValue(self.mapId, taskId, value, {bit, bit})
end

--- 得到地图任务变量值(如果需要优化的话，这里可以用1个byte存储)
function ChessData:GetMapTaskVar(taskVarIndex)
    if not self.mapId then return 0 end

    local taskId = self:GetMapTaskId("taskVar", taskVarIndex)
    return self:GetTaskValue(self.mapId, taskId)
end

--- 设置任务变量值
function ChessData:SetMapTaskVar(taskVarIndex, value)
    local taskId = self:GetMapTaskId("taskVar", taskVarIndex)
    return self:SetTaskValue(self.mapId, taskId, value)
end

--- 得到当前正在进行的任务列表
function ChessData:GetCurrentTaskIds()
    local max = _MapVar.taskCur[2] -_MapVar.taskCur[1]
    local tbId = {}
    for i = 1, max do 
        local taskId = self:GetMapTaskId("taskCur", i);
        local value = self:GetTaskValue(self.mapId, taskId)
        if value == 0 then 
            break
        end
        table.insert(tbId, value)
    end
    return tbId
end

--- 设置当前正在进行的任务列表
function ChessData:SetCurrentTaskIds(tbIds)
    local max = _MapVar.taskCur[2] -_MapVar.taskCur[1]
    for i = 1, max do 
        local taskId = self:GetMapTaskId("taskCur", i);
        local value = self:GetTaskValue(self.mapId, taskId)
        if value == 0 then 
            break
        end
        self:SetTaskValue(self.mapId, taskId, 0)
    end

    for i = 1, #tbIds do 
        local taskId = self:GetMapTaskId("taskCur", i);
        self:SetTaskValue(self.mapId, taskId, tbIds[i])
    end
end

----------------------------------------------------------------------------------
--- rewards
----------------------------------------------------------------------------------
---奖励是否已经领取
---@param rewardIndex奖励索引[1-3000]
function ChessData:CanReward(rewardIndex)
    assert(rewardIndex <= ChessData.MaxRewardIndex)
    local index, bit = ChessReward:GetIndexAndBit(rewardIndex)
    local taskId = index + _GlobalVar.reward[1]
    assert(taskId <= _GlobalVar.reward[2])
    return self:GetTaskBitValue(0, taskId, {bit, bit}) == 0;
end

---设置奖励已经领取
---@param rewardIndex奖励索引[1-3000]
function ChessData:SetReward(rewardIndex, SetRewardCallback)
    assert(rewardIndex <= ChessData.MaxRewardIndex)
    local index, bit = ChessReward:GetIndexAndBit(rewardIndex)
    local taskId = index + _GlobalVar.reward[1]
    assert(taskId <= _GlobalVar.reward[2])
    if self:CanReward(rewardIndex) then 
        self:SetTaskBitValue(0, taskId, 1, {bit, bit});
        ChessReward:AppplyGetClientReward(self.moduleName, rewardIndex)
    end

    if RunFromEntry then
        ChessData.SetRewardCallback = SetRewardCallback
        local tbParam = {
            activityId = self.activityId, 
            activityType = self.activityType, 
            rewardIndex = rewardIndex
        }
        me:CallGS("chess.apply_get_reward", json.encode(tbParam))
    else
        ChessTools:ShowTip(string.format("拾取宝箱，奖励id: %d", rewardIndex), true)
        if ChessData.SetRewardCallback then
            ChessData.SetRewardCallback()
            ChessData.SetRewardCallback = nil
        end
    end
end

s2c.Register("chess.get_reward_callback", function(tbParam)
    if tbParam and #tbParam ~= 0 then
        UI.Open("GainItem", tbParam)
    end
    if ChessData.SetRewardCallback then
        ChessData.SetRewardCallback()
        ChessData.SetRewardCallback = nil
    end
end)

---得到当前地图是否已经完成
function ChessData:GetMapIsComplete(mapId)
    assert(mapId <= ChessReward.MaxMapId)
    return self:GetTaskBitValue(0, _GlobalVar.mapComplete, {mapId, mapId})
end

---设置当前地图已经完成
function ChessData:SetMapComplete(mapId)
    assert(mapId <= ChessReward.MaxMapId)
    self:SetTaskBitValue(0, _GlobalVar.mapComplete, 1, {mapId, mapId})
    local tbParam = {
        activityId = self.activityId, 
        activityType = self.activityType, 
        mapId = mapId
    }
    me:CallGS("chess.apply_map_complete", json.encode(tbParam))
end

----------------------------------------------------------------------------------
--- items
----------------------------------------------------------------------------------
--- 得到道具数量
---@param itemIndex 道具索引[1-999]
function ChessData:GetItemCount(itemIndex)
    assert(itemIndex < ChessData.MaxItemIndex);
    local taskId = self:GetMapTaskId("items", itemIndex);
    return self:GetTaskBitValue(self.mapId, taskId, _BitItem.count)
end

--- 增加道具数量
---@param itemIndex 道具索引[1-999]
---@param count 道具数量（总数不能超过65535）
function ChessData:AddItemCount(itemIndex, count)
    assert(itemIndex < ChessData.MaxItemIndex);
    local taskId = self:GetMapTaskId("items", itemIndex);
    local total = self:GetTaskBitValue(self.mapId, taskId, _BitItem.count) + count
    if total > 65535 then total = 65535 end
    if total < 0 then total = 0 end
    self:SetTaskBitValue(self.mapId, taskId, total, _BitItem.count)
end

--- 使用道具
---@param itemIndex 道具索引[1-999]
---@param count 道具数量
function ChessData:UseItem(itemIndex, count)
    assert(itemIndex < ChessData.MaxItemIndex);
    local taskId = self:GetMapTaskId("items", itemIndex);
    local total = self:GetTaskBitValue(self.mapId, taskId, _BitItem.count)
    total = total - count
    if total < 0 then total = 0 end
    self:SetTaskBitValue(self.mapId, taskId, total, _BitItem.count)
end

--- 清空道具
function ChessData:ResetItem(itemIndex)
    assert(itemIndex < ChessData.MaxItemIndex);
    local taskId = self:GetMapTaskId("items", itemIndex);
    self:SetTaskValue(self.mapId, taskId, 0)
end

----------------------------------------------------------------------------------
--- data save
----------------------------------------------------------------------------------
---保存时向服务器发消息
function ChessData:C2S_OnMapSave(tbMapId)
    for _, mapId in pairs(tbMapId) do
        assert(mapId <= ChessReward.MaxMapId)
    end
    local tbParam = {
        tbMapId = tbMapId,
        activityId = self.activityId, 
        activityType = self.activityType, 
        moduleName = self.moduleName,
    }
    me:CallGS("chess.apply_on_map_save", json.encode(tbParam))
end

----------------------------------------------------------------------------------
--- 加载运行时数据
function ChessData:LoadSave(moduleName, mapId)
    local value;
    if RunFromEntry then 
        local group, startId, endId = ChessReward:GetActivityInnerTaskStr(self.activityId, self.activityType)
        value = me:GetStrAttribute(group, startId + mapId)
    else 
        local key = string.format("chess_save_%s_%d", moduleName, mapId)
        value = UE4.UUserSetting.GetString(key, "")
        if value == "" then 
            return {}
        end
    end

    local tb = json.decode(value) or {}
    local tbRet = {}
    for _, v in ipairs(tb) do 
        if v[1] then 
            tbRet[v[1]] = v[2]
        end
    end
    return tbRet
end

--- 保存运行时数据
function ChessData:SaveData(moduleName, mapId, tbSave)
    -- 将数据转换为数值存储并排序，保证存档一致性
    local tbNew = {}
    for k, v in pairs(tbSave) do 
        table.insert(tbNew, {k, v})
    end
    table.sort(tbNew, function(a, b) return a[1] < b[1] end)

    local value = json.encode(tbNew)
    if RunFromEntry then 
        local group, startId, endId = ChessReward:GetActivityInnerTaskStr(self.activityId, self.activityType)
        local taskId = startId + mapId
        local old = me:GetStrAttribute(group, taskId)
        if value ~= old then 
            me:SetStrAttribute(group, taskId, value)
        end
    else 
        local key = string.format("chess_save_%s_%d", moduleName, mapId)
        UE4.UUserSetting.SetString(key, value)
        UE4.UUserSetting.Save()
    end
end

----------------------------------------------------------------------------------
ChessData:Init()
----------------------------------------------------------------------------------