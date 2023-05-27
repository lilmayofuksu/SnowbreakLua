-- ========================================================
-- @File    : RelativeDirectionMove.lua
-- @Brief   : 相对方向移动
-- @Author  : CMS
-- @Date    : 2021-1-5
-- ========================================================

---@class USkillMove_RelativeDirectionMove:USkillMove
local RelativeDirectionMove = Class();

function RelativeDirectionMove:IsUsedToAddVelocityInsteadOverride()
    return false;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function RelativeDirectionMove:OnMoveStart(Launcher , MovementComp)
    
    --- Param1 : 初速度
    --- Param2 : 加速度
    --- Param3 : 最大速度
    --- Param4 : 速度方向与角色正方向夹角
    --- Param5 : 是否每帧更新方向

    self.CurrentSpeed = self:GetParamfloatValue(0); 
    self.Acceleration = self:GetParamfloatValue(1); 
    self.MaxSpeed = self:GetParamfloatValue(2); 
    self.AngleBetweenCharacterForward = self:GetParamfloatValue(3); 
    self.bTickUpdateDirection = self:GetParamboolValue(4); 
    self.Direction =  UE4.UKismetMathLibrary.RotateAngleAxis(Launcher:GetActorForwardVector(),self.AngleBetweenCharacterForward , UE4.FVector(0,0,1));
    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(self.Direction,self.CurrentSpeed);


end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function RelativeDirectionMove:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)

    if(self.bTickUpdateDirection) then
        self.Direction = UE4.UKismetMathLibrary.RotateAngleAxis(MovementComp:GetOwner():GetActorForwardVector(),self.AngleBetweenCharacterForward , FVector(0,0,1));
    end
    self.CurrentSpeed = UE4.UKismetMathLibrary.FClamp(self.CurrentSpeed + DeltaTime * self.Acceleration , 0 , self.MaxSpeed);
    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(self.Direction,self.CurrentSpeed);

end

function RelativeDirectionMove:OnMoveEnd(MovementComp)
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end


return RelativeDirectionMove;