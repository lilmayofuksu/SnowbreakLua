-- ========================================================
-- @File    : umg_fight.lua
-- @Brief   : 战斗界面
-- ========================================================

--- @class umg_fight : UI_Template
local tbClass = Class("UMG.BaseWidget")


function tbClass:OnInit()
    self.AimCrossHairNodes = {}
    self.AimWidget = nil
    self.CurPlayer = nil
    self.bInAiming = false
    self.InitTime = UE4.UGameplayStatics.GetTimeSeconds(self)
    self.CurSkillSelectorIndex = -1;

    BtnAddEvent(self.BtnGM, function()  self:OnOpenGM()  end )

    if WithEditor then
        WidgetUtils.SetVisibleOrCollapsed(self.BtnGM, GM.TryOpenAdin())
    else
        GM.TryOpenAdin()
        WidgetUtils.Collapsed(self.BtnGM)
    end

    -- 初始化屏蔽战斗UI信息
    self:InitHideFightWidgetInfo();

    -- self.uw_Storagebar:OnInit()
    self:CenterBreakTag(false)
    local OwnerPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)

    if OwnerPlayer ~= nil then
        OwnerPlayer.OnPlayerInitComplate:Add(self, function(InCharacter)
            self:OnPlayerChange()
        end
    )
    end
    self:OnPlayerChange()

    BtnAddEvent(self.BtnOpenWorld, function() UI.Open('OpenWorldMap')  end)
    BtnAddEvent(self.BtnOpenWorldMap, function() UI.Open('OpenWorldDebugMap')  end)
    self.Pause.pauseNew.OnClicked:Add(self, function()
        -- UI.Open('PauseNew')
        self:OpenPause(false)
    end)

    self.bPause = false
    self.PauseHandle = EventSystem.On( Event.PauseGame, function(bDownESC)
        if GuideLogic.IsGuiding() and GuideLogic.CanPauseGame==0 then
            return
        end
        if DialogueMgr.IsPlayingSequence() then 
            return
        end
        if Launch.LevelHasFinished then
            return
        end
        local TopUI = UI.GetTop()

        if TopUI and TopUI ~= self and TopUI:CanEsc() == false then return end

        if TopUI and TopUI ~= self then
            local pChild = TopUI:GetTopChild()
            if pChild and pChild:CanEsc() == false then  return end
        end
        
        if TopUI and TopUI ~= self and TopUI:CanEsc() then
            if not UI.CloseTopChild() then UI.CloseTop() end
            return
        end

        if not UI.GetUI("MessageBox") and not UE4.UUMGLibrary.IsPlayingNormalPlot() then
            self:OpenPause(bDownESC)
        end
    end)

    self.gamepadReturnHandle = EventSystem.On(Event.GamepadReturn, function()
        if GuideLogic.IsGuiding() then
            if GuideLogic.IsHelpGuiding() then
                local ui = UI.GetUI("guide")
                if ui then
                    ui:GotoNextStep()
                end
            else
                return
            end
        end
        if DialogueMgr.IsPlayingSequence() then
            return
        end
        local TopUI = UI.GetTop()
        if TopUI and TopUI ~= self and TopUI:CanEsc() then
            if not UI.CloseTopChild() then UI.CloseTop() end
            return
        end
    end)

    self:RegisterEvent( Event.CharacterChange, function()
        self:OnPlayerChange()
    end)

    self:RegisterEvent( Event.LevelStarUpdate, function (taskStar)
        self.StarTips:LevelStarUpdate(taskStar)
    end)

    self:RegisterEvent(Event.OnChallengeStart, function(ExecuteNode)
        local ChallengId = ExecuteNode.DescArgs:Get(1)
        self.ChallengTimeSuperiorLimit = ExecuteNode.DescArgs:Get(2)
        local name = Text('challenge.'..ChallengId..'_Name')
        local desc = Text('challenge.'..ChallengId..'_Desc')
        if ExecuteNode.DescArgs:Length() > 1 then
            local tbArgs = {}
            for i=3,ExecuteNode.DescArgs:Length() do
                table.insert(tbArgs, ExecuteNode.DescArgs:Get(i))
            end
            desc = string.format(desc, table.unpack(tbArgs))
        end

        self.Sudden.TxtNameOn:SetText(name)
        self.Sudden.TxtDescOn:SetText(desc)
        self.Sudden.TxtNameOff:SetText(name)
        self.Sudden.TxtDescOff:SetText(desc)

        if not WidgetUtils.IsVisible(self.Sudden) and not self.InSudden then
            self.InSudden = ExecuteNode:OnSudden(name, desc)
            if self.ChallengTimeSuperiorLimit > 0 then
                self:SetSuddenBarParam(curTime, self.ChallengTimeSuperiorLimit, true)
                WidgetUtils.SelfHitTestInvisible(self.Sudden.BarTime)
            else
                WidgetUtils.Collapsed(self.Sudden.BarTime)
            end
        end

        if self.ChallengTimeSuperiorLimit > 0 then
            local curTime = ExecuteNode.DescArgs:Get(3)
            self:SetSuddenBarParam(curTime, self.ChallengTimeSuperiorLimit)
        end
    end)

    self:RegisterEvent(Event.ShowSudden, function ()
        WidgetUtils.SelfHitTestInvisible(self.Sudden)
    end)

    self:RegisterEvent(Event.OnChallengeFinish, function ()
        self.InSudden = false;
        WidgetUtils.Collapsed(self.Sudden)
    end)

    -- 队友复活万向轮b
    self.tbReviveTip = {}
    --self:RegisterEvent(Event.NotifyTeammateDeathBegin, function(Index, Actor) self:NotifyTeammateDeathBegin(Index, Actor) end)
    --self:RegisterEvent(Event.NotifyTeammateDeathEnd, function(Index) self:NotifyTeammateDeathEnd(Index) end)
    self:RegisterEvent(Event.NotifyShowMsg, function(msg)
        if msg == 'no_revive_count' then UI.ShowMessage('ui.TxtOnlineEvent12') end
    end)
    if OwnerPlayer then
        ---@param OwnerPlayer AGamePlayerController
        OwnerPlayer.OnReloadWeapon:Add(self, function(Target, bIsReload, TotalTime)
                if bIsReload then
                    WidgetUtils.SelfHitTestInvisible(self.uw_fight_reload)
                    WidgetUtils.Collapsed(self.uw_fight_collimation)
                    self.uw_fight_collimation:Clear()
                else
                    WidgetUtils.SelfHitTestInvisible(self.uw_fight_collimation)
                    WidgetUtils.Collapsed(self.uw_fight_reload)
                end
            end
        )
        ---开镜处理
        OwnerPlayer.OnShowAimMask:Add(self, function(InTarget, bInAiming)
               self:OnShowAimMask(bInAiming)
            end
        )
        ---
        OwnerPlayer.OnSetAimTargetPosition:Add( self, function(InTarget, InPos)
                self:SetAimPos(InPos)
            end
        )

        OwnerPlayer.OnAim:Add(self, function (InTarget, bInAiming)
            self:OnAim(bInAiming)
        end)

        self:SetAimPos(OwnerPlayer:GetAimTargetPosition())
    end


    -- 部分特殊指引，隐藏切换角色按钮或者部分技能按钮
    GuideLogic.HiddenSomeBtn(self)

    --[[self:RegisterEvent(Event.,function ( ... )
        CreateItem
    end)]]

    self:RegisterEvent(Event.NotifyBufferShopState,function (shopId,shopState)
        if shopState == 1 then
            self:ShowOnlineShopTips(shopId,true)
        end
    end)

    self:RegisterEvent(Event.NotifyBufferShopHideTip,function (shopId)
        self:ShowOnlineShopTips(shopId,false)
    end)

    self:RegisterEvent(Event.CharacterChange,function()
            self:CharacterChange()
        end)

    --[[self:RegisterEvent(Event.OnInputDeviceChange, function()
        self:UpdateKeyShow()
    end)--]]

    self.nEventUpdateControl = EventSystem.On(Event.UpdateControl, function()
        self:UpdateControl()
    end)

    self.OnVisibilityChanged:Add(self, function(_, InVisibility)        
        if InVisibility == UE4.ESlateVisibility.Visible or InVisibility == UE4.ESlateVisibility.HitTestInvisible or InVisibility == UE4.ESlateVisibility.SelfHitTestInvisible then
            UE4.UUMGLibrary.PlayAnimation(self, self.AllEnter)
            self:OpenDamage()
        else
            self:CloseDamage()
        end
    end)

    if IsMobile() then
        self.tbCustomize = {
            self.SkillPanel.Aim, -- Panel 1
            self.SkillPanel.AimFire, -- Panel 2
            self.BossHp, --3
            self.SkillPanel.Cancel, -- Panel -- 4 
            self.SkillPanel.Fire, -- Panel -- 5
            self.Hp,  -- 6
            self.InteractList, -- 7,
            self.Pause, -- 8
            self.SkillPanel.LeftFireBtn, -- Panel 9
            self.PlayerSelect, -- 10
            self.Time, -- 11
            self.SkillPanel.Reload, -- Panel 12
            self.Teammate, -- 13
            self.SkillPanel.Skill1, -- Panel 14
            self.SkillPanel.Skill3, -- Panel 15
            self.SkillPanel.Skill5, -- Panel 16
            self.JoyStick.JoyStick,-- JPanel 17
            self.JoyStick.CheckKeepRun, -- JPanel 18
            self.LevelTask,  -- Panel 19
            self.SkillPanel.Jump -- 20
        }
    end
