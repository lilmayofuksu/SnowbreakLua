-- ========================================================
-- @File    : Challenge/Boss/Boss.lua
-- @Brief   : boss挑战逻辑
-- ========================================================

BossLogic = BossLogic or {}

BossLogic.GID           = 6     --Boss挑战GID

BossLogic.ActivitySubID = 0     --存当前开放的活动ID

BossLogic.DiffRecordID  = 99    --存解锁的难度等级
BossLogic.StartSID      = 100   --1-100存奖励领取信息，之后存boss关信息
BossLogic.SubNum        = 50    --每个boss关的存的信息不能超过50个(不可修改)
--[[
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 0      积分成绩

    --记道具ID，处理锁定逻辑
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 1      角色1
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 2      武器
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 3      后勤1-1
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 4      后勤1-2
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 5      后勤1-3

    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 6      角色2
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 7      武器
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 8      后勤2-1
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 9      后勤2-2
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 10     后勤2-3

    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 11     角色3
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 12     武器
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 13     后勤3-1
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 14     后勤3-2
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 15     后勤3-3

    --显示快照信息，防止升级或消耗后信息变化
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 20     武器1 GDPL-level-配件情况
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 21     后勤1-1 GDPL-level
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 22     后勤1-2 GDPL-level
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 23     后勤1-3 GDPL-level

    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 30     角色2 GDPL-level-配件情况
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 31     后勤2-1 GDPL-level
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 32     后勤2-2 GDPL-level
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 33     后勤2-3 GDPL-level

    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 40     角色3 GDPL-level-配件情况
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 41     后勤3-1 GDPL-level
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 42     后勤3-2 GDPL-level
    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 43     后勤3-3 GDPL-level

    BossLogic.SubNum * bossLevelID + BossLogic.StartSID + 44     通关时间
--]]

--- 当前开放的活动ID
BossLogic.NowOpenID     = nil
--- 当前开放的活动ID
BossLogic.NowBossLevelID     = nil

---加载配置
function BossLogic.LoadCfg()
    BossLogic.LoadTimeCfg()
    BossLogic.LoadBossLevelCfg()
    BossLogic.LoadSceneDataCfg()
    BossLogic.LoadEntriesPoolCfg()
    BossLogic.LoadEntriesCfg()
    BossLogic.LoadAwardCfg()
    BossLogic.LoadLevelCfg()
end

--- 加载时间周期配置
function BossLogic.LoadTimeCfg()
    BossLogic.tbTimeCfg = {}
    local tbFile = LoadCsv('challenge/boss/boss_challenge.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID             = nID,
                sName           = tbLine.Name,
                sDesc           = tbLine.Desc,
            };

            tbInfo.nStartTime      = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), tbInfo, "nStartTime")
            tbInfo.nEndTime        = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), tbInfo, "nEndTime")

            tbInfo.tbBossID = {}
            for i = 1, 10 do
                local bossID = tonumber(tbLine["Boss"..i])
                if bossID then
                    tbInfo.tbBossID[i] = bossID
                else
                    break
                end
            end
            BossLogic.tbTimeCfg[nID] = tbInfo
        end
    end
    print('challenge/boss/boss_challenge.txt')
end

--- 加载关卡配置
function BossLogic.LoadBossLevelCfg()
    BossLogic.tbBossLevelCfg = {}
    local tbFile = LoadCsv('challenge/boss/boss.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID             = nID,
                nLevelID        = tonumber(tbLine.LevelID),
                nBossID         = tonumber(tbLine.BossID),
                tbBuffID        = Eval(tbLine.tbBuffID) or {},
                tbBossLevel     = Eval(tbLine.BossLevel) or {},
                tbBossEntries   = Eval(tbLine.BossEntries) or {},
                nDataId         = tonumber(tbLine.DataId) or 0,
            };
            tbInfo.sName = tbInfo.nBossID
            tbInfo.GetName = function()
                return Text(Localization.GetMonsterName(tbInfo.nBossID))
            end
            tbInfo.sDesc = tbInfo.nBossID
            BossLogic.tbBossLevelCfg[nID] = tbInfo
        end
    end
    print('challenge/boss/boss.txt')
end

--- 加载场景内boss显示配置
function BossLogic.LoadSceneDataCfg()
    BossLogic.tbSceneDataCfg = {}
    local tbFile = LoadCsv('challenge/boss/scene_data.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID             = nID,
                Position        = Eval(tbLine.Position) or {},
                Rotator         = Eval(tbLine.Rotator) or {},
                Scale           = Eval(tbLine.Scale) or {},
                BPScale         = Eval(tbLine.BPScale) or {},
                BossRotator     = Eval(tbLine.BossRotator) or {},
                BossPosition    = Eval(tbLine.BossPosition) or {},
                BPPosition      = Eval(tbLine.BPPosition) or {}
            };
            BossLogic.tbSceneDataCfg[nID] = tbInfo
        end
    end
    print('challenge/boss/scene_data.txt')
