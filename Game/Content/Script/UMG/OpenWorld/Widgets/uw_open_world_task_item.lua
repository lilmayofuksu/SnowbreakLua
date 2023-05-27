-- ========================================================
-- @File    : uw_open_world_task_item.lua
-- @Brief   : 
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
	self:DoClearListItems(self.ItemList)
end

--- 得到任务点的名字
function tbClass:GetTaskPointId()
	return self.TaskPositionID;
end

function tbClass:SetTaskId(taskId)
	self.taskId = taskId;
	self.Factory = self.Factory or Model.Use(self);
	self.tbDatas = self.tbDatas or {}
	self.TaskPositionID = ""

	local cfg = OpenWorldMgr.GetTaskCfg(taskId);
	local tbPoints = OpenWorldMgr.GetPointCfg()
	if cfg then 
		local data = tbPoints.points[cfg.PointName];
		if data then 
			self.TaskPositionID = data.id
		end
	end
end

--- 直接设置文本内容
function tbClass:SetText(value)
	print("set text only", value)
	self:DoClearListItems(self.ItemList)
	self.tbDatas = {}
	local tbData = {desc = value}
	local pObj = self.Factory:Create(tbData);
	self.ItemList:AddItem(pObj)
end

--- 清空文本内容
function tbClass:ClearText()
	self.tbDatas = {}
	self:DoClearListItems(self.ItemList)
end

--- 当执行步骤变化时
function tbClass:OnExecuteChange(Execute)
	print("OnExecuteChange", Execute)
	for _, data in ipairs(self.tbDatas) do 
		if data.Execute == Execute then 
			data.onDataChange(Execute);
			return
		end
	end
end

--- 当任务流变化时
function tbClass:OnFlowChange(Flow)
	print("OnFlowChange", Flow)

    self.Title:SetText(Flow:GetUIDescription())
	self:DoClearListItems(self.ItemList)
    self.tbDatas = {}
    local AllExecuteNodes = Flow:GetAllInProgressExecuteNodes()
    if AllExecuteNodes == nil then
        return
    end
    
    for i = 1, AllExecuteNodes:Length() do
        local tbData = {Execute = AllExecuteNodes:Get(i), onDataChange = function() end }
		local pObj = self.Factory:Create(tbData);
        self.ItemList:AddItem(pObj)
        table.insert(self.tbDatas, tbData)
    end
end


return tbClass