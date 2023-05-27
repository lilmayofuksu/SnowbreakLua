-- ========================================================
-- @File    : uw_fight_interactlist.lua
-- @Brief   : 交互列表
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_interactlist = Class("UMG.SubWidget")

function uw_fight_interactlist:Construct()
    self:RegisterEvent(
        Event.OnInteractListAddItem,
        function(WidgetClass, Order, InItemOwner)
            self:AddInteractItem(WidgetClass, Order, InItemOwner)
            self:RefreshKeyboardText()
        end
    )

    self:RegisterEvent(
        Event.OnInteractListRemoveItem,
        function(InItemOwner)
            self:RemoveInteractItemOfOwner(InItemOwner)
        end
    )

    local OwnerPlayer = self:GetOwningPlayer():Cast(UE4.AGamePlayerController)
    ---绑定PlayerController交互通知
    if OwnerPlayer then
        OwnerPlayer.OnOpenBox:Add(
            self,
            function(ThisPtr, PlayerController)
                if self.ListInteractItems:GetChildrenCount() > 0 then
                    self.ListInteractItems:GetChildAt(0):TriggerInteract(PlayerController)
                end
            end
        )
    end

    local OwnerCharacter = self:GetOwningPlayer():GetCurrentChar():Cast(UE4.AGameCharacter)
    if OwnerCharacter then
        OwnerCharacter.OnNotifyPlayerActionFlay:Add(
            self,
            function(ThisPtr, _, ActionState, SetFlag)
                if ActionState == UE4.ECharacterActionState.Dodge then
                    self:HideOrShow(SetFlag)--Set true 进入闪避状态，hide. False 离开闪避状态，show.
                end
            end
        )
    end

    self:RegisterEvent(Event.OnInputTypeChange, function()
        self:RefreshKeyboardText()
    end)
end

function uw_fight_interactlist:RefreshKeyboardText()
    if not IsMobile() then
        return
    end
    local PlayerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
    if PlayerController then
        for i = 1, self.ListInteractItems:GetChildrenCount() do
            local Obj = self.ListInteractItems:GetChildAt(i - 1)
            if Obj ~= nil then
                if PlayerController.LastInputGamepad then
                    WidgetUtils.SelfHitTestInvisible(Obj.PanelKey)
                else
                    WidgetUtils.Hidden(Obj.PanelKey)
                end
            end
        end
    end
end

function uw_fight_interactlist:OnDestruct()
    EventSystem.Remove(self.HideHook)
end

function uw_fight_interactlist:HideOrShow(ShowFlag)
    if self.ListInteractItems:GetChildrenCount() > 0 then
        -- print("uw_fight_interactlist:", ShowFlag)
        for i = 1, self.ListInteractItems:GetChildrenCount() do
            local Obj = self.ListInteractItems:GetChildAt(i - 1)
            if Obj ~= nil then
                if ShowFlag then
                    WidgetUtils.Collapsed(Obj)
                else
                    WidgetUtils.SelfHitTestInvisible(Obj)
                end
            end
        end
    end
end


return uw_fight_interactlist
