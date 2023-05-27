---@class Magic_IgnoreEnmity:Magic
local Magic = Ability.DefineMagic('Slomo');

---@param Modifier UModifier
---@param Parameter table
function Magic:GetParameter(Modifier, Parameter)
    return UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(1));
end

function Magic:GetOrAddRecordTable(AbilityTarget, Modifier)
    if not self.RecordData then
        self.RecordData = {}
    end
    if not self.RecordData[AbilityTarget] then
        self.RecordData[AbilityTarget] = {}
    end

    local AbilityTargetInfo = self.RecordData[AbilityTarget]
    if not AbilityTargetInfo[Modifier] then
        AbilityTargetInfo[Modifier] = {}
    end

    return AbilityTargetInfo[Modifier]
end

function Magic:ClearRecordTable(AbilityTarget, Modifier)
    if self.RecordData and AbilityTarget and self.RecordData[AbilityTarget] and Modifier and self.RecordData[AbilityTarget][Modifier] then
        self.RecordData[AbilityTarget][Modifier] = nil
    end

    if self.RecordData and AbilityTarget and self.RecordData[AbilityTarget] and next(self.RecordData[AbilityTarget]) == nil then
        self.RecordData[AbilityTarget] = nil
    end
end

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffectr)
    local RecordTable = self:GetOrAddRecordTable(AbilityTarget, Modifier);

    local Target = AbilityTarget:GetOwner();
    if Target ~= nil and Target:HasAuthority() then
        RecordTable.OpenControlProtection = AbilityTarget:IsOpenControlProtection()
        local InControlProtection = RecordTable.OpenControlProtection and AbilityTarget:IsInControlProtectionTimeCall();
        local Value = self:GetParameter(Modifier , Parameter);
        -- print("Pree Target.CustomTimeDilation ", Target.CustomTimeDilation, ' -- ', Target);
        if not InControlProtection and Value ~= 0 then
            if Modifier.bScaleSlomo then
                UE4.AGamePlayerController.ScaleActorTimeDilation(Target, Modifier.SlomPriority, Value)
            else
                UE4.AGamePlayerController.SetActorTimeDilation(Target, Modifier.SlomPriority, Value)
            end
            -- print("Start Target.CustomTimeDilation ", Target.CustomTimeDilation, ' ---- ', Target.CurrentTimeDilationValue, ' -- ', Target, "  Value :", Value);
            if RecordTable.OpenControlProtection then
                AbilityTarget:SetBeginNewAbnormalControlStateCall()
                RecordTable.MagicBornSuccess = true;
            end
        end

        if RecordTable.OpenControlProtection and not RecordTable.MagicBornSuccess then
            AbilityTarget:HandleFlyImmuneControl(Modifier:GetLauncher(), "modifier.immune")
            Modifier.LifeTime = 0.0;
            print("Slomo Block")
        end
    end
    Modifier:LogReceiveAbnormalState(true)
    return true;
end

function Magic:OnRemove(AbilityTarget, Modifier, Parameter)
    local RecordTable = self:GetOrAddRecordTable(AbilityTarget, Modifier);
    local Target = AbilityTarget:GetOwner();
    if Target ~= nil and Target:HasAuthority() then
        local Value = self:GetParameter(Modifier , Parameter);
        -- print("Check Target.CustomTimeDilation ", Target.CustomTimeDilation, ' -- ', Target, "  Value :", Value );
        if (not (RecordTable.OpenControlProtection and not RecordTable.MagicBornSuccess) and Value ~= 0.0) then
            if (Modifier.bScaleSlomo) then
                UE4.AGamePlayerController.ScaleActorTimeDilation(Target, Modifier.SlomPriority, 1.0 / (Value ^ Modifier.CurOverlaid))
            else
                UE4.AGamePlayerController.SetActorTimeDilation(Target, Modifier.SlomPriority, 1.0)
            end
            -- print("End Target.CustomTimeDilation ", Target.CustomTimeDilation, ' ---- ', Target.CurrentTimeDilationValue, " --- ", Target);
            if(RecordTable.OpenControlProtection) then
                AbilityTarget:SetEndNewAbnormalControlStateCall()
                RecordTable.MagicBornSuccess = nil;
            end
        end
    end
    
    Modifier:LogReceiveAbnormalState(false)
    self:ClearRecordTable(AbilityTarget, Modifier);
    return true;
end

return Magic;