end

function tbClass:CharacterChange()
    local Player = self:GetOwningPlayerPawn()
    if not Player then
        return
    end
    if self.CurPlayer then
        self.CurPlayer.OnNotifyEquipedWeapon:Remove(self, self.NotifyEquipedWeapon)
    end
    local OwnerPlayer = Player:Cast(UE4.AGameCharacter)    
    if not OwnerPlayer then return end
    self.CurPlayer = OwnerPlayer
    self.CurPlayer.OnNotifyEquipedWeapon:Add(self, self.NotifyEquipedWeapon)
end
function tbClass:NotifyEquipedWeapon(InWeapon)
    self:OnShowAimMask(self.bInAiming)
end

function tbClass:OnAim(bInAiming)
    self.AimShadow:PlayAnim(bInAiming)
end

function tbClass:OnShowAimMask(bInAiming)
    self.bInAiming = bInAiming
    if bInAiming then
        -- self.AimCrossHairNode
        local PlayerPawn = self:GetOwningPlayerPawn()
        if not PlayerPawn then return end
        local lpWeapon = PlayerPawn:GetWeapon()
        if not lpWeapon then return end

        local AimAudioID = lpWeapon:GetAimAudioID()
        if AimAudioID > 0 then
            Audio.PlaySounds(AimAudioID)
        end

        local CurCrossSoftPath = lpWeapon:GetAimCrossHairUIWidget()
        local strCurCrossSoftPath = UE4.UKismetSystemLibrary.BreakSoftClassPath(CurCrossSoftPath)
        WidgetUtils.Collapsed(self.AimWidget)
        self.AimWidget = self.AimCrossHairNodes[strCurCrossSoftPath]
        if self.AimWidget then
            WidgetUtils.HitTestInvisible(self.AimWidget)
        else     
            self.AimWidget = LoadUI(CurCrossSoftPath)
            if not self.AimWidget then
                return
            end
            self.AimCrossHairNodes[strCurCrossSoftPath] = self.AimWidget
            self.AimCrossHairOverlay:AddChild(self.AimWidget)
            local Slot = UE4.UWidgetLayoutLibrary.SlotAsOverlaySlot(self.AimWidget)
            Slot:SetHorizontalAlignment(UE4.EHorizontalAlignment.HAlign_Center)
            Slot:SetVerticalAlignment(UE4.EHorizontalAlignment.HAlign_Center)
        end
    else
        WidgetUtils.Collapsed(self.AimWidget)
    end
