-- ========================================================
-- @File    : umg_guide.lua
-- @Brief   : 新手指引界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnMouseButtonUp(MyGeometry, InTouchEvent)
    if not self.tbConfig.bSkip or self.BtnSkip:GetVisibility() == UE4.ESlateVisibility.Visible then
        return UE4.UWidgetBlueprintLibrary.Handled()
    end
    if not self.InvalidClickNum then
        --记录无效点击次数，三秒内超过5次显示跳过按钮
        self.InvalidClickNum = 0
    end
    self.InvalidClickNum = self.InvalidClickNum + 1
    if self.InvalidClickNum >= 5 then
        WidgetUtils.Visible(self.BtnSkip)
        self.InvalidClickNum = 0
    end
    return UE4.UWidgetBlueprintLibrary.Handled()
end
function tbClass:OnMouseButtonDown(MyGeometry, InTouchEvent)
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function tbClass:OnInit()
    self.ViewportScale = UE4.UWidgetLayoutLibrary.GetViewportScale(self)
    self.ViewportSize = UE4.UWidgetLayoutLibrary.GetViewportSize(self) / self.ViewportScale

    self.WidgetHidden = {}

    local MaskSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Mask)
    MaskSlot:SetPosition(UE4.FVector2D(0, 0))
    MaskSlot:SetSize(UE4.FVector2D(self.ViewportSize.X, self.ViewportSize.Y))
    local MaskOpacitySlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.MaskOpacity)
    MaskOpacitySlot:SetPosition(UE4.FVector2D(0, 0))
    MaskOpacitySlot:SetSize(UE4.FVector2D(self.ViewportSize.X, self.ViewportSize.Y))

    WidgetUtils.Collapsed(self.MaskFull)
    WidgetUtils.Collapsed(self.Mask3D)
    self.m_fCurrentTime = 0

    BtnAddEvent(self.BtnSkip, function()
        if self.tbStep then
            if self.tbConfig.tbSkipID then
                for _, id in ipairs(self.tbConfig.tbSkipID) do
                    GuideLogic.SetCompleteSkipGuide(id)
                end
            end
            self:OnStepEnd()
            GuideLogic.SetCompleteSkipGuide(self.tbConfig.nID)
            GuideLogic.EndGuide()
        end
    end)

    self:RegisterEvent(Event.UIClose, function(sName)
        if self.tbStep and self.nStepId then
            local tbData = self.tbStep[self.nStepId]
            if tbData and sName == tbData.sWindow and tbData.nAutoComplete and tbData.nAutoComplete>0 then
                WidgetUtils.Collapsed(self.Tips)
                local nNextStep = GuideLogic.GetNextStep(self.nGuideId, self.nStepId + 1)
                self:BeginStep(nNextStep)
            end
        end
    end)

    self:RegisterEvent(Event.OnInputTypeChange, function(bGamepad)
        if not self.tbStep or not self.nStepId then
            return
        end
        local tbData = self.tbStep[self.nStepId]
        if tbData and self.Tips:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
            if bGamepad and tbData.HandleTips then --手柄
                self.Tips.TalkText:SetContent(Text(tbData.HandleTips, self:GetHandleName(tbData.HandleKeyBoard, UE4.UGameKeyboardLibrary.GetActiveInputType())))
            else
                self.Tips.TalkText:SetContent(Text(tbData.Tips, self:GetKeyBoardName(tbData.KeyBoard)))
            end
        end
    end)
end

function tbClass:OnOpen(tbData)
    if not self.RoleMaterial then
        self.RoleMaterial = self.Tips.Role:GetDynamicMaterial()
    end

    if tbData and tbData[1] then
        self:BeginGuide(tbData[1], tbData[2])
    else
        UI.Close(self)
    end
end

function tbClass:OnClose()
    if self.tbEvent then
        for key in pairs(self.tbEvent) do
            self.tbEvent[key] = nil
        end
    end
    self.tbEvent = nil
    self:ReleaseEvent()
end

--- 开始进行新手指引
function tbClass:BeginGuide(nId, nStepId)
    self:UpdateAllWidget()
    --隐藏动画
    self:UpdateGuideRound()
    GuideLogic.bResetInput = nil

    self.tbConfig = GuideLogic.GetConfig(nId)
    if not self.tbConfig then
        UI.Close(self)
        return
    end

    self.nGuideId = nId
    self.tbStep = self.tbConfig.tbStep
    --- 是否是非强制指引
    self.IsNonForce = GuideLogic.IsNonForce(nId)

    if nStepId and nStepId > 1 then
        self:BeginStep(nStepId)
    else
        self:BeginStep(1)
    end
end

--- 开始指引步骤
function tbClass:BeginStep(nStepId)
    if not nStepId or not self.tbStep then
        GuideLogic.EndGuide(true)
        return
    end
    self.nStepId = nStepId
    local tbData = self.tbStep[nStepId]
    if not tbData then
        --返还按钮的指引结束后需要重新检测
        if self.tbConfig.sRefresh then
            GuideLogic.SetGuideComplete(self.nGuideId)
            GuideLogic.nGuideId = 0
            GuideLogic.nStepId = 0
            self:ReleaseEvent()
            UI.Close(self, function()
                if tonumber(self.tbConfig.sRefresh) then
                    local topui = UI.GetTop()
                    if topui then
                        GuideLogic.CheckGuide(topui.sName)
                    end
                else
                    if UI.IsOpen(self.tbConfig.sRefresh) then
                        GuideLogic.CheckGuide(string.lower(self.tbConfig.sRefresh))
                    end
                end
            end)
        else
            GuideLogic.EndGuide(true)
        end
        return
    end
    GuideLogic.UpdateStep(self.nGuideId, nStepId)
    self:ReleaseEvent()
    if tbData.sWindow == "" or UI.IsOpen(tbData.sWindow) then
        self:DoBeginStep(tbData)
    end
end

