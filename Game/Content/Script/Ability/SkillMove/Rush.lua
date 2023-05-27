-- ========================================================
-- @File    : Rush.lua
-- @Brief   : 技能冲锋
-- @Author  : Xiong
-- @Date    : 2020-05-09
-- ========================================================

---@class USkillMove_Rush:USkillMove
local Rush = Class();

function Rush:IsUsedToAddVelocityInsteadOverride()
    return false;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function Rush:OnMoveStart(Launcher , MovementComp)

    --- Param1 : 冲锋速度
    --- Param2 : 冲锋最长持续时间

    local RushSpeed = self:GetParamfloatValue(0); 
    local RushTime = self:GetParamfloatValue(1); 

    if self.SpawnedBy ~= nil then
        self.SpawnedBy.bKeepRunning = true;
    end
    local Direction = Launcher:GetActorForwardVector();
    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction,RushSpeed);
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function Rush:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)

    --- Param1 : 冲锋速度
    --- Param2 : 冲锋最长持续时间

    local RushSpeed = self:GetParamfloatValue(0); 
    local RushTime = self:GetParamfloatValue(1); 

    self.ActiveTime = self.ActiveTime + DeltaTime;
    local Direction = MovementComp:GetOwner():GetActorForwardVector();
    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction,RushSpeed);
    if self.ActiveTime > RushTime then
        self:MoveFinish(MovementComp);
    end
end

function Rush:OnMoveEnd(MovementComp)
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end

return Rush;