end

function tbClass:SetAimPos(InPos)
    local OwnerPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    if OwnerPlayer and OwnerPlayer:GetCrossMode() then
        self.AimNode:SetRenderTranslation(InPos / UE4.UWidgetLayoutLibrary.GetViewportScale(self))
    end
    
    if InPos == UE4.FVector2D(0, 0) then
        WidgetUtils.Collapsed(self.Dot)
        -- WidgetUtils.Collapsed(self.Lock)
    else
        WidgetUtils.SelfHitTestInvisible(self.Dot)
        -- WidgetUtils.Collapsed(self.Lock)
    end
end

---角色变化
function tbClass:OnPlayerChange()
    local PlayerPawn = self:GetOwningPlayerPawn()
    if not PlayerPawn then return end
    local Character = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter)
    if not Character then
        return
    end
    -- self.uw_Storagebar:GetCurCharacter(Character)
    self.HP:ResetChange()

    -- local OwnerPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    -- local ViewSize = UE4.UWidgetLayoutLibrary.GetViewportSize(self)
    -- local SSize = ViewSize / UE4.UWidgetLayoutLibrary.GetViewportScale(self)
    -- local Size = OwnerPlayer:GetTargetUIRange() * math.min(SSize.X, SSize.Y)
    -- UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Fream):SetSize(Size)
    self:ModifyHideInfoOnPlayerChange();
end

function tbClass:UpdateJoystic()
    if IsMobile() then 
        local JFixed = PlayerSetting.Get(PlayerSetting.SSID_OPERATION, OperationType.JOYSTIC_FIXED);
        self.JoyStick.JoyStickFixed = JFixed[1] == 1;
    end
end

function tbClass.HiddenTaskCountDown(ExecuteNode)
    local self = UI.GetUI('Fight')
    if self then
        self.LevelGuard:TryCollapsed(ExecuteNode)
    end
end

function tbClass.UpdateTaskCountDown(nCountDown, ExecuteNode)
    local self = UI.GetUI('Fight')
    if self then
        self.LevelGuard:TryCountDown(ExecuteNode, nCountDown)
    end
end

function tbClass:OpenDamage()
    if not self.DamageWidget then
        local DamageName = "/Game/UI/UMG/Fight/umg_fight_Damage.umg_fight_Damage_C"
        local damageWidget = LoadWidget(DamageName)
        if not damageWidget then return end
        damageWidget:AddToViewport()
        self.DamageWidget = damageWidget
    else 
        WidgetUtils.HitTestInvisible(self.DamageWidget)
    end
    if self.DamageWidget then
        self.DamageWidget:OnOpen()
    end
end
function tbClass:CloseDamage()
    if self.DamageWidget then     
        self.DamageWidget:OnDisable()
        WidgetUtils.Collapsed(self.DamageWidget)
    end
end

function tbClass:OnOpen()
    self:OpenDamage()

    self:UpdateCustomizeWidgets()
    self:UpdateJoystic()
    self:UpdateKeyShow()
    self:UpdateDarkPanel()
    
    UE4.UGameplayStatics.SetGamePaused(self, false)
    self:ShowOrHideWidgets()
    UE4.UUMGLibrary.UpdatePCInputMode(false)
    RuntimeState.ChangeInputMode(false)
    self:ShowOnlineShopTips();

    -- 界面隐藏时，不会触发AppliedModifierChange事件，所以在OnOpen时重新刷新一次Modifier信息
    self:ModifyHideInfoOnPlayerChange();

    if GuideLogic.IsHiddenSkillBt and GuideLogic.nNowStep and Map.GetCurrentID() == GuideLogic.PrologueMapID then
        GuideLogic.IsHiddenSkillBt = nil
        self:HiddenAllSkillBtn()
    end
    self.StarTips:TryPlay()

    if WaterMarkLogic.IsShowWaterMark() and not UI.IsOpen("WaterMark") then
        --显示水印
        UI.Open("WaterMark")
    end
    
    -- self.Damage:FightUIClose(false)
    
    --- 构造联机队友救助信息
    self:ConstructReviveTip()
