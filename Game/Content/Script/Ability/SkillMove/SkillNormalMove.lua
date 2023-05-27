-- ========================================================
-- @File    : Rush.lua
-- @Brief   : 技能冲锋
-- @Author  : Xiong
-- @Date    : 2020-05-09
-- ========================================================

---@class USkillNormalMove:USkillMove
local SkillNormalMove = Class();

function SkillNormalMove:IsUsedToAddVelocityInsteadOverride()
    return false;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function SkillNormalMove:OnMoveStart(Launcher , MovementComp)

    --- Param1 : 冲锋速度
    self.SpeedRatioCurve = UE4.UGameAssetManager.GameLoadAssetFormPath(self:GetParamValue(0)):Cast(UE4.UCurveFloat)
    local BaseSpeed = self:GetParamfloatValue(2);
    local KeepMove = self:GetParamboolValue(3);

    if self.SpeedRatioCurve == nil then
        self:MoveFinish(MovementComp);
        return;
    end
    local MaxSpeed = BaseSpeed;
    if BaseSpeed < 1.0 then
        MaxSpeed = MovementComp:K2_GetCharacterMaxSpeed();
    end
    local CurrentSpeed = MaxSpeed * self.SpeedRatioCurve:GetFloatValue(self.ActiveTime)
    local Acceleration = MovementComp:GetCurrentAcceleration();
    local AccelerationDir = UE4.UKismetMathLibrary.Normal(Acceleration); 
    if AccelerationDir:Size() < 0.1 and KeepMove == true then
        AccelerationDir = UE4.UKismetMathLibrary.Normal(MovementComp.Velocity);
        if AccelerationDir:Size() < 0.1 then
            AccelerationDir = MovementComp:GetOwner():GetActorForwardVector();
        end
    end

    if self.SpawnedBy ~= nil then
        self.SpawnedBy.bKeepRunning = true;
    end
    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(AccelerationDir,CurrentSpeed);
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function SkillNormalMove:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)

    --- Param1 : 冲锋速度
    local BaseSpeed = self:GetParamfloatValue(2);
    local KeepMove = self:GetParamboolValue(3);

    if self.SpeedRatioCurve == nil then
        self:MoveFinish(MovementComp);
        return;
    end
    local MaxSpeed = BaseSpeed;
    if BaseSpeed < 1.0 then
        MaxSpeed = MovementComp:K2_GetCharacterMaxSpeed();
    end
    
    local CurrentSpeed = MaxSpeed * self.SpeedRatioCurve:GetFloatValue(self.ActiveTime)
    local Acceleration = MovementComp:GetCurrentAcceleration();
    local AccelerationDir = UE4.UKismetMathLibrary.Normal(Acceleration); 
    if AccelerationDir:Size() < 0.1 and KeepMove == true then
        AccelerationDir = UE4.UKismetMathLibrary.Normal(MovementComp.Velocity);
        if AccelerationDir:Size() < 0.1 then
            AccelerationDir = MovementComp:GetOwner():GetActorForwardVector();
        end
    end

    if self.SpawnedBy ~= nil then
        self.SpawnedBy.bKeepRunning = true;
    end

    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(AccelerationDir,CurrentSpeed);
end

function SkillNormalMove:OnMoveTickCheck(DeltaTime)
    local MoveKeepTime = self:GetParamfloatValue(1); 
    
    local MovementComp = self:GetMovementComp();
    self.ActiveTime = self.ActiveTime + DeltaTime;
    if self.ActiveTime > MoveKeepTime and MoveKeepTime > 0.0 then
        self:MoveFinish(MovementComp);
    end
end

function SkillNormalMove:OnMoveEnd(MovementComp)
    
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end

return SkillNormalMove;