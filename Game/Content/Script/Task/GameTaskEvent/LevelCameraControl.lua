-- ========================================================
-- @File    : LevelCameraFocus.lua
-- @Brief   :
-- @Author  :
-- @Date    :
-- ========================================================

local LevelCameraControl = Class()

LevelCameraControl.SkillEndHandle = nil
LevelCameraControl.QteEndHandle = nil
function LevelCameraControl:OnRemoveSkillEnd()
    print("LevelCameraControl:OnRemoveSkillEnd1", self, self.SkillEndHandle)
    if self.SkillEndHandle ~= nil then
        EventSystem.Remove(self.SkillEndHandle)
        self.SkillEndHandle = nil
        print("LevelCameraControl:OnRemoveSkillEnd2", self)
    end
end

function LevelCameraControl:OnSkillEndCheck()
    self.PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    print("LevelCameraControl:OnSkillEndCheck", self, self.PlayerController, self.PlayerController:IsInAnimSkill(), self.PlayerController.bIsInQTESwitch)
    
    if self.PlayerController ~= nil then
        if self.PlayerController:IsInAnimSkill() == false then
            if self.SkillEndHandle ~= nil then
                EventSystem.Remove(self.SkillEndHandle)
                print("LevelCameraControl:OnSkillEndCheck Not InAnimSkill, remove skill handle", self)
            end
            print("LevelCameraControl:OnSkillEndCheck Not InAnimSkill, continue camera control!", self)
            return true
        elseif self.PlayerController:IsInAnimSkill() == true and self.PlayerController.bIsInQTESwitch == false then -- 非QTE技能
            if self.SkillEndHandle == nil then
                print("LevelCameraControl:OnSkillEndCheck InAnimSkill, wait skill end!")
                self.SkillEndHandle = EventSystem.On(Event.OnSkillEnd, function(ActorAbility, id)
                    local GamePlayer = ActorAbility:GetOwner():Cast(UE4.AGamePlayer)
                    if IsValid(GamePlayer) and self.PlayerController and self.PlayerController:IsInAnimSkill(id) == false then
                        print("LevelCameraControl:OnSkillEndCheck InAnimSkill, skill end, continue camera control!", id, self)
                        self:CameraControl()
                        return true
                    end
                end)
                return false
            end
        elseif self.PlayerController.bIsInQTESwitch ==  true then -- QTE技能
            --if self.QteEndHandle == nil then
                print("LevelCameraControl:OnSkillEndCheck InQTESkill, wait QTE end!")
                --self.PlayerController:CancleAllInAnimSkill()
                --UE4.Timer.Add(0.5, function()
                --    print("LevelCameraControl:OnSkillEndCheck InQTESkill, QTE end, continue camera control!", id, self)
                --    self:CameraControl()
                --end)
                return false
            --end
        end
    end
end

return LevelCameraControl
