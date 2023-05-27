-- ========================================================
-- @File    : RushToGoal.lua
-- @Brief   : 技能冲锋指定目标
-- @Author  : Xiong
-- @Date    : 2020-05-28
-- ========================================================

---@class USkillMove_RushToGoal:USkillMove
local RushToGoal = Class();
function RushToGoal:IsUsedToAddVelocityInsteadOverride()
    return false;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function RushToGoal:OnMoveStart(Launcher , MovementComp)

     --- Param1 : 冲锋速度
    --- Param2 : 冲锋最长持续时间
    --- Param3 : 靠近范围
    self.ActiveTime = 0
    local RushSpeed = self:GetParamfloatValue(0); 
    local RushTime = self:GetParamfloatValue(1); 
    local Offset = self:GetParamfloatValue(2); 
    local UseGravity = false;
    local ParamLength = self:GetParamLength()
    if ParamLength > 4 then
        UseGravity = self:GetParamboolValue(4); 
    end
    local OwnerChar = MovementComp:GetOwner():Cast(UE4.AGameCharacter)
    if OwnerChar and OwnerChar:IsPlayer() and RushSpeed > 5000 and UE4.UGameLibrary.IsEnableCustomMovementIteration() then
        MovementComp.MaxSimulationTimeStep = 0.0166
        MovementComp.MaxSimulationIterations = 25
    end   

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
    local Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction,RushSpeed);
    if UseGravity then
        Velocity.Z = MovementComp:GetGravityZ()
    end
    MovementComp.Velocity = Velocity
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function RushToGoal:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)
    if self:IsFinish() == true then
        return;
    end
    --- Param1 : 冲锋速度
    --- Param2 : 冲锋最长持续时间
    --- Param3 : 靠近范围
    local RushSpeed = self:GetParamfloatValue(0); 
    local RushTime = self:GetParamfloatValue(1); 
    local Offset = self:GetParamfloatValue(2); 
    local RotOffset = self:GetParamfloatValue(3); 

    local UseGravity = false;
    local ParamLength = self:GetParamLength()
    if ParamLength > 4 then
        UseGravity = self:GetParamboolValue(4); 
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
    local Distance = DisOffset:Size()
    local Direction = DisOffset
    Direction = UE4.UKismetMathLibrary.Normal(Direction)

    if RotOffset > 1 then
        local CurDir = MovementComp:GetOwner():GetActorForwardVector()
        Direction = UE4.UMathLibrary.VInterpNormalRotationTo(CurDir, Direction, DeltaTime, RotOffset);
    end

    local DirectionRotator = UE4.UKismetMathLibrary.FindLookAtRotation(UE4.FVector(0, 0, 0), Direction);
    DirectionRotator.Roll = 0;
    DirectionRotator.Pitch = 0;

    local ZV = 0
    if UseGravity == true then
        ZV = MovementComp:GetGravityZ()
        local FloorResult = MovementComp:K2_FindFloor(MovementComp:GetOwner():K2_GetActorLocation());
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

    local Calc = 1
    if self.ActiveTime + DeltaTime > RushTime then
        CalcDeltaTime = RushTime - self.ActiveTime
        Calc = CalcDeltaTime/DeltaTime;
        if Calc < 0 then
            Calc = 0
        end
    end
    local Speed = (RushSpeed + RealAccelerate * DeltaTime) * Calc;


    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction,Speed);
    MovementComp.Velocity.Z = ZV;
    self.ActiveTime = self.ActiveTime + DeltaTime;
    self.Distance = self.Distance + DeltaTime * Speed
    self:OnMoveTickCheck(DeltaTime)
end


function RushToGoal:OnMoveBlock(HitResult)
    if self == nil then
        return
    end
    if self:IsFinish() == false then
        self:GetMovementComp().Velocity = UE4.FVector(0,0,0)
        self:MoveFinish(self:GetMovementComp());
    else
    end
end

function RushToGoal:OnMoveTickCheck(DeltaTime)
    local RushSpeed = self:GetParamfloatValue(0); 
    local RushTime = self:GetParamfloatValue(1); 
    local Offset = self:GetParamfloatValue(2); 
    local MovementComp = self:GetMovementComp();
    local DisOffset;
    if self.MoveTarget ~= nil then
        DisOffset = self:GetAimTargetLocation() - MovementComp:GetOwner():K2_GetActorLocation() ;
        DisOffset.Z = 0;
        if DisOffset:Size() < Offset then
            self:MoveFinish(MovementComp);
            return
        end
    end

    local DesireMoveDistance = RushSpeed * RushTime

    local StartAccelerateTime = -1
    local EndAccelerateTime = -1
    local Accelerate = 0
    local ParamLength = self:GetParamLength()
    if ParamLength >= 8 then
        StartAccelerateTime = self:GetParamfloatValue(5); 
        EndAccelerateTime = self:GetParamfloatValue(6); 
        Accelerate = self:GetParamfloatValue(7); 

        local AccelerateTime = EndAccelerateTime - StartAccelerateTime;
        if AccelerateTime > 0 then
            DesireMoveDistance = DesireMoveDistance + 0.5 * Accelerate * AccelerateTime * AccelerateTime;
        end
    end
    if self.ActiveTime > RushTime or self.Distance >= DesireMoveDistance  then
        self:MoveFinish(MovementComp);
        return
    end
end

function RushToGoal:OnMoveTouchTargetCheck(InTarget)
    local bStop = self:CheckTouchAimTarget(InTarget)
    if bStop then
        local MovementComp = self:GetMovementComp()
        self:MoveFinish(MovementComp)
        return true
    end
    return false
end

function RushToGoal:OnMoveEnd(MovementComp)
    if MovementComp then
        local OwnerChar = MovementComp:GetOwner():Cast(UE4.AGameCharacter)
        if OwnerChar and OwnerChar:IsPlayer() and UE4.UGameLibrary.IsEnableCustomMovementIteration() then            
            MovementComp.MaxSimulationTimeStep = 0.05
            MovementComp.MaxSimulationIterations = 8
        end
    end
    self:DeActiveSpawnedByEmitter()

    self:Destroy();
end

return RushToGoal;