end

--- 加载词条组信息配置
function BossLogic.LoadEntriesPoolCfg()
    BossLogic.tbEntriesPoolCfg = {}
    local tbFile = LoadCsv('challenge/boss/entries_pool.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID             = nID,
                tbEntries       = Eval(tbLine.tbEntries) or {},
            };
            BossLogic.tbEntriesPoolCfg[nID] = tbInfo
        end
    end
    print('challenge/boss/entries_pool.txt')
end

--- 加载词条信息配置
function BossLogic.LoadEntriesCfg()
    BossLogic.tbEntriesCfg = {}
    local tbFile = LoadCsv('challenge/boss/entries.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID             = nID,
                nEntryID        = tonumber(tbLine.EntryID) or 0,
                tbCondition     = Eval(tbLine.Condition) or {},
                nDiffLimit      = tonumber(tbLine.DiffLimit) or 0,
                tbMutex         = Eval(tbLine.tbMutex) or {},
                nScore          = tonumber(tbLine.Score) or 0,
                nType           = tonumber(tbLine.Type) or 0,
                tbParam         = Eval(tbLine.tbParam) or {},
                sDesc           = tbLine.Desc,
                sSummary        = tbLine.Summary,
            };
            BossLogic.tbEntriesCfg[nID] = tbInfo
        end
    end
    print('challenge/boss/entries.txt')
end

--- 加载关卡配置
function BossLogic.LoadLevelCfg()
    BossLogic.tbLevel = {}
    local tbConfig = LoadCsv("challenge/boss/level.txt", 1)
    for _, tbLine in ipairs(tbConfig) do
        local nID = tonumber(tbLine.ID) or 0;
        local tbInfo = {
            nID                 = nID,
            nType               = tonumber(tbLine.Type) or 0,
            nMapID              = tonumber(tbLine.MapID) or 0,
            -- sTaskPath           = string.format('/Game/Blueprints/LevelTask/Tasks/%s', tbLine.TaskPath),
            -- tbCondition	        = Eval(tbLine.Condition) or {},
            -- tbConsumeVigor      = Eval(tbLine.ConsumeVigor),
            -- tbStarCondition     = Eval(tbLine.StarCondition) or {},
            -- sStarCondition      = tbLine.StarCondition or '', -- 关卡用
            -- tbMonster           = Eval(tbLine.Monster) or {},
            -- nRecommendPower     = tonumber(tbLine.RecommendPower) or 0,
            -- bMultipleFight      = tonumber(tbLine.MultipleFight) == 1,
            -- nNextID             = tonumber(tbLine.NextID),
            -- nPlayerExp          = tonumber(tbLine.PlayerExp) or 0,
            -- nRoleExp            = tonumber(tbLine.RoleExp) or 0,
            -- bAgainFight         = tonumber(tbLine.AgainFight) == 1,
            -- tbTeamRule          = Eval(tbLine.TeamRule) or {0, 0, 0},
            -- tbBaseDropID        = Eval(tbLine.BaseDropID) or {},
            -- tbFirstDropID       = Eval(tbLine.FirstDropID) or {},
            -- tbRandomDropID      = Eval(tbLine.RandomDropID) or {},
            -- tbStarAward         = Eval(tbLine.StarAward) or {},
            -- tbShowAward         = Eval(tbLine.ShowAward) or {},
            -- tbShowFirstAward    = Eval(tbLine.ShowFirstAward) or {},
            -- nPictureBoss        = tonumber(tbLine.PictureBoss),
            -- nPictureLevel       = tonumber(tbLine.PictureLevel),
            -- nReviveCount        = tonumber(tbLine.ReviveCount) or 0,
            -- nAutoReviveTime     = tonumber(tbLine.AutoReviveTime) or 0,
            -- nAutoReviveHealthScale = tonumber(tbLine.AutoReviveHealthScale) or 0,
        }
        BossLogic.tbLevel[nID] = tbInfo;
    end
end

