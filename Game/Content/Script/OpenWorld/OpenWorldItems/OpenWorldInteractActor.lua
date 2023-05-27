-- ========================================================
-- @File    : OpenWorldInteractActor.lua
-- @Brief   : 开放世界可交互物
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class()

function tbClass:Client_OnInteracting()
    local WhoInteractActor = self.Data.WhoInteract
    if not WhoInteractActor:IsValid() or not WhoInteractActor:IsLocalPlayerController() then
        return
    end
    local Pawn = WhoInteractActor:K2_GetPawn()
    if Pawn == nil or not Pawn:IsValid() then
        return
    end
    local AnimInstance = Pawn:GetGameAnimInstance()
    if AnimInstance == nil or not AnimInstance:IsValid() then
        return
    end
    local AnimMontage = AnimInstance:GetMontageByVariableName("Act_Montage")
    if AnimMontage == nil or not AnimMontage:IsValid() then
        return
    end
    if self.bForceInteraction then
        WhoInteractActor:LockControl(true, true, true, true, true, true, true, true)
    end
    AnimInstance:Montage_Play(AnimMontage)

    local Interaction = self:GetInteractionWidget()
    if not Interaction then
        return
    end
    WidgetUtils.SelfHitTestInvisible(Interaction)
    local PerformTime = self.Cfg_InteractTime * self.TimeScale
    Interaction:StartProgress(PerformTime)

    self.UpdateRedTimer = UE4.UKismetSystemLibrary.K2_SetTimerDelegate({self, function()
        AnimInstance:Montage_Stop(0.25, AnimMontage)
        WidgetUtils.Hidden(Interaction)
        Interaction.Progress:SetPercent(0)
        if self.bForceInteraction then
            WhoInteractActor:UnLockControl()
        end
    end}, PerformTime, false)
end

---进入
function tbClass:OnTrigger_Client(bIsBeginOverlap, OtherActor)
    self:TriggerHandle(bIsBeginOverlap, OtherActor)
end

function tbClass:TriggerHandle(bIsBeginOverlap, OtherActor)
    if self:IsLocalPlayer(OtherActor) then
        if bIsBeginOverlap then
            if self:CanInteractRaw() then 
                EventSystem.Trigger(Event.OnInteractListAddItem, self.InteractWidgetClass ,1,self)
            end
        else
            EventSystem.Trigger(Event.EndOverlapTaskBox, self)
        end
    end
end

function tbClass:IsLocalPlayer(OtherActor)
    if IsPlayer(OtherActor) and OtherActor:GetController() and OtherActor:GetController():IsLocalController() then
        return true
    end
    return false
end

return tbClass