function tbClass:DoBeginStep(tbData)
    tbData = tbData or self.tbStep[self.nStepId]
    if not tbData then
        GuideLogic.EndGuide(true)
        return
    end
    if self.IsInStep then
        return
    end
    self.IsInStep = true

    self:UpdateAllWidget()
    WidgetUtils.SelfHitTestInvisible(self.Mask)
    self:ShowMaskFull(tbData.nShowMask > 0)

    -- qte指引处理
    -- if tbData.nID == 105 and tbData.nStepId == 1 then
    --     if tbData.PCKey then
    --         --禁止键盘输入
    --         local Controller = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    --         if Controller then
    --             Controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.SwitchNext)
    --             Controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.SwitchPre)
    --             Controller:ClearAllKeyboardInput()
    --         end
    --     end
    --     --移动端停止摇杆移动
    --     local sUI = UI.GetUI("fight")
    --     if sUI and sUI.Joystick and sUI:IsOpen() then
    --         sUI.Joystick:StopMove()
    --     end
    -- end

    GuideLogic.WriteGuideLog(string.format("%d|%d|%s|0", self.nGuideId, self.nStepId, self.tbConfig.sType))
    if tbData.nReleaseInput and tbData.nReleaseInput > 0 then
        UE4.UUMGLibrary.ReleaseInput()
    end

    GuideLogic.ExecuteExtension(tbData.OnWindowOpen)
    self:AddEvent(tbData.nTime or self:GetTime(tbData), function() self:ShowGuideUI(tbData) end)
end

function tbClass:GetTime(tbData)
    -- qte指引延时4s
    -- if tbData.nID == 105 and tbData.nStepId == 1 then
    --     return 4
    -- end
    return 0.6
end

--- 点击目标按钮的回调
function tbClass.EventCall(widget)
    if not widget.EventHander then return end
    widget:GotoNextStep()
end
--- 点击战斗界面目标按钮的回调
function tbClass.FightClickEventCall(widget, type, pointerEvent)
    if not widget.EventHander then return end
    if type == nil or type == 3 then
        widget:GotoNextStep()
    end
end
--- 移动角色指引时的回调
function tbClass.MoveEventCall(widget, type)
    if not widget.EventHander then return end
    if type == 0 then
        widget:ShowMaskPart(false)
    elseif type == 1 then
        widget:GotoNextStep()
    end
end
--- 旋转角色指引时的回调
function tbClass.RotateEventCall(widget, type)
    if not widget.EventHander then return end
    if type == 0 then
        widget:ShowMaskPart(false)
    elseif type == 2 then
        widget:GotoNextStep()
    end
end
--- 移动或旋转角色隐藏mask时的回调
function tbClass.HideMaskEventCall(widget, type)
    if not widget.EventHander then return end
    if type == 0 then
        widget:ShowMaskPart(false)
    elseif type > 0 then
        widget:ShowMaskPart(true)
        -- if self.ViewPortPos and self.GuideCover:GetVisibility() == UE4.ESlateVisibility.HitTestInvisible then
        --     local wSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.GuideCover)
        --     wSlot:SetPosition(self.ViewPortPos)
        -- end
    end
end

---PC端键盘按键时的回调
function tbClass:PCInputCall(key, type)
    if not self.InputKey then
        return
    end
    if self.InputKey == key or self.InputKey == -1 then
        self.InputKey = nil
        if GuideLogic.bResetInput then
            local Controller = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
            if Controller then
                Controller:RestoreAllKeyboardInput()
            end
            GuideLogic.bResetInput = nil
        end
        self:GotoNextStep()
    end
end

-- 显示战斗界面之前隐藏的按钮
function tbClass:ShowSomeBtn(tbData)
    if tbData.nID == 7 and tbData.nStepId == 1 then
        local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
        if controller then
            controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.Dodge)
        end
    elseif tbData.nID == 10 and tbData.nStepId == 1 then
        local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
        if controller then
            controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.Rush)
        end
    elseif tbData.nID == 10101 and tbData.nStepId == 1 then
        local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
        if controller then
            controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.SupperSkill)
        end
        local uifight = UI.GetUI("fight")
        if uifight.SkillPanel.Skill3 then
            WidgetUtils.Visible(uifight.SkillPanel.Skill3)
            GuideLogic.tbControlButton[uifight.SkillPanel.Skill3] = nil
        end
    elseif tbData.nID == 10031 and tbData.nStepId == 1 then
        local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
        if controller then
            controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.Rush)
            controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.Dodge)
            controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.Skill_1)
            controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.Fire)
        end
        local uifight = UI.GetUI("fight")
        WidgetUtils.Visible(uifight.SkillPanel.Skill1)
        WidgetUtils.HitTestInvisible(uifight.Center)
        GuideLogic.tbControlButton[uifight.SkillPanel.Skill1] = nil
        GuideLogic.tbControlButton[uifight.Center] = nil

        if uifight.SkillPanel.Fire then
            WidgetUtils.Visible(uifight.SkillPanel.Fire)
            GuideLogic.tbControlButton[uifight.SkillPanel.Fire] = nil
        end
        if uifight.SkillPanel.AimFire then
            WidgetUtils.Visible(uifight.SkillPanel.AimFire)
            GuideLogic.tbControlButton[uifight.SkillPanel.AimFire] = nil
        end
        if uifight.SkillPanel.Skill5 then
            WidgetUtils.Visible(uifight.SkillPanel.Skill5)
            GuideLogic.tbControlButton[uifight.SkillPanel.Skill5] = nil
        end
    elseif tbData.nID == 10041 and tbData.nStepId == 1 then
        local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
        if controller then
            controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.SupperSkill)
        end
        local uifight = UI.GetUI("fight")
        WidgetUtils.Visible(uifight.SkillPanel.Skill3)
        GuideLogic.tbControlButton[uifight.SkillPanel.Skill3] = nil
    elseif (tbData.nID == 10061 or tbData.nID == 10081) and tbData.nStepId == 1 then
        --如果是1-3芬妮后勤技 或 1-4星期三后勤技
        if tbData.PCKey then
            local controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
            if controller then
                controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.SwitchPre)
                controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.SwitchNext)
                controller:SetKeyboardInput(GuideLogic.EPCKeyboardType.BackSkill2)
            end
        end
        local uifight = UI.GetUI("fight")
        WidgetUtils.SelfHitTestInvisible(uifight.PlayerSelect)
        GuideLogic.tbControlButton[uifight.PlayerSelect] = nil
    end
