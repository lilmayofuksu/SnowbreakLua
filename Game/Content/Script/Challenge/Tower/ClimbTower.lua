-- ========================================================
-- @File    : Challenge/Tower/ClimbTower.lua
-- @Brief   : 爬塔逻辑
-- ========================================================

ClimbTowerLogic = ClimbTowerLogic or {}

ClimbTowerLogic.GID             = 3     --爬塔活动GID

ClimbTowerLogic.TimeSubID       = 1     --存当前的周期ID
ClimbTowerLogic.LevelSubID      = 2     --存1-8层未挑战完成的关卡信息（0-23关卡id 24-31区域）
ClimbTowerLogic.LevelSubID2     = 3     --存9-12层未挑战完成的关卡信息（0-23关卡id 24-31区域）
ClimbTowerLogic.DiffSubID       = 4     --存9-12层挑战难度

--[[
    1-8层未挑战完成的角色信息
        10:角色1ID
        11:角色1血量
        12:队伍的大招能量
        20:角色2ID
        21:角色2血量
        30:角色3ID
        31:角色3血量
    9-12层未挑战完成的角色信息
        40:角色1ID
        41:角色1血量
        42:队伍的大招能量
        50:角色2ID
        51:角色2血量
        60:角色3ID
        61:角色3血量
]]--

ClimbTowerLogic.SubIDStart      = 100   --100开始保存每层的信息（0-3首通奖励 4-7要求一奖励 8-11要求二奖励 12-15要求三奖励）
ClimbTowerLogic.LevelSubIDStart = 10000 --10000开始保存每关的信息（0-2区域一星级 3-5区域二星级 6-8区域三星级 12-15是否挑战过）

--- 当前进行的爬塔周期配置ID
ClimbTowerLogic.NowTimeId       = nil
--- 当前进行的爬塔关卡配置ID
ClimbTowerLogic.NowTowerId      = nil
--- 当前进行的爬塔关卡配置ID
ClimbTowerLogic.NowAreaId       = nil
--- 当前挑战需要生效的buffID
ClimbTowerLogic.tbNowBuffID     = nil

---获取当前的周期配置
function ClimbTowerLogic.GetTimeCfg()
    ClimbTowerLogic.NowTimeId = ClimbTowerLogic.NowTimeId or me:GetAttribute(ClimbTowerLogic.GID, ClimbTowerLogic.TimeSubID)
    return ClimbTowerLogic.tbTimeConf[ClimbTowerLogic.NowTimeId]
end
---获取当前周期结束时间
function ClimbTowerLogic.GetEndTime()
    local time = GetTime()
    for _, cfg in pairs(ClimbTowerLogic.tbTimeConf) do
        if IsInTime(cfg.nStartTime, cfg.nEndTime, time) then
            return cfg.nEndTime
        end
    end
    return 0
end
---获取难度对应的怪物等级
function ClimbTowerLogic.GetMonsterGrade()
    if ClimbTowerLogic.IsBasic() then
        return 0
    end
    local levelcfg = ClimbTowerLogic.GetLevelCfg()
    if levelcfg then
        local diff = ClimbTowerLogic.GetLevelDiff()
        if diff ~= 0 and levelcfg.tbMonsterLevel[diff] then
            return tonumber(levelcfg.tbMonsterLevel[diff]) or 0
        end
    end
    return 0
end
---保存当前进行的爬塔关卡ID
function ClimbTowerLogic.SetLevelID(nID)
    ClimbTowerLogic.NowTowerId = nID
end
---获取当前进行的爬塔关卡ID
function ClimbTowerLogic.GetLevelID()
    return ClimbTowerLogic.NowTowerId or 0
end
---根据爬塔关卡ID获取层 默认获取当前挑战层
function ClimbTowerLogic.GetNowLayer(TowerLevelID)
    local levelid = TowerLevelID or ClimbTowerLogic.GetLevelID()
    local timecfg = ClimbTowerLogic.GetTimeCfg()
    if not timecfg then return 0 end
    for i, v in pairs(timecfg.tbLevel1) do
        for _, id in pairs(v) do
            if levelid == id then
                return i
            end
        end
    end
    for i, v in pairs(timecfg.tbLevel2) do
        for _, id in pairs(v) do
            if levelid == id then
                return i
            end
        end
    end
    return 0
