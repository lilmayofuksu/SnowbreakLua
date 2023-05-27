---@class Magic_Invisible:Magic
local Magic = Ability.DefineMagic('Invisible');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    local Target = AbilityTarget;
    local CharacterTarget = Target:GetOwner():Cast(UE4.AGameCharacter);
    if CharacterTarget ~= nil then
        -- Start Invisible Render
        local RenderComp = CharacterTarget.CharacterRenderComponent;
        local ID = RenderComp:StartCharacterStateSimple(UE4.ECharacterRenderStateType.Invisible, 0);
        RenderComp:UpdateMaterialScalarParameters(ID, "DepthOpacityScale", 0.5);
        Modifier.RenderStateID = ID;
    end

    return true;
end--[[  ]]


function Magic:OnRemove(AbilityTarget, Modifier, Parameter)
    local Target = AbilityTarget;
    local CharacterTarget = Target:GetOwner():Cast(UE4.AGameCharacter);
    if CharacterTarget ~= nil then
        local RenderComp = CharacterTarget.CharacterRenderComponent;
        RenderComp:EndCharacterState(Modifier.RenderStateID);
    end

    return true;
end

return Magic;