end

---显示指引界面的各个UI控件
function tbClass:ShowGuideUI(tbData)
    if not self:IsOpen() then
        return GuideLogic.EndGuide()
    end
    local sUI = UI.GetUI(tbData.sWindow)
    if tbData.sWindow ~= "" and (not sUI or not sUI:IsOpen()) then
        return GuideLogic.EndGuide()
    end

    --执行步骤开始时扩展
    GuideLogic.ExecuteExtension(tbData.StepBegin)
    self:ShowSomeBtn(tbData)

    local widget = self:GetWidget(sUI, tbData.Path)
    local showwidget = self:GetWidget(sUI, tbData.WidgetPath)
    if tbData.PCKey then   --键盘按键指引
        if tbData.PCKey == "DeviceBack" then    --返回键
            self.EventPCInputId = EventSystem.On(Event.DeviceBack, function()
                self:GotoNextStep()
            end)
        else    --其他按键
            if not self.EventPCInputId then
                self.EventPCInputId = EventSystem.On(Event.PCKeyboardEvent, function(key, type)
                    self:PCInputCall(key, type)
                end)
            end
            if tbData.nPressContinue > 0 or not GuideLogic.EPCKeyboardType[tbData.PCKey] then
                self.InputKey = -1
            else
                self.InputKey = GuideLogic.EPCKeyboardType[tbData.PCKey]
                local Controller = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
                if Controller then
                    Controller:ClearAllKeyboardInput()
                    if tbData.nShowMask > 0 then    --显示遮罩的步骤需要屏蔽其他输入
                        Controller:SetKeyboardInput(self.InputKey)
                        GuideLogic.bResetInput = true
                    else
                        Controller:RestoreAllKeyboardInput()
                    end
                end
            end
        end
        if widget then  --同时需要检测界面上的按钮
            if tbData.sWindow == "fight" then
                if tbData.sCompleteMode == "Click" then
                    self.EventHander = widget.OnGuideMouseButtonEvent or widget.OnClicked
                    self.pEventCall = self.FightClickEventCall
                elseif tbData.sCompleteMode == "Released" then
                    self.EventHander = widget.OnReleased
                    self.pEventCall = self.EventCall
                elseif tbData.sCompleteMode == "Move" then
                    self.EventHander = sUI.Joystick.OnGuideTouch
                    self.pEventCall = self.MoveEventCall
                elseif tbData.sCompleteMode == "Rotate" then
                    self.EventHander = sUI.Joystick.OnGuideTouch
                    self.pEventCall = self.RotateEventCall
                -- elseif tbData.sCompleteMode == "Notify" then
                --     self.EventHander = sUI.Joystick.OnGuideTouch
                --     self.pEventCall = self.HideMaskEventCall
                end
            else
                if tbData.sCompleteMode == "Click" then
                    self.EventHander = widget.OnClicked or widget.GuideEvent
                    self.pEventCall = self.EventCall
                elseif tbData.sCompleteMode == "Released" then
                    self.EventHander = widget.OnReleased
                    self.pEventCall = self.EventCall
                elseif tbData.sCompleteMode == "LongPress" then
                    self.EventHander = widget.OnLongPressed
                    self.pEventCall = self.EventCall
                elseif tbData.sCompleteMode == "CheckBox" then
                    self.EventHander = widget.OnCheckStateChanged
                    self.pEventCall = self.EventCall
                end
            end
            if self.EventHander then
                self.EventHander:Add(self, self.pEventCall)
            else
                print("umg_guide_error:Event add failed...")
            end
        end
    else    --界面按钮指引
        -- if tbData.nID == 105 and tbData.nStepId == 1 then
        --     --QTE第一步特殊处理一下
        --     UE4.UGameplayStatics.SetGamePaused(self, true)
        -- end
        if tbData.nPressContinue > 0 then
            --点击屏幕任意位置指引结束
            local fun = function ()
                self.MouseButtonUpEvent = EventSystem.On(Event.MouseButtonUp, function()
                    self:GotoNextStep()
                end, true)
            end
            if tbData.nDelay and tbData.nDelay > 0 then
                self:AddEvent(tbData.nDelay, fun)
            else
                fun()
            end
        elseif tbData.bNoFunction and showwidget then
            BtnClearEvent(self.BtnNoFun)
            self.EventHander = self.BtnNoFun.OnClicked
            self.pEventCall = self.EventCall
            if self.EventHander then
                self.EventHander:Add(self, self.pEventCall)
            else
                print("umg_guide_error:BtnNoFun Event add failed...")
            end
        elseif tbData.sTextureUI and self[tbData.sTextureUI] then
            if tbData.sTextureUI == "HelpPop" then
                WidgetUtils.Visible(self.HelpPop)
                self.HelpPop:Display(tbData.sTexturePath)
                self.EventHander = self.HelpPop.BtnClose_1.OnClicked
                self.pEventCall = self.EventCall
                if self.EventHander then
                    self.EventHander:Add(self, self.pEventCall)
                end
            elseif tbData.sTextureUI == "FightAction" then
                WidgetUtils.SelfHitTestInvisible(self.FightAction)
                self.FightAction:UpdatePanel()
                self.EventHander = self.FightAction.BtnOK.OnClicked
                self.pEventCall = self.EventCall
                if self.EventHander then
                    self.EventHander:Add(self, self.pEventCall)
                end
            elseif tbData.sTextureUI == "FightAction2" then
                WidgetUtils.SelfHitTestInvisible(self.FightAction2)
                self.FightAction2:UpdatePanel()
                self.EventHander = self.FightAction2.BtnOK.OnClicked
                self.pEventCall = self.EventCall
                if self.EventHander then
                    self.EventHander:Add(self, self.pEventCall)
                end
            end
        else
            if widget then
                if tbData.sWindow == "fight" then
                    if tbData.sCompleteMode == "Click" then
                        self.EventHander = widget.OnGuideMouseButtonEvent or widget.OnClicked
                        self.pEventCall = self.FightClickEventCall
                    elseif tbData.sCompleteMode == "Released" then
                        self.EventHander = widget.OnReleased
                        self.pEventCall = self.EventCall
                    elseif tbData.sCompleteMode == "Move" then
                        self.EventHander = sUI.Joystick.OnGuideTouch
                        self.pEventCall = self.MoveEventCall
                    elseif tbData.sCompleteMode == "Rotate" then
                        self.EventHander = sUI.Joystick.OnGuideTouch
                        self.pEventCall = self.RotateEventCall
                    -- elseif tbData.sCompleteMode == "Notify" then
                    --     self.EventHander = sUI.Joystick.OnGuideTouch
                    --     self.pEventCall = self.HideMaskEventCall
                    end
                else
                    if tbData.sCompleteMode == "Click" then
                        self.EventHander = widget.OnClicked or widget.GuideEvent
                        self.pEventCall = self.EventCall
                    elseif tbData.sCompleteMode == "Released" then
                        self.EventHander = widget.OnReleased
                        self.pEventCall = self.EventCall
                    elseif tbData.sCompleteMode == "LongPress" then
                        self.EventHander = widget.OnLongPressed
                        self.pEventCall = self.EventCall
                    elseif tbData.sCompleteMode == "CheckBox" then
                        self.EventHander = widget.OnCheckStateChanged
                        self.pEventCall = self.EventCall
                    end
                end

                if self.EventHander then
                    self.EventHander:Add(self, self.pEventCall)
                else
                    print("umg_guide_error:Event add failed...")
                end
            elseif not tbData.nAutoComplete then
                print(string.format("umg_guide_error:Id:%d,StepId:%d中找不到目标按钮，请检查guide/guide.txt中的配置", tbData.nID, tbData.nStepId))
                UI.Close(self)
                return
            end
        end
    end

    if tbData.nAutoComplete and tbData.nAutoComplete>0 then
        if self.AutoCompleteHandle then UE4.Timer.Cancel(self.AutoCompleteHandle) end
        self.AutoCompleteHandle = UE4.Timer.Add(tbData.nAutoComplete, function ()
            self:GotoNextStep()
        end)
    end

    if showwidget and showwidget:GetVisibility() == UE4.ESlateVisibility.Collapsed then
        WidgetUtils.HitTestInvisible(showwidget)
    end
    if widget and widget:GetVisibility() ~= UE4.ESlateVisibility.Visible then
        if widget.GetWidgetHidden then
            local bHidden = widget:GetWidgetHidden()
            if bHidden then
                if not self.WidgetHidden[self.nGuideId] then
                    self.WidgetHidden[self.nGuideId] = {}
                end
                self.WidgetHidden[self.nGuideId][self.nStepId] = bHidden
                widget:SetWidgetHidden(false)
            else
                WidgetUtils.Visible(widget)
            end
        else
            WidgetUtils.Visible(widget)
        end
    end
    if tbData.nID == 5 and tbData.nStepId == 1 and sUI and sUI.SkillPanel then
        WidgetUtils.Visible(sUI.SkillPanel.Aim)
    end
    widget = showwidget or widget

    -- 刷新显示内容
    self:AddEvent(0, function() self:ShowPanel(tbData, widget) end)
