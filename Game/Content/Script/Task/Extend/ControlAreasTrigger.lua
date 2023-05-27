-- ========================================================
-- @File    : ControlAreasTrigger.lua
-- @Brief   : 多方占领任务trigger
-- @Author  : 刘东锫
-- @Date    : 2022/4/2
-- ========================================================

local ControlAreasTrigger = Class()

ControlAreasTrigger.IsPlayerIn = false
ControlAreasTrigger.AreaOwner = 0 --1:Player 2:Enemy
ControlAreasTrigger.bIsPlayerInstigateOccupyInfo = false --玩家进入是否触发过左侧占领中的信息提示
ControlAreasTrigger.bIsEnemyInstigateOccupyInfo = false

--显示UI场景特效
function ControlAreasTrigger:DoActive(index, guardUIParent)
	self:SetActive(true);
	self:OnPlay();
	self.DeathHook =
        EventSystem.On(
        Event.CharacterDeath,
        function(InMonster)
            if InMonster then
                --延迟执行  防止立即注册立即调用
                local UpdateUITimerHandle =
                    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {
                        self,
                        function()
                            self:OnDeath(InMonster)
                        end
                    },
                    0.01,
                    false
                )
            end
        end
    )
    TaskCommon.AddHandle(self.DeathHook)

    self.MonstersInTri = {}
    self.TbControlTime = {0,0}
    self:AddTimer()
    self.index = index
	self.guardOccupyItemHolder = nil
	self.guardOccupyItem = nil
    self:SetGuardUIParent(nil, nil)
    self.HasSetName = false;
    self:CheckUI()

    local pc = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    if pc then
		local AllCharacter = pc:GetPlayerCharacters()
        for i = 1, AllCharacter:Length() do
			local cc = AllCharacter:Get(i)
            if cc:IsAlive() then
                self.localPlayer = cc
            end
        end
	end

	self.ControlBackSpeed = self.NeedTimeToControl/((self.ControlBackTime and self.ControlBackTime > 0) and self.ControlBackTime or 1) + 0.00001
end

function ControlAreasTrigger:SetGuardUIParent(guardOccupyHolder, guardFight)
	if guardOccupyHolder and not self.guardOccupyItemHolder then
		print("ControlAreasTrigger:SetGuardUIParent holder:", guardOccupyHolder)
		self.guardOccupyItemHolder = guardOccupyHolder
		self.guardOccupyItem = self.guardOccupyItemHolder:GetAreaUIAt(self.index or 1)--具体是左边1\2\3中的一个盾
	end
	if guardFight and not self.guardOccupyingPrompt then
		self.guardOccupyingPrompt = guardFight--屏幕中间的进入区域提示 多个区域共用一个
		self.guardOccupyingPrompt.TxtName:SetText(self.index)
		self.guardOccupyingPrompt.bIsCenterPrompt = true
	end
end

function ControlAreasTrigger:CheckUI()
	if not self.guardOccupyItem and self.guardOccupyItemHolder then
		self.guardOccupyItem = self.guardOccupyItemHolder:GetAreaUIAt(self.index or 1)
		--print("ControlAreasTrigger:CheckUI init:", self.index)
	end
	if not self.UIItem and not self.IsPlayerIn then
		--显示交互图标
	    local FightUMG = UI.GetUI("Fight")
	    if FightUMG and FightUMG.uw_fight_monster_tips then
	        self.UIItem = FightUMG.uw_fight_monster_tips:CreateItem(self, UE4.EFightMonsterTipsType.DefendArea, "GuideUIPos")

	        WidgetUtils.Collapsed(self.UIItem.ImgDefeat)
	        WidgetUtils.Collapsed(self.UIItem.ImgFight)
			WidgetUtils.SelfHitTestInvisible(self.UIItem.ImgBarWhite)
			WidgetUtils.Collapsed(self.UIItem.ImgBarRed)
			WidgetUtils.Collapsed(self.UIItem.ImgBarBlue)

	        self:SetPercent(self.UIItem.BarBlue, 0)
	        self:SetPercent(self.UIItem.BarRed, 0)
	    end
	end

	if not self.HasSetName and self.UIItem then
		WidgetUtils.SelfHitTestInvisible(self.UIItem.TxtGuardName)
		self.UIItem.TxtGuardName:SetText(self.index)
		--print("ControlAreasTrigger:CheckUI Set UIItem Text:", self.index)
		self.HasSetName = true
	end
end

function ControlAreasTrigger:SetPercent(Bar,Value)
	if Bar.SetPercent then
        Bar:SetPercent(Value)
    else
        local Mat = Bar:GetDynamicMaterial()
        if Mat then
            Mat:SetScalarParameterValue("Percent", Value)
        end
    end
end

