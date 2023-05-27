local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
	local tbParam = pObj and pObj.Data
	if not tbParam then
		return
	end

	self.Item:Display({G = tbParam.itemAward[1],D = tbParam.itemAward[2],P = tbParam.itemAward[3],L = tbParam.itemAward[4],N = tbParam.itemAward[5]})
	self.ItemBig:Display({G = tbParam.itemAward[1],D = tbParam.itemAward[2],P = tbParam.itemAward[3],L = tbParam.itemAward[4],N = tbParam.itemAward[5]})

	self.TxtPt:SetText(tbParam.needPoint or 1)
	BtnClearEvent(self.BtnBox)
	WidgetUtils.Collapsed(self.Image_2)
	local gotState = tbParam.gotState--0未领取1领取
	if tbParam.maxIndex > tbParam.index then
		WidgetUtils.Hidden(self.BigBox)
		WidgetUtils.SelfHitTestInvisible(self.PanelBox)
		if gotState == 1 then--已领取
			WidgetUtils.SelfHitTestInvisible(self.PanelOver)
			WidgetUtils.Hidden(self.PanelCurrent)
			WidgetUtils.Hidden(self.PanelUnFinish)
			BtnAddEvent(self.BtnBox,function ( ... )
				self.Item:DefaultClick()
			end)
		else
			if tbParam.needPoint <= tbParam.nowPoint then--可以领取
				WidgetUtils.Hidden(self.PanelOver)
				WidgetUtils.SelfHitTestInvisible(self.PanelCurrent)
				WidgetUtils.Hidden(self.PanelUnFinish)
				WidgetUtils.Visible(self.Image_2)
				--UE4.Timer.Add(0.2,function ( ... )
					self:PlayAnimation(self.AllLoop,0,0)
				--end)
				BtnAddEvent(self.BtnBox,function ()
					tbParam.getAwardFunc()
				end)
			else--不可领取
				WidgetUtils.Hidden(self.PanelOver)
				WidgetUtils.Hidden(self.PanelCurrent)
				WidgetUtils.SelfHitTestInvisible(self.PanelUnFinish)
				BtnAddEvent(self.BtnBox,function ()
					self.Item:DefaultClick()
				end)
			end
		end
	else
		WidgetUtils.Hidden(self.PanelBox)
		WidgetUtils.SelfHitTestInvisible(self.BigBox)
		--WidgetUtils.Hidden(self.PanelOver)
		--WidgetUtils.Hidden(self.PanelReward)
		--WidgetUtils.Hidden(self.PanelUnFinish)

		--WidgetUtils.Collapsed(self.ImgBox3)
		--WidgetUtils.Collapsed(self.ImgMask_1)
		--WidgetUtils.Collapsed(self.ImgOver_1)
		--WidgetUtils.Collapsed(self.ImgBox_1)
		--WidgetUtils.Collapsed(self.Image_1)
		WidgetUtils.Collapsed(self.ImgFrameSmall2_1)
		WidgetUtils.Collapsed(self.ImgFrameBig_1)
		WidgetUtils.Collapsed(self.ImgFrameSmall_1)
		WidgetUtils.Collapsed(self.Image_2)
		--WidgetUtils.Collapsed(self.Image_6)
		WidgetUtils.SelfHitTestInvisible(self.BigBox)
		WidgetUtils.Collapsed(self.PanelBigOver)
		WidgetUtils.Collapsed(self.PanelBigCurrent)
		WidgetUtils.Collapsed(self.PanelBigUnFinish)

		if gotState == 1 then--已领取
			--[[WidgetUtils.Visible(self.ImgBox3)
			WidgetUtils.Visible(self.ImgMask_1)
			WidgetUtils.Visible(self.ImgOver_1)
			WidgetUtils.Visible(self.Image_6)]]
			BtnClearEvent(self.BtnBigBox)
			WidgetUtils.SelfHitTestInvisible(self.PanelBigOver)
			BtnAddEvent(self.BtnBigBox,function ( ... )
				--tbParam.preViewFunc()
				self.Item:DefaultClick()
			end)
		else
			if tbParam.needPoint <= tbParam.nowPoint then--可以领取
				--[[WidgetUtils.Visible(self.ImgBox3)
				WidgetUtils.Visible(self.Image_6)]]
				WidgetUtils.Visible(self.ImgFrameBig_1)
				WidgetUtils.Visible(self.ImgFrameSmall_1)
				WidgetUtils.Visible(self.Image_2)
				--self:PlayAnimation(self.AllLoop,0,0)
				self:PlayAnimation(self.AllLoopBig,0,0)
				WidgetUtils.SelfHitTestInvisible(self.PanelBigCurrent)
				BtnClearEvent(self.BtnBigBox)
				BtnAddEvent(self.BtnBigBox,function ()
					tbParam.getAwardFunc()
					--self.Item:DefaultClick()
				end)
			else--不可领取
				--WidgetUtils.Visible(self.ImgBox_1)
				WidgetUtils.Visible(self.ImgFrameSmall2_1)
				WidgetUtils.SelfHitTestInvisible(self.PanelBigUnFinish)
				BtnClearEvent(self.BtnBigBox)
				--WidgetUtils.Visible(self.Image_1)
				BtnAddEvent(self.BtnBigBox,function ( ... )
					--tbParam.preViewFunc()
					self.Item:DefaultClick()
				end)
			end
		end
	end
end

return tbClass;