--- 加载积分奖励配置
function BossLogic.LoadAwardCfg()
    BossLogic.tbAwardCfg = {}
    local tbFile = LoadCsv('challenge/boss/boss_award.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID and nID > 0 then
            local tbInfo = {}
            tbInfo.nID = nID
            tbInfo.nScoreCount  = tonumber(tbLine.ScoreCount) or 0
            tbInfo.tbScoreAward = Eval(tbLine.ScoreAward) or {}
            BossLogic.tbAwardCfg[nID] = tbInfo
        end
    end
    print('challenge/boss/boss_award.txt')
end

---检查是否有可领取的奖励
function BossLogic.IsCanReceive()
    if not BossLogic.tbAwardCfg then return false end
    local integral = BossLogic.GetTotalIntegral()
    for i, info in pairs(BossLogic.tbAwardCfg) do
        if integral >= info.nScoreCount and not BossLogic.IsReceive(i) then
            return true
        end
    end
    return false
end

---获取当前的活动配置
function BossLogic.GetTimeCfg()
    if not BossLogic.NowOpenID then
        return nil
    end
    return BossLogic.tbTimeCfg[BossLogic.NowOpenID]
end

---获取boss关配置
function BossLogic.GetBossLevelCfg(id)
    if not id then return nil end
    return BossLogic.tbBossLevelCfg[id]
end

---获取boss关地图ID
function BossLogic.GetMapID(ID)
    ---先检查选择的词条中是否有更改地图ID
    for id, v in pairs(BossLogic.tbSelectEntrie) do
        if v and BossLogic.tbEntriesCfg[id] and BossLogic.tbEntriesCfg[id].nType == 3 and #BossLogic.tbEntriesCfg[id].tbParam > 0 then
            return tonumber(BossLogic.tbEntriesCfg[id].tbParam[1])
        end
    end
    local cfg = BossLogic.GetBossLevelCfg(ID)
    if not cfg or not cfg.nLevelID then
        return
    end
    if BossLogic.tbLevel[cfg.nLevelID] then
        return BossLogic.tbLevel[cfg.nLevelID].nMapID
    end
end

---保存当前进行的BOSS关ID
function BossLogic.SetBossLevelID(nID)
    if BossLogic.NowBossLevelID ~= nID then
        BossLogic.ClearEntrie()
        BossLogic.SetNowDifficulty(1)
        BossLogic.SetNowIntegral(0)
    end
    BossLogic.NowBossLevelID = nID
end
---获取当前进行的BOSS关ID
function BossLogic.GetBossLevelID()
    return BossLogic.NowBossLevelID
end

BossLogic.tbSelectEntrie = {}    ---选择的词条
---增加一个词条
function BossLogic.AddEntrie(id)
    local cfg = BossLogic.tbEntriesCfg[id]
    if not cfg then return end
    for _, mid in pairs(cfg.tbMutex) do
        if BossLogic.tbSelectEntrie[mid] then
            BossLogic.ReduceEntrie(mid)
        end
    end
    BossLogic.tbSelectEntrie[id] = true
end
---减少一个词条
function BossLogic.ReduceEntrie(id)
    BossLogic.tbSelectEntrie[id] = nil
end
---清空选择的词条
function BossLogic.ClearEntrie()
    BossLogic.tbSelectEntrie = {}
end
---选择的词条中移除不符合当前难度要求的词条
function BossLogic.CheckDiffLimit()
    for id, v in pairs(BossLogic.tbSelectEntrie) do
        local cfg = BossLogic.tbEntriesCfg[id]
        if v and cfg and cfg.nDiffLimit > BossLogic.GetNowDifficulty() then
            BossLogic.ReduceEntrie(id)
        end
    end
end
---判断词条是否解锁
function BossLogic.IsUnLock(id)
    local cfg = BossLogic.tbEntriesCfg[id]
    if not cfg then
        return false
    end
    local tbCondition = cfg.tbCondition
    if not tbCondition or #tbCondition <= 0 then
        return true
    end
    if tbCondition[1] == 1 and #tbCondition >= 3 then ---积分
        return BossLogic.GetTotalIntegral() >= tbCondition[2], Text("bossentries.unlock1", tbCondition[2])
    end
    if tbCondition[1] == 2 and #tbCondition >= 2 then ---等级
        return me:Level() >= tbCondition[2], Text("bossentries.unlock2", tbCondition[2])
    end
    return true
end
---获取一个词条的状态 返回 0未解锁 1已选择 2未选择 3不可选择
function BossLogic.GetEntrieState(id)
    local isUnLock, desc = BossLogic.IsUnLock(id)
    if not isUnLock then
        return 0, desc    --未解锁
    end
    if BossLogic.tbSelectEntrie[id] then
        return 1    --已选择
    end
    for k, v in pairs(BossLogic.tbSelectEntrie) do
        if v and BossLogic.tbEntriesCfg[k] then
            for _, mid in pairs(BossLogic.tbEntriesCfg[k].tbMutex) do
                if id == mid then
                    return 3    --不可选择
                end
            end
        end
    end
    return 2    --未选择
end
---获得选择的词条(外部调用，在关卡内生效)
function BossLogic.GetTbEntrie()
    local EntrieArray = UE4.TArray(UE4.int32)
    if Launch.GetType() ~= LaunchType.BOSS then
        return EntrieArray
    end
    for id, v in pairs(BossLogic.tbSelectEntrie) do
        if v and BossLogic.tbEntriesCfg[id] and BossLogic.tbEntriesCfg[id].nType == 0 then
            EntrieArray:Add(id)
        end
    end
    return EntrieArray
end
---获得选择的词条中的BUFFID和关卡自带的BUFFID(外部调用，在关卡内生效)
function BossLogic.GetTbBuffID()
    local data = {}
    if Launch.GetType() ~= LaunchType.BOSS then
        return data
    end
    for id, v in pairs(BossLogic.tbSelectEntrie) do
        if v and BossLogic.tbEntriesCfg[id] and BossLogic.tbEntriesCfg[id].nEntryID > 0 then
            table.insert(data, BossLogic.tbEntriesCfg[id].nEntryID)
        end
    end
    local levelcfg = BossLogic.GetBossLevelCfg(BossLogic.GetBossLevelID())
    if levelcfg and #levelcfg.tbBuffID > 0 then
        for _, id in pairs(levelcfg.tbBuffID) do
            table.insert(data, id)
        end
    end
    return data
end
---获得选择的词条中的通关时间限制(外部调用，在关卡内生效)
function BossLogic.GetTimeLimit()
    if Launch.GetType() ~= LaunchType.BOSS then
        return 0
    end
    for id, v in pairs(BossLogic.tbSelectEntrie) do
        if v and BossLogic.tbEntriesCfg[id] and BossLogic.tbEntriesCfg[id].nType == 1 and #BossLogic.tbEntriesCfg[id].tbParam > 0 then
            return tonumber(BossLogic.tbEntriesCfg[id].tbParam[1]) or 0
        end
    end
    return 0
end
---获得选择的词条中的角色限制
function BossLogic.GetRoleLimit()
    for id, v in pairs(BossLogic.tbSelectEntrie) do
        if v and BossLogic.tbEntriesCfg[id] and BossLogic.tbEntriesCfg[id].nType == 2 and #BossLogic.tbEntriesCfg[id].tbParam > 0 then
            return tonumber(BossLogic.tbEntriesCfg[id].tbParam[1]) or 0
        end
    end
    return 0
end
---获得选择的难度对应的怪物等级
function BossLogic.GetBossGrade()
    local info = BossLogic.GetNowDifficultyInfo()
    if info and info[2] then
        return info[2]
    end
    return 1
end
---根据选择的词条计算积分
function BossLogic.GetIntegralByEntries()
    local num = 0
    for id, v in pairs(BossLogic.tbSelectEntrie) do
        local cfg = BossLogic.tbEntriesCfg[id]
        if v and cfg then
            num = num + cfg.nScore
        end
    end
    local difficultyInfo = BossLogic.GetNowDifficultyInfo()
    if difficultyInfo then
        if difficultyInfo[4] then
            num = num + difficultyInfo[4]
        end
        if difficultyInfo[3] then
            num = num * difficultyInfo[3]
        end
    end
    return math.ceil(num)
end

---暂存当前选择的难度
function BossLogic.SetNowDifficulty(v)
    local cfg = BossLogic.GetBossLevelCfg(BossLogic.GetBossLevelID())
    if cfg then
        BossLogic.NowDifficulty = math.min(v, #cfg.tbBossLevel)
    end
end
---获取当前选择的难度
function BossLogic.GetNowDifficulty()
    if not BossLogic.NowDifficulty then
        BossLogic.NowDifficulty = 1
    end
    return BossLogic.NowDifficulty
end
---获取当前选择的难度对应的信息
function BossLogic.GetNowDifficultyInfo()
    local bosslevelcfg = BossLogic.GetBossLevelCfg(BossLogic.GetBossLevelID())
    if bosslevelcfg and bosslevelcfg.tbBossLevel then
        return bosslevelcfg.tbBossLevel[BossLogic.GetNowDifficulty()]
    end
end

---暂存当前挑战积分
function BossLogic.SetNowIntegral(v)
    BossLogic.CountIntegral = v
end
---获取当前暂存的挑战积分
function BossLogic.GetNowIntegral()
    return BossLogic.CountIntegral or 0
end

---检查是否能出战
function BossLogic.CanFight()
    local lineup = Formation.GetCurrentLineup()
    for i = 1, 3 do
        local pCard = lineup:GetMember(i-1):GetCard()
        if pCard then
            local islock, msg = BossLogic.CheckCardIsLock(pCard)
            if islock then
                return false, msg
            end
        end
    end
    return true
end

---检查角色是否被锁定(被锁定返回true)
function BossLogic.CheckCardIsLock(pCard)
    local TimeCfg = BossLogic.GetTimeCfg()
    if not pCard or not TimeCfg then return false end
    for _, id in pairs(TimeCfg.tbBossID) do
        local bossname = ""
        local cfg = BossLogic.GetBossLevelCfg(id)
        if cfg then
            bossname = Localization.GetMonsterName(cfg.nBossID)
        end
        if id ~= BossLogic.GetBossLevelID() then
            for _, roleid in pairs(BossLogic.GetMaxIntegralLineup(id)) do
                if roleid ~= 0 and pCard:Id() == roleid then
                    return true, Text("bossentries.lock1", bossname)
                end
            end

            local PWeapon = pCard:GetSlotWeapon()
            for _, weaponid in pairs(BossLogic.GetMaxIntegralWeapon(id)) do
                if weaponid ~= 0 and PWeapon:Id() == weaponid then
                    return true, Text("bossentries.lock2", bossname)
                end
            end

            local tbItem = UE4.TArray(UE4.USupporterCard)
            pCard:GetSupporterCards(tbItem)
            for i = 1, tbItem:Length() do
                local PItem = tbItem:Get(i)
                for _, supporterid in pairs(BossLogic.GetMaxIntegralSupporter(id)) do
                    if supporterid ~= 0 and PItem:Id() == supporterid then
                        return true, Text("bossentries.lock3", bossname)
                    end
                end
            end
        end
    end
    return false
end
---检查角色是否被boss锁定(锁定返回true)
function BossLogic.CheckCard(templateId)
    local pCard = nil
    local Cards = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(Cards)
    for i = 1, Cards:Length() do
        local card = Cards:Get(i)
        if card:TemplateId() == templateId then
            pCard = card
            break
        end
    end
    local TimeCfg = BossLogic.GetTimeCfg()
    if not pCard or not TimeCfg then return false end
    local islock = false
    for _, id in pairs(TimeCfg.tbBossID) do
        if id ~= BossLogic.GetBossLevelID() then
            for _, roleid in pairs(BossLogic.GetMaxIntegralLineup(id)) do
                if roleid ~= 0 and pCard:Id() == roleid then
                    islock = true
                    break
                end
            end
        end
    end
    return islock
end
---检查武器是否被boss锁定(锁定返回true)
function BossLogic.CheckWeapon(PWeapon)
    local TimeCfg = BossLogic.GetTimeCfg()
    if not PWeapon or not TimeCfg then return false end
    local islock = false
    for _, id in pairs(TimeCfg.tbBossID) do
        if id ~= BossLogic.GetBossLevelID() then
            for _, weaponid in pairs(BossLogic.GetMaxIntegralWeapon(id)) do
                if weaponid ~= 0 and PWeapon:Id() == weaponid then
                    islock = true
                    break
                end
            end
        end
    end
    return islock
end
---检查后勤是否被boss锁定(锁定返回true)
function BossLogic.CheckSupporter(pSupporter)
    local TimeCfg = BossLogic.GetTimeCfg()
    if not pSupporter or not TimeCfg then return false end
    local islock = false
    for _, id in pairs(TimeCfg.tbBossID) do
        if id ~= BossLogic.GetBossLevelID() then
            for _, supporterid in pairs(BossLogic.GetMaxIntegralSupporter(id)) do
                if supporterid ~= 0 and pSupporter:Id() == supporterid then
                    islock = true
                    break
                end
            end
        end
    end
    return islock
end

---获取本期所有boss关总分分
function BossLogic.GetTotalIntegral()
    local timecfg = BossLogic.GetTimeCfg()
    if not timecfg then
        return 0
    end
    local n = 0
    for _, bosslevelid in pairs(timecfg.tbBossID) do
        n = n + BossLogic.GetMaxIntegral(bosslevelid)
    end
    return n
end

---获取boss关存储的历史最高分
function BossLogic.GetMaxIntegral(id)
    id = id or BossLogic.GetBossLevelID()
    return me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 0)
end

---获取boss关存储的通关耗时
function BossLogic.GetLevelFinishTime(id)
    id = id or BossLogic.GetBossLevelID()
    return me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 44)