function ControlAreasTrigger:OnDeath(InMonster)
	if not InMonster then
		return
	end
	if self:GetEnemyCount() == 0  then
		self.bIsEnemyInstigateOccupyInfo = false
	end
	local uId = InMonster:GetName();
	if uId then
		self.MonstersInTri[uId] = nil;
		self:CheckChangeAreaColorOnRemove();
	end
end

function ControlAreasTrigger:Disable()
	self:SetActive(false);
	self:ClearTimerHandle()
	EventSystem.Remove(self.DeathHook);
	if self.UIItem then
        self.UIItem:Reset()
        self.UIItem = nil
    end
end

function ControlAreasTrigger:OnTrigger(IsEnter, Actor)
	if IsEnter then
		if self:IsLocalPlayer(Actor) then--玩家进
			self.IsPlayerIn = true;
			if self.guardOccupyingPrompt then
				self.guardOccupyingPrompt:SetVisibility(self.IsPlayerIn and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
				self.guardOccupyingPrompt.TxtName:SetText(self.index)
				self:OnTeamNumChange()
			end
			if self.UIItem then
				self.UIItem:Reset()
				self.UIItem = nil
				--self.UIItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
			end
		elseif self:IsMonster(Actor) then--怪物进
			local gameCharacter = Actor:Cast(UE4.AGameCharacter)
			local uId = gameCharacter and gameCharacter:GetName();
			if uId then
				self.MonstersInTri[uId] = true
				self:CheckChangeAreaColorOnAdd()
				self:OnTeamNumChange()
			end
		end
	else
		if self:IsLocalPlayer(Actor) then--玩家出
			self.IsPlayerIn = false
			self.bIsPlayerInstigateOccupyInfo = false
			if self.guardOccupyingPrompt then
				self.guardOccupyingPrompt:SetVisibility(self.IsPlayerIn and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
			end
			if not self.UIItem then
				--显示交互图标
			    local FightUMG = UI.GetUI("Fight")
			    if FightUMG and FightUMG.uw_fight_monster_tips then
			        self.UIItem = FightUMG.uw_fight_monster_tips:CreateItem(self,UE4.EFightMonsterTipsType.DefendArea,"GuideUIPos")
			        WidgetUtils.Collapsed(self.UIItem.ImgDefeat)
					WidgetUtils.Collapsed(self.UIItem.ImgFight)
                    --根据当前据点状态，恢复万向轮指示
                    if self.AreaOwner == 1 then
                        WidgetUtils.Collapsed(self.UIItem.ImgBarWhite)
                        WidgetUtils.Collapsed(self.UIItem.ImgBarRed)
                        WidgetUtils.SelfHitTestInvisible(self.UIItem.ImgBarBlue)
                    elseif self.AreaOwner == 2 then
                        WidgetUtils.Collapsed(self.UIItem.ImgBarWhite)
                        WidgetUtils.Collapsed(self.UIItem.ImgBarBlue)
                        WidgetUtils.SelfHitTestInvisible(self.UIItem.ImgBarRed)
                    elseif self.AreaOwner == 0 then
                        WidgetUtils.Collapsed(self.UIItem.ImgBarRed)
                        WidgetUtils.Collapsed(self.UIItem.ImgBarBlue)
                        WidgetUtils.SelfHitTestInvisible(self.UIItem.ImgBarWhite)
                    end
					WidgetUtils.SelfHitTestInvisible(self.UIItem.TxtGuardName)
					self.UIItem.TxtGuardName:SetText(self.index)
			        self:OnTeamNumChange()
			    end
			end
		elseif self:IsMonster(Actor) then--怪物出

			local gameCharacter = Actor:Cast(UE4.AGameCharacter)
			local uId = gameCharacter and gameCharacter:GetName();
			if uId then
				self.MonstersInTri[uId] = nil;
                if self:GetEnemyCount() == 0  then
                    self.bIsEnemyInstigateOccupyInfo = false
                end
				self:CheckChangeAreaColorOnRemove()
				self:OnTeamNumChange()
			end
		end
	end
end

function ControlAreasTrigger:IsLocalPlayer(OtherActor)
    if IsPlayer(OtherActor) and OtherActor:GetController() and OtherActor:GetController():IsLocalController() then
        return true
    end
    return false
end

function ControlAreasTrigger:IsMonster(OtherActor)
	local gameCharacter = OtherActor:Cast(UE4.AGameCharacter)
	if gameCharacter and not gameCharacter:IsPlayer() and gameCharacter:IsAI() and gameCharacter:IsAlive() then
		if IsValid(self.localPlayer) then
			local rel = UE4.UAbilityFunctionLibrary.GetRelation(gameCharacter,self.localPlayer)
			if rel == UE4.ECampRelation.UnFriendly or rel == UE4.ECampRelation.Enermy then
				return true
			end
	    end
	end
	return false;
end

--获取区域内敌人数量
function ControlAreasTrigger:GetEnemyCount( ... )
	local count = 0
	for k,v in pairs(self.MonstersInTri or {}) do
		count = count + 1
	end
	return count
end

--处理进度
function ControlAreasTrigger:DealAreaNum(deltaTime)
	self:CheckUI()
	local enemyCount = self:GetEnemyCount()
	local isPlayerOccupying = self.IsPlayerIn and (enemyCount == 0)
	local isEnemyOccupying = not self.IsPlayerIn and (enemyCount > 0)
    local isContesting = self.IsPlayerIn and (enemyCount > 0)
	if isPlayerOccupying then self:AddTeamNumForArea(true, false, deltaTime) end
	if isEnemyOccupying then self:AddTeamNumForArea(false, true, deltaTime) end
	if not isPlayerOccupying and not isEnemyOccupying and not isContesting then
		self:AddTeamNumForArea(false, false, deltaTime)
	end
end

function ControlAreasTrigger:AddTeamNumForArea(isPlayerOccupying, isEnemyOccupying, deltaTime)
	if isPlayerOccupying then
		if self.TbControlTime[2] > 0 then
			self.TbControlTime[2] = self.TbControlTime[2] - self.ControlBackSpeed * deltaTime
			if self.TbControlTime[2] <= 0 and self.AreaOwner == 2 then
				self:TeamCancelOccupying(2)
			end
		else
			self.TbControlTime[1] = math.min(self.TbControlTime[1] + deltaTime, self.NeedTimeToControl)
		end
		if self.TbControlTime[1] >= self.NeedTimeToControl then
			self:TeamCompleteOccupy(1)
		end
		if self.OccupyEffectId ~= 1 then
			self:SetOccupyEffect(1)
		end
	elseif isEnemyOccupying then
		if self.TbControlTime[1] > 0 then
			self.TbControlTime[1] = self.TbControlTime[1] - self.ControlBackSpeed * deltaTime
			if self.TbControlTime[1] <= 0 and self.AreaOwner == 1 then
				self:TeamCancelOccupying(1)
			end
		else
			self.TbControlTime[2] = math.min(self.TbControlTime[2] + deltaTime, self.NeedTimeToControl)
		end
		if self.TbControlTime[2] >= self.NeedTimeToControl then
			self:TeamCompleteOccupy(2)
		end

		if self.OccupyEffectId ~= 2 then
			self:SetOccupyEffect(2)
		end
	end
    if self.TbControlTime[1] < 0 then
        self.TbControlTime[1] = 0
    end
    if self.TbControlTime[2] < 0 then
        self.TbControlTime[2] = 0
    end
    if isPlayerOccupying and self.TbControlTime[1] > 0 and not self.bIsPlayerInstigateOccupyInfo and self.AreaOwner ~= 1 then -- 只触发一次Add
        self.guardOccupyItemHolder:UpdateOccupyInfoItem(self.index, false, 3)--清理掉之前的占领中
        self.guardOccupyItemHolder:UpdateOccupyInfoItem(self.index, true, 1) --triggerid, isplayer, state
        self.bIsPlayerInstigateOccupyInfo = true
        --self:SetOccupyEffect(1)
    elseif isEnemyOccupying and self.TbControlTime[2] > 0 and not self.bIsEnemyInstigateOccupyInfo and self.AreaOwner ~= 2 then
        self.guardOccupyItemHolder:UpdateOccupyInfoItem(self.index, false, 3)--清理掉之前的占领中
        self.guardOccupyItemHolder:UpdateOccupyInfoItem(self.index, false, 1)
        self.bIsEnemyInstigateOccupyInfo = true
        --self:SetOccupyEffect(2)d
    elseif (not isPlayerOccupying and not isEnemyOccupying) and (self.TbControlTime[1] > 0 or self.TbControlTime[2] > 0) then
        self.guardOccupyItemHolder:UpdateOccupyInfoItem(self.index, false, 3)
    end
	self:OnTeamNumChange()
end

function ControlAreasTrigger:TeamCompleteOccupy(teamid)--阵营完成了占领,但是还需要占领一段时间
	if self.AreaOwner == teamid then
		return
	end
	self.AreaOwner = teamid
	--self.TbControlTime[1] = 0
	--self.TbControlTime[2] = 0
	self.TbControlTime[teamid] = self.NeedTimeToControl;
	if self.OnTeamControlChanged then
		self:OnTeamControlChanged(teamid)
	end
	if self.guardOccupyItem then
		print("ControlAreasTrigger:TeamCompleteOccupy left ", teamid)
		self.guardOccupyItem:OnTeamControlChanged(teamid)
	end
	if self.guardOccupyingPrompt then
		print("ControlAreasTrigger:TeamCompleteOccupy center", teamid)
		self.guardOccupyingPrompt:OnTeamControlChanged(teamid)
	end

	if self.guardOccupyItemHolder then
		-- print("ControlAreasTrigger:TeamCompleteOccupy-Remove info:", self.index, 1)
		self.guardOccupyItemHolder:RemoveOccupyInfo(self.index, teamid == 1, 1)
		self.guardOccupyItemHolder:UpdateOccupyInfoItem(self.index, teamid == 1, 2)
	end

	if self.UIItem then
		if teamid == 1 then
			WidgetUtils.Collapsed(self.UIItem.ImgBarWhite)
			WidgetUtils.Collapsed(self.UIItem.ImgBarRed)
			WidgetUtils.SelfHitTestInvisible(self.UIItem.ImgBarBlue)
		elseif teamid == 2 then
			WidgetUtils.Collapsed(self.UIItem.ImgBarWhite)
			WidgetUtils.SelfHitTestInvisible(self.UIItem.ImgBarRed)
			WidgetUtils.Collapsed(self.UIItem.ImgBarBlue)
		end
	end

	self:UpdateOwnerEffect(teamid)

end

function ControlAreasTrigger:TeamCancelOccupying(teamid)
	self.AreaOwner = 0;
	self.TbControlTime[teamid] = 0
	if self.OnTeamControlChanged then
		self:OnTeamControlChanged(0)
	end
	if self.guardOccupyItem then
		self.guardOccupyItem:OnTeamControlChanged(0)
	end
	if self.guardOccupyingPrompt then
		self.guardOccupyingPrompt:OnTeamControlChanged(0)
	end
	self:UpdateOwnerEffect(0)
end

--区域内怪物数量增加时检查
function ControlAreasTrigger:CheckChangeAreaColorOnAdd()
	if self:GetEnemyCount() == 1 then
		self:OnEnemyEntry()
	end
end
--区域内怪物数量减少时检查
function ControlAreasTrigger:CheckChangeAreaColorOnRemove()
	if self:GetEnemyCount() == 0 then
		self:OnEnemyClear()
	end
end

function ControlAreasTrigger:AddTimer()
    self.TimerHandle =
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
				self:DealAreaNum(0.1)
            end
        },
        0.1,
        true
    )
