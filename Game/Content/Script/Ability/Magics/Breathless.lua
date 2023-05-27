---@class Magic_Breathless:Magic
local Magic = Ability.DefineMagic('Breathless');

---@param Modifier UModifier
---@param Parameter table
function Magic:GetParameter(Modifier, Parameter)
    return UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(1));
end

---@param Modifier UModifier
---@param Parameter table
function Magic:GetModifyParam(Modifier, Parameter)
    return true, self:GetParameter(Modifier, Parameter);
end

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local Launcher = Modifier:GetLauncher();
    local Target = AbilityTarget;

    local AbnormalInfo = UE4.FAbnormalInfo();
    AbnormalInfo.AbnormalCauser = Launcher:GetOwner();
    AbnormalInfo.AbnormalState = UE4.EAbnormalState.Breathless;
    AbnormalInfo.KeepTime = Target:K2_GetCardGrowTemplateData().BreathlessTime;
    AbnormalInfo.AppliedModifierRunTimeID = Modifier.RunTimeID;
    if Target ~= nil then
        local bSuccess = Target:ReceiveAbnormalState(UE4.EAbnormalState.Breathless, AbnormalInfo);
        if bSuccess == false then
            Modifier.LifeTime = 0.0;
        end
    end
    Modifier:LogReceiveAbnormalState(true)
    return true;
end

function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    local Launcher = Modifier:GetLauncher();
    local Target = AbilityTarget;

    if Target ~= nil then
        Target:RemoveAbnormalState(UE4.EAbnormalState.Breathless,Modifier.RunTimeID);
        Modifier:LogReceiveAbnormalState(false)
    end
    return true;
end


return Magic;