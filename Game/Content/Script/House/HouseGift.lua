HouseGiftLogic = HouseGiftLogic or {}
local tbClass = HouseGiftLogic

function tbClass:LoadCfg()
	self.tbGift = {}
	self.tbFurnitureToGift = {}
	local tbFile = LoadCsv('house/gift.txt', 1)
    for _, tbLine in ipairs(tbFile) do
    	local giftId = tonumber(tbLine.GiftId);
    	local tbInfo = {}
    	tbInfo.furnitureTmpId = tonumber(tbLine.FurnitureTmpId)
    	tbInfo.addLoveNum = tonumber(tbLine.AddLoveNum)
    	tbInfo.desc = tbLine.Desc or ''
    	tbInfo.supportTargets = Eval(tbLine.SupportTargets)
    	tbInfo.supportTargets2 = {}
		tbInfo.SendMessage = tbLine.SendMessage
		tbInfo.CanInteract = tonumber(tbLine.CanInteract) == 1 and true or false;
    	for k,v in pairs(tbInfo.supportTargets) do
    		tbInfo.supportTargets2[v] = 1
    	end
    	self.tbGift[giftId] = tbInfo;
		self.tbFurnitureToGift[tbInfo.furnitureTmpId] = giftId
    end

    self.tbGiftExchange = {}
    local tbFile2 = LoadCsv('house/gift_exchange.txt',1)
    for _, tbLine in ipairs(tbFile2) do
    	local Index = tonumber(tbLine.Index or 0)
    	local Gift = Eval(tbLine.Gift or '')
    	local NeedItems = Eval(tbLine.NeedItems or '')
    	--[[if not self.tbGiftExchange[Index] then
    		self.tbGiftExchange[Index] = {}
    	end]]
    	self.tbGiftExchange[Index] = {Index = Index,Gift = Gift,NeedItems = NeedItems}
    end 
end

function tbClass:GetAllGiftExchange()
	return self.tbGiftExchange
end

function tbClass:GetGiftExchange(Index)
	return self.tbGiftExchange and self.tbGiftExchange[Index]
end

function tbClass:GetGiftInfo(giftId)
	if self.tbGift and giftId and self.tbGift[giftId] then
		return self.tbGift[giftId]
	end
end

--获得已拥有的礼物
function tbClass:GetGiftsHad()
	local pTmpData = UE4.TArray(UE4.UItem)
	if not me then
		return pTmpData
	end
  	me:GetItemsByType(UE4.EItemType.HouseGift, pTmpData)
  	return pTmpData
end

--获得已拥有的，可以送给区域礼物
function tbClass:GetGiftsHadForArea(AreaId)
	local pTmpData = UE4.TArray(UE4.UItem)
	if not me then
		return pTmpData
	end
  	me:GetItemsByType(UE4.EItemType.HouseGift, pTmpData)
  	local pTmpDataArea = UE4.TArray(UE4.UItem)
  	for i=1,pTmpData:Length() do
  		local nowTmp = pTmpData:Get(i)
  		local supportArea = false;
  		local giftId = nowTmp:Param1()
  		local giftInfo = self:GetGiftInfo(giftId)
  		if giftInfo then
  			if giftInfo.supportTargets2 and giftInfo.supportTargets2[AreaId] == 1 then
  				pTmpDataArea:Add(nowTmp)
  			end
  		end
  	end
  	return pTmpDataArea
end

--获得所有可送给区域的礼物
function tbClass:GetGiftsForArea(AreaId)
	local Res = {}
    local pList = UE4.TArray(UE4.FItemTemplate)
    UE4.UItem.GetAllTemplates(pList)
    for i = 1, pList:Length() do
        local pTemplate = pList:Get(i)
        if pTemplate.Genre == UE4.EItemType.HouseGift then
        	local giftId = pTemplate.Param1
  			local giftInfo = self:GetGiftInfo(giftId)
  			if giftInfo then
	  			if giftInfo.supportTargets2 and giftInfo.supportTargets2[AreaId] == 1 then
	  				table.insert(Res,pTemplate)
	  			end
	  		end
        end
    end
    return Res
end



