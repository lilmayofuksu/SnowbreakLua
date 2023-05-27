--Occupy中间的进度条
local tbClass = Class('UMG.SubWidget')

function tbClass:Construct()
	local BarBlueSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.BarBlue)
	self.BarSize = BarBlueSlot:GetSize().X
	self.BarIndicator = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ImgBlueUp)
	self:Init(100)
end

function tbClass:Init(MaxValue,NowValue)
	self.MaxValue = MaxValue
	NowValue = NowValue or MaxValue / 2
	self:UpdateTeamNum(NowValue, MaxValue - NowValue, false, true)
	--print("Occupy Progressbar Indicator init:", self.MaxValue)
end

function tbClass:UpdateTeamNum(PlayerScore, EnemyScore, bIsPlayerScoreIncrease, bIsInit)
	PlayerScore = PlayerScore or 0
	EnemyScore = EnemyScore or 0
	MaxValue = self.MaxValue or 100
	-- if self.TxtBlue then
		--print("Occupy Progressbar Indicator UpdateTeamNum:", PlayerScore)
	-- end
	self.TxtBlue:SetText(PlayerScore)--(math.min(100, math.floor(PlayerScore / MaxValue * 100)))
	self.TxtRed:SetText(EnemyScore)--(math.min(100, math.floor(EnemyScore / MaxValue * 100)))

	self.BarBlue:SetPercent(PlayerScore / self.MaxValue)
	self.BarRed:SetPercent(EnemyScore / self.MaxValue)
	self:SetBarIndicatorPos(PlayerScore / self.MaxValue)
	if not bIsInit then
		if bIsPlayerScoreIncrease then
			self:PlayAnimation(self.BlueUp)
			--print("Occupy Progressbar Indicator SetPercent Blue:", PlayerScore / self.MaxValue)
		else
			self:PlayAnimation(self.RedUp)
			--print("Occupy Progressbar Indicator SetPercent Red:", EnemyScore / self.MaxValue)
		end
	end

end

function tbClass:SetBarIndicatorPos(Ratio)
	--local PosXChange = self.BarSize * Ratio * 100
	local PosXChange = self.BarSize * Ratio
	local MakePos = UE4.FVector2D()
    MakePos.X = PosXChange
    MakePos.Y = self.BarIndicator:GetPosition().Y
	self.BarIndicator:SetPosition(MakePos)
	--print("Occupy Progressbar Indicator Pos:", self.BarIndicator:GetPosition())
end

return tbClass