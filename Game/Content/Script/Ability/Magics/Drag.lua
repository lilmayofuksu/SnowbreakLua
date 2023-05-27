---@class Magic_IgnoreEnmity:Magic
local Magic = Ability.DefineMagic('Drag');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    ---拖拽的模式
    local Launcher = Modifier:GetLauncher():GetOwner();
    local Target = AbilityTarget;
    local OriginLoc = Modifier.OriginLocation;

    local SkillName = self:GetAssetName(Parameter)

    -- local MoveClass = UE4.UClass.Load(path)
    local GameCharacter = Target:GetOwner():Cast(UE4.AGameCharacter);

    if GameCharacter ~= nil then
        UE4.USkillMove.CreatSkillMoveByMagic(OriginLoc, Launcher, GameCharacter, Parameter, Modifier, SkillName);
    end
    Modifier:LogReceiveAbnormalState(true)
    return true;
end

function Magic:OnRemove(AbilityTarget, Modifier, Parameter)

    local Target = AbilityTarget;

    local GameCharacter = Target:GetOwner():Cast(UE4.AGameCharacter);

    if GameCharacter ~= nil then
        UE4.USkillMove.CancleSkillMoveByMagic(GameCharacter, Modifier.RunTimeID);
    end
    Modifier:LogReceiveAbnormalState(false)
    return true;
end

function Magic:GetAssetName(Parameter)
    local DragType = UE4.UAbilityFunctionLibrary.GetParamintValue(Parameter.Params:Get(1));
    --local path = string.format("/Game/Blueprints/Ability/SkillMove/SkillMove_DragToGoal.SkillMove_DragToGoal_C");
    local SkillName = "SkillMove_DragToGoal"

    if  DragType == 0 then
        -- path = string.format("/Game/Blueprints/Ability/SkillMove/SkillMove_DragToGoal_Update.SkillMove_DragToGoal_Update_C");
        SkillName = "SkillMove_DragToGoal"
    end
    if DragType == 1 then
        -- path = string.format("/Game/Blueprints/Ability/SkillMove/SkillMove_DragToLoc_Update.SkillMove_DragToLoc_Update_C");
        SkillName = "SkillMove_DragToLoc_Update"
    end
    
    if  DragType == 2 then
        -- path = string.format("/Game/Blueprints/Ability/SkillMove/SkillMove_DragToGoal.SkillMove_DragToGoal_C");
        SkillName = "SkillMove_DragToGoal"
    end
    if DragType == 3 then
        -- path = string.format("/Game/Blueprints/Ability/SkillMove/SkillMove_DragToLoc.SkillMove_DragToLoc_C");
        SkillName = "SkillMove_DragToLoc"
    end
    if  DragType == 4 then
        -- path = string.format("/Game/Blueprints/Ability/SkillMove/SkillMove_DragToLine_Update.SkillMove_DragToLine_Update_C");
        SkillName = "SkillMove_DragToLine_Update"
    end
    -- return path;
    return SkillName
end

function Magic:GetAssetPath(Parameter)
    local SkillName = self:GetAssetName(Parameter)
    return string.format("/Game/Blueprints/Ability/SkillMove/%s.%s_C", SkillName, SkillName);
end

return Magic;