end

---根据UI界面名称和路径获取目标按钮
function tbClass:GetWidget(sUI, Path)
    if not sUI or not Path or #Path <= 0 then
        return nil
    end
    if Path[1] == "Special_SelectCard" and sUI.sName == "role" then
        local gdpl = Eval(Path[2])
        if gdpl then
            local array = sUI.LeftList:GetDisplayedEntryWidgets()
            sUI.LeftList:SetScrollable(false)
            for i = 1, array:Length() do
                local template = array:Get(i).Obj.Template
                if template and gdpl[1] == template.Genre and gdpl[2] == template.Detail and gdpl[3] == template.Particular and gdpl[4] == template.Level then
                    Path = {"LeftList", i, "SelClick"}
                    break
                end
            end
        end
    elseif Path[1] == "Special_SelectWeapon" and sUI.sName == "role" then
        local gdpl = Eval(Path[2])
        if gdpl then
            local UIWeapon = sUI:GetSwitcherWidget("Weapon")
            if UIWeapon then
                local array = UIWeapon.WeaponList:GetDisplayedEntryWidgets()
                UIWeapon.WeaponList.bCanMove = false
                for i = 1, array:Length() do
                    local weapon = array:Get(i).tbData.pItem
                    if weapon and gdpl[1] == weapon:Genre() and gdpl[2] == weapon:Detail() and gdpl[3] == weapon:Particular() and gdpl[4] == weapon:Level() then
                        Path = {"Weapon", "WeaponList", i, "BtnClick"}
                        break
                    end
                end
            end
        end
    elseif Path[1] == "Special_SelectChapterLevel" and sUI.sName == 'level' then
        if sUI.LevelContent and sUI.LevelContent.tbLevelWidget[tonumber(Path[2])] then
            return sUI.LevelContent.tbLevelWidget[tonumber(Path[2])].Btn
        end
        return nil
    elseif Path[1] == "Special_SelectResourseLevel" and sUI.sName == 'dungeonsresourse' then
        local index = tonumber(Path[2])
        local array = sUI.CustListView_66:GetDisplayedEntryWidgets()
        sUI.CustListView_66:SetScrollable(false)
        for i = 1, array:Length() do
            if array:Get(i).nID == index then
                return array:Get(i).Object.BtnClick
            end
        end
        return nil
    end

    local widget = sUI
    local temp = 1
    for _, v in pairs(Path) do
        local index = tonumber(v)
        if index then
            if temp == 2 then
                widget = widget:GetDisplayedEntryWidgets():Get(index)
            else
                widget = widget:GetChildAt(index)
            end
        else
            widget = widget[v]
            if widget and widget:Cast(UE4.UListViewBase) then
                if widget.bCanMove then
                    widget.bCanMove = false
                end
                temp = 2
            else
                temp = 1
            end
        end
        if not widget then
            return nil
        end
    end
    return widget
