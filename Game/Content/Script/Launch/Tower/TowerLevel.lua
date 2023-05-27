-- ========================================================
-- @File    : Launch/Tower/TowerLevel.lua
-- @Brief   : 爬塔关卡数据
-- ========================================================
TowerLevel = TowerLevel or { tbLevel = {} }

---@class TowerLevelTemplate 数据设置逻辑
---@field nID int 唯一ID
---@field nType int 类型
---@field nMapID int 加载地图ID，配置在map/map.txt中的唯一ID
---@field sGameMode string 游戏模式，默认BP_GameBaseMode
---@field sTaskPath string 关卡任务配置路径
---@field tbCondition table 解锁条件
---@field tbConsumeVigor int[] 体力消耗，两部分
---@field tbStarCondition int[] 配置的星级条件列表
---@field tbMonster table 配置的怪物列表，用于显示
---@field nShowListType integer 关卡详情是否显示怪物列表 0或不配显示奖励列表 1显示怪物列表
---@field nRecommendPower int 推荐的战力
---@field bMultipleFight bool 是否允许多重战斗
---@field bAgainFight bool 是否显示【再次挑战】按钮
---@field tbTeamRule table 队伍规则
---@field nNextID int 下一关ID
---@field nPlayerExp int 通关后奖励帐号经验值
---@field nRoleExp int 通关后奖励上场角色经验值
---@field tbBaseDropID table 固定掉落
---@field tbFirstDropID table 首通掉落ID
---@field tbStarAward table 首次达成星级奖励
---@field tbRandomDropID table 随机掉落ID
TowerLevelTemplate = {

    __GetFlag = function(self, nIdx)
        return GetBits(me:GetAttribute(Launch.GID, self.nID), nIdx, nIdx);
    end,

    ---是否首通
    ---@param self TowerLevelTemplate
    IsFirstPass = function(self)
        return self:GetPassTime() == 0
    end,

    ---获得通关次数
    GetPassTime = function(self)
        return me:GetAttribute(Launch.GPASSID, self.nID)
    end,

    ---是否通关
    IsPass = function(self)
        return self:GetPassTime() > 0
    end,

    ---获取掉落
    GetDrop = function(self)
        local sInfo = me:GetStrAttribute(Launch.GID, self.nID)
        if sInfo and sInfo ~= '' then
            return json.decode(sInfo)
        end
        return nil
    end,

    ---获取附加选项
    GetOption = function(self)
        local sOption = 'TaskPath=%s?ReviveCount=%s?AutoReviveTime=%s?AutoReviveHealthScale=%s'
        sOption = string.format(sOption, self.sTaskPath, self.nReviveCount, self.nAutoReviveTime, self.nAutoReviveHealthScale)
        return sOption
    end,

    ---获取体力消耗
    GetConsumeVigor = function(self)
        return (self.tbConsumeVigor[1] or 0) + (self.tbConsumeVigor[2] or 0)
    end,
};


---取得一个关卡配置
---@param nID int 唯一的关卡ID
---@return TowerLevelTemplate 关卡对象
function TowerLevel.Get(nID)
    return TowerLevel.tbLevel[nID];
end

