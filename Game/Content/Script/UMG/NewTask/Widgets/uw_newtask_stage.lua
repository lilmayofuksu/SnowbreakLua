local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
	local tbParam = pObj and pObj.Data
	if not tbParam then
		return
	end

	WidgetUtils.Collapsed(self.PopAward)
	self.TxtPt:SetText(tbParam.needPoint or 1)
	BtnClearEvent(self.BtnBox)
	local gotState = tbParam.gotState--0未领取1领取
	if tbParam.maxIndex > tbParam.index then
		WidgetUtils.Hidden(self.PanelBigBox)
		if gotState == 1 then--已领取
			WidgetUtils.SelfHitTestInvisible(self.PanelOver)
			WidgetUtils.Hidden(self.PanelReward)
			WidgetUtils.Hidden(self.PanelUnFinish)
			BtnAddEvent(self.BtnBox,function ( ... )
				tbParam.preViewFunc()
			end)
		else
			if tbParam.needPoint <= tbParam.nowPoint then--可以领取
				WidgetUtils.Hidden(self.PanelOver)
				WidgetUtils.SelfHitTestInvisible(self.PanelReward)
				WidgetUtils.Hidden(self.PanelUnFinish)
				--UE4.Timer.Add(0.2,function ( ... )
					self:PlayAnimation(self.AllLoop,0,0)
				--end)
				BtnAddEvent(self.BtnBox,function ()
					tbParam.getAwardFunc()
				end)
			else--不可领取
				WidgetUtils.Hidden(self.PanelOver)
				WidgetUtils.Hidden(self.PanelReward)
				WidgetUtils.SelfHitTestInvisible(self.PanelUnFinish)
				BtnAddEvent(self.BtnBox,function ( ... )
					tbParam.preViewFunc()
				end)
			end
		end
	else
		WidgetUtils.Hidden(self.PanelOver)
		WidgetUtils.Hidden(self.PanelReward)
		WidgetUtils.Hidden(self.PanelUnFinish)

		WidgetUtils.Collapsed(self.ImgBox3)
		WidgetUtils.Collapsed(self.ImgMask_1)
		WidgetUtils.Collapsed(self.ImgOver_1)
		WidgetUtils.Collapsed(self.ImgBox_1)
		WidgetUtils.Collapsed(self.Image_1)
		WidgetUtils.Collapsed(self.ImgFrameSmall2_1)
		WidgetUtils.Collapsed(self.ImgFrameBig_1)
		WidgetUtils.Collapsed(self.ImgFrameSmall_1)
		WidgetUtils.Collapsed(self.Image_6)
		WidgetUtils.SelfHitTestInvisible(self.PanelBigBox)
		if gotState == 1 then--已领取
			WidgetUtils.Visible(self.ImgBox3)
			WidgetUtils.Visible(self.ImgMask_1)
			WidgetUtils.Visible(self.ImgOver_1)
			WidgetUtils.Visible(self.Image_6)
			BtnAddEvent(self.BtnBox,function ( ... )
				tbParam.preViewFunc()
			end)
		else
			if tbParam.needPoint <= tbParam.nowPoint then--可以领取
				WidgetUtils.Visible(self.ImgBox3)
				WidgetUtils.Visible(self.ImgFrameBig_1)
				WidgetUtils.Visible(self.ImgFrameSmall_1)
				WidgetUtils.Visible(self.Image_6)
				self:PlayAnimation(self.AllLoop,0,0)
				BtnAddEvent(self.BtnBox,function ()
					tbParam.getAwardFunc()
				end)
			else--不可领取
				WidgetUtils.Visible(self.ImgBox_1)
				WidgetUtils.Visible(self.ImgFrameSmall2_1)
				WidgetUtils.Visible(self.Image_1)
				BtnAddEvent(self.BtnBox,function ( ... )
					tbParam.preViewFunc()
				end)
			end
		end
	end

	self:ShowPop(tbParam.tbPopConfig, tbParam.needPoint)
end

--显示POP
function tbClass:ShowPop(tbShowConfig, nPoint)
	if not tbShowConfig then return end

	if not self.PopPanel then
		self.PopPanel = WidgetUtils.AddChildToPanel(self.PopAward, '/Game/UI/UMG/Achievement/Widgets/uw_achievement_pop.uw_achievement_pop_C', 1)
	end

	if not self.PopPanel then
		return
	end

	if not self.tbSavePosition and nPoint == 100 then
		local tbSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.PopAward)
		local tbPosition = tbSlot:GetPosition()
		tbPosition.X = tbPosition.X - 100
		tbPosition.Y = tbPosition.Y - 30
		tbSlot:SetPosition(tbPosition)
		self.tbSavePosition = tbPosition
	elseif self.tbSavePosition then
		local tbSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.PopAward)
		tbSlot:SetPosition(self.tbSavePosition)
	end

	WidgetUtils.SelfHitTestInvisible(self.PopAward)
	WidgetUtils.SelfHitTestInvisible(self.PopPanel)

    self.PopPanel:OnOpen(tbShowConfig)
end

return tbClass;