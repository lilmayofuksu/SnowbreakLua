-- ========================================================
-- @File    : SummonApplied.lua
-- @Brief   : 作用技能效果到召唤物上
-- @Author  : XiongHongJi
-- @Date    : 2020-09-02
-- ========================================================

---@class USkillEmitter_Teleport:USkillEmitter
local SummonApplied = Class()


function SummonApplied:OnEmit()
     ---目标拥有Tag
    local EmitterInfo = self:GetEmitterInfo()
    local SummonTag = self:GetParamValue(0)

    local Launcher = self:GetInstigator();
    if Launcher ~= nil then
        local Team = Launcher.AIControlData.Team;
        local AllDrones = Team:GetAllMembersPtr(true);
        if AllDrones:Length() == 0 then
            return UE4.EEmitterResult.Finish;
        end
        for i = 1, AllDrones:Length() do
            print("Try SummonApplied")
            if AllDrones:Get(i):ActorHasTag(SummonTag) == true or UE4.UKismetStringLibrary.IsEmpty(SummonTag) then
                local Result = UE4.UAbilityFunctionLibrary.MakeQueryResult_AdjustToTarget(AllDrones:Get(i), EmitterInfo.ApplyLocationType);
                self:ApplyMagicToActor(Result, Result.QueryPoint, Launcher:K2_GetActorLocation() , 1);
            else
                print("Tag not find : ", SummonTag)
            end

        end
    end

    return UE4.EEmitterResult.Finish
end

function SummonApplied:ApplyEffect(Center,Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function SummonApplied:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end


function SummonApplied:EmitterDestroyLua()
    self:Destroy()
end

return SummonApplied