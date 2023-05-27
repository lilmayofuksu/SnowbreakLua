local tbClass = Class('UMG.BaseWidget')

function tbClass:OnInit()
	BtnClearEvent(self.Button)
	--[[BtnAddEvent(self.Button,function ()
		if self.SelectIndex then
			local tbParam = {}
			tbParam.FuncName = 'ExchangeGift'
			tbParam.Index = self.SelectIndex
			HouseMessageHandle.HouseMessageSender(tbParam)
		end
	end)]]

	self.ExChangeFunc = function ( ... )
		if self.SelectIndex then
			local tbParam = {}
			tbParam.FuncName = 'ExchangeGift'
			tbParam.Index = self.SelectIndex
			HouseMessageHandle.HouseMessageSender(tbParam)
		end
	end

	self.CantExChangeFunc = function ( ... )
		UI.ShowTip('tip.house.LackItem')
	end

	local tbRule = {}
	for k,v in pairs(HouseBedroom.GirlConfig) do
		table.insert(tbRule,{HouseLogic:GetGirlName(k),k})
	end
	self.tbFilterParam = {
        tbFilter = {
		{
			sDesc='house.GirlFilter', 
            rule = 11,
            tbRule = tbRule,
		}
	}};

	BtnClearEvent(self.BtnScreen)
	BtnAddEvent(self.BtnScreen,function ( ... )
		self.tbCond = self.tbCond or {tbFilter=nil}
		UI.Open('Screen',self.tbFilterParam,self.tbCond,function () 
			local tbGirl = nil
			if self.tbCond and self.tbCond.tbFilter and self.tbCond.tbFilter[1] then
				tbGirl = {}
				for k,v in pairs(self.tbCond.tbFilter[1]) do
					if type(v)== 'table' and v[2] then
						tbGirl[v[2]] = 1
					end
				end
			end

			if tbGirl then
				self.OnOpenClick = nil
				self:UpdateUI(tbGirl)
				if self.OnOpenClick then
					self.OnOpenClick()
				end
			end
		end)
	end)

	self.Factory = Model.Use(self)
end

function tbClass:UpdateUI(tbGirlId)
	local tbExchange = HouseGiftLogic:GetAllGiftExchange()
	if not tbExchange then
		return
	end
	self:DoClearListItems(self.ListCost)
	self:DoClearListItems(self.ListItem)

	self.tbGirlId = tbGirlId or self.tbGirlId 

	local tbNotCollectAll = {}
	local tbCollectAll = {}

	local tbExchangeFiltered = {};
	if self.tbGirlId and not self.tbGirlId[0] then
		for i,v in ipairs(tbExchange) do
			local GDPL = v.Gift
			local Tmp = UE4.UItemLibrary.GetItemTemplateByGDPL(GDPL[1],GDPL[2],GDPL[3],GDPL[4])
			if Tmp then
				local GiftId = Tmp.Param1;
				local GiftInfo = HouseGiftLogic:GetGiftInfo(GiftId)
				local HasCollectAll = false;
				local GiftTargetGirl = nil
				if GiftInfo then
					for _,st in pairs(GiftInfo.supportTargets) do
						if self.tbGirlId[st] then
							table.insert(tbExchangeFiltered,v);
						end
					end
				end
			end
		end
	else
		tbExchangeFiltered = tbExchange;
	end

	for i,v in ipairs(tbExchangeFiltered) do
		local GDPL = v.Gift
		local Tmp = UE4.UItemLibrary.GetItemTemplateByGDPL(GDPL[1],GDPL[2],GDPL[3],GDPL[4])
		if Tmp then
			local GiftId = Tmp.Param1;
			local GiftInfo = HouseGiftLogic:GetGiftInfo(GiftId)
			local HasCollectAll = false;
			local GiftTargetGirl = nil
			if GiftInfo then
				local NeedCollectNum = #GiftInfo.supportTargets
				local NowCollectNum = me and me:GetItemCount(GDPL[1],GDPL[2],GDPL[3],GDPL[4]) or 0;
				for i,v in ipairs(GiftInfo.supportTargets) do
					if HouseFurniture.CheckFurnitureById(v,GiftInfo.furnitureTmpId) then
						NowCollectNum = NowCollectNum + 1;
					end
				end
				if #GiftInfo.supportTargets == 1 then
					GiftTargetGirl = GiftInfo.supportTargets[1]
				end
				HasCollectAll = NowCollectNum >= NeedCollectNum;
			end

			local CanExchange = self:CheckExChangeInfoHasNeed(v);

			local tbParam = {
	            G = Tmp.Genre,
	            D = Tmp.Detail,
	            P = Tmp.Particular,
	            L = Tmp.Level,
	            N = 1,
	            Color = Tmp.Color,
	            pItem = nil,
	            Total = 1,
	            Name = "",
	            bSelected = false,
	            tbDorm = {bCollectAll = HasCollectAll,TargetGirl = GiftTargetGirl,CanExchange = CanExchange,CanInteract = GiftInfo and GiftInfo.CanInteract},
	            CanExChange = CanExchange and 1 or 0,
	            GiftId = GiftId,
	        }
	        tbParam.fCustomEvent = function ()
	        	if self.SelectTbParam then
	        		self.SelectTbParam.bSelected = false;
	        		EventSystem.TriggerTarget(self.SelectTbParam,"SET_SELECTED")
	        	end
	        	self.SelectTbParam = tbParam;
	    		tbParam.bSelected = not tbParam.bSelected
	    		EventSystem.TriggerTarget(tbParam,"SET_SELECTED")

	    		self.SelectIndex = v.Index
	    		self:ShowGiftExchange(v,HasCollectAll)
	        end

	        if HasCollectAll then
	        	table.insert(tbCollectAll,tbParam)
	        else
	        	table.insert(tbNotCollectAll,tbParam)
	        end
		end
	end

	table.sort(tbNotCollectAll,function (a,b)
		if a.CanExchange == b.CanExchange then
			if a.Color == b.Color then
				if a.D == b.D then
					return a.GiftId < b.GiftId
				end
				return a.D < b.D
			end
			return a.Color > b.Color
		end
		return a.CanExchange > b.CanExchange
	end)
	table.sort(tbCollectAll,function (a,b)
		if a.Color == b.Color then
			if a.D == b.D then
				return a.GiftId < b.GiftId
			end
			return a.D < b.D
		end
		return a.Color > b.Color
	end)

	for i,v in ipairs(tbNotCollectAll) do
		if not self.OnOpenClick then
        	self.OnOpenClick = v.fCustomEvent
        end
        local item =self.Factory:Create(v)
        self.ListItem:AddItem(item)
	end
	for i,v in ipairs(tbCollectAll) do
		if not self.OnOpenClick then
        	self.OnOpenClick = v.fCustomEvent
        end
        local item =self.Factory:Create(v)
        self.ListItem:AddItem(item)
	end