---------------------------------------- 配置加载 --------------------------------------------------
---加载配置
function TowerLevel.Load()
    local tbConfig = LoadCsv("challenge/climbtower/level.txt", 1)
    for _, tbLine in ipairs(tbConfig) do
        local nID = tonumber(tbLine.ID) or 0;
        local tbInfo = {
            Logic               = TowerLevelTemplate,
            nID                 = nID,
            sName               = 'chapter.level_' .. nID,
            sFlag               = 'chapter.level_name_' .. nID,
            sDes                = 'chapter.level_des_' .. nID,
            nType               = ChapterLevelType.RANDOM,
            nMapID              = tonumber(tbLine.MapID) or 0,
            sTaskPath           = string.format('/Game/Blueprints/LevelTask/Tasks/%s', tbLine.TaskPath),
            tbCondition	        = Eval(tbLine.Condition) or {},
            tbConsumeVigor      = Eval(tbLine.ConsumeVigor),
            tbStarCondition     = Eval(tbLine.StarCondition) or {},
            sStarCondition      = tbLine.StarCondition or '', -- 关卡用
            tbMonster           = Eval(tbLine.Monster) or {},
            nShowListType       = tonumber(tbLine.ShowListType) or 0,
            nRecommendPower     = tonumber(tbLine.RecommendPower) or 0,
            bMultipleFight      = tonumber(tbLine.MultipleFight) == 1,
            nNextID             = tonumber(tbLine.NextID),
            nPlayerExp          = tonumber(tbLine.PlayerExp) or 0,
            nRoleExp            = tonumber(tbLine.RoleExp) or 0,
            bAgainFight         = tonumber(tbLine.AgainFight) == 1,
            tbTeamRule          = Eval(tbLine.TeamRule) or {0, 0, 0},
            tbBaseDropID        = Eval(tbLine.BaseDropID) or {},
            tbFirstDropID       = Eval(tbLine.FirstDropID) or {},
            tbRandomDropID      = Eval(tbLine.RandomDropID) or {},
            tbStarAward         = Eval(tbLine.StarAward) or {},
            tbShowAward         = Eval(tbLine.ShowAward) or {},
            tbShowRandomAward   = Eval(tbLine.ShowRandomAward) or {},
            tbShowFirstAward    = Eval(tbLine.ShowFirstAward) or {},
            nPictureBoss        = tonumber(tbLine.PictureBoss),
            nPictureLevel       = tonumber(tbLine.PictureLevel),
            nReviveCount        = tonumber(tbLine.ReviveCount) or 0,
            nAutoReviveTime     = tonumber(tbLine.AutoReviveTime) or 0,
            nAutoReviveHealthScale      = tonumber(tbLine.AutoReviveHealthScale) or 0,
            LevelStrength      = tonumber(tbLine.LevelStrength) or 0,
        }

        setmetatable(tbInfo, {
            __index = function(tb, key)
                local v = rawget(tb, key);
                return v or tb.Logic[key];
            end
        });

        TowerLevel.tbLevel[nID] = tbInfo;
    end
end


---请求进入关卡
function TowerLevel.Req_EnterLevel(nLevelID)
    local tbCfg = TowerLevel.Get(nLevelID)
    if not tbCfg then return end
    ---体力检查
    if tbCfg.tbConsumeVigor and #tbCfg.tbConsumeVigor > 1 and  (not Cash.CheckMoney(Cash.MoneyType_Vigour, tbCfg.tbConsumeVigor[1] + tbCfg.tbConsumeVigor[2])) then
        return
    end

    local diff = 0
    if ClimbTowerLogic.IsAdvanced() then
        diff = ClimbTowerLogic.GetLevelDiff()
    end
    local levelId = string.format("%d-%d-%d", ClimbTowerLogic.NowTimeId, ClimbTowerLogic.GetLevelID(), diff)
    local tbLog = LaunchLog.LogLevelEnter(4, levelId)
    -- 是否开启
    local cmd = {
        nID = nLevelID,
        tbLog = tbLog,
        nTeamID = Formation.GetCurLineupIndex()
    }

    me:CallGS("TowerLevel_EnterLevel", json.encode(cmd))
end

---注册进入关卡的回调
s2c.Register("TowerLevel_EnterLevel", function(tbRet)
    if tbRet.sErr then
        UI.ShowTip(Text(tbRet.sErr))
        return
    end
    TowerLevel.nSeed = tbRet.nSeed
    Launch.Response("TowerLevel_EnterLevel")
end)

---请求结算关卡
function TowerLevel.Req_LevelSettlement(nLevelID)
    local nStar = 0
    local pSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelStarTaskManager)
    if pSubSys then
        nStar = pSubSys:GetStarTaskResultCache()
    end
    local nDrop = 0
    local pDropSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelDropsManager)
    if pDropSubSys then
        nDrop = pDropSubSys:GetSpecialDropsCache()
    end

    local tbKill = {}
    local TaskSubActor = UE4.ATaskSubActor.GetTaskSubActor(GetGameIns())
    local tbMonster = RikiLogic:GetMonsterData(TaskSubActor)
    if TaskSubActor and TaskSubActor.GetAchievementData then
        local tbKillMonster = TaskSubActor:GetAchievementData()
        local tbKey = tbKillMonster:Keys()
        for i = 1, tbKey:Length() do
            local sName = tbKey:Get(i)
            tbKill[sName] = tbKillMonster:Find(tbKey:Get(i))
        end
    end

    local tbLog = {}
    tbLog['FightHistory'] = LaunchLog.LogFightHistory(4)
    tbLog['LevelPerformance'] = LaunchLog.LogPerformance()
    tbLog['FightRecont'] = LaunchLog.LogFightRecont()

    local cmd = {
        nID = nLevelID,
        nTowerID = ClimbTowerLogic.GetLevelID(),
        nSeed = TowerLevel.nSeed,
        tbLog = TowerLevel.Log(),
        tbLog2 = tbLog,
        nTime = Launch.GetLatelyTime(),
        nStar = nStar,
        nDrop = nDrop,
        tbKill = tbKill,
        tbMonster = tbMonster
    }
    UI.ShowConnection()
    Reconnect.Send_SettleInfo("TowerLevel_LevelSettlement", cmd)