end

function tbClass:OnDisable()
    self:CloseDamage()
    -- self.Damage:FightUIClose(true)
    UE4.UUMGLibrary.ReleaseInput()
    UE4.UUMGLibrary.UpdatePCInputMode(true)
end

function tbClass:OnClose()
    self:CloseDamage()
    self.DamageWidget = nil
    -- self.Damage:FightUIClose(true)
    UE4.UUMGLibrary.ReleaseInput()
    self:RemoveRegisterEvent()
    TaskCommon.ClearHandle()
    EventSystem.Remove(self.PauseHandle)
    EventSystem.Remove(self.gamepadReturnHandle)
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.ChallengeTimeHandle)
end

function tbClass:UpdateCustomizeWidgets()
    if not IsMobile() then return end
    local sCfg = PlayerSetting.GetCurrentCustomizeCfg()
    local tbCfg = json.decode(sCfg) or {}
    local pFunc = function (widget, config)
        widget:SetRenderScale(UE4.FVector2D(config[3] or 1, config[3] or 1))
        widget:SetRenderOpacity(config[4] or 1)
        widget:SetRenderTranslation(UE4.FVector2D(config[1] or 0, config[2] or 0))
        if widget.SetWidgetHidden ~= nil then
            widget:SetWidgetHidden(config[6] == 0 and true or false)
        end
    end

    for i,one in ipairs(self.tbCustomize) do
        local cfg = tbCfg[i] or {}
        if type(one) == "table" and #one == 2 then
            for _,v in ipairs(one) do
                pFunc(v, cfg)
            end
        else
            pFunc(one, cfg)
        end
    end
end

function tbClass:ShowSkillSelector(SkillIndex)
    if self.SkillOperation then
        self.CurSkillSelectorIndex = SkillIndex;
        WidgetUtils.SelfHitTestInvisible(self.SkillOperation)
    end
end

function tbClass:HideSkillSelector(SkillIndex)
    if self.SkillOperation and self.CurSkillSelectorIndex == SkillIndex then
        self.CurSkillSelectorIndex = -1;
        WidgetUtils.Collapsed(self.SkillOperation)
    end
end

function tbClass:ShowOrHideCross(bShow)
    if self.Cross then
        if bShow then
            WidgetUtils.SelfHitTestInvisible(self.Cross)
        else
            WidgetUtils.Collapsed(self.Cross)
        end
    end
end

function tbClass:ShowOrHideWidgets()
    if Launch.GetType() == LaunchType.OPENWORLD then
        WidgetUtils.Visible(self.BtnOpenWorldMap)
        WidgetUtils.Visible(self.BtnOpenWorld)
        WidgetUtils.Visible(self.LevelTaskOpenWorld)
        WidgetUtils.Collapsed(self.LevelTask)
    else
        WidgetUtils.Collapsed(self.BtnOpenWorldMap)
        WidgetUtils.Collapsed(self.BtnOpenWorld)
        WidgetUtils.Collapsed(self.LevelTaskOpenWorld)
        WidgetUtils.Visible(self.LevelTask)
    end

    self.IsOnlineClient = UE4.UGameLibrary.IsOnlineClient(self:GetOwningPlayer())
    -- 复活进度条
    if self.IsOnlineClient then 
        WidgetUtils.Visible(self.ReviveProgress)
        if self.LevelNumbers then
            WidgetUtils.Visible(self.LevelNumbers)
            local childCount = self.LevelNumbers.WrapBox_24:GetChildrenCount()
            for i = childCount, 1 do
                local newWidget = LoadWidget("/Game/UI/UMG/Fight/Widgets/uw_fight_level_numbers.uw_fight_level_numbers_C")
                self.LevelNumbers.WrapBox_24:AddChildToWrapBox(newWidget)
            end
            if not self.onlinePoints or not self.onlineMoney then
                self.onlinePoints = self.LevelNumbers.WrapBox_24:GetChildAt(0)
                self.onlineMoney = self.LevelNumbers.WrapBox_24:GetChildAt(1)
            end

            local pawn = self:GetOwningPlayerPawn();
            if (pawn ~= nil) and pawn.PlayerState then
                self.onlineMoney:ShowMoney(pawn.PlayerState:GetMultiLevelMoney(false))
                self.onlinePoints:ShowPoint(pawn.PlayerState:GetMultiLevelPoint())
            end

            if self.MultiMoneyEvent then
                EventSystem.Remove(self.MultiMoneyEvent)
                self.MultiMoneyEvent = nil
            end
            self.MultiMoneyEvent = EventSystem.On(Event.OnMultiLevelMoneyChange,
                function(num)
                    self.onlineMoney:ShowMoney(num)
                end)

            if self.MultiPointEvent then
                EventSystem.Remove(self.MultiPointEvent)
                self.MultiPointEvent = nil
            end
            self.MultiPointEvent = EventSystem.On(Event.OnMultiLevelPointChange,
                function(num)
                    self.onlinePoints:ShowPoint(num)
                end)
        end
    else 
        WidgetUtils.Collapsed(self.ReviveProgress)
        if self.LevelNumbers then
            WidgetUtils.Collapsed(self.LevelNumbers)
        end
    end

    if Launch.GetType() == LaunchType.DEFEND then
        WidgetUtils.SelfHitTestInvisible(self.LevelNumbers)
        WidgetUtils.Collapsed(self.LevelNumbers.Num1)
        WidgetUtils.SelfHitTestInvisible(self.LevelNumbers.Num2)
        self.LevelNumbers.Num2:SetMoneyIconId(1002003)
        self:UpdateDefendMoney()

        self:RegisterEvent(
            "OnTaskMoneyChanged",
            function(NowMoney)
                UE4.Timer.Add(3.8,function ()
                    local UIFight = UI.GetUI('Fight')
                    if UIFight then
                        UIFight:UpdateDefendMoney()
                    end
                end)
            end
        )
    end
