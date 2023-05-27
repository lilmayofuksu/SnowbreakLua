-- ========================================================
-- @File    : NotifyListener.lua
-- @Brief   : Notify监听器
-- @Author  : XiongHongJi
-- @Date    : 2020-5-11
-- ========================================================

---@class NotifyListener 用于检测异常状态的结束
NotifyListener = {}


---检测击飞状态是否结束
---@param Emitter UEmitter 对应的Emitter对象
---@param NotifyParamName FString Notify对应参数的名字
function NotifyListener.AbilityNotifyTrigger(Skill , NotifyParamName)

    if NotifyParamName == "OpenHalfSkill" then
        if Skill:GetCharacter() ~= nil then
            local Char = Skill:GetCharacter();
            Char:SetInHalfSkillMontage(true);
        end
    end

    if NotifyParamName == "CloseHalfSkill" then
        if Skill:GetCharacter() ~= nil then
            local Char = Skill:GetCharacter();
            Char:SetInHalfSkillMontage(false);
        end
    end

    if NotifyParamName == "OpenFire" then
        if Skill:GetOwner() ~= nil then
            local Ability = Skill:GetOwner():Cast(UE4.UAbilityComponent);
            if Ability ~= nil then
                Ability.bCanFireNow = true;
            end
        end
    end

    if NotifyParamName == "CloseFire" then
        local Ability = Skill:GetOwner():Cast(UE4.UAbilityComponent);
        if Ability ~= nil then
            Ability.bCanFireNow = false;
        end
    end

    if NotifyParamName == "SamePriorityBreakPoint" then
        if Skill ~= nil then
            Skill.bSamePriorityBreakable = true;
        end
    end
end

function NotifyListener.NotifyTrigger(Skill , Notify)
end

function NotifyListener.NotifyStateTrigger(Skill , NotifyStateClass)
end