end
---注册结算回调
s2c.Register("TowerLevel_LevelSettlement", function(tbAward)
    UI.CloseConnection()
    Launch.Response("TowerLevel_LevelSettlement", tbAward)
end)

---关卡失败
function TowerLevel.Req_LevelFail(nLevelID, nReason)
    local tbLog = {}
    tbLog['FightHistory'] = LaunchLog.LogFightHistory(4)
    tbLog['LevelPerformance'] = LaunchLog.LogPerformance()
    tbLog['FightRecont'] = LaunchLog.LogFightRecont()
    local cmd = {
        nID = nLevelID,
        nTowerID = ClimbTowerLogic.GetLevelID(),
        nSeed = TowerLevel.nSeed,
        tbLog = TowerLevel.Log(nReason),
        tbLog2 = tbLog,
    }
    if nReason ~= UE4.ELevelFailedReason.ManualExit then
        cmd.bClear = true   --如果不是主动退出，爬塔关需要清除进度
    end
    UI.ShowConnection()
    me:CallGS("TowerLevel_LevelFail", json.encode(cmd))
end
s2c.Register("TowerLevel_LevelFail", function()
    UI.CloseConnection()
end)


---获取日志
function TowerLevel.Log(nFailReason)
    local TowerId = ClimbTowerLogic.GetNowRealLayer()   --在哪一层
    local BuffId = "NULL"   --当期的活动buff
    local TimeCfg = ClimbTowerLogic.GetTimeCfg()
    if TimeCfg and TimeCfg.tbBuffID[1] then
        BuffId = TimeCfg.tbBuffID[1]
    end
    local TaskName = table.concat(ClimbTowerLogic.tbTaskName, "-")   --1号房间任务ID-2号房间任务ID-3号房间任务ID
    if nFailReason then
        local nowArea = ClimbTowerLogic.GetLevelArea()
        local GameTaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
        local LevelFinishType = 0
        if GameTaskActor then 
            LevelFinishType = GameTaskActor:GetFightLog_LevelFinishType()
        end
        ClimbTowerLogic.tbTaskFinishType[nowArea] = LevelFinishType
    end
    local TaskFinishType = table.concat(ClimbTowerLogic.tbTaskFinishType, "-")   --任务1完成情况-任务2完成情况-任务3完成情况

    local TaskGetStar = "NULL"   --本次新获得星
    for i = 1, 3 do
        local str = "NULL"
        local tb = ClimbTowerLogic.tbTaskFinalStar[i]
        if tb and #tb > 0 then
            str = table.concat(tb, "-")
        end
        if TaskGetStar == "NULL" then
            TaskGetStar = str
        else
            TaskGetStar = TaskGetStar .. ";" ..str
        end
    end

    local tbteam = Formation.GetCurrentLineup()
    local tbCards = tbteam and tbteam:GetCards() or nil
    local CardNum = tbCards:Length()
    local Card1 = CardNum >= 1 and tbCards:Get(1) or nil
    local Character1Data, Weapon1Data, Parts1Data, Support1Data, nPower1 = LaunchLog.LogCard(Card1)
    local Card2 = CardNum >= 2 and tbCards:Get(2) or nil
    local Character2Data, Weapon2Data, Parts2Data, Support2Data, nPower2 = LaunchLog.LogCard(Card2)
    local Card3 = CardNum >= 3 and tbCards:Get(3) or nil
    local Character3Data, Weapon3Data, Parts3Data, Support3Data, nPower3 = LaunchLog.LogCard(Card3)

    local HurtData, HealData, DeadTime  = LaunchLog.LogPlayerDataOther()

    local LevelFinishType,GetStar,FinalStar,LevelTime,TaskNodeTime,FightNodeTime, RealTime = LaunchLog.LogTaskActor()
    ---推荐战力
    local RequirePower = 0
    local cfg = TowerLevel.Get(ClimbTowerLogic.GetLevelID())
    if cfg then
        RequirePower = cfg.nRecommendPower
    end

    ---操作日志
    local sOperationSetting = string.format('%s-%s-%s-%s-%s-%s-%s',
        PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.JOYSTIC) or 0,
        PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.CROSSHAIR_FORCE) or 0,
        PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.SKILL_FRAME) or 0,
        PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.FIRE_ADSORB) or 0,
        PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.AIM) or 0,
        PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.SLIDE) or 0,
        PlayerSetting.GetOne(PlayerSetting.SSID_OPERATION, OperationType.ACC_FACTOR) or 0
    )

    local levelcfg = ClimbTowerLogic.GetLevelCfg()
    local LevelBuff = "NULL"
    if levelcfg and levelcfg.tbLevelBuff then
        LevelBuff = table.concat(levelcfg.tbLevelBuff, ";")
    end

    local Diff = "NULL-0"
    local diff = 0
    if ClimbTowerLogic.IsAdvanced() then
        diff = ClimbTowerLogic.GetLevelDiff()
        if diff ~= 0 and levelcfg and levelcfg.tbMonsterLevel[diff] then
            Diff = diff .. "-" .. levelcfg.tbMonsterLevel[diff]
        end
    end

    local levelId = string.format("%d-%d-%d", ClimbTowerLogic.NowTimeId, ClimbTowerLogic.GetLevelID(), diff)

    local tbLog = {
        --[[['在哪一层'] =]] TowerId,
        --[[['当期的活动buff'] = ]] BuffId,
        --[[['任务1ID-任务2ID...'] =]] TaskName,
        --[[['任务1完成情况-任务2完成情况'] = ]] TaskFinishType,
        --[[['本次新获得星'] = ]] TaskGetStar,
        --[[['最终获得星'] = ]] "NULL",
        --[[['任务1用时（秒）-任务2用时（秒）-任务3用时（秒）'] = ]] table.concat(ClimbTowerLogic.tbTaskTime, "-"),
        --[[['各节点耗时记录'] = ]] TaskNodeTime,
        --[[['各节点仇恨时间'] = ]] FightNodeTime,

        --[[['1号位角色数据'] = ]] Character1Data,
        --[[['1号位武器数据'] =]] Weapon1Data,
        --[[['1号位武器配件数据'] = ]] Parts1Data,
        --[[['1号位3个后勤数据'] = ]] Support1Data,
        --[[['2号位角色数据'] = ]] Character2Data,
        --[[['2号位武器数据'] =]] Weapon2Data,
        --[[['2号位武器配件数据'] = ]] Parts2Data,
        --[[['2号位3个后勤数据'] = ]] Support2Data,
        --[[['3号位角色数据'] = ]] Character3Data,
        --[[['3号位武器数据'] =]] Weapon3Data,
        --[[['3号位武器配件数据'] =]] Parts3Data,
        --[[['3号位3个后勤数据'] = ]] Support3Data,

        --[[['1号位角色普攻次数 普攻命中次数..'] =]] LaunchLog.LogPlayerData(1),
        --[[['2号位角色普攻次数 普攻命中次数..'] =]] LaunchLog.LogPlayerData(2),
        --[[['3号位角色普攻次数 普攻命中次数..'] =]] LaunchLog.LogPlayerData(3),

        --[[['角色1承伤~角色2承伤~角色3承伤'] =]] HurtData,
        --[[['角色1回复;角色2回复;角色3回复'] =]] HealData,
        --[[['角色1死亡次数-角色2死亡次数-角色3死亡次数'] =]] DeadTime,

        --[[['关卡中BOSS造成伤害前5的技能数据'] =]] LaunchLog.GetBossSkillDamage(),
        --[[['关卡中BOSS各阶段的数据'] =]] LaunchLog.GetBossStateDamage(),
        --[[['关卡中造成伤害前5的小怪伤害'] =]] LaunchLog.GetMonsterDamage(),
        --[[['关卡中被破坏的可破坏物的数量'] =]] LaunchLog.GetDestructibleData(),
        --[[['角色1战力-角色2战力-角色3战力'] =]] string.format("%0.1f-%0.1f-%0.1f", nPower1, nPower2, nPower3),
        --[[['关卡要求战力'] =]] RequirePower,
        --[[['射击模式-准心阻力-技能锁定提示-技能瞄准等级-瞄准操作灵敏度-视角操作滑屏-滑动操作加速度'] =]] sOperationSetting,

        --[[['关卡自带且启用的buffid，没有记'NULL', 多个用;分开'] =]] LevelBuff,
        --[[['当前关卡的难度等级及怪物等级，记为'难度等级-怪物等级', 若没有难度等级则记为'NULL-怪物等级'] =]] Diff,
        --[[['塔期数-关卡ID-难度ID =]] levelId
    }
    return tbLog
end

TowerLevel.Load()
