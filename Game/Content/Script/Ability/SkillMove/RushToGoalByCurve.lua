-- ========================================================
-- @File    : RushToGoalByCurve.lua
-- @Brief   : 加减速基于曲线的RushToGoal
-- @Author  : CMS
-- @Date    : 2021-1-17
-- ========================================================

---@class USkillMove_RushToGoalByCurve:USkillMove
local RushToGoalByCurve = Class()

function RushToGoalByCurve:IsUsedToAddVelocityInsteadOverride()
    return false
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function RushToGoalByCurve:OnMoveStart(Launcher, MovementComp)
    ---Param1: 加速曲线资源路径
    ---Param2: 减速曲线资源路径
    ---Param3: 冲锋最长持续时间
    ---Param4: 开启减速范围
    ---Param5: 转向修正量
    ---Param6: 碰撞是否停下
    self.AccelerationCurve = UE4.UGameAssetManager.GameLoadAssetFormPath(self:GetParamValue(0)):Cast(UE4.UCurveFloat)
    self.DecelerationCurve = UE4.UGameAssetManager.GameLoadAssetFormPath(self:GetParamValue(1)):Cast(UE4.UCurveFloat)
    self.MaxRushTime = self:GetParamfloatValue(2)
    self.BeginDecelerateRadius = self:GetParamfloatValue(3)
    self.RotSpeed = self:GetParamfloatValue(4)
    self.CanBlock = self:GetParamboolValue(5)
    self.AccelerationCurveMaxTime = self:GetCurveMaxTime(self.AccelerationCurve)
    self.DecelerationCurveMaxTime = self:GetCurveMaxTime(self.DecelerationCurve)
    self.CurrentTime = 0

    local Direction = Launcher:GetActorForwardVector()
    Direction = UE4.UKismetMathLibrary.Normal(self:GetAimTargetLocation() - Launcher:K2_GetActorLocation())
    
    local DirectionRotator = UE4.UKismetMathLibrary.FindLookAtRotation(UE4.FVector(0, 0, 0), Direction)
    DirectionRotator.Roll = 0
    DirectionRotator.Pitch = 0
    Launcher:K2_SetActorRotation(DirectionRotator)

    self.CurrentSpeed = self.AccelerationCurve:GetFloatValue(0)
    MovementComp.Velocity = UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction, self.CurrentSpeed)
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function RushToGoalByCurve:OnMoveTick(DeltaTime, Friction, Fluid, BrakingDeceleration, MovementComp)

    self.CurrentTime = self.CurrentTime + DeltaTime
    local Direction = MovementComp:GetOwner():GetActorForwardVector()
    
    Direction = UE4.UKismetMathLibrary.Normal(self:GetAimTargetLocation() - MovementComp:GetOwner():K2_GetActorLocation())
    if self.RotSpeed > 0 then
        local CurDir = MovementComp:GetOwner():GetActorForwardVector()
        Direction = UE4.UMathLibrary.VInterpNormalRotationTo(CurDir, Direction, DeltaTime, self.RotSpeed)
    end
    
    local DirectionRotator = UE4.UKismetMathLibrary.FindLookAtRotation(UE4.FVector(0, 0, 0), Direction)
    DirectionRotator.Roll = 0
    DirectionRotator.Pitch = 0
    MovementComp:GetOwner():K2_SetActorRotation(DirectionRotator)

    local Distance = (self:GetAimTargetLocation() - MovementComp:GetOwner():K2_GetActorLocation()):Size()
    if self.CurrentTime <= self.MaxRushTime and Distance > self.BeginDecelerateRadius and not self.BeginDecelerate then
        if self.CurrentTime < self.AccelerationCurveMaxTime then
            self.CurrentSpeed = self.AccelerationCurve:GetFloatValue(self.CurrentTime)
        else
            self.CurrentSpeed = self.AccelerationCurve:GetFloatValue(self.AccelerationCurveMaxTime)
        end
    else
        if not self.BeginDecelerate then
            self.BeginDecelerate = true
            self.CurrentTime = DeltaTime
            self.DecelerationRatio = self.CurrentSpeed / self.DecelerationCurve:GetFloatValue(0)
            if self.CurrentSpeed <= 0 then 
                return
            end
        end
        if self.CurrentTime < self.DecelerationCurveMaxTime then
            self.CurrentSpeed = self.DecelerationCurve:GetFloatValue(self.CurrentTime) * self.DecelerationRatio
        else
            self.CurrentSpeed = self.DecelerationCurve:GetFloatValue(self.DecelerationCurveMaxTime) * self.DecelerationRatio
        end
    end
    
    MovementComp.Velocity = UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction, self.CurrentSpeed)
    print("Test Only")
end

function RushToGoalByCurve:OnMoveTickCheck(DeltaTime)
    if self == nil then
        return;
    end
    local MovementComp = self:GetMovementComp();
    if self.CurrentTime <= self.MaxRushTime and Distance > self.BeginDecelerateRadius and not self.BeginDecelerate then
    else
        if not self.BeginDecelerate then
            if self.CurrentSpeed <= 0 then 
                self:MoveFinish(MovementComp)
                return
            end
        end
        if self.CurrentTime < self.DecelerationCurveMaxTime then
            self:MoveFinish(MovementComp)
            return 
        end
    end
end

function RushToGoalByCurve:OnMoveBlock(HitResult)
    if self == nil then
        return
    end
    
    if self.CanBlock then
        self:GetMovementComp().Velocity = UE4.FVector(0,0,0)
        self:MoveFinish( self:GetMovementComp());
    end
end

function RushToGoalByCurve:OnMoveEnd(MovementComp)
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end

return RushToGoalByCurve