end

function tbClass:UpdateDefendMoney()
    local TaskActor = self:GetTaskActor()
    if IsValid(TaskActor) and IsValid(TaskActor.TaskDataComponent) then
        local NowDefendMoney = TaskActor.TaskDataComponent:GetOrAddValue('Money')
        self.LevelNumbers.Num2:ShowMoney(NowDefendMoney)
    else
        self.LevelNumbers.Num2:ShowMoney(0)
    end
end

function tbClass:CenterBreakTag(InValue)
    if InValue then
        WidgetUtils.SelfHitTestInvisible(self.Monster_break)
    else
        WidgetUtils.Collapsed(self.Monster_break)
    end
end

--- 隐藏所有技能按钮（新手教学关卡中按指引顺序一个一个解锁）
function tbClass:HiddenAllSkillBtn()
    WidgetUtils.Hidden(self.SkillPanel.Fire)
    WidgetUtils.Hidden(self.SkillPanel.AimFire)
    WidgetUtils.Hidden(self.SkillPanel.Skill1)
    WidgetUtils.Hidden(self.SkillPanel.Skill3)
    WidgetUtils.Hidden(self.SkillPanel.Skill4)
    WidgetUtils.Hidden(self.SkillPanel.Skill5)
    WidgetUtils.Hidden(self.SkillPanel.Skill7_1)
    WidgetUtils.Hidden(self.SkillPanel.Aim)
    WidgetUtils.Hidden(self.SkillPanel.Reload)
end

function tbClass:OpenPause(bDownESC)
    if UE4.UGameplayStatics.GetTimeSeconds(self) - self.InitTime < 0.6 then
        return
    end
    if bDownESC and self.bPause == false then
        local umg_Seq = UE4.UClass.Load("/Game/UI/UMG/Sequencer/umg_sequencer")
        local OutUmgs = UE4.TArray(UE4.UUserWidget)
        UE4.UWidgetBlueprintLibrary.GetAllWidgetsOfClass(self, OutUmgs, umg_Seq, true)

        if OutUmgs:Length() > 0 then
            if  OutUmgs:Get(1):IsVisible() then
                OutUmgs:Get(1).BtnSkip:ForceClick()
                return
            end
        end
    end

    local needOpenPause = false;
    -- 如果不是按的esc，并且是pc平台
    if not bDownESC and UE4.UGameLibrary.IsWindowsPlatform() then 
        -- 如果当前打开了协议动画
        if DialogueMgr.SetSequencePause(true) then 
            needOpenPause = true;
        end
    end

    if (self:IsOpen() and not self.bPause) or needOpenPause then
        UE4.UUMGLibrary.ReleaseInput()
        self.bPause = true
        UE4.UUMGLibrary.ReleaseInput()
        UI.Open('PauseNew', not bDownESC, function() self:OnClosePause() end)
        return
    end

    if self.bPause then
        local pause = UI.GetUI('PauseNew')
        if pause and pause:IsOpen() then
            pause:OnReturn()
        else
            UI.CloseTop()
        end
    end
end

function tbClass:OnClosePause()
    self.bPause = false
end

function tbClass:UpdateKeyShow(sBindKey,pKeyName,pKeyCfg)
    if self.SkillPanel and self.SkillPanel.Skill1 and self.SkillPanel.Skill1.KeyBtn then
        self.SkillPanel.Skill1.KeyBtn:UpdateKeyShow('TxtKeySkill1')
    end
    if self.SkillPanel and self.SkillPanel.Skill3 and self.SkillPanel.Skill3.KeyBtn then
        self.SkillPanel.Skill3.KeyBtn:UpdateKeyShow('TxtKeySkill2')
    end
    if self.SkillPanel and self.SkillPanel.Aim and self.SkillPanel.Aim.KeyBtn then
        self.SkillPanel.Aim.KeyBtn:UpdateKeyShow('TxtKeyAim')
    end
    if self.SkillPanel and self.SkillPanel.Reload and self.SkillPanel.Reload.KeyBtn then
        self.SkillPanel.Reload.KeyBtn:UpdateKeyShow('TxtKeyReload')
    end
    if self.SkillPanel and self.SkillPanel.Fire and self.SkillPanel.Fire.KeyBtn then
        self.SkillPanel.Fire.KeyBtn:UpdateKeyShow('TxtKeyFire')
    end
    if self.SkillPanel and self.SkillPanel.Skill5 and self.SkillPanel.Skill5.KeyBtn then
        self.SkillPanel.Skill5.KeyBtn:UpdateKeyShow('TxtKeyMiss')
    end
    if self.SkillPanel and self.SkillPanel.Jump and self.SkillPanel.Jump.KeyBtn then
        self.SkillPanel.Jump.KeyBtn:UpdateKeyShow('TxtKeyJump')
    end