end

---获取boss关存储的历史最高分编队
function BossLogic.GetMaxIntegralLineup(id)
    id = id or BossLogic.GetBossLevelID()
    local roledata = {}
    roledata[1] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 1)
    roledata[2] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 6)
    roledata[3] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 11)
    local isNone = nil
    if roledata[1] == 0 and roledata[2] == 0 and roledata[3] == 0 then
        isNone = true
    end
    return roledata, isNone
end
---获取boss关存储的历史最高分武器
function BossLogic.GetMaxIntegralWeapon(id)
    id = id or BossLogic.GetBossLevelID()
    local data = {}
    data[1] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 2)
    data[2] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 7)
    data[3] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 12)
    return data
end
---获取boss关存储的历史最高分后勤
function BossLogic.GetMaxIntegralSupporter(id)
    id = id or BossLogic.GetBossLevelID()
    local data = {}
    data[1] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 3)
    data[2] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 4)
    data[3] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 5)
    data[4] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 8)
    data[5] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 9)
    data[6] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 10)
    data[7] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 13)
    data[8] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 14)
    data[9] = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + 15)
    return data
end

---获取一个boss关的历史积分和阵容信息
function BossLogic.GetIntegralAndFormation(id)
    id = id or BossLogic.GetBossLevelID()
    local data = {}
    for i = 1, 3 do
        local info = {}
        info.nRole = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + ((i-1)*5+1))
        if info.nRole ~= 0 then
            local wValue = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + (i*10+10))
            info.WG = GetBits(wValue, 0, 1)
            info.WD = GetBits(wValue, 2, 6)
            info.WP = GetBits(wValue, 7, 15)
            info.WL = GetBits(wValue, 16, 19)
            info.WLevel = GetBits(wValue, 20, 26)
            info.tbPart = {GetBits(wValue, 27, 27), GetBits(wValue, 28, 28), GetBits(wValue, 29, 29), GetBits(wValue, 30, 30), GetBits(wValue, 31, 31)}

            info.sInfo = {}
            for j = 1, 3 do
                local sValue = me:GetAttribute(BossLogic.GID, BossLogic.SubNum * id + BossLogic.StartSID + (i*10+10+j))
                local sinfo = nil
                if sValue ~= 0 then
                    sinfo = {}
                    sinfo.SG = GetBits(sValue, 0, 1)
                    sinfo.SD = GetBits(sValue, 2, 3)
                    sinfo.SP = GetBits(sValue, 4, 13)
                    sinfo.SL = GetBits(sValue, 14, 19)
                    sinfo.SLevel = GetBits(sValue, 20, 26)
                    sinfo.BreakNum = GetBits(sValue, 27, 31)
                end
                info.sInfo[j] = sinfo
            end
        end
        data[i] = info
    end
    return data
