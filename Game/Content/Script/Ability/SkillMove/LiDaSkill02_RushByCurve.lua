-- ========================================================
-- @File    : LiDaSkill02_RushByCurve.lua
-- @Brief   : 基于曲线的Rush
-- @Author  : XHJ
-- @Date    : 2021-8-25
-- ========================================================

---@class USkillMove_RushByCurve:USkillMove
local LiDaSkill02_RushByCurve = Class();

function LiDaSkill02_RushByCurve:IsUsedToAddVelocityInsteadOverride()
    return false;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function LiDaSkill02_RushByCurve:OnMoveStart(Launcher , MovementComp)
    
    ---Param1:曲线资源
    ---Param2:指定时长

    local Direction = Launcher:GetActorForwardVector();

    if self.MoveTarget ~= nil then
        Direction = UE4.UKismetMathLibrary.Normal(self:GetAimTargetLocation() - MovementComp:GetOwner():K2_GetActorLocation())
    end
    local ParamsLength = self:GetParamLength()
    local Duration = 0.0
    Duration = self.EmitterMontageDurationTime;
    if ParamsLength > 1 then
        local ParamDuration = self:GetParamfloatValue(1); 
        if ParamDuration > 0 then
            Duration = ParamDuration;
        end
    end
    
    local pLoadCurve = UE4.UGameAssetManager.GameLoadAssetFormPath(self:GetParamValue(0))
    if not pLoadCurve then return end

    self.Curve = pLoadCurve:Cast(UE4.UCurveFloat); 
    self.CurveMin = self:GetCurveMinTime(self.Curve);
    self.CurveMax = self:GetCurveMaxTime(self.Curve);
    self.CurrentTime = self.CurveMin;
    self.Ratio = (self.CurveMax - self.CurveMin) / Duration;
    MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction,self.Curve:GetFloatValue(self.CurveMin));

end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function LiDaSkill02_RushByCurve:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)

    local Direction = MovementComp:GetOwner():GetActorForwardVector();
    if self.MoveTarget ~= nil then
        Direction = UE4.UKismetMathLibrary.Normal(self:GetAimTargetLocation() - MovementComp:GetOwner():K2_GetActorLocation())
    end
    self.CurrentTime = self.CurrentTime + DeltaTime * self.Ratio;
    
    if self.CurrentTime <= self.CurveMax  then
        MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction,self.Curve:GetFloatValue(self.CurrentTime));
    else
        self:MoveFinish(MovementComp);
    end
end


function LiDaSkill02_RushByCurve:OnMoveBlock(HitResult)
    if self == nil then
        return
    end

    local HitCharacter = HitResult.Actor:Cast(UE4.AGameCharacter);
    local IsDead = false;
    if HitCharacter ~= nil then
        IsDead = HitCharacter:IsDead()
    end
    if self:IsFinish() == false and HitCharacter ~= nil and IsDead == false then
        self:GetMovementComp().Velocity = UE4.FVector(0,0,0)
        self:MoveFinish( self:GetMovementComp());
    end
end


function LiDaSkill02_RushByCurve:OnMoveEnd(MovementComp)
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end


return LiDaSkill02_RushByCurve;