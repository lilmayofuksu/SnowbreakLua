-- ========================================================
-- @File    : RoundTimerExecute.lua
-- @Brief   : 打靶-回合计时
-- ========================================================

local RoundTimer = Class()

RoundTimer.TimerHandle = nil
RoundTimer.LeftTime = 0
RoundTimer.TargetShootUI = nil
RoundTimer.HadKillNum = 0
RoundTimer.ShowInfoDone = false
function RoundTimer:OnActive()
    -- print("RoundTimer:OnActive")
    self.LeftTime = self.Duration
    self.CountTime = self.EnterTimer

    local bCanShow = me:GetAttribute(TargetShootLogic.nGroupId, TargetShootLogic.ShownInfo)
    if bCanShow and self.bIsFirst then
        self.ShowInfoDone = true
        self:ShowInfo()
    else
        self:InitTargetShootUI()
    end

    -- UE4.Timer.Add(3, function()
    -- print("RoundTimer:OnActive", self.LeftTime, self.Duration)
    -- end)

    -- 统计怪物死亡数量以实现计时器时间未到，怪物杀完切换进入下一波
    self.DeathHandle = EventSystem.On(
        "CharacterDeath",
        function(InMonster)
            if IsAI(InMonster) then
                local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
                if (not IsValid(PlayerController)) then
                    return
                end
                for i = 1, PlayerController.TargetShootScoreArray:Length() do
                    local Item = PlayerController.TargetShootScoreArray:Get(i)
                    if Item.Id == InMonster.TemplateID then
                        local MonsterValue = Item.Score
                        if Item.Type == UE4.ETargetShootItemType.Normal or Item.Type == UE4.ETargetShootItemType.High then
                            print("RoundTimer:CharacterDeath", InMonster.TemplateID, MonsterValue)
                            self.HadKillNum = self.HadKillNum + 1
                            if self.HadKillNum >= self.AllNum then
                                self:Finish()
                            end
                        end
                        break
                    end
                end
            end
        end,
        false)
end

function RoundTimer:InitTargetShootUI()
    if self.ShowInfoDone then --显示过提示信息，隐藏鼠标
        local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
        if IsValid(PlayerController) then
            print("RoundTimer:InitTargetShootUI hide mouse")
            PlayerController:ExhaleMouse(false)
        end
    end

    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.uw_fight_target then
        -- print("RoundTimer:OnActive Fight UW",FightUMG.uw_fight_target)
        self.TargetShootUI = FightUMG.uw_fight_target
        self.TargetShootUI:Active(self)
    end

    if self.bIsFirst then --是每一场的第一轮
        self:LockPlayer(true)
        self:CloseDamageFloat()
        TargetShootLogic.SetCanEnterRound(false)
        self.CountHandle =
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
            {
                self,
                function()
                    self.CountTime = self.CountTime - 1 --开场倒计时5秒
                    if self.TargetShootUI and self.CountTime >= 0 then
                        -- print("RoundTimer:CountTimer Tick", self.CountTime)
                        self.TargetShootUI:UpdateFirstTimer(self, false)
                    end
                    if self.CountTime < 0 then
                        TargetShootLogic.SetCanEnterRound(true)
                        self.TargetShootUI:CloseFirstTimer(self)
                        self.bIsFirst = false
                        self:LockPlayer(false)
                        self:ClearTimerHandle()
                        self:StartRoundTimer()
                        return
                    end
                end
            },
            1,
            true
        )
    else
        TargetShootLogic.SetCanEnterRound(true)
        self:StartRoundTimer()
    end

end

--锁定玩家
function RoundTimer:LockPlayer(bLock)
    local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
    if IsValid(PlayerController) then
        if bLock then
            UE4.UUMGLibrary.ReleaseInput()
            PlayerController:ClearAllKeyboardInput()
            PlayerController:ClearAllKeyboardInputStateCache()
            PlayerController:LockControl(true, true, true, true, true, true, true, true)
        else
            PlayerController:UnLockControl()
            PlayerController:RestoreAllKeyboardInput()
        end
    end
end

function RoundTimer:ShowInfo()
    if not UI.IsOpen("TargetShootInfo") then
        UI.Open("TargetShootInfo")
        self.InfoUI = UI.GetUI("TargetShootInfo")
        self.InfoUI:SetNode(self)
        self:LockPlayer(true)
        --呼出鼠标给确认框
        local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
        if IsValid(PlayerController) then
            PlayerController:ExhaleMouse(true)
        end
    end
end

function RoundTimer:CloseDamageFloat()
    --关闭伤害数字上飘

    local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
    if (not IsValid(PlayerController)) then
        return
    end
    PlayerController.bDisableDamageShow = true
end

-- 设置得分倍率
function RoundTimer:SetScoreScale(Scale)
    local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
    if (not IsValid(PlayerController)) then
        return
    end
    print("RoundTimer:SetScoreScale", Scale)
    PlayerController.TargetShootScoreScale = Scale
end

function RoundTimer:StartRoundTimer()--开启局内计时器，此计时器内含有多轮刷新怪物，计时器结束即玩法结束
    self:ClearTimerHandle()
    print("RoundTimer:StartRoundTimer", self.LeftTime)
    self.TimerHandle =
    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                self.LeftTime = self.LeftTime - 0.1
                if self.TargetShootUI and self.LeftTime >= 0 then
                    -- print("RoundTimer:RoundTimer Tick", self.LeftTime)
                    self.TargetShootUI:UpdateRoundTimer(self)
                end
                if self.LeftTime < 0 then
                    self.LeftTime = 0
                    print("RoundTimer:RoundTimer Finish", self.LeftTime)
                    self:ClearTimerHandle()
                    self:Finish()
                    return
                end
            end
        },
        0.1,
        true
    )
end

function RoundTimer:OnActive_Client()
end

function RoundTimer:OnUpdate_Client(leftTime)
    self.LeftTime = leftTime;
end

function RoundTimer:ClearTimerHandle()
    -- print("RoundTimer:ClearTimerHandle")
    if self.TimerHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
    elseif self.CountHandle then
        UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.CountHandle)
    end
end

function RoundTimer:ClearDeathHandle()
    -- print("RoundTimer:ClearDeathHandle")
    EventSystem.Remove(self.DeathHandle)
end

function RoundTimer:OnEnd()
    self:ClearDeathHandle()
    self:ClearTimerHandle()
end

function RoundTimer:OnEnd_Client()
end

function RoundTimer:OnFail()
end

function RoundTimer:OnFail_Client()
end

function RoundTimer:OnFinish_Client()
end

function RoundTimer:OnFinish()
end

--获取开局倒计时
function RoundTimer:GetCountTime()
    local time = math.max(self.CountTime, 0)
    -- print("RoundTimer:GetCountTime", self.CountTime)
    return time
end

--获取每波倒计时
function RoundTimer:GetLeftTime()
    return self.LeftTime
end

return RoundTimer
