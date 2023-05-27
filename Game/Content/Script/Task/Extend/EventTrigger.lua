-- ========================================================
-- @File    : EventTrigger.lua
-- @Brief   : 事件触发器
-- @Author  :
-- @Date    :
-- ========================================================

local EventTrigger = Class()

function EventTrigger:DoEvents()
    for i = 1, self.Events:Length() do
        self.Events:Get(i):DoEvent()
    end
end

function EventTrigger:ReceiveActorBeginOverlap(OtherActor)
    if self:IsValid(OtherActor) then
        self:DoEvents()
        self.bTrigger = true
    end
end

---目标是否有效
function EventTrigger:IsValid(InActor)
    ---@param Character AGameCharacter
    local Character = InActor:Cast(UE4.AGameCharacter)
    return Character ~= nil and not self.bTrigger
end

return EventTrigger
