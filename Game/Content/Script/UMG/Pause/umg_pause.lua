-- ========================================================
-- @File    : umg_pause.lua
-- @Brief   : 暂停界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")


function tbClass:OnInit()
    BtnAddEvent(self.BtnLevelinfo, function()
        UI.Open('LevelInfo')
    end)

    BtnAddEvent(self.BtnSetUp, function()
        UI.Open('SetUp')
    end)

    BtnAddEvent(self.BtnGiveUp, function()
        self.DontHideMouseOnClose = true
        UI.Open('GiveUp')
    end)

    BtnAddEvent(self.BtnReturn, function()
        self:OnReturn()
    end)

    BtnAddEvent(self.BtnGiveUp_1, function()
        UI.Open('TrySkill')
    end)

    self.pPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
end

function tbClass:OnOpen(bPauseBtnDown, fnClosePauseCallback)
    self.DontHideMouseOnClose = false
    self.bPauseBtnDown = bPauseBtnDown
    UE4.UWwiseLibrary.PostEvent2D(GetGameIns(), "Play_UI_Fight_Open")
    EventSystem.TriggerToCpp(Event.UIOpenToCpp, self.sName)
    if fnClosePauseCallback then
        self.fnClosePauseCallback = fnClosePauseCallback
    end
    self:ExhaleMouse(true)
    UE4.UGameplayStatics.SetGamePaused(self, true)
    self:SetPlotPause(true)
    self.pPlayer:CancelSemiAutomaticFire(false)

    if Launch.GetType() == LaunchType.GUIDE and Map.GetCurrentID() == GuideLogic.PrologueMapID then
        --教学关卡隐藏放弃战斗和关卡信息
        WidgetUtils.Collapsed(self.PanelLevelInfo)
        WidgetUtils.Collapsed(self.PanelGiveUp)
        if GuideLogic.bCanSetUp then
            WidgetUtils.SelfHitTestInvisible(self.PanelSetUp)
        else
            WidgetUtils.Collapsed(self.PanelSetUp)
        end
        if GuideLogic.IsGuiding() then
            GuideLogic.EndGuide(true)
        end
    else
        WidgetUtils.Visible(self.PanelLevelInfo)
        WidgetUtils.Visible(self.PanelGiveUp)
        if GuideLogic.IsGuiding() then
            GuideLogic.SetGuidePaused(true)
        end
    end

    if GuideLogic.nNowStep and GuideLogic.nNowStep <= 5 and Map.GetCurrentID() == GuideLogic.PrologueMapID then
        WidgetUtils.Collapsed(self.PanelTryRoleSkill)
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelTryRoleSkill)
    end

    self.IsOnlineClient = UE4.UGameLibrary.IsOnlineClient(self:GetOwningPlayer())
    if self.IsOnlineClient then
        WidgetUtils.Collapsed(self.PanelTryRoleSkill)
        -- 联机BuffShop UI处理
        WidgetUtils.SelfHitTestInvisible(self.PanelBuff)
        BtnAddEvent(self.BtnBuff,function ()
            if not UI.IsOpen('FightOnlineAllBuff') then
                local pawn = self:GetOwningPlayerPawn()
                local buffList = pawn and pawn.RandomBufferes
                if buffList and buffList:Length() > 0 then
                    UI.Open('FightOnlineAllBuff')
                else
                    UI.ShowTip(Text('ui.TxtOnlineEvent11'))
                end
            end
        end)
    else
        WidgetUtils.Collapsed(self.BtnBuff)
    end

    if Map.GetCurrentID() ~= GuideLogic.PrologueMapID or GuideLogic.IsGuideComplete(1) then
        --暂停界面锁主角输入
        if self.pPlayer then
            self.pPlayer:StopAllInput(self.IsOnlineClient)
        end
    end

    local umg_simple_dialogue = UI.GetUI("SimpleDialogue")
    if umg_simple_dialogue then
        umg_simple_dialogue:OnGamePause(true)
    end

    self:UpdateStarInfo()
    UE4.UUIGameInstanceSubsystem.SwitchMouseEventNotice()

    if IsAndroid() or IsIOS() then 
        self.nGlobalInvalidationFlag = UE4.UKismetSystemLibrary.GetConsoleVariableIntValue("Slate.EnableGlobalInvalidation")
        if self.nGlobalInvalidationFlag == 1 then
            UE4.UKismetSystemLibrary.ExecuteConsoleCommand(GetGameIns(), "Slate.EnableGlobalInvalidation  0")
        end
    end
