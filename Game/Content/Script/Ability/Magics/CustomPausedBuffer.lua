---@class Magic_CustomPausedBuffer:Magic
local Magic = Ability.DefineMagic('CustomPausedBuffer');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    
    local BufferName = Parameter.Params:Get(1).ParamValue;
    local path = string.format("/Game/Blueprints/Ability/Buffer/%s.%s_C" , BufferName , BufferName);
    local BufferClass = UE4.UClass.Load(path);

    local PausedFlag =  UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(2));
    print(string.format("CustomPausedBuffer Born : Set [%s] Buffer bCustomPaused to [%s] :", BufferName, PausedFlag))
    local Buffers = AbilityTarget:GetActiveAbilityBuffer(BufferClass);
    for i = 1, Buffers:Length() do 
        Buffers:Get(i).bCustomPaused = PausedFlag;
    end
    
    return true;
end

function Magic:OnExec(AbilityTarget,Modifier, Parameter, CurOverlaid)

    local BufferName = Parameter.Params:Get(1).ParamValue;
    local path = string.format("/Game/Blueprints/Ability/Buffer/%s.%s_C" , BufferName , BufferName);
    local BufferClass = UE4.UClass.Load(path);

    local PausedFlag =  UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(2));
    print(string.format("CustomPausedBuffer Exec : Set [%s] Buffer bCustomPaused to [%s] :", BufferName, PausedFlag))
    local Buffers = AbilityTarget:GetActiveAbilityBuffer(BufferClass);
    for i = 1, Buffers:Length() do 
        Buffers:Get(i).bCustomPaused = PausedFlag;
    end
    
    return true;

end


function Magic:OnRemove(AbilityTarget, Modifier, Parameter)

    local BufferName = Parameter.Params:Get(1).ParamValue;
    local path = string.format("/Game/Blueprints/Ability/Buffer/%s.%s_C" , BufferName , BufferName);
    local BufferClass = UE4.UClass.Load(path);

    local PausedFlag =  not UE4.UAbilityFunctionLibrary.GetParamboolValue(Parameter.Params:Get(2));
    print(string.format("CustomPausedBuffer Remove : Set [%s] Buffer bCustomPaused to [%s] :", BufferName, PausedFlag))
    local Buffers = AbilityTarget:GetActiveAbilityBuffer(BufferClass);
    for i = 1, Buffers:Length() do 
        Buffers:Get(i).bCustomPaused = PausedFlag;
    end
    
    return true;
end
function Magic:GetAssetPath(Parameter)
    local BufferName = Parameter.Params:Get(1).ParamValue;
    local path = string.format("/Game/Blueprints/Ability/Buffer/%s.%s_C" , BufferName , BufferName);
    return path;
end
return Magic;