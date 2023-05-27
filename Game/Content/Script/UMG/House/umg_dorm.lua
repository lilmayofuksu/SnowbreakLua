-- ========================================================
-- @File    : umg_dorm.lua
-- @Brief   : 宿舍主界面
-- ========================================================

--- @class umg_dorm : UI_Template
local tbClass = Class("UMG.BaseWidget")
tbClass.tbCountDown = {60, 30}

--功能性子UI，特定情况下打开的全屏UI，如3DUI等
tbClass.FuncUIPath = {
    TalkUIPath = '/Game/UI/UMG/Dorm/Widgets/uw_dorm_dialogue.uw_dorm_dialogue_C'
}

--功能性子UI，特定情况下打开的全屏UI，如3DUI等,存储实例
tbClass.FuncUIIns = {}

function tbClass:OnInit()

    if IsMobile() then
        self.tbCustomize = {
            { self.JoyStick.JoyStick, self.JoyStick.Area },-- JPanel 1
            self.JoyStick.CheckKeepRun, -- JPanel 2
        }

        WidgetUtils.Visible(self.JoyStick)
        WidgetUtils.Visible(self.BtnGaze)
    else
        WidgetUtils.Collapsed(self.JoyStick)
        WidgetUtils.Collapsed(self.BtnGaze)
    end

    WidgetUtils.Visible(self.BtnMap)

    BtnAddEvent(self.BtnMap,function ( ... )
        if not HouseLogic:IsPlayerCanControl() then
            return
        end
        UI.Open('DormMap',0)
    end)

    self.BtnGaze.OnPressed:Add(self, function()
        if self.player then
            self.player:OnGazeButton(true)
        end
    end)

    self.BtnGaze.OnReleased:Add(self, function()
        if self.player then
            self.player:OnGazeButton(false)
        end
    end)

    self.BubbleWidgetClass = LoadClass('/Game/UI/UMG/Dorm/Widgets/uw_dorm_bubble.uw_dorm_bubble_C');
    self.HitRes = UE4.FHitResult();
    self.IgnoreActors = UE4.TArray(UE4.AActor);
end

function tbClass:UpdateCustomizeWidgets()
    if not IsMobile() then return end
    local sCfg = UE4.UUserSetting.GetString('Customize');
    local tbCfg = json.decode(sCfg) or {}
    local pFunc = function (widget, config)
        widget:SetRenderScale(UE4.FVector2D(config.Scale or 1, config.Scale or 1))
        widget:SetRenderOpacity(config.Opacity or 1)
        widget:SetRenderTranslation(UE4.FVector2D(config.X or 0, config.Y or 0))
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

function tbClass:UpdateJoystic()
    if IsMobile() then 
        local JFixed = PlayerSetting.Get(PlayerSetting.SSID_OPERATION, OperationType.JOYSTIC_FIXED);
        self.JoyStick.JoyStickFixed = JFixed[1] == 1;
    end
end

function tbClass:OnOpen()
    if not RunFromEntry then
        UI.Open('AdinGM')
    end
    --[[self.Title:SetCustomEvent(function ()
        GoToMainLevel()
        --UI.OpenMainUI()
        --UI.GC()
    end, function()
        GoToMainLevel()
        --UI.OpenMainUI()
        --UI.GC()
    end)]]


    -- self:UpdateJoystic()
    local player = UE4.UGameplayStatics.GetPlayerController(self,0)
    local housePlayer = player:Cast(UE4.AHousePlayerController)
    if housePlayer then
        self.player = housePlayer
    end

    self.BubbleCache = self.BubbleCache or {}

    self:SetMaskOpa()
end

function tbClass:OnClose()
    self:SetMaskOpa()
end

function tbClass:TalkWith(npcId,InGirlId)
    --[[if not self.FuncUIIns.TalkUI then
        local Path = self.FuncUIPath.TalkUIPath
        local FuncUIClass = LoadClass(Path)
        self.FuncUIIns.TalkUI = NewObject(FuncUIClass,self,nil)
    end
    local UIClass = self.FuncUIIns.TalkUI
    UIClass:AddToViewport(UIClass.pOrder)
    print("HoustTest::ShowPlotUI::",InGirlId)]]
    UI.Open('DormDialogue')
    local UIClass = UI.GetUI('DormDialogue')

    --WidgetUtils.SelfHitTestInvisible(UIClass)
    if UIClass.ShowTalk then
        self:ShowMouseCursor(true)
        if self.player then
            self.player:SetBlockControl(true)
        end

        UIClass.TalkNpcId = npcId
        UIClass.TalkGirlId = InGirlId
        UIClass:ShowTalk()
    end
end

