local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
	if not pObj or not pObj.Data then
		return
	end
	local tbParam = pObj.Data;
	--self
	--如果配的key有. 说明是UIKey，否则是HouseTalk的函数
	if string.find(tbParam.OptionInfo.OptionKey,'.') then
		self.BranchText:SetText(Text(tbParam.OptionInfo.OptionKey))
		self.BranchText_1:SetText(Text(tbParam.OptionInfo.OptionKey))
		self.BranchTextSP:SetText(Text(tbParam.OptionInfo.OptionKey))
	else
		self.BranchText:SetText(HouseTalk:DealFunc(tbParam.OptionInfo.OptionKey))
		self.BranchText_1:SetText(HouseTalk:DealFunc(tbParam.OptionInfo.OptionKey))
		self.BranchTextSP:SetText(HouseTalk:DealFunc(tbParam.OptionInfo.OptionKey))
	end

	if tbParam.OptionInfo.OptionIcon then
		SetTexture(self.ImgIcon_1,tbParam.OptionInfo.OptionIcon)
		SetTexture(self.ImgIcon,tbParam.OptionInfo.OptionIcon)
		SetTexture(self.ImgIconSP,tbParam.OptionInfo.OptionIcon)
	end

	if tbParam.OptionInfo.OptionKey == 'house.RandomEvent' then
		WidgetUtils.SelfHitTestInvisible(self.SPBackground)
	end

	self.FuncStr = tbParam.OptionInfo.OptionFunc[1]
	local params = {}
	params[1] = tbParam.NpcId
	params[2] = tbParam.GirlId
	for i=2,#tbParam.OptionInfo.OptionFunc do
		params[#params + 1] = tbParam.OptionInfo.OptionFunc[i]
	end
	BtnClearEvent(self.ClickBtn)
	BtnAddEvent(self.ClickBtn,function ()
		HouseTalk:DealOptionFunc(self.FuncStr,params)
	end);
end

return tbClass;