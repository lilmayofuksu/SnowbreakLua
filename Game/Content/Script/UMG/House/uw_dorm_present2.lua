--===============
--区域送礼界面
--===============
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
	--self.ListItem
    BtnClearEvent(self.Button)
    BtnAddEvent(self.Button,function() 
        self:ClickGiveGift()
    end)
end

function tbClass:OnOpen(AreaId)
    self.Title:SetCustomEvent(function ()
        UI.CloseTop()
    end,function ()
        GoToMainLevel()
    end)
    self.Title:SetShowExitBtn(false)
    
    WidgetUtils.SelfHitTestInvisible(self.Title)
    self.Title:SetCustomEvent(nil, function()
        UI.OpenDormMainUI()
        UI.GC()
    end)
	self.AreaId = AreaId or 0
	
	self.nowSlGifts = {}

	self.Factory = Model.Use(self)
    self:DoClearListItems(self.ListItem)
    local gifts = HouseGiftLogic:GetGiftsForArea(self.AreaId)
    for i,value in ipairs(gifts) do
        local GiftId = value.Param1;
        local GiftInfo = HouseGiftLogic:GetGiftInfo(GiftId)
        local HasCollectAll = true;
        if GiftInfo then
            for i,v in ipairs(GiftInfo.supportTargets) do
                if not HouseFurniture.CheckFurnitureById(v,GiftInfo.furnitureTmpId) then
                    HasCollectAll = false;
                end
            end
        end

        local pItemList = UE4.TArray(UE4.UItem)
        me:GetItemsByGDPL(value.Genre,value.Detail,value.Particular,value.Level,pItemList)
        local nowNum = 0
        if pItemList:Length() >= 1 then
            local nowItem = pItemList:Get(1)
            nowNum = nowItem:Count()
        end
        local Lock = (nowNum == 0)
        if HasCollectAll then Lock = false; end

        local tbParam = {
            G = value.Genre,
            D = value.Detail,
            P = value.Particular,
            L = value.Level,
            N = value.Count,
            pItem = value,
            Total = nowNum,
            Name = "",
            bSelected = false,
            tbDorm = {bCollectAll = HasCollectAll,bLock = Lock}
        }
        
        tbParam.fCustomEvent = function ()
            if Lock or HasCollectAll then
                return
            end
    		tbParam.bSelected = not tbParam.bSelected
    		EventSystem.TriggerTarget(tbParam,"SET_SELECTED")

    		if tbParam.bSelected then
    			self.nowSlGifts[value] = 1
    		else
    			self.nowSlGifts[value] = nil
    		end
        end
        local item =self.Factory:Create(tbParam)
        self.ListItem:AddItem(item)
    end

    --显示收集度
    local NowGotNum,AllCanGotNum = HouseGiftLogic:GetGiftGotInfo(AreaId)
    self.TxtProgressNum:SetText(NowGotNum..'/'..AllCanGotNum);
end

function tbClass:ClickGiveGift()
    if not self.AreaId then return end
    local tbParam = {}
    tbParam.FuncName = 'GiveGiftToArea'
	tbParam.tbGDPLN = {}
    tbParam.AreaId = self.AreaId or 0
    for k,v in pairs(self.nowSlGifts) do
        table.insert(tbParam.tbGDPLN,{k.Genre,k.Detail,k.Particular,k.Level,1})
    end
    HouseMessageHandle.HouseMessageSender(tbParam);
end

function tbClass:OnClose()
	
end

return tbClass