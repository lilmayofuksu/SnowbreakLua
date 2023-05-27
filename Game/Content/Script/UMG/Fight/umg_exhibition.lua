-- ========================================================
-- @File    : umg_exhibition.lua
-- @Brief   : 联机战斗结束时进行角色展示
-- ========================================================

--- @class umg_exhibition : UI_Template
local umg_exhibition = Class("UMG.BaseWidget");

function umg_exhibition:OnInit()
    self.pPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    self.ListFactory = Model.Use(self)
    self.FuncNext = function ()
        UI.Close(self);
        UI.Open('OnlineSettlement');
    end

    -- 进入下一步处理
    self.BtnOk.OnClicked:Add(self, self.FuncNext);
end

function umg_exhibition:OnOpen()
    self:ExhaleMouse(true)
    self:DoClearListItems(self.ListNum)

    local TotalValue = 0
    local localPlayer = self:GetOwningPlayerPawn();
    local gameState = UE4.UGameplayStatics.GetGameState(localPlayer);
    local myState = UE4.UGameLibrary.GetPlayerState(self:GetOwningPlayer())
    local myLevel = myState.AttackLevel or 1 --pState:GetCardMaxLevel()
    local playerArray = gameState.PlayerArray

    for i=1,3 do
        if i <= playerArray:Length() then 
            local pState = playerArray:Get(i)
            local level = pState.AttackLevel or 1
            TotalValue = TotalValue + pState:GetDamage() / math.max(1, UE4.UGMLibrary.GetHealth(GetGameIns(), 4001, pState.AttackLevel or 1))
        end
    end
    
    
    self.TxtName:SetText(myState:GetPlayerName()) 
    local nTotalDamage = myState:GetDamage()
  
    local nTime = math.ceil(UE4.AGameTaskActor.GetGameTaskActor(GetGameIns()):GetLevelTime())
    local nMin = math.floor(nTime / 60) 
    local nSec = nTime % 60
    local nPer = 100 * (nTotalDamage / math.max(1, UE4.UGMLibrary.GetHealth(GetGameIns(), 4001, myLevel))) / math.max(1, TotalValue)

    local tbPlayerInfo = {
        { sName = "ui.TxtOnlineEnd1", nData = nTotalDamage, nIcon = 1002002},
        { sName = "ui.TxtOnlineEnd2", nData = string.format("%.2f%%", nPer), nIcon = 1002001},
        { sName = "ui.TxtOnlineEnd3", nData = string.format(Text("ui.TxtOnlineEnd4"), nMin, nSec), nIcon = 1002000}
    }

    for _, one in ipairs(tbPlayerInfo) do
        local pObj = self.ListFactory:Create(one)
        self.ListNum:AddItem(pObj)
    end

    self.Countdown = 15
    self.TxtTime_1:SetText(self.Countdown)
    self.CurrentCountdown = 0

    local tb = {
        self.Player1,
        self.Player2,
        self.Player3
    }

    local pIdx = 2
    for i,v in ipairs(tb) do
        if i <= playerArray:Length() then 
            local pState = playerArray:Get(i)
            if pState == myState then
                tb[1]:Init(pState:GetPlayerName())
            else
                tb[pIdx]:Init(pState:GetPlayerName())
                pIdx = pIdx + 1;
            end
        else
            v:SetVisibility(UE4.ESlateVisibility.Collapsed);
        end
    end
end

function umg_exhibition:OnClose()
    --self:ExhaleMouse(false)
end

function umg_exhibition:ExhaleMouse(bShow)
    RuntimeState.ChangeInputMode(bShow)
end

function umg_exhibition:Tick(MyGeometry, InDeltaTime)
    self.CurrentCountdown = self.CurrentCountdown + InDeltaTime
    if self.CurrentCountdown >= self.Countdown then
        UI.Close(self);
        UI.Open('OnlineSettlement');
        return
    else
        self.TxtTime_1:SetText(math.ceil(self.Countdown - self.CurrentCountdown))
    end
    local tb = {
        self.Player1,
        self.Player2,
        self.Player3
    }

    local localPlayer = self:GetOwningPlayerPawn();
    local gameState = UE4.UGameplayStatics.GetGameState(localPlayer);
    local playerArray = gameState.PlayerArray;
    local myState = UE4.UGameLibrary.GetPlayerState(self:GetOwningPlayer());
    local pIdx = 2;
    for i,v in ipairs(tb) do
        if i <= playerArray:Length() then
            local pState = playerArray:Get(i);
            local location = UE4.UAbilityFunctionLibrary.GetSocketLocationFromActor("Multi_Name01", pState.PawnPrivate);
            local slot = nil;
            if pState == myState then
                slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(tb[1]);
            else
                slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(tb[pIdx]);
                pIdx = pIdx + 1;
            end
            local ScreenPos = UE4.FVector2D();
            UE4.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(self.pPlayer, location, ScreenPos, true);
            slot:SetPosition(ScreenPos)

            --- print('Location is ', location, ' --->>> ', ScreenPos, ' ---- ', pState)
            --- slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.PosImg);
            --- slot:SetPosition(ScreenPos)
        end
    end
end

return umg_exhibition;