end

function tbClass:OnOpen()
	self.Title:SetCustomEvent(function ()
		UI.CloseTop()
	end,function ()
        GoToMainLevel()
    end)

    self.Title:SetShowExitBtn(false)
    self.ListItem:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
	--self.SelectIndex = self.SelectIndex
	self:UpdateUI()

	if self.OnOpenClick then
		self.OnOpenClick()
	end
end

function tbClass:OnExChangeRsp(tbParam)
	Item.Gain(tbParam.Award)
	self:ShowGiftExchange(self.ExchangeInfo,self.HasCollectAll)
	self.OnOpenClick = nil
	self:UpdateUI()
	if self.OnOpenClick then
		self.OnOpenClick()
	end
end

--判断某个兑换是否满足条件
function tbClass:CheckExChangeInfoHasNeed(ExchangeInfo)
	local HasNeedItems = true;
	self:DoClearListItems(self.ListCost)
	for i,v in ipairs(ExchangeInfo.NeedItems) do
		local pItemList = UE4.TArray(UE4.UItem)
		--me:GetItemsByGDPL(v[1],v[2],v[3],v[4],pItemList)
		local Tmp = UE4.UItemLibrary.GetItemTemplateByGDPL(v[1],v[2],v[3],v[4])
		me:GetItemsByGDPL(v[1],v[2],v[3],v[4],pItemList)
		local nowNum = 0
		if pItemList:Length() >= 1 then
			local nowItem = pItemList:Get(1)
			nowNum = nowItem:Count()
		end
		if nowNum < v[5] then
			HasNeedItems = false
		end
	end
	return HasNeedItems
end

function tbClass:ShowGiftExchange(ExchangeInfo,HasCollectAll)
	if not ExchangeInfo or not me then
		return
	end
	self.ExchangeInfo = ExchangeInfo
	self.HasCollectAll = HasCollectAll
	local HasNeedItems = true;
	self:DoClearListItems(self.ListCost)
	for i,v in ipairs(ExchangeInfo.NeedItems) do
		local pItemList = UE4.TArray(UE4.UItem)
		--me:GetItemsByGDPL(v[1],v[2],v[3],v[4],pItemList)
		local Tmp = UE4.UItemLibrary.GetItemTemplateByGDPL(v[1],v[2],v[3],v[4])
		me:GetItemsByGDPL(v[1],v[2],v[3],v[4],pItemList)
		local nowNum = 0
		if pItemList:Length() >= 1 then
			local nowItem = pItemList:Get(1)
			nowNum = nowItem:Count()
		end
		if nowNum < v[5] then
			HasNeedItems = false
		end
		local tbParam = {
			G = v[1],
			D = v[2],
			P = v[3],
			L = v[4],
			N = {nHaveNum = nowNum,nNeedNum = v[5]},
			pItem = nil,
			bSelected = false,
		}
		local item =self.Factory:Create(tbParam)
        self.ListCost:AddItem(item)
	end

	--更新按钮状态
	if HasCollectAll then
		WidgetUtils.Collapsed(self.Button)
		WidgetUtils.Collapsed(self.BtnUnable)
	else
		if not HasNeedItems then
			--[[WidgetUtils.Collapsed(self.Button)
			WidgetUtils.Visible(self.BtnUnable)]]
			BtnClearEvent(self.Button)
			BtnAddEvent(self.Button,self.CantExChangeFunc)
			WidgetUtils.Visible(self.Button)
		else
			BtnClearEvent(self.Button)
			BtnAddEvent(self.Button,self.ExChangeFunc)
			WidgetUtils.Visible(self.Button)
			--[[WidgetUtils.Collapsed(self.BtnUnable)
			WidgetUtils.Visible(self.Button)]]
		end
	end

	--显示礼物信息
	self.Info:UpdateGift(ExchangeInfo.Gift)
	local GDPL = ExchangeInfo.Gift
	if GDPL then
		local Tmp = UE4.UItemLibrary.GetItemTemplateByGDPL(GDPL[1],GDPL[2],GDPL[3],GDPL[4])
		self.TxtPresentName:SetText(Text(Tmp.I18N))
	end
end

function tbClass:OnClose()
	self.SelectTbParam = nil
end

return tbClass;