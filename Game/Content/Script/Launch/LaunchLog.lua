-- ========================================================
-- @File    : Launch/LaunchLog.lua
-- @Brief   : 关卡日志
-- ========================================================
---@class LaunchLog 关卡日志
LaunchLog = LaunchLog or {}

function LaunchLog.GetPlayerDamage(InIndex)
    InIndex = InIndex - 1
    local Storge = UE4.AAbilityRunTimeInfoStorge.GetStorge()
    local PlayerData = UE4.FPlayerRecordData()
    local bFind = Storge:GetPlayerData(InIndex, PlayerData)
    if not bFind then return 0 end
    local nDamage = 0
    for i= 0, 4 do
        nDamage = nDamage + PlayerData.Damage:Find(i)
    end
    return nDamage
end

function LaunchLog.LogCardSimple(pCard)
    local sGDPL = 'NULL'
    local sWeaponGDPL = 'NULL'
    local sSupportGDPL = 'NULL'

    if pCard == nil then
        return sGDPL, sWeaponGDPL, sSupportGDPL
    end
    sGDPL = string.format("%d-%d-%d-%d-%d", pCard:Genre(), pCard:Detail(), pCard:Particular(), pCard:Level(), pCard:EnhanceLevel())

    local pWeapon = pCard:GetSlotWeapon()
    if pWeapon then
        sWeaponGDPL = string.format("%d-%d-%d-%d-%d", pWeapon:Genre(), pWeapon:Detail(), pWeapon:Particular(), pWeapon:Level(), pWeapon:EnhanceLevel())
    end

    local supporterCards = pCard:GetSupporterCards()
    local nCount = supporterCards:Length()
    if nCount > 0 then sSupportGDPL = '' end
    for i = 1, nCount do
        local pSupporter = supporterCards:Get(i)
        if pSupporter then
            sSupportGDPL = sSupportGDPL .. string.format("%d-%d-%d-%d-%d", pSupporter:Genre(), pSupporter:Detail(), pSupporter:Particular(), pSupporter:Level(), pSupporter:EnhanceLevel())
            if i < nCount then
                sSupportGDPL = sSupportGDPL .. ','
            end
        end
    end

    return sGDPL, sWeaponGDPL, sSupportGDPL
end

function LaunchLog.LogCard(InCard)
    local strCharacterData = "NULL"
    local strWeaponData = "NULL"
    local strPartsData = "NULL"
    local strSupportData = "NULL"
    local nPower = 0

    local GetSuperCardLog = function(InSuperCard)
        if InSuperCard == nil then
            return "NULL"
        end

        local Affix1 = InSuperCard:GetAffix(1) and InSuperCard:GetAffix(1):Get(1) or 0;
        local Affix2 = InSuperCard:GetAffix(2) and InSuperCard:GetAffix(2):Get(1) or 0;
        local Affix3 = InSuperCard:GetAffix(3) and InSuperCard:GetAffix(3):Get(1) or 0;
        local nValueLv1, _ = Logistics.GetAffixValue(InSuperCard:GetAffix(1))
        local nValueLv2, _ = Logistics.GetAffixValue(InSuperCard:GetAffix(2))
        local nValueLv3, _ = Logistics.GetAffixValue(InSuperCard:GetAffix(3))

        local str = string.format("%d-%d-%d-%d-%d-%d-%d:%d-%d:%d-%d:%d"
            , InSuperCard:Genre(), InSuperCard:Detail()
            , InSuperCard:Particular(), InSuperCard:Level()
            , InSuperCard:EnhanceLevel(), InSuperCard:Break()
            , Affix1, nValueLv1, Affix2, nValueLv2, Affix3, nValueLv3)
        return str
    end

    if InCard then
        local intArray = UE4.TArray(UE4.int32);
        InCard:GetAllActiveSpineNode(false, intArray)
        local SpineCount = intArray:Length()
        local nProlevel = InCard:ProLevel() or 0
        strCharacterData = string.format("%d-%d-%d-%d-%d-%d-%d", InCard:Genre(), InCard:Detail(), InCard:Particular(), InCard:Level(), InCard:EnhanceLevel(), InCard:Break(), SpineCount)

        local InWeapon = InCard:GetSlotWeapon()
        if InWeapon then
            strWeaponData = string.format("%d-%d-%d-%d-%d-%d-%d", InWeapon:Genre(), InWeapon:Detail(), InWeapon:Particular(), InWeapon:Level(), InWeapon:EnhanceLevel(), InWeapon:Break(), InWeapon:Evolue())
            local Part = InWeapon:GetWeaponSlot(UE4.EWeaponSlotType.Muzzle)
            strPartsData = Part ~= nil and tostring(Part:Particular()) or "0"
            Part = InWeapon:GetWeaponSlot(UE4.EWeaponSlotType.TopGuide)
            strPartsData = strPartsData .. "-" .. (Part ~= nil and Part:Particular() or "0")
            Part = InWeapon:GetWeaponSlot(UE4.EWeaponSlotType.Ammunition)
            strPartsData = strPartsData .. "-" .. (Part ~= nil and Part:Particular() or "0")
            Part = InWeapon:GetWeaponSlot(UE4.EWeaponSlotType.LowerGuide)
            strPartsData = strPartsData .. "-" .. (Part ~= nil and Part:Particular() or "0")
        end

    
        strSupportData = GetSuperCardLog(InCard:GetSupporterCardForIndex(1))
        strSupportData = strSupportData .. ";" .. GetSuperCardLog(InCard:GetSupporterCardForIndex(2))
        strSupportData = strSupportData .. ";" .. GetSuperCardLog(InCard:GetSupporterCardForIndex(3))      
        
        nPower = Item.Zhanli_CardTotal(InCard)
    end
    return strCharacterData, strWeaponData, strPartsData, strSupportData, nPower
end

