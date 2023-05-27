-- ========================================================
-- @File    : TargetShootScoreExecute.lua
-- @Brief   : 打靶-回合计时
-- ========================================================

local TargetShootScoreExecute = Class()

TargetShootScoreExecute.TimerHandle = nil
TargetShootScoreExecute.Score = 0

function TargetShootScoreExecute:OnActive()
    local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0):Cast(UE4.AGamePlayerController)
    if (not IsValid(PlayerController)) then
        return
    end
    PlayerController.TargetShootScoreArray = self.ScoreItemArray
    PlayerController.TargetShootTotalScore = self.Score
    print("TargetShootScoreExecute OnActive:", PlayerController, PlayerController.TargetShootScoreArray)
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.uw_fight_target then
        self.TargetShootUI = FightUMG.uw_fight_target
    end
    self.DeathHandle = EventSystem.On(
        "CharacterDeath",
        function(InMonster)
            if IsAI(InMonster) then
                local TempScore = self.Score
                for i = 1, self.ScoreItemArray:Length() do
                   local Item = self.ScoreItemArray:Get(i)
                   if Item.Id == InMonster.TemplateID then
                        print("TargetShootScoreExecute Score MonsterInfo", InMonster.TemplateID, Item.Score, Item.Type)
                        local ScoreValue = Item.Score
                        if ScoreValue ~= 0 and ScoreValue ~= nil and (Item.Type ~= UE4.ETargetShootItemType.Bomb or Item.Type ~= UE4.ETargetShootItemType.Ammo) then
                            if ScoreValue > 0 then
                                if self.TargetShootUI then
                                    ScoreValue = ScoreValue * self.TargetShootUI.RangeState
                                end
                                self.Score = self.Score + ScoreValue
                            elseif ScoreValue < 0 then
                                -- print("TargetShootScoreExecute Score:", self.Score, "in Score:", ScoreValue)
                                if self.Score <= math.abs(ScoreValue) then
                                    -- print("TargetShootScoreExecute Score <= 0", self.Score)
                                    self.Score = 0
                                else
                                    self.Score = self.Score + ScoreValue --扣分
                                    -- print("TargetShootScoreExecute Score > 0", self.Score)
                                end
                            end
                            print("TargetShootScoreExecute Score Modify", self.Score)
                            if TempScore < self.Score then
                                local tbParam = {
                                    FuncName = "RecordHighestScore",
                                    Score = self.Score,
                                }
                                print("TargetShootScoreExecute Score MsgSend", self.Score)
                                TargetShootMsgHandle.TargetShootMsgSender(tbParam, function(RetScore)
                                    if self.TargetShootUI then
                                        self.TargetShootUI:UpdateHistoryScore(RetScore.Score)
                                    end
                                end)
                            end
                            PlayerController.TargetShootTotalScore = self.Score
                        end
                        break
                   end
                end


                self:UpdateDataToClient(self.Score)
                self:SetExecuteDescription()
            end
        end,
        false)

    TaskCommon.AddHandle(self.DeathHandle)
    self:SetExecuteDescription()
end

function TargetShootScoreExecute:OnActive_Client()
end

function TargetShootScoreExecute:OnUpdate_Client(Score)
    print("TargetShootScoreExecute OnUpdate_Client", self.Score)
    self.Score = Score
    self:SetExecuteDescription()
end

function TargetShootScoreExecute:ClearTimerHandle()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.TimerHandle)
end

function TargetShootScoreExecute:OnFail_Client()
end

function TargetShootScoreExecute:OnFail()
end

function TargetShootScoreExecute:OnEnd()
    self:ClearTimerHandle()
end

function TargetShootScoreExecute:OnFinish()
    self:ClearTimerHandle()
end

function TargetShootScoreExecute:OnFinish_Client()
end

function TargetShootScoreExecute:GetDescription()
    if self:IsServer() then
        self.DescArgs:Clear()
        self.DescArgs:Add(self.Score)
    elseif self:IsClient() then
        self.Score = self.DescArgs:Get(1)
    end

    local Title = string.format(self:GetUIDescription(), self.Score, self.TargetScore)
    print("TargetShootScoreExecute GetDescription", self.Title, self.Score)
    return Title
end

return TargetShootScoreExecute
