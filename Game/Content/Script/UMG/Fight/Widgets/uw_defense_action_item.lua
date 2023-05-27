local tbClass = Class("UMG.SubWidget")

function tbClass:Initialize()
    self.NumParam = nil
end

function tbClass:OnListItemObjectSet(pObj)
    local tbParam = pObj and pObj.Data;
    self.Index = tbParam.Index;

    if tbParam.Index == tbParam.NowIndex() then
        WidgetUtils.SelfHitTestInvisible(self.Select)
    else
        WidgetUtils.Collapsed(self.Select)
    end

    self.TxtName:SetText(Text(tbParam.TxtKey))
    self.Cost:SetText(tbParam.NeedMoney)
    WidgetUtils.SelfHitTestInvisible(self.LimitNum)

    local SetNumParamFunc = function (Num)
        self.NumParam = Num
        tbParam.SlFunc(tbParam.Index,self.NumParam or 0)
    end

    BtnClearEvent(self.BtnSelect)
    local IsValidBtn = true;
    local IsSoldOut = false;
    local MoneyIsNotEnough = false;
    if tbParam.NowMoney() < tbParam.NeedMoney then
        IsValidBtn = false;
        MoneyIsNotEnough = true;
    end
    self.tbParam = tbParam

    if tbParam.Action.Action == UE4.ELevelTaskAction.ReviveGamePlayer then
        local Controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
        if IsValid(Controller) then
            local HasDead = false;
            local lineup = Controller:GetPlayerCharacters()
            for i = 1, lineup:Length() do
                local Character = lineup:Get(i)
                if Character and Character:IsDead() then
                    self.NumParam = self.NumParam or i
                    HasDead = true;
                end
            end
            if not HasDead then
                IsValidBtn = false;
            end
        end
    end

    if tbParam.Action.Action == UE4.ELevelTaskAction.ReSpawnDevice then
        local HasNotValid = false;
        local DeviceArray = UE4.UGameplayStatics.GetAllActorsOfClassWithTag(self,UE4.AItemSpawner_CanSave,tbParam.Action.Param1)
        for i=1,DeviceArray:Length() do
            if not DeviceArray:Get(i):GetIsValid() then
                HasNotValid = true
            end
        end
        if not HasNotValid then
            IsValidBtn = false
        end
    end

    if IsValidBtn then
        self.BtnSelect:SetIsEnabled(true)
        BtnAddEvent(self.BtnSelect,function ()
            if tbParam.Action.Action == UE4.ELevelTaskAction.ReviveGamePlayer then
                UI.Open('DefendSelectRole',SetNumParamFunc)
            else
                tbParam.SlFunc(tbParam.Index,self.NumParam or 0)
            end
        end)
    else
        if MoneyIsNotEnough then
            BtnAddEvent(self.BtnSelect,function ()
                UI.ShowTip(Text('ui.Defense_Shop_LackMoney'))
            end)
        elseif not IsSoldOut then
        --self.BtnSelect:SetIsEnabled(false)
            BtnAddEvent(self.BtnSelect,function ()
                if tbParam.Action.Action == UE4.ELevelTaskAction.ReviveGamePlayer then
                    UI.ShowTip(Text('ui.Defense_LevelShop_NoDie'))
                end
                if tbParam.Action.Action == UE4.ELevelTaskAction.ReSpawnDevice then
                    UI.ShowTip(Text('ui.Defense_LevelShop_ItemFull'))
                end
            end)
        end
    end

    self:Update()
end

function tbClass:Update()
    local tbParam = self.tbParam;
    if not tbParam then
        return
    end
    if tbParam.IsSoldOut(self.Index) and not WidgetUtils.IsVisible(self.SellOut) then
        IsValidBtn = false;
        IsSoldOut = true;
        self:PlayAnimation(self.Animation_SellOut)
        WidgetUtils.SelfHitTestInvisible(self.SellOut)

        BtnClearEvent(self.BtnSelect)
    end

    if not tbParam.IsSoldOut(self.Index) then
        WidgetUtils.Collapsed(self.SellOut)
    end

    if tbParam.Index == tbParam.NowIndex() then
        WidgetUtils.SelfHitTestInvisible(self.Select)
    else
        WidgetUtils.Collapsed(self.Select)
    end
end

return tbClass