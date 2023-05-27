---@class Magic_InvalidSpecifiedSkill:Magic
local Magic = Ability.DefineMagic('InvalidSpecifiedSkill');

function Magic:OnBorn(AbilityTarget,Modifier, Parameter, bKeepEffect)
    local strSkillNames = Parameter.Params:Get(1).ParamValue;
    local InvalidIndex = AbilityTarget:GetInvalidSpecifiedSkill();
    if string.find(strSkillNames, "常规技") then
        InvalidIndex = SetBits(InvalidIndex, 1, 1, 1)
        InvalidIndex = SetBits(InvalidIndex, 1, 2, 2)
    end
    if string.find(strSkillNames, "QTE") then
        InvalidIndex = SetBits(InvalidIndex, 1, 3, 3)
    end
    if string.find(strSkillNames, "大招") then
        InvalidIndex = SetBits(InvalidIndex, 1, 4, 4)
    end
    AbilityTarget:SetInvalidSpecifiedSkill(InvalidIndex);

    return true;
end


function Magic:OnRemove(AbilityTarget,Modifier, Parameter)
    local strSkillNames = Parameter.Params:Get(1).ParamValue;
    local InvalidIndex = AbilityTarget:GetInvalidSpecifiedSkill();
    if string.find(strSkillNames, "常规技") then
        InvalidIndex = SetBits(InvalidIndex, 0, 1, 1)
        InvalidIndex = SetBits(InvalidIndex, 0, 2, 2)
    end
    if string.find(strSkillNames, "QTE") then
        InvalidIndex = SetBits(InvalidIndex, 0, 3, 3)
    end
    if string.find(strSkillNames, "大招") then
        InvalidIndex = SetBits(InvalidIndex, 0, 4, 4)
    end
    AbilityTarget:SetInvalidSpecifiedSkill(InvalidIndex);
    return true;
end

return Magic;