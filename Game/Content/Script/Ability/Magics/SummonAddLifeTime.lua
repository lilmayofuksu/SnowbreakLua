---@class Magic_SummonAddLifeTime:Magic
local Magic = Ability.DefineMagic('SummonAddLifeTime');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    if not AbilityTarget then return end

    local nSummonID = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(1));
    local nLifeTime = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(2));
    local nLefeTimePer = -1
    if Parameter.Params:Length() >= 3 then
        nLefeTimePer = UE4.UAbilityFunctionLibrary.GetParamfloatValue(Parameter.Params:Get(3));
    end
    local bSumonSon = false
    if Parameter.Params:Length() >= 4 then
        bSumonSon = Parameter.Params:Get(4).ParamValue == "召唤物"
    end
    local bPercent = nLefeTimePer > 0
    local lpCharacter = AbilityTarget:GetOriginCharacter()
    if not lpCharacter then return end
    if bSumonSon == false then
        local AllSummon = UE4.TArray(UE4.AGameCharacter)
        lpCharacter:GetAllSummoned(AllSummon)
        for i = 1, AllSummon:Length() do
            local lpSummon = AllSummon:Get(i)       
            if lpSummon then                
                local AppearID = lpSummon:GetAppearID()
                if nSummonID <= 0 or AppearID == nSummonID then            
                    local nLifeSpan = lpSummon:GetLifeSpan()
                    if nLifeSpan > 0 then
                        local nInitialLifeSpan = lpSummon.InitialLifeSpan
                        if bPercent then
                            lpSummon:SetLifeSpan(nInitialLifeSpan * nLefeTimePer * 0.01 + nLifeSpan)
                        else
                            lpSummon:SetLifeSpan(nLifeTime + nLifeSpan)
                        end
                        lpSummon.InitialLifeSpan = nInitialLifeSpan
                    end
                end
            end
        end
    else
        if lpCharacter:IsSummon() or lpCharacter:IsTrap() then
            local lpSummon = lpCharacter
            local AppearID = lpSummon:GetAppearID()
            if nSummonID <= 0 or AppearID == nSummonID then            
                local nLifeSpan = lpSummon:GetLifeSpan()
                if nLifeSpan > 0 then
                    local nInitialLifeSpan = lpSummon.InitialLifeSpan
                    if bPercent then
                        lpSummon:SetLifeSpan(nInitialLifeSpan * nLefeTimePer * 0.01 + nLifeSpan)
                    else
                        lpSummon:SetLifeSpan(nLifeTime + nLifeSpan)
                    end
                    lpSummon.InitialLifeSpan = nInitialLifeSpan
                end
            end
        end
    end
    return true;
end


return Magic;