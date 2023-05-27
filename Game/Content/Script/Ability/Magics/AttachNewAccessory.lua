---@class Magic_AttachNewAccessory  给目标增加新的挂件
local Magic = Ability.DefineMagic('AttachNewAccessory');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)

    local AccessoryPath = Parameter.Params:Get(1).ParamValue;
    local ClassPath = UE4.UKismetSystemLibrary.MakeSoftObjectPath(AccessoryPath);
    local AccessoryClass = UE4.UClass.Load(ClassPath.AssetPathName);
    if AccessoryClass ~= nil then
        local TargetCharacter = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
        if TargetCharacter ~= nil then
            TargetCharacter:AttachCharacterAccessory(AccessoryClass);
        end
    end
    return true;
end

function Magic:OnRemove(AbilityTarget,Modifier, Parameter, CurOverlaid)
    local AccessoryPath = Parameter.Params:Get(1).ParamValue;
    local ClassPath = UE4.UKismetSystemLibrary.MakeSoftObjectPath(AccessoryPath);
    local AccessoryClass = UE4.UClass.Load(ClassPath.AssetPathName);
    if AccessoryClass ~= nil then
        local TargetCharacter = AbilityTarget:GetOwner():Cast(UE4.AGameCharacter);
        if TargetCharacter ~= nil then
            local AccessoryRef = TargetCharacter:GetAccessoryByClass(AccessoryClass);
            if AccessoryRef ~= nil then
                local bHasLeaveFunc = UE4.UAbilityFunctionLibrary.IsBpFunctionExsit(AccessoryRef, "AccessoryLeave");
                if bHasLeaveFunc == true then
                    UE4.UAbilityFunctionLibrary.ProcessBpFunction(AccessoryRef, "AccessoryLeave");
                else
                    AccessoryRef:SetActorHiddenInGame(true)
                    AccessoryRef:SetOwner(nil)
                    AccessoryRef:SetLifeSpan(0.1)
                end

            end
        end
    end
    return true;
end


return Magic;