end
---根据爬塔关卡ID获取真实的层 默认获取当前挑战层
function ClimbTowerLogic.GetNowRealLayer(TowerLevelID)
    local levelid = TowerLevelID or ClimbTowerLogic.GetLevelID()
    local timecfg = ClimbTowerLogic.GetTimeCfg()
    if not timecfg then return 0 end
    for i, v in pairs(timecfg.tbLevel1) do
        for k, id in pairs(v) do
            if levelid == id then
                return i, k
            end
        end
    end
    for i, v in pairs(timecfg.tbLevel2) do
        for k, id in pairs(v) do
            if levelid == id then
                return #timecfg.tbLevel1 + i, k
            end
        end
    end
    return 0
end
---保存当前进行的爬塔关区域
function ClimbTowerLogic.SetLevelArea(nArea)
    ClimbTowerLogic.NowAreaId = nArea
end
---获取当前进行的爬塔关区域（爬塔逻辑调用）
function ClimbTowerLogic.GetLevelArea()
    if not ClimbTowerLogic.NowAreaId then
        ClimbTowerLogic.NowAreaId = 1
    end
    return ClimbTowerLogic.NowAreaId
end
---获取当前进行的爬塔关区域(外部动态关卡调用)
function ClimbTowerLogic.GetArea()
    local AreaId = ClimbTowerLogic.GetLevelArea()
    if AreaId == 1 then
        -- local v = me:GetAttribute(ClimbTowerLogic.GID, ClimbTowerLogic.LevelSubIDStart + ClimbTowerLogic.GetLevelID())
        -- if GetBits(v, 12, 15) <= 0 then
        --     return 0    ---以前没挑战过，出生在初始出生点
        -- end
        return 0
    end
    return AreaId       ---以前挑战过，出生在1~3号房间
end

---返回储存的未挑战完成的爬塔关id和区域id
function ClimbTowerLogic.GetLevelAndArea(nType)
    local v = 0
    if nType == 1 then
        v = me:GetAttribute(ClimbTowerLogic.GID, ClimbTowerLogic.LevelSubID)
    elseif nType == 2 then
        v = me:GetAttribute(ClimbTowerLogic.GID, ClimbTowerLogic.LevelSubID2)
    end
    if v == 0 then
        return nil
    end
    return GetBits(v, 0, 23), GetBits(v, 24, 31)
end

---获取当前进行的爬塔关区域星级条件
function ClimbTowerLogic.GetStarCondition(nArea)
    local LevelCfg = ClimbTowerLogic.GetLevelCfg()
    if not LevelCfg then return nil end
    local Area = nArea
    if Area < 0 then
        Area = ClimbTowerLogic.GetLevelArea()
    end
    return LevelCfg.StarConditionStr[Area]
end

---获取当前进行的爬塔关区域星级历史达成
function ClimbTowerLogic.GetAreaStar(nArea)
    local value = me:GetAttribute(ClimbTowerLogic.GID, ClimbTowerLogic.LevelSubIDStart + ClimbTowerLogic.GetLevelID())
    local Area = nArea or ClimbTowerLogic.GetLevelArea()
    local v = 0
    for i = 0, 2 do
        local index = (Area - 1) * 3 + i
        if GetBits(value, index, index) == 1 then
            v = SetBits(v, 1, i, i)
        end
    end
    return v
end

---添加血量以及队伍能力恢复事件
function ClimbTowerLogic.AddRefreshHPEvent(nType)
    if ClimbTowerLogic.CharacterSpawnHandle then
        ClimbTowerLogic.RemoveRefreshHPEvent()
    end
    ClimbTowerLogic.CharacterSpawnHandle = EventSystem.On(Event.CharacterSpawned, function(SpawnCharacter)
        if IsValid(SpawnCharacter) and IsPlayer(SpawnCharacter) then
            local index = 1
            if nType == 2 then
                index = 4
            end
            for i = index, index+2 do
                local tempID = me:GetAttribute(ClimbTowerLogic.GID, i*10)
                if tempID > 0 and tempID == SpawnCharacter:GetTemplateID() then
                    local hp = me:GetAttribute(ClimbTowerLogic.GID, i*10+1)
                    SpawnCharacter.Ability:SetPropertieValueFromString("Health", hp)
                    if hp <= 0 then
                        local Controller = SpawnCharacter:GetCharacterController()
                        if Controller then
                            Controller:SwitchNextPlayerCharacter(true)
                        end
                    end
                end
            end
            local Controller = SpawnCharacter:GetCharacterController()
            if Controller then
                local TeamComponent = Controller:GetTeamComponent()
                local CurEnergy = me:GetAttribute(ClimbTowerLogic.GID, index*10+2)
                if TeamComponent and CurEnergy then
                   TeamComponent:SetPropertieValueFromString("CharacterEnergy", CurEnergy)
                end
            end
        end
    end)
