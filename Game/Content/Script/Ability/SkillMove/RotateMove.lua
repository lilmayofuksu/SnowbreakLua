-- ========================================================
-- @File    : RotateMove.lua
-- @Brief   : 可转向移动
-- @Author  : CMS
-- @Date    : 2020-12-21
-- ========================================================

---@class USkillMove_RotateMove:USkillMove
local RotateMove = Class();

function RotateMove:IsUsedToAddVelocityInsteadOverride()
    return false;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function RotateMove:OnMoveStart(Launcher , MovementComp)
    
    --- Param1 : 初速度
    --- Param2 : 加速度
    --- Param3 : 最大速度
    --- Param4 : 转向速度

    local StartSpeed = self:GetParamfloatValue(0); 
    local Direction = Launcher:GetActorForwardVector();
    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction,StartSpeed);
    self.CurrentSpeed = StartSpeed; 

    self.Acceleration = self:GetParamfloatValue(1); 
    self.MaxSpeed = self:GetParamfloatValue(2); 
    self.RotateSpeed = self:GetParamfloatValue(3); 


end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function RotateMove:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)

    --- Param1 : 初速度
    --- Param2 : 加速度
    --- Param3 : 最大速度
    --- Param4 : 转向速度
    
    self.CurrentSpeed = UE4.UKismetMathLibrary.FClamp(self.CurrentSpeed + DeltaTime * self.Acceleration , 0 , self.MaxSpeed);
    local InputAcceleration = MovementComp:GetCurrentAcceleration();
    InputAcceleration.Z = 0
    InputAcceleration = UE4.UKismetMathLibrary.Vector_NormalUnsafe(InputAcceleration)
    local YawAdd = UE4.UKismetMathLibrary.DegCos(self:AngleBetweenVectors(InputAcceleration,MovementComp:GetOwner():GetActorRightVector())) * UE4.UKismetMathLibrary.VSize(InputAcceleration) * DeltaTime * self.RotateSpeed;
    MovementComp:GetOwner():K2_AddActorWorldRotation(UE4.FRotator(0,YawAdd,0));
    local Direction = MovementComp:GetOwner():GetActorForwardVector();
    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction,self.CurrentSpeed);
end

function RotateMove:OnMoveEnd(MovementComp)
    if MovementComp:GetCurrentAcceleration():Size() <= 0 then
        MovementComp.Velocity =  UE4.FVector(0,0,0)
    end
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end


return RotateMove;