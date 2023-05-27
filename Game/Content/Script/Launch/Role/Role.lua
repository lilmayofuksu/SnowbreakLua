-- ========================================================
-- @File    : Role.lua
-- @Brief   : 角色碎片本
-- ========================================================

Role = Role or {}
Role.GroupID        = 9     --碎片本活动GID 存每章节的最近挑战时间
Role.LevelIDStart   = 10000 --1000开始存关卡的挑战次数
Role.LimitNum       = 0     --碎片本活动记忆嵌片每日数量

Role.MoneyID = 7    --记忆嵌片ID

local var = {nSeed = 0 , nDifficult = 0, tbNowChapterCfg = nil, nLevelID = nil}

---设置当前选择的章节配置
function Role.SetNowChapterCfg(cfg)
    var.tbNowChapterCfg = cfg
end

---获取当前选择的章节配置
function Role.GetNowChapterCfg()
    return var.tbNowChapterCfg
end

---设置选择的关卡ID
---@param nID number 每日关卡ID
function Role.SetLevelID(nID)
    var.nLevelID = nID
end

---获取选择的关卡ID
function Role.GetLevelID()
    return var.nLevelID or 0
end

---获取下一关ID
function Role.GetNextLevelID()
    local tbCfg = RoleLevel.Get(var.nLevelID)
    if not tbCfg then return var.nLevelID end
    if tbCfg.nNextID == 0 then return var.nLevelID end
    return tbCfg.nNextID
end

---得到当前挑战关的所有buffID
function Role.GetLevelBuffID()
    local tbCfg = RoleLevel.Get(Role.GetLevelID())
    if tbCfg and tbCfg.tbBuffID then
        return tbCfg.tbBuffID
    end
    return {}
end

---获取所有章节信息，默认难度1
function Role.GetAllChapterCfg(nDifficult)
    local nDif = nDifficult or 1
    return Role.tbChapterCfg[nDif] or {}
end

---获取开放的所有章节信息，默认难度1
function Role.GetAllOpenChapterCfg(nDifficult)
    local nDif = nDifficult or 1
    local allOpenCfg = {}
    for _, Cfg in pairs(Role.tbChapterCfg[nDif] or {}) do
        if IsInTime(Cfg.nBegin, Cfg.nEnd) then
            table.insert(allOpenCfg, Cfg)
        end
    end
    return allOpenCfg
end

function Role.IsOPen(nDifficult)
    local nDif = nDifficult or 1
    for _, Cfg in pairs(Role.tbChapterCfg[nDif] or {}) do
        if IsInTime(Cfg.nBegin, Cfg.nEnd) then
            return true
        end
    end
    return false
end

---获取某一章的章节信息
function Role.GetChapterCfg(nId, nDifficult)
    if not nId then return nil end
    local allChapterCfg = Role.GetAllChapterCfg(nDifficult)
    return allChapterCfg[nId]
end

