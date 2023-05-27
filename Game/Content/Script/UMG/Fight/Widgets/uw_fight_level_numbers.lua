--==============================================
--联机显示代币控件
--==============================================

local OnlineLevelNumber = Class("UMG.SubWidget")

local tbClass = OnlineLevelNumber

function tbClass:Construct()
	
end

function tbClass:SetMoneyIconId(Id)
	SetTexture(self.ImgMoney,Id)
end

--显示代币
function tbClass:ShowMoney(num,showBtn)
	WidgetUtils.Collapsed(self.TxtOnlineNumbers)
	WidgetUtils.SelfHitTestInvisible(self.ImgMoney)
	local nowMoney = self.TxtOnlineNum:GetText()
	if tonumber(nowMoney) and tonumber(nowMoney) < num then
        self.TxtOnlineNum_1:SetText(num - tonumber(nowMoney))
		if self.IsVisible and self:IsVisible() then
			self:PlayAnimation(self.GetMoney)
		end
	end
	self.TxtOnlineNum:SetText(num)
	if showBtn then
		WidgetUtils.Visible(self.BtnCheck)
		BtnRemoveEvent(self.BtnCheck)
		BtnAddEvent(self.BtnCheck,function ()
			if not UI.IsOpen('ItemInfo') then
				UI.Open('ItemInfo',5,18,1,1,num)
			end
		end)
	end
	self.ImgPanel:SetVisibility(showBtn and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
--显示积分
function tbClass:ShowPoint(num)
	WidgetUtils.Collapsed(self.ImgMoney)
	WidgetUtils.SelfHitTestInvisible(self.TxtOnlineNumbers)
	local nowPoint = self.TxtOnlineNum:GetText()
	if tonumber(nowPoint) and tonumber(nowPoint) < num then
        self.TxtOnlineNum_1:SetText(num - tonumber(nowPoint))
        if self.IsVisible and self:IsVisible() then
			self:PlayAnimation(self.GetMoney)
		end
	end
	self.TxtOnlineNum:SetText(num)
	WidgetUtils.Collapsed(self.BtnCheck)
	BtnRemoveEvent(self.BtnCheck)
	WidgetUtils.Collapsed(self.ImgPanel)
end

return OnlineLevelNumber
