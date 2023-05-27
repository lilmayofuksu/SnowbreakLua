-- ========================================================
-- @File    : DragToGoal.lua
-- @Brief   : 技能冲锋
-- @Author  : Xiong
-- @Date    : 2020-05-09
-- ========================================================

---@class USkillMove_DragToGoal:USkillMove
local DragToLoc = Class();

function DragToLoc:IsUsedToAddVelocityInsteadOverride()
    return false;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function DragToLoc:OnMoveStart(Launcher , MovementComp)

    --- Param1 : 拉扯持续速度
    local DragSpeed = self:GetParamfloatValue(0)
    local ParamsLength = self:GetParamLength()
    local MoveDistanceFuncParam = UE4.FVector2D(1,0)
    if ParamsLength > 3 then
        MoveDistanceFuncParam = self:GetFVector2DValue(3); 
    end

    local ChracterLoc = MovementComp:GetOwner():K2_GetActorLocation();
    self.FinalTargetLoc = self:CalcTargetLoc(MoveDistanceFuncParam, MovementComp);

    local Offset = FinalTargetLoc - ChracterLoc;
    Offset.Z = 0.0;
    local Dir =  UE4.UKismetMathLibrary.Normal(Offset);

    MovementComp.Velocity =  MovementComp.Velocity + UE4.UKismetMathLibrary.Multiply_VectorFloat(Dir,DragSpeed);
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function DragToLoc:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)

    --- Param1 : 拉扯持续速度
    local DragSpeed = self:GetParamfloatValue(0)
    --- Param2 : 拉扯到位置后是否停止
    local bNeedStop = self:GetParamboolValue(1)
    local ParamsLength = self:GetParamLength()
    local StopOffset = 60
    if ParamsLength > 2 then
        StopOffset = self:GetParamfloatValue(2); 
    end

    local ChracterLoc = MovementComp:GetOwner():K2_GetActorLocation();

    local Offset = self.FinalTargetLoc - ChracterLoc;
    Offset.Z = 0.0;

    local Distance = UE4.UKismetMathLibrary.VSize(Offset);
    local Dir =  UE4.UKismetMathLibrary.Normal(Offset);

    if Distance > StopOffset then
        local Dir =  UE4.UKismetMathLibrary.Normal(Offset);
        MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Dir,DragSpeed);
    else
        
    end
end

function DragToLoc:OnMoveTickCheck(DeltaTime)
    --- Param2 : 拉扯到位置后是否停止
    local bNeedStop = self:GetParamboolValue(1)
    local ParamsLength = self:GetParamLength()
    local StopOffset = 60
    if ParamsLength > 2 then
        StopOffset = self:GetParamfloatValue(2); 
    end

    if bNeedStop == true then
        local MovementComp = self:GetMovementComp();
        local ChracterLoc = MovementComp:GetOwner():K2_GetActorLocation();
        local Offset = self.FinalTargetLoc - ChracterLoc;
        Offset.Z = 0.0;
        local Distance = UE4.UKismetMathLibrary.VSize(Offset);
        
        if Distance < StopOffset then
            self:MoveFinish(MovementComp);
        end
    end
end

function DragToLoc:CalcTargetLoc(InMoveDistanceFuncParam, InMovement)
    local ChracterLoc = InMovement:GetOwner():K2_GetActorLocation();
    local TargetLoc = self.TargetLocation;
    local Offset = TargetLoc - ChracterLoc;
    Offset.Z = 0.0;
    local Distance = UE4.UKismetMathLibrary.VSize(Offset);
    local Dir =  UE4.UKismetMathLibrary.Normal(Offset);


    local X = InMoveDistanceFuncParam.X;
    local Y = InMoveDistanceFuncParam.Y;
    local MoveDis = Distance * X + Y;
    local TargetLoc = Dir * MoveDis + ChracterLoc;
    return TargetLoc;
end

function DragToLoc:OnMoveEnd(MovementComp)
    self:Destroy();
end

return DragToLoc;