function LaunchLog.LogPlayerData(InIndex)
    InIndex = InIndex - 1
    local Storge = UE4.AAbilityRunTimeInfoStorge.GetStorge()
    local PlayerData = UE4.FPlayerRecordData()
    local bFind = Storge:GetPlayerData(InIndex, PlayerData)
    if not bFind then return "NULL" end
    local dodgeCount = (PlayerData.TriggerCount:Find(5) or 0) + (PlayerData.TriggerCount:Find(9) or 0)
    local strDataLog = string.format("%d~%d~%d~%d~%d~%d~%d~%d~%d~%d~%d~%d"
        ,PlayerData.TriggerCount:Find(0) or 0, PlayerData.HitCount:Find(0) or 0, PlayerData.Damage:Find(0) or 0
        ,PlayerData.TriggerCount:Find(2) or 0, PlayerData.Damage:Find(2) or 0
        ,PlayerData.TriggerCount:Find(4) or 0, PlayerData.Damage:Find(4) or 0
        ,PlayerData.TriggerCount:Find(3) or 0, PlayerData.Damage:Find(3) or 0
        ,dodgeCount, PlayerData.ElemExplosionCount, math.floor(PlayerData.ElemExplosionDamage))

    return strDataLog
end
function LaunchLog.LogPlayerDeadInfo()
    local Storge = UE4.AAbilityRunTimeInfoStorge.GetStorge()
    if not Storge then return "" end
    local PlayerData = UE4.FPlayerRecordData()
   

    local OutLog = nil
    local funStr = function(SkillId, Time, G, D, P, L)
        if OutLog == nil then
            OutLog = string.format("%d-%.1f-%d-%d-%d-%d", SkillId, Time, G, D, P, L)
        else
            OutLog = string.format( "%s:%d-%.1f-%d-%d-%d-%d", OutLog, SkillId, Time, G, D, P, L)
        end
    end

    local bFind = Storge:GetPlayerData(0, PlayerData)    
    if bFind then
        local SkillCount = PlayerData.DeadSkillId:Length()
        local TimeCount = PlayerData.DeadTime:Length()

        for i = 1, SkillCount do
            funStr(PlayerData.DeadSkillId:Get(i), PlayerData.DeadTime:Get(i), PlayerData.G, PlayerData.D, PlayerData.P, PlayerData.L)
        end        
    end
    bFind = Storge:GetPlayerData(1, PlayerData)    
    if bFind then
        local SkillCount = PlayerData.DeadSkillId:Length()
        local TimeCount = PlayerData.DeadTime:Length()

        for i = 1, SkillCount do
            funStr(PlayerData.DeadSkillId:Get(i), PlayerData.DeadTime:Get(i), PlayerData.G, PlayerData.D, PlayerData.P, PlayerData.L)
        end        
    end
    bFind = Storge:GetPlayerData(2, PlayerData)    
    if bFind then
        local SkillCount = PlayerData.DeadSkillId:Length()
        local TimeCount = PlayerData.DeadTime:Length()

        for i = 1, SkillCount do
            funStr(PlayerData.DeadSkillId:Get(i), PlayerData.DeadTime:Get(i), PlayerData.G, PlayerData.D, PlayerData.P, PlayerData.L)
        end        
    end
    return OutLog == nil and "NULL" or OutLog
end
function LaunchLog.LogPlayerDataOther(InIndex)
    local HurtData = ""
    local HealData = ""
    local DeadTime = ""

    local Storge = UE4.AAbilityRunTimeInfoStorge.GetStorge()
    local PlayerData = UE4.FPlayerRecordData()
    InIndex = InIndex or 0

    local bFind = Storge:GetPlayerData(InIndex * 3, PlayerData)
    HurtData = bFind and tostring(PlayerData.DamageReceived) or "NULL"
    HealData = bFind and string.format("%d~%d~%d", PlayerData.RecoverBloodAmount, PlayerData.RecoverBloodBox, PlayerData.RecoverBloodSkill) or "NULL"
    DeadTime = bFind and tostring(PlayerData.DeadCount) or "NULL"

    bFind = Storge:GetPlayerData(1 + InIndex * 3, PlayerData)
    HurtData = HurtData .. "~" .. (bFind and PlayerData.DamageReceived or "NULL")
    HealData = HealData .. ";" .. (bFind and string.format("%d~%d~%d", PlayerData.RecoverBloodAmount, PlayerData.RecoverBloodBox, PlayerData.RecoverBloodSkill) or "NULL")
    DeadTime = DeadTime .. "-" .. (bFind and PlayerData.DeadCount or "NULL")

    bFind = Storge:GetPlayerData(2 + InIndex * 3, PlayerData)
    HurtData = HurtData .. "~" .. (bFind and PlayerData.DamageReceived or "NULL")
    HealData = HealData .. ";" .. (bFind and string.format("%d~%d~%d", PlayerData.RecoverBloodAmount, PlayerData.RecoverBloodBox, PlayerData.RecoverBloodSkill) or "NULL")
    DeadTime = DeadTime .. "-" .. (bFind and PlayerData.DeadCount or "NULL")
 
    return HurtData, HealData, DeadTime
end
 
function LaunchLog.GetBossSkillDamage()    
    local Storge = UE4.AAbilityRunTimeInfoStorge.GetStorge()
    if not Storge then return "NULL" end
    
    local ArrayDamage = Storge:GetBossSkillDamage()
    local Length = ArrayDamage:Length()
    if Length < 1 then return "NULL" end

    local OutLog = ""
    for i = 1, Length do
        if i > 5 then break end
        local Value = ArrayDamage:Get(i)        
        local strLog = string.format("%d~%d~%.0f", Value.SkillID, Value.TriggerTimes, Value.Damage)
        if OutLog == "" then
            OutLog = strLog
        else
            OutLog= OutLog .. ";" .. strLog
        end
    end
    return OutLog    
