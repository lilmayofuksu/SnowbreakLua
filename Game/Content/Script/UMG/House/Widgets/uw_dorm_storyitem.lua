local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
	local tbParam = pObj and pObj.Data
	if not tbParam then
		return
	end
	self.tbParam = tbParam;
	local GirlId = tbParam.GirlId
	local Index = tbParam.Index
	local Level = tbParam.Level
	local nowLevel = HouseGirlLove:GetGirlLoveLevel(GirlId)
	local IsUnLock = (nowLevel >= Level)

	self.TxtName:SetText(Text(tbParam.StoryName))
	local LockStr = string.format(Text('house.StoryLock'),Level or 0)
	self.TxtName_1:SetText(LockStr)

	BtnClearEvent(self.Btn)
	if IsUnLock then
		WidgetUtils.Collapsed(self.Lock)
		WidgetUtils.SelfHitTestInvisible(self.Normal)
		BtnAddEvent(self.Btn,function ()
			HouseGirlLove:ReadGirlLoveStory(GirlId,Index)
		end)
	else
		WidgetUtils.Collapsed(self.Normal)
		WidgetUtils.SelfHitTestInvisible(self.Lock)
		BtnAddEvent(self.Btn,function ()
			UI.Open('CheckItem', self.tbParam.TbReward, nil, false, true)
		end)
	end

	if IsUnLock and not HouseGirlLove:CheckGirlLoveStoryHasRead(GirlId,Index) then
		WidgetUtils.SelfHitTestInvisible(self.New)
	else
		WidgetUtils.Collapsed(self.New)
	end
end


return tbClass;