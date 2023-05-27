----------------------------------------------------------------------------------
-- @File    : ChessTask.lua
-- @Brief   : 棋盘任务相关 
----------------------------------------------------------------------------------

---@class ChessTask 棋盘任务系统
ChessTask = ChessTask or {}

--[[
-- 任务触发条件（可以有多个）
-- 条件1，条件2，条件3

-- 任务参数：
    任务类型 - 主线，支线
    任务名
    是否追踪
    时间限制
    奖励id

-- 任务具体类型（收集物品，对话，战斗等等）

-- 事件 - 当任务开始时
--      行为1 隐藏物件
--      行为2 显示物件
-- 事件 - 当任务结束时
        行为1 
        行为2
-- 事件 - 当任务失败时
        行为1
        行为2
--]]

-- 类型
ChessTask.TypeCondition = "condition"		-- 任务条件
ChessTask.TypeEventBegin = "eventbegin"		-- 任务开始事件
ChessTask.TypeEventEnd = "eventend"			-- 任务结束事件
ChessTask.TypeEventFail = "eventfail"		-- 任务失败事件

-- 
ChessTask.InputTypeText = "text"           -- 输入文本
ChessTask.InputTypeCombo = "combo"         -- combo box
ChessTask.InputTypeGrids = "grids"         -- 选择格子
ChessTask.InputTypeTag = "tags"            -- 选择tag
ChessTask.InputTypeEvent = "event"         -- 选择Event Id
ChessTask.InputTypeObjectId = "objectId"   -- 选择物件 Id
ChessTask.InputTypeCheckBox = "checkbox"   -- 单选框
ChessTask.InputTypeItemId = "itemId"       -- 物品id
ChessTask.InputTypeRewardId = "rewardId"   -- 奖励id
ChessTask.InputTypeTaskId = "taskId"       -- 任务id
ChessTask.InputTypeTaskVarId = "taskVarId" -- 任务变量id
ChessTask.InputTypeModifyVar = "typeModifyVar" -- 修改变量类型

----------------------------------------------------------------------------------
--- 变量修改类型
ChessTask.TaskModifyType = {
	{id = 0, name = "无"},
	{id = 1, name = "增加"},
	{id = 2, name = "减少"},
	{id = 3, name = "设置"},
	{id = 4, name = "重置为初始值"},
}


----------------------------------------------------------------------------------
--- 初始化
function ChessTask:InitData()
	self.tbListeningEvent = {}
	self.tbListeningObject = {}

	for _, tbTask in ipairs(ChessConfigHandler:GetTaskDef()) do 
		for _, tbCond in ipairs(tbTask.tbCondition) do 
			if tbCond.id == "EventComplete" then 
				local tbEventId = tbCond.tbParam.eventId;
				if tbEventId then 
					for _, id in ipairs(tbEventId) do 
						self.tbListeningEvent[tonumber(id)] = true
					end
				end
			elseif tbCond.id == "ObjectComplete" then 
				local tbObjectId = tbCond.tbParam.objectId;
				if tbObjectId then 
					for _, id in ipairs(tbObjectId) do 
						self.tbListeningObject[tonumber(id)] = true
					end
				end
			end
		end
	end
end

--- 首次进入场景时
function ChessTask:OnGameInit()
	for _, tb in ipairs(ChessConfigHandler:GetTaskVarDef()) do 
		if tb.init ~= 0 then 
			ChessData:SetMapTaskVar(tb.id, tb.init)
		end
	end
	
	self.__isOnInit = true;
    self:UpdateCurrentTasks()
	self.__isOnInit = nil;
end

--- 每次进入场景
function ChessTask:OnGameStart()
	local tbList = self:UpdateCurrentTasks()
	if #tbList > 0 then 
		for _, id in ipairs(tbList) do 
			local cfg = ChessConfigHandler:GetTaskById(id)
			if cfg and cfg.tbArg.trace and cfg.tbArg.main then
				self:NotifyUIBeginTask(cfg)
				break
			end
		end
	else 
		local maxId = -1;
		for _, tbTask in ipairs(ChessConfigHandler:GetTaskDef()) do 
			local id = tbTask.tbArg.id
			if ChessData:GetMapTaskIsComplete(id) then 
				maxId = math.max(id, maxId)
			end
		end
		if maxId > 0 then 
			local cfg = ChessConfigHandler:GetTaskById(maxId) 
			self:NotifyUIBeginTask(cfg)
		end
	end
	self:NotifyUIUpdateAllSubTask()
end