end
function LaunchLog.GetBossStateDamage()
    local Storge = UE4.AAbilityRunTimeInfoStorge.GetStorge()
    if not Storge then return "NULL" end

    local StateDamage = Storge:GetBossStateDamage()
    local Length = StateDamage.StateDamage:Length()
    if Length < 1 then return "NULL" end

    local OutLog = ""
    for i = 1, Length do
        local nDamage = StateDamage.StateDamage:Get(i)
        local nTime = StateDamage.StateTime:Get(i)
        local strLog = string.format("%.0f~%.0f", nTime, nDamage)
        if OutLog == "" then
            OutLog = strLog
        else
            OutLog= OutLog .. ";" .. strLog
        end
    end
    return OutLog
end
function LaunchLog.GetBOSSBreak()
    local Storge = UE4.AAbilityRunTimeInfoStorge.GetStorge()
    if not Storge then return "NULL" end

    local StateDamage = Storge:GetBossStateDamage()
    local Length = StateDamage.DestName:Length()
    if Length < 1 then return "NULL" end

    local OutLog = ""
    local CurStateName = nil
    for i = 1, Length do
        local sName = StateDamage.DestName:Get(i)
        local nTime = StateDamage.DestDeadTime:Get(i)
        local strLog = string.format("%s~%d", sName, nTime)
        local lastState = StateDamage.DestStateName:Get(i)
        local type = ":"
        if CurStateName == nil then
            CurStateName = lastState
        elseif CurStateName == lastState then
            type = ":"
        elseif CurStateName ~= lastState then
            CurStateName = lastState
            type = ";"
        end

        if OutLog == "" then
            OutLog = strLog
        else
            OutLog= OutLog .. type .. strLog
        end
    end
    return OutLog
end
function LaunchLog.GetMonsterDamage()
    local Storge = UE4.AAbilityRunTimeInfoStorge.GetStorge()
    if not Storge then return "NULL" end
    
    
    local ArrayDamage = Storge:GetMonsterDamage()
    local Length = ArrayDamage:Length()
    if Length < 1 then return "NULL" end

    local OutLog = ""
    for i = 1, Length do
        if i > 5 then break end
        local Value = ArrayDamage:Get(i)
        local strLog = string.format("%d~%.0f", Value.ID, Value.Damage)
        if OutLog == "" then
            OutLog = strLog
        else
            OutLog= OutLog .. ";" .. strLog
        end
    end
    return OutLog
end
function LaunchLog.GetSkillKillCount()
    local OutCount = 0;
    local Storge = UE4.AAbilityRunTimeInfoStorge.GetStorge()
    if not Storge then return OutCount end

    local PlayerData = UE4.FPlayerRecordData()
    for i = 0, 2 do
        local bFind = Storge:GetPlayerData(0, PlayerData)    
        if bFind then
            OutCount = OutCount + PlayerData.DeadSkillId:Length()
        end
    end
    return OutCount
end

function LaunchLog.GetDestructibleData()
    local Storge = UE4.AAbilityRunTimeInfoStorge.GetStorge()
    if not Storge then return "NULL" end

    local Data = Storge:GetDestructibleData()   
    return string.format("%d~%.0f~%.0f~%d~%d~%d", Data.DeadCount, Data.HurtMonsterDamage, Data.HurtPlayerDamage, Data.KillMonsterCount, Storge.KillZoneCount,LaunchLog.GetSkillKillCount())
end

function LaunchLog.GetOperateSequence()
    local Storge = UE4.AAbilityRunTimeInfoStorge.GetStorge()
    if not Storge then return "NULL" end
    if Storge.PlayerInputOperate == "" then return "NULL" end
    return Storge.PlayerInputOperate
end

LaunchLog.UseGamepad = false
function LaunchLog.SetGamepadUsed(bUse)
    if LaunchLog.UseGamepad ~= bUse then LaunchLog.UseGamepad = bUse end
end

function LaunchLog.LogTaskActor()
    local LevelFinishType = ""
    local GetStar = ""
    local FinalStar = ""
    local LevelTime = ""
    local TaskNodeTime = ""
    local FightNodeTime = ""
    local RealTime = 0

    local GameTaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
    local StarTaskSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelStarTaskManager)
    if GameTaskActor then 
        LevelFinishType = GameTaskActor:GetFightLog_LevelFinishType()
        LevelTime = GameTaskActor:GetLevelTotalTime()
        TaskNodeTime = GameTaskActor:GetFightLog_ExecuteTime()
        FightNodeTime = GameTaskActor:GetFightLog_ExecuteFightTime()
        RealTime = math.floor(GameTaskActor:GetLevelTime())
    end
    if StarTaskSubSys then
        GetStar = StarTaskSubSys:GetFightLog_GetStar()
        FinalStar = StarTaskSubSys:GetFightLog_FinalStar()
    end
    return LevelFinishType,GetStar,FinalStar,LevelTime,TaskNodeTime,FightNodeTime, RealTime
end

function LaunchLog.GetCharacterATTR(InCard)
    if not InCard then return "NULL", "NULL", "NULL" end
    local Health = InCard:Total_Health()
    local Attack= InCard:Total_Attack()
    local Defence = InCard:Total_Defence()
    local CriticalValue = InCard:Total_CriticalValue()
    local CriticalDamage = InCard:Total_CriticalDamageAddtion()
    local strBase = string.format("%.2f~%d~%.2f~%.2f~%.2f", Health, Attack, Defence, CriticalValue, CriticalDamage)

    local CharacterEnergyEfficiency = InCard:Total_CharacterEnergyEfficiency() + 100
    local Vigour = InCard:Total_Vigour()
    local EntityBulletResistance = InCard:EntityBulletResistance()
    local FireResistance = InCard:FireResistance()
    local IceResistance = InCard:IceResistance()
    local ThunderResistance = InCard:ThunderResistance()
    local SuperpowersResistance = InCard:SuperpowersResistance()
    local SkillCDQuick = InCard:Total_SkillCDQuick()
    local NormalEnergyRecoverSpeed = InCard:Total_NormalEnergyRecoverSpeed()
    local Command = InCard:Total_Command()
    local SkillMastery = InCard:Total_SkillMastery()
    local strSp = string.format("%.2f~%.2f~%.2f~%.2f~%.2f~%.2f~%.2f~%.2f~%.2f~%.2f~%.2f", 
        CharacterEnergyEfficiency,Vigour, EntityBulletResistance, FireResistance, IceResistance, ThunderResistance, SuperpowersResistance, SkillCDQuick, NormalEnergyRecoverSpeed, Command, SkillMastery)
    
    local Weapon = InCard:GetSlotWeapon()
    local DamageCoefficient = Weapon:DamageCoefficient()
    local FireSpeed = Weapon:FireSpeed()
    local DamageType = Weapon:DamageType()
    local FiringRangeUltimateLimit = Weapon:FiringRangeUltimateLimit()
    local BulletNum = Weapon:BulletNum()
    local ReloadSpeed = Weapon:ReloadSpeed()
    local CriticalDamage = Weapon:CriticalDamage()
    local strWeapon = string.format("%.2f~%d~%d~%.0f~%d~%.2f~%.2f", DamageCoefficient, FireSpeed, DamageType, FiringRangeUltimateLimit, BulletNum, ReloadSpeed, CriticalDamage)

    return strBase, strSp, strWeapon
