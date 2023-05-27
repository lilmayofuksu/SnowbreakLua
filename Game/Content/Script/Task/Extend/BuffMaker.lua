-- ========================================================
-- @File    : BuffMaker.lua
-- @Brief   : 用于施加buff的场景触发器
-- @Author  :
-- @Date    :
-- ========================================================
local BuffMaker = Class()

function BuffMaker:ReceiveBeginPlay()
    if not self:HasAuthority() then
        return
    end
    local TaskActor = UE4.AGameTaskActor.GetGameTaskActor(self)
    if not TaskActor then
        return
    end

    --ModifierID 通过阵营配置区分玩家和怪物
    self.tbModifierID = nil
    --玩家SkillID
    self.tbPlayerSkillID = nil
    --怪物SkillID
    self.tbMonsterSkillID = nil

    if TaskActor.LevelType == UE4.ELevelType.Tower then
        self.tbModifierID = ClimbTowerLogic.GetAllBuffID()
    end
    if TaskActor.LevelType == UE4.ELevelType.Fragments then
        self.tbModifierID = Role.GetLevelBuffID()
    end
    if TaskActor.LevelType == UE4.ELevelType.BossChallenge then
        self.tbModifierID = BossLogic.GetTbBuffID()
    end
    if TaskActor.LevelType == UE4.ELevelType.Defend then
        self.tbModifierID = DefendLogic.GetAllBuff()
    end
    if Launch.GetType() == LaunchType.TOWEREVENT then
        if TowerEventChapter.GetIsBuffOnlyAddToPlayer() then
            self.tbPlayerSkillID = TowerEventChapter.GetTbBuffID()
        else
            self.tbMonsterSkillID = TowerEventChapter.GetTbBuffID()
        end
    end
    if Launch.GetType() == LaunchType.CHAPTER then
        local tbLevelCfg = ChapterLevel.Get(Chapter.GetLevelID())
        self.tbModifierID = tbLevelCfg.tbBuff
    end
    if Launch.GetType() == LaunchType.DLC1_ROGUE then
        self.tbPlayerSkillID = RogueLogic.GetTbBuffID()
        self.tbMonsterSkillID = RogueLogic.GetTbMonsterBuffID()
    end

    if not self.tbModifierID and not self.tbPlayerSkillID and not self.tbMonsterSkillID then
        return
    end

    if self.tbModifierID or self.tbPlayerSkillID then
        local AllPlayerChars = UE4.UGameplayStatics.GetAllActorsOfClass(self, UE4.AGamePlayer)
        for i = 1, AllPlayerChars:Length() do
            self:AddSkills(AllPlayerChars:Get(i), self.tbPlayerSkillID)
            self:AddModifiers(AllPlayerChars:Get(i), self.tbModifierID)
        end
    end

    self.CharacterSpawnHandle = EventSystem.On(Event.CharacterSpawned, function(SpawnCharacter)
        if not IsValid(SpawnCharacter) then
            return
        end
        self:AddModifiers(SpawnCharacter, self.tbModifierID)
        if IsPlayer(SpawnCharacter) then
            self:AddSkills(SpawnCharacter, self.tbPlayerSkillID)
        elseif IsAI(SpawnCharacter) then
            self:AddSkills(SpawnCharacter, self.tbMonsterSkillID)
        end
    end, false)
end

function BuffMaker:AddSkills(InChar, tbID)
    if not IsValid(InChar) or not tbID then
        return
    end

    for _, ID in pairs(tbID) do
        InChar:GetAbilityComponent():AddSkill(ID)
    end
end

function BuffMaker:AddModifiers(InChar, tbID)
    if not IsValid(InChar) or not tbID then
        return
    end

    local vector = UE4.FVector(0, 0, 0)
    local BuffMakerAbility = self:GetAbility()
    for _, ID in pairs(tbID) do
        UE4.UModifier.MakeModifier(ID, InChar, BuffMakerAbility, InChar.Ability, nil, vector, vector)
    end
end

function BuffMaker:ReceiveEndPlay()
    EventSystem.Remove(self.CharacterSpawnHandle)
end

return BuffMaker
