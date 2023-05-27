local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self:DoClearListItems(self.List)
    self.Factory = Model.Use(self)
    self.SlIndex = nil
    self.NumParam = 0;
end

function tbClass:CanEsc( ... )
    return false
end

function tbClass:OnOpen(tbParams)
    self.HasDoneAction = false;
    self.tbParams = self.tbParams or tbParams;
    self:ExhaleMouse(true)
    if not IsValid(self.tbParams.TaskActor) or not IsValid(self.tbParams.TaskActor.TaskDataComponent) then
        return
    end
    local TaskDataCom = self.tbParams.TaskActor.TaskDataComponent

    if not self.tbParams.Actions or not self.tbParams.TxtKeys or not self.tbParams.MoneyNums or self.tbParams.Actions:Length() ~= self.tbParams.TxtKeys:Length() or self.tbParams.Actions:Length() ~= self.tbParams.MoneyNums:Length() then
        return
    end
    local MonsterWaveNum = TaskDataCom:GetOrAddValue('MonsterWave')
    self.Num:SetText(MonsterWaveNum)

    if MonsterWaveNum >= DefendLogic.GetMaxWave() then
        WidgetUtils.SelfHitTestInvisible(self.Image_593)
        WidgetUtils.SelfHitTestInvisible(self.Image_15)
        WidgetUtils.SelfHitTestInvisible(self.TxtRecord)
    else
        WidgetUtils.Collapsed(self.Image_593)
        WidgetUtils.Collapsed(self.TxtRecord)
        WidgetUtils.Collapsed(self.Image_15)
    end

    self.NowMoney = TaskDataCom:GetOrAddValue('Money')

    self.CoinNum:SetText(self.NowMoney)

    for i=1,self.tbParams.Actions:Length() do
        local Action = self.tbParams.Actions:Get(i)
        local UIKey = self.tbParams.TxtKeys:Get(i)
        local MoneyNum = self.tbParams.MoneyNums:Get(i)
        local tbAction = {};
        tbAction['Action'] = Action;
        tbAction['TxtKey'] = UIKey;
        tbAction['NeedMoney'] = MoneyNum;
        tbAction['NowMoney'] = function ()
            self.NowMoney = TaskDataCom:GetOrAddValue('Money')
            return self.NowMoney;
        end
        tbAction['Index'] = i
        tbAction['NowIndex'] = function ()
            return self.SlIndex; 
        end

        tbAction['IsSoldOut'] = function ( Index )
            return (self.tbSoldOut or {})[Index] ~= nil
        end
        tbAction['SlFunc'] = function ( Index,NumParam)
            self.SlIndex = Index
            self.NumParam = NumParam;
            --self.List:RegenerateAllEntries();
            local Widgets = self.List:GetDisplayedEntryWidgets();
            for i=1,Widgets:Length() do
                local Widget = Widgets:Get(i)
                if IsValid(Widget) then
                    Widget:Update()
                end
            end
        end

        self.List:AddItem(self.Factory:Create(tbAction))
    end

    BtnClearEvent(self.BtnOK)
    BtnAddEvent(self.BtnOK,function ()
        if self.HasDoneAction then
            self.tbParams.ChooseContinue()
        else
            UI.Open("MessageBox", Text("ui.Defense_Shop_Continue"), function ()
                self.tbParams.ChooseContinue()
            end)
        end
    end)

    BtnClearEvent(self.BtnNo)
    BtnAddEvent(self.BtnNo,function ()
        UI.Open("MessageBox", Text("ui.Defense_Shop_Quit"), function ()
            self.tbParams.ChooseExit()
        end)
    end)

    BtnClearEvent(self.BtnConfirm)
    BtnAddEvent(self.BtnConfirm,function ()
        if not self.SlIndex then
            UI.ShowTip(Text('ui.DefendShopUnSelected'))
            return
        end
        self:DoAction(self.tbParams.Node)
    end)
end

function tbClass:DoAction(Node)
    if not self.tbParams or not self.SlIndex then
        return
    end
    if not self.tbParams.Actions:IsValidIndex(self.SlIndex) or not self.tbParams.MoneyNums:IsValidIndex(self.SlIndex) then
        return
    end

    local SlAction = self.tbParams.Actions:Get(self.SlIndex)
    local NeedMoney = self.tbParams.MoneyNums:Get(self.SlIndex)
    local TaskActor = self.tbParams.TaskActor
    --先扣钱然后执行行为
    local TaskActionSubSystem = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(self,UE4.UTaskActionSubSystem)
    if not IsValid(TaskActionSubSystem) or not IsValid(TaskActor) or not IsValid(TaskActor.TaskDataComponent) then
        return
    end
    local NowMoney = TaskActor.TaskDataComponent:GetOrAddValue('Money')
    if NowMoney >= NeedMoney then
        TaskActor.TaskDataComponent:AddValue('Money',-1*NeedMoney)
        if SlAction.Action == UE4.ELevelTaskAction.ReviveGamePlayer then
            SlAction.NumParam = self.NumParam - 1
            TaskActionSubSystem:DoActionByInfoWithNode(SlAction,Node)
            --弹复活提示
            local Controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
            if IsValid(Controller) then
                local lineup = Controller:GetPlayerCharacters()
                local ShowNum = SlAction.NumParam + 1
                if lineup:Length() >= (ShowNum) and (ShowNum >= 1) then
                    local Character = lineup:Get(ShowNum)
                    if Character then
                        UI.ShowTip(string.format(Text('ui.Defense_LevelShop_RebirthSuccess'),Text(Character:K2_GetPlayerMember():I18N())))
                    end
                end
            end
        else
            TaskActionSubSystem:DoActionByInfoWithNode(SlAction,Node)
        end
    end

    self.HasDoneAction = true;

    self.tbSoldOut = self.tbSoldOut or {}

    if SlAction.Action == UE4.ELevelTaskAction.ReviveGamePlayer then
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
                self.tbSoldOut[self.SlIndex] = 1
            end
        end
    else
        self.tbSoldOut[self.SlIndex] = 1
    end

    DefendLogic:BillCacheLog(self.SlIndex)

    if SlAction.Action ~= UE4.ELevelTaskAction.ReviveGamePlayer then
        UI.ShowTip(Text('ui.Defense_LevelShop_BuySuccess'))
    end

    self.SlIndex = nil;
    self.NowMoney = TaskActor.TaskDataComponent:GetOrAddValue('Money')
    self.CoinNum:SetText(self.NowMoney)
    --self.List:RegenerateAllEntries();
    local Widgets = self.List:GetDisplayedEntryWidgets();
    for i=1,Widgets:Length() do
        local Widget = Widgets:Get(i)
        if IsValid(Widget) then
            Widget:Update()
        end
    end
end

function tbClass:OnClose()
    self:ExhaleMouse(false)
end

function tbClass:ExhaleMouse(bShow)
    RuntimeState.ChangeInputMode(bShow)
end

function tbClass:CanEsc()
    return false
end

return tbClass