-- ========================================================
-- @File    : uw_chess_tpl_interaction.lua
-- @Brief   : 交互模板
-- ========================================================

local view = Class("UMG.SubWidget")

function view:Construct()
    self.playerController = UE4.UGameplayStatics.GetPlayerController(self, 0)   
    self.canvasRoot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Root)

    BtnAddEvent(self.BtnInteraction, function() self:OnBtnClickInteraction() end)
end

function view:SetContent(actor)
    self.targetActor = actor
    self.height = actor:GetHeight() * 100
    WidgetUtils.Collapsed(self.Root)

    if actor:HasTag("box") then 
        self.TxtValue:SetText(Text("ui.TxtChessPush"))
    else 
        self.TxtValue:SetText(Text("ui.TxtDormRoomInteract"))
    end

    self:Update(0)
    UE4.Timer.Add(0.1, function() 
        WidgetUtils.Visible(self.Root)
    end)
end

function view:Update(deltaSecond)
    self.parentGeometry = self.Root:GetParent():GetCachedGeometry()
    local location = self.targetActor:K2_GetActorLocation();
    location.Z = location.Z + self.height
    local ret, screenPos = self.playerController:ProjectWorldLocationToScreen(location)
    if ret then 
        local localPos = UE4.USlateBlueprintLibrary.ScreenToWidgetLocal(self, self.parentGeometry, screenPos)
        self.canvasRoot:SetPosition(localPos)
    end
end

function view:OnBtnClickInteraction()
    ChessTools:ApplyInteraction(self.targetActor)
end



return view