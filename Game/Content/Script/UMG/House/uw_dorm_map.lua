local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
	----数据相关
	self.tbFloor = {}
	self.tbFloor[1] = {
		['FloorName'] = Text(""),
		['FloorPanelType'] = 1,
		['EventTipTb'] = {true,true,true},
	}
	self.tbFloor[2] = {
		['FloorName'] = Text(""),
		['FloorPanelType'] = 2,
		['EventTipTb'] = {true,false,true},
	}
	self.FloorCount = #self.tbFloor;

	self.tbPanelFloor = {}
	self.tbPanelFloor[1] = self.PanelParlour;
	self.tbPanelFloor[2] = self.PanelRoom;

	self.NpcWidgetClass = LoadClass('/Game/UI/UMG/Dorm/Widgets/uw_dorm_roleitem.uw_dorm_roleitem_C');

	----UI相关
	local BackEvent = function ()
		UI.OpenDormMainUI()
        UI.GC()
	end
	self.Title:SetCustomEvent(BackEvent,BackEvent);
	self.Title:SetShowExitBtn(true)

	BtnAddEvent(self.Larrow,function ()
		local index = self.NowFloorId - 1
		if index < 1 then
			index = self.FloorCount
		end
		self:ShowFloor(index)
	end)
	BtnAddEvent(self.Rarrow,function ()
		local index = self.NowFloorId + 1
		if index > self.FloorCount then
			index = 1
		end
		self:ShowFloor(index)
	end)

	BtnAddEvent(self.PanelParlour.BtnRoom,function ()
		self:PlayerTransTo(self.NowFloorId or 1)
	end)

	BtnAddEvent(self.PanelRoom.BtnRoom,function ()
		self:PlayerTransTo(self.NowFloorId or 1)
	end)

	WidgetUtils.Collapsed(self.Item)
end

function tbClass:OnOpen()
	self.Title:SetCustomEvent(nil,function ()
        GoToMainLevel()
    end)

	self.tbNpcWidgets = {}

	local player = UE4.UGameplayStatics.GetPlayerController(self,0)
    local housePlayer = player:Cast(UE4.AHousePlayerController)
    if housePlayer then
        self.player = housePlayer
        housePlayer:SetBlockControl(true)
    end


	self:ShowMouseCursor(true)
	local TargetFloorId = 2
	if self.player then
		local PlayerCharacter = self.player:K2_GetPawn()
		if IsValid(PlayerCharacter) then
			local FloorBoxs = UE4.UGameplayStatics.GetAllActorsOfClass(self,UE4.AHouseFloorCheckBox)
			local TargetFloor = nil
			for i=1,FloorBoxs:Length() do
				local Floor = FloorBoxs:Get(i)
				if Floor:CheckIsOnFloor(PlayerCharacter) then
					TargetFloorId = Floor.FloorId
				end
			end
		end
	end
	self:ShowFloor(TargetFloorId)
end

function tbClass:OnClose()
	self:ClearNowNpcWidgets()

	self:ShowMouseCursor(false)
	if self.player then
		self.player:SetBlockControl(false)
	else
		local player = UE4.UGameplayStatics.GetPlayerController(self,0)
		if player then
			player:SetBlockControl(false)
		end
	end
end

function tbClass:ClearNowNpcWidgets()
	for k,v in pairs(self.tbNpcWidgets or {}) do
		v:RemoveFromParent()
		v:Destroy()
	end
	self.tbNpcWidgets = {}
end

function tbClass:IsTabHas(tb,value)
	if not tb or not value then
		return false;
	end
	for k,v in pairs(tb) do
		if value == v then
			return true
		end
	end
	return false
end

function tbClass:ShowFloor(index)
	self.NowFloorId = index;
	local Info = self.tbFloor[index]

	if Info then
		self.Floor.TxtNum:SetText(index)
		for i,v in ipairs(self.tbPanelFloor) do
			if i == index then
				WidgetUtils.SelfHitTestInvisible(v)
			else
				WidgetUtils.Collapsed(v)
			end
		end
		for i = 1,3 do
			if Info.EventTipTb[i] then
				WidgetUtils.SelfHitTestInvisible(self['Info'..i])
			else
				WidgetUtils.Collapsed(self['Info'..i])
			end
		end
		
		if self['SetCharactersOnUI'..Info.FloorPanelType] and self.tbPanelFloor[Info.FloorPanelType] then
			UE4.Timer.NextFrame(function ( ... )
				self['SetCharactersOnUI'..Info.FloorPanelType](self,self.tbPanelFloor[Info.FloorPanelType],index)
			end)
			--self['SetCharactersOnUI'..Info.FloorPanelType](self,self.tbPanelFloor[Info.FloorPanelType],index)
			--self:SetCharactersOnUI1(self.tbPanelFloor[Info.FloorPanelType],index)
		end
	end
end

