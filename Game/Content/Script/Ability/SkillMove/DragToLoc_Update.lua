-- ========================================================
-- @File    : DragToLoc_Update.lua
-- @Brief   : 技能冲锋
-- @Author  : Xiong
-- @Date    : 2020-05-09
-- ========================================================

---@class USkillMove_DragToLoc_Update:USkillMove
local DragToLoc_Update = Class();

function DragToLoc_Update:IsUsedToAddVelocityInsteadOverride()
    return true;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function DragToLoc_Update:OnMoveStart(Launcher , MovementComp)
    local ParamsLength = self:GetParamLength()
    local MoveDistanceFuncParam = UE4.FVector2D(1,0)
    if ParamsLength > 3 then
        MoveDistanceFuncParam = self:GetFVector2DValue(3); 
    end
    
    self.FinalTargetLocation = self:CalcTargetLoc(MoveDistanceFuncParam, MovementComp);
    print("Final Target Location is : ", self.FinalTargetLocation)
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function DragToLoc_Update:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)
    --- Param1 : 拉扯持续速度
    local DragSpeed = self:GetParamfloatValue(0)
    --- Param2 : 拉扯到位置后是否停止
    local bNeedStop = self:GetParamboolValue(1)
    local ParamsLength = self:GetParamLength()
    local StopOffset = 10
    if ParamsLength > 2 then
        StopOffset = self:GetParamfloatValue(2); 
    end
    
    local ChracterLoc = MovementComp:GetOwner():K2_GetActorLocation();

    local Offset = self.FinalTargetLocation - ChracterLoc;
    Offset.Z = 0.0;
    local Distance = UE4.UKismetMathLibrary.VSize(Offset);
    local Dir =  UE4.UKismetMathLibrary.Normal(Offset);
    local MoveDistance = DragSpeed * DeltaTime;

    if Distance > StopOffset then
        local NewOffset = UE4.UKismetMathLibrary.Multiply_VectorFloat(Dir,MoveDistance);

        local CharacterRef = MovementComp:GetOwner():Cast(UE4.AGameCharacter);
        if CharacterRef ~= nil then
            UE4.UAbilityFunctionLibrary.AddCharacterOffset(CharacterRef, NewOffset);
        end

    else
        if bNeedStop == true then
            MovementComp:RemoveUpdateSkillMove(self);
        end
    end
end

function DragToLoc_Update:CalcTargetLoc(InMoveDistanceFuncParam, InMovement)
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

function DragToLoc_Update:OnMoveEnd(MovementComp)
    self:Destroy();
end

return DragToLoc_Update;