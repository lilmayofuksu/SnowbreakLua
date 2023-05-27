-- ========================================================
-- @File    : LevelCameraFocus.lua
-- @Brief   :
-- @Author  :
-- @Date    :
-- ========================================================

local LevelCameraFocus = Class()
-- function LevelCameraFocus:Construct()
--     print("LevelCameraFocus:Construct")
--     self.LevelTaskLibrary = UE4.UClass.Load(
--             '/Game/Blueprints/LevelTask/Utils/BP_LevelTaskLibrary.BP_LevelTaskLibrary_C'
--         )
-- end
LevelCameraFocus.SkillEndHandle = nil
LevelCameraFocus.PlayerController = nil
function LevelCameraFocus:HideWidgets(HideFlag, Widgets)
    self.LevelTaskLibrary = UE4.UClass.Load(
        '/Game/Blueprints/LevelTask/Utils/BP_LevelTaskLibrary.BP_LevelTaskLibrary_C'
    )
    if self.LevelTaskLibrary then
        if not HideFlag and Widgets ~= nil then
            -- print("LevelCameraFocus:HideWidgets RestoreAllUserWigdets")
            self.LevelTaskLibrary.RestoreAllUserWidgets(Widgets)
        elseif HideFlag then
            -- print("LevelCameraFocus:HideWidgets HideAllUserWigdets")
            self.RelateWidgets = self.LevelTaskLibrary.HideAllUserWidgets()
        end
    end

end

function LevelCameraFocus:OnEnd()
    if self.SkillEndHandle ~= nil then
        EventSystem.Remove(self.SkillEndHandle)
        self.SkillEndHandle = nil
    end
end

function LevelCameraFocus:OnSkillEndCheck()
    self.PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    if self.PlayerController and self.PlayerController:IsInAnimSkill() == false then
        if self.SkillEndHandle ~= nil then
            EventSystem.Remove(self.SkillEndHandle)
            self.SkillEndHandle = nil 
        end
        print("LevelCameraFocus:OnSkillEndCheck Not InAnimSkill, continue camera focus!")
        return true
    elseif self.PlayerController and self.PlayerController:IsInAnimSkill() then
        if self.SkillEndHandle == nil then
            print("LevelCameraFocus:OnSkillEndCheck InAnimSkill, wait skill end!")
            self.SkillEndHandle = EventSystem.On(Event.OnSkillEnd, function(ActorAbility, id)
                local GamePlayer = ActorAbility:GetOwner():Cast(UE4.AGamePlayer)
                if IsValid(GamePlayer) and self.PlayerController and self.PlayerController:IsInAnimSkill(id) == false then
                    print("LevelCameraFocus:OnSkillEndCheck InAnimSkill, skill end, continue camera focus!", id)
                    self:CameraFocus()
                    EventSystem.Remove(self.SkillEndHandle) 
                    self.SkillEndHandle = nil 
                    return true
                end
            end)
            return false
        end
    end
end

function LevelCameraFocus:DefferRestore(DelayTime, Widgets)
    -- print("LevelCameraFocus:DefferRestore~~~")
    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                -- print("LevelCameraFocus:DefferRestore~~~CallBack")
                self:HideWidgets(false, Widgets)
            end
        },
        DelayTime,
        false
    )
end
return LevelCameraFocus