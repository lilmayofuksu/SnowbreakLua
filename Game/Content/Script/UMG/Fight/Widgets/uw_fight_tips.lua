-- ========================================================
-- @File    : uw_fight_tips.lua
-- @Brief   : 战斗界面提示
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_tips = Class("UMG.SubWidget")
uw_fight_tips.tbTips = {}
uw_fight_tips.bPlaying = false
uw_fight_tips.FightUI = nil
uw_fight_tips.FinishType = 0 -- 0 默认 1 FightTipsKey 2 FightTipsGain

function uw_fight_tips:Construct()
    self:RemoveRegisterEvent()
    self:RegisterEvent(
        Event.FightTip,
        function(InTip, Msg)
            if InTip.bCheckIsPlaying and self.bPlaying then
                return;
            end
            WidgetUtils.HitTestInvisible(self)
            self:Add(InTip)
        end
    )
    WidgetUtils.Collapsed(self)
    WidgetUtils.Collapsed(self.TitleChange)
    WidgetUtils.Collapsed(self.TitleFinish)
    WidgetUtils.Collapsed(self.TitleFail)
    WidgetUtils.Collapsed(self.Tipskey)
    WidgetUtils.Collapsed(self.Tipsgain)
end

function uw_fight_tips:ShowGuardUI()
    --[[local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.LevelGuard and self.HasCloseGuard then
        WidgetUtils.SelfHitTestInvisible(FightUMG.LevelGuard)
        self.HasCloseGuard = false;
    end]]
end

function uw_fight_tips:OnDestruct()
    self:RemoveRegisterEvent()
    self.pGameTaskActor = nil
end

function uw_fight_tips:Add(InTip)
    if not self.FightUI then
        self.FightUI = UI.GetUI("Fight")
    end
    if not InTip.bShowCompleteTip then
        return
    end
    table.insert(self.tbTips, InTip)
    if not self.bPlaying then
        self:TryPlay()
    end
end

function uw_fight_tips:AddBuff(buffId) -- use uw fight tipskey, not queue
    self.BuffId = buffId
    if self:AddTip(Text('buff_online.buff_'..buffId..'_name'), Text('buff_online.buff_'..buffId..'_dec')) then
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                function()
                    self:RemoveTip()
                    self.BuffId = nil
                    self:TryPlay()
                end
            },
            3,
            false
        )
    end
end