end

---获取当前挑战的积分和阵容信息(结算时调用)
function BossLogic.GetData()
    local id  = BossLogic.GetBossLevelID()
    local data = {}
    data.nID = id
    data.nTime = BossLogic.FinishTime

    local lineup = Formation.GetCurrentLineup()
    for i = 1, 3 do
        local pCard = lineup:GetMember(i-1):GetCard()
        if pCard then
            data["nRole"..i] = pCard:Id()
            local weapon = pCard:GetSlotWeapon()
            if weapon then
                data["nWeapon"..i] = weapon:Id()
            end
            data["nSupporter"..i] = {}
            for k = 1, 3 do
                local Item = pCard:GetSupporterCardForIndex(k)
                if Item then
                    data["nSupporter"..i][k] = Item:Id()
                else
                    data["nSupporter"..i][k] = 0
                end
            end
        end
    end
    return data
end

---获取奖励领取情况
---@param mileage integer 里程
function BossLogic.IsReceive(mileage)
    if mileage and mileage > 0 and mileage < BossLogic.StartSID then
        return me:GetAttribute(BossLogic.GID, mileage) > 0
    end
    return true
end

---向服务器请求领取奖励
---@param mileage integer 要领取的里程
function BossLogic.GetReward(mileage)
    if not mileage then
        return
    end
    local data = {Mileage = mileage}
    me:CallGS("BossLogic_GetReward", json.encode(data))