end

function tbClass:UpdateDarkPanel()
    if Launch.GetType() == LaunchType.DARKZONE then
        WidgetUtils.SelfHitTestInvisible(self.PanelDark)
        WidgetUtils.Collapsed(self.PanelNormalLevel)
        WidgetUtils.Collapsed(self.Time)
    end
end

function tbClass:ShowOnlineShopTips(shopId,isAdd)
    if self.IsOnlineClient == nil then
        self.IsOnlineClient = UE4.UGameLibrary.IsOnlineClient(self:GetOwningPlayer())
    end
    if not self.IsOnlineClient then return end
    if not self.uw_fight_monster_tips then return end
    if not self.onlineShopTips then self.onlineShopTips = {} end
    local shops = UE4.UGameplayStatics.GetAllActorsOfClass(self,UE4.ABufferShop)
    if shops:Length() == 0 then return end

    local addTipItem = function (shopActor)
        local shopId_ = shopActor:GetShopId()
        if not self.onlineShopTips[shopId_] then
            if shopActor:GetInteractiveMode() == 0 then
                self.onlineShopTips[shopId_] = self.uw_fight_monster_tips:CreateItem(shopActor,UE4.EFightMonsterTipsType.Shop, "GuideUIPos")
            else
                self.onlineShopTips[shopId_] = self.uw_fight_monster_tips:CreateItem(shopActor,UE4.EFightMonsterTipsType.Box, "GuideUIPos")
            end
        end
    end
    local removeTipItem = function (shopActor)
        local shopId_ = shopActor:GetShopId()
        if self.onlineShopTips[shopId_] then
            self.onlineShopTips[shopId_]:Reset()
            self.onlineShopTips[shopId_] = nil
        end
    end

    --如果有商店Id，则直接找对应商店处理显示即可，没有的话，则遍历商店检测状态，开放中的就加万向轮，不开放的就删万向轮
    if not shopId then
        for i = 1, shops:Length() do
            local shop = shops:Get(i)
            if shop.bShowTip then
                addTipItem(shop)
            else
                removeTipItem(shop)
            end
        end
    else
        for i = 1, shops:Length() do
            local shop = shops:Get(i)
            if shop:GetShopId() == shopId then
                if isAdd then
                    addTipItem(shop)
                else
                    removeTipItem(shop)
                end
            end
        end
    end
end

function tbClass:NotifyTeammateDeathBegin(Index, Actor)
    if IsValid(Actor) then
        self.tbReviveTip[Index] = self.uw_fight_monster_tips:CreateItem(Actor, UE4.EFightMonsterTipsType.Revive)
    end
end

function tbClass:NotifyTeammateDeathEnd(Index)
    local tb = self.tbReviveTip[Index]
    if tb then
        if IsValid(tb) then
            tb:Reset()
        end
        table.remove(self.tbReviveTip, Index)
    end
end

function tbClass:ConstructReviveTip()
    print("umg_fight", "ConstructReviveTip")
    for Index, Actor in pairs(Online.tbCacheReviveData) do
        self:NotifyTeammateDeathBegin(Index, Actor)
    end
    Online.ClearReviveCacheData()
end

function  tbClass:ClearReviveTip()
    print("umg_fight", "ClearReviveTip")
    if not self.tbReviveTip then return end
    for k, v in pairs(self.tbReviveTip) do
        if v and IsValid(v) then
            v:Reset()
        end
    end
end

function tbClass:OnDestruct()
    EventSystem.Remove(self.nEventUpdateControl)
    self.AimCrossHairNodes = {}
    self.AimWidget = nil
    self.nEventUpdateControl = nil

    if self.StarTipInterval then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.StarTipInterval)
    end

    if self.StarTipHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
    end
    self:ClearReviveTip()
    if self.MultiMoneyEvent then
        EventSystem.Remove(self.MultiMoneyEvent)
        self.MultiMoneyEvent = nil
    end

    if self.MultiPointEvent then
        EventSystem.Remove(self.MultiPointEvent)
        self.MultiPointEvent = nil
    end
end

--打靶UI加载
function tbClass:AddTargetShootUI()
    self.TargetShootUI = LoadWidget("/Game/UI/UMG/Fight/Widgets/uw_fight_target.uw_fight_target_C")
    self.RootCanvasPanel:AddChild(self.TargetShootUI)
    return self.TargetShootUI
end

-- 初始化屏蔽战斗UI信息
function tbClass:InitHideFightWidgetInfo()
    self.HideWidgetInfos = {};
    for i = UE4.EFightWidgetPart.None+1, UE4.EFightWidgetPart.Max-1 do
        local HideInfo = {
            ModifierInfo = {},
            HideState = 0,
        }
        self.HideWidgetInfos[i] = HideInfo;
    end
    -- for i = UE4.EFightWidgetPart.NormalSkill, UE4.EFightWidgetPart.FightCross do
    --     self.HideWidgetInfos[i].HideState = 4;
    -- end
    self:RegisterEvent(Event.AppliedModifierChange, function (Ability, ModifierID, bAdd)
        self:OnAppliedModifierChange(Ability, ModifierID, bAdd);
    end);
