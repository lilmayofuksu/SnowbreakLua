-- ========================================================
-- @File    : EvacuationTrigger.lua
-- @Brief   : 撤退任务trigger
-- @Author  : 刘东锫
-- @Date    : 2022/2/7
-- ========================================================

local EvacuationTrigger = Class()

EvacuationTrigger.IsPlayerIn = false;
EvacuationTrigger.LeftTime = 0;
EvacuationTrigger.IsActive = false;

--显示UI场景特效
function EvacuationTrigger:DoActive(callback,callBegin,evacuateTime)
	self:SetActive(true);
	self.callback = callback;
	self.callBegin = callBegin;
	self.EvacuateTime = evacuateTime
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

    self.MonstersInTri = {};
    self:OnPlay();
    self:AddTimer();
    self:callBegin();
    --显示交互图标
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.uw_fight_monster_tips then
        self.UIItem = FightUMG.uw_fight_monster_tips:CreateItem(self,UE4.EFightMonsterTipsType.Retreat,"GuideUIPos")
    end
    if FightUMG and FightUMG.LevelGuard then
        self.LevelGuardUI = FightUMG.LevelGuard
        self.LevelGuardUI:SetGuardType(2)
    end

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
end


function EvacuationTrigger:OnDeath(InMonster)
	if not InMonster then
		return
	end
	local uId = InMonster:GetName();
	if uId then
		self.MonstersInTri[uId] = nil;
		self:CheckChangeAreaColorOnRemove();
	end
end

function EvacuationTrigger:Disable()
	self.callback = nil;
	self.callPerSec = nil
	self:SetActive(false);
	WidgetUtils.Collapsed(self.LevelGuardUI)
	self.LevelGuardUI = nil;
	if self.OnEnd then
		self:OnEnd();
	end
	EventSystem.Remove(self.DeathHook);
	if self.UIItem then
        self.UIItem:Reset()
    end
end

function EvacuationTrigger:OnTrigger(IsEnter,Actor)
	if IsEnter then
		if self:IsLocalPlayer(Actor) then--玩家进
			self.IsPlayerIn = true;
			if self:CheckCanCalTime() then self:OnTimeChange() end
		elseif self:IsMonster(Actor) then--怪物进
			local gameCharacter = Actor:Cast(UE4.AGameCharacter)
			local uId = gameCharacter and gameCharacter:GetName();
			if uId then
				self.MonstersInTri[uId] = true;
				self:CheckChangeAreaColorOnAdd()
			end
		end
	else
		if self:IsLocalPlayer(Actor) then--玩家出
			self.IsPlayerIn = false;
		elseif self:IsMonster(Actor) then--怪物出
			local gameCharacter = Actor:Cast(UE4.AGameCharacter)
			local uId = gameCharacter and gameCharacter:GetName();
			if uId then
				self.MonstersInTri[uId] = nil;
				self:CheckChangeAreaColorOnRemove()
			end
		end
	end
end

function EvacuationTrigger:IsLocalPlayer(OtherActor)
    if IsPlayer(OtherActor) and OtherActor:GetController() and OtherActor:GetController():IsLocalController() then
        return true
    end
    return false
end

function EvacuationTrigger:IsMonster(OtherActor)
	local gameCharacter = OtherActor:Cast(UE4.AGameCharacter)
	if gameCharacter and not gameCharacter:IsPlayer() and not gameCharacter:IsHostage() then
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
function EvacuationTrigger:GetEnemyCount( ... )
	local count = 0
	for k,v in pairs(self.MonstersInTri or {}) do
		count = count + 1
	end
	return count
end

--检测是否满足倒计时减少条件
function EvacuationTrigger:CheckCanCalTime()
	if not self.IsPlayerIn then
		return false;
	end
	return (self:GetEnemyCount() == 0)
end

--区域内怪物数量增加时检查
function EvacuationTrigger:CheckChangeAreaColorOnAdd()
	if self:GetEnemyCount() == 1 then
		self:OnEnemyEntry()
	end
end
--区域内怪物数量减少时检查
function EvacuationTrigger:CheckChangeAreaColorOnRemove()
	if self:GetEnemyCount() == 0 then
		self:OnEnemyClear()
	end
end

function EvacuationTrigger:AddTimer( ... )
	self.LeftTime = self.EvacuateTime
	self:OnTimeChange();
    self.TimerHandle =
        UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
            	if self.IsPlayerIn then
	                self.LeftTime = self.LeftTime - 1
	                self:OnTimeChange()
	                if self.LeftTime <= 0 then
	                    if self.callback then self.callback(); end;
	                    self:ShowTimer(false);
	                    self:Disable();
	                    return
	                end
	            else
	            	self:TipKeepIn()
	            end
	            self:ShowTimer(true)
            end
        },
        1,
        true
    )
end

function EvacuationTrigger:ClearTimerHandle()
    UE4.UKismetSystemLibrary.K2_ClearTimerHandle(self,self.TimerHandle)
end

function EvacuationTrigger:ResetTimer()
	self:ClearTimerHandle()
	self:AddTimer()
end

function EvacuationTrigger:ContinueTimer()
	self:ClearTimerHandle()
	self:AddTimer()
end

function EvacuationTrigger:OnTimeChange( ... )
	--if self.callPerSec then
		--self.callPerSec()
	--end

	if self.LevelGuardUI and self.LeftTime >= 0 then
		local str = os.date("%M:%S",self.LeftTime)
		--local str = tostring(self.LeftTime);
		self.LevelGuardUI:UpdateText(string.format(Text("taskdes.1000101"), str));
	end
end

function EvacuationTrigger:TipKeepIn()
	if self.LevelGuardUI then
		self.LevelGuardUI:UpdateText(Text("taskdes.1000100"));
	end
end

function EvacuationTrigger:ShowTimer(bShow)
	if self.LevelGuardUI then
		if bShow then
			WidgetUtils.HitTestInvisible(self.LevelGuardUI)
		else
			WidgetUtils.Collapsed(self.LevelGuardUI)
		end
	end
end

return EvacuationTrigger;