end
---一键领取奖励
function BossLogic.OneClicReward()
    me:CallGS("BossLogic_OneClicReward")
end
-- 领取奖励后的回调
s2c.Register('BossLogic_GetReward',function(tbParam)
    if tbParam.tbAward then
        Item.Gain(tbParam.tbAward)
    end
    local sUI = UI.GetUI("DungeonsBoss")
    if sUI and sUI:IsOpen() then
        sUI:OnReceiveCallback()
    end
end)

---向服务器请求当前开放的活动
function BossLogic.GetOpenID()
    FunctionRouter.CheckEx(FunctionType.BossChallenge, function()
        if UI.IsOpen("DungeonsBoss") then
            UI.ShowConnection()
            me:CallGS("BossLogic_GetOpenID")
        else
            UI.Open("DungeonsBoss")
        end
    end)
end
---向服务器请求当前开放活动后的回调
s2c.Register("BossLogic_GetOpenID", function(tbParam)
    UI.CloseConnection()
    local sUI = UI.GetUI("DungeonsBoss")
    if tbParam and tbParam.nID then
        BossLogic.NowOpenID = tbParam.nID
        if tbParam.tbTimeCfg then   --GM指令设置期数的时候将服务器配置修改后同步下来
            BossLogic.tbTimeCfg = tbParam.tbTimeCfg
        end
        if sUI and sUI:IsOpen() then
            sUI:UpdatePanel()
        end
    else
        BossLogic.NowOpenID = nil
        UI.ShowTip(Text("ui.TxtNotOpen"))
        if sUI and sUI:IsOpen() then
            sUI:ShowWaitOpenPanel()
        end
    end
end)

