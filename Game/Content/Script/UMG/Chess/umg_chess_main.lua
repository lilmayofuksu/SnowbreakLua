-- ========================================================
-- @File    : umg_chess_main.lua
-- @Brief   : 棋盘 - 主界面
-- ========================================================

local view = Class("UMG.BaseWidget")


function view:OnInit()
    self.playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
    BtnAddEvent(self.BtnEditor, function() self:OnBtnClickEditor() end)
    BtnAddEvent(self.BtnExit, function() self:OnBtnClickExit() end)
    BtnAddEvent(self.BtnBag, function() self:OnBtnClickBag() end)
    BtnAddEvent(self.BtnLog, function() self:OnBtnClickLog() end)
    BtnAddEvent(self.BtnHideAll, function() self:OnBtnClickArtEditor( not self.isArtEditorMode) end)
    --BtnAddEvent(self.BtnArtSave, function() self:OnBtnClickArtSave() end)
    BtnAddEvent(self.BtnArtMap, function() ChessClient:LoadArtMap() end)
    BtnAddEvent(self.BtnLog, function() UI.Open("ChessLog") end)
    BtnAddEvent(self.Replay, function()
        UI.Open("MessageBox", Text("ui.TxtChessReset"), function() ChessRuntimeHandler:ResetMap() end)
    end)
    BtnAddEvent(self.Btn, function()
        if ChessClient.gameMode and not ChessClient:GetLockControl() then
            ChessClient.gameMode.CameraFollow:ResetCamera()
        end
        WidgetUtils.Collapsed(self.Reset)
    end)
    self:RegisterEvent(Event.NotifyChessCameraTypeChange, function()
        WidgetUtils.SelfHitTestInvisible(self.Reset)
    end)
    self:OnBtnClickArtEditor(false)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.PanelEditor, IsEditor)
end

function view:OnOpen()
    self.Return:SetCustomEvent(function() GoToMainLevel() end, function() GoToMainLevel(function() UI.OpenMainUI(); UI.GC() end) end)
    self.SaveTimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                ChessData:Save()
            end
        },
        10,
        true
    )
    WidgetUtils.Collapsed(self.Mission2)
    local tbChessMap = ChessLogic.GetMapConf(ChessActivityType.DLC1, ChessClient.mapId)
    if tbChessMap then
        self.TxtName_1:SetText(Text(tbChessMap.sName))
    end
    -- local region = ChessClient.gameMode.MapBuilder:FindRegi on(1)
    -- local actor = region:FindGroundActor(-10, 0)
    -- print("actor is", actor:GetName(), actor:K2_GetActorLocation())

    -- UE4.Timer.Add(1, function() 
    --     EventSystem.Trigger(Event.NotifyShowChessInteraction, actor)

    --     EventSystem.Trigger(Event.NotifyChessTalkMsg, {actor = actor, msg = "测试内容", offset = 1})
    -- end)
end

function view:Tick(geometry, deltaSecond)
    self.uw_chess_panel_interaction:Update(deltaSecond)
    self.uw_chess_panel_msg:Update(deltaSecond)
end


function view:SetShowOrHide(isShow)
    if isShow then
        ChessClient:SetIsUIMode(false)
        WidgetUtils.SelfHitTestInvisible(self)
    else
        ChessClient:SetIsUIMode(true)
        WidgetUtils.Collapsed(self)
    end
end

function view:OnBtnClickEditor()
    UI.GetUI("ChessMap"):SetShowOrHide()
end

function view:OnBtnClickExit()
    if me:Id() > 0 and not me:IsOfflineLogin() then 
        GoToMainLevel();
    else 
        GoToLoginLevel()
    end
end

function view:OnMouseWheel(MyGeometry, MouseEvent)
    local delta = UE.UKismetInputLibrary.PointerEvent_GetWheelDelta(MouseEvent);
    if not self.CameraTarget then
        local CameraTargets = UE4.TArray(UE4.AChessCameraFollow)
        UE4.UGameplayStatics.GetAllActorsOfClass(self, UE4.AChessCameraFollow, CameraTargets)
        if CameraTargets:Length() == 0 then
            return
        end
        self.CameraTarget = CameraTargets:Get(1)
    end
    self.CameraTarget:OnZoomChange(delta * 50)
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function view:OnBtnClickBag()
    UI.Open("ChessBag")
end

function view:OnBtnClickLog()

end

function view:OnBtnClickArtEditor(value)
    self.isArtEditorMode = value
    if self.isArtEditorMode then 
        WidgetUtils.Collapsed(self.Root)
        WidgetUtils.Collapsed(self.BtnEditor)
    else 
        WidgetUtils.SelfHitTestInvisible(self.Root)
        WidgetUtils.Visible(self.BtnEditor)
    end
end

function view:OnBtnClickArtSave()
    ChessConfigHandler:SaveChessArt(ChessClient.gameMode)
    ChessTools:ShowTip("场景保存成功", true)
end

function view:BeginTask(cfg)
    self.curTaskCfg = cfg;
    self:RefreshTaskStatus() 
end

function view:RefreshTaskStatus()
    local cfg = self.curTaskCfg
    if not cfg then return end
    
    -- 推动箱子到指定位置: {taskVar=1}/{taskVar=1,max}
    local value = ChessTools:GetTaskContentDesc(nil, cfg.tbContent.desc)
    self.TxtDes1:SetContent(value)
    self.MissionName1:SetText(Text(cfg.tbArg.name))

    if ChessData:GetMapTaskIsComplete(cfg.tbArg.id) then 
        WidgetUtils.SelfHitTestInvisible(self.Complete)
    else 
        WidgetUtils.Collapsed(self.Complete)
    end
end

function view:RefreshSubTaskStatus()
    local allSubTask = ChessTask:GetCurrentTasks()
    local Index = 1
    for _, tbSubTask in pairs(allSubTask) do
        if Index > 2 then
            break
        end
        local cfg = tbSubTask.cfg
        if cfg and not ChessData:GetMapTaskIsComplete(cfg.tbArg.id) and not cfg.tbArg.main then
            local value = ChessTools:GetTaskContentDesc(nil, cfg.tbContent.desc)
            WidgetUtils.SelfHitTestInvisible(self["Panel".. Index])
            self["TxtDes".. (Index + 1)]:SetContent(value)
            self["MissionName".. (Index + 1)]:SetText(Text(cfg.tbArg.name))
            Index = Index + 1
        end
    end

    if Index == 1 then
        WidgetUtils.Collapsed(self.Mission2)
    else
        WidgetUtils.SelfHitTestInvisible(self.Mission2)
        for i = Index, 2 do
            WidgetUtils.Collapsed(self["Panel".. i])
        end
    end
end

-- 在OnMouseMove 和 OnTouchMoved之间切换 仅测试
function view:ChangeTouchWidget()
    if self.uw_chess_interaction:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
        WidgetUtils.Collapsed(self.uw_chess_interaction)
        WidgetUtils.SelfHitTestInvisible(self.uw_chess_interaction2)
    else
        WidgetUtils.Collapsed(self.uw_chess_interaction2)
        WidgetUtils.SelfHitTestInvisible(self.uw_chess_interaction)
    end
end

function view:SwitchChessInteractionState()
    if self.uw_chess_interaction:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
        WidgetUtils.Collapsed(self.uw_chess_interaction)
    else
        WidgetUtils.SelfHitTestInvisible(self.uw_chess_interaction)
    end
end

function view:OnClose()
    UE4.UKismetSystemLibrary.K2_ClearTimerDelegate(self, self.SaveTimerHandle)
end

return view