-- ========================================================
-- @File    : uw_fight_target.lua
-- @Brief   : 战斗界面 打靶
-- ========================================================


local TargetShoot = Class("UMG.SubWidget")
TargetShoot.RangeState = 1 -- 1 普通分区， 2 midrange, 3highrange
TargetShoot.HighestScore = 0
TargetShoot.FirstTimerAudio = 2015 -- 5 4 3 2 1的声音
TargetShoot.FirstTimerStartAudio = 2016 --"Start"字符的声音

function TargetShoot:Active(RoundTimerExecuteNode)
    print("TargetShoot:Active")
    if RoundTimerExecuteNode then
        self.RoundTimerExecute = RoundTimerExecuteNode
        if self.RoundTimerExecute.bIsFirst then
            --获取历史最高分
            self:GetHistoryScore()
            self:UpdateHistoryScore(self.HighestScore)

            WidgetUtils.SelfHitTestInvisible(self)
            WidgetUtils.SelfHitTestInvisible(self.PanelStart)
            -- print("TargetShoot:Active ShowPanel")
            self:UpdateFirstTimer(RoundTimerExecuteNode)
            Audio.PlaySounds(self.FirstTimerAudio)
        end
        self.Bar:SetPercent(1)
        self.bInHighRange = false
        self.bInMidRange = false
        self.bInNormalRange = false
    end
end

--开局倒计时
function TargetShoot:UpdateFirstTimer(RoundTimerExecuteNode)
    if RoundTimerExecuteNode == nil or RoundTimerExecuteNode ~= self.RoundTimerExecute then
        return
    end
    local Time = RoundTimerExecuteNode:GetCountTime()
    -- print("TargetShoot:UpdateFirstTimer", Time)
    if Time > 0 then
        self.TxtTime:SetText(Time)
    elseif Time == 0 then
        self.TxtTime:SetText("Start")
        Audio.PlaySounds(self.FirstTimerStartAudio)
    end

    -- if not bIsInit then
        self:PlayFirstTimeAnim()
    -- end
end

function TargetShoot:PlayFirstTimeAnim()
    -- print("TargetShoot:PlayFirstTimeAnim", self.Time)
    self:PlayAnimFromAnimation(self.Time)
end

function TargetShoot:CloseFirstTimer(RoundTimerExecuteNode)
    if RoundTimerExecuteNode == nil or RoundTimerExecuteNode ~= self.RoundTimerExecute then
        return
    end
    WidgetUtils.Collapsed(self.PanelStart)
end

--获取历史最高分
function TargetShoot:GetHistoryScore()
    local HighestScore = me:GetAttribute(TargetShootLogic.nGroupId, TargetShootLogic.HighestScoreId)
    self.HighestScore = HighestScore
end

--更新历史最高分
function TargetShoot:UpdateHistoryScore(Score)
    if self.HighestScore < Score then
        self.HighestScore = Score
    end
    self.TxtScore:SetText(self.HighestScore)
end

--更新每回合倒计时
function TargetShoot:UpdateRoundTimer(RoundTimerExecuteNode)
    if RoundTimerExecuteNode == nil or RoundTimerExecuteNode ~= self.RoundTimerExecute then
        return
    end
    WidgetUtils.SelfHitTestInvisible(self.LevelGuard)
    local Value = RoundTimerExecuteNode.LeftTime / RoundTimerExecuteNode.Duration
    -- print("TargetShoot:UpdateRoundTimer", Value)
    self.Bar:SetPercent(Value)
    local BeforeValue = self.RangeState
    if RoundTimerExecuteNode.LeftTime <= RoundTimerExecuteNode.Duration and RoundTimerExecuteNode.LeftTime >= RoundTimerExecuteNode.HighRange then
        self.RangeState = 3 --高分区
    elseif RoundTimerExecuteNode.LeftTime < RoundTimerExecuteNode.HighRange and RoundTimerExecuteNode.LeftTime >= RoundTimerExecuteNode.MidRange then
        self.RangeState = 2 --中分区
    elseif RoundTimerExecuteNode.LeftTime < RoundTimerExecuteNode.MidRange and RoundTimerExecuteNode.LeftTime > 0 then
        self.RangeState = 1 --普通分区
    end
    if BeforeValue ~= self.RangeState then
        RoundTimerExecuteNode:SetScoreScale(self.RangeState)
    end
    self.LevelGuard.TxtGuardNum:SetText(string.format("%0.1f",  RoundTimerExecuteNode:GetLeftTime()))
end

return TargetShoot
