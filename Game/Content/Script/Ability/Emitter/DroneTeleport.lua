-- ========================================================
-- @File    : DroneTeleport.lua
-- @Brief   : 传送(小飞机专用)
-- @Author  : XiongHongJi
-- @Date    : 2020-09-02
-- ========================================================

---@class USkillEmitter_DroneTeleport:USkillEmitter
local DroneTeleport = Class()

---@param Skill USkill
function DroneTeleport:OnEmit()
    local EmitterInfo = self:GetEmitterInfo()
    ---召唤物ID
    local SummonID = self:GetParamintValue(0)
    ---Token的游戏路径
    local TokenPath = self:GetParamValue(1)
    ---是否需要传送
    local bNeedTeleport = self:GetParamboolValue(2)
    ---目标是否包含永久无人机
    local bIncludeMortalDrone = self:GetParamboolValue(3)
    ---目标拥有Tag
    local Tag = self:GetParamValue(4)

    local Token = UE4.UObject.Load(TokenPath)
    local Launcher = self:GetSkillLauncher()
    if Launcher ~= nil then
        local Team = Launcher.AIControlData.Team
        if Team == nil then
            return UE4.EEmitterResult.Finish
        end

        local AllDrones = Team:GetAllMembersPtr(true)
        if AllDrones:Length() == 0 then
            return UE4.EEmitterResult.Finish
        end

        --小飞机变换阵型时，阵型生成方向为角色技能最终期望朝向
        local PlayerMovement = Launcher.CharacterMovement:Cast(UE4.UPlayerMovementComponent)
        if PlayerMovement then
            local DesiredRotation = UE4.UKismetMathLibrary.Quat_Rotator(PlayerMovement:GetSkillDesiredRotation())
            Launcher:K2_SetActorRotation(DesiredRotation)
            Team:SetSpecialTeamSlotConfig(Token)
            Team:UpdateSlotConfig()
        else
            Team:SetSpecialTeamSlotConfig(Token)
            Team:UpdateSlotConfig()
        end
        for i = 1, AllDrones:Length() do
            local Drone = AllDrones:Get(i)
            if Drone:GetTemplateID() == SummonID then
                if bIncludeMortalDrone == false and Drone:IsImmortal() == true then
                else
                    if
                        Drone:GetCharacterIsEnable() == true and
                            (Drone:ActorHasTag(Tag) or UE4.UKismetStringLibrary.IsEmpty(Tag))
                     then
                        local DroneController = self:GetDroneController(Drone)
                        if DroneController ~= nil and bNeedTeleport == true then
                            local SceneTarget = DroneController:GetSceneTarget()
                            if SceneTarget ~= nil then
                                local SceneTransform = SceneTarget:GetTransform()
    
                                --1技能召唤出的小飞机和永久小飞机被2技能拉回时在原位置播放消失特效
                                if Drone:ActorHasTag("Casting Skill1") or Drone:IsImmortal() then
                                    self:ApplyEffect(Drone:K2_GetActorLocation(), Drone:K2_SetActorRotation())
                                end
                                AllDrones:Get(i).CharacterMovement.Velocity = UE4.FVector(0,0,0);
                                AllDrones:Get(i):K2_SetActorTransform(SceneTransform)
                                local Result =
                                    UE4.UAbilityFunctionLibrary.MakeQueryResult_AdjustToTarget(
                                    Drone,
                                    EmitterInfo.ApplyLocationType
                                )
                                self:ApplyMagicToActor(Result, Result.QueryPoint, Launcher:K2_GetActorLocation())
                            end
                        end
                    end
                end
            end
        end
    end
    return UE4.EEmitterResult.Finish
end

function DroneTeleport:OnEmitTick()
    ---召唤物ID
    local SummonID = self:GetParamintValue(0)
    ---Token的游戏路径
    local TokenPath = self:GetParamValue(1)
    ---是否需要传送
    local bNeedTeleport = self:GetParamboolValue(2)
    ---目标是否包含永久无人机
    local bIncludeMortalDrone = self:GetParamboolValue(3)
    ---目标拥有Tag
    local Tag = self:GetParamValue(4)

    local Token = UE4.UObject.Load(TokenPath)
    local Launcher = self:GetSkillLauncher()
    if Launcher ~= nil then
        local Team = Launcher.AIControlData.Team
        if Team == nil then
            return UE4.EEmitterResult.Finish
        end

        local AllDrones = Team:GetAllMembersPtr(true)
        if AllDrones:Length() == 0 then
            return UE4.EEmitterResult.Finish
        end

        --小飞机变换阵型时，阵型生成方向为角色技能最终期望朝向
        local PlayerMovement = Launcher.CharacterMovement:Cast(UE4.UPlayerMovementComponent)
        if PlayerMovement then
            local DesiredRotation = UE4.UKismetMathLibrary.Quat_Rotator(PlayerMovement:GetSkillDesiredRotation())
            Launcher:K2_SetActorRotation(DesiredRotation)
            Team:SetSpecialTeamSlotConfig(Token)
            Team:UpdateSlotConfig()
        else
            Team:SetSpecialTeamSlotConfig(Token)
            Team:UpdateSlotConfig()
        end
        for i = 1, AllDrones:Length() do
            local Drone = AllDrones:Get(i)
            if Drone:GetTemplateID() == SummonID then
                if bIncludeMortalDrone == false and Drone:IsImmortal() == true then
                else
                    if
                        Drone:GetCharacterIsEnable() == true and
                            (Drone:ActorHasTag(Tag) or UE4.UKismetStringLibrary.IsEmpty(Tag))
                     then
                        local DroneController = self:GetDroneController(Drone)
                        if DroneController ~= nil and bNeedTeleport == true then
                            local SceneTarget = DroneController:GetSceneTarget()
                            local SceneTransform = SceneTarget:GetTransform()
                            AllDrones:Get(i).CharacterMovement.Velocity = UE4.FVector(0,0,0);
                            AllDrones:Get(i):K2_SetActorTransform(SceneTransform)
                        end
                    end
                end
            end
        end
    end
end

function DroneTeleport:ApplyEffect(Center, Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function DroneTeleport:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

function DroneTeleport:EmitterDestroyLua()
    self:Destroy()
end

return DroneTeleport