end


---关卡日志收集
function LaunchLog.LogLevel(levelType, extend, LevelId)
    local intArray = UE4.TArray(UE4.int32);

    local tbteam = Formation.GetCurrentLineup()
    local tbCards = tbteam and tbteam:GetCards() or nil
    local CardNum = tbCards and tbCards:Length() or 0
    local Card1 = CardNum >= 1 and tbCards:Get(1) or nil
    local Character1Data, Weapon1Data, Parts1Data, Support1Data, nPower1 = LaunchLog.LogCard(Card1)
    local Card2 = CardNum >= 2 and tbCards:Get(2) or nil
    local Character2Data, Weapon2Data, Parts2Data, Support2Data, nPower2 = LaunchLog.LogCard(Card2)
    local Card3 = CardNum >= 3 and tbCards:Get(3) or nil
    local Character3Data, Weapon3Data, Parts3Data, Support3Data, nPower3 = LaunchLog.LogCard(Card3)
    local HurtData,HealData,DeadTime  = LaunchLog.LogPlayerDataOther()
    local LevelFinishType,GetStar,FinalStar,LevelTime,TaskNodeTime,FightNodeTime, RealTime = LaunchLog.LogTaskActor()

    ---推荐战力
    local RequirePower = 0
    local cfg = nil
    if not LevelId then
        if levelType == 6 then  --爬塔战术考核关
            LevelId = string.format('%d-%d-%d', TowerEventChapter.GetChapterID(), TowerEventChapter.GetLevelID(), 1)
            cfg = TowerEventLevel.Get(LevelId)
        elseif levelType == LaunchType.DEFEND then
            local id, diff = DefendLogic.GetIDAndDiff()
            local levelConf = DefendLogic.GetLevelConf(id, diff)
            LevelId = string.format('%d-%d-%d', id, diff, levelConf.nLevelID)
            local GameTaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
            LevelTime = GameTaskActor and GameTaskActor:GetLevelTotalTime() or 0
        elseif levelType == LaunchType.DLC1_CHAPTER then
            LevelId = string.format('%d-%d-%d', DLC_Chapter.GetChapterID(), DLC_Chapter.GetLevelID(), 1)
            cfg = DLCLevel.Get(DLC_Chapter.GetLevelID())
        elseif levelType == LaunchType.DAILY then
            local nLevelID = Daily.GetLevelID()
            local nMultiple = Launch.GetMultiple()
            local cfg = DailyLevel.Get(nLevelID)
            local nDifficult = cfg.nType == DailyLevel.TeachingLevelType and 1 or math.floor(nLevelID % 10)
            LevelId = string.format('%s-%s-%s', nMultiple, nLevelID, nDifficult)
        else
            LevelId = string.format('%s-%s-%s', Chapter.GetChapterID(), Chapter.GetLevelID(), Chapter.GetChapterDifficult())
            cfg = ChapterLevel.Get(Chapter.GetLevelID(), true)
        end
    end
    if cfg and cfg.nRecommendPower then
        RequirePower = cfg.nRecommendPower
    end

    local tbLog = {
        --[[1['LevelType'] =]] levelType or LaunchLog.GetLevelType(),
        --[[2['LevelId'] = ]] LevelId,
        --[[3['LevelFinishType'] =]] LevelFinishType, 
        --[[4['GetStar'] = ]] GetStar,
        --[[5['FinalStar'] = ]] FinalStar,
        --[[6['LevelTime'] = ]] LevelTime,
        --[[7['TaskNodeTime'] = ]] TaskNodeTime,
        --[[8['FightNodeTime'] = ]] FightNodeTime,
        --[[9['BattleGroupId'] = ]] Formation.GetCurLineupIndex(),
        --[[10['Character1Data'] =]] Character1Data,
        --[[11['Weapon1Data'] = ]] Weapon1Data,
        --[[12['Parts1Data'] = ]] Parts1Data,
        --[[13['Support1Data'] = ]] Support1Data,
        --[[14['Character2Data'] =]] Character2Data,
        --[[15['Weapon2Data'] = ]] Weapon2Data,
        --[[16['Parts2Data'] = ]] Parts2Data,
        --[[17['Support2Data'] = ]] Support2Data,
        --[[18['Character3Data'] =]] Character3Data,
        --[[19['Weapon3Data'] =]] Weapon3Data,
        --[[20['Parts3Data'] = ]] Parts3Data,
        --[[21['Support3Data'] =]] Support3Data,

        --[[22['Character1FightData'] =]] LaunchLog.LogPlayerData(1),
        --[[23['Character2FightData'] =]] LaunchLog.LogPlayerData(2),
        --[[24['Character3FightData'] =]] LaunchLog.LogPlayerData(3),

        --[[25['GetHurtData'] =]] HurtData,
        --[[26['HealData'] =]] HealData,
        --[[27['DeadTimes'] = ]] DeadTime,

        --[[28['BossSkillData'] = ]] LaunchLog.GetBossSkillDamage(),
        --[[29['BossStageData'] =]] LaunchLog.GetBossStateDamage(),
        --[[30['MonsterStageData'] =]] LaunchLog.GetMonsterDamage(),
        --[[31['DestructableData'] =]] LaunchLog.GetDestructibleData(),

        --[[32['TeamPower'] =]] string.format("%0.1f-%0.1f-%0.1f", nPower1, nPower2, nPower3),
        --[[33['RequirePower'] =]] RequirePower,
        --[[34['RealTime'] =]] RealTime,
        --[[35['Extend'] =]] extend or 'NULL',
    }
    -- Dump(tbLog)
    return tbLog
