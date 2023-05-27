---@class Magic_ReplaceMesh:Magic
local Magic = Ability.DefineMagic('ReplaceMesh');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    local BodyMesh = Parameter.Params:Get(1).ParamValue;
    local HeadMesh = Parameter.Params:Get(2).ParamValue;

    local BodyMeshPath = string.format("/Game/%s" , BodyMesh);
    local HeadMeshPath = string.format("/Game/%s" , HeadMesh);
    local GameCharacter = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
    if GameCharacter ~= nil then
        GameCharacter:SetTempSkeletalMesh(BodyMeshPath);
    end
    return true;
end

function Magic:OnExec(AbilityTarget,Modifier, Parameter, CurOverlaid)
    local BodyMesh = Parameter.Params:Get(1).ParamValue;
    local HeadMesh = Parameter.Params:Get(2).ParamValue;

    local BodyMeshPath = string.format("/Game/%s" , BodyMesh);
    local HeadMeshPath = string.format("/Game/%s" , HeadMesh);
    local GameCharacter = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
    if GameCharacter ~= nil then
        GameCharacter:SetTempSkeletalMesh(BodyMeshPath);
    end
    return true;
end

function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    local GameCharacter = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
    if GameCharacter ~= nil then
        GameCharacter:ResetSkeletalMesh();
    end
    return true;
end

return Magic;