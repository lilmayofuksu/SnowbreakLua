---@class Magic_IgnoreEnmity:Magic
local Magic = Ability.DefineMagic('Drag');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)

    local DirectionOffset = UE4.UAbilityFunctionLibrary.GetFRotatorValue(Parameter.Params:Get(1));

    local Launcher = Modifier:GetLauncher():GetOwner();
    local Target = AbilityTarget;
    local Direction = Launcher:K2_GetActorRotation();
    
    Direction.Roll = DirectionOffset.Roll + Direction.Roll;
    Direction.Pitch = DirectionOffset.Pitch + Direction.Pitch;
    Direction.Yaw = DirectionOffset.Yaw + Direction.Yaw;

    local Forward = UE4.UKismetMathLibrary.GetForwardVector(Direction)
    -- local path = string.format("/Game/Blueprints/Ability/SkillMove/SkillMove_DirectionDrag_Update.SkillMove_DirectionDrag_Update_C");
    -- local MoveClass = UE4.UClass.Load(path)
    USkillMove.CreatSkillMoveByMagic(Forward, Launcher, Target:GetOriginCharacter(), Parameter, Modifier,  "SkillMove_DirectionDrag_Update");
    return true;
end

function Magic:OnRemove(AbilityTarget, Modifier, Parameter)
    local Target = AbilityTarget;
    UE4.USkillMove.CancleSkillMoveByMagic(Target:GetOriginCharacter(), Modifier.RunTimeID);
    return true;
end
function Magic:GetAssetPath(Parameter)
    local path = string.format("/Game/Blueprints/Ability/SkillMove/SkillMove_DirectionDrag_Update.SkillMove_DirectionDrag_Update_C");
    return path;
end
return Magic;