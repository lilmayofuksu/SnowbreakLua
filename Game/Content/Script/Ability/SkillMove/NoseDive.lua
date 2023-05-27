-- ========================================================
-- @File    : NoseDive.lua
-- @Brief   : 技能跳跃
-- @Author  : Xiong
-- @Date    : 2020-09-24
-- ========================================================

---@class USkillMove_NoseDive:USkillMove
local NoseDive = Class()

function NoseDive:IsUsedToAddVelocityInsteadOverride()
    return false;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function NoseDive:OnMoveStart(Launcher, MovementComp)
    MovementComp.GravityScale = 0;
    MovementComp:SetMovementMode(UE4.EMovementMode.Move_Flying)
end

function NoseDive:CheckBlock(MovementComp)
    local OwnerChar = MovementComp:GetOwner():Cast(UE4.AGameCharacter)
    if OwnerChar ~= nil then
        local Cap = OwnerChar.CapsuleComponent;
        local FloorResult = MovementComp:K2_FindFloor(Cap:K2_GetComponentLocation());

        if FloorResult.bWalkableFloor == true then
            return true;
        end
    end

    return false
end


function NoseDive:OnMoveEnd(MovementComp)
    self:DeActiveSpawnedByEmitter()
    MovementComp:SetMovementMode(UE4.EMovementMode.Move_Falling)
    MovementComp.GravityScale = 1;

    self:Destroy();
end

return NoseDive
