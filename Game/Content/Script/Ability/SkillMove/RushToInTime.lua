-- ========================================================
-- @File    : RushToInTime.lua
-- @Brief   : 技能冲锋指定目标,持续指定时间，中间不会停止
-- @Author  : Xiong
-- @Date    : 2020-05-28
-- ========================================================

---@class USkillMove_RushToInTime:USkillMove
local RushToInTime = Class();
function RushToInTime:IsUsedToAddVelocityInsteadOverride()
    return false;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function RushToInTime:OnMoveStart(Launcher , MovementComp)

     --- Param1 : 冲锋速度
    --- Param2 : 冲锋最长持续时间
    local RushSpeed = self:GetParamfloatValue(0); 
    local RushTime = self:GetParamfloatValue(1); 

    if self.SpawnedBy ~= nil then
        self.SpawnedBy.bKeepRunning = true;
    end
    local Offset;
    if self.MoveTarget ~= nil then
        Offset = self:GetAimTargetLocation() - Launcher:K2_GetActorLocation() 
    else
        Offset = Launcher:GetActorForwardVector()* 2000;;
    end
    
    local Distance = Offset:Size()
    local Direction = Offset
    Direction = UE4.UKismetMathLibrary.Normal(Direction)
    local DirectionRotator = UE4.UKismetMathLibrary.FindLookAtRotation(UE4.FVector(0, 0, 0), Direction);
    DirectionRotator.Roll = 0;
    DirectionRotator.Pitch = 0;

    Launcher:K2_SetActorRotation(DirectionRotator);
    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction,RushSpeed);
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function RushToInTime:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)
    if self:IsFinish() == true then
        return;
    end
    --- Param1 : 冲锋速度
    --- Param2 : 冲锋最长持续时间
    --- Param3 : 转向速度
    --- Param4 : 是否应用重力
    local RushSpeed = self:GetParamfloatValue(0); 
    local RushTime = self:GetParamfloatValue(1); 
    local RotOffset = self:GetParamfloatValue(2); 

    local UseGravity = false;
    local ParamLength = self:GetParamLength()
    if ParamLength > 3 then
        UseGravity = self:GetParamboolValue(3); 
    end
    local StartAccelerateTime = -1
    local EndAccelerateTime = -1
    local Accelerate = 0
    local RealAccelerate = 0
    if ParamLength >= 8 then
        StartAccelerateTime = self:GetParamfloatValue(5); 
        EndAccelerateTime = self:GetParamfloatValue(6); 
        Accelerate = self:GetParamfloatValue(7); 

        if StartAccelerateTime >= 0 and self.ActiveTime >= StartAccelerateTime and self.ActiveTime <= EndAccelerateTime then
            RealAccelerate = Accelerate
        end
    end

    local DisOffset;
    if self.MoveTarget ~= nil then
        DisOffset = self:GetAimTargetLocation() - MovementComp:GetOwner():K2_GetActorLocation() ;
    else
        DisOffset = MovementComp:GetOwner():GetActorForwardVector()* 2000;
    end
    DisOffset.Z = 0;
    local Direction = DisOffset
    Direction = UE4.UKismetMathLibrary.Normal(Direction)

    if RotOffset > 1 then
        local CurDir = MovementComp:GetOwner():GetActorForwardVector()
        Direction = UE4.UMathLibrary.VInterpNormalRotationTo(CurDir, Direction, DeltaTime, RotOffset);
    end

    local DirectionRotator = UE4.UKismetMathLibrary.FindLookAtRotation(UE4.FVector(0, 0, 0), Direction);
    DirectionRotator.Roll = 0;
    DirectionRotator.Pitch = 0;

    local FloorResult = MovementComp:K2_FindFloor(MovementComp:GetOwner():K2_GetActorLocation());
    local ZV = 0.0;
    if UseGravity == true then  
        if FloorResult.bWalkableFloor == true then
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
        else
            MovementComp:SetMovementMode(UE4.EMovementMode.Move_Falling)
        end
    end
    if RotOffset > -0.5 then
        MovementComp:GetOwner():K2_SetActorRotation(DirectionRotator);
    end

    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction,RushSpeed + RealAccelerate * DeltaTime);
    MovementComp.Velocity.Z = ZV;
end

function RushToInTime:OnMoveTickCheck(DeltaTime)
    local MovementComp = self:GetMovementComp();
    self.ActiveTime = self.ActiveTime + DeltaTime;
    local RushTime = self:GetParamfloatValue(1); 
    
    if self.ActiveTime > RushTime then
        self:MoveFinish(MovementComp);
    end
end

function RushToInTime:OnMoveEnd(MovementComp)
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end

return RushToInTime;