function tbClass:ShowOneNpcOnMap(Widget,TargetFloor,Npc)
	if not IsValid(TargetFloor) or not IsValid(Npc) then
		return nil
	end
	if not Npc:GetCharacterTemplate().ShowOnMap then
		return nil
	end
	local NormalizedPos = TargetFloor:GetActorNormalizedPosInBox(Npc);
	local IconPath = '';
	if Npc.GirlId > 0 then
		IconPath = HouseLogic:GetGirlIcon(Npc.GirlId)
	else
		IconPath = tonumber(Npc:GetIcon())
	end
	local NewItem = NewObject(self.NpcWidgetClass, self, nil)
	WidgetUtils.SelfHitTestInvisible(Widget.PanelParlour)
	Widget.PanelParlour:AddChild(NewItem)
	table.insert(self.tbNpcWidgets,NewItem)

	WidgetUtils.HitTestInvisible(NewItem)
	NewItem.IconPath = IconPath;

	if HouseLogic:GetNpcHasNew(Npc.NpcId) then
		WidgetUtils.SelfHitTestInvisible(NewItem.New)
	else
		WidgetUtils.Collapsed(NewItem.New)
	end
	SetTexture(NewItem.ImgIcon,IconPath)
	--NewItem:SetShowPlayer()
	if Npc.GirlId > 0 and HouseBedroom.CheckGirlAviliable(Npc.GirlId) then
		WidgetUtils.SelfHitTestInvisible(NewItem.Heart)
		NewItem.Heart:Display(HouseGirlLove:GetGirlLoveLevel(Npc.GirlId))
	else
		WidgetUtils.Collapsed(NewItem.Heart)
	end

	local NpcSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(NewItem)
	local MapSize = UE4.USlateBlueprintLibrary.GetLocalSize(Widget:GetCachedGeometry());
	if NpcSlot then
		NpcSlot:SetMinimum(UE.FVector2D(0.5, 0.5))
		NpcSlot:SetMaximum(UE.FVector2D(0.5, 0.5))
		NpcSlot:SetAlignment(UE.FVector2D(0.5, 0.5))
		NpcSlot:SetSize(UE.FVector2D(100, 30) * 0.85)
		NpcSlot:SetAutoSize(true)
		NpcSlot:SetZOrder(201 - Npc.NpcId)
		NpcSlot:SetPosition(MapSize * NormalizedPos * 0.5)
	end
	return NewItem;
end

--显示卧室那一层的Npc
function tbClass:SetCharactersOnUI2( Widget,FloorId )
	self:ClearNowNpcWidgets()
	for i=1,8 do
		self:DealBedRoomUI(self.PanelRoom,i)
	end

	self:ShowNpcsOnFloor(Widget,FloorId)
end

--显示某一层所有的Npc
function tbClass:SetCharactersOnUI1(Widget,FloorId)
	self:ShowNpcsOnFloor(Widget,FloorId)
end

--显示某一层所有的npc
function tbClass:ShowNpcsOnFloor(Widget,FloorId)
	self:ClearNowNpcWidgets()
	WidgetUtils.Collapsed(self.TransBtn)
	local FloorBoxs = UE4.UGameplayStatics.GetAllActorsOfClass(self,UE4.AHouseFloorCheckBox)
	local TargetFloor = nil
	for i=1,FloorBoxs:Length() do
		local Floor = FloorBoxs:Get(i)
		if Floor.FloorId == FloorId then
			TargetFloor = Floor
		end
	end
	if not TargetFloor then
		return
	end

	local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(Widget)
	if not Slot then
		return
	end
	local Position = Slot:GetPosition()
	--local MapSize = Slot:GetSize()
	local MapSize = UE4.USlateBlueprintLibrary.GetLocalSize(Widget:GetCachedGeometry());

	local Npcs = UE4.UGameplayStatics.GetAllActorsOfClass(self,UE4.AHouseBaseCharacter)
	for i=1,Npcs:Length() do
		local Npc = Npcs:Get(i)
		if IsValid(Npc) and TargetFloor:CheckIsOnFloor(Npc) then
			local Character = Npc:Cast(UE4.AHouseBaseCharacter)		
			if IsValid(Character) then
				local NewItem = self:ShowOneNpcOnMap(Widget, TargetFloor, Character)
				if NewItem then
					if Npc.NpcId == 0 then
						NewItem:SetShowPlayer()
					end
					if Npc.NpcId == 99 then
						NewItem:SetShowNpc99()
					end
				end
			end
		end
	end
end

--玩家传送
function tbClass:PlayerTransTo(FloorId)
	local func = function ( ... )
		if not self.player then
			return
		end
		
		local FloorPoints = UE4.UGameplayStatics.GetAllActorsOfClass(self,UE4.AHouseFloorTransmissionPoint)
		local TargetPoint = nil
		for i=1,FloorPoints:Length() do
			local Point = FloorPoints:Get(i)
			if Point.FloorId == FloorId then
				TargetPoint = Point
			end
		end
		--加载了场景就传送
		if IsValid(TargetPoint) then
			HouseLogic.ShowUIMask(true)
			self.player:UnLoadBedRoomThenTransToPos(TargetPoint)
			HouseLogic.ShowUIMask(false)
		end
		UI.Close('DormMap')
	end

	local str = Text('house.TransTip'..FloorId)
	UI.Open("MessageBox", str, function() func() end,function() end)