end

---删除血量恢复事件
function ClimbTowerLogic.RemoveRefreshHPEvent()
    if ClimbTowerLogic.CharacterSpawnHandle then
        EventSystem.Remove(ClimbTowerLogic.CharacterSpawnHandle)
        ClimbTowerLogic.CharacterSpawnHandle = nil
    end
end

---加载配置
function ClimbTowerLogic.LoadConf()
    ClimbTowerLogic.LoadAwardConf()
    ClimbTowerLogic.LoadLevelorderConf()
    ClimbTowerLogic.LoadTimeConf()
    ClimbTowerLogic.LoadDiffConf()
end
--- 加载奖励配置
function ClimbTowerLogic.LoadAwardConf()
    ClimbTowerLogic.tbAwardConf = {}
    local tbFile = LoadCsv('challenge/climbtower/climb_tower_award.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        local nDiff = tonumber(tbLine.Diff) or 1;
        if nID then
            local tbCount = {}
            local tbAward = {}
            for i = 1, 3 do
                tbCount[i] = tonumber(tbLine["StarCount"..i] or 1)
                tbAward[i] = Eval(tbLine["StarAward"..i]) or {}
            end
            local tbInfo = {
                nID             = nID,
                FirstAward      = Eval(tbLine.FirstAward) or {},
                tbStarCount     = tbCount,
                tbStarAward     = tbAward
            };
            ClimbTowerLogic.tbAwardConf[nID] = ClimbTowerLogic.tbAwardConf[nID] or {}
            ClimbTowerLogic.tbAwardConf[nID][nDiff] = tbInfo
        end
    end
    print('challenge/climbtower/climb_tower_award.txt')
end
--- 加载关卡排列配置
function ClimbTowerLogic.LoadLevelorderConf()
    ClimbTowerLogic.tbLevelorderConf = {}
    local tbFile = LoadCsv('challenge/climbtower/climb_tower_levelorder.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID             = nID,
                tbLevelBuff     = Eval(tbLine.LevelBuff) or {},
                sBuffDesc       = tbLine.BuffDesc,
                nLevelID        = tonumber(tbLine.LevelID),
                tbMonsterLevel  = Eval(tbLine.MonsterLevel) or {},
                nReset          = tonumber(tbLine.Reset or 0),
                StarCondition   = {},
                StarConditionStr= {},
                tbMonster       = {}
            };
            for i = 1, 3 do
                tbInfo.tbMonster[i] = Eval(tbLine["Monster" .. i]) or {}
                tbInfo.StarCondition[i] = Eval(tbLine["StarCondition" .. i]) or {}
                tbInfo.StarConditionStr[i] = tbLine["StarCondition" .. i] or ""
            end
            ClimbTowerLogic.tbLevelorderConf[nID] = tbInfo
        end
    end
    print('challenge/climbtower/climb_tower_levelorder.txt')
end
--- 加载活动周期配置
function ClimbTowerLogic.LoadTimeConf()
    ClimbTowerLogic.tbTimeConf = {}
    local tbFile = LoadCsv('challenge/climbtower/climb_tower_time.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID         = nID,
                tbBuffID    = Eval(tbLine.BuffID) or {},
                sBuffDesc   = tbLine.BuffDesc,
                tbLevel1    = Eval(tbLine.Level1) or {},
                tbLevel2    = Eval(tbLine.Level2) or {},
                tbCondition	= Eval(tbLine.Condition) or {},
            };

            tbInfo.nStartTime  = ParseTime(string.sub(tbLine.StartTime or '', 2, -2, tbInfo, "nStartTime"))
            tbInfo.nEndTime    = ParseTime(string.sub(tbLine.EndTime or '', 2, -2, tbInfo, "nEndTime"))
            ClimbTowerLogic.tbTimeConf[nID] = tbInfo
        end
    end
    print('challenge/climbtower/climb_tower_time.txt')
end
--- 加载难度配置
function ClimbTowerLogic.LoadDiffConf()
    ClimbTowerLogic.tbDiffConf = {}
    local tbFile = LoadCsv('challenge/climbtower/climb_tower_diff.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID);
        if nID then
            local tbInfo = {
                nID         = nID,
                Level1      = tonumber(tbLine.Level1) or 0,
                Level2      = tonumber(tbLine.Level2) or 0,
            };
            ClimbTowerLogic.tbDiffConf[nID] = tbInfo
        end
    end
    print('challenge/climbtower/climb_tower_diff.txt')
end

---得到爬塔关卡配置信息
---@param nLevel integer 爬塔关ID
---@return table 返回爬塔关卡配置信息
function ClimbTowerLogic.GetLevelInfo(nLevel)
    if not nLevel then return nil end
    return ClimbTowerLogic.tbLevelorderConf[nLevel]
end

---得到当前挑战进度 返回层数和关卡ID
---@param nType int 1：基座 2：大楼
function ClimbTowerLogic.GetLayerID(nType)
    local tb = ClimbTowerLogic.GetAllLayerTbLevel(nType)
    for id, tblevelid in ipairs(tb) do
        for _, levelid in ipairs(tblevelid) do
            local towerlevel = ClimbTowerLogic.GetLevelInfo(levelid)
            if towerlevel then
                local levelcfg = TowerLevel.Get(towerlevel.nLevelID)
                if not levelcfg or not levelcfg:IsPass() then
                    return id, levelid
                end
            end
        end
    end
    return #tb, tb[#tb]
end

---获取当前进行的爬塔关卡配置
function ClimbTowerLogic.GetLevelCfg()
    return ClimbTowerLogic.tbLevelorderConf[ClimbTowerLogic.GetLevelID()]
end

---获取当前进行的爬塔关怪物信息
function ClimbTowerLogic.GetMonsterInfo()
    local LevelCfg = ClimbTowerLogic.GetLevelCfg()
    if not LevelCfg then return {} end
    return LevelCfg.tbMonster
end

---获取所有层的关卡列表
---@param nType integer 1：基座 2：大楼
function ClimbTowerLogic.GetAllLayerTbLevel(nType)
    local timecfg = ClimbTowerLogic.GetTimeCfg()
    if not timecfg then return {} end
    return timecfg["tbLevel" .. nType] or {}
end

---获取某层的关卡列表
---@param nType integer 1：基座 2：大楼（可选，如果传nil且想获取大楼的, 则nlayer是连续的）
---@param nlayer integer 层
function ClimbTowerLogic.GetLayerTbLevel(nType, nlayer)
    if not nType then
        local timecfg = ClimbTowerLogic.GetTimeCfg()
        if timecfg then
            if nlayer <= #timecfg.tbLevel1 then
                return timecfg.tbLevel1[nlayer] or {}
            else
                nlayer = nlayer - #timecfg.tbLevel1
                return timecfg.tbLevel2[nlayer] or {}
            end
        end
    else
        return ClimbTowerLogic.GetAllLayerTbLevel(nType)[nlayer] or {}
    end
end

---得到某层是否首通
---@param nType integer 1：基座 2：大楼（可选，如果传nil且想获取大楼的, 则nlayer是连续的）
---@param nlayer integer 层
function ClimbTowerLogic.GetLayerIsPass(nType, nlayer)
    local TbLevel = ClimbTowerLogic.GetLayerTbLevel(nType, nlayer)
    local isComplete = true
    for _, id in pairs(TbLevel) do
        local towerlevel = ClimbTowerLogic.GetLevelInfo(id)
        if towerlevel then
            local tbLevelCfg = TowerLevel.Get(towerlevel.nLevelID)
            if not tbLevelCfg or tbLevelCfg:GetPassTime() <= 0 then
                isComplete = false
            end
        end
    end
    return isComplete
end

---得到基座是否全部完成
function ClimbTowerLogic.BasicIsComplete()
    local talevel = ClimbTowerLogic.GetAllLayerTbLevel(1)
    for _, v in pairs(talevel) do
        for _, id in pairs(v) do
            local towerlevel = ClimbTowerLogic.GetLevelInfo(id)
            if towerlevel then
                local tbLevelCfg = TowerLevel.Get(towerlevel.nLevelID)
                if not tbLevelCfg or not tbLevelCfg:IsPass() then
                    return false
                end
            else
                return false
            end
        end
    end
    return true
end

---得到某层是否解锁
function ClimbTowerLogic.CheckUnlock(nType, nlayer)
    if nType == 1 and nlayer == 1 then
        return true
    end
    if nType ~= 1 then
        local cfg = ClimbTowerLogic.GetTimeCfg()
        local bok, dec = Condition.Check(cfg.tbCondition)
        if not bok then
            return false, dec[1]
        end
        local layer = ClimbTowerLogic.GetLayerID(1)
        if layer <= 4 then
            return false, Text("climbtower.tips2", 4)
        end
    end
    local layer = ClimbTowerLogic.GetLayerID(nType)
    return layer >= nlayer, "climbtower.tips"
end

---获取某区域三个星级条件是否达成
---@param nLevel integer 爬塔关
---@param nArea integer 区域1,2,3
---@return table 返回是否达成
function ClimbTowerLogic.DidGotStars(nLevel, nArea)
    if not nLevel or not nArea then return {} end
    local value = me:GetAttribute(ClimbTowerLogic.GID, ClimbTowerLogic.LevelSubIDStart + nLevel)
    local tbInfo = {}
    for i = 1, 3 do
        local index = (nArea - 1) * 3 + i - 1
        tbInfo[i] = GetBits(value, index, index) == 1
    end
    return tbInfo
end

---获取某关累计的星级
---@param nLevel integer 爬塔关
---@return integer 返回区域星级
function ClimbTowerLogic.GetLevelStar(nLevel)
    if not nLevel then return 0 end
    local value = me:GetAttribute(ClimbTowerLogic.GID, ClimbTowerLogic.LevelSubIDStart + nLevel)
    local num = 0
    for i = 0, 8 do
        if GetBits(value, i, i) == 1 then
            num = num + 1
        end
    end
    return num
end

---得到某层累计的星级
---@param nType integer 1：基座 2：大楼（可选，如果传nil且想获取大楼的, 则nlayer是连续的）
---@param nlayer integer 层
function ClimbTowerLogic.GetLayerStar(nType, nlayer)
    local TbLevel = ClimbTowerLogic.GetLayerTbLevel(nType, nlayer)
    local num = 0
    for _, id in pairs(TbLevel) do
        num = num + ClimbTowerLogic.GetLevelStar(id)
    end
    return num
end

---得到某层的奖励配置
---@param nType integer 1：基座 2：大楼（可选，如果传nil且想获取大楼的, 则nlayer是连续的）
---@param nlayer integer 层
function ClimbTowerLogic.GetLayerTbAward(nType, nlayer)
    local timecfg = ClimbTowerLogic.GetTimeCfg()
    if not timecfg then return {} end
    if nType and nType == 2 then
        nlayer = nlayer + #timecfg.tbLevel1
    end
    local diff = 1
    if (nType and nType == 2) or nlayer > #timecfg.tbLevel1 then
        diff = ClimbTowerLogic.GetLevelDiff()
    end
    return ClimbTowerLogic.tbAwardConf[nlayer][diff] or {}
end

---得到所有奖励配置
---@param nType integer 1：基座 2：大楼
function ClimbTowerLogic.GetTbAward(nType)
    local tbAward = {}
    local timecfg = ClimbTowerLogic.GetTimeCfg()
    if not timecfg then return tbAward end
    local istart = 0
    local iend = 0
    if nType == 1 then
        istart = 1
        iend = #timecfg.tbLevel1
    elseif nType == 2 then
        istart = #timecfg.tbLevel1 + 1
        iend = #timecfg.tbLevel1 + #timecfg.tbLevel2
    elseif not nType then
        istart = 1
        iend = #timecfg.tbLevel1 + #timecfg.tbLevel2
    end
    local diff = ClimbTowerLogic.GetLevelDiff()
    for i = istart, iend do
        if i > #timecfg.tbLevel1 then
            table.insert(tbAward, ClimbTowerLogic.tbAwardConf[i][diff])
        else
            table.insert(tbAward, ClimbTowerLogic.tbAwardConf[i][1])
        end
    end
    table.sort(tbAward, function(a,b) return a.nID < b.nID end)
    return tbAward
end

---是否有奖励未领取
---@param nType integer 1：基座 2：大楼
---@param nSelectGroup integer 1:首通奖励 2:星级奖励 不传或者为空:所有奖励
function ClimbTowerLogic.CanReceive(nType, nSelectGroup)
    local tbAward = ClimbTowerLogic.GetTbAward(nType)
    for _, cfg in pairs(tbAward) do
        if not ClimbTowerLogic.IsReceive(cfg.nID, 0) and ClimbTowerLogic.GetLayerIsPass(nil, cfg.nID) and (not nSelectGroup or nSelectGroup == 1) then
            return true
        end

        if not nSelectGroup or nSelectGroup == 2 then
            for k, v in pairs(cfg.tbStarCount) do
                local bReceive = ClimbTowerLogic.IsReceive(cfg.nID, k)
                local nowStarCount = ClimbTowerLogic.GetLayerStar(nil, cfg.nID)
                local bCompleted = nowStarCount >= v
                if not bReceive and bCompleted then
                    return true
                end
            end
        end
    end
    return false
end

---是否基座
function ClimbTowerLogic.IsBasic(towerlevelid)
    towerlevelid = towerlevelid or ClimbTowerLogic.GetLevelID()
    local timecfg = ClimbTowerLogic.GetTimeCfg()
    if not timecfg then return false end
    for _, v in pairs(timecfg.tbLevel1) do
        for _, id in pairs(v) do
            if towerlevelid == id then
                return true
            end
        end
    end
    return false
end

---是否大楼
function ClimbTowerLogic.IsAdvanced(towerlevelid)
    towerlevelid = towerlevelid or ClimbTowerLogic.GetLevelID()
    if towerlevelid == 0 then
        return ClimbTowerLogic.CheckUnlock(2, 1)
    end
    local timecfg = ClimbTowerLogic.GetTimeCfg()
    if not timecfg then return false end
    for _, v in pairs(timecfg.tbLevel2) do
        for _, id in pairs(v) do
            if towerlevelid == id then
                return true
            end
        end
    end
    return false
end

---获取当前一层一组关卡ID
function ClimbTowerLogic.GetNowTbLevelID()
    local levelid = ClimbTowerLogic.GetLevelID()
    local timecfg = ClimbTowerLogic.GetTimeCfg()
    if not timecfg then return {} end
    for _, v in pairs(timecfg.tbLevel1) do
        for _, id in pairs(v) do
            if levelid == id then
                return v
            end
        end
    end
    for _, v in pairs(timecfg.tbLevel2) do
        for _, id in pairs(v) do
            if levelid == id then
                return v
            end
        end
    end
    return {}
end

---是否是上下层关卡 如果是上下层还返回是否上层
function ClimbTowerLogic.IsDouble(towerlevelid)
    towerlevelid = towerlevelid or ClimbTowerLogic.GetLevelID()
    local timecfg = ClimbTowerLogic.GetTimeCfg()
    if not timecfg then return false end
    for _, v in pairs(timecfg.tbLevel1) do
        for i, id in pairs(v) do
            if towerlevelid == id then
                return #v > 1, i <= 1
            end
        end
    end
    for _, v in pairs(timecfg.tbLevel2) do
        for i, id in pairs(v) do
            if towerlevelid == id then
                return #v > 1, i <= 1
            end
        end
    end
    return false
end

---是否是由爬塔的上层进入到下层
ClimbTowerLogic.IsToNext = nil
---加载关卡时是否是由爬塔的上层进入到下层
function ClimbTowerLogic.IsChangeToNext()
    if Launch.GetType() == LaunchType.TOWER and ClimbTowerLogic.IsToNext then
        return true
    end
    return false
end

---上下关的层获取下一关ID，没有返回nil
function ClimbTowerLogic.NextLevelID()
    local levelid = ClimbTowerLogic.GetLevelID()
    local timecfg = ClimbTowerLogic.GetTimeCfg()
    if not levelid or not timecfg then return nil end
    for _, v in pairs(timecfg.tbLevel1) do
        for i, id in pairs(v) do
            if levelid == id then
                return v[i+1]
            end
        end
    end
    for _, v in pairs(timecfg.tbLevel2) do
        for i, id in pairs(v) do
            if levelid == id then
                return v[i+1]
            end
        end
    end
    return nil
end

---得到当前挑战的所有buffID
function ClimbTowerLogic.GetAllBuffID()
    if not ClimbTowerLogic.tbNowBuffID then
        ClimbTowerLogic.UpdateBuffID()
    end
    return ClimbTowerLogic.tbNowBuffID
end

---刷新当前挑战的所有buffID
function ClimbTowerLogic.UpdateBuffID()
    ClimbTowerLogic.tbNowBuffID = {}
    if ClimbTowerLogic.IsAdvanced() then
        local timecfg = ClimbTowerLogic.GetTimeCfg()
        if timecfg and timecfg.tbBuffID then
            for _, buffid in pairs(timecfg.tbBuffID) do
                table.insert(ClimbTowerLogic.tbNowBuffID, buffid)
            end
        end
    end
    local levelcfg = ClimbTowerLogic.GetLevelCfg()
    if levelcfg and levelcfg.tbLevelBuff then
        for _, buffid in pairs(levelcfg.tbLevelBuff) do
            table.insert(ClimbTowerLogic.tbNowBuffID, buffid)
        end
    end
end

--- 进入或退出关卡时刷新数据
---@param IsClean boolean 可选参数，是否清除数据
function ClimbTowerLogic.UpdateFight(IsClean)
    if IsClean then -- 清除数据
        ClimbTowerLogic.tbNowBuffID = nil
    else    -- 准备战斗
        ClimbTowerLogic.UpdateBuffID()
    end
end

--- 刷新玩家身上的buff
function ClimbTowerLogic.AddPlayerBuff(TargetPawn, LauncherAbility)
    if not TargetPawn or Launch.GetType() ~= LaunchType.TOWER then
        return
    end
    local Ability = TargetPawn:GetAbilityComponent()
    local vector = UE4.FVector(0,0,0)
    for _, buffid in ipairs(ClimbTowerLogic.GetAllBuffID()) do
        UE4.UModifier.MakeModifier(buffid, TargetPawn, LauncherAbility, Ability, nil, vector, vector)
    end
end

---刷新怪物身上的buff
function ClimbTowerLogic.AddMonsterBuff(TargetPawn, LauncherAbility)
    if not TargetPawn or Launch.GetType() ~= LaunchType.TOWER then
        return
    end
    local Ability = TargetPawn:GetAbilityComponent()
    local vector = UE4.FVector(0,0,0)
    for _, buffid in ipairs(ClimbTowerLogic.GetAllBuffID()) do
        UE4.UModifier.MakeModifier(buffid, TargetPawn, LauncherAbility, Ability, nil, vector, vector)
    end
end

---检查某层是否领取奖励
---@param nLayer integer 层
---@param nGroup integer 0：首通奖励 1,2,3：星级等级奖励
---@return boolean 返回是否领奖
function ClimbTowerLogic.IsReceive(nLayer, nGroup)
    if not nLayer or not nGroup then return true end
    local v = me:GetAttribute(ClimbTowerLogic.GID, ClimbTowerLogic.SubIDStart + nLayer)
    if nGroup == 0 then
        return GetBits(v, 0, 3) > 0
    elseif nGroup == 1 then
        return GetBits(v, 4, 7) > 0
    elseif nGroup == 2 then
        return GetBits(v, 8, 11) > 0
    elseif nGroup == 3 then
        return GetBits(v, 12, 15) > 0
    end
    return true
end

---获取9-12层当前的挑战难度
function ClimbTowerLogic.GetLevelDiff()
    return me:GetAttribute(ClimbTowerLogic.GID, ClimbTowerLogic.DiffSubID)
end
---设置9-12层当前的挑战难度
function ClimbTowerLogic.SetLevelDiff(diff)
    UI.ShowConnection()
    me:CallGS("ClimbTowerLogic_SetLevelDiff", json.encode({nDiff = diff}))
end
-- 设置9-12层挑战难度后供服务端调用的回调
s2c.Register('ClimbTowerLogic_SetLevelDiff', function()
    UI.CloseConnection()
    local sUI = UI.GetUI("Tower")
    if sUI and sUI:IsOpen() then
        WidgetUtils.Collapsed(sUI.TowerDifficulty)
        sUI:UpdateLevel()
    end
end)

---领取奖励
---@param nType integer 1：基座 2：大楼（可选，如果传nil且想获取大楼的, 则nlayer是连续的）
---@param nLayer integer 层
---@param nGroup integer 可选 0：首通奖励 1,2,3：星级等级奖励，nil则领取该层所有奖励
function ClimbTowerLogic.GetReward(nType, nLayer, nGroup)
    if not nLayer then
        return
    end
    local data = {
        nType = nType,
        nLayer = nLayer,
        nGroup = nGroup
    }
    UI.ShowConnection()
    me:CallGS("ClimbTowerLogic_GetReward", json.encode(data))
end

---一键领取奖励
---@param Group integer 1首通奖励 2星级奖励
function ClimbTowerLogic.OneClicReward(Group, Type)
    if not Group then return end
    me:CallGS("ClimbTowerLogic_OneClicReward", json.encode({nGroup = Group, nType = Type}))
end

-- 领取奖励后供服务端调用的回调
s2c.Register('ClimbTowerLogic_GetReward', function(tbParam)
    UI.CloseConnection()
    if tbParam.tbRewards then
        Item.Gain(tbParam.tbRewards)
    end

    local sUI = UI.GetUI("Tower")
    if sUI and sUI:IsOpen() then
        sUI:UpdateRewardState()
    end
end)

-- 放弃之前的爬塔挑战后供服务端调用的回调
-- s2c.Register('ClimbTowerLogic_TowerGiveUp', function()
-- end)

---记录关卡挑战进度和区域星级，方便下次继续挑战
function ClimbTowerLogic.RecordProgres(nlevelid, nArea, nStar, isRecordHP)
    local data = {nID = nlevelid, nArea = nArea, nStar = nStar}
    if isRecordHP then
        data.tbRoleHP = {}
        local Controller = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
        if Controller then
            local lineup = Controller:GetPlayerCharacters()
            for i = 1, lineup:Length() do
                local Character = lineup:Get(i)
                data.tbRoleHP[i] = {Character:GetTemplateID(), math.ceil(Character.Ability:GetPropertieValueFromString("Health"))}
            end
        end
        local TeamComponent = Controller:GetTeamComponent()
        if TeamComponent then
            data.nTeamEnergy = math.ceil(TeamComponent:GetRolePropertieValue(UE4.EAttributeType.CharacterEnergy))
        end
    end
    UI.ShowConnection()
    me:CallGS("ClimbTowerLogic_RecordProgres", json.encode(data))
end
s2c.Register("ClimbTowerLogic_RecordProgres", function()
    UI.CloseConnection()
end)

---标记关卡挑战过，方便下次挑战刷新出生点
function ClimbTowerLogic.RecordChallenged()
    local v = me:GetAttribute(ClimbTowerLogic.GID, ClimbTowerLogic.LevelSubIDStart + ClimbTowerLogic.GetLevelID())
    local CurrentNum = GetBits(v, 12, 15)
    if CurrentNum <= 0 then    ---以前没挑战过，标记挑战过
        me:CallGS("ClimbTowerLogic_RecordChallenged", json.encode({nID = ClimbTowerLogic.GetLevelID()}))
        printf("ClimbTowerLogic.RecordChallenged %d", CurrentNum)
    end
end

---检查周期关卡，到时间则重置
function ClimbTowerLogic.CheckCycleLevel()
    FunctionRouter.CheckEx(FunctionType.Tower, function()
        UI.ShowConnection()
        me:CallGS("ClimbTowerLogic_CheckCycleLevel")
    end)
end

---检查周期关卡后供服务端调用的回调
s2c.Register('ClimbTowerLogic_CheckCycleLevel', function(tbParam)
    UI.CloseConnection()
    if tbParam and tbParam.timeID then
        if tbParam.cfg and ClimbTowerLogic.tbTimeConf[tbParam.timeID] then
            for k, v in pairs(tbParam.cfg) do
                ClimbTowerLogic.tbTimeConf[tbParam.timeID][k] = v
            end
        end
        ClimbTowerLogic.NowTimeId = tbParam.timeID
        local sUI = UI.GetUI("Tower")
        if sUI and sUI:IsOpen() then
            sUI:UpdateOnOpen()
            return
        end
        UI.Open('Tower')
    else
        UI.ShowTip(Text("ui.TxtNotOpen"))
    end
end)

---GM指令注册完成当前层事件
s2c.Register('ClimbTowerLogic_TowerVictory', function()
    Launch.Next()
end)

ClimbTowerLogic.LoadConf()

printf("lxh_test ClimbTower.lua load success!")