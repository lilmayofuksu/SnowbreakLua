-- ========================================================
-- @File    : umg_dungeons.lua
-- @Brief   : 出击主界面
-- ========================================================
---@class tbClass : ULuaWidget
local tbClass = Class("UMG.BaseWidget")

tbClass.GyroOffsetUI = UE4.FVector2D(30, 20)
tbClass.GyroOffsetScene = UE4.FVector(-30, -30, 0)

tbClass.InputOffset = UE4.FVector2D(0, 0)

function tbClass:OnInit()
    BtnAddEvent(self.BtnLevel, function() FunctionRouter.GoTo(FunctionType.Chapter) end)
    BtnAddEvent(self.BtnChallenge, function() FunctionRouter.GoTo(FunctionType.Challenge) end)
    BtnAddEvent(self.BtnTime, function() FunctionRouter.GoTo(FunctionType.TimeActivitie) end)
    BtnAddEvent(self.BtnResourse, function() FunctionRouter.GoTo(FunctionType.DungeonsResourse) end)
    BtnAddEvent(self.BtnStory, function() FunctionRouter.GoTo(FunctionType.RoleLevel) end)

    if OpenWorldMgr.IsOpen() then
        BtnAddEvent(self.BtnBigWorld, function() self:GotoOpenWorld() end)
    else
        WidgetUtils.Hidden(self.PanelBigWorld)
    end

    self.tb3DSlot = {}
    self:Get3DWidgets(self.CanvasPanel_113, self.tb3DSlot)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.e_ui_panel_glow_p, UE4.UDeviceProfileLibrary.GetDeviceProfileLevel() > 0)

    UE4.Timer.Add(0.1, function()
        local tb = {'CustomText_guzhang', 'CustomText_guzhang_1', 'CustomText_guzhang_4',
        'CustomText_guzhang_2', 'CustomText_guzhang_3', 'CustomText_51guzhang'}
        for _, name in pairs(tb) do
            if self[name] then
                self[name]:SetRetainRendering(false)
                self[name].RenderOnPhase = false
            end
        end
    end)
end

function tbClass:OnOpen()
    local bPoping = UI.bPoping
    PreviewScene.Enter(PreviewType.Dungeons, function()
        local logic = PreviewScene.Class('Dungeons')
        if logic and logic.PlaySequence then
            if bPoping then
                if UI.LastTop == "chapter" then
                    logic:PlaySequence(1, false, 0)
                elseif UI.LastTop == "dungeonsresourse" then
                    logic:PlaySequence(2, false, 0)
                elseif UI.LastTop == "challenge" then
                    logic:PlaySequence(3, false, 0)
                elseif UI.LastTop == "dungeonsonline" then
                    logic:PlaySequence(4, false, 0)
                elseif UI.LastTop == "dungeonsrole" then
                    logic:PlaySequence(5, false, 0)
                else
                    logic:PlaySequence(0, true)
                end
            else
                logic:PlaySequence(1, false, 0)
            end
            if IsMobile() then
                self.TimerIdx = UE4.Timer.Add(1.1, function()
                    self.ActiveGyro = true
                    self.TimerIdx = nil
                    PreviewMain.LoadBG(function()
                        self.GyroActor = PreviewMain.GetBG()
                        local pCameraManger = UE4.UGameplayStatics.GetPlayerCameraManager(self, 0)
                        if pCameraManger then
                            self.ViewTarget = pCameraManger.ViewTarget.Target
                            self.ViewOrgPos = self.ViewTarget:K2_GetActorLocation()
                        end
                        PreviewMain.ActiveGyro(true)
                        PreviewMain.SetBgVisble(false)
                    end, false)
                end)
            end
        end
    end)

    --PreviewScene.Enter(PreviewType.role_lvup)
    self:ShowOnline()
    self:UpdateChallengeState()
    self:UpdateResourseState()
    self:UpdateRoleState()
    self:PlayAnimation(self.AllEnter)
end

function tbClass:GotoOpenWorld()
    Launch.SetType(LaunchType.OPENWORLD)
    UI.Open('OpenWorldEnter')
end

--联机按钮相关显示
function tbClass:ShowOnline()
    local tbShowList = Online.GetAllOpenList()
    if #tbShowList == 1 then
        self.TxtName:SetText(Text(tbShowList[1].sName))
    else
        self.TxtName:SetText(Text("ui.TxtOnlineMulti"))
    end
    local bUnlock = FunctionRouter.IsOpenById(FunctionType.TimeActivitie) and #tbShowList > 0
    if bUnlock then
        WidgetUtils.HitTestInvisible(self.Open)
        WidgetUtils.HitTestInvisible(self.Image)
        WidgetUtils.Collapsed(self.BtnLock)
    else
        WidgetUtils.Collapsed(self.Open)
        WidgetUtils.Collapsed(self.Image)
        WidgetUtils.HitTestInvisible(self.BtnLock)
    end
    self.TxtBg_5:SetRenderOpacity(bUnlock and 1 or 0.4)
