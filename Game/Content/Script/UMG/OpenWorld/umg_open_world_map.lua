-- ========================================================
-- @File    : umg_open_world_map.lua
-- @Brief   : 开放世界
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self:DoClearListItems(self.ItemList)
    BtnAddEvent(self.BtnClose, function() UI.Close(self) end)
    BtnAddEvent(self.BtnAward, function() UI.Open("OpenWorldExploreAward") end)
    BtnAddEvent(self.BtnTrace, function() self:OnBtnClickTrace() end)
    BtnAddEvent(self.BtnTaskClose, function() WidgetUtils.Hidden(self.TaskDetail) end)
    BtnAddEvent(self.BtnTaskMask, function() WidgetUtils.Hidden(self.TaskDetail) end)
    BtnAddEvent(self.ResetPlayerPos,function ()
        self:ResetPlayerPosOnNearestNav()
        UI.Close(self)
    end)

    BtnAddEvent(self.TestPlayerOutMap,function ()
        local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
        if (not IsValid(PlayerController)) then
            return
        end
        local gamePlayer = self:GetOwningPlayer()
        if gamePlayer then
            local SweepResult = UE4.FHitResult()
            local pawn = gamePlayer:K2_GetPawn()
            if pawn then
                pawn:K2_SetActorLocation(pawn:K2_GetActorLocation() + UE4.FVector(10,10,0),false,SweepResult,true)
            end
        end
    end)
    self.Factory = Model.Use(self);
    self.MinMap:SetParent(self)
end

function tbClass:OnOpen(tbParam)
    WidgetUtils.ShowMouseCursor(self, true);
    UE4.UGameplayStatics.SetGamePaused(self, true)
    WidgetUtils.Hidden(self.TaskDetail)

    self.MinMap:Refresh()
    self.ProgressValue:SetText(string.format("%0.2f %%", OpenWorldMgr.GetTaskCompleteProgress() ))
    self.MoneyValue:SetText(OpenWorldMgr.GetMoneyCount())
end

function tbClass:OnClose()
    WidgetUtils.ShowMouseCursor(self, false);
    UE4.UGameplayStatics.SetGamePaused(self, false)
end

function tbClass:OnReturn()
    UE4.UGameplayStatics.SetGamePaused(self, false)
    UI.Close(self)
end

function tbClass:OnBtnClickTrace()
    print("OnBtnClickTrace")
    self:ShowTaskPath(self.currentTipClass.pointName)
    UI.Close(self)
end

--- 显示导航路
function tbClass:ShowTaskPath(pointName)
    local actor = UE4.UUMGLibrary.FindActorByName(self, pointName) 
    if actor then 
        local painter = UE4.ALevelPathPainter.GetLevelPathPainter(self)
        painter:SetPathEnd(actor, UE4.ELevelPathEndType.Main);
        painter:ShowLevelPath(true)
    end
end

--- 更新任务面版
function tbClass:UpdateTaskDetail(taskId)
    self:DoClearListItems(self.ItemList)
    local cfg = OpenWorldMgr.GetTaskCfg(taskId);
    local tbItems = Drop.GetPreview(cfg.DropId)

    for _, item in ipairs(tbItems) do 
        local tbData = {
            G = item[1], 
            D = item[2], 
            P = item[3],  
            L = item[4],  
            N = item[5] or 1,
        }
        local pObj = self.Factory:Create(tbData);
        self.ItemList:AddItem(pObj)
    end
end

function tbClass:ResetPlayerPosOnNearestNav( ... )
    local gameBaseMode = UE4.UGameplayStatics.GetGameMode(self):Cast(UE4.AGameBaseMode)
    if gameBaseMode then
        gameBaseMode:TrySetNearestPointOnNav()
    end
end

return tbClass