end

--- 进入下一个步骤
function tbClass:GotoNextStep()
    self:OnStepEnd()
    local funBeginNext = function()
        WidgetUtils.Collapsed(self.Tips)
        self.Tips:StopAnimation(self.Tips.AllEnter)
        self.Tips:StopAnimation(self.Tips.ALLloop)
        local nNextStep = GuideLogic.GetNextStep(self.nGuideId, self.nStepId + 1)
        self:DelaySetWidgetHidden(self.tbStep, self.nGuideId, self.nStepId)
        self:BeginStep(nNextStep)
    end
    local tbData = self.tbStep[self.nStepId]
    if tbData.Tips and tbData.nTxtDelay and tbData.nTxtDelay > 0 then
        self:ShowMaskFull(false)
        self:AddEvent(tbData.nTxtDelay, funBeginNext)
    else
        funBeginNext()
    end
end

--- 删除事件
function tbClass:ReleaseEvent()
    if self.EventHander then
        self.EventHander:Remove(self, self.pEventCall)
        self.EventHander = nil
        self.pEventCall = nil
    end

    if self.AutoCompleteHandle then UE4.Timer.Cancel(self.AutoCompleteHandle) end
    self.AutoCompleteHandle = nil

    EventSystem.Remove(self.EventPCInputId)
    EventSystem.Remove(self.MouseButtonUpEvent)
    self.EventPCInputId = nil
    self.MouseButtonUpEvent = nil
end

--- 在指引开始前先隐藏界面部分控件
function tbClass:UpdateAllWidget()
    WidgetUtils.Collapsed(self.Tips)
    WidgetUtils.Collapsed(self.GuideCover)
    WidgetUtils.Collapsed(self.GuideNovice)
    WidgetUtils.Collapsed(self.GuideLongPress)
    WidgetUtils.Collapsed(self.GuideClick)
    WidgetUtils.Collapsed(self.HelpPop)
    WidgetUtils.Collapsed(self.FightAction)
    WidgetUtils.Collapsed(self.FightAction2)
    WidgetUtils.Collapsed(self.BtnNoFun)
end

---分别设置2D区域遮罩的显示
function tbClass:SetMaskFullVisibility(bShow)
    if bShow then
        WidgetUtils.Visible(self.MaskUp)
        WidgetUtils.Visible(self.MaskDown)
        WidgetUtils.Visible(self.MaskLeft)
        WidgetUtils.Visible(self.MaskRight)
    else
        WidgetUtils.Collapsed(self.MaskUp)
        WidgetUtils.Collapsed(self.MaskDown)
        WidgetUtils.Collapsed(self.MaskLeft)
        WidgetUtils.Collapsed(self.MaskRight)
    end
end

--- 设置全屏遮罩的显示
function tbClass:ShowMaskFull(isFull)
    self:SetMaskFullVisibility(false)
    WidgetUtils.Collapsed(self.Mask3D)
    if isFull then
        WidgetUtils.Visible(self.MaskFull)
    else
        WidgetUtils.Collapsed(self.MaskFull)
    end
end
--- 设置区域遮罩的显示
function tbClass:ShowMaskPart(isShow)
    WidgetUtils.Collapsed(self.MaskFull)
    self:SetMaskFullVisibility(isShow)
    if not isShow then
        WidgetUtils.Collapsed(self.Mask3D)
    end
end