function uw_fight_tips:TryPlay()
    print("uw_fight_tips:TryPlay:", #self.tbTips)

    if self.BuffId then return end

    if #self.tbTips <= 0 then
        self.bPlaying = false
        WidgetUtils.Collapsed(self.TitleChange)
        WidgetUtils.Collapsed(self.TitleFinish)
        WidgetUtils.Collapsed(self.TitleFail)
        WidgetUtils.Collapsed(self.Tipskey)
        WidgetUtils.Collapsed(self.Tipsgain)
        WidgetUtils.Collapsed(self)
        return
    end

    local Data = table.remove(self.tbTips, 1)
    print("uw_fight_tips:TryPlay Title:", Data.Title)
    print("uw_fight_tips:TryPlay Msg:", Data.Msg)
    self.FinishType = 0
    self.IsSudden = false
    if Data.Type == 0 then -- Data.Type 对应蓝图Enum EFightTipsType
        self.ChangeMsg:SetText(Data.Msg .. string.format("  %s", Text("ui.TxtBattleTips")))
        WidgetUtils.HitTestInvisible(self.TitleChange)
    elseif Data.Type == 1 then
        self.FinishMsg:SetText(Data.Msg .. string.format("  %s", Text("ui.TxtCompleted")))
        if Data.bShowUIAnim then
            self:Play(self.task_refresh)
        end
        WidgetUtils.HitTestInvisible(self.TitleFinish)
    elseif Data.Type == 2 then
        local msg = Text("ui.CountdownTimeTips", Data.Msg)
        self.FailMsgHyper:SetContent(msg)
        WidgetUtils.HitTestInvisible(self.TitleFail)
    elseif Data.Type == 3 then --add buff
        self.FinishMsg:SetText(Data.Msg)
        self:Play(self.task_refresh)
        WidgetUtils.HitTestInvisible(self.TitleFinish)
    elseif Data.Type == 4 or Data.Type == 6 then -- AddTextTip
        self.Tipskey.FinishMsg:SetText(Data.Title)
        self.Tipskey.ChangeMsg:SetText(Data.Msg)
        local ParamDuration
        if Data.Duration == 0 then
            ParamDuration = 2
        else
            ParamDuration = Data.Duration
        end
        self.FinishType = 1
        self.IsSudden = Data.Type == 6
        self:Play(self.Tipskey.Open, ParamDuration, self.Tipskey) -- Duration 默认两秒
        WidgetUtils.HitTestInvisible(self)
        WidgetUtils.HitTestInvisible(self.Tipskey)
        WidgetUtils.HitTestInvisible(self.Tipskey.FinishMsg)
        WidgetUtils.HitTestInvisible(self.Tipskey.ChangeMsg)
        self.Tipskey.Effect:ActivateSystem(true)
    end
    self.bPlaying = true
end

function uw_fight_tips:Play(InAnim, Duration, Owner)
    self:UnbindAllFromAnimationFinished(InAnim)
    if Duration == 0 or Duration == nil then
        self:BindToAnimationEvent(InAnim, {self, uw_fight_tips.Move}, UE4.EWidgetAnimationEvent.Finished)
    elseif Duration == -1 then
        --无限时间，手动控制关闭
    else
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                function()
                    self:Move()
                end
            },
            Duration,
            false
        )
        -- self:BindToAnimationEvent(InAnim, {self, uw_fight_tips.TipskeyDeactiveEffect}, UE4.EWidgetAnimationEvent.Finished)
    end
    Owner = Owner or self
    Owner:PlayAnimation(InAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end

function uw_fight_tips:TipskeyDeactiveEffect()
    if self.Tipskey and self.Tipskey.Effect then
        self.Tipskey.Effect:SetAutoActivate(false)
    end
end

function uw_fight_tips:Move()
    if not self.FightUI then
        return
    end

    if self.FinishType == 0 or self.FinishType == 2 then
        self.FightUI:UnbindAllFromAnimationFinished(self.FightUI.tips_move)
        self.FightUI:BindToAnimationEvent(
            self.FightUI.tips_move,
            { self, uw_fight_tips.TryPlay },
            UE4.EWidgetAnimationEvent.Finished
        )
        self.FightUI:PlayAnimation(self.FightUI.tips_move, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, true)
    elseif self.FinishType == 1 then
        self.Tipskey:UnbindAllFromAnimationFinished(self.Tipskey.Close)
        self.Tipskey:BindToAnimationEvent(
            self.Tipskey.Close,
            { self, uw_fight_tips.TryPlay },
            UE4.EWidgetAnimationEvent.Finished
        )
        
        self.Tipskey:PlayAnimation(self.Tipskey.Close, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, true)
    end

    if self.IsSudden then
        EventSystem.Trigger(Event.ShowSudden)
    end
end

function uw_fight_tips:AddTipsPool(Title, Desc, Duration, Type)
    local InTip = {bShowCompleteTip = true, Type = Type, bShowUIAnim = true, Title = Title, Msg = Desc, Duration = Duration} -- Type 4 for level
    WidgetUtils.HitTestInvisible(self)
    self:Add(InTip)
end

function uw_fight_tips:CloseCurrent()
    -- if #self.tbTips > 0 then
    if self.FightUI and self.Tipskey then
        -- print("uw_fight_tips:RemoveTopInPool Size", #self.tbTips)
        self.FightUI:UnbindAllFromAnimationFinished(self.Tipskey.Close)
        self.FightUI:BindToAnimationEvent(
            self.Tipskey.Close,
            { self, uw_fight_tips.TryPlay },
            UE4.EWidgetAnimationEvent.Finished
        )
        self.FightUI:PlayAnimation(self.Tipskey.Close, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, true)
    end

    -- end
end

return uw_fight_tips
