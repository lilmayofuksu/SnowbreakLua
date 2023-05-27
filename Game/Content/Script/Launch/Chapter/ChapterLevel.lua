-- ========================================================
-- @File    : Launch/Chapter/ChapterLevel.lua
-- @Brief   : 章节关卡数据
-- ========================================================
ChapterLevel = ChapterLevel or { tbLevel = {} }


---关卡信息存放组，每一个LevelID对应一个uint32，第0-7位存放星级达成Flag，第8位存放首通Flag
ChapterLevel.GID = 21;


---@class ChapterLevelType 关卡类型
ChapterLevelType = {}
ChapterLevelType.NORMAL    = 0
ChapterLevelType.BOSS      = 1
ChapterLevelType.PLOT      = 2
ChapterLevelType.MAIN      = 3
ChapterLevelType.RANDOM    = 4
ChapterLevelType.Challenge = 5
ChapterLevelType.Online = 6

ChapterLevel.DebugCount = 0;  -- 调试用的，

---@class ChapterLevelTemplate 数据设置逻辑
---@field nID int 唯一ID
---@field sName string 关卡显示名，配置在language/chapter.txt中的字串ID
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
ChapterLevelTemplate = {

    __GetFlag = function(self, nIdx)
        return GetBits(me:GetAttribute(ChapterLevel.GID, self.nID), nIdx, nIdx);
    end,

    ---是否首通
    ---@param self ChapterLevelTemplate
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

    ---取得星级历史达成标记
    DidGotStar = function(self, nIdx)
        return nIdx < 8 and self:__GetFlag(nIdx) == 1 or false;
    end,

    ---获取星级历史达成标记
    DidGotStars = function(self)
        local tbInfo = {}
        for i = 0, 2 do
            tbInfo[i] = self:DidGotStar(i)
        end
        return tbInfo
    end,

    ---统计星级历史达成数量
    CountGotStar = function(self)
        local nOld = me:GetAttribute(ChapterLevel.GID, self.nID);
        local nCount = 0;
        for i = 0, 7 do
            nCount = nCount + GetBits(nOld, i, i);
        end
        return nCount;
    end,

    ---获取掉落
    GetDrop = function(self)
        local sInfo = me:GetStrAttribute(Launch.GID, self.nID)
        if sInfo and sInfo ~= '' then
            return json.decode(sInfo)
        end
        return nil
    end,
    ---是否完成
    --[[
        剧情：观看完/获取完奖励后，显示
        关卡：3星通关后，显示
    ]]
    IsCompleted = function(self)
        if Chapter.IsPlot(self.nID) then
            return self:GetPassTime() > 0
        end
        return self:CountGotStar() == 3
    end,

    ---获取附加选项
    GetOption = function(self)
        local sOption = 'TaskPath=%s?ReviveCount=%s?AutoReviveTime=%s?AutoReviveHealthScale=%s'
        sOption = string.format(sOption, self.sTaskPath, self.nReviveCount, self.nAutoReviveTime, self.nAutoReviveHealthScale)
        ---Add Other Option
        
        return sOption
    end,

    ---获取体力消耗
    GetConsumeVigor = function(self)
        return (self.tbConsumeVigor[1] or 0) + (self.tbConsumeVigor[2] or 0)
    end,

     -- 获取推荐战力ID
     GetRecommendPowerId = function(self)
        local powerId = self.nRecommendPower
        if not powerId or powerId == 0 then
            local monLevel = UE4.ULevelLibrary.GetPresetMonsterLevelById(self.nID)
            if Chapter.GetChapterDifficult() == CHAPTER_LEVEL.EASY then
                powerId = monLevel
            elseif Chapter.GetChapterDifficult() == CHAPTER_LEVEL.NORMAL then
                powerId = monLevel + 5
            end
        end
        return powerId
    end,

    -- 获取推荐战力
    GetRecommendPower = function(self)
        return ItemPower.GetRecommendPower(self:GetRecommendPowerId())
    end,

    -- 关卡名中'x-x'会被WPS替换为'x月x日'  故策划配置改为'x_x' 程序强行替换'_'为'-'
    GetName = function(self)
        local strName = Text(self.sName)
        strName = string.gsub(strName, '_', '-')
        return strName
    end,
};


---取得一个关卡配置
---@param nID int 唯一的关卡ID
---@return ChapterLevelTemplate 关卡对象
---@return dontShowError 是否不显示错误信息
function ChapterLevel.Get(nID, dontShowError)
    ChapterLevel.AddChapterConditon()
    if not nID or nID <= 0 then return end
    local cfg = ChapterLevel.tbLevel[nID];
    if not cfg and not dontShowError then
        print(debug.traceback())
        UE4.UUMGLibrary.LogError('ChapterLevel: Not Find Level Config ID =' .. nID)
        if IsEditor then 
            if not dontShowError and GM.IsOpen() and ChapterLevel.DebugCount == 0 then 
                ChapterLevel.DebugCount = ChapterLevel.DebugCount + 1
                UE4.UGMLibrary.ShowDialog("请复制以下消息到项目大群中", string.format("读取关卡配置失败！\n有地方试图读取一个不存在的关卡Id：%d（chapter/level.txt）\n\n%s", nID, debug.traceback()));
            end
        end
    end
    return cfg
end

-- 关卡条件中加入所属章节条件
function ChapterLevel.AddChapterConditon()
    if ChapterLevel.IsAddChapterCondition then return end
    for _, diffCfg in ipairs(Chapter.tbMain) do
        for _, chapterCfg in ipairs(diffCfg) do
            for _, levelId in ipairs(chapterCfg.tbLevel) do
                local levelCfg = ChapterLevel.tbLevel[levelId]
                if levelCfg then
                    levelCfg.tbCondition = Concat(levelCfg.tbCondition, chapterCfg.tbCondition)
                end
            end
        end
    end
    ChapterLevel.IsAddChapterCondition = true
