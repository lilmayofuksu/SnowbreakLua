-- ========================================================
-- @File    : DragToGoal.lua
-- @Brief   : 朝着指定目标拉扯
-- @Author  : Xiong
-- @Date    : 2020-05-09
-- ========================================================

---@class USkillMove_DragToGoal:USkillMove
local DragToGoal = Class();

function DragToGoal:IsUsedToAddVelocityInsteadOverride()
    return false;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function DragToGoal:OnMoveStart(Launcher , MovementComp)
    --- Param1 : 拉扯持续速度
    local DragSpeed = self:GetParamfloatValue(0)
    --- Param2 : 拉扯到位置后是否停止
    local bNeedStop = self:GetParamboolValue(1)

    -- --- Param3 : 拉扯位置误差值
    -- local bNeedStop = false
    -- if self.ParamInfo.Params:Length() > 1 then
    --     bNeedStop = UE4.UAbilityFunctionLibrary.GetParamboolValue(self.ParamInfo.Params:Get(2)); 
    -- end

    local ChracterLoc = MovementComp:GetOwner():K2_GetActorLocation();
    local TargetLoc;
    if self.MoveTarget ~= nil then
        TargetLoc = self:GetAimTargetLocation();
    end
    local Offset = TargetLoc - ChracterLoc;
    Offset.Z = 0.0;
    local Dir =  UE4.UKismetMathLibrary.Normal(Offset);

    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Dir,DragSpeed);
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function DragToGoal:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)

    --- Param1 : 拉扯持续速度
    local DragSpeed = self:GetParamfloatValue(0)
    --- Param2 : 拉扯到位置后是否停止
    local bNeedStop = self:GetParamboolValue(1)

    local ChracterLoc = MovementComp:GetOwner():K2_GetActorLocation();
    local TargetLoc;
    if self.MoveTarget ~= nil then
        TargetLoc = self:GetAimTargetLocation();
    end

    local Offset = TargetLoc - ChracterLoc;
    Offset.Z = 0.0;
    local Distance = UE4.UKismetMathLibrary.VSize(Offset);
    local Dir =  UE4.UKismetMathLibrary.Normal(Offset);
    
    if Distance > 10 then
        MovementComp.Velocity = UE4.UKismetMathLibrary.Multiply_VectorFloat(Dir,DragSpeed);
    else
        if bNeedStop == true then
            MovementComp:RemoveUpdateSkillMove(self);
        end
    end
end

function DragToGoal:OnMoveTickCheck(DeltaTime)
    local MovementComp = self:GetMovementComp();
    if self.MoveTarget == nil then
        self:MoveFinish(MovementComp);
        return;
    end
end

function DragToGoal:OnMoveEnd(MovementComp)
    self:Destroy();
end

return DragToGoal;