end

function tbClass:ModifyHideInfoOnPlayerChange()
    local PlayerPawn = self:GetOwningPlayerPawn();
    if not PlayerPawn then return end
    local Character = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter);
    if not Character then
        return
    end
    -- 重置Modifier状态
    for k, v in pairs(self.HideWidgetInfos) do
        v.HideState = SetBits(v.HideState, 0, UE4.EFightWidgetPartHideReason.Modifier, UE4.EFightWidgetPartHideReason.Modifier);
        v.ModifierInfo = {};
    end
    -- 获取当前UI显示类Modifier
    for i = 1, Character.Ability.AppliedModifierDatas:Length() do
        local ModifierData = Character.Ability.AppliedModifierDatas:Get(i);
        local ModifierInfo = UE4.UAbilityComponentBase.K2_LoadModifierInfoStatic(ModifierData.ModifierID, Character.Ability);
        if ModifierInfo.HideFightWidgetParts ~= 0 then
            for i = UE4.EFightWidgetPart.None+1, UE4.EFightWidgetPart.Max-1 do
                local bHide = GetBits(ModifierInfo.HideFightWidgetParts, i, i);
                if bHide ~= 0 then
                    local HideInfo = self.HideWidgetInfos[i];
                    HideInfo.HideState = SetBits(HideInfo.HideState, 1, UE4.EFightWidgetPartHideReason.Modifier, UE4.EFightWidgetPartHideReason.Modifier);
                    table.insert(HideInfo.ModifierInfo, ModifierData.ModifierID);
                end
            end
        end
    end
    -- 刷新界面显示
    for k, v in pairs(self.HideWidgetInfos) do
        self:UpdatePartShow(k);
    end
end

function tbClass:OnAppliedModifierChange(Ability, ModifierID, bAdd)
    -- print("remove", Ability, ModifierID, bAdd);
    local PlayerPawn = self:GetOwningPlayerPawn();
    if not PlayerPawn then return end
    local Character = self:GetOwningPlayerPawn():Cast(UE4.AGameCharacter);
    if not Character then
        return;
    end
    if Character.Ability ~= Ability then
        return;
    end
    local ModifierInfo = UE4.UAbilityComponentBase.K2_LoadModifierInfoStatic(ModifierID, Ability);
    if ModifierInfo.HideFightWidgetParts ~= 0 then
        -- print("remove  1111", Ability, ModifierID, bAdd);
        for i = UE4.EFightWidgetPart.None+1, UE4.EFightWidgetPart.Max-1 do
            local bHide = GetBits(ModifierInfo.HideFightWidgetParts, i, i);
            -- print("GetBits", i, bHide);
            if bHide ~= 0 then
                local HideInfo = self.HideWidgetInfos[i];
                -- 添加
                if bAdd == true then
                    -- print("bAdd = true", i, bHide);
                    HideInfo.HideState = SetBits(HideInfo.HideState, 1, UE4.EFightWidgetPartHideReason.Modifier, UE4.EFightWidgetPartHideReason.Modifier);
                    table.insert(HideInfo.ModifierInfo, ModifierID);
                    self:UpdatePartShow(i);
                -- 移除
                else
                    for k, v in pairs(HideInfo.ModifierInfo) do
                        if v == ModifierID then
                            table.remove(HideInfo.ModifierInfo, k);
                            break;
                        end
                    end
                    -- print("bAdd = false", i, bHide);
                    if #HideInfo.ModifierInfo == 0 then
                        HideInfo.HideState = SetBits(HideInfo.HideState, 0, UE4.EFightWidgetPartHideReason.Modifier, UE4.EFightWidgetPartHideReason.Modifier);
                        self:UpdatePartShow(i);
                    end
                end
            end
        end
    end
end