---获取某一章的挑战进度 返回关卡id
function Role.GetChapterProgres(nId, nDifficult)
    local cfg = nil
    if nId then
        cfg = Role.GetChapterCfg(nId, nDifficult)
    else
        cfg = Role.GetNowChapterCfg()
    end
    if not cfg then return 0 end
    for _, id in pairs(cfg.tbLevel) do
        local level = RoleLevel.Get(id)
        if level and not level:IsPass() then
            return id
        end
    end
    return cfg.tbLevel[#cfg.tbLevel]
end

---是否是剧情关卡
---@param nLevelID Integer 关卡ID
function Role.IsPlot(nLevelID)
    nLevelID = nLevelID or var.nLevelID
    return RoleLevel.IsPlot(nLevelID)
end

---返回章节挑战次数和总次数
function Role.GetNum(cfg)
    local num = 0
    local passnum = 0
    if cfg and cfg.tbLevel then
        for _, levelid in pairs(cfg.tbLevel) do
            local levelcfg = RoleLevel.Get(levelid)
            if levelcfg and levelcfg.nNum >= 0 then
                num = num + levelcfg.nNum
                passnum = passnum + Role.GetLevelPassNum(levelcfg.nID)
            end
        end
        if passnum > num then
            passnum = num
        end
        return passnum, num
    end
    return 0, 0
end

--获取关卡今日通关次数
function Role.GetLevelPassNum(ID)
    return me:GetAttribute(Role.GroupID, Role.LevelIDStart + ID)
end

---返回记忆嵌片数量和每日总数量
function Role.GetActivityNum()
    return Cash.GetMoneyCount(Role.MoneyID), Role.LimitNum
end

---能否开始挑战
function Role.CanFight()
    local cfg = RoleLevel.Get(Role.GetLevelID())
    if not cfg then return end
    local num = Cash.GetMoneyCount(Role.MoneyID)
    local nMultiple = Launch.GetMultiple()
    if num < cfg.nConsume * nMultiple then
        return false, Text("role.limit_1")
    end
    if cfg.nNum >= 0 and Role.GetLevelPassNum(cfg.nID) + nMultiple > cfg.nNum then
        return false, Text("role.limit_2")
    end
    return true
end

---返回突破需要的道具信息
function Role.GetBreakInfo(tbGDPL)
    if not tbGDPL or #tbGDPL < 4 then
        return nil
    end
    local Cards = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(Cards)
    for i = 1, Cards:Length() do
        local card = Cards:Get(i)
        if card:Genre() == tbGDPL[1] and card:Detail() == tbGDPL[2] and card:Particular() == tbGDPL[3] and card:Level() == tbGDPL[4] then
            return Item.GetBreakMaterials(card)
        end
    end
end

---获取关卡星级目标配置
---@param nLevelID number 关卡ID
function Role.GetLevelStarCfg(nLevelID)
    local id = nLevelID or Role.GetLevelID()
    local tbLevel = RoleLevel.Get(id)
    if not tbLevel then return '' end
    return tbLevel.sStarCondition
end

--- 得到角色名字
function Role.GetRoleName(roleId)
    local key = "role.role_chapter_" .. roleId;
    return Text(key);
end

----------------------配置--------------------------
function Role.LoadChapter()
    Role.tbChapterCfg = {}
    local tbFile = LoadCsv("challenge/role/chapter_role.txt", 1);
    for _, tbLine in ipairs(tbFile) do
        local nID           = tonumber(tbLine.ID)
        local nDifficult    = tonumber(tbLine.Difficult)
        if nID and nDifficult then
            local tbInfo        = {
                nID         = nID,
                nDifficult  = nDifficult,
                tbCharacter = Eval(tbLine.Character) or {},
                tbCondition = Eval(tbLine.Condition) or {},
                tbLevel     = Eval(tbLine.Level) or {},
                tbStarAward = Eval(tbLine.StarAward) or {},
                nType       = tonumber(tbLine.Type) or 0,
                nActivity   = tonumber(tbLine.nActivity or 0),
                GetSubID    = function(self) return self.nID << 8 | self.nDifficult end,
                DidGotStarAward = function(self, nIndex)
                    local nMask = me:GetAttribute(Chapter.GID_MASK, self:GetSubID());
                    return GetBits(nMask, nIndex, nIndex) == 1
                end
            };

            tbInfo.nBegin      = ParseTime(string.sub(tbLine.Begin or '', 2, -2), tbInfo, "nBegin")
            tbInfo.nEnd        = ParseTime(string.sub(tbLine.End or '', 2, -2), tbInfo, "nEnd")

            Role.tbChapterCfg[nDifficult] = Role.tbChapterCfg[nDifficult] or {};
            Role.tbChapterCfg[nDifficult][nID] = tbInfo;
        elseif tonumber(tbLine.Num) then
            Role.LimitNum = tonumber(tbLine.Num)
        end
    end

    print("load challenge/role/chapter_role.txt")
end

Role.LoadChapter()


--- 得到掉落途径
function Role.GetDropWay(g, d, p, l, count)
    for diff, tb in pairs(Role.tbChapterCfg) do 
        for roleId, data in pairs(tb) do 
            for _, levelId in ipairs(data.tbLevel) do 
                local levelData = RoleLevel.Get(levelId)
                if levelData then 
                    for _, gdpln in ipairs(levelData.tbShowFirstAward) do 
                        if gdpln[1] == g and gdpln[2] == d and gdpln[3] == p and gdpln[4] == l then 
                            local isUnlock = true;-- Condition.Check(data.tbCondition)
                            return {{tbArgs = {diff, roleId, levelId, data}, isUnlock = isUnlock}}
                        end
                    end
                end
            end
        end
    end
end

---------------------数据请求----------------------------
--------------------------------------------------------

---数据请求类型
---进入关卡
Role.REQ_ENTER_LEVEL         = 'Role_EnterLevel'
---结算关卡
Role.REQ_LEVEL_SETTLEMENT    = 'Role_LevelSettlement'
---关卡失败
Role.REQ_LEVEL_FAIL          = 'Role_LevelFail'
---像服务器请求开放时间
Role.GET_OPEN_TIME           = 'Role_GetOPenTime'
---扫荡
Role.REQ_LEVEL_MOPUP           = 'Role_LevelMoppingUp'

---请求进入关卡
function Role.Req_EnterLevel(nLevelID)
    local cfg = RoleLevel.Get(nLevelID)
    if not cfg then return end
    ---体力检查
    if cfg.tbConsumeVigor and #cfg.tbConsumeVigor > 1 and (not Cash.CheckMoney(Cash.MoneyType_Vigour, cfg.tbConsumeVigor[1] + cfg.tbConsumeVigor[2])) then
       return
    end

    --剧情关卡 不能多倍
    if RoleLevel.IsPlot(nLevelID) then Launch.SetMultiple(1) end

    local tbLog = LaunchLog.LogLevelEnter(7)
    tbLog[2] = nLevelID

    -- 是否开启
    local cmd = {
        nID = nLevelID,
        nTeamID = Formation.GetCurLineupIndex(),
        tbLog = tbLog,
        nMultiple = Launch.GetMultiple(),
    }
    me:CallGS(Role.REQ_ENTER_LEVEL, json.encode(cmd))
end

---注册进入关卡的回调
s2c.Register(Role.REQ_ENTER_LEVEL, function(tbRet)
    var.nSeed = tbRet.nSeed
    Launch.Response(Role.REQ_ENTER_LEVEL)
end
)

---请求结算关卡
function Role.Req_LevelSettlement(nLevelID)
    local nStar = 0
    local pSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelStarTaskManager)
    if pSubSys then
        nStar = pSubSys:GetStarTaskResultCache()
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

    local RoleID = nil
    local cfg = Role.GetNowChapterCfg()
    if cfg then
        RoleID = cfg.nID
    end

    local cmd = {
        nID = nLevelID,
        nSeed = var.nSeed,
        nTime = Launch.GetLatelyTime(),
        nStar = nStar,
        tbKill = tbKill,
        nRoleID = RoleID,
        tbLog = Role.Log(nLevelID),
        tbMonster = tbMonster
    }
    UI.ShowConnection()
    Reconnect.Send_SettleInfo(Role.REQ_LEVEL_SETTLEMENT, cmd)
