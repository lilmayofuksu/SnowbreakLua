-- ========================================================
-- @File    : Teleport.lua
-- @Brief   : 传送
-- @Author  : XiongHongJi
-- @Date    : 2021-09-02
-- ========================================================

---@class USkillEmitter_Teleport:USkillEmitter
local SummonTeleportCast = Class()

function SummonTeleportCast:OnEmitSearch()
    EmitterSearcher:OnEmitSearch(self)
end

---@param Skill USkill
function SummonTeleportCast:OnEmit()
    ---召唤物ID
    local EmitterInfo = self:GetEmitterInfo()
    local SummonID = self:GetParamintValue(0)
    local SkillID = self:GetParamintValue(1)
    ---目标拥有Tag
    local Tag = self:GetParamValue(2)
    local bUseSummonCustomSlot = self:GetParamboolValue(3)
   

    local Launcher = self:GetSkillLauncher():GetCharacterController():K2_GetPawn()
    if Launcher ~= nil then
        local Team = Launcher.AIControlData.Team
        if Team == nil then
            return UE4.EEmitterResult.Finish
        end

        local AllSummon = Team:GetAllMembersPtr(true)
        if AllSummon:Length() == 0 then
            return UE4.EEmitterResult.Finish
        end

        for i = 1, AllSummon:Length() do
            local Summon = AllSummon:Get(i)
            if
                Summon:GetCharacterIsEnable() == true and Summon:GetTemplateID() == SummonID and
                    (Summon:ActorHasTag(Tag) or UE4.UKismetStringLibrary.IsEmpty(Tag))
             then
                if bUseSummonCustomSlot then
                    Summon:K2_SetActorLocation(Summon:GetCustomTeamSlot():K2_GetActorLocation())
                else
                    if self.QueryResults:Length() > 0 then
                        Summon:K2_SetActorLocation(self.QueryResults:Get(1).QueryPoint)
                    end
                end

                local Result =
                    UE4.UAbilityFunctionLibrary.MakeQueryResult_AdjustToTarget(
                    Summon,
                    EmitterInfo.ApplyLocationType
                )
                self:ApplyMagicToActor(Result, Result.QueryPoint, Launcher:K2_GetActorLocation())
                Summon.Ability:CastSkill(SkillID, UE4.ESkillCastType.Auto)
            end
        end
    end
    return UE4.EEmitterResult.Finish
end

function SummonTeleportCast:ApplyEffect(Center, Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self)
    UE4.USkillEmitter.EmitterAnchorEffectPlay(
        self:GetSkillLauncher(),
        self:GetEmitterInfo(),
        Center,
        UE4.UKismetMathLibrary.Quat_Rotator(Rotator),
        HashIndex,
        self.QueryResults
    )
end

function SummonTeleportCast:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self)
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(), HashIndex,self:GetEmitterInfo())
end


function SummonTeleportCast:EmitterDestroyLua()
    self:Destroy()
end

return SummonTeleportCast