---重置
function BossLogic.Reset()
    UI.ShowConnection()
    me:CallGS("BossLogic_Reset", json.encode({nID = BossLogic.GetBossLevelID()}))
end
s2c.Register("BossLogic_Reset", function()
    UI.CloseConnection()
    local sUI = UI.GetUI("DungeonsBoss")
    if sUI and sUI:IsOpen() then
        sUI:UpdatePanel()
    end
end)

BossLogic.nSeed = nil       ---验证参数
---请求进入关卡
---@param tbEntrie table 选择的词条ID
function BossLogic.Req_EnterLevel()
    local tbEntrie = {}
    for id, v in pairs(BossLogic.tbSelectEntrie) do
        if v then
            table.insert(tbEntrie, id)
        end
    end

    -- 是否开启
    local cmd = {
        nID = BossLogic.GetBossLevelID(),
        nTeamID = Formation.GetCurLineupIndex(),
        nDifficulty = BossLogic.GetNowDifficulty(),
        tbEntrie = tbEntrie,
        tbLog = BossLogic.EnterLog(),
    }

    me:CallGS("BossLogic_EnterLevel", json.encode(cmd))
end
---注册进入关卡的回调
s2c.Register("BossLogic_EnterLevel", function(tbRet)
    BossLogic.nSeed = tbRet.nSeed
    Launch.Response("BossLogic_EnterLevel")
end)

---关卡结束
function BossLogic.Req_LevelEnd()
    UI.ShowConnection()
    Reconnect.Send_SettleInfo("BossLogic_LevelEnd", {nID = BossLogic.GetBossLevelID(), nSeed = BossLogic.nSeed})
end
---注册关卡结束回调
s2c.Register("BossLogic_LevelEnd", function()
    UI.CloseConnection()
    UI.Open("Success")
end)

---请求结算关卡
---@param IsRecord integer 是否记录成绩
function BossLogic.Req_LevelSettlement(IsRecord)
    local data = nil
    if IsRecord then
        data = BossLogic.GetData()
    end
    local partNum = 0
    local tbKill = {}
    local TaskSubActor = UE4.ATaskSubActor.GetTaskSubActor(GetGameIns())
    local tbMonster = RikiLogic:GetMonsterData(TaskSubActor)
    if TaskSubActor then
        partNum = TaskSubActor:GetDestructAccessoryNum()

        if TaskSubActor.GetAchievementData then
            local tbKillMonster = TaskSubActor:GetAchievementData()
            local tbKey = tbKillMonster:Keys()
            for i = 1, tbKey:Length() do
                local sName = tbKey:Get(i)
                tbKill[sName] = tbKillMonster:Find(tbKey:Get(i))
            end
        end
    end

    local tbEntrie = {}
    for id, v in pairs(BossLogic.tbSelectEntrie) do
        if v then
            table.insert(tbEntrie, id)
        end
    end

    local tbLog = {}
    tbLog['FightHistory'] = LaunchLog.LogFightHistory(5)
    tbLog['LevelPerformance'] = LaunchLog.LogPerformance()
    tbLog['FightRecont'] = LaunchLog.LogFightRecont()

    local cmd = {
        nID = BossLogic.GetBossLevelID(),
        nSeed = BossLogic.nSeed,
        Data = data,
        PartNum = partNum,
        nDiff = BossLogic.GetNowDifficulty(),
        tbLog = BossLogic.Log(),
        tbLog2 = tbLog,
        tbKill = tbKill,
        tbMonster = tbMonster,
        tbEntrie = tbEntrie
    }
    cmd.tbLog[5] = 1    --完成类型：关卡胜利
    UI.ShowConnection()
    me:CallGS("BossLogic_LevelSettlement", json.encode(cmd))
