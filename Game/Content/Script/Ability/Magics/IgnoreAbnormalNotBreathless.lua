---@class Magic_IgnoreAbnormalNotBreathless:Magic
local Magic = Ability.DefineMagic('IgnoreAbnormalNotBreathless');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    -- Modifier.StateInfo.bCanEnterAbnormal = false;
    if Modifier == nil then
        return
    end
    local path = string.format("/Game/Blueprints/Ability/Buffer/State_DisOutControllableNotBreathless.State_DisOutControllableNotBreathless_C");
    local BufferClass = UE4.UClass.Load(path)

    local Buffer = AbilityTarget:ActiveAbilityBuffer(BufferClass, Modifier.Launcher, Parameter.Params, nil, Modifier.Level, Modifier)
    if Buffer == nil then
        print("Buffer class is not valid :", BufferName)
    end
    Modifier.BufferRefs:Add(Buffer);
    return true;
end


function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    return true;
end
function Magic:GetAssetPath(Parameter)
    local path = string.format("/Game/Blueprints/Ability/Buffer/State_DisOutControllableNotBreathless.State_DisOutControllableNotBreathless_C");
    return path;
end
return Magic;