end

function ControlAreasTrigger:ClearTimerHandle()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.TimerHandle)
end

function ControlAreasTrigger:OnTeamNumChange()
	if self.guardOccupyItem and self.guardOccupyItem.UpdateProgressBar then
		self.guardOccupyItem:UpdateProgressBar(self.TbControlTime, self.NeedTimeToControl)
		-- print("OnTeamNumChange Occupy Item update!")
	end

	if self.guardOccupyingPrompt and self.IsPlayerIn and self.guardOccupyItem and self.guardOccupyItem:IsVisible() then
		self.guardOccupyingPrompt:UpdateProgressBar(self.TbControlTime, self.NeedTimeToControl)
		-- print("OnTeamNumChange Occupy Prompt update!")
	end

	if self.guardOccupyItemHolder then
		local bIsPlayer = self.IsPlayerIn
		-- print("OnTeamNumChange Occupy Info Item update:", self.index, self.TbControlTime, self.NeedTimeToControl, bIsPlayer)
		self.guardOccupyItemHolder:UpdateOccupyInfoProgressbar(self.index, self.TbControlTime, self.NeedTimeToControl, bIsPlayer)
	end

	--界面上的Trigger 空间指示器 更新
	local bluePercent = self.TbControlTime[1] / ((self.NeedTimeToControl and self.NeedTimeToControl > 0) and self.NeedTimeToControl or 100)
	local redPercent = self.TbControlTime[2] / ((self.NeedTimeToControl and self.NeedTimeToControl > 0) and self.NeedTimeToControl or 100)

	--更新占领特效进度
	local enemyCount = self:GetEnemyCount()
	local isPlayerOccupying = self.IsPlayerIn and (enemyCount == 0)
	local isEnemyOccupying = not self.IsPlayerIn and (enemyCount > 0)

	if isPlayerOccupying and self.TbControlTime[2] <= 0 then
		self:UpdateOccupyEffect(bluePercent)
	elseif isEnemyOccupying and self.TbControlTime[1] > 0 then
		self:UpdateOccupyEffect(bluePercent)
	elseif isEnemyOccupying and self.TbControlTime[1] <= 0 then
		self:UpdateOccupyEffect(redPercent)
	elseif isPlayerOccupying and self.TbControlTime[2] > 0 then
		self:UpdateOccupyEffect(redPercent)
	end

	--更新UI
	if self.UIItem then
		--self.UIItem.BarBlue:SetPercent(bluePercent)
	    --self.UIItem.BarRed:SetPercent(redPercent)
	    self:SetPercent(self.UIItem.BarBlue,bluePercent)
	    self:SetPercent(self.UIItem.BarRed,redPercent)
	end
end

return ControlAreasTrigger