--- 当事件完成时
function ChessTask:OnEventComplete(eventId)
	eventId = tonumber(eventId)
	if not self.tbListeningEvent[eventId] then return end 

	self.currentCompleteEventId = eventId
	self:UpdateCurrentTasks()
	self.currentCompleteEventId = nil;
end

--- 当物件完成时
function ChessTask:OnObjectComplete(objectId)
	objectId = tonumber(objectId)
	if not self.tbListeningObject[objectId] then return end 

	self.currentCompleteObjectId = objectId
	self:UpdateCurrentTasks()
	self.currentCompleteObjectId = nil;
end

--- 得到所有解锁的任务（未必触发）
function ChessTask:GetAllUnlockTasks()
	local tbTaskId = {}
	for _, tbTask in ipairs(ChessConfigHandler:GetTaskDef()) do 
		local id = tbTask.tbArg.id
		local preTaskId = ChessConfigHandler:GetTaskPreTaskId(tbTask)
		if preTaskId then 
			preTaskId = preTaskId[1]
		end
		preTaskId = preTaskId or 0
		if not ChessData:GetMapTaskIsComplete(id) and ((preTaskId == 0) or ChessData:GetMapTaskIsComplete(preTaskId)) then 
			table.insert(tbTaskId, {id = id, cfg = tbTask})
		end
	end
	return tbTaskId;
end

--- 更新所有正在进行的任务
function ChessTask:UpdateCurrentTasks()
	local tbTasks = self:GetAllUnlockTasks()
	local tbRet = {}
	for i = 1, #tbTasks do 
		local one = tbTasks[i]
		local ok = #one.cfg.tbCondition > 0
		for _, tbCondition in ipairs(one.cfg.tbCondition) do 
			local class = ChessTaskCondition:FindClassById(tbCondition.id)
			if class and not class:OnCheck(tbCondition.tbParam or {}) then 
				ok = false
				break
			end
		end
		if ok then 
			table.insert(tbRet, one.id)
		end
	end
	if #tbRet == 0 then return ChessData:GetCurrentTaskIds() end

	local tbCurTaskId = ChessData:GetCurrentTaskIds();
	for i = 1, #tbRet do 
		if not ChessTools:Contain(tbCurTaskId, tbRet[i]) then 
			self:RunTask(tbRet[i]);
		end
	end

	for _, id in ipairs(tbCurTaskId) do 
		if not ChessTools:Contain(tbRet, id) then 
			table.insert(tbRet, id)
		end
	end
	
	ChessData:SetCurrentTaskIds(tbRet)
	return tbRet
end

--- 开始任务
function ChessTask:BeginTask(tbTaskId)
	local tbCurTaskId = ChessData:GetCurrentTaskIds();
	for _, id in ipairs(tbTaskId) do 
		table.insert(tbCurTaskId, 1, id)
		self:RunTask(id);
	end
	ChessData:SetCurrentTaskIds(tbCurTaskId)
	self:NotifyUIUpdateAllSubTask()
	ChessClient:SetDataDirty()
end

--- 完成任务 
function ChessTask:CompleteTask(tbTaskId)
	local updated = false
	for _, id in ipairs(tbTaskId) do 
		if not ChessData:GetMapTaskIsComplete(id) then 
			ChessData:SetMapTaskIsComplete(id)
			local cfg = ChessConfigHandler:GetTaskById(id)
			local tbRewardId = cfg.tbArg.rewardId
			if tbRewardId and type(tbRewardId) == "table" then
				local rewardId = tbRewardId[1]
				if ChessData:CanReward(rewardId) then
					ChessData:SetReward(rewardId)
				end
			end
			ChessClient:WriteOperationLog(cfg.tbArg.main and 6 or 7, self:GetTaskExParam(id, cfg.tbArg.main))
			self:ShowTaskCompleteEffect(id)
			updated = true;
		end
	end

	if not updated then return end
	ChessClient:SetDataDirty()
	local tbList = self:UpdateCurrentTasks()
	if #tbList > 0 then 
		for _, id in ipairs(tbList) do 
			local cfg = ChessConfigHandler:GetTaskById(id)
			if cfg and cfg.tbArg and cfg.tbArg.main and cfg.tbArg.trace then
				self:NotifyUIBeginTask(cfg)
				self:NotifyUIUpdateAllSubTask()
				return;
			end
		end
	end

	local ui = UI.GetUI("ChessMain");
	if ui then ui:RefreshTaskStatus() end
end

--- 得到所有正在进行的任务
function ChessTask:GetCurrentTasks()
	local tbTaskIds = ChessData:GetCurrentTaskIds()
	local tbTask = {}
	for i = 1, #tbTaskIds do 
		local cfg = ChessConfigHandler:GetTaskById(tbTaskIds[i])
		table.insert(tbTask, {id = i, cfg = cfg})
	end
	return tbTask
end

--- 当有变量变化时，更新任务进度
function ChessTask:UpdateTaskIsComplete()
	local ok = false
	local tbTasks = self:GetCurrentTasks()
	for i = 1, #tbTasks do 
		local one = tbTasks[i]
		if ChessTaskCompleteCondition:CheckIsComplete(one.cfg) then 
			ChessData:SetMapTaskIsComplete(one.id)
			ok = true
			self:ShowTaskCompleteEffect(one.id)
		end
	end

	-- 刷新任务
	if ok then 
		self:UpdateCurrentTasks()
	end
end

function ChessTask:GetTaskExParam(taskId, bMain)
	local nComplete = 0
	local tbList = {}
	if bMain then
		tbList = ChessConfigHandler:GetAllMainTask()
		for _, tbData in pairs(tbList) do
			if ChessData:GetMapTaskIsComplete(tbData.tbArg.id) then
				nComplete = nComplete + 1
			end
		end
	else
		tbList = ChessConfigHandler:GetAllSubTask()
		for _, tbData in pairs(tbList) do
			if ChessData:GetMapTaskIsComplete(tbData.tbArg.id) then
				nComplete = nComplete + 1
			end
		end
	end
	return string.format("%d-%d-%d", taskId, nComplete, #tbList)
end

----------------------------------------------------------------------------------
--- 开始执行任务
function ChessTask:RunTask(taskId)
	local cfg = ChessConfigHandler:GetTaskById(taskId)
	if not cfg then return end 
	
	-- 运行各个任务
	-- 事件参数支持 modifyTaskValue
	self:NotifyUIBeginTask(cfg)
	self:ShowTaskBeginEffect(taskId)
end

function ChessTask:NotifyUIBeginTask(cfg)
	local ui = UI.GetUI("ChessMain");
	if ui and cfg.tbArg.trace and cfg.tbArg.main then 
		ui:BeginTask(cfg)
	end
end

function ChessTask:NotifyUIUpdateAllSubTask()
	local ui = UI.GetUI("ChessMain");
	if ui then 
		ui:RefreshSubTaskStatus()
	end
end

--- 显示任务开始特效
function ChessTask:ShowTaskBeginEffect(taskId)
	local cfg = ChessConfigHandler:GetTaskById(taskId)
	cfg.bStart = true
	ChessClient:StopMovementImmediately()
	ChessTools:ShowTip(Text("ui.TxtChessTips3", Text(cfg.tbArg.name)), true, true, cfg)
end

--- 显示任务完成特效
function ChessTask:ShowTaskCompleteEffect(taskId)
	local cfg = ChessConfigHandler:GetTaskById(taskId)
	cfg.bStart = false
	ChessTools:ShowTip(Text("ui.TxtChessTips4", Text(cfg.tbArg.name)), true, true, cfg)
end

----------------------------------------------------------------------------------
---请求修改变量值
---@param varId 变量id
---@param modifyType 修改类型 - 见定义 ChessTask.TaskModifyType 
---@param modifyValue 修改值
function ChessTask:ApplyModifyTaskVar(varId, modifyType, modifyValue)
	if type(varId) == "table" then 
		varId = varId[1]
	end
	local cfg = ChessConfigHandler:GetTaskVarById(varId)
	if not cfg then return end 
	local curValue = ChessData:GetMapTaskVar(varId)
	local newValue;
	if modifyType == 0 then 
		return
	elseif modifyType == 1 then 
		newValue = curValue + modifyValue
	elseif modifyType == 2 then 
		newValue = curValue - modifyValue
	elseif modifyType == 3 then
		newValue = modifyValue
	elseif modifyType == 4 then
		newValue = cfg.init 
	else 
		assert(false)
	end
	newValue = math.max(newValue, cfg.min)
	newValue = math.min(newValue, cfg.max)
	if newValue == curValue then 
		return 
	end 
	ChessData:SetMapTaskVar(varId, newValue)
	self:UpdateTaskIsComplete()
end

--- 通过修改id找修改名
function ChessTask:FindModifyTypeNameById(id)
	for _, tb in ipairs(self.TaskModifyType) do 
		if tb.id == id then 
			return tb.name
		end
	end
	return ""
end

--- 通过修改名找修改id
function ChessTask:FindModifyTypeIdByName(name)
	for _, tb in ipairs(self.TaskModifyType) do 
		if tb.name == name then 
			return tb.id
		end
	end
	return 0
end

----------------------------------------------------------------------------------