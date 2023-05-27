-- ========================================================
-- @File    : OpenWorldGameMode.lua
-- @Brief   : 开放世界游戏模式
-- ========================================================

local tbClass = Class()

function tbClass:ReceiveBeginPlay()
    Launch.SetType(LaunchType.OPENWORLD)

    UE4.Timer.Add(1, function()
        UI.Open("Fight")
        GM.TryOpenAdin()
        local tbUI = UI.GetUI("Fight");
        tbUI.LevelTaskOpenWorld:SetGameMode(self);
        self.TaskUI = tbUI.LevelTaskOpenWorld

        OpenWorldClient.RefreshTaskList()
        self:UpdateTaskStatus()

        self:ShowTaskMainPath()
    end)

    self.EventId = EventSystem.On(Event.NotifyRefreshOWTask, function() 
        self:UpdateTaskStatus()
    end)
end

function tbClass:ReceiveEndPlay()
    OpenWorldClient.onUpdateTaskCallBack = nil
    print("ReceiveEndPlaysssss");
    EventSystem.Remove(self.EventId)
end

-- 更新任务状态
function tbClass:UpdateTaskStatus(tbParam)
    self.mainTaskId = 0;
    self.randomTaskId = 0;
    local mainTaskRegionId = 0;
    local onlyMain = tbParam and tbParam.type == "onlyMain"

    local tb = OpenWorldClient.tbTaskIds
    print("UpdateTaskStatus", tb[1], tb[2], tb[3], tb[4], tb[5], tb[6], tb[7], tb[8])

    for _, id in ipairs(OpenWorldClient.tbTaskIds) do 
        -- 主线任务
        if OpenWorldMgr.IsTaskMain(id) then 
            if self.mainTaskId == 0 then
                self.mainTaskId = id;
                mainTaskRegionId = OpenWorldMgr.GetTaskCfg(id).RegionId
            end

        -- 分支或者随机任务
        elseif not onlyMain then 
            local cfg = OpenWorldMgr.GetTaskCfg(id);
            if cfg.RegionId == self.CurrentRegionId and cfg.RegionId ~= mainTaskRegionId then 
                self.randomTaskId = id;
            end
        end
    end

    self:_StopTask();
    self.TaskUI:SetTaskMainId(self.mainTaskId)
    self.TaskUI:SetTaskBranchId(self.randomTaskId)
end

--- 开始任务
function tbClass:_BeginTask(taskId) 
    local cfg = OpenWorldMgr.GetTaskCfg(taskId)
    if cfg then 
        self:BeginTask(taskId, cfg.ResPath, cfg.LevelLogic)
    else 
        printf_t("can not find task id " ..taskId)
    end
end

--- 结束任务
function tbClass:_StopTask()
    self.TaskUI:SetCurrentTaskType(nil)
    self:StopAllTask();
end

-- ========================================================
function tbClass:NotifyTaskComplete(regionId, taskId)
    print("lua task complete", regionId, taskId)
    
    -- 注册任务更新回调
    OpenWorldClient.onUpdateTaskCallBack = function()
        self:UpdateTaskStatus({type = "onlyMain"})
        
        if OpenWorldMgr.IsTaskMain(taskId) then 
            self:ShowTaskMainPath()
        end

        OpenWorldClient.onUpdateTaskCallBack = nil
    end

    -- 任务完成
    OpenWorldClient.SetTaskComplete(taskId)
end

--- 通知进入区域
---@param regionId integer 区域id
---@param changed bool 所在区域是否发生变化
function tbClass:NotifyEntryRegion(regionId, changed)
    print("lua entry region", regionId)

    if changed then
        self:UpdateTaskStatus()

        -- 检查是否触发主线任务
        local mainCfg = OpenWorldMgr.GetTaskCfg(self.mainTaskId);
        if mainCfg and mainCfg.RegionId == regionId then 
            self.TaskUI:SetCurrentTaskType("main")
            self:_BeginTask(self.mainTaskId)
            UI.ShowTip("触发主线任务")
            return;
        end

        -- 检查是否触发支线任务
        local branchCfg = OpenWorldMgr.GetTaskCfg(self.randomTaskId)
        if branchCfg and branchCfg.RegionId == regionId then 
            self.TaskUI:SetCurrentTaskType("random")
            self:_BeginTask(self.randomTaskId)
            UI.ShowTip("触发支线任务")
            return;
        end 
    else 
        if self:GetCurrentTaskId() > 0 then 
            UI.ShowTip("即将离开任务区域")
        end
    end
end

---通知离开区域
---@param regionId integer 区域id
---@param changed bool 所在区域是否发生变化
function tbClass:NotifyExitRegion(regionId, changed)
    print("lua exit region", regionId)
    if changed then
        self:UpdateTaskStatus()
    else 
        -- ;
    end
end

--- 通知任务失败
function tbClass:NotifyTaskFailed(FailedReason)
    print("game mode NotifyTaskFailed", FailedReason);
    if FailedReason == UE4.ELevelFailedReason.Dead then 
        print("NotifyTaskFailed UE4.ELevelFailedReason.Dead");
        UI.Open("OpenWorldPlayerDeath")
    elseif FailedReason == UE4.ELevelFailedReason.ManualExit then 
        Launch.End()
    end
end

--- 显示导航路
function tbClass:ShowTaskMainPath()
    local pointName = self.TaskUI.TaskMain:GetTaskPointId();
    if pointName == "" then return end

    local actor = UE4.UUMGLibrary.FindActorByName(self, pointName) 
    if actor then 
        local painter = UE4.ALevelPathPainter.GetLevelPathPainter(self)
        painter:SetPathEnd(actor, UE4.ELevelPathEndType.Main);
        painter:ShowLevelPath(true)
    end
end

return tbClass