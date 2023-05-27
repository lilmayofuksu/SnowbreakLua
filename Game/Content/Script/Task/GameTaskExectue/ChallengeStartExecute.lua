-- ========================================================
-- @File    : ChallengeStartExecute.lua
-- @Brief   : 挑战节点
-- @Author  :
-- @Date    :
-- ========================================================

---@class ChallengeStartExecute : TaskItem
local ChallengeStartExecute = Class()

function ChallengeStartExecute:OnActive()
	local world = GetGameIns():GetWorld()
    local TaskActor = self:GetGameTaskActor()
    self.challengeCfg = UE4.UTaskRandomSubsystem.GetBattleChallange(TaskActor, TaskActor.AreaId)

	print('==================挑战开始==================')
	print('当前挑战ID:'..self.challengeCfg.ChallangeId)

	if self.challengeCfg.TaskType == UE4.EChallangeType.InvalidType or self.challengeCfg.ChallangeId == -1 then
    	self:Finish()
		return
    end

    local ChallengeInfo = { self = self }

	-- 限时挑战
    if self.challengeCfg.TaskType == UE4.EChallangeType.TimeLimited then
    	self.Time = self.challengeCfg.Time
    	self:CountDownReady(ChallengeInfo)
	    
	    if self.challengeCfg.DeathCount > 0 then
	    	self.DeathCount = self.challengeCfg.DeathCount
	    	ChallengeInfo.DeathHook = EventSystem.On(
		        Event.CharacterDeath,
		        function(InMonster)
		            if IsAI(InMonster) then
		                --延迟执行  防止立即注册立即调用
		                local UpdateUITimerHandle =
		                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
		                    {
		                        self,
		                        function()
		                        	self.DeathCount = self.DeathCount - 1
									if self.DeathCount <= 0 then
										return
									end
		                        	self:SetSuddenDescription()
		                        end
		                    },
		                    0.01,
		                    false
		                )
		            end
		        end
		    )
		    TaskCommon.AddHandle(ChallengeInfo.DeathHook)
	    end
    	ChallengeMgr.AddChallenge(self.challengeCfg.ChallangeId, ChallengeInfo)
    end

    -- 击杀挑战2
    if self.challengeCfg.TaskType == UE4.EChallangeType.Kill2 then
    	if self.challengeCfg.Time > 0 then 
    		self.Time = self.challengeCfg.Time
    		self:CountDownReady(ChallengeInfo, ChallengeStartExecute.KillCountDown_Check)
    	end
	    
	    if self.challengeCfg.DeathCount > 0 then
	    	self.DeathCount = self.challengeCfg.DeathCount
	    	ChallengeInfo.DeathHook = EventSystem.On(
		        Event.CharacterDeath,
		        function(InMonster)
		            if IsAI(InMonster) then
		                --延迟执行  防止立即注册立即调用
		                local UpdateUITimerHandle =
		                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
		                    {
		                        self,
		                        function()
									if self.DeathCount > 0 then
										self:SetSuddenDescription()
		                        		self.DeathCount = self.DeathCount - 1
									else
										self:Finish()
									end
		                        	
		                        end
		                    },
		                    0.01,
		                    false
		                )
		            end
		        end
		    )
		    TaskCommon.AddHandle(ChallengeInfo.DeathHook)
	    end
    	ChallengeMgr.AddChallenge(self.challengeCfg.ChallangeId, ChallengeInfo)
    end

    -- 击杀挑战
    if self.challengeCfg.TaskType == UE4.EChallangeType.Kill1 then
    	self.Time = self.challengeCfg.TimeKill
    	self:CountDownReady(ChallengeInfo, ChallengeStartExecute.KillCountDown_Check)
    	ChallengeInfo.DeathHook = EventSystem.On(
	        Event.CharacterDeath,
	        function(InMonster)
	            if InMonster then
	                --延迟执行  防止立即注册立即调用
	                local UpdateUITimerHandle =
	                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
	                    {
	                        self,
	                        function()
	                        	self.Time = self.challengeCfg.TimeKill
	                        	self:SetSuddenDescription()
	                        end
	                    },
	                    0.01,
	                    false
	                )
	            end
	        end
	    )
	    TaskCommon.AddHandle(ChallengeInfo.DeathHook)
	    ChallengeMgr.AddChallenge(self.challengeCfg.ChallangeId, ChallengeInfo)
    end

    -- 血量挑战
    if self.challengeCfg.TaskType == UE4.EChallangeType.Blood then
    	local nAllPlayerMaxHpSum = UE4.ULevelLibrary.GetAllPlayerMaxHpSum(self);
    	self.HurtLimit = nAllPlayerMaxHpSum * self.challengeCfg.Health / 100
    	self.Health = self.challengeCfg.Health
    	ChallengeInfo.DamageReceiveHandle = EventSystem.On(
	        Event.DamageReceive,
	        function(DamageParam)
	            if DamageParam.Target then
	                if DamageParam.Target:Cast(UE4.AGamePlayer) then
	                	self.HurtLimit = self.HurtLimit - DamageParam.DamageResult.RealHealthDamageValue
	                	self.Health =  math.max(math.ceil(100 * self.HurtLimit / nAllPlayerMaxHpSum), 0) 
	                	
	                	print(string.format('================>血量伤害还有%s%%达到上限', self.Health))
	                    if self.Health <= 0 then
                    		self:Finish()
							return
                    	end
						self:SetSuddenDescription()
	                end
	            end
	        end
	    )
	    TaskCommon.AddHandle(ChallengeInfo.DamageReceiveHandle)
	    ChallengeMgr.AddChallenge(self.challengeCfg.ChallangeId, ChallengeInfo)
    end

    -- 死亡挑战
    if self.challengeCfg.TaskType == UE4.EChallangeType.Death then
    	self.DeathCount = self.challengeCfg.DeathCount
    	ChallengeInfo.DeathHook = EventSystem.On(
	        Event.CharacterDeath,
	        function(InCharacter)
	            if InCharacter and InCharacter:Cast(UE4.AGamePlayer) then
	                --延迟执行  防止立即注册立即调用
	                local UpdateUITimerHandle =
	                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
	                    {
	                        self,
	                        function()
	                        	self.DeathCount = self.DeathCount - 1
	                        	if self.DeathCount <= 0 then
	                        		self:Finish()
									return
	                        	end
								self:SetSuddenDescription()
	                        end
	                    },
	                    0.01,
	                    false
	                )
	            end
	        end
	    )
	    TaskCommon.AddHandle(ChallengeInfo.DeathHook)
	    ChallengeMgr.AddChallenge(self.challengeCfg.ChallangeId, ChallengeInfo)
    end

	self:SetSuddenDescription()
