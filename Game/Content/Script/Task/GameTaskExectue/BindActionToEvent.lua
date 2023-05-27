local tbClass = Class()


function tbClass:OnActive_Client()
	if self.TargetUI == 'Defend_Level_Guard' then
		local FightUMG = UI.GetUI("Fight")
        if FightUMG and FightUMG.LevelGuard then
            FightUMG.LevelGuard:SetGuardType(2)
            local TaskActor = self:GetGameTaskActor()
        	if IsValid(TaskActor) and IsValid(TaskActor.TaskDataComponent) then
        		local AddNum = TaskActor.TaskDataComponent:GetOrAddValue('WaveLeftTime')
	            local time = math.max(AddNum, 0)
	    		local str = os.date("%M:%S", time)
	            FightUMG.LevelGuard:UpdateText(str)
	            FightUMG.LevelGuard:ShowDefendTimeWithAnim()
	        end
        end
	end
end

function tbClass:OnUpdate_Client(InNowValue)
	self.NowValue = InNowValue;
	self:SetExecuteDescription();
	self:OnUpdateUI(InNowValue)
end

function tbClass:GetDescription()
	if self.EndByData then
		return string.format(self:GetUIDescription(),self.NowValue..'/'..self.TargetValue)
	else
		return self:GetUIDescription();
	end
end

function tbClass:OnEnd_Client()
	if self.TargetUI == 'Defend_Level_Guard' then
		local FightUMG = UI.GetUI("Fight")
        if FightUMG and FightUMG.LevelGuard then
        	local TaskActor = self:GetGameTaskActor()
        	if IsValid(TaskActor) and IsValid(TaskActor.TaskDataComponent) then
        		local AddNum = TaskActor.TaskDataComponent:GetOrAddValue('WaveLeftTime')
        		if AddNum > 0 then
        			UE4.Timer.Add(2.8,function ()
        				local FightUMG = UI.GetUI("Fight")
        				if FightUMG and FightUMG.LevelGuard then
        					FightUMG.LevelGuard:ShowDefendMoneyEffect(AddNum)
        				end
        			end)
        		else
        			FightUMG.LevelGuard:Show(false)
        		end
        	else
        		FightUMG.LevelGuard:Show(false)
        	end
        end
	end
end

function tbClass:OnUpdateUI(InNowValue)
	if self.TargetUI == 'Defend_Level_Guard' then
		local FightUMG = UI.GetUI("Fight")
        if FightUMG and FightUMG.LevelGuard then
        	local time = math.max(InNowValue, 0)
    		local str = os.date("%M:%S", time)
            FightUMG.LevelGuard:UpdateText(str)
        end
	end
end

return tbClass;