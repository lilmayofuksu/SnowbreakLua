--================

--七天乐日期标签

--================
local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
	if not pObj or not pObj.Data then
		return
	end
	local tbParam = pObj.Data;
	self.dayId = tbParam.dayId or 1
	self.actId = tbParam.actId or 5
	self.Txtday:SetText(string.format("%02d",self.dayId))
	self.Txtday1:SetText(string.format("%02d",self.dayId))
	self:UpdateState(tbParam)
	--BtnClearEvent(self)
end

function tbClass:UpdateState(tbParam)
	local slDayId = 1
	local ui = UI.GetUI('NewTask')
	if ui then
		slDayId = ui.dayId
	end
	BtnClearEvent(self.BtnDayUnsl)
	if tbParam.dayId > tbParam.nowUnLockDay then
		WidgetUtils.Hidden(self.BtnDayUnsl)
		WidgetUtils.Hidden(self.PanelSlDay)
		WidgetUtils.Visible(self.BtnLock)
		BtnClearEvent(self.BtnLock)
		BtnAddEvent(self.BtnLock,function ()
			UI.ShowTip(string.format(Text("tip.nextStageUnlockTime"),tbParam.dayId))
		end)
	else
		if slDayId == tbParam.dayId then
			WidgetUtils.Hidden(self.BtnDayUnsl)
			WidgetUtils.Visible(self.PanelSlDay)
			WidgetUtils.Hidden(self.BtnLock)
		else
			WidgetUtils.Visible(self.BtnDayUnsl)
			WidgetUtils.Hidden(self.PanelSlDay)
			WidgetUtils.Hidden(self.BtnLock)
			BtnAddEvent(self.BtnDayUnsl,function ( ... )
				tbParam.onClick();
			end)
		end
	end

	self.New:SetVisibility(SevenDay:CheckHasNewAchieveAward(self.actId,tbParam.dayId) and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)

	local HasUnComplete = SevenDay:CheckHasUnCompletedAchieve(self.actId,tbParam.dayId)
	if not HasUnComplete then
		WidgetUtils.Collapsed(self.Txtday)
		WidgetUtils.Collapsed(self.Txtday1)
		WidgetUtils.SelfHitTestInvisible(self.ImgTaskOK)
		WidgetUtils.SelfHitTestInvisible(self.ImgTaskOK_1)
	else
		WidgetUtils.SelfHitTestInvisible(self.Txtday)
		WidgetUtils.SelfHitTestInvisible(self.Txtday1)
		WidgetUtils.Collapsed(self.ImgTaskOK)
		WidgetUtils.Collapsed(self.ImgTaskOK_1)
	end
end

return tbClass