end

-- 策划限时内挑战给玩家3缓冲阅读内容
function ChallengeStartExecute:CountDownReady(ChallengeInfo, pCheck)
	if not ChallengeInfo then return end
	self.TimeSuperiorLimit = self.Time
	UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
            	ChallengeInfo.TimerHandle = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, pCheck or ChallengeStartExecute.TimeChallenge_Check}, 1, true)
            	TaskCommon.AddHandle(ChallengeInfo.TimerHandle)
            end
        },
        3,
        false
    )
end

function ChallengeStartExecute:GetDescription()
    if self:IsServer() then
    	self.DescArgs:Clear()
        self.DescArgs:Add(self.challengeCfg.ChallangeId)
        self.DescArgs:Add(self.TimeSuperiorLimit or -1)
        -- 限时挑战
	    if self.challengeCfg.TaskType == UE4.EChallangeType.TimeLimited or self.challengeCfg.TaskType == UE4.EChallangeType.Kill1 then
	    	self.DescArgs:Add(self.Time)
	    	if self.DeathCount and self.DeathCount > 0 then
	    		self.DescArgs:Add(self.DeathCount)
	    	end
	    end

	    -- 击杀挑战2
	    if self.challengeCfg.TaskType == UE4.EChallangeType.Kill2 then
	    	if self.Time then
	    		self.DescArgs:Add(self.Time)
	    	end
	    	
	    	if self.DeathCount and self.DeathCount > 0 then
	    		self.DescArgs:Add(self.DeathCount)
	    	end
	    end


	    -- 血量挑战
	    if self.challengeCfg.TaskType == UE4.EChallangeType.Blood then
			self.DescArgs:Add(self.Health)
		end

	    -- 死亡挑战
	    if self.challengeCfg.TaskType == UE4.EChallangeType.Death then
	    	self.DescArgs:Add(self.DeathCount)
	    end
    end

    return self:GetUIDescription()
end

function ChallengeStartExecute:OnActive_Client()
    
end

function ChallengeStartExecute:TimeChallenge_Check()
	self.Time = self.Time - 1;
	print('限时任务计时剩余'..tostring(self.Time).."s")
	if self.Time <= 0 then 
		self:Finish()
		return 
	end
	self:SetSuddenDescription()
end

function ChallengeStartExecute:KillCountDown_Check()
	self.Time = self.Time - 1;
	print('击杀限时'..tostring(self.Time).."s")
	
	if self.Time <= 0 then 
		self:Finish()
		return
	end

	if self.DeathCount > 0 then
		self:SetSuddenDescription()
	end
end

function ChallengeStartExecute:OnFinish()
	if self:IsServer() and self.challengeCfg.ChallangeId ~= -1 then 
		self:TipToClient('challenge.challenge_defeat', 3) 
	end
end

function ChallengeStartExecute:OnEnd()
	ChallengeMgr.RemoveChallenge(self.challengeCfg.ChallangeId)
end

function ChallengeStartExecute:OnEnd_Client( ... )
	EventSystem.Trigger(Event.OnChallengeFinish)
end

return ChallengeStartExecute
