---@class Magic_NoCostFightPower:Magic
local Magic = Ability.DefineMagic('NoCostFightPower');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
   
    local path = string.format("/Game/Blueprints/Ability/Buffer/State_NoCostFightPower.State_NoCostFightPower_C");
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
    local path = string.format("/Game/Blueprints/Ability/Buffer/State_NoCostFightPower.State_NoCostFightPower_C");
    return path;
end

return Magic;