--检测是否能给对应区域送礼
--返回0:不行 1:可以 2:已经送过了
function tbClass:CheckCanGiveGiftToArea(tbGDPLN,AreaId)

	return true;
end

--送礼
function tbClass:GiveGift(tbGDPLN,AreaId)
	if not me then
		return false
	end
	if type(tbGDPLN) ~= 'table' or #tbGDPLN ~= 5 or not AreaId then
		return false;
	end
	local tbParam = {}
	tbParam.FuncName = 'GiveGiftToArea'
	tbParam.tbGDPLN = tbGDPLN;
	tbParam.AreaId = AreaId;
	HouseMessageHandle.HouseMessageSender(tbParam)
end

function tbClass:OnGiveGiftSuccess(tbParam)
	if not tbParam or not tbParam.AreaId then
		return
	end
	self.tbLastParam = tbParam
	self.GiftGivenAreaId = tbParam.AreaId
	local areaId = tbParam.AreaId;

	self.AddFurList = tbParam.AddFurList;

	--更新对应区域的家具
	--[[local spawners = UE4.UGameplayStatics.GetAllActorsOfClass(GetGameIns(),UE4.AHouseFurnitureSpawner)
    
    for i = 1, spawners:Length() do
        local spawner = spawners:Get(i)
        if spawner.AreaId == areaId then
        	spawner:CheckNeedSpawn(true)
        end
    end]]

    if HouseLogic:CheckIsGirl(areaId) then
    	local ui = UI.GetUI('DormPresentSend')
	    if ui then
	    	UI.CloseByName('DormPresentSend')
	    	--ui:OnOpen(areaId)
	    end
    else
	    local ui = UI.GetUI('DormPresent2')
	    if ui then
	    	UI.CloseByName('DormPresent2')
	    	--ui:OnOpen(areaId)
	    end
	end

	local Mode = UE4.UGameplayStatics.GetGameMode(GetGameIns())
	local HouseMode = Mode and Mode:Cast(UE4.AHouseGameMode)
    if HouseMode then
    	local ThanksKey = 'house.SendMessageMult'
    	
    	if CountTB(tbParam.AddFurList) == 1 then
    		ThanksKey = HouseGiftLogic:GetSendGiftKey(tbParam.AddFurList[1], areaId)
    	end
    	HouseMode:OnGiveGiftSuccess(areaId,ThanksKey)

    	HouseMode:UpdateDoors()
    end
end

function tbClass.CheckHasCameraAnim(InFurId,InAreaId)
	if HouseGiftLogic.GiftGivenAreaId ~= InAreaId then
		return false
	end
	for k,v in pairs(HouseGiftLogic.AddFurList) do
		if v == InFurId then
			return true
		end
	end
	return false;
end

function tbClass:OnGiveGiftSuccessAnimEnd()
	self.AddFurList = {}
	HouseGirlLove:OnParamRspCheckNewLevel(self.tbLastParam)
	HouseLogic.EndTalk()
end

function HouseGiftLogic.GetGiftGotInfo_Cpp(AreaId)
	return HouseGiftLogic:GetGiftGotInfo(AreaId)
end

function tbClass:GetGiftGotInfo(AreaId)
	local NowGotNum = 0;
	local AllCanGotNum = 0;
	for k,v in pairs(self.tbGift) do
		if v.supportTargets2[AreaId] then
			AllCanGotNum = AllCanGotNum + 1
			if HouseFurniture.CheckFurnitureById(AreaId,v.furnitureTmpId) then
				NowGotNum = NowGotNum + 1
			end
		end
	end
	return NowGotNum,AllCanGotNum
end

function tbClass:GetSendGiftKey(InFurnitureId, InGirlId)
	local GiftId = self.tbFurnitureToGift[InFurnitureId]
	local tbGift = self.tbGift[GiftId]
	if not tbGift then
		return
	end
	if #tbGift.supportTargets == 1 then
		if tbGift.supportTargets2[InGirlId] then
			return tbGift.SendMessage
		end
	elseif #tbGift.supportTargets > 1 then
		if tbGift.supportTargets2[InGirlId] then
			return string.format("%s_%02d", tbGift.SendMessage, InGirlId)
		end
	end
end