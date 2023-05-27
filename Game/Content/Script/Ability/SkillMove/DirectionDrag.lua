-- ========================================================
-- @File    : DirectionDrag.lua
-- @Brief   : 朝着指定朝向拉扯
-- @Author  : Xiong
-- @Date    : 2020-05-09
-- ========================================================

---@class USkillMove_DirectionDrag:USkillMove
local DirectionDrag = Class();

function DirectionDrag:IsUsedToAddVelocityInsteadOverride()
    return true;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function DirectionDrag:OnMoveStart(Launcher , MovementComp)
    --- Param1 : 拉扯持续速度
    local DragSpeed = self:GetParamfloatValue(0)
    --- Param2 : 拉扯到位置后是否停止
    local bNeedStop = self:GetParamboolValue(1)

    local ChracterLoc = MovementComp:GetOwner():K2_GetActorLocation();
    local TargetDir = self.TargetLocation;

    local Offset = TargetLoc - ChracterLoc;
    Offset.Z = 0.0;
    local Dir =  UE4.UKismetMathLibrary.Normal(TargetDir);

    MovementComp.Velocity =  MovementComp.Velocity + UE4.UKismetMathLibrary.Multiply_VectorFloat(Dir,DragSpeed);
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function DirectionDrag:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)

    --- Param1 : 拉扯持续速度
    local DragSpeed = self:GetParamfloatValue(0)
    --- Param2 : 拉扯到位置后是否停止
    local bNeedStop = self:GetParamboolValue(1)
 
    local ChracterLoc = MovementComp:GetOwner():K2_GetActorLocation();
    local TargetDir = self.TargetLocation;
    local Dir =  UE4.UKismetMathLibrary.Normal(TargetDir);
    MovementComp.Velocity =  MovementComp.Velocity + UE4.UKismetMathLibrary.Multiply_VectorFloat(Dir,DragSpeed);
end

function DirectionDrag:OnMoveEnd(MovementComp)
    self:Destroy();
end

return DirectionDrag;