end
---战斗经历日志收集
function LaunchLog.LogFightHistory(levelType, extend)
        local LevelId = ""
        if levelType == 6 then  --爬塔战术考核关
            LevelId = string.format('%d-%d-%d', TowerEventChapter.GetChapterID(), TowerEventChapter.GetLevelID(), 1)
        elseif levelType == LaunchType.DEFEND then
            local id, diff = DefendLogic.GetIDAndDiff()
            local levelConf = DefendLogic.GetLevelConf(id, diff)
            LevelId = string.format('%d-%d-%d', id, diff, levelConf.nLevelID)
        elseif levelType == LaunchType.DLC1_CHAPTER then
            LevelId = string.format('%s-%s-%s', DLC_Chapter.GetChapterID(), DLC_Chapter.GetLevelID(), 1)
        elseif levelType == 7 then --个人故事
            LevelId = Role.GetLevelID()
        elseif levelType == 4 then --爬塔
            local diff = 0
            local levelcfg = ClimbTowerLogic.GetLevelCfg()
            if ClimbTowerLogic.IsAdvanced() then
                diff = ClimbTowerLogic.GetLevelDiff()
                if diff ~= 0 and levelcfg and levelcfg.tbMonsterLevel[diff] then
                    Diff = diff .. "-" .. levelcfg.tbMonsterLevel[diff]
                end
            end
            LevelId = string.format('%d-%d-%d', ClimbTowerLogic.NowTimeId, ClimbTowerLogic.GetLevelID(), diff)
        elseif levelType == 5 then --boss
            local BossChallengeId = 0   --挑战期数id
            local cfg = BossLogic.GetTimeCfg()
            if cfg then
                BossChallengeId = cfg.nID
            end
            local levelId = 0    --levelId
            local levelcfg = BossLogic.GetBossLevelCfg(BossLogic.GetBossLevelID())
            if levelcfg then
                levelId = levelcfg.nLevelID
            end
            LevelId = string.format('%d-%d-%d', BossChallengeId, levelId, BossLogic.GetNowDifficulty())
        elseif levelType == 2 then
            local nLevelID = Daily.GetLevelID()
            local nMultiple = Launch.GetMultiple()
            local cfg = DailyLevel.Get(nLevelID)
            local nDifficult = cfg.nType == DailyLevel.TeachingLevelType and 1 or math.floor(nLevelID % 10)
            LevelId = string.format('%s-%s-%s', nMultiple, nLevelID, nDifficult)
        else
            LevelId = string.format('%s-%s-%s', Chapter.GetChapterID(), Chapter.GetLevelID(), Chapter.GetChapterDifficult())
        end
    local tbLog = {
        --[[1['LevelType'] =]] levelType or LaunchLog.GetLevelType(),
        --[[2['LevelId'] = ]] LevelId,
        --[[3['OperateSequence'] = ]] LaunchLog.GetOperateSequence(),
        --[[4['BOSSBreak'] = ]] LaunchLog.GetBOSSBreak(),
        --[[5['GamepadUsed'] = ]] LaunchLog.UseGamepad and 1 or 0,
    }
    -- Dump(tbLog)
    return tbLog
end

