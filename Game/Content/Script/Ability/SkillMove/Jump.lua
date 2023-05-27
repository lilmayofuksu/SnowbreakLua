-- ========================================================
-- @File    : Jump.lua
-- @Brief   : 技能跳跃
-- @Author  : Xiong
-- @Date    : 2020-05-07
-- ========================================================

---@class USkillMove_Jump:USkillMove
local Jump = Class()

function Jump:IsUsedToAddVelocityInsteadOverride()
    return false;
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function Jump:OnMoveTick(DeltaTime, Friction, Fluid, BrakingDeceleration, MovementComp)
end

function Jump:OnMoveTickCheck(DeltaTime)
    local MovementComp = self:GetMovementComp();
    self.ActiveTime = self.ActiveTime + DeltaTime
    if self:CheckJump(MovementComp) == true then
        self:MoveFinish(MovementComp);
    end
end

function Jump:OnMoveEnd(MovementComp)
    local bOptimizeNavWalk = false
    local OwnerChar = MovementComp:GetOwner():Cast(UE4.AGameCharacter)
    if OwnerChar ~= nil then
        if OwnerChar:IsOptimizeNavWalk() == true then
            bOptimizeNavWalk = true
        end
    end

    if bOptimizeNavWalk == false then
        MovementComp:SetMovementMode(UE4.EMovementMode.MOVE_Walking)
    else
        MovementComp:SetMovementMode(UE4.EMovementMode.MOVE_NavWalking)
    end
    MovementComp.GravityScale = self.Gravity;
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end

function Jump:CheckJump(MovementComp)
    local OwnerChar = MovementComp:GetOwner():Cast(UE4.AGameCharacter)
    if OwnerChar ~= nil then
        local Cap = OwnerChar.CapsuleComponent;
        local FloorResult = MovementComp:K2_FindFloor(Cap:K2_GetComponentLocation());

        if FloorResult.bWalkableFloor == true and self.ActiveTime >= self.JumpCostTime * 0.5 then
            print("Jump End To Ground  ", FloorResult.HitResult.Component:GetName())
            return true;
        end
    end

    return false
end


return Jump
