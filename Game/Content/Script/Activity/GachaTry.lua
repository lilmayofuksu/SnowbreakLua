-- ========================================================
-- @File    : GachaTry.lua
-- @Brief   : 扭蛋角色试玩逻辑
-- ========================================================

GachaTry = GachaTry or {}

GachaTry.RewardGet_Task = 1  -- 按位记录领奖情况

-- 当前活动id 试用角色idx 关卡id
GachaTry.tbCache = {nActId = nil, nGirlIdx = nil, nLevelID = nil}
GachaTry.tbSpine = {}

function GachaTry.Init()
    GachaTry.LoadConfig()
    GachaTry.LoadTryGirlConf()
    GachaTry.LoadLevelConf()
    GachaTry.LoadSkillIntro()
end

function GachaTry.LoadConfig()
    GachaTry.tbTryConf = {}
    local tbFile = LoadCsv('activity/gacha_try/gacha_try.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local nActId = tonumber(tbLine.ActId) or 0
        if nActId > 0 then
            local tb = {}
            tb.nActId = nActId
            tb.tbTryGirl = Eval(tbLine.TryGirl)
            tb.sDesc = tbLine.Desc
            tb.sUI = tbLine.UI
            GachaTry.tbTryConf[nActId] = tb
        end
    end
end

function GachaTry.LoadTryGirlConf()
    GachaTry.tbTryGirlConf = {}
    local tbFile = LoadCsv('activity/gacha_try/try_girl.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID) or 0
        if nId > 0 then
            local tb = {}
            tb.tbGDPL = Eval(tbLine.Girl)
            tb.tbReward = Eval(tbLine.Reward)
            tb.nTrialId = tonumber(tbLine.TrialId) or 0
            tb.nLevelId = tonumber(tbLine.LevelId) or 0
            tb.sSpine = tbLine.Spine
            tb.tbSpineAnimInfo = Eval(tbLine.SpineAnimInfo) or {}
            tb.nPose = tonumber(tbLine.Pose) or 0
            tb.nBg = tonumber(tbLine.Bg) or 1602059
            tb.sBgColor = tbLine.BgColor
            tb.tbPoseOffset = Eval(tbLine.PoseOffset) or {}
            tb.sTitleColor = tbLine.TitleColor
            tb.nTitleBg = tonumber(tbLine.TitleBg) or 0
            tb.sTitleBgColor = tbLine.TitleBgColor
            tb.sPv = tbLine.Pv
            tb.nGachaId = tonumber(tbLine.GachaId)
            GachaTry.tbTryGirlConf[nId] = tb
        end
    end
end

function GachaTry.LoadLevelConf()
    GachaTry.tbLevelConf = {}
    local tbFile = LoadCsv('activity/gacha_try/level.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID) or 0
        local nMapId = tonumber(tbLine.MapID) or 0
        if nId > 0 and nMapId > 0 then
            local tb = {}
            tb.nID = nId
            tb.sName = tbLine.Name
            tb.sDes = tbLine.Desc
            tb.nMapID = nMapId
            tb.tbBuffID = Eval(tbLine.BuffID) or {}
            tb.nTeamRuleID = tonumber(tbLine.TeamRuleID) or 0
            tb.sTaskPath = tbLine.TaskPath
            tb.GetOption = function(self)
                local sOption = ''
                if self.sTaskPath and self.sTaskPath ~= '' then
                    sOption = string.format('TaskPath=/Game/Blueprints/LevelTask/Tasks/%s', self.sTaskPath)
                end
                return sOption
            end
            GachaTry.tbLevelConf[nId] = tb
        end
    end
end

function GachaTry.LoadSkillIntro()
    GachaTry.tbSkillIntro = {}
    local tbFile = LoadCsv('activity/gacha_try/SkillIntro.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID) or 0
        local nSkillId = tonumber(tbLine.Skillid) or 0
        if nId > 0 and nSkillId > 0 then
            local tb = {}
            tb.nID = nId
            tb.nSkillId = nSkillId
            GachaTry.tbSkillIntro[nId] = tb
        end
    end
end

function GachaTry.GetSpine(path)
    if GachaTry.tbSpine[path] and IsValid(GachaTry.tbSpine[path]) then
        return GachaTry.tbSpine[path]
    end
    local spine = UE4.UGameAssetManager.GameLoadAssetFormPath(path)
    if spine then GachaTry.tbSpine[path] = spine end
    return spine
end

function GachaTry.GetSkillIntroConf(nId)
    return GachaTry.tbSkillIntro[nId]
end

function GachaTry.GetConfig(nActId)
    return GachaTry.tbTryConf[nActId]
end

function GachaTry.GetTryGirlConf(nGrilId)
    return GachaTry.tbTryGirlConf[nGrilId]
end

function GachaTry.GetLevelConf(nLevelId)
    return GachaTry.tbLevelConf[nLevelId]
end

function GachaTry.GetActId()
    return GachaTry.tbCache.nActId
end

function GachaTry.GetGirlIdx()
    return GachaTry.tbCache.nGirlIdx
end

function GachaTry.GetLevelID()
    local conf = GachaTry.tbTryConf[GachaTry.tbCache.nActId]
    if not conf then return 0 end
    local tbTry = GachaTry.GetTryGirlConf(conf.tbTryGirl[GachaTry.tbCache.nGirlIdx])
    if not tbTry then return 0 end
    return tbTry.nLevelId
end

function GachaTry.CacheId(nActId, girlIdx)
    GachaTry.tbCache.nActId = nActId
    GachaTry.tbCache.nGirlIdx = girlIdx
end

function GachaTry.IsLevelPassed(nActId, nGirlIdx)
    local val = Activity.GetDiyData(nActId, GachaTry.RewardGet_Task)
    return GetBits(val, nGirlIdx, nGirlIdx) == 1
end

function GachaTry.HasNew(nActId)
    local tbConf = GachaTry.tbTryConf[nActId]
    if not tbConf then return false end
    for idx, tryGirlId in ipairs(tbConf.tbTryGirl) do
        if GachaTry.tbTryGirlConf[tryGirlId] and not GachaTry.IsLevelPassed(nActId, idx) then
            return true
        end
    end
    return false
end

---请求进入关卡
function GachaTry.Req_EnterLevel(nActId, nGirlIdx, nLevelID)
    if not Activity.IsOpen(nActId) then return UI.ShowTip(Text('ui.TxtSignOver')) end
    if GachaTry.bReqEnter then return end
    GachaTry.bReqEnter = true

    local tbLog = {}
    tbLog['LevelEnter'] = LaunchLog.LogLevelEnter(LaunchType.GACHATRY, string.format('%d-%d', nActId, nLevelID))

    local cmd = {nActId = nActId, nGirlIdx = nGirlIdx, nLevelID = nLevelID, tbLog = tbLog}
    me:CallGS('GachaTry_EnterLevel', json.encode(cmd))
end

---注册进入关卡的回调
s2c.Register('GachaTry_EnterLevel', function(tbRet)
    GachaTry.bReqEnter = false
    GachaTry.nSeed = tbRet.nSeed
    Launch.Response('GachaTry_EnterLevel')
end)

---请求结算关卡
function GachaTry.Req_LevelSettlement(nActId, nGirlIdx, nLevelID)
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
    tbLog['LevelFinish'] = LaunchLog.LogLevel(LaunchType.GACHATRY, nil, string.format('%d-%d', nActId, nLevelID))
    tbLog['FightRecont'] = LaunchLog.LogFightRecont()

    local cmd = {
        nActId = nActId,
        nGirlIdx = nGirlIdx,
        nLevelID = nLevelID,
        nTime = Launch.GetLatelyTime(),
        nSeed = GachaTry.nSeed,
        tbKill = tbKill,
        tbMonster = tbMonster,
        tbLog = tbLog,
    }
    UI.ShowConnection()
    Reconnect.Send_SettleInfo('GachaTry_LevelSettlement', cmd)
end

---注册结算回调
s2c.Register('GachaTry_LevelSettlement', function(tbAward)
    UI.CloseConnection()
    Launch.Response('GachaTry_LevelSettlement', tbAward)
end)


function GachaTry.Req_LevelFail(nActId, nGirlIdx, nLevelID)
    local tbLog = {}
    tbLog['LevelFinish'] = LaunchLog.LogLevel(LaunchType.GACHATRY, nil, string.format('%d-%d', nActId, nLevelID))
    tbLog['FightRecont'] = LaunchLog.LogFightRecont()
    local cmd = {
        nActId = nActId,
        nGirlIdx = nGirlIdx,
        nLevelID = nLevelID,
        tbLog = tbLog,
    }
    me:CallGS('GachaTry_LevelFail', json.encode(cmd))
end

GachaTry.Init()

return GachaTry