---战斗补充日志
function LaunchLog.LogFightRecont(tbInfo)
    local Card1, Card2, Card3
    if tbInfo then
        local GameController = tbInfo.GameController
        if not GameController then return {} end

        local tbCards = GameController:GetPlayerCharInfos()
        if not tbCards  then return {} end
        local CardNum = tbCards:Length()
        Card1 = CardNum >= 1 and tbCards:Get(1) or nil
        Card2 = CardNum >= 2 and tbCards:Get(2) or nil
        Card3 = CardNum >= 3 and tbCards:Get(3) or nil
    else
        local tbteam = Formation.GetCurrentLineup()
        local tbCards = tbteam and tbteam:GetCards() or nil
        local CardNum = tbCards and tbCards:Length() or 0
        Card1 = CardNum >= 1 and tbCards:Get(1) or nil
        Card2 = CardNum >= 2 and tbCards:Get(2) or nil
        Card3 = CardNum >= 3 and tbCards:Get(3) or nil
    end

    local strCardBase1, strCardSp1, strWeaponBase1 = LaunchLog.GetCharacterATTR(Card1)    
    local strCardBase2, strCardSp2, strWeaponBase2 = LaunchLog.GetCharacterATTR(Card2)    
    local strCardBase3, strCardSp3, strWeaponBase3 = LaunchLog.GetCharacterATTR(Card3)


    local Storge = UE4.AAbilityRunTimeInfoStorge.GetStorge()
    if not Storge then return {} end
    Storge:CallGameEnd()
    local PlayerData = UE4.FPlayerRecordData()

    local EffectiveDamage = {0, 0, 0}
    local OverflowDamage = {0, 0, 0}
    local DamageReceived = {0, 0, 0}
    local ConcessionDamageReceived = {0, 0, 0}
    local EffectiveTreatHealth = {0, 0, 0}
    local OverflowTreatHealth = {0, 0, 0}
    local TotalShieldDamage = {0, 0, 0}
    local ShieldDamage = {0, 0, 0}
    local FightTime = {0, 0, 0}
    local EndHealth = {0, 0, 0}
    for i = 1, 3 do
        local Index = i
        if tbInfo then
            Index = i + tbInfo.PlayerIndex * 3
        end
        local bFind = Storge:GetPlayerData(Index-1, PlayerData)

        if bFind then
            EffectiveDamage[i] = PlayerData.EffectiveDamage
            OverflowDamage[i] = PlayerData.OverflowDamage
            DamageReceived[i] = PlayerData.DamageReceived
            ConcessionDamageReceived[i] = PlayerData.ConcessionDamageReceived
            EffectiveTreatHealth[i] = PlayerData.EffectiveTreatHealth
            OverflowTreatHealth[i] = PlayerData.OverflowTreatHealth
            TotalShieldDamage[i] = PlayerData.TotalShieldDamage
            ShieldDamage[i] = PlayerData.ShieldDamage
            FightTime[i] = PlayerData.FightTime
            EndHealth[i] = PlayerData.MatchEndHealth
        end
    end
    local strTrapsDamage = "NULL"
    for i = 1, Storge.LogExplosiveInfos:Length() do
        local Data = Storge.LogExplosiveInfos:Get(i)
        local str = string.format("%d-%.2f-%d", Data.ID, Data.Value, Data.Count)
        if strTrapsDamage == "NULL" then
            strTrapsDamage = str
        else
            strTrapsDamage = strTrapsDamage .. ":" .. str
        end
    end

    local strDamageSkill = "NULL"
    for i = 1, Storge.LogDamageInfos:Length() do
        local Data = Storge.LogDamageInfos:Get(i)
        local str = string.format("%d-%.2f-%d", Data.ID, Data.Value, Data.Count)
        if strDamageSkill == "NULL" then
            strDamageSkill = str
        else
            strDamageSkill = strDamageSkill .. ":" .. str
        end
    end

    local strHealSkill = "NULL"
    for i = 1, Storge.LogTreatInfo:Length() do
        local Data = Storge.LogTreatInfo:Get(i)
        local str = string.format("%d-%.2f-%d", Data.ID, Data.Value, Data.Count)
        if strHealSkill == "NULL" then
            strHealSkill = str
        else
            strHealSkill = strHealSkill .. ":" .. str
        end
    end


    local strShieldSkill = "NULL"
    for i = 1, Storge.LogShieldInfos:Length() do
        local Data = Storge.LogShieldInfos:Get(i)
        local str = string.format("%d-%.2f-%d", Data.ID, Data.Value, Data.Count)
        if strShieldSkill == "NULL" then
            strShieldSkill = str
        else
            strShieldSkill = strShieldSkill .. ":" .. str
        end
    end

    local strControlSkill = "NULL"
    for i = 1, Storge.LogContrlInfos:Length() do
        local Data = Storge.LogContrlInfos:Get(i)
        local str = string.format("%d-%.2f-%d", Data.ID, Data.Value, Data.Count)
        if strControlSkill == "NULL" then
            strControlSkill = str
        else
            strControlSkill = strControlSkill .. ":" .. str
        end
    end


    local tbLog = {
        --[[1['Character1basicATTR'] =]] strCardBase1,
        --[[2['Character1specialATTR'] = ]] strCardSp1,
        --[[3['Character1weaponATTR'] =]] strWeaponBase1,
        --[[4['Character2basicATTR'] = ]] strCardBase2,
        --[[5['Character2specialATTR'] = ]] strCardSp2,
        --[[6['Character2weaponATTR'] = ]] strWeaponBase2,
        --[[7['Character3basicATTR'] = ]] strCardBase3,
        --[[8['Character3specialATTR'] = ]] strCardSp3,
        --[[9['Character3weaponATTR'] = ]] strWeaponBase3,
        --[[10['CharacterDamage'] =]] string.format('%.2f-%.2f:%.2f-%.2f:%.2f-%.2f', EffectiveDamage[1], OverflowDamage[1], EffectiveDamage[2], OverflowDamage[2], EffectiveDamage[3], OverflowDamage[3]),
        --[[11['CharacterInjury'] = ]] string.format('%.2f-%.2f:%.2f-%.2f:%.2f-%.2f', DamageReceived[1], ConcessionDamageReceived[1], DamageReceived[2], ConcessionDamageReceived[2], DamageReceived[3], ConcessionDamageReceived[3]),
        --[[12['CharacterHeal'] = ]] string.format('%.2f-%.2f:%.2f-%.2f:%.2f-%.2f', EffectiveTreatHealth[1], OverflowTreatHealth[1], EffectiveTreatHealth[2], OverflowTreatHealth[2], EffectiveTreatHealth[3], OverflowTreatHealth[3]),
        --[[13['CharacterShield'] = ]] string.format('%.2f-%.2f:%.2f-%.2f:%.2f-%.2f', TotalShieldDamage[1], ShieldDamage[1], TotalShieldDamage[2], ShieldDamage[2], TotalShieldDamage[3], ShieldDamage[3]),
        --[[14['CharacterHP'] =]] string.format('%.2f-%.2f-%.2f', EndHealth[1], EndHealth[2], EndHealth[3]),
        --[[15['Characterplayingtime'] = ]] string.format('%.2f-%.2f-%.2f', FightTime[1], FightTime[2], FightTime[3]),
        --[[16['HealProps'] = ]] string.format('%.2f-%d', Storge.DropTreatHealth, Storge.DropTreatCount),
        --[[17['ShieldProps'] = ]] string.format('%.2f-%d', Storge.DropShieldValue, Storge.DropShieldCount),
        --[[18['Trapsdata'] =]] string.format('%.2f-%d:%.2f-%d', Storge.ExplosiveContrlPlayerTime, Storge.ExplosiveContrlPlayerCount, Storge.ExplosiveContrlMonTime, Storge.ExplosiveContrlMonCount),
        --[[19['TrapsDamage'] =]] strTrapsDamage,
        --[[20['DamageSkill'] = ]] strDamageSkill,
        --[[21['HealSkill'] =]] strHealSkill,
        --[[22['ShieldSkill'] =]] strShieldSkill,
        --[[23['ControlSkill'] =]] strControlSkill,
    }
    -- Dump(tbLog)
    return tbLog
end


