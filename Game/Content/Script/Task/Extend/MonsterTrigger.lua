-- ========================================================
-- @File    : MonsterTrigger.lua
-- @Brief   : 怪物触发器
-- @Author  :
-- @Date    :
-- ========================================================

---@class MonsterTrigger
local MonsterTrigger = Class()

MonsterTrigger.bActive = false
MonsterTrigger.BindItem = nil

---激活
function MonsterTrigger:DoActive(InBindItem)
    self.BindItem = InBindItem
    self.bActive = true
end

---重置
function MonsterTrigger:Reset()
    self.BindItem = nil
    self.bActive = false
end

function MonsterTrigger:ReceiveActorBeginOverlap(OtherActor)
    if self.bActive then
        local Character = OtherActor:Cast(UE4.AGameAICharacter)
        if IsAI(Character) then
            if self.BindItem then
                self.BindItem:BeginOverlap()
                self:OnTrigger()
                self:SpawnDisapperEffect(Character:K2_GetActorLocation())
                Character:Leave()
                local Data = Character:GetComponentByClass(UE4.UUMGDataBaseComponent)
                if IsValid(Data) then
                    Data:SetActiveHpComponent(false)
                end
            end
        end
    end
end

return MonsterTrigger