--- 设置黑色遮罩和图片的显示
function tbClass:ShowPanel(tbData, widget)
    local Panel3D = self:GetWidget(UI.GetUI(tbData.sWindow), tbData.Panel3DPath)
    if Panel3D and not Panel3D:Cast(UE4.UCanvasPanel3D) then
        Panel3D = nil
    end
    if widget then
        local Geometry = widget:GetCachedGeometry()
        self.Halfsize = UE4.USlateBlueprintLibrary.GetLocalSize(Geometry) * 0.5
        if not Panel3D then
            Panel3D = UE4.UUMGLibrary.FindParentCanvasPanel3D(widget)
        end
        local Mask2DGeometry = self.Mask:GetCachedGeometry()
        if Panel3D then
            self.ViewPortPosAbs = UE4.UUMGLibrary.WidgetLocalToAbsolute3D(Panel3D, widget, self.Halfsize)
            self.ViewPortPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(Mask2DGeometry, self.ViewPortPosAbs)
        else
            self.ViewPortPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(Mask2DGeometry, UE4.UUMGLibrary.WidgetLocalToAbsolute3D(self.Mask, widget, self.Halfsize))
        end
    elseif tbData.sTargetActor then
        local Actors = UE4.UGameplayStatics.GetAllActorsOfClass(self, UE4.AActor)
        for i = 1, Actors:Length() do
            local actors = Actors:Get(i)
            if actors:GetName() == tbData.sTargetActor then
                local VectorPos = actors:K2_GetActorLocation()
                self.ViewPortPos = UE4.FVector2D()
                UE4.UGameplayStatics.ProjectWorldToScreen(UE4.UGameplayStatics.GetPlayerController(self, 0), VectorPos, self.ViewPortPos)
                self.ViewPortPos = self.ViewPortPos / self.ViewportScale
                break
            end
        end
    end
    if tbData.TargetSize and #tbData.TargetSize >= 2 then
        self.Halfsize = UE4.FVector2D(tbData.TargetSize[1], tbData.TargetSize[2])
    end

    if tbData.nShowMask > 0 then
        if self.ViewPortPos and self.Halfsize then
            if tbData.bNoFunction then
                self:UpdateBtnSizeAndPos(self.ViewPortPos, self.Halfsize, tbData.ShadowSize)
            else
                self:SetMaskFullVisibility(true)
                self:UpdateSizeAndPos(self.ViewPortPos, self.Halfsize, Panel3D, tbData.ShadowSize)
            end
        elseif tbData.nPressContinue > 0 then
            self:ShowMaskFull(true)
        else
            self:ShowMaskPart(false)
        end
    else --不显示遮罩
        self:ShowMaskPart(false)
    end

    if tbData.Tips then
        self.Tips:PlayAnimation(self.Tips.AllEnter)
        self.Tips:PlayAnimation(self.Tips.ALLloop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)

        local bHandle = false
        local InputType = UE4.UGameKeyboardLibrary.GetActiveInputType()
        if InputType ~= UE4.EKeyboardInputType.Keyboard and tbData.HandleTips then --有手柄
            local Controller = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
            if Controller and Controller.LastInputGamepad then  --正在使用的是手柄
                bHandle = true
            end
        end
        if bHandle then
            self.Tips.TalkText:SetContent(Text(tbData.HandleTips, self:GetHandleName(tbData.HandleKeyBoard, InputType)))
        else
            self.Tips.TalkText:SetContent(Text(tbData.Tips, self:GetKeyBoardName(tbData.KeyBoard)))
        end

        WidgetUtils.HitTestInvisible(self.Tips)
        self:AddEvent(self.DelayStart or 1, function ()
            self.fOffsetNow = 0
        end)

        local TextTipsSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Tips)
        if #tbData.TxtPos >= 2 then
            TextTipsSlot:SetPosition(UE4.FVector2D(tbData.TxtPos[1], tbData.TxtPos[2]))
        end
        if tbData.TxtIcon then
            WidgetUtils.HitTestInvisible(self.Tips.Character)
            self:SetRoleTexture(tbData.TxtIcon)
        else
            WidgetUtils.Collapsed(self.Tips.Character)
        end
        if tbData.TxtTitle then
            WidgetUtils.HitTestInvisible(self.Tips.Speaker)
            self.Tips.Speaker:SetText(Text(tbData.TxtTitle))
        else
            WidgetUtils.Collapsed(self.Speaker)
        end
    end

    if tbData.tbShowList then
        for _, v in pairs(tbData.tbShowList) do
            if self[v] then
                WidgetUtils.HitTestInvisible(self[v])
                if self.ViewPortPos then
                    local wSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self[v])
                    wSlot:SetPosition(self.ViewPortPos)
                end
            end
        end
    end
end

---获取键盘按键名
function tbClass:GetKeyBoardName(tbkey)
    if not tbkey or #tbkey == 0 then
        return nil
    end
    local tb = {}
    for _, key in ipairs(tbkey) do
        local key1 = UE4.UGameKeyboardLibrary.GetInputChordByType(key, UE4.EKeyboardInputType.Keyboard)
        local keyName1 = UE4.UGameKeyboardLibrary.GetInputChordShowName(key1)
        local cfg1 = Keyboard.Get(keyName1)
        if cfg1 and cfg1.sName then
            table.insert(tb, Text(cfg1.sName))
        end
    end
    if #tb>0 then
        return table.unpack(tb)
    end
end

---获取手柄按键名
function tbClass:GetHandleName(tbkey, InputType)
    if not tbkey or #tbkey == 0 or not InputType then
        return nil
    end
    local tb = {}
    for _, key in ipairs(tbkey) do
        local keyName1, keyName2 = Gamepad.GetDisplayNameKeys(key, InputType)
        local cfg1 = Keyboard.Get(keyName1)
        if cfg1 and cfg1.sName then
            keyName1 = Text(cfg1.sName)
        end
        if keyName2 then
            local cfg2 = Keyboard.Get(keyName2)
            if cfg2 and cfg2.sName then
                keyName2 = Text(cfg2.sName)
            end
            table.insert(tb, keyName1 .. "+" .. keyName2)
        else
            table.insert(tb, keyName1)
        end
    end
    if #tb>0 then
        return table.unpack(tb)
    end
end

---刷新文字滚动
function tbClass:UpdateTipTextScrollOffset(InDeltaTime)
    if not self.fOffsetNow then
        return
    end

    local fend = self.Tips.ScrollBoxFight:GetScrollOffsetOfEnd()
    if fend == 0 or self.fOffsetNow >= fend then
        return
    end

    if not self.ScrollSpeed then
        self.ScrollSpeed = 20
    end
    self.fOffsetNow = self.fOffsetNow + (self.ScrollSpeed*InDeltaTime)
    if self.fOffsetNow >= fend then
        self.Tips.ScrollBoxFight:SetScrollOffset(fend)
        self.fOffsetNow = nil
        self:AddEvent(self.DelayEnd or 1, function ()
            self.Tips.ScrollBoxFight:SetScrollOffset(0)
            self:AddEvent(self.DelayStart or 1, function ()
                self.fOffsetNow = 0
            end)
        end)
    else
        self.Tips.ScrollBoxFight:SetScrollOffset(self.fOffsetNow)
    end
end