end

function tbClass:PlayerTransToGirl(BedRoomId)
	local func = function ( ... )
		if not self.player then
			return
		end
		
		--local BedRoomId = 1;--待修改为取少女卧室Id
		local FloorPoints = UE4.UGameplayStatics.GetAllActorsOfClass(self,UE4.AHouseFloorTransmissionPoint)
		local TargetPoint = nil
		for i=1,FloorPoints:Length() do
			local Point = FloorPoints:Get(i)
			if Point.BedRoomId == BedRoomId then
				TargetPoint = Point
			end
		end
		--加载了场景就传送
		if IsValid(TargetPoint) then
			HouseLogic.ShowUIMask(true)
			self.player:UnLoadBedRoomThenTransToPos(TargetPoint)
			HouseLogic.ShowUIMask(false)
		end
		UI.Close('DormMap')
	end

	local GirlId = HouseBedroom.GetBedroomGirlId(BedRoomId)
	if GirlId and GirlId > 0 then
		local GirlName = HouseLogic:GetGirlName(GirlId)
		local str = string.format(Text('house.TransTip0'),GirlName)
		UI.Open("MessageBox", str, function() func() end,function() end)
	end
end

function tbClass:ShowMouseCursor(bShow)
    RuntimeState.ChangeInputMode(bShow)
end

--处理地图上一个卧室UI
function tbClass:DealBedRoomUI(UIItem,BedRoomId)
	local IsUnlock = HouseBedroom.CheckRoomAviliable(BedRoomId)
    local GirlId = HouseBedroom.GetBedroomGirlId(BedRoomId)
    if IsUnlock then
    	WidgetUtils.Collapsed(UIItem['Lock'..BedRoomId])
    else
    	WidgetUtils.Visible(UIItem['Lock'..BedRoomId])
    end

    --UIItem['Lock'..BedRoomId]:SetVisibility(IsUnlock > 0 and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)

    if GirlId > 0 then
    	local Mode = UE4.UGameplayStatics.GetGameMode(GetGameIns())
		local HouseMode = Mode and Mode:Cast(UE4.AHouseGameMode)
		WidgetUtils.SelfHitTestInvisible(UIItem['Item'..BedRoomId])
		WidgetUtils.Collapsed(UIItem['Item'..BedRoomId].New)
		WidgetUtils.Collapsed(UIItem['Location'..BedRoomId])
		WidgetUtils.SelfHitTestInvisible(UIItem['Comfort'..BedRoomId])
		local nowCount,allCount = HouseGiftLogic:GetGiftGotInfo(GirlId)
		UIItem['Comfort'..BedRoomId]:Display(nowCount,allCount);
		UIItem['Item'..BedRoomId].Heart:Display(HouseGirlLove:GetGirlLoveLevel(GirlId))
	    if HouseMode then
	    	local NpcId = HouseMode:GetNpcIdByGirlId(GirlId)
	    	local AreaId = HouseMode:GetNpcBornAreaId(NpcId);
	    	UIItem['Lived'..BedRoomId]:SetVisibility(AreaId == GirlId and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)

	    	local IconPath = HouseLogic:GetGirlIcon(GirlId)
	    	SetTexture(UIItem['Item'..BedRoomId] and UIItem['Item'..BedRoomId].ImgIcon,IconPath)
	    	if AreaId == GirlId then

	    		local EventId = HouseStorage.GetCharacterAttr(GirlId, HouseStorage.EGirlAttr.DailyEvent);
	    		
	    		--在房间才有随机事件提示
	    		local HasNewEvent = EventId and EventId > 0
	    		if HasNewEvent then
	    			WidgetUtils.SelfHitTestInvisible(UIItem['Item'..BedRoomId].New)
	    		else
	    			WidgetUtils.Collapsed(UIItem['Item'..BedRoomId].New)
	    		end

				local BedRoomMgr = HouseMode:GetBedRoomMgr()
				if IsValid(BedRoomMgr) and BedRoomMgr.NowLoadBedRoomId == BedRoomId then
					WidgetUtils.SelfHitTestInvisible(UIItem['Location'..BedRoomId])
				else
					WidgetUtils.Collapsed(UIItem['Location'..BedRoomId])
				end
	    	end
	    end

	    UIItem['Item'..BedRoomId]:SetClickFunc(function ( ... )
	    	self:PlayerTransToGirl(BedRoomId)
	    end)
	    UIItem['Item'..BedRoomId].CanDrag = false;
    else
    	UIItem['Lived'..BedRoomId]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    	WidgetUtils.Collapsed(UIItem['Item'..BedRoomId])
    	WidgetUtils.Collapsed(UIItem['Location'..BedRoomId])
    end

    BtnClearEvent(UIItem['Lock'..BedRoomId])
    BtnAddEvent(UIItem['Lock'..BedRoomId],function ( ... )
    	UI.ShowTip(Text('house.TransTipLock'))
    end)
end

return tbClass;