-- ========================================================
-- @File    : AddBuffMakerEvent.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================


---@class AddBuffMakerEvent : GameTaskEvent
local AddBuffMakerEvent = Class()

function AddBuffMakerEvent:OnTrigger()
    local buffId = self.ModifierID
    local toPlayer = self.CastToPlayer
    local TaskActor = self:GetGameTaskActor()

    if self.MultType then
        if self.RandomMonster then
            local RandomCfg = UE4.UTaskRandomSubsystem.GetBattleRandomMonster(TaskActor, TaskActor.AreaId)
            if RandomCfg then
                buffId = RandomCfg.BufferId
                toPlayer = RandomCfg.BufferType == UE4.EChallengeBuffType.Player
            end
        else
            self.challengeCfg = UE4.UTaskRandomSubsystem.GetBattleChallange(TaskActor, TaskActor.AreaId)
            if self.challengeCfg then
                buffId = self.challengeCfg.BufferId
                toPlayer = self.challengeCfg.BufferType == UE4.EChallengeBuffType.Player
            end
        end
    end

    if buffId == 0 then
        return false
    end

    local Handle = EventSystem.On(Event.CharacterSpawned, function(SpawnCharacter)
        if self:Check(SpawnCharacter) then
            if (CastToPlayer and IsPlayer(SpawnCharacter)) or (not CastToPlayer and self:IsEnermy(SpawnCharacter)) then
                local Location = UE4.FVector(0,0,0)
                UE4.UModifier.MakeModifier(buffId, SpawnCharacter, SpawnCharacter.Ability, SpawnCharacter.Ability, nil, Location, Location);
            end
        end
    end)

    TaskActor:AddBufferMaker(buffId, Handle)
end

function AddBuffMakerEvent:Check(InCharacter)
    if not IsValid(InCharacter) then return false end

    if self.Tag == 'None' then
        return true
    end

    local bInClude = InCharacter.Tags:Contains(self.Tag)
    if self.InClude then
        return bInClude
    else
        return not bInClude
    end
end

function AddBuffMakerEvent:IsEnermy(InCharacter)
    local pc = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    local player = nil
    if pc then
        local AllCharacter = pc:GetPlayerCharacters()
        for i = 1, AllCharacter:Length() do
            local cc = AllCharacter:Get(i)
            player = cc
        end
    end
    return player and UE4.UAbilityFunctionLibrary.GetRelation(InCharacter, player) or false
end

return AddBuffMakerEvent