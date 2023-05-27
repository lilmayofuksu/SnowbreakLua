local tbClass = Class()

function tbClass:OnActive()
	print("ControlAreasExecute:OnActive")
	self.areaTriggers = {}
	self.tbNameKey = {}
	for i=1,3 do
		local tag = self['TriggerTag'..i]
		local trigger = self:FindAreaByTag(tag)
		if trigger then
			self.areaTriggers[#self.areaTriggers + 1] = trigger
			self.tbNameKey[#self.tbNameKey + 1] = #self.tbNameKey + 1
		end
	end

	self.triggerNum = #self.areaTriggers
	self.OccupyStateInfos = {}
	--队伍
	self.TeamNum = {self.InitPoints, self.PointsNeedToWin - self.InitPoints}
	--分配N个区域状态
	for i, v in ipairs(self.areaTriggers) do
		v:DoActive(i, nil)
	end

	self.TimerHandle =
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
				self:OnTimerAdd()
            end
        },
        1,
        true
    )
end

function tbClass:CheckUI()
	if self.OccupyProgressBar then return end

	local FightUMG = UI.GetUI("Fight")
	print("ControlAreasExecute:", FightUMG)
	if FightUMG then
		print("ControlAreasExecute")
		if FightUMG.Occupy then --中间的进度条
			self.OccupyProgressBar = FightUMG.Occupy
			WidgetUtils.SelfHitTestInvisible(self.OccupyProgressBar)
			self.OccupyProgressBar:Init(self.PointsNeedToWin,self.InitPoints)
			print("ControlAreasExecute:CheckUI() init OccupyProgressBar init:", self.PointsNeedToWin)
		end
		if FightUMG.OccupyFight then--中间的进入哪个区域提示
			self.OccupyingPrompt = FightUMG.OccupyFight
		end
		if FightUMG.OccupyList then--左侧列表
			self.OccupySummary = FightUMG.OccupyList
			if not self.triggerNum then
				return
			end
			WidgetUtils.SelfHitTestInvisible(self.OccupySummary)
			self.OccupySummary:InitByAreaNum(self.triggerNum, self.tbNameKey);
		end
	end

		for _, v in ipairs(self.areaTriggers) do
			v:SetGuardUIParent(self.OccupySummary, self.OccupyingPrompt)
		end
end

function tbClass:OnTimerAdd()
	self:CheckUI()
	local bIsDirty = false;
	local PlayerChangedValue = 0;
	local EnemyChangedValue = 0;

	for _, v in ipairs(self.areaTriggers) do
		local teamOwned = v.AreaOwner
		if teamOwned ~= 0 then
			if teamOwned == 1 then
				PlayerChangedValue = PlayerChangedValue + v.ContributeNumPerSec
			elseif teamOwned == 2  then
				EnemyChangedValue = EnemyChangedValue + v.ContributeNumPerSec
			end
			bIsDirty = true;
		end
	end
	if bIsDirty then
		self.TeamNum[1] = (self.TeamNum[1] or 0) + PlayerChangedValue - EnemyChangedValue
		self.TeamNum[2] = (self.TeamNum[2] or 0) + EnemyChangedValue - PlayerChangedValue
		local bIsPlayerScoreIncrease = (PlayerChangedValue - EnemyChangedValue) > 0
		-- local TotalScore = (self.PointsNeedToWin and self.PointsNeedToWin > 0) and self.PointsNeedToWin or 100
		local PlayerCurrentScore = math.max(0, self.TeamNum[1])
		local EnemyCurrentScore = math.max(0, self.TeamNum[2])
		self.OccupyProgressBar:UpdateTeamNum(PlayerCurrentScore, EnemyCurrentScore, bIsPlayerScoreIncrease, false)
	end
	if self.TeamNum[1] >= self.PointsNeedToWin then
		self:Finish()
	elseif self.TeamNum[2] >= self.PointsNeedToWin then
		self:Fail()
	end
	self:SetExecuteDescription()
end

function tbClass:OnActive_Client()
	--self:SetExecuteDescription()
	self:CheckUI()
end

function tbClass:ClearTimerHandle()
	for _, v in ipairs(self.areaTriggers) do
		if v.Disable then
			v:Disable()
		end
	end

	UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.TimerHandle)
	self.TeamNum = {0,0}
	if self.OccupyProgressBar then
		WidgetUtils.Collapsed(self.OccupyProgressBar)
		self.OccupyProgressBar = nil
	end
	if self.OccupyingPrompt then
		WidgetUtils.Collapsed(self.OccupyingPrompt)
		self.OccupyingPrompt = nil
	end
	if self.OccupySummary then
		WidgetUtils.Collapsed(self.OccupySummary)
		self.OccupySummary = nil
	end
end


function tbClass:OnFail()
    self:ClearTimerHandle()
end

function tbClass:OnFinish()
    self:ClearTimerHandle()
end

return tbClass