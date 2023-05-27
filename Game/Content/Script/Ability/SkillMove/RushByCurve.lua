-- ========================================================
-- @File    : RushByCurve.lua
-- @Brief   : 基于曲线的Rush
-- @Author  : CMS
-- @Date    : 2021-1-17
-- ========================================================

---@class USkillMove_RushByCurve:USkillMove
local RushByCurve = Class();

function RushByCurve:IsUsedToAddVelocityInsteadOverride()
    return false;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function RushByCurve:OnMoveStart(Launcher , MovementComp)
    
    ---Param1:曲线资源
    ---Param2:指定时长

    local Direction = Launcher:GetActorForwardVector();
    local Duration = self.EmitterMontageDurationTime;
    local ParamsLength = self:GetParamLength()
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
function RushByCurve:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)
    local Direction = MovementComp:GetOwner():GetActorForwardVector();
    if self.CurrentTime <= self.CurveMax  then
        MovementComp.Velocity =  UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction,self.Curve:GetFloatValue(self.CurrentTime));
    end
end

function RushByCurve:OnMoveTickCheck(DeltaTime)
    local MovementComp = self:GetMovementComp();
    self.CurrentTime = self.CurrentTime + DeltaTime * self.Ratio;
    if self.CurrentTime > self.CurveMax  then
        self:MoveFinish(MovementComp);
    end
end

function RushByCurve:OnMoveEnd(MovementComp)
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end


return RushByCurve;