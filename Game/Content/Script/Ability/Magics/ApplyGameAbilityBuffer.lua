---@class Magic_ApplyGameAbilityBuffer:Magic
local Magic = Ability.DefineMagic('ApplyGameAbilityBuffer');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    local BufferName = Parameter.Params:Get(1).ParamValue;
    local path = string.format("/Game/Blueprints/Ability/Buffer/%s.%s_C" , BufferName , BufferName);
    local BufferClass = UE4.UClass.Load(path)
    if BufferClass == nil then
        print("Bufferpath is not valid :", BufferName)
        return false;
    else
        -- local Buffer = AbilityTarget:ActiveAbilityBuffer(BufferClass, Modifier.Launcher, Parameter, nil, Modifier.Level, Modifier)
        -- if Buffer == nil then
        --     print("Buffer class is not valid :", BufferName)
        -- end
    end
    return true;
end

function Magic:OnExec(AbilityTarget,Modifier, Parameter, CurOverlaid)
    local BufferName = Parameter.Params:Get(1).ParamValue;
    local path = string.format("/Game/Blueprints/Ability/Buffer/%s.%s_C" , BufferName , BufferName);
    local BufferClass = UE4.UClass.Load(path)
    if BufferClass == nil then
        print("Bufferpath is not valid :", BufferName)
        return false;
    else
        -- local Buffer = AbilityTarget:ActiveAbilityBuffer(BufferClass, Modifier.Launcher, Parameter, nil, Modifier.Level, Modifier)
        -- if Buffer == nil then
        --     print("Buffer class is not valid :", BufferName)
        -- end
    end
    return true;
end

function Magic:OnRemove(AbilityTarget, Modifier, Parameter)
    return true;
end

return Magic;