end

---注册结算回调
s2c.Register(Role.REQ_LEVEL_SETTLEMENT, function(tbAward)
    UI.CloseConnection()
    Launch.Response(Role.REQ_LEVEL_SETTLEMENT, tbAward)
end)

---关卡失败
function Role.Req_LevelFail(nLevelID, IsPlot)
    local tbLog = {}
    if IsPlot then
        tbLog['StoryFinish'] = LaunchLog.LogStoryFinish()
    else
        local tb = LaunchLog.LogLevel(7)
        tb[2] = nLevelID
        tbLog['LevelFinish'] = tb
        tbLog['FightRecont'] = LaunchLog.LogFightRecont()
        tbLog['FightHistory'] = LaunchLog.LogFightHistory(7)
        tbLog['LevelPerformance'] = LaunchLog.LogPerformance()
    end

    local cmd = {
        nID = nLevelID,
        tbLog = tbLog
    }
    me:CallGS(Role.REQ_LEVEL_FAIL, json.encode(cmd))
end
s2c.Register(Role.REQ_LEVEL_FAIL, function()
    UI.CloseConnection()
end)

---像服务器请求开放时间
function Role.GetOPenTime()
    --UI.ShowConnection()
    --me:CallGS(Role.GET_OPEN_TIME)
    if Role.IsOPen() then
        Launch.SetType(LaunchType.ROLE)
        local ui = UI.GetUI("Chapter")
        if ui then UI.Close(ui, nil, true) end
        UI.Open("DungeonsRole")
    else
        UI.ShowTip(Text("ui.TxtNotOpen"))
    end
end

---注册请求时间的回调
s2c.Register(Role.GET_OPEN_TIME, function(tbparam)
    UI.CloseConnection()
    if tbparam then
        for dif, tbcfg in pairs(tbparam) do
            for id, cfg in pairs(tbcfg) do
                if Role.tbChapterCfg[dif] and Role.tbChapterCfg[dif][id] then
                    Role.tbChapterCfg[dif][id].nBegin = cfg.nBegin
                    Role.tbChapterCfg[dif][id].nEnd = cfg.nEnd
                end
            end
        end
    end
    if Role.IsOPen() then
        Launch.SetType(LaunchType.ROLE)
        local ui = UI.GetUI("Chapter")
        if ui then UI.Close(ui, nil, true) end
        UI.Open("DungeonsRole")
    else
        UI.ShowTip(Text("ui.TxtNotOpen"))
    end
end)

---收集日志
function Role.Log(nLevelID)
    if Role.IsPlot(nLevelID) then
        return LaunchLog.LogStoryFinish(2)
    else
        local tbLog = {}
        local tb = LaunchLog.LogLevel(7)
        tb[2] = nLevelID
        tbLog['LevelFinish'] = tb
        tbLog['FightRecont'] = LaunchLog.LogFightRecont()
        tbLog['FightHistory'] = LaunchLog.LogFightHistory(7)
        tbLog['LevelPerformance'] = LaunchLog.LogPerformance()
        return tbLog
    end
end

---请求扫荡
function Role.Req_LevelMopup(nLevelID, nNum)
    local RoleID = nil
    local cfg = Role.GetNowChapterCfg()
    if cfg then
        RoleID = cfg.nID
    end

    local cmd = {
        nID = nLevelID,
        nRoleID = RoleID,
        nMultiple = nNum,
    }
    me:CallGS(Role.REQ_LEVEL_MOPUP, json.encode(cmd))
end

---注册结算回调
s2c.Register(Role.REQ_LEVEL_MOPUP, function(tbParam)
    local sUI = UI.GetUI("DungeonsRoleMap")
    if not sUI:IsOpen() then
        return
    end

    sUI:UpdateLevelList()

    UI.Open("MopupResult", tbParam)
end)