--Occupy 盾牌提示器的预制体

local tbClass = Class('UMG.SubWidget')
tbClass.bIsCenterPrompt = false
function tbClass:Construct()
	local BarBlueSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.BarBlue)
	self.BarSize = BarBlueSlot:GetSize().Y
	-- print("Occupy Prompt Indicator:BarSize", self.BarSize)
	self.BarIndicator = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ImgGrowUp)
	-- print("Occupy Prompt Indicator:", self.BarIndicator)
	self.CurProgressValue = 0
	self.TriggerIndex = 0
	WidgetUtils.Collapsed(self.ImgOverBlue)
	WidgetUtils.Collapsed(self.ImgOverRed)
	WidgetUtils.Collapsed(self.Txt1)
	WidgetUtils.SelfHitTestInvisible(self.Image_102)
end

function tbClass:OnDestruct()
	print("Occupy Prompt Destruct")
end

function tbClass:OnListItemObjectSet(obj)
	self.BarRed:SetPercent(0)
	self.BarBlue:SetPercent(0)
	if obj and obj.Data then
		self:ShowName(obj.Data.name)
		self.TriggerIndex = obj.Data.TriggerIndex
	end
end

function tbClass:ShowName(key)
	self.TxtName:SetText(key)
end

function tbClass:OnTeamControlChanged(teamid)
	-- if not self.TbColor then
	-- 	self.TbColor = {
	-- 		[0] = {['R'] = 1.0,['G'] = 1.0,['B'] = 1.0,['A'] = 1.0},
	-- 		[1] = {['R'] = 0.0,['G'] = 0.0,['B'] = 1.0,['A'] = 1.0},
	-- 		[2] = {['R'] = 1.0,['G'] = 0.0,['B'] = 0.0,['A'] = 1.0},
	-- 	}
	-- end
	print("Occupy Prompt Indicator:占领成功 ", teamid)
	if teamid ~= 0 and teamid == 1 then
		if self.bIsCenterPrompt then
			WidgetUtils.SelfHitTestInvisible(self.Txt1)
			self.Txt1:SetText(Text("ui.TXTOccupyOverOur"))
			print("Occupy Prompt Indicator:玩家占领成功 Text")
			self.bIsCenterPrompt = false
			local LocalTimeHanlder =
				UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
					{
						self,
						function()
							WidgetUtils.Collapsed(self.Txt1)
						end
					},
					4.9,
					false
				)
		end
		self:PlayAnimation(self.OverBlue)--玩家占领成功
		print("Occupy Prompt Indicator:玩家占领成功 Animation")
		WidgetUtils.Collapsed(self.Image_102)
		WidgetUtils.Collapsed(self.ImgOverRed)
		WidgetUtils.Collapsed(self.BarRed)
		WidgetUtils.Collapsed(self.BarBlue)
		WidgetUtils.SelfHitTestInvisible(self.ImgOverBlue)
	elseif teamid ~= 0 and teamid == 2 then
		self:PlayAnimation(self.OverRed)
		print("Occupy Prompt Indicator:敌人占领成功 Animation")
		WidgetUtils.Collapsed(self.Image_102)
		WidgetUtils.Collapsed(self.ImgOverBlue)
		WidgetUtils.Collapsed(self.BarRed)
		WidgetUtils.Collapsed(self.BarBlue)
		WidgetUtils.SelfHitTestInvisible(self.ImgOverRed)
	elseif teamid == 0 then
		WidgetUtils.Collapsed(self.ImgOverBlue)
		WidgetUtils.Collapsed(self.ImgOverRed)
		if self.bIsCenterPrompt then
			WidgetUtils.Collapsed(self.Txt1)
		end
		WidgetUtils.SelfHitTestInvisible(self.BarRed)
		WidgetUtils.SelfHitTestInvisible(self.BarBlue)
		WidgetUtils.SelfHitTestInvisible(self.Image_102)
	end
	-- self.TxtName:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(self.TbColor[teamid].R, self.TbColor[teamid].G, self.TbColor[teamid].B, self.TbColor[teamid].A))
end

function tbClass:UpdateProgressBar(tb, NeedTimeToControl)--TODO-ZGY need optimize code
	if not tb then return end
	if tb[1] > 0  and tb[1] <= NeedTimeToControl then
		local Value = tb[1] / ((NeedTimeToControl and NeedTimeToControl > 0) and NeedTimeToControl or 100)
		-- print("occupy list Blue UpdateProgressBar-",self, tb[1], NeedTimeToControl, Value)
		if self.CurProgressValue ~= Value then -- 值设置以后不重复设置
			-- print("Occupy Prompt Indicator SetPercent Blue:", self, Value)
			if self.CurProgressValue > Value then --下降时的处理
				WidgetUtils.SelfHitTestInvisible(self.BarBlue)
				WidgetUtils.Collapsed(self.ImgOverBlue)
			end
			self.CurProgressValue = Value
			self.BarBlue:SetPercent(Value)
			self:SetBarIndicatorPos(Value)
			self:PlayAnimation(self.GrowUpBlue)
			if self.bIsCenterPrompt then
				WidgetUtils.SelfHitTestInvisible(self.Txt1)
				self.Txt1:SetText(Text("ui.TxtOccupyOur"))
			end
		end
	else
		-- print("Occupy Prompt Indicator SetPercent Blue Zero:", self)
		self.BarBlue:SetPercent(0)
	end

	if tb[2] > 0 and tb[2] <= NeedTimeToControl then
		local Value = tb[2] / ((NeedTimeToControl and NeedTimeToControl > 0) and NeedTimeToControl or 100)
		-- print("occupy list Red UpdateProgressBar-",self, tb[2], NeedTimeToControl, Value)
		if self.CurProgressValue ~= Value then
			-- print("Occupy Prompt Indicator SetPercent Red:", self, Value)
			if self.CurProgressValue > Value then --下降时的处理
				WidgetUtils.SelfHitTestInvisible(self.BarRed)
				WidgetUtils.Collapsed(self.ImgOverRed)
			end
			self.CurProgressValue = Value
			-- WidgetUtils.Collapsed(self.ImgOverBlue)
			-- WidgetUtils.Collapsed(self.ImgOverRed)
			self.BarRed:SetPercent(Value)
			self:SetBarIndicatorPos(Value)
			self:PlayAnimation(self.GrowUpRed)
			if self.bIsCenterPrompt then
				WidgetUtils.Collapsed(self.Txt1)
			end
		end
	else
		-- print("Occupy Prompt Indicator SetPercent Red Zero:", self)
		self.BarRed:SetPercent(0)
	end
end

function tbClass:SetBarIndicatorPos(Ratio)
	-- local PosYChange = self.BarSize * Ratio--竖直方向增长
	local PosYChange = self.ImgSize.Brush.ImageSize.Y * Ratio
	-- print("SetBarIndicatorPos:", self.ImgOVerRed.Brush.ImageSize.Y)
	-- print("Occupy Prompt Indicator Pos before set:", self.BarIndicator, PosYChange, self.BarIndicator:GetPosition().X, self.BarIndicator:GetPosition().Y + PosYChange)
	local MakePos = UE4.FVector2D()
    MakePos.X = self.BarIndicator:GetPosition().X
    MakePos.Y = -1 * PosYChange
	self.BarIndicator:SetPosition(MakePos)
	--print("Occupy Prompt Indicator Pos after set:", self.BarIndicator:GetPosition())
end

return tbClass