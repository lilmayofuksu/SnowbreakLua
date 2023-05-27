-- ========================================================
-- @File    : Drone.lua
-- @Brief   : 召唤无人机
-- @Author  : Xiong
-- @Date    : 2020-04-27
-- ========================================================

---@class USkillEmitter_Drone:USkillEmitter
local Drone = Class()

function Drone:OnEmit()
    ---TODO : New skill info
    --- Param1 : 召唤物ID
    --- Param2 : 召唤物AI Id
    --- Param3 : 召唤物等级
    --- Param4 : 召唤物个数
    --- Param5 : 召唤物存在时长
    --- Param6 : 召唤物类型
    --- Param7 : 召唤物Tag
    --- Param8 : 入场动画类型
    --- Param9 : 刷新之前的飞机
    --- Param10 : 是否清除非永久无人机
    local DroneSummonID = self:GetParamintValue(0)
    local DroneSummonAI = self:GetParamintValue(1)
    local DroneSummonLevel = self:GetParamintValue(2)
    local DroneSummonNum = self:GetParamintValue(3)
    local SummonLife = self:GetParamfloatValue(4)
    local DroneType = self:GetParamintValue(5)
    local DroneTag = self:GetParamValue(6)
    local PlayEnterAnimIndex = 1
    if not UE4.UKismetStringLibrary.IsEmpty(self:GetParamValue(7)) then
        PlayEnterAnimIndex = self:GetParamintValue(7)
    end
    local bFreshTime = false
    local ParamLength = self:GetParamLength()
    if ParamLength > 8 then
        bFreshTime = self:GetParamboolValue(8)
    end
    local bClearTemporaryDrone = false
    if ParamLength > 9 then
        bClearTemporaryDrone = self:GetParamboolValue(9)
    end
    local bClearForeverDrone = false
    if ParamLength > 10 then
        bClearForeverDrone = self:GetParamboolValue(10)
    end

    if ParamLength > 11 then
        local SummonOwner = self:GetInstigator()
        if SummonOwner and self:GetParamboolValue(11) then            
            DroneSummonLevel = SummonOwner.Level;
        end
    end

    ---Param6 : DroneType == 0 :正常无人机  1 :轰炸用无人机  2 :永久无人机
    local Launcher = self:GetInstigator()
    local Team = Launcher.AIControlData.Team

    if (Launcher == nil or Team == nil) then
        return nil
    end

    --1技能位置不足则先清除相同数量的飞机
    local ClearIndexArr = UE4.TArray(UE4.int32) 
    if DroneTag == "Casting Skill1" then
        ClearIndexArr = Team:ClearExcessMembers(DroneSummonNum)
    end
    --2技能不清除飞机 没空位则不召唤
    if DroneTag == "Casting Skill2" then
        DroneSummonNum = math.min(Team:GetMembersMaxNum() - Team:GetAllMembersPtr(true):Length(),DroneSummonNum)
    end

    if bClearTemporaryDrone then
        Team:ClearTemporaryMembers(Launcher)
    end
    if bClearForeverDrone then
        Team:ClearForeverMembers(Launcher)
    end

    if bFreshTime == true then
        local Launcher = self:GetSkillLauncher():Cast(UE4.AGameCharacter)
        local Team = nil
        local AllDrones
        if Launcher == nil then
            return UE4.EEmitterResult.Finish
        end
        local Team = Launcher.AIControlData.Team;
        if Team == nil then
            return UE4.EEmitterResult.Finish
        end
            AllDrones = Team:GetAllMembersPtr(true)

        for i = 1, AllDrones:Length() do
            if AllDrones:Get(i):IsImmortal() == false and self:IsDrone(AllDrones:Get(i)) == true then
                AllDrones:Get(i):SetLifeSpan(SummonLife);
            end
        end
    end

    --是否可以插队
    local bCanJump = true
    for i = 1, DroneSummonNum do
        if not Team:IsSlotEmpty(i, 100) then
            bCanJump = false
        end
    end
    for i = 1, DroneSummonNum do
        local JumpIndex = -1
        local SpawnTransform = Team:GetNextEmptySlotTrans()
        if ClearIndexArr:Length() >= i then
            SpawnTransform = Team:GetSlotTransformByIndex(ClearIndexArr:Get(i) - 1)
            JumpIndex = ClearIndexArr:Get(i)
        end
        if bCanJump then
            SpawnTransform = Team:GetSlotTransformByIndex(i)
            JumpIndex = i + 1
        end

        local NpcParams = UE4.FSpawnNpcParams()
        NpcParams.Id = DroneSummonID
        NpcParams.Level = DroneSummonLevel
        NpcParams.Location = SpawnTransform.Translation
        NpcParams.Rotation = SpawnTransform.Rotation:ToRotator()
        NpcParams.Type = UE4.ECharacterType.Summon
        NpcParams.AI = DroneSummonAI
        NpcParams.PlayEnterAnimIndex = PlayEnterAnimIndex

        local SummonRef = UE4.AGameAICharacter.SpawnAICharacter(self:GetAbilityOwner(), NpcParams, self:GetInstigator())
        if not SummonRef then 
            return
        end

        SummonRef.bIgnore = true
        if DroneType ~= 2 then
            SummonRef:SetLifeSpan(SummonLife)
        end
        Team:AddMember(SummonRef, JumpIndex)

        SummonRef.SummonedRuntimeEASInfo = self.RuntimeEASInfo

        self:ApplyEffect(NpcParams.Location, NpcParams.Rotation)
        local Result =
            UE4.UAbilityFunctionLibrary.MakeQueryResult_AdjustToTarget(SummonRef, self:GetEmitterInfo().ApplyLocationType)
        self:ApplyMagicToActor(Result, Result.QueryPoint, Launcher:K2_GetActorLocation())
        if not UE4.UKismetStringLibrary.IsEmpty(DroneTag) then
            SummonRef.Tags:AddUnique(DroneTag)
        end
    end

    return UE4.EEmitterResult.Finish
end

function Drone:ApplyEffect(Center, Rotator)
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectPlay(self:GetSkillLauncher(),self:GetEmitterInfo(),Center,UE4.UKismetMathLibrary.Quat_Rotator(Rotator), HashIndex, self.QueryResults);
end

function Drone:OnEmitEnd()
    local HashIndex = UE4.UAbilityFunctionLibrary.GetObjectHashIndex(self);
    UE4.USkillEmitter.EmitterAnchorEffectEnd(self:GetSkillLauncher(),HashIndex,self:GetEmitterInfo());
end

function Drone:EmitterDestroyLua()
    self:Destroy()
end

return Drone
