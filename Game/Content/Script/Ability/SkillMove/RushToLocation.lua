-- ========================================================
-- @File    : RushToLocation.lua
-- @Brief   : 技能冲锋指定点
-- @Author  : Xiong
-- @Date    : 2021-08-02
-- ========================================================

---@class USkillMove_RushToLocation:USkillMove
local RushToLocation = Class();

function RushToLocation:IsUsedToAddVelocityInsteadOverride()
    return false;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function RushToLocation:OnMoveStart(Launcher , MovementComp)

     --- Param1 : 冲锋速度
    --- Param2 : 冲锋最长持续时间
    --- Param3 : 靠近范围

    local RushSpeed = self:GetParamfloatValue(0); 
    local RushTime = self:GetParamfloatValue(1); 
    local Offset = self:GetParamfloatValue(2); 
    
    if self.SpawnedBy ~= nil then
        self.SpawnedBy.bKeepRunning = true;
    end
    local Offset = self.TargetLocation - Launcher:K2_GetActorLocation()
    
    local Distance = Offset:Size()
    local Direction = Offset
    Direction = UE4.UKismetMathLibrary.Normal(Direction)
    local DirectionRotator = UE4.UKismetMathLibrary.FindLookAtRotation(UE4.FVector(0, 0, 0), Direction);
    DirectionRotator.Roll = 0;
    DirectionRotator.Pitch = 0;

    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction,RushSpeed);
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function RushToLocation:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)

    --- Param1 : 冲锋速度
    --- Param2 : 冲锋最长持续时间
    --- Param3 : 靠近范围
    --- Param4 : 转向速率(<=-1 时不转向， 0 时立刻转向， >1 时每秒转向指定角度)

    local RushSpeed = self:GetParamfloatValue(0); 
    local RushTime = self:GetParamfloatValue(1); 
    local Offset = self:GetParamfloatValue(2); 
    local RotOffset = self:GetParamfloatValue(3); 

    local DisOffset = self.TargetLocation - MovementComp:GetOwner():K2_GetActorLocation() ;
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

    if RotOffset > -0.5 then
        MovementComp:GetOwner():K2_SetActorRotation(DirectionRotator);
    end

    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction,RushSpeed);
end

function RushToLocation:OnMoveTickCheck(DeltaTime)
    local RushTime = self:GetParamfloatValue(1); 
    local MovementComp = self:GetMovementComp();
    local Offset = self:GetParamfloatValue(2); 
    
    local DisOffset = self.TargetLocation - MovementComp:GetOwner():K2_GetActorLocation() ;
    DisOffset.Z = 0;
    local Distance = DisOffset:Size()
    self.ActiveTime = self.ActiveTime + DeltaTime;
    if self.ActiveTime > RushTime or Distance <= Offset then
        self:MoveFinish(MovementComp);
    end
end

function RushToLocation:OnMoveBlock(HitResult)
    if self == nil then
        return
    end

    if self:IsFinish() == false then
        self:GetMovementComp().Velocity = UE4.FVector(0,0,0)
        self:MoveFinish(self:GetMovementComp());
    end
end

function RushToLocation:OnMoveEnd(MovementComp)
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end

return RushToLocation;