end

function tbClass:UpdateStarInfo()
    WidgetUtils.Collapsed(self.PanelStar)
    WidgetUtils.Collapsed(self.StarContent)
    local levelCfg
    if Launch.GetType() == LaunchType.CHAPTER then
        levelCfg = ChapterLevel.Get(Launch.GetLevelID())
        if not levelCfg or #levelCfg.tbStarCondition == 0 then
            return
        end
    elseif Launch.GetType() == LaunchType.DLC1_CHAPTER then
        levelCfg = DLCLevel.Get(Launch.GetLevelID())
        if not levelCfg or #levelCfg.tbStarCondition == 0 then
            return
        end
    else
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.PanelStar)
    WidgetUtils.SelfHitTestInvisible(self.StarContent)

    local pSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE4.ULevelStarTaskManager)
    if not pSubSys then
        WidgetUtils.Collapsed(self.StarContent)
        return
    end
    local Infos = pSubSys:GetStarTaskProperties()
    for i = 1, Infos:Length() do
        local pItem = Infos:Get(i)
        local pWidget = self.StarContent:GetChildAt(i - 1)
        if pWidget then
            local bHasGot = false
            if levelCfg and levelCfg.DidGotStar then
                bHasGot = levelCfg:DidGotStar(i-1)
            end
            pWidget:Set(pItem.bFinished, pItem.Description, pItem.CurrentState, bHasGot)
        end
    end
end

function tbClass:OnClose()
    if self.nGlobalInvalidationFlag == 1 then 
        UE4.UKismetSystemLibrary.ExecuteConsoleCommand(GetGameIns(), "Slate.EnableGlobalInvalidation  " .. self.nGlobalInvalidationFlag)
    end

    UE4.UWwiseLibrary.PostEvent2D(GetGameIns(), "Play_UI_Fight_Close")
    UE4.UGameplayStatics.SetGamePaused(self, false)
    self:SetPlotPause(false)

    if not self.DontHideMouseOnClose then
        self:ExhaleMouse(false)
    end
    if self.fnClosePauseCallback then
        self:fnClosePauseCallback()
        self.fnClosePauseCallback = nil
    end

    -- self.IsOnlineClient = UE4.UGameLibrary.IsOnlineClient(self:GetOwningPlayer())
    if Map.GetCurrentID() ~= GuideLogic.PrologueMapID or GuideLogic.IsGuideComplete(1) then
        if self.pPlayer then
            self.pPlayer:RestoreAllInput()
        end
    end


    if GuideLogic.IsGuiding() then
        GuideLogic.SetGuidePaused(false)
    end

    local umg_simple_dialogue = UI.GetUI("SimpleDialogue")
    if umg_simple_dialogue then
        umg_simple_dialogue:OnGamePause(false)
    end

    if Map.InFight() then
        UE4.UUIGameInstanceSubsystem.SwitchMouseEventNotice(false)
    end
end

function tbClass:OnReturn()
    UE4.UGameplayStatics.SetGamePaused(self, false)
    self:SetPlotPause(false)

    UI.Close(self)
    -- 协议动画继续播放
    if UE4.UGameLibrary.IsWindowsPlatform() and DialogueMgr.SetSequencePause(false) then 
        local fight = UI.GetUI("Fight")
        if fight then 
            WidgetUtils.Collapsed(fight)
        end
    end
end

function tbClass:SetPlotPause(bPause) 
    DialogueMgr.SetPause(bPause)
    
end

function tbClass:ExhaleMouse(bShow)
    RuntimeState.ChangeInputMode(bShow)
end

return tbClass