--- 设置遮罩的区域和位置
function tbClass:UpdateSizeAndPos(ViewPortPos, Halfsize, Panel3D, ShadowSize)
    if Panel3D then
        WidgetUtils.SelfHitTestInvisible(self.Mask3D)
        self.Mask3D:SetCameraAnchor(Panel3D.CameraAnchor)
        self.Mask3D:SetCameraFOV(Panel3D.CameraFOV)
        self.Mask3D:SetCameraRadius(Panel3D.CameraRadius)
        self.Mask3D:SetCameraAngle(Panel3D.CameraAngle)
        self.Mask3D:SetRotateCenter(Panel3D.RotateCenter)
        self.Mask3D:SetRotateValue(Panel3D.RotateValue)
        self.Mask3D:SetOffsetValue(Panel3D.OffsetValue)

        local Mask3DSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Mask3D)
        local Panel3DSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(Panel3D)
        if Panel3DSlot then
            Mask3DSlot:SetAnchors(Panel3DSlot:GetAnchors())
            Mask3DSlot:SetOffsets(Panel3DSlot:GetOffsets())
            Mask3DSlot:SetAlignment(Panel3DSlot:GetAlignment())
        else
            Mask3DSlot:SetAnchors(UE4.FAnchors())
            Mask3DSlot:SetOffsets(UE4.FMargin())
            Mask3DSlot:SetAlignment(UE4.FVector2D())
        end
        -- 延迟一帧再计算3D Mask的位置，只有3D Canvas显示过才会记录变换矩阵
        self:AddEvent(0, function()
            local Center = UE4.UUMGLibrary.AbsoluteToWidgetLocal3D(self.Mask3D, self.ViewPortPosAbs)
            local LT = Center - Halfsize;
            local RB = Center + Halfsize;

            --刷新3D遮罩
            local Left3DSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Mask3DLeft)
            Left3DSlot:SetPosition(UE4.FVector2D(0, 0))
            Left3DSlot:SetSize(UE4.FVector2D(LT.X, self.ViewportSize.Y))

            local Right3DSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Mask3DRight)
            Right3DSlot:SetPosition(UE4.FVector2D(RB.X, 0))
            Right3DSlot:SetSize(UE4.FVector2D(self.ViewportSize.X - RB.X, self.ViewportSize.Y))

            local Up3DSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Mask3DUp)
            Up3DSlot:SetPosition(UE4.FVector2D(LT.X, 0))
            Up3DSlot:SetSize(UE4.FVector2D(Halfsize.X * 2, LT.Y))

            local Down3DSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Mask3DDown)
            Down3DSlot:SetPosition(UE4.FVector2D(LT.X, RB.Y))
            Down3DSlot:SetSize(UE4.FVector2D(Halfsize.X * 2, self.ViewportSize.Y - RB.Y))
        end)
    else
        WidgetUtils.Collapsed(self.Mask3D)
    end

    --刷新2D遮罩
    local LeftSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.MaskLeft)
    LeftSlot:SetPosition(UE4.FVector2D(-200, -200))
    LeftSlot:SetSize(UE4.FVector2D(ViewPortPos.X - Halfsize.X + 200, self.ViewportSize.Y + 400))

    local RightSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.MaskRight)
    RightSlot:SetPosition(UE4.FVector2D(ViewPortPos.X + Halfsize.X, -200))
    RightSlot:SetSize(UE4.FVector2D(self.ViewportSize.X - ViewPortPos.X - Halfsize.X + 200, self.ViewportSize.Y + 400))

    local UpSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.MaskUp)
    UpSlot:SetPosition(UE4.FVector2D(ViewPortPos.X - Halfsize.X, -200))
    UpSlot:SetSize(UE4.FVector2D(Halfsize.X * 2, ViewPortPos.Y - Halfsize.Y + 200))

    local DownSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.MaskDown)
    DownSlot:SetPosition(UE4.FVector2D(ViewPortPos.X - Halfsize.X, ViewPortPos.Y + Halfsize.Y))
    DownSlot:SetSize(UE4.FVector2D(Halfsize.X * 2, self.ViewportSize.Y - ViewPortPos.Y - Halfsize.Y + 200))

    ---隐藏全屏遮罩  现在才可以点击
    WidgetUtils.Collapsed(self.MaskFull)
    self:UpdateGuideRound(ViewPortPos, Halfsize, ShadowSize)
end

---设置无功能型指引按钮的位置和大小
function tbClass:UpdateBtnSizeAndPos(ViewPortPos, Halfsize, ShadowSize)
    WidgetUtils.Visible(self.BtnNoFun)
    local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.BtnNoFun)
    Slot:SetPosition(ViewPortPos)
    Slot:SetSize(Halfsize*2)
    self:UpdateGuideRound(ViewPortPos, Halfsize, ShadowSize)
end

---设置指引动画的显示
function tbClass:UpdateGuideRound(ViewPortPos, Halfsize, ShadowSize)
    if not self.GuideRound then
        return
    end

    if not ViewPortPos or not Halfsize then
        self:HideGuideRound()
        return
    end

    local Scale = 1
    if ShadowSize and ShadowSize > 0 then
        Scale = ShadowSize/370
    end
    self:ShowGuideRound(ViewPortPos.X, ViewPortPos.Y, Scale)
    --显示遮罩并设置遮罩空白位置和空白大小
    self:SetOpacityPos(ViewPortPos.X/self.ViewportSize.X, ViewPortPos.Y/self.ViewportSize.Y, self.ViewportSize.X/ShadowSize, self.ViewportSize.Y/ShadowSize)
end

--- 步骤结束
function tbClass:OnStepEnd()
    if not self.nStepId or not self.tbStep then return end

    --隐藏动画
    self:UpdateGuideRound()
    ---隐藏Mask遮罩 避免3DUI报错
    WidgetUtils.Collapsed(self.Mask)

    self.IsInStep = false
    self:ReleaseEvent()
    self.Halfsize = nil
    self.ViewPortPos = nil
    self.isDynamic = false

    self.InvalidClickNum = 0
    self.InvalidClickTime = 0

    self.fOffsetNow = nil

    -- QTE指引结束特殊操作一下
    -- if self.nGuideId == 105 and self.nStepId == 2 then
    --     local uifight = UI.GetUI("Fight")
    --     if uifight then
    --         WidgetUtils.Visible(uifight.SkillPanel.Skill1)
    --         WidgetUtils.Visible(uifight.SkillPanel.Skill3)
    --         WidgetUtils.Visible(uifight.SkillPanel.Skill5)
    --         WidgetUtils.Visible(uifight.SkillPanel.Aim)
    --     end
    -- end

    local tbData = self.tbStep[self.nStepId]
    if not tbData.nTxtDelay and self.WidgetHidden[self.nGuideId] and self.WidgetHidden[self.nGuideId][self.nStepId] then
        local sUI = UI.GetUI(tbData.sWindow)
        local widget = self:GetWidget(sUI, tbData.Path)
        if widget then
            widget:SetWidgetHidden(true)
        end
        self.WidgetHidden[self.nGuideId][self.nStepId] = false
    end

    if self.nGuideId == 5 and self.nStepId == 1 then
        local uifight = UI.GetUI("fight")
        if uifight and uifight:IsOpen() and uifight.SkillPanel then
            WidgetUtils.Visible(uifight.SkillPanel.Fire)
        end
    end

    --执行步骤结束时扩展
    GuideLogic.ExecuteExtension(self.tbStep[self.nStepId].StepEnd)

    GuideLogic.WriteGuideLog(string.format("%d|%d|%s|1", self.nGuideId, self.nStepId, self.tbConfig.sType))