end
---注册结算回调
s2c.Register("BossLogic_LevelSettlement", function(tbParam)
    UI.CloseConnection()
    if tbParam and tbParam.isRecord then
        UI.ShowTip(Text("bossentries.record"))
    end
end)

---获取进入日志
function BossLogic.EnterLog()
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

    local tbteam = Formation.GetCurrentLineup()
    local tbCards = tbteam and tbteam:GetCards() or nil
    local CardNum = tbCards and tbCards:Length() or 0
    local Card1 = CardNum >= 1 and tbCards:Get(1) or nil
    local Character1, Weapon1, Support1 = LaunchLog.LogCardSimple(Card1)
    local Card2 = CardNum >= 2 and tbCards:Get(2) or nil
    local Character2, Weapon2, Support2 = LaunchLog.LogCardSimple(Card2)
    local Card3 = CardNum >= 3 and tbCards:Get(3) or nil
    local Character3, Weapon3, Support3 = LaunchLog.LogCardSimple(Card3)


    local tbLog = {
    --[[['LevelType'] =]] 5,
    --[[['期数-levelId-难度ID'] = ]] string.format('%d-%d-%d', BossChallengeId, levelId, BossLogic.GetNowDifficulty()),
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

---获取结算日志
function BossLogic.Log()
    local BossChallengeId = 0   --挑战期数id
    local cfg = BossLogic.GetTimeCfg()
    if cfg then
        BossChallengeId = cfg.nID
    end

    local bossID = 0    --bossID
    local levelId = 0    --levelId
    local levelcfg = BossLogic.GetBossLevelCfg(BossLogic.GetBossLevelID())
    if levelcfg then
        bossID = levelcfg.nBossID
        levelId = levelcfg.nLevelID
    end

    local EntriesId = "0"   --词条1ID-词条2ID...
    local tbentries = {}
    for id in pairs(BossLogic.tbSelectEntrie) do
        table.insert(tbentries, id)
    end
    if #tbentries > 0 then
        EntriesId = table.concat(tbentries, "-")
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

    local FightNodeTime = ""
    local GameTaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
    local StarTaskSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelStarTaskManager)
    if GameTaskActor then 
        FightNodeTime = GameTaskActor:GetFightLog_ExecuteFightTime()
    end

    local tbLog = {
        --[[['挑战期数id'] =]] bossID,
        --[[['期数-levelId-难度ID'] = ]] string.format('%d-%d-%d', BossChallengeId, levelId, BossLogic.GetNowDifficulty()),
        --[[['词条1ID-词条2ID...'] =]] EntriesId,
        --[[['挑战成功次数-挑战总次数'] = ]] "0-0",
        --[[['关卡完成情况'] = ]] 0,
        --[[['本次新获分数，未完成记0'] = ]] 0,
        --[[['最终分数，即本次完成后最高分'] = ]] 0,
        --[[['关卡用时（秒）'] = ]] math.ceil(BossLogic.FinishTime or 0),

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
        --[[['关卡中BOSS致死技能数据'] =]] LaunchLog.LogPlayerDeadInfo(),
        --[[['AI状态持续时间（秒）'] = ]] LaunchLog.GetBossStateDamage(),
        --[[['战斗状态时间（实际战斗时间）'] = ]] FightNodeTime
    }
    return tbLog
end

---关卡失败
function BossLogic.Req_LevelFail(nReason)
    local tbLog = {}
    tbLog['FightHistory'] = LaunchLog.LogFightHistory(5)
    tbLog['LevelPerformance'] = LaunchLog.LogPerformance()
    tbLog['FightRecont'] = LaunchLog.LogFightRecont()

    local cmd = {
        nID = BossLogic.GetBossLevelID(),
        tbLog = BossLogic.Log(),
        tbLog2 = tbLog,
    }
    --完成类型
    if nReason == UE4.ELevelFailedReason.Dead then
        cmd.tbLog[5] = 3
    elseif nReason == UE4.ELevelFailedReason.OverTime then
        cmd.tbLog[5] = 4
    elseif nReason == UE4.ELevelFailedReason.ManualExit then
        cmd.tbLog[5] = 2
    elseif nReason == UE4.ELevelFailedReason.OffLine then
        cmd.tbLog[5] = 5
    end
    UI.ShowConnection()
    me:CallGS("BossLogic_LevelFail", json.encode(cmd))
end
s2c.Register("BossLogic_LevelFail", function()
    UI.CloseConnection()
end)

BossLogic.LoadCfg()