---性能日志收集
function LaunchLog.LogPerformance()
    local FPSDetail = ""
    local GameTaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
    if GameTaskActor then
        FPSDetail = GameTaskActor:GetFightLog_FPSDetail()
    end

    ---操作日志
    local sOperationSetting = 'NULL'

    ---画质日志 剑沛说只留画质日志
    local nLevel = PlayerSetting.GetOne(PlayerSetting.SSID_FRAME, FrameType.LEVEL) or 0
    local IsPc = not IsMobile() and not UE4.UGameLibrary.IsEditorMobile() and not UE4.UGameLibrary.IsDebugPcOpenMobileController()
    local rendering = PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.RENDERING)
    if IsPc then rendering = PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.RENDERING_PC) end
    local sPictureSetting = string.format('%s-%s-%s-%s-%s-%s-%s-%s-%s-%s-%s-%s-%s-%s',
        nLevel,
       PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.PARTICLE) or 0, -- FrameType.IMG_QUALITY
       PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.EFFECT) or 0,
       PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.SHADOW) or 0,
       PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.POST) or 0,
       PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.JAG) or 0,
       rendering or 0, -- FrameType.RESOLUTION
       PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.FPS) or 0,
       PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.MIRRIR) or 0,
       PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.BLUR) or 0,
       PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.FROG) or 0,
       PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.MAXFPS) or 0,
       PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.VERTICAL) or 0,
       PlayerSetting.GetFrameCheckIndexByLevel(nLevel, FrameType.SCENE) or 0
    )

    ---声音日志
    local sSoundSetting = 'NULL'

    ---其他
    local sOtherSetting = 'NULL'

    local tbLog = {
       --[[ ['SystemHardware'] =]] UE4.UUMGLibrary.GetDeviceMake() or 'NULL',
       --[[ ['ClientVersion'] = ]] UE4.UGameLibrary.GetGameIni_String("Distribution", "Version", "1.0"),
       --[[ ['FPSDetail'] = ]] FPSDetail,
       --[[['OperationSetting'] =]] sOperationSetting,
       --[[['PictureSetting'] =]] sPictureSetting,
       --[[['SoundSetting'] =]] sSoundSetting,
       --[[['sOtherSetting'] =]] sOtherSetting,
    }
    return tbLog
end

---剧情完成日志
---@param nStoryType integer 剧情类型，1-主线剧情,2-个人剧情 默认是1
---@return table
function LaunchLog.LogStoryFinish(nStoryType)
    local StoryType = nStoryType or 1
    local GameTaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
    local StoryId = GameTaskActor and GameTaskActor:GetFightLog_PlotID() or 0
    local StoryFinishType = GameTaskActor and GameTaskActor:GetFightLog_PlotCompleteType() or 0

    local tbLog = {
        StoryType,      -- StoryType
        StoryId,  -- StoryId
        StoryFinishType,       -- StoryFinishType
    }

    return tbLog
end

---获取关卡类型
function LaunchLog.GetLevelType()
    local nLevelType = 1
    local cfg = ChapterLevel.Get(Chapter.GetLevelID())
    if cfg then
        if cfg.nType == 4 then
            nLevelType = 3
        end
    end
    return nLevelType
end


---进入关卡
function LaunchLog.LogLevelEnter(levelType, LevelId)
    local tbteam = Formation.GetCurrentLineup()
    local tbCards = tbteam and tbteam:GetCards() or nil
    local CardNum = tbCards and tbCards:Length() or 0
    local Card1 = CardNum >= 1 and tbCards:Get(1) or nil
    local Character1, Weapon1, Support1 = LaunchLog.LogCardSimple(Card1)
    local Card2 = CardNum >= 2 and tbCards:Get(2) or nil
    local Character2, Weapon2, Support2 = LaunchLog.LogCardSimple(Card2)
    local Card3 = CardNum >= 3 and tbCards:Get(3) or nil
    local Character3, Weapon3, Support3 = LaunchLog.LogCardSimple(Card3)

    if levelType == 6 then
        LevelId = string.format('%d-%d-%d', TowerEventChapter.GetChapterID(), TowerEventChapter.GetLevelID(), 1)
    elseif levelType == LaunchType.DEFEND then
        local id, diff = DefendLogic.GetIDAndDiff()
        local levelConf = DefendLogic.GetLevelConf(id, diff)
        LevelId = string.format('%d-%d-%d', id, diff, levelConf.nLevelID)
    elseif levelType == LaunchType.DLC1_CHAPTER then
        LevelId = string.format('%d-%d-%d', DLC_Chapter.GetChapterID(), DLC_Chapter.GetLevelID(), 1)
    elseif not LevelId then
        LevelId = string.format('%s-%s-%s', Chapter.GetChapterID(), Chapter.GetLevelID(), Chapter.GetChapterDifficult())
    end

    local tbLog = {
    --[[['LevelType'] =]] levelType or LaunchLog.GetLevelType(),
    --[[['LevelId'] = ]] LevelId,
    --[[['BattleGroupId'] = ]] Formation.GetCurLineupIndex(),
    --[[['Character1'] =]]  Character1 or 'NULL',
    --[[['Weapon1'] = ]] Weapon1 or 'NULL',
    --[[['Support1'] = ]] Support1 or 'NULL',

    --[[['Character2'] =]]  Character2 or 'NULL',
    --[[['Weapon2'] = ]] Weapon2 or 'NULL',
    --[[['Support2'] = ]] Support2 or 'NULL',

    --[[['Character3'] =]]  Character3 or 'NULL',
    --[[['Weapon3'] = ]] Weapon3 or 'NULL',
    --[[['Support3'] = ]] Support3 or 'NULL',
    }
    return tbLog
end

