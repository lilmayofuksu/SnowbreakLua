-- ========================================================
-- @File    : DragToGoal_Update.lua
-- @Brief   : 朝着指定坐标拉扯
-- @Author  : Xiong
-- @Date    : 2020-05-09
-- ========================================================

---@class USkillMove_DragToGoal_Update:USkillMove
local DirectionDrag_Update = Class();

function DirectionDrag_Update:IsUsedToAddVelocityInsteadOverride()
    return true;
end

---@param Launcher ACharacter使用者
---@param MovementComp MovementComponent的对象
function DirectionDrag_Update:OnMoveStart(Launcher , MovementComp)
end

---@param DeltaTime float 间隔时间
---@param Friction float 摩擦
---@param Fluid bool 是否为流体
---@param BrakingDeceleration float 制动减速
function DirectionDrag_Update:OnMoveTick(DeltaTime , Friction , Fluid , BrakingDeceleration , MovementComp)
    --- Param1 : 拉扯持续速度
    local DragSpeed = self:GetParamfloatValue(0)

    --- Param2 : 拉扯到位置后是否停止
    local bNeedStop = self:GetParamboolValue(1)


    local ChracterLoc = MovementComp:GetOwner():K2_GetActorLocation();
    local TargetLoc = self.TargetLocation;
    local Dir =  UE4.UKismetMathLibrary.Normal(TargetLoc);
    local MoveDistance = DragSpeed * DeltaTime;
    local NewOffset = UE4.UKismetMathLibrary.Multiply_VectorFloat(Dir,MoveDistance);
    
    local CharacterRef = MovementComp:GetOwner():Cast(UE4.AGameCharacter);
    if CharacterRef ~= nil then
        UE4.UAbilityFunctionLibrary.AddCharacterOffset(CharacterRef, NewOffset);
    end

end

function DirectionDrag_Update:OnMoveEnd(MovementComp)
    self:Destroy();
end

return DirectionDrag_Update;