function tbClass:EndTalk()
    --[[if self.FuncUIIns.TalkUI then
        self.FuncUIIns.TalkUI:OnTalkEnd()
        WidgetUtils.Hidden(self.FuncUIIns.TalkUI)
        --self.FuncUIIns.TalkUI:RemoveFromViewport()
    end]]
    self:ShowMouseCursor(false)
    UI.CloseByName('DormDialogue')
    if self.player then
        self.player:SetBlockControl(false)
        self.player:TryInteract()
    end
end

function tbClass:ShowMouseCursor(bShow)
    RuntimeState.ChangeInputMode(bShow)
end

function tbClass:SetMaskOpa()
    WidgetUtils.Collapsed(self.Black)
    self.Black:SetRenderOpacity(1.0)
end

function tbClass:ShowUIMask(bShow)
    if bShow then
        WidgetUtils.SelfHitTestInvisible(self.Black)
    else
        --[[if self:IsOpen() then
            self:UnbindAllFromAnimationFinished(self.Enter)
            self:BindToAnimationEvent(self.Enter,
            { self, tbClass.SetMaskOpa},
            UE4.EWidgetAnimationEvent.Finished)
            self:PlayAnimation(self.Enter)
        else
            self:SetMaskOpa()
        end]]
        self:SetMaskOpa()
    end
end

function tbClass:Tick(MyGeometry,InDeltaTime)
    if CountTB(self.BubbleCache or {}) <= 0 or not IsValid(self.player) or not IsValid(self.player:K2_GetPawn()) then
        return
    end
    for k,v in pairs(self.BubbleCache) do
        if IsValid(k) and IsValid(v.bubble) then
            local Dis = UE4.FVector.DistSquared(self.player:K2_GetPawn():K2_GetActorLocation(),k:K2_GetActorLocation())
            self.IgnoreActors:Clear()
            self.IgnoreActors:Add(k)
            local bHit = UE4.UKismetSystemLibrary.LineTraceSingle(self, self.player.PlayerCameraManager:GetCameraLocation(), k.Mesh:GetSocketLocation("socket_housebubble"), 7, false, self.IgnoreActors, UE4.EDrawDebugTrace.None, self.HitRes, true);
            if Dis > 25000000 or bHit then
                WidgetUtils.Collapsed(v.bubble)
            else
                WidgetUtils.SelfHitTestInvisible(v.bubble)
                local pos = k.Mesh:GetSocketLocation("socket_housebubble")
                local ScreenPos = UE4.FVector2D()
                UE4.UGameplayStatics.ProjectWorldToScreen(self.player, pos, ScreenPos)
                local WidgetPos = UE4.FVector2D()
                UE4.USlateBlueprintLibrary.ScreenToWidgetLocal(self.CanvasPanel_0, self.CanvasPanel_0:GetCachedGeometry(), ScreenPos, WidgetPos)
                local BubbleSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(v.bubble)
                if BubbleSlot then
                    BubbleSlot:SetAlignment(UE.FVector2D(0.5, 0.5))
                    BubbleSlot:SetSize(UE.FVector2D(100, 30))
                    local rs = self:GetBubbleScale(Dis);
                    v.bubble:SetRenderScale(UE4.FVector2D(rs,rs))
                    BubbleSlot:SetAutoSize(true)
                    BubbleSlot:SetPosition(WidgetPos)
                end
            end
        end
    end
end

function tbClass:GetBubbleScale(DistSquard)
    local scale = 1
    if not DistSquard then
        return scale
    end
    local MaxDis = 640000
    local MinDis = 10000
    local MinScale = 0.5
    local MaxScale = 1.0
    if DistSquard > MaxDis then
        scale = MinScale
    elseif DistSquard < MinDis then
        scale = MaxScale
    else
        scale = MaxScale - (MaxScale - MinScale) * (DistSquard - MinDis)/(MaxDis - MinDis)
    end
    return scale
end

function tbClass:AddBubble(InCharacter,InTexId)
    --CanvasPanel_0
    self.BubbleCache = self.BubbleCache or {}
    local NewItem = NewObject(self.BubbleWidgetClass, self, nil)
    self.CanvasPanel_0:AddChild(NewItem)
    SetTexture(NewItem.ImgIcon,InTexId)
    self.BubbleCache[InCharacter] = {bubble = NewItem,texId = InTexId}
end

function tbClass:RemoveBubble(InCharacter,InTexId)
    --CanvasPanel_0
    self.BubbleCache = self.BubbleCache or {}
    if self.BubbleCache[InCharacter] and IsValid(self.BubbleCache[InCharacter].bubble) then
        self.BubbleCache[InCharacter].bubble:RemoveFromParent();
    end
end

function tbClass:StopMove()
    if IsMobile() then
        self.JoyStick:StopMove()
    end
end

return tbClass