function tbClass:UpdatePartShow(PartIndex)
    -- 新手引导过程中不处理屏蔽战斗UI逻辑
    if GuideLogic.IsGuiding() then
        return;
    end
    if PartIndex == UE4.EFightWidgetPart.QTESkill then
        local Widgets = self.PlayerSelect.PlayerList:GetAllChildren();
        for i=1, Widgets:Length() do
            local Widget = Widgets:Get(i);
            Widget:UpdateSkillShow();
        end
        return;
    elseif PartIndex == UE4.EFightWidgetPart.BulletCount then
        if self.CrossHair then
            self.CrossHair:UpdateAmmunitionShow();
        end
        return;
    elseif PartIndex == UE4.EFightWidgetPart.FightCross then
        if self.CrossHair then
            self.CrossHair:UpdateCrossShow();
        end
        return;
    end
    local bShow = self.HideWidgetInfos[PartIndex].HideState == 0;
    local bSetVisibleIfShow = true;
    local PartUI;
    if PartIndex == UE4.EFightWidgetPart.NormalSkill then
        if GuideLogic.nNowStep and Map.GetCurrentID() == GuideLogic.PrologueMapID then
            return;
        end
        PartUI = self.SkillPanel.Skill1;
    elseif PartIndex == UE4.EFightWidgetPart.SuperSkill then
        if GuideLogic.nNowStep and Map.GetCurrentID() == GuideLogic.PrologueMapID then
            return;
        end
        PartUI = self.SkillPanel.Skill3;
        local Widgets = self.PlayerSelect.PlayerList:GetAllChildren();
        for i=1, Widgets:Length() do
            local Widget = Widgets:Get(i);
            Widget:UpdateSkillShow();
        end
    elseif PartIndex == UE4.EFightWidgetPart.BackCharacter then
        PartUI = self.PlayerSelect;
    -- elseif PartIndex == UE4.EFightWidgetPart.FightTime then
    --     PartUI = self.Time;
    elseif PartIndex == UE4.EFightWidgetPart.FightPower then
        PartUI = self.Power;
        bSetVisibleIfShow = false;
    elseif PartIndex == UE4.EFightWidgetPart.FightMonsterTips then
        PartUI = self.uw_fight_monster_tips;
    elseif PartIndex == UE4.EFightWidgetPart.LevelTask then
        PartUI = self.LevelTask;
    elseif PartIndex == UE4.EFightWidgetPart.PlayerHP then
        PartUI = self.HP;
    elseif PartIndex == UE4.EFightWidgetPart.SpecialFightUI then
        PartUI = self.uw_fight_special_ui;
    end
    if PartUI == nil or GuideLogic.tbControlButton[PartUI] then
        return;
    end
    -- print("UpdatePartShow", PartIndex, bShow, PartUI);
    if bShow and bSetVisibleIfShow then
        WidgetUtils.SelfHitTestInvisible(PartUI)
    else
        WidgetUtils.Collapsed(PartUI)
    end
end

function tbClass:GetFightPartShow(InPart)
    return self:GetPartShow(InPart);
end

function tbClass:GetPartShow(PartIndex)
    if self.HideWidgetInfos == nil then
        return true;
    end
    -- print(PartIndex, self.HideWidgetInfos[PartIndex].HideState == 0);
    return self.HideWidgetInfos[PartIndex].HideState == 0;
end

function tbClass:UpdateControl()
    if GuideLogic.SkipUpdate() then
        return
    end

    local ControlType = {
        BlockMove = 0,
        BlockSkill = 1,
        BlockFireAction = 2,
        BlockDodge = 3,
        BlockSwitch = 4,
        BlockQTE = 5,
        BlockAimAction = 6 
    }

    local OwnerPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    if OwnerPlayer then
        if OwnerPlayer:GetControlBlock(ControlType.BlockMove) then
            WidgetUtils.Collapsed(self.JoyStick)
        else
            WidgetUtils.SelfHitTestInvisible(self.JoyStick)
        end

        if OwnerPlayer:GetControlBlock(ControlType.BlockSkill) then
            WidgetUtils.Collapsed(self.SkillPanel.Skill1)
            WidgetUtils.Collapsed(self.SkillPanel.Skill3)
            WidgetUtils.Collapsed(self.SkillPanel.Skill5)
        else
            WidgetUtils.Visible(self.SkillPanel.Skill1)
            WidgetUtils.Visible(self.SkillPanel.Skill3)
            WidgetUtils.Visible(self.SkillPanel.Skill5)
        end

        if OwnerPlayer:GetControlBlock(ControlType.BlockFireAction) then
            WidgetUtils.Collapsed(self.SkillPanel.Fire)
            WidgetUtils.Collapsed(self.SkillPanel.LeftFireBtn)
            WidgetUtils.Collapsed(self.SkillPanel.AimFire)
        else
            WidgetUtils.Visible(self.SkillPanel.Fire)
            WidgetUtils.Visible(self.SkillPanel.LeftFireBtn)
            WidgetUtils.Visible(self.SkillPanel.AimFire)
        end

        -- 暂时弃用
        -- if OwnerPlayer:GetControlBlock(ControlType.BlockDodge) then
        --     WidgetUtils.Collapsed(self.SkillPanel.Skill7)
        -- else
        --     WidgetUtils.Visible(self.SkillPanel.Skill7)
        -- end

        if OwnerPlayer:GetControlBlock(ControlType.BlockSwitch) then
            WidgetUtils.Collapsed(self.PlayerSelect)
        else
            WidgetUtils.SelfHitTestInvisible(self.PlayerSelect)
        end

        if OwnerPlayer:GetControlBlock(ControlType.BlockAimAction) then
            WidgetUtils.Collapsed(self.SkillPanel.Aim)
        else
            
            WidgetUtils.Visible(self.SkillPanel.Aim)
        end
    end
end

function tbClass:OnOpenGM()
    local widget = UI.GetUI("GM")
    print("OnOpenGM", widget)
    if widget then
        print("umg_fight->UI.Close", widget.sName)
        UI.Close(widget)
        return
    end

    UI.Open("GM")
end

function tbClass:TryPlayStarInfoTip(Execute)
    if Execute:IsTaskFinishExecute() then
        return
    end
    
    if self.StarTipInterval then
        return
    end
    
    EventSystem.Trigger(Event.OnStarTaskChange, false, true, true)
    self.StarTipInterval = UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                self.StarTipInterval = nil
            end
        },
        10,
        false
    )
end

function tbClass:HideStarInfoTip()
    WidgetUtils.Collapsed(self.Star)
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.StarTipInterval)
    self.StarTipInterval = nil
    return
end

-- 打开时不聚焦
function tbClass:DontFocus()
    return true;
end

return tbClass
