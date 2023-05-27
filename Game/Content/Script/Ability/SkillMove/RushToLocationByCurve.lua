-- ========================================================
-- @File    : RushToLocationByCurve.lua
-- @Brief   : 加减速基于曲线的RushToLocation
-- @Author  : CMS
-- @Date    : 2021-2-4
-- ========================================================

---@class USkillMove_RushToLocationByCurve:USkillMove
local RushToLocationByCurve = Class()

function RushToLocationByCurve:IsUsedToAddVelocityInsteadOverride()
    return false
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function RushToLocationByCurve:OnMoveStart(Launcher, MovementComp)
    ---Param1: 加速曲线资源路径
    ---Param2: 减速曲线资源路径
    ---Param3: 开启减速范围
    ---Param4: 碰撞是否停下
    ---Param5: 计算曲线平均速度时的段数
    self.AccelerationCurve = UE4.UGameAssetManager.GameLoadAssetFormPath(self:GetParamValue(0)):Cast(UE4.UCurveFloat)
    self.DecelerationCurve = UE4.UGameAssetManager.GameLoadAssetFormPath(self:GetParamValue(1)):Cast(UE4.UCurveFloat)
    self.BeginDecelerateRadius = self:GetParamfloatValue(2)
    self.CanBlock = self:GetParamboolValue(3)
    self.SegmentsNum = self:GetParamfloatValue(4)
    local Offset = self.TargetLocation - Launcher:K2_GetActorLocation()
    self.Direction = UE4.UKismetMathLibrary.Normal(UE4.FVector(Offset.X, Offset.Y, 0))
    local DirectionRotator = UE4.UKismetMathLibrary.FindLookAtRotation(UE4.FVector(0, 0, 0), self.Direction)
    DirectionRotator.Roll = 0
    DirectionRotator.Pitch = 0
    Launcher:K2_SetActorRotation(DirectionRotator)

    self.CurrentTime = 0
    self.AccelerationCurveMaxTime = self:GetCurveMaxTime(self.AccelerationCurve)
    self.DecelerationCurveMaxTime = self:GetCurveMaxTime(self.DecelerationCurve)
    self.TimeRatio = self.AccelerationCurveMaxTime / self:GenerateCurveMaxTime(Offset:Size2D() - self.BeginDecelerateRadius,self.AccelerationCurve,self.SegmentsNum)
    self.CurrentSpeed = self.AccelerationCurve:GetFloatValue(0)
    MovementComp.Velocity = UE4.UKismetMathLibrary.Multiply_VectorFloat(self.Direction, self.CurrentSpeed)
    --self:DebugSphere(self.TargetLocation);
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function RushToLocationByCurve:OnMoveTick(DeltaTime, Friction, Fluid, BrakingDeceleration, MovementComp)

    local DirectionRotator = UE4.UKismetMathLibrary.FindLookAtRotation(UE4.FVector(0, 0, 0), self.Direction)
    DirectionRotator.Roll = 0
    DirectionRotator.Pitch = 0
    MovementComp:GetOwner():K2_SetActorRotation(DirectionRotator)
    self.CurrentTime = self.CurrentTime + DeltaTime
    local Distance = (self.TargetLocation - MovementComp:GetOwner():K2_GetActorLocation()):Size2D()

    if Distance > self.BeginDecelerateRadius  and not self.BeginDecelerate then
        if self.CurrentTime * self.TimeRatio < self.AccelerationCurveMaxTime then
            self.CurrentSpeed = self.AccelerationCurve:GetFloatValue(self.CurrentTime * self.TimeRatio)
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
    MovementComp.Velocity = UE4.UKismetMathLibrary.Multiply_VectorFloat(self.Direction, self.CurrentSpeed)
end

function RushToLocationByCurve:OnMoveTickCheck(DeltaTime)
    local MovementComp = self:GetMovementComp();
    local Distance = (self.TargetLocation - MovementComp:GetOwner():K2_GetActorLocation()):Size2D()

    if self ~= nil then
        if Distance > self.BeginDecelerateRadius and not self.BeginDecelerate then
        else
            if self.CurrentSpeed <= 0 then 
                self:MoveFinish(MovementComp)
                return
            end
            local DCMT = 0.0
            if self.DecelerationCurveMaxTime ~= nil then
                DCMT = self.DecelerationCurveMaxTime;
                if self.CurrentTime >= DCMT then
                    self:MoveFinish(MovementComp)
                    return
                end
            end
        end
    end

end

function RushToLocationByCurve:OnMoveBlock(HitResult)
    if self ~= nil then
        if self.CanBlock then
            self:GetMovementComp().Velocity = UE4.FVector(0,0,0)
            self:MoveFinish( self:GetMovementComp());
        end
    end
end

function RushToLocationByCurve:OnMoveEnd(MovementComp)
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end

--根据距离缩放曲线，返回曲线实际缩放后的最大时间
function RushToLocationByCurve:GenerateCurveMaxTime(Distance, InCurve, SegmentsNum)
    if InCurve == nil then
        return 0
    end
    local TotalValue = 0
    local SegmentTime = self:GetCurveMaxTime(InCurve) / SegmentsNum;
    for i = 0 , SegmentsNum do
        TotalValue = TotalValue + InCurve:GetFloatValue(SegmentTime * i)
    end
    return Distance / (TotalValue / (SegmentsNum+1))
end


return RushToLocationByCurve