end


---------------------------------------- 掉落途径 --------------------------------------------------
--- 从指定的关卡列表找道具掉落情况
function ChapterLevel.GetDropWayByLevels(tbLevels, diff, g, d, p, l, count)
    local maxPassLevelId = {levelId = 0, chapterId = 0}; -- 最大已通关 关卡id
    local minLockLevelId = {levelId = 0, chapterId = 0}; -- 最小未通关 关卡id

    for _, tb in ipairs(tbLevels) do 
        local id = tb[1]
        local chapter = tb[2]
        local cfg = ChapterLevel.tbLevel[id];
        if cfg then 
            local ok = false
            for _, gdpln in ipairs(cfg.tbShowAward) do 
                if gdpln[1] == g and gdpln[2] == d and gdpln[3] == p and gdpln[4] == l then 
                    ok = true;
                    break
                end
            end

            for _, gdpln in ipairs(cfg.tbShowRandomAward) do 
                if gdpln[1] == g and gdpln[2] == d and gdpln[3] == p and gdpln[4] == l then 
                    ok = true;
                    break
                end
            end
            
            if ok then 
                if cfg:IsPass() and Condition.Check(cfg.tbCondition) then 
                    if cfg.nID > maxPassLevelId.levelId then 
                        maxPassLevelId.levelId = cfg.nID 
                        maxPassLevelId.chapterId = chapter
                    end
                else 
                    if minLockLevelId.levelId == 0 or cfg.nID < minLockLevelId.levelId then 
                        minLockLevelId.levelId = cfg.nID 
                        minLockLevelId.chapterId = chapter
                    end
                end
            end
        else 
            printf_e("can not find level id: %s", id);
        end
    end

    -- 关卡掉落情况补充
    local pGetDrop = function(tbLevel, isUnlock)
        local tbData = {isUnlock = isUnlock, isComplete = false, diff = diff, chapterId = tbLevel.chapterId}
        local cfg = ChapterLevel.tbLevel[tbLevel.levelId]
        tbData.nID = tbLevel.levelId
        tbData.name = GetLevelName(cfg)
        return tbData;
    end

    local tbDrop = {}
    if maxPassLevelId.levelId > 0 then table.insert(tbDrop, pGetDrop(maxPassLevelId, true)) end
    if minLockLevelId.levelId > 0 then table.insert(tbDrop, pGetDrop(minLockLevelId, false)) end
    return tbDrop
end

--- 取得道具在主线关卡的掉落途径
function ChapterLevel.GetDropWay(g, d, p, l, count)
    local tbRet = {}
    for nDifficult, tbList in ipairs(Chapter.tbMain) do 
        local tbLevels = {}
        for chapterId, tb in pairs(tbList) do 
            for _, id in ipairs(tb.tbLevel) do 
                local levelCfg = ChapterLevel.Get(id)
                if levelCfg and levelCfg.nType == 0 or levelCfg.nType == 1 or levelCfg.nType == 3 then
                    table.insert(tbLevels, {id, chapterId})
                end
            end
        end
        local tbDrop = ChapterLevel.GetDropWayByLevels(tbLevels, nDifficult, g, d, p, l, count)
        for _, tb in ipairs(tbDrop) do 
            table.insert(tbRet, tb)
        end
    end

    return tbRet; 
end

---------------------------------------- 配置加载 --------------------------------------------------
---加载配置
function ChapterLevel.Load()
    local tbConfig = LoadCsv("chapter/level.txt", 1)
    for _, tbLine in ipairs(tbConfig) do
        local nID = tonumber(tbLine.ID) or 0;
        local tbInfo = {
            Logic               = ChapterLevelTemplate,
            nID                 = nID,
            sName               = 'chapter.level_' .. nID,
            sFlag               = 'chapter.level_name_' .. nID,
            sDes               = 'chapter.level_des_' .. nID,
            nType               = tonumber(tbLine.Type) or 0,
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
            nTeamRuleID          = tonumber(tbLine.TeamRuleID),
            tbBaseDropID         = Eval(tbLine.BaseDropID) or {},
            tbFirstDropID        = Eval(tbLine.FirstDropID) or {},
            tbRandomDropID       = Eval(tbLine.RandomDropID) or {},
            tbStarAward         = Eval(tbLine.StarAward) or {},
            tbShowAward         = Eval(tbLine.ShowAward) or {},
            tbShowRandomAward   = Eval(tbLine.ShowRandomAward) or {},
            tbShowFirstAward    = Eval(tbLine.ShowFirstAward) or {},
            nPictureBoss        = tonumber(tbLine.PictureBoss),
            nPictureLevel       = tonumber(tbLine.PictureLevel),
            nReviveCount      = tonumber(tbLine.ReviveCount) or 0,
            nAutoReviveTime      = tonumber(tbLine.AutoReviveTime) or 0,
            nAutoReviveHealthScale      = tonumber(tbLine.AutoReviveHealthScale) or 0,
            tbBuff        = Eval(tbLine.Buff) or {},
            LevelStrength      = tonumber(tbLine.LevelStrength) or 0,
        }

        setmetatable(tbInfo, {
            __index = function(tb, key)
                local v = rawget(tb, key);
                return v or tb.Logic[key];
            end
        });

        ChapterLevel.tbLevel[nID] = tbInfo;
    end
end


ChapterLevel.Load()