-- 联机关卡统计日志
function LaunchLog.LogOnlineTaskActor(GameTaskActor)
    local LevelFinishType = 0
    local LevelTime = 0
    local TaskNodeTime = 0
    local FightNodeTime = 0
    local RealTime = 0

    if GameTaskActor then
        LevelFinishType = GameTaskActor:GetFightLog_LevelFinishType()
        LevelTime = GameTaskActor:GetLevelCountDownTotalTime()
        TaskNodeTime = GameTaskActor:GetFightLog_ExecuteTime()
        FightNodeTime = GameTaskActor:GetFightLog_ExecuteFightTime()
        RealTime = math.floor(GameTaskActor:GetLevelTime())
    end

    return LevelFinishType,LevelTime,TaskNodeTime,FightNodeTime, RealTime
end

--玩家免费获得的1-3级buffID   1
--购物机购买获得的1-3级buffID  0
--特殊商店购买的buffID 2
function LaunchLog.LogOnlineBuffId(GameController, nShopId)
    local BuffId = "NULL"

    if GameController then
        local tbArray = GameController.BoughtBufferes
        if tbArray and tbArray:Length() then
            for i = 1, tbArray:Length() do
                local FBoughtBufferInfo = tbArray:Get(i)
                if FBoughtBufferInfo and FBoughtBufferInfo.ShopId == nShopId then
                    if BuffId == "NULL" then
                        BuffId = FBoughtBufferInfo.BufferCount .. "-" ..FBoughtBufferInfo.BufferId
                    else 
                        BuffId = BuffId .. ";" .. FBoughtBufferInfo.BufferCount .. "-" ..FBoughtBufferInfo.BufferId
                    end
                end
            end
        end
    end
    
    return BuffId
end

function LaunchLog.LogOnlineResurrectTimes(GameController)
    local ResurrectTimes = "NULL"

    if GameController then
        local tbArray = GameController.CharacterReviveInfo
        if tbArray and tbArray:Length() then
            for i = 1, tbArray:Length() do
                local nNum = tbArray:Get(i)
                if ResurrectTimes == "NULL" then
                    ResurrectTimes = string.format("%d", nNum)
                else 
                    ResurrectTimes = ResurrectTimes .. "-" .. string.format("%d", nNum)
                end
            end
        end
    end
    
    return ResurrectTimes
end

function LaunchLog.DSLevelLog(tbInfo)
    if not tbInfo then return {} end

    local nScore = tbInfo.nScore or 0
    local nCoin = tbInfo.nCoin or 0
    local nUseCoin = tbInfo.nUseCoin or 0
    local nResurrectTimes = tbInfo.nResurrectTimes or 0
    local GameController = tbInfo.GameController
    if not GameController then return {} end

    local tbCards = GameController:GetPlayerCharInfos()
    if not tbCards  then return {} end

    local CardNum = tbCards:Length()
    local Card1 = CardNum >= 1 and tbCards:Get(1) or nil
    local Character1Data, Weapon1Data, Parts1Data, Support1Data, nPower1 = LaunchLog.LogCard(Card1)
    local Card2 = CardNum >= 2 and tbCards:Get(2) or nil
    local Character2Data, Weapon2Data, Parts2Data, Support2Data, nPower2 = LaunchLog.LogCard(Card2)
    local Card3 = CardNum >= 3 and tbCards:Get(3) or nil
    local Character3Data, Weapon3Data, Parts3Data, Support3Data, nPower3 = LaunchLog.LogCard(Card3)    
    local HurtData,HealData,DeadTime  = LaunchLog.LogPlayerDataOther(tbInfo.PlayerIndex)
    local LevelFinishType,LevelTime,TaskNodeTime,FightNodeTime, RealTime = LaunchLog.LogOnlineTaskActor(tbInfo.GameTaskActor)

    local tbLog = {
        --[[['LevelId'] = ]] 0,
        --[[['LevelFinishType'] =]] LevelFinishType,
        --[[['LevelTime'] = ]] LevelTime,
        --[[['BattleGroupId'] = ]] Online.TeamId or 10,
        --[[['TeamRoleID'] = ]] "NULL",
        --[[['GetScore'] = ]] nScore,
        --[[['GetCoin'] = ]] nCoin,
        --[[['UseCoin'] = ]] nUseCoin,
        --[[['FreeBuffId'] = ]] LaunchLog.LogOnlineBuffId(GameController, 1),
        --[[['OrdinaryShopBuffId'] = ]] LaunchLog.LogOnlineBuffId(GameController, 0),
        --[[['SpecialShopBuffId'] = ]] LaunchLog.LogOnlineBuffId(GameController, 2),
        --[[['Character1'] =]] Character1Data,
        --[[['Weapon1'] = ]] Weapon1Data,
        --[[['Support1'] = ]] Support1Data,
        --[[['Character2'] =]] Character2Data,
        --[[['Weapon2'] = ]] Weapon2Data,
        --[[['Support2'] = ]] Support2Data,
        --[[['Character3'] =]] Character3Data,
        --[[['Weapon3'] =]] Weapon3Data,
        --[[['Support3'] =]] Support3Data,

        --[[['Character1FightData'] =]] LaunchLog.LogPlayerData(1 + tbInfo.PlayerIndex * 3),
        --[[['Character2FightData'] =]] LaunchLog.LogPlayerData(2 + tbInfo.PlayerIndex * 3),
        --[[['Character3FightData'] =]] LaunchLog.LogPlayerData(3 + tbInfo.PlayerIndex * 3),

        --[[['GetHurtData'] =]] HurtData,
        --[[['HealData'] =]] HealData,
        --[[['DeadTimes'] = ]] DeadTime,

        --[[['ResurrectTimes'] =]] LaunchLog.LogOnlineResurrectTimes(GameController),

        --[[['BossSkillData'] = ]] LaunchLog.GetBossSkillDamage(),
        --[[['BossStageData'] =]] LaunchLog.GetBossStateDamage(),
        --[[['MonsterStageData'] =]] LaunchLog.GetMonsterDamage(),
        --[[['DestructableData'] =]] LaunchLog.GetDestructibleData(),

        --[[['TeamPower'] =]] string.format("%0.1f-%0.1f-%0.1f", nPower1, nPower2, nPower3),

        --[[['OfflineTime'] =]] GameController.PlayerState.TotalOfflineTime,
    }
    return tbLog
end

