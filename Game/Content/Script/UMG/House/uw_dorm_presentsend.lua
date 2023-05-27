--===============
--少女礼物赠送界面
--===============

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
	--self.ListItem
    BtnClearEvent(self.Button)
    BtnAddEvent(self.Button,function() 
        self:ClickGiveGift()
    end)

    self.RefreshSpeed = 0.2;
end

function tbClass:OnOpen(AreaId)
    WidgetUtils.SelfHitTestInvisible(self.Title)
    self.Title:SetCustomEvent(function ()
        UI.CloseTop()
    end,function ()
        GoToMainLevel()
    end)
    self.Title:SetShowExitBtn(false)

    self.NowCollectNum = 0

    self.AreaId = AreaId or 1
    self.nowSlGifts = {}
    WidgetUtils.Collapsed(self.Info)

    self.Factory = Model.Use(self)
    self:DoClearListItems(self.ListItem)
    --local gifts = HouseGiftLogic:GetGiftsHad(self.AreaId)
    local tbGiftsForArea = HouseGiftLogic:GetGiftsForArea(self.AreaId)

    local tbParamGiftsForArea = {}

    for i,value in ipairs(tbGiftsForArea) do
        local GiftId = value.Param1;
        local GiftInfo = HouseGiftLogic:GetGiftInfo(GiftId)
        local HasCollectAll = true;
        if GiftInfo then
            --[[for i,v in ipairs(GiftInfo.supportTargets) do
                if not HouseFurniture.CheckFurnitureById(v,GiftInfo.furnitureTmpId) then
                    HasCollectAll = false;
                end
            end]]
            if not HouseFurniture.CheckFurnitureById(self.AreaId,GiftInfo.furnitureTmpId) then
                HasCollectAll = false;
            end
        end

        local CollectState = 0;
        local ItemCount = 0
        if me then
            ItemCount = me:GetItemCount(value.Genre,value.Detail,value.Particular,value.Level)
        end
        local bLock = false
        if not HasCollectAll then
            if ItemCount == 0 then
                CollectState = 1
                bLock = true
            else
                CollectState = 2
            end
        end

        local tbParam = {
            G = value.Genre,
            D = value.Detail,
            P = value.Particular,
            L = value.Level,
            N = ItemCount,
            pItem = value,
            Total = ItemCount,
            Name = "",
            bSelected = false,
            tbDorm = {bCollectAll = HasCollectAll,TargetGirl = nil,bLock = bLock,CanInteract = GiftInfo and GiftInfo.CanInteract},
            CollectState = CollectState,
            Color = value.Color,
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
            if HasCollectAll then
                self:ShowGift({tbParam.G,tbParam.D,tbParam.P,tbParam.L,tbParam.N},CollectState)
                return
            end
            if tbParam.bSelected then
                self.nowSlGifts = {}
                self.nowSlGifts[value] = 1
            --[[else
                self.nowSlGifts[value] = nil--]]
            end

            self:ShowGift({tbParam.G,tbParam.D,tbParam.P,tbParam.L,tbParam.N},CollectState)
        end

        table.insert(tbParamGiftsForArea,tbParam)
    end

    table.sort(tbParamGiftsForArea,function (a,b)
        if not a.CollectState or not b.CollectState then
            return false
        end
        if a.CollectState == b.CollectState then
            if a.Color == b.Color then
                return a.GiftId < b.GiftId
            end
            return a.Color > b.Color;
        end
        return a.CollectState > b.CollectState;
    end)

    --local AllCanGive = HouseGiftLogic:GetGiftsForArea(AreaId)
    self.AllCanCollectNum = #tbGiftsForArea;

    for i,value in ipairs(tbParamGiftsForArea) do
        if not self.OnOpenClick then
            self.OnOpenClick = value.fCustomEvent
        end
        local item =self.Factory:Create(value)
        self.ListItem:AddItem(item)
    end

    --self.GirlItem:DisplayByGirlId(self.AreaId)

    local nowPoint = HouseGirlLove:GetGirlNowLovePoint(self.AreaId);
    local nowLevel = HouseGirlLove:GetGirlLoveLevel(self.AreaId)
    local nowNeedPoint,HasNextLevel = HouseGirlLove:GetGirlLevelUpNeedPoint(nowLevel)
    if HasNextLevel then
        self.BarExp:SetPercent(nowPoint/nowNeedPoint)
    else
        WidgetUtils.Collapsed(self.BarExp)
    end
    self.NowPoint = nowPoint;
    self.NowLevel = nowLevel;
    self.NowShowTargetLevel = self.NowLevel;
    self.NowShowTargetPoint = self.NowPoint;
    --self.TxtExp:SetText(nowPoint..'/'..nowNeedPoint)

    self.Heart:Display(nowLevel)
    local Template = UE4.UItem.FindTemplate(1, self.AreaId, 1, 1)
    SetTexture(self.ImgIcon, Template.Icon)


    self:UpdateCollectPercent()

    self.BarNextExp:SetPercent(0)
    WidgetUtils.SelfHitTestInvisible(self.BarNextExp)
    self:SetAddTarget(0)

    if self.OnOpenClick then
        self.OnOpenClick()
    end
end

function tbClass:UpdateCollectPercent()
    local nowCount,allCount = HouseGiftLogic:GetGiftGotInfo(self.AreaId)
    self.NowCollectNum = nowCount;
    self.AllCanCollectNum = allCount;
    --旧UI
    --local str = (self.NowCollectNum or 0)..'+'..self:CountTB(self.nowSlGifts or {})..'/'..(self.AllCanCollectNum or 0);
    --self.TxtNum:SetText(str)
    self.TxtProgressNum1:SetText(self.NowCollectNum or 0)
    self.TxtProgressNum2:SetText(self.AllCanCollectNum or 0)
    self.TxtExpPlus:SetText('+'..self:CountTB(self.nowSlGifts or {}))
end

function tbClass:CountTB(InTb)
    local res = 0
    for k,v in pairs(InTb or {}) do
        res = res + 1
    end
    return res
end

function tbClass:ShowGift(Gift,CollectState)
    --显示礼物信息
    WidgetUtils.SelfHitTestInvisible(self.Info)
    self.Info:UpdateGift(Gift)
    --local str = (self.NowCollectNum or 0)..'+'..self:CountTB(self.nowSlGifts or {})..'/'..(self.AllCanCollectNum or 0);
    --self.TxtNum:SetText(str)

    local AddTotal = 0
    for k,v in pairs(self.nowSlGifts) do
        local GiftId = k.Param1;
        local GiftInfo = HouseGiftLogic:GetGiftInfo(GiftId)
        AddTotal = AddTotal + GiftInfo.addLoveNum;
    end
    --self.TxtNumTotal:SetText(AddTotal)
    --self.TxtExp:SetText(AddTotal)

    local Tmp = UE4.UItemLibrary.GetItemTemplateByGDPL(Gift[1],Gift[2],Gift[3],Gift[4])
    if Tmp then
        self.TxtPresentName:SetText(Text(Tmp.I18N))
    end

    self:UpdateCollectPercent()

    if CollectState ~= 2 then
        WidgetUtils.Collapsed(self.TxtExp)
        WidgetUtils.Collapsed(self.TxtExpPlus)
        self.Button:SetIsEnabled(false)
        self:SetAddTarget(0)
    else
        WidgetUtils.SelfHitTestInvisible(self.TxtExp)
        WidgetUtils.SelfHitTestInvisible(self.TxtExpPlus)
        self.Button:SetIsEnabled(true)
        self:SetAddTarget(AddTotal)
    end
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


--增加好感度进度条表现
--ShowTargetxxx表示目前显示的预览等级

function tbClass:SetAddTarget(AddExp)
    self.TxtExp:SetText('+'..AddExp)

    self.NowTargetLevel = self.NowLevel;
    local LevelUpNeedPoint,HasNextLevel = HouseGirlLove:GetGirlLevelUpNeedPoint(self.NowLevel)
    if not HasNextLevel then
        return
    end
    self.NowTargetPoint = self.NowPoint + AddExp
    self.NowShowTargetLevel = self.NowShowTargetLevel or self.NowLevel;
    self.NowShowTargetPoint = self.NowShowTargetPoint or self.NowPoint;


    while (self.NowTargetPoint >= LevelUpNeedPoint and HasNextLevel) do
        self.NowTargetLevel = self.NowTargetLevel + 1
        self.NowTargetPoint = self.NowTargetPoint - LevelUpNeedPoint;
        LevelUpNeedPoint,HasNextLevel = HouseGirlLove:GetGirlLevelUpNeedPoint(self.NowTargetLevel)
    end

    self.NeedDynamicRefresh = 0;    
    if self.NowTargetLevel > self.NowShowTargetLevel then
        self.NeedDynamicRefresh = 2;
    elseif self.NowTargetLevel < self.NowShowTargetLevel then
        self.NeedDynamicRefresh = 1;
    elseif self.NowTargetLevel == self.NowShowTargetLevel then
        if self.NowTargetPoint > self.NowShowTargetPoint then
            self.NeedDynamicRefresh = 2
        elseif self.NowTargetPoint < self.NowShowTargetPoint then
            self.NeedDynamicRefresh = 1
        end
    end
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.NeedDynamicRefresh or self.NeedDynamicRefresh < 1 then
        return
    end

    --预览等级变少
    if self.NeedDynamicRefresh == 1 then
        if self.NowShowTargetLevel == self.NowTargetLevel then
            self.NowShowTargetPoint = Lerp(self.NowShowTargetPoint, self.NowTargetPoint, self.RefreshSpeed)
        else
            self.NowShowTargetPoint = Lerp(self.NowShowTargetPoint, 0, self.RefreshSpeed)
            if self.NowShowTargetPoint < 5 then
                self.NowShowTargetLevel = self.NowShowTargetLevel - 1;
                self.NowShowTargetPoint = HouseGirlLove:GetGirlLevelUpNeedPoint(self.NowShowTargetLevel)
            end
        end
    end

    if self.NeedDynamicRefresh == 2 then
        if self.NowShowTargetLevel == self.NowTargetLevel then
            self.NowShowTargetPoint = Lerp(self.NowShowTargetPoint, self.NowTargetPoint, self.RefreshSpeed) 
        else
            local MaxPointNowLevel = HouseGirlLove:GetGirlLevelUpNeedPoint(self.NowShowTargetLevel)
            self.NowShowTargetPoint = Lerp(self.NowShowTargetPoint, MaxPointNowLevel, self.RefreshSpeed)
            if self.NowShowTargetPoint > MaxPointNowLevel - 5 then
                self.NowShowTargetLevel = self.NowShowTargetLevel + 1;
                self.NowShowTargetPoint = 0;
            end
        end
    end

    if math.abs(self.NowShowTargetPoint - self.NowTargetPoint) <= 5 and self.NowTargetLevel == self.NowShowTargetLevel then
        self.NeedDynamicRefresh = 0;
        self.NowShowTargetPoint = self.NowTargetPoint;
        self.NowShowTargetLevel = self.NowTargetLevel;
    end

    self.Heart:Display(self.NowShowTargetLevel)
    if self.NowShowTargetLevel == self.NowLevel then
        WidgetUtils.SelfHitTestInvisible(self.BarExp)
    else
        WidgetUtils.Collapsed(self.BarExp)
    end
    local NowMaxPoint = HouseGirlLove:GetGirlLevelUpNeedPoint(self.NowShowTargetLevel)
    self.BarNextExp:SetPercent((self.NowShowTargetPoint or 0) / (NowMaxPoint or 1)) 
end

return tbClass;