end

---添加倒计时执行事件
---@param time number 倒计时
---@param callBack function 执行函数
function tbClass:AddEvent(time, callBack)
    if type(time) ~= "number" or type(callBack) ~= "function" then
        return
    end
    if not self.tbEvent then
        self.tbEvent = {}
    end
    local event = {Time = time, CallBack = callBack}
    table.insert(self.tbEvent, event)
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    --如果可以跳过,则记录无效点击，超过次数显示跳过按钮
    if self.tbConfig.bSkip then
        if not self.InvalidClickTime then
            --无效点击记录时间，超过三秒重置
            self.InvalidClickTime = 0
        end
        self.InvalidClickTime = self.InvalidClickTime + InDeltaTime
        if self.InvalidClickTime >= 3 then
            self.InvalidClickTime = 0
            self.InvalidClickNum = 0
        end
    end

    if self.bPaused then  --暂停中
        return
    end
    self:NativeTick(MyGeometry, InDeltaTime)
    self:UpdateTipTextScrollOffset(InDeltaTime)
    if not self.tbEvent or #self.tbEvent <= 0 then
        return
    end

    local tbnowfun = {}
    for i, event in ipairs(self.tbEvent) do
        if event.Time <= 0 then
            tbnowfun[i] = event.CallBack
        end
        event.Time = event.Time - InDeltaTime
    end
    for i, fun in pairs(tbnowfun) do
        if self.tbEvent and self.tbEvent[i] then
            table.remove(self.tbEvent, i)
        end
        fun()
    end
end

--- 设置tips头像的贴图
function tbClass:SetRoleTexture(key)
    if key and self.RoleMaterial then
        UE4.UPlotLibrary.SetPlotRoleTexture(key, self.RoleMaterial)
        self.isDynamic = true
    end
end

function tbClass:NativeTick(MyGeometry, InDeltaTime)
    if not self.isDynamic then
        return
    end
    self.m_fCurrentTime = self.m_fCurrentTime + InDeltaTime
    if self.m_fCurrentTime > self.m_fMaxTime then
        self.m_fCurrentTime = 0
    end

    if self.Tips.CurveData and self.RoleMaterial then
        local TimeData = self.Tips.CurveData:GetVectorValue(self.m_fCurrentTime)
        self.RoleMaterial:SetScalarParameterValue("NoiseSpeed", TimeData.X)
        self.RoleMaterial:SetScalarParameterValue("NoiseStrength", TimeData.Y)
    end
end

--- 暂停或继续指引
function tbClass:SetGuidePaused(bPaused)
    if bPaused and not self.bPaused then
        self.bPaused = true
        self.MaskFullVisibility = self.MaskFull:GetVisibility()
        self.MaskVisibility = self.Mask:GetVisibility()
        self:ShowMaskFull(false)
    elseif not bPaused and self.bPaused then
        self.bPaused = nil
        if self.MaskFullVisibility then
            self.MaskFull:SetVisibility(self.MaskFullVisibility)
        end
        if self.MaskVisibility then
            self.Mask:SetVisibility(self.MaskVisibility)
        end
        self.MaskFullVisibility = nil
        self.MaskVisibility = nil
    end
end

---当分辨率变化时刷新一下
function tbClass:UpdateUIPos()
    local tbData = self.tbStep[self.nStepId]
    if not tbData then
        return
    end
    --等待两帧之后UI绘制结束后再刷新指引的位置
    self:AddEvent(0, function ()
        self:AddEvent(0, function ()
            self.ViewportScale = UE4.UWidgetLayoutLibrary.GetViewportScale(self)
            self.ViewportSize = UE4.UWidgetLayoutLibrary.GetViewportSize(self) / self.ViewportScale
            local MaskSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Mask)
            MaskSlot:SetPosition(UE4.FVector2D(0, 0))
            MaskSlot:SetSize(UE4.FVector2D(self.ViewportSize.X, self.ViewportSize.Y))
            local MaskOpacitySlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.MaskOpacity)
            MaskOpacitySlot:SetPosition(UE4.FVector2D(0, 0))
            MaskOpacitySlot:SetSize(UE4.FVector2D(self.ViewportSize.X, self.ViewportSize.Y))

            local sUI = UI.GetUI(tbData.sWindow)
            if tbData.sWindow ~= "" and (not sUI or not sUI:IsOpen()) then
                return
            end
            local widget = self:GetWidget(sUI, tbData.WidgetPath) or self:GetWidget(sUI, tbData.Path)
            self:ShowPanel(tbData, widget)
        end)
    end)
end

-- 处理缓存隐藏的控件
function tbClass:DelaySetWidgetHidden(tbStep, nID, nStepId)
    if self.WidgetHidden[nID] and self.WidgetHidden[nID][nStepId] then
        local tbData = tbStep[nStepId]
        local sUI = UI.GetUI(tbData.sWindow)
        local widget = self:GetWidget(sUI, tbData.Path)
        if widget then
            widget:SetWidgetHidden(true)
        end
        self.WidgetHidden[nID][nStepId] = false
    end
end

-- 打开时不聚焦
function tbClass:DontFocus()
    return true;
end

return tbClass