end

function tbClass:UpdateChallengeState()
    local bUnlock = FunctionRouter.IsOpenById(FunctionType.Challenge)
    if bUnlock then
        WidgetUtils.Collapsed(self.BtnLockChallenge)
        WidgetUtils.HitTestInvisible(self.Image_351)
    else
        WidgetUtils.HitTestInvisible(self.BtnLockChallenge)
        WidgetUtils.Collapsed(self.Image_351)
    end
    self.TxtBg_1:SetRenderOpacity(bUnlock and 1 or 0.4)
end

function tbClass:UpdateResourseState()
    local bUnlock = FunctionRouter.IsOpenById(FunctionType.DungeonsResourse)
    if bUnlock then
        WidgetUtils.Collapsed(self.BtnLockResourse)
        WidgetUtils.HitTestInvisible(self.Image_131)

        local HasNew = false
        for _, tbCfg in pairs(Daily.GetCfg()) do
            if Condition.Check(tbCfg.tbCondition) then
                for _, nChapterID in ipairs(tbCfg.tbChapter or {}) do
                    local cfg = DailyChapter.Get(1, nChapterID)
                    for _, levelId in ipairs(cfg.tbLevel) do
                        local levelConf = DailyLevel.Get(levelId)
                        if levelConf and DailyLevel.IsNew(levelConf) then
                            HasNew = true
                            break
                        end
                    end
                end
            end
        end
        WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.ResourseNew, HasNew)
    else
        WidgetUtils.HitTestInvisible(self.BtnLockResourse)
        WidgetUtils.Collapsed(self.Image_131)
        WidgetUtils.Collapsed(self.ResourseNew)
    end
    self.TxtBg_2:SetRenderOpacity(bUnlock and 1 or 0.4)
end

function tbClass:UpdateRoleState()
    local bUnlock = FunctionRouter.IsOpenById(FunctionType.RoleLevel)
    if bUnlock then
        WidgetUtils.Collapsed(self.BtnLockStory)
        WidgetUtils.HitTestInvisible(self.Image_131)
    else
        WidgetUtils.HitTestInvisible(self.BtnLockStory)
        WidgetUtils.Collapsed(self.Image_131)
    end
    self.TxtBg_3:SetRenderOpacity(bUnlock and 1 or 0.4)
end

function tbClass:Get3DWidgets(widget, tb)
    local List = UE4.TArray(UE4.UCanvasPanel3D)
    UE4.UUMGLibrary.GetAll3DPanel(widget, List)
    for i = 1, List:Length() do
        local slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(List:Get(i))
        if slot then table.insert(tb, slot) end
    end
end

function tbClass:Move3DSlot(Vec)
    for _, slot in pairs(self.tb3DSlot) do
        slot:SetPosition(Vec)
    end
end

function tbClass:Tick()
    if self.ActiveGyro and self.GyroActor then
        local Input = self.GyroActor:GetInputPercent()
        if not self.bInitGyroOffset and (Input.X ~= 0 or Input.Y ~= 0) then
            self.InputOffset = Input
            self.bInitGyroOffset = true
            print('InputOffset', self.InputOffset)
        end
        Input = Input - self.InputOffset
        self:Move3DSlot(Input * self.GyroOffsetUI)
        if self.ViewTarget then
            self.ViewTarget:K2_SetActorLocation(self.ViewOrgPos + UE4.FVector(Input.X, Input.Y, 0) * self.GyroOffsetScene)
        end
    end
end

function tbClass:ClearGyro()
    if self.TimerIdx then UE4.Timer.Cancel(self.TimerIdx); self.TimerIdx = nil end
    PreviewMain.ActiveGyro(false)
    PreviewMain.DestroyBG()
    self.ActiveGyro = false
    self.GyroActor = nil
    self.ViewTarget = nil
    self.bInitGyroOffset = false
    self.InputOffset = UE4.FVector2D(0, 0)
    self:Move3DSlot(UE4.FVector2D(0, 0))
end

function tbClass:OnClose()
    self:ClearGyro()
end

function tbClass:OnDisable()
    self:ClearGyro()
end

return tbClass