-- ========================================================
-- @File    : uw_open_world_task.lua
-- @Brief   : 
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
   print("uw_open_world_task Construct ", self.Image_55, self.TaskMain, self.BtnTest)

	if Launch.GetType() == LaunchType.OPENWORLD then 
		self.event1 = EventSystem.On(Event.OnExecuteChange, function(Execute) self:OnExecuteChange(Execute) end)
		self.event2 = EventSystem.On(Event.OnFlowChange, function(Flow) self:OnFlowChange(Flow) end)
	else 
		print("open world is false: ", Launch.GetType());
	end
end

function tbClass:SetGameMode(gameMode)
	self.gameMode = gameMode
end

function tbClass:SetTaskMainShow(show)
	if show then 
		WidgetUtils.Visible(self.TaskMain)
	else 
		WidgetUtils.Collapsed(self.TaskMain)
	end
end

function tbClass:SetTaskBranchShow(show)
	if show then 
		WidgetUtils.Visible(self.TaskBranch)
	else 
		WidgetUtils.Collapsed(self.TaskBranch)
	end
end 

function tbClass:SetTaskMainId(taskId)
	self.TaskMain:SetTaskId(taskId)
	self:SetTaskMainShow(taskId > 0)

	local cfg = OpenWorldMgr.GetTaskCfg(taskId)
	if cfg then 
		self.TaskMain:SetText(cfg.Desc)
	end
end

function tbClass:SetTaskBranchId(taskId)
	self.TaskBranch:SetTaskId(taskId)
	self:SetTaskBranchShow(taskId > 0)

	if taskId > 0 then 
		self.TaskBranch:ClearText()
	end
end

--- 设置当前任务类型: main random
function tbClass:SetCurrentTaskType(type)
	self.CurrentTaskType = type
end

function tbClass:OnExecuteChange(Execute)
	print("OnExecuteChange")
	if self.CurrentTaskType == "main" then 
		self.TaskMain:OnExecuteChange(Execute)
	elseif self.CurrentTaskType == "random" then 
		self.TaskBranch:OnExecuteChange(Execute)
	end
end

function tbClass:OnFlowChange(Flow)
	print("OnFlowChange")
	if self.CurrentTaskType == "main" then 
		self.TaskMain:OnFlowChange(Flow)
	elseif self.CurrentTaskType == "random" then 
		self.TaskBranch:OnFlowChange(Flow)
	end
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.event1)
    EventSystem.Remove(self.event2)
    self.gameMode = nil;
end

return tbClass