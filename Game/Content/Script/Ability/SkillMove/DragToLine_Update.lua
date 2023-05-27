-- ========================================================
-- @File    : DragToLine_Update.lua
-- @Brief   : 朝着指定线拉扯
-- @Author  : Xiong
-- @Date    : 2020-05-09
-- ========================================================

---@class USkillMove_DragToLine_Update:USkillMove
local DragToLine_Update = Class();

function DragToLine_Update:IsUsedToAddVelocityInsteadOverride()
    return true;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function DragToLine_Update:OnMoveStart(Launcher , MovementComp)
    local MoveDistanceFuncParam = UE4.FVector2D(1,0)
    local ParamsLength = self:GetParamLength()
    if ParamsLength > 3 then
        MoveDistanceFuncParam = self:GetFVector2DValue(3); 
    end

    local TargetLoc = self:CalcTargetLoc(MoveDistanceFuncParam, MovementComp);
    print("ToLine Location is : ", TargetLoc)
    local ChracterLoc = MovementComp:GetOwner():K2_GetActorLocation();
    self.FinalTargetLoc = TargetLoc;
    self.Offset = self.FinalTargetLoc - ChracterLoc;
    self.Dir =  UE4.UKismetMathLibrary.Normal(self.Offset);
    print("Monster name : ", MovementComp:GetOwner():GetName(),  " Offset is :", self.Dir)
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function DragToLine_Update:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)
    --- Param1 : 拉扯持续速度
    local DragSpeed = self:GetParamfloatValue(0)
    --- Param2 : 拉扯到位置后是否停止
    local bNeedStop = self:GetParamboolValue(1)
    
    local ParamsLength = self:GetParamLength()
    local StopOffset = 60
    if ParamsLength > 2 then
        StopOffset = self:GetParamfloatValue(2); 
    end

    local MoveDistance = DragSpeed * DeltaTime;
    local ChracterLoc = MovementComp:GetOwner():K2_GetActorLocation();
    local MoveOffset = self.FinalTargetLoc - ChracterLoc;
    local Distance = UE4.UKismetMathLibrary.Dot_VectorVector(MoveOffset, self.Dir);
    if Distance > StopOffset then
        local NewOffset = UE4.UKismetMathLibrary.Multiply_VectorFloat(self.Dir,MoveDistance);

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


function DragToLine_Update:CalcTargetLoc(InMoveDistanceFuncParam, InMovement)
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

function DragToLine_Update:OnMoveEnd(MovementComp)
    self:Destroy();
end

return DragToLine_Update;