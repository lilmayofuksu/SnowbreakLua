---@class Magic_ChangeCollimationUI  修改准心UI、弹夹UI
local Magic = Ability.DefineMagic('ChangeCollimationUI');

function Magic:OnBorn(AbilityTarget, Modifier, Parameter, bKeepEffect)
    local lpWeapon = nil
    if AbilityTarget then
        local lpCharacter = AbilityTarget:GetOriginCharacter()
        if not lpCharacter then return true end
        lpWeapon = lpCharacter:GetWeapon()                
    end
    if not lpWeapon then return true end

    local Params = Parameter.Params
    local ParamNum = Params:Length()
    for idx = 1, ParamNum do
        local tb = Eval(Params:Get(idx).ParamValue)
        if #tb >= 2 then
            local name = tb[1]
            local path = tb[2]
            path = string.sub(path, 0, #path-1) .. "_C'"
            if tb[1] == "准心" then
                lpWeapon:SetCrossHairUI(path)
            elseif tb[1] == "瞄准准心" then
                lpWeapon:SetAimCrossHairUI(path)
            elseif tb[1] == "弹夹" then
                lpWeapon:SetAmmunitionUI(path)
            end
        end
    end
    return true;
end

function Magic:OnRemove(AbilityTarget,Modifier, Parameter, CurOverlaid)
    local lpWeapon = nil
    if AbilityTarget then
        local lpCharacter = AbilityTarget:GetOriginCharacter()
        if not lpCharacter then return true end
        lpWeapon = lpCharacter:GetWeapon()                
    end
    if not lpWeapon then return true end

    local Params = Parameter.Params
    local ParamNum = Params:Length()
    for idx = 1, ParamNum do
        local tb = Eval(Params:Get(idx).ParamValue)
        if #tb >= 2 then
            local name = tb[1]
            local path = tb[2]
            if tb[1] == "准心" then
                lpWeapon:SetCrossHairUI("")
            elseif tb[1] == "瞄准准心" then
                lpWeapon:SetAimCrossHairUI("")
            elseif tb[1] == "弹夹" then
                lpWeapon:SetAmmunitionUI("")
            end
        end
    end
    return true;
end


return Magic;