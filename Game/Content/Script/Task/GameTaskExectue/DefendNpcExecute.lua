---守护NPC

local DefendNpc = Class()

function DefendNpc:OnActive( ... )
	self.DefendTargets = self:FindDefendNpcs()
    self.HasSetNpcName = nil
    if self.DefendTargets:Length() >= 1 then
    	self.DefendNpc = self.DefendTargets:Get(1)
	    self.DefendNpc.Ability.OnCharacterDie:Add(
	        self,
	       	self.Fail
	    )

	    self.DefendNpc.Ability.OnReceiveDamage:Add(
	    	self,
	    	self.UpdateNpcBar
	    )

	    self.DefendNpc.Ability.OnReceiveHeal:Add(
	    	self,
	    	self.UpdateNpcBar
	    )
	    self:UpdateNpcBar()
	end
end

function DefendNpc:OnActive_Client()
	self:SetExecuteDescription()
	self.LeftTime = self.DefendTime
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.NpcBar then
        self.NpcBar = FightUMG.NpcBar
        WidgetUtils.SelfHitTestInvisible(self.NpcBar)
        self:UpdateNpcBar()
    end
end

function DefendNpc:UpdateNpcBar()
	if self.NpcBar and self.DefendNpc then
    	if not self.HasSetNpcName then
    		self.NpcBar.TxtName:SetText(Text("chapter.defend"))
    		self.HasSetNpcName = true;
    	end
		local CurrentHp = self.DefendNpc.Ability:GetRolePropertieValue(UE4.EAttributeType.Health)
		local MaxHp = self.DefendNpc.Ability:GetRolePropertieMaxValue(UE4.EAttributeType.Health)
		if MaxHp > 0 then
			local Percent = math.ceil(CurrentHp * 100/MaxHp)
			self.NpcBar.TxtNum:SetText(tostring(Percent)..'%')
			self.NpcBar.BarNum:SetPercent(Percent / 100)
		end
	end
end

function DefendNpc:OnFail()
    self:Clear()
end

function DefendNpc:OnFail_Client()
    self:Clear()
end

function DefendNpc:OnFinish()
    self:Clear()
end

function DefendNpc:OnFinish_Client()
    self:Clear()
end

function DefendNpc:Clear()
	WidgetUtils.Collapsed(self.NpcBar)
	self.NpcBar = nil
    self.DefendTargets = nil;
    if self.DefendNpc then
    	self.DefendNpc.Ability.OnReceiveDamage:Remove(self,self.UpdateNpcBar)
    	self.DefendNpc.Ability.OnReceiveHeal:Remove(self,self.UpdateNpcBar)
    end
end

return DefendNpc;