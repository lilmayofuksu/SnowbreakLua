-- ========================================================
-- @File    : LiDaJump.lua
-- @Brief   : 跳跃最高高度不变，距离变化的固定时长跳跃
-- @Author  : Xiong
-- @Date    : 2020-05-09
-- ========================================================

---@class USkillMove_LiDaJump:USkillMove
local LiDaJump = Class();

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function LiDaJump:OnMoveStart(Launcher , MovementComp)
    local JumpCostTime = self:GetParamfloatValue(0);
    local HeightScaleCurveName = self:GetParamValue(1)
    local DistanceScope = self:GetFVector2DValue(2);

    local CharacterMesh = Launcher.Mesh;
    local AnimInstance = CharacterMesh:GetAnimInstance();

    --- 如果MoveTarget有效，则使用TargetLocation的位置，否则寻找自身前方最远点
    local TargetLoc = self.TargetLocation;
    -- if self.MoveTarget == nil then
    --     local ForwardOffset = UE4.UKismetMathLibrary.Multiply_VectorFloat(Launcher:GetActorForwardVector(), DistanceScope.Y);
    --     TargetLoc = ForwardOffset + Launcher:K2_GetActorLocation();
    -- else
    --     TargetLoc = self.TargetLocation + UE4.UKismetMathLibrary.Multiply_VectorFloat(Launcher:GetActorForwardVector(), -100);
    --     local Offset = TargetLoc - Launcher:K2_GetActorLocation();
    --     Offset.Z = 0;
    --     local Size = Offset:Size();
    --     local Direction = UE4.UKismetMathLibrary.Normal(Offset);
    --     if Size < DistanceScope.X then
    --         local ForwardOffset = UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction, DistanceScope.X);
    --         TargetLoc = ForwardOffset + Launcher:K2_GetActorLocation();
    --     end

    --     if Size > DistanceScope.Y then
    --         local ForwardOffset = UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction, DistanceScope.Y);
    --         TargetLoc = ForwardOffset + Launcher:K2_GetActorLocation();
    --     end
    -- end
    
    MovementComp:SetMovementMode(UE4.EMovementMode.Move_Flying)
    self.StartLoc = Launcher:K2_GetActorLocation();
    self.TargetLocation = TargetLoc;
    self.KeepTime = 0;
    self.bEndFly = false;
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function LiDaJump:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)

    local JumpCostTime = self:GetParamfloatValue(0);
    local HeightSpeedCurveName = self:GetParamValue(1)
    local HorizontalSpeedCurveName =  self:GetParamValue(2)

    local Launcher = MovementComp:GetOwner():Cast(UE4.AGameCharacter);
    local CharacterMesh = Launcher.Mesh;
    local AnimInstance = CharacterMesh:GetAnimInstance();
    
    self.KeepTime = self.KeepTime + DeltaTime;
    if self.KeepTime < JumpCostTime then 
        if self.bEndFly == true then
            MovementComp.Velocity = UE4.FVector(0,0,0);
        else
            local LastTime = JumpCostTime - self.KeepTime;
            local TargetLoc = self.TargetLocation;
            if AnimInstance == nil then
                print("LiDaJump -- Animinstance is Not Valie!!")
            else
                local HeightSpeed = AnimInstance:GetCurveValue(HeightSpeedCurveName);
                local HorizontalSpeed = AnimInstance:GetCurveValue(HorizontalSpeedCurveName);

                local Offset = TargetLoc - Launcher:K2_GetActorLocation();
                Offset.Z = 0;
                -- local Size = Offset:Size();
                -- local HorizentalSpeed = Size /LastTime;
                local Direction = UE4.UKismetMathLibrary.Normal(Offset);
        
                local CurrentHeightOffset = UE4.UKismetMathLibrary.Multiply_VectorFloat(UE4.FVector(0,0,1), HeightSpeed);
                local CurrentDistanceOffset = UE4.UKismetMathLibrary.Multiply_VectorFloat(Direction, HorizontalSpeed);
                print("TargetLocation is : ", self.TargetLocation , "Launcher Location is :", Launcher:K2_GetActorLocation())
                local JumpVelocity = CurrentHeightOffset + CurrentDistanceOffset;
                
                MovementComp.Velocity = JumpVelocity;
            end
        end

    else
        MovementComp:SetMovementMode(UE4.EMovementMode.Move_Falling)
        MovementComp.Velocity = Velocity;
    end
end

function LiDaJump:OnMoveTickCheck(DeltaTime)
    local MovementComp = self:GetMovementComp();
    if self:CheckJump(MovementComp) == true then
        self:MoveFinish(MovementComp);
    end
end

function LiDaJump:OnMoveBlock(HitResult)
    if self == nil then
        return
    end
    self.bEndFly = true;
end

function LiDaJump:OnMoveEnd(MovementComp)
    local bOptimizeNavWalk = false
    local OwnerChar = MovementComp:GetOwner():Cast(UE4.AGameCharacter)
    if OwnerChar ~= nil then
        if OwnerChar:IsOptimizeNavWalk() == true then
            bOptimizeNavWalk = true
        end
    end

    if bOptimizeNavWalk == false then
        MovementComp:SetMovementMode(UE4.EMovementMode.MOVE_Walking)
    else
        MovementComp:SetMovementMode(UE4.EMovementMode.MOVE_NavWalking)
    end
    
    self:DeActiveSpawnedByEmitter()
    self:Destroy();
end

function LiDaJump:CheckJump(MovementComp)
    local OwnerChar = MovementComp:GetOwner():Cast(UE4.AGameCharacter)
    if OwnerChar ~= nil then
        local Cap = OwnerChar.CapsuleComponent;
        local FloorResult = MovementComp:K2_FindFloor(Cap:K2_GetComponentLocation());

        if FloorResult.bWalkableFloor == true and self.KeepTime >= 0.5 then
            return true;
        end
    end

    return false
end

return LiDaJump;