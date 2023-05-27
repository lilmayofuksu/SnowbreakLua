-- ========================================================
-- @File    : Chapter.lua
-- @Brief   : 章节管理器
-- ========================================================

---@class Chapter 章节逻辑管理
Chapter = Chapter or {tbMain = {}, tbBranch = {}}

Chapter.GID_MASK        = 20;  -- 章节星级奖励领取Mask记录组ID

---难度切换事件
Chapter.DIFFICULT_CHANGE = 'DIFFICULT_CHANGE'
---章节类型切换事件
Chapter.CHAPTER_TYPE_CHANGE = 'CHAPTER_TYPE_CHANGE'

---难度等级
---@class CHAPTER_LEVEL 困难等级
CHAPTER_LEVEL = {}
CHAPTER_LEVEL.EASY       = 1
CHAPTER_LEVEL.NORMAL     = 2
CHAPTER_LEVEL.DIFFCULT   = 3

Chapter.DebugCount = 0  -- 调试用

---临时变量
local var = { bMain = true, nDifficult = CHAPTER_LEVEL.EASY, nChapterID = nil, nLevelID = nil, nSeed = 0 }

function Chapter.Print()
    printf("Chapter.Print() : bMain %s , nDifficult %s , nChapterID %s , nLevelID %s ", var.bMain, var.nDifficult, var.nChapterID, var.nLevelID)
end


function Chapter.Log(nLevelID)
    local bPlot = Chapter.IsPlot(nLevelID)
    local tbLog = {}
    if bPlot then
        tbLog['StoryFinish'] = LaunchLog.LogStoryFinish()
    else
        tbLog['LevelFinish'] = LaunchLog.LogLevel()
        tbLog['FightRecont'] = LaunchLog.LogFightRecont()
        tbLog['FightHistory'] = LaunchLog.LogFightHistory()
        tbLog['LevelPerformance'] = LaunchLog.LogPerformance()
    end
    return tbLog
end

---保存关卡ID
function Chapter.SetLevelID(nLevelID)
    var.nLevelID = nLevelID
end

---获取关卡ID
function Chapter.GetLevelID()
    return var.nLevelID
end

---设置章节难度
---@param nDifficult CHAPTER_LEVEL 难度等级
function Chapter.SetChapterDifficult(nDifficult)
    var.nDifficult = nDifficult
    EventSystem.TriggerTarget(Chapter, Chapter.DIFFICULT_CHANGE, nDifficult)
end

---获取难度等级
function Chapter.GetChapterDifficult()
    return var.nDifficult
end

---设置章节类型
---@param bMain boolean 是否主线章节
function Chapter.SetChapterType(bMain)
    var.bMain = bMain
    EventSystem.TriggerTarget(Chapter, Chapter.CHAPTER_TYPE_CHANGE, var.bMain)
end

---是否是主线类型
function Chapter.IsMain()
    return var.bMain
end

---设置章节ID
---@param nChapterID number 章节ID
function Chapter.SetChapterID(nChapterID)
    if var.nChapterID ~= nChapterID then
        var.nChapterID = nChapterID
        Chapter.SetLevelID(Chapter.GetProceedLevel(nChapterID, var.nDifficult))
    end
end

function Chapter.GetChapterID()
    return var.nChapterID
end

function Chapter.GetNextLevelID()
    local tbCfg = ChapterLevel.Get(var.nLevelID)
    if not tbCfg then return 0 end
    return tbCfg.nNextID
end

---是否是剧情关卡
---@param nLevelID Integer 关卡ID
function Chapter.IsPlot(nLevelID)
    nLevelID = nLevelID or var.nLevelID
    local tbLevelCfg = ChapterLevel.Get(nLevelID)
    return tbLevelCfg and (tbLevelCfg.nType == 2 or tbLevelCfg.nType == 7)
end

---获取队伍限制
function Chapter.GetTeamRule()
    local tbLevel = ChapterLevel.Get(var.nLevelID)
    if tbLevel then
        return tbLevel.tbTeamRule
    end
end

---获取关卡星级目标配置
---@param nLevelID number 关卡ID
function Chapter.GetLevelStarCfg(nLevelID)
    if Launch.GetType() == LaunchType.ROLE then
        return Role.GetLevelStarCfg(nLevelID)
    elseif Launch.GetType() == LaunchType.CHAPTER then
        local tbLevel = ChapterLevel.Get(nLevelID, true)
        if not tbLevel then return "" end
        return tbLevel.sStarCondition
    end
    return ""
end

---刷新剧情关卡提示信息
---@param nChapterID Integer 章节ID
function Chapter.UpdatePlotLevelTip(nChapterID)
    local chapterCfg = Chapter.GetChapterCfg(true, CHAPTER_LEVEL.EASY, nChapterID)
    if not chapterCfg then return end
     ---剧情关卡
     local tbLevel = chapterCfg.tbLevel
     for _, nLevelID in ipairs(tbLevel) do
         if Chapter.IsPlot(nLevelID) then
             local tbLevelCfg = ChapterLevel.Get(nLevelID)
             if Condition.Check(tbLevelCfg.tbCondition) and tbLevelCfg:IsFirstPass() then
                 RedPoint.SetRedNum(RedPointType.PlotLevel, 1, string.format('%d_%d-%d', chapterCfg.nID, CHAPTER_LEVEL.EASY, tbLevelCfg.nID))
             end
         end
     end
end


---更新章节星级奖励提示
---@param bMain boolean 是否主线章节
---@param nDifficult CHAPTER_LEVEL 难度等级
---@param nChapterID number 章节ID
function Chapter.UpdateStarAwardTip(bMain, nDifficult, nChapterID)
    local bTip = Chapter.IsCanGetStarAward(bMain, nDifficult, nChapterID)
    local nNum = bTip and 1 or 0
    RedPoint.SetRedNum(RedPointType.StarAward, nNum, string.format('%d_%d', nChapterID, nDifficult))
end

---章节星级奖励是否可以领取
---@param bMain boolean 是否主线章节
---@param nDifficult CHAPTER_LEVEL 难度等级
---@param nChapterID number 章节ID
function Chapter.IsCanGetStarAward(bMain, nDifficult, nChapterID)
    local tbCfg = Chapter.GetChapterCfg(bMain, nDifficult, nChapterID)
    if tbCfg == nil then return false end
    local tbAward = tbCfg.tbStarAward
    if tbAward == nil then return false end

    local nAllNum, nGetNum = Chapter.GetChapterStarInfo(bMain, nDifficult, nChapterID)
    for nLevel, tbInfo in ipairs(tbAward) do
        local bGet = tbCfg:DidGotStarAward(nLevel)
        if (not bGet) and tbInfo[1] <= nGetNum then
                return true
        end
    end
    return false
end

---获取章节星级信息 星级总数 获得星级数
---@param bMain boolean 是否主线章节
---@param nDifficult CHAPTER_LEVEL 难度等级
---@param nChapterID number 章节ID
function Chapter.GetChapterStarInfo(bMain, nDifficult, nChapterID)
    local bMain = (bMain == nil) and var.bMain or bMain
    local nDifficult = nDifficult  or var.nDifficult
    local nChapterID = nChapterID or var.nChapterID
    local tbCfg = Chapter.GetChapterCfg(bMain, nDifficult, nChapterID)
    if not tbCfg then return 999, 0 end
    local nStarNum = 0
    local nGetStarNum = 0
    for _, nLevelID in ipairs(tbCfg.tbLevel or {}) do
        local tbLevelCfg = ChapterLevel.Get(nLevelID)
        local n = tbLevelCfg and #tbLevelCfg.tbStarCondition or 0
        if tbLevelCfg and n > 0 then
            nStarNum = nStarNum + #tbLevelCfg.tbStarCondition
            nGetStarNum = nGetStarNum + tbLevelCfg:CountGotStar()
        end
    end
    return nStarNum , nGetStarNum
end

function Chapter.GetChapterPlotInfo( bMain, nDifficult, nChapterID )
    local chapterCfg = Chapter.GetChapterCfg(bMain, nDifficult, nChapterID)
    if not chapterCfg then return nil end

    local nPlotNum = 0
    local nGetPlotNum = 0
    for nIdx, nLevelID in ipairs(chapterCfg.tbLevel) do
        if nLevelID ~= 1100 and Chapter.IsPlot(nLevelID) then
            local tbLevelCfg = ChapterLevel.Get(nLevelID)
            if tbLevelCfg and tbLevelCfg:GetPassTime() > 0 then
                nGetPlotNum = nGetPlotNum + 1
            end
            nPlotNum = nPlotNum + 1
        end
    end
    return nPlotNum,nGetPlotNum
end

function Chapter.GetProceedLevelByDiff(nChapterID,nDifficult)
    local chapterCfg = Chapter.GetChapterCfg(true, nDifficult, nChapterID)
    if not chapterCfg then return nil end

    local nLastLevelId = nil
    for nIdx, nLevelID in ipairs(chapterCfg.tbLevel) do
        if nLevelID ~= 1100 then
            local tbLevelCfg = ChapterLevel.Get(nLevelID)
            if tbLevelCfg and tbLevelCfg:GetPassTime() <= 0 then
                return tbLevelCfg.nID
            end
            nLastLevelId = nLevelID
        end
    end
    return nLastLevelId
end

function Chapter.IsChapterContainsLevel(nChapterID,nDifficult,nLevelID2)
    local chapterCfg = Chapter.GetChapterCfg(true, nDifficult, nChapterID)
    if not chapterCfg then return nil end

    for nIdx, nLevelID in ipairs(chapterCfg.tbLevel) do
        if nLevelID == nLevelID2 then
            return true;
        end
    end
    return false
end

function Chapter.GetMaxProceedLevel()
    local maxChapter = Chapter.GetProceedChapter()
    local chapterDiffConf = Chapter.GetChapterCfg(true, CHAPTER_LEVEL.NORMAL, maxChapter)
    local easyMaxLevel, easyIdx = Chapter.GetProceedLevel(maxChapter, CHAPTER_LEVEL.EASY)

    -- debug msg
    if not chapterDiffConf and GM.IsOpen() and Chapter.DebugCount == 0 then 
        Chapter.DebugCount = 1
        local msg = string.format("找不到主线关卡第%d章难度%d配置，请相关同学尽快解决！\n关联配置表:chapter/chapter_main.txt", maxChapter, CHAPTER_LEVEL.NORMAL)
        UE4.UGMLibrary.ShowDialog("游戏脚本异常", msg);
    end

    if chapterDiffConf and Condition.Check(chapterDiffConf.tbCondition) then
        local diffMaxLevel, maxIdx = Chapter.GetProceedLevel(maxChapter, CHAPTER_LEVEL.NORMAL)
        if maxIdx >= easyIdx then
            return chapterDiffConf, ChapterLevel.Get(diffMaxLevel)
        end
    end
    return Chapter.GetChapterCfg(true, CHAPTER_LEVEL.EASY, maxChapter), ChapterLevel.Get(easyMaxLevel)
end

function Chapter.GetProceedChapter(nDiff)
    local maxChapter = 1
    local tbChapter = Chapter.GetChapterCfgs(true, nDiff or CHAPTER_LEVEL.EASY)
    for _, tbConf in ipairs(tbChapter) do
        if Condition.Check(tbConf.tbCondition) then
            maxChapter = tbConf.nID
        end
    end
    return maxChapter
end

function Chapter.GetProceedLevel(nChapterID, nDiff)
    local chapterCfg = Chapter.GetChapterCfg(true, nDiff or CHAPTER_LEVEL.EASY, nChapterID)
    if not chapterCfg then return nil end

    local nLastLevelId, index = nil, 0
    for _, nLevelID in ipairs(chapterCfg.tbLevelBranch) do
        nLevelID = type(nLevelID) == 'table' and nLevelID[1] or nLevelID
        if nLevelID ~= 1100 then
            local tbLevelCfg = ChapterLevel.Get(nLevelID)
            if not Chapter.IsPlot(nLevelID) then index = index + 1 end
            if tbLevelCfg and tbLevelCfg:GetPassTime() <= 0 then
                return tbLevelCfg.nID, index
            end
            nLastLevelId = nLevelID
        end
    end
    return nLastLevelId, index
end

function Chapter.GetProceedLevelNotPlot(nChapterID)
    local chapterCfg = Chapter.GetChapterCfg(true, CHAPTER_LEVEL.EASY, nChapterID)
    if not chapterCfg then return nil end

    local nLastLevelId = nil
    for nIdx, nLevelID in ipairs(chapterCfg.tbLevel) do
        if nLevelID ~= 1100 and not Chapter.IsPlot(nLevelID) then
            local tbLevelCfg = ChapterLevel.Get(nLevelID)
            if tbLevelCfg and tbLevelCfg:GetPassTime() <= 0 then
                if nLastLevelId == nil then
                    nLastLevelId = Chapter.GetProceedLevelNotPlot(nChapterID - 1)
                end
                return nLastLevelId
            end
            nLastLevelId = nLevelID
        end
    end
    return nLastLevelId
end

function Chapter.GetProceedNotPlot()
    local nChapterID = nil
    local tbChapter = Chapter.GetChapterCfgs(true, CHAPTER_LEVEL.EASY)
    for nIdx, chapterCfg in ipairs(tbChapter) do
        nChapterID = chapterCfg.nID 
        if not chapterCfg:IsComplete() then
            break
        end
    end
    if not nChapterID then return end
    return Chapter.GetProceedLevelNotPlot(nChapterID)
end


---登录初始化
function Chapter.LoginInit()
    var.bMain = true
    Chapter.SetChapterDifficult(CHAPTER_LEVEL.EASY)
    local nLastChapterId = nil
    local tbChapter = Chapter.GetChapterCfgs(true, CHAPTER_LEVEL.EASY)
    for nIdx, chapterCfg in ipairs(tbChapter) do
        if not chapterCfg:IsComplete() then
            Chapter.SetChapterID(chapterCfg.nID)
            break  
        end
        nLastChapterId = chapterCfg.nID
    end

    if Chapter.GetChapterID() == nil then
        Chapter.SetChapterID(nLastChapterId)
    end

    print('Chapter.Init() : ', var.bMain, var.nDifficult, var.nChapterID, var.nLevelID)
end


--[[
     章节配置获取
]]

---获取章节列表
---@param bMain boolean 是否主线章节
---@param nDifficult CHAPTER_LEVEL 难度
function Chapter.GetChapterCfgs(bMain, nDifficult)
    return bMain and Chapter.tbMain[nDifficult] or Chapter.tbBranch[nDifficult]
end

---获取指定ID的章节
---@param bMain boolean 是否主线章节
---@param nDifficult CHAPTER_LEVEL 难度等级
---@param nChapterID number 章节ID
function Chapter.GetChapterCfg(bMain, nDifficult, nChapterID)
    local tbChapter = Chapter.GetChapterCfgs(bMain, nDifficult)
    if tbChapter then return tbChapter[nChapterID] end
    print("Chapter Not Find ID ==", bMain, nDifficult, nChapterID)
end


---获取当前章节配置
function Chapter.GetCurrentChapterCfg()
    return var.bMain and Chapter.tbMain[var.nDifficult][var.nChapterID] or Chapter.tbBranch[var.nDifficult][var.nChapterID]
end

---根据章节ID获取
---@param nChapterID number 章节ID
function Chapter.GetCurrentChapterCfgByID(nChapterID)
    return var.bMain and Chapter.tbMain[var.nDifficult][nChapterID] or Chapter.tbBranch[var.nDifficult][nChapterID]
end

-- 根据关卡id获取所在的章节配置
function Chapter.GetChapterCfgByLevelID(nLevelID)
    for _, tbDiff in ipairs(Chapter.tbMain) do
        for _, tbCfg in pairs(tbDiff) do
            for _, id in ipairs(tbCfg.tbLevel) do
                if id == nLevelID then
                    return tbCfg
                end
            end
        end
    end
end

function Chapter.GetDiffUnlock(nDif, bMain, nChapter)
    if nDif > 1 then
        local bUnlock, tbTip = FunctionRouter.IsOpenById(FunctionType.ChapterDiff)
        if not bUnlock then
            UI.ShowTip(tbTip[1] or '')
            return false
        end
    end
    nChapter = nChapter or 1
    local cfg = Chapter.GetChapterCfg(bMain, nDif, nChapter)
    if not cfg then return false end
    local bUnlock, tbTip, tbResult = Condition.Check(cfg.tbCondition or {}, true)
    if bUnlock then return true end
    for i = 1, #cfg.tbCondition do
        if cfg.tbCondition[i][1] == 2 and tbResult[i] == false then
            local levelId = cfg.tbCondition[i][2]
            local levelConf = ChapterLevel.Get(levelId)
            local chapterConf = Chapter.GetChapterCfgByLevelID(levelId)
            if levelConf and chapterConf then
                local strDiff = chapterConf.nDifficult == 1 and Text('ui.TxtNormal') or Text('ui.TxtHard')
                local levelName = GetLevelName(levelConf)
                UI.ShowTip(string.format(Text('chapter.condition_5'), chapterConf.nID, strDiff, levelName))
            end
            return false
        end
    end
    UI.ShowTip(tbTip[1] or '')
    return false
end

--[[
    加载章节配置
]]


---@class ChapterTemplate 章节模板
local ChapterTemplate = {
    ---是否完成
    IsComplete = function(self)
        for _, nLevelID in ipairs(self.tbLevel) do
            local levelCfg = ChapterLevel.Get(nLevelID)
            if not Chapter.IsPlot(nLevelID) and nLevelID ~= 1100 then
                if not levelCfg or not levelCfg:IsPass() then
                   return false
                end
            end
        end
        return true
    end,

    ---获取最后一个章节
    GetLastLevel = function(self)
        local nLastLevelId = nil
        for _, nLevelID in ipairs(self.tbLevel) do
            local levelCfg = ChapterLevel.Get(nLevelID)
            if not Chapter.IsPlot(nLevelID) and nLevelID ~= 1100 then
                nLastLevelId = nLevelID
            end
        end
        return nLastLevelId
    end,
}





function Chapter.Load(sFile, sLanguageKey, tbStorage)
    local tbFile = LoadCsv(sFile, 1);
    for _, tbLine in ipairs(tbFile) do
        local nID           = tonumber(tbLine.ID) or 0;
        local nDifficult    = tonumber(tbLine.Difficult) or 0;
        local tbInfo        = {
            Logic       = ChapterTemplate,
            nID         = nID,
            nDifficult  = nDifficult,
            sName       = sLanguageKey .. '_' .. nID,
            sEnglishName = sLanguageKey .. '_english_' .. nID,
            sPreName    = 'ui.main_' .. nID,
            tbLevel     = Eval(tbLine.Level) or {},
            tbStarAward = Eval(tbLine.StarAward) or {},
            tbCondition = Eval(tbLine.Condition) or {},
            tbLevelBranch = Eval(tbLine.LevelSort) or {},
            GetSubID    = function(self) return self.nID << 8 | self.nDifficult end,
            DidGotStarAward = function(self, nIndex)
                local nMask = me:GetAttribute(Chapter.GID_MASK, self:GetSubID());
                return GetBits(nMask, nIndex, nIndex) == 1
            end,
            nPicture    = tonumber(tbLine.Picture)
        };

        setmetatable(tbInfo, {
            __index = function(tb, key)
                local v = rawget(tb, key);
                return v or tb.Logic[key];
            end
        });

        tbStorage[nDifficult] = tbStorage[nDifficult] or {};
        tbStorage[nDifficult][nID] = tbInfo;
    end

    print('load ' .. sFile)
end




--[[
        //数据请求
]]



---数据请求类型
Chapter.REQ_ENTER_LEVEL         = 'Chapter_EnterLevel'
Chapter.REQ_GET_STAR_AWARDC     = 'Chapter_GetStarAward' 
Chapter.REQ_LEVEL_SETTLEMENT    = 'Chapter_LevelSettlement'
Chapter.REQ_LEVEL_FAIL          = 'Chapter_LevelFail'  

--[[
        请求进入关卡
]]

function Chapter.Req_EnterLevel(nLevelID)
    local tbCfg = ChapterLevel.Get(nLevelID)
    if not tbCfg then return end
    ---体力检查
    if tbCfg.tbConsumeVigor and #tbCfg.tbConsumeVigor > 1 and  (not Cash.CheckMoney(Cash.MoneyType_Vigour, tbCfg.tbConsumeVigor[1] + tbCfg.tbConsumeVigor[2])) then
        return
    end

    --剧情关卡 不能多倍
    if Chapter.IsPlot(nLevelID) then Launch.SetMultiple(1) end

    local tbLog = {}
    tbLog['LevelEnter'] = LaunchLog.LogLevelEnter()

    -- 是否开启
    local cmd = {
        nID = nLevelID,
        nTeamID = Formation.GetCurLineupIndex(),
        tbLog = tbLog,
        nMultiple = Launch.GetMultiple(),
    }

    --- 判断是否剧情关卡
    if Chapter.IsPlot(nLevelID) and cmd.nTeamID > 5 then
        cmd.nTeamID = 1
    end

    if Chapter.bReqEnter then
        return
    end
    Chapter.bReqEnter = true
    me:CallGS(Chapter.REQ_ENTER_LEVEL, json.encode(cmd))
end

---注册进入关卡的回调
s2c.Register(Chapter.REQ_ENTER_LEVEL, function(tbRet)
    Chapter.bReqEnter = false
    if tbRet.sErr then
        UI.ShowTip(Text(tbRet.sErr))
        return
    end

    var.nSeed = tbRet.nSeed
    Launch.Response(Chapter.REQ_ENTER_LEVEL)
    
end
)

--[[
        请求领取星级奖励
]]

function Chapter.Req_GetStarAward(bMain, nDifficult, nChapterID, nLevel)
    local cmd = {
        bMain = bMain,
        nDifficult = nDifficult,
        nChapterID = nChapterID,
        nIndex = nLevel
    }
    me:CallGS(Chapter.REQ_GET_STAR_AWARDC, json.encode(cmd))
end

---注册领取星级奖励的回调
s2c.Register(Chapter.REQ_GET_STAR_AWARDC, function(...)
    print("get star award:", ...)
    EventSystem.TriggerTarget(Chapter, Chapter.REQ_GET_STAR_AWARDC)
end
)

--[[
    ---请求结算关卡
]]
function Chapter.Req_LevelSettlement(nLevelID)
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

    local bPlot = Chapter.IsPlot(nLevelID)
    local cmd = {
        nID = nLevelID,
        nSeed = var.nSeed,
        tbLog = Chapter.Log(nLevelID) or {},
        nTime = Launch.GetLatelyTime(),
        nStar = nStar,
        nDrop = nDrop,
        tbKill = tbKill,
        tbMonster = tbMonster,
    }
    UI.ShowConnection()
    Reconnect.Send_SettleInfo(Chapter.REQ_LEVEL_SETTLEMENT, cmd)
    --me:CallGS(Chapter.REQ_LEVEL_SETTLEMENT, json.encode(cmd))
end
---注册结算回调
s2c.Register(Chapter.REQ_LEVEL_SETTLEMENT, function(tbAward)
    print("level settlement:", tbAward)
    UI.CloseConnection()
    Launch.Response(Chapter.REQ_LEVEL_SETTLEMENT, tbAward)
end
)

---关卡失败
function Chapter.Req_LevelFail(nLevelID)
    local cmd = {
        nID = nLevelID,
        tbLog = Chapter.Log(nLevelID) or {}
    }
    me:CallGS(Chapter.REQ_LEVEL_FAIL, json.encode(cmd))
end

-----------------------------------------------------------------
Chapter.Load('chapter/chapter_main.txt', 'chapter.main', Chapter.tbMain)
Chapter.Load('chapter/chapter_branch.txt', 'chapter.branch', Chapter.tbBranch)



---注册登录时计算红点
EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    Chapter.bReqEnter = false
    Formation.bReqUpdate = false

    if bReconnected then return end
    if not RunFromEntry then return end

    -- 清空红点数据缓存
    RedPoint.Clear()

    ---设置当前关卡数据
    Chapter.LoginInit()
    ---红点数据
    local tbChapter = Chapter.GetChapterCfgs(true, CHAPTER_LEVEL.EASY)
    for _, chapter in pairs(tbChapter) do
        local bTip = Chapter.IsCanGetStarAward(true, CHAPTER_LEVEL.EASY, chapter.nID)
        if bTip then
            RedPoint.SetRedNum(RedPointType.StarAward, 1, string.format('%d_%d', chapter.nID, CHAPTER_LEVEL.EASY))
        end
        ---剧情关卡
        Chapter.UpdatePlotLevelTip(chapter.nID)
    end
    tbChapter = Chapter.GetChapterCfgs(true, CHAPTER_LEVEL.NORMAL)
    for _, chapter in pairs(tbChapter) do
        local bTip = Chapter.IsCanGetStarAward(true, CHAPTER_LEVEL.NORMAL, chapter.nID)
        if bTip then
            RedPoint.SetRedNum(RedPointType.StarAward, 1, string.format('%d_%d', chapter.nID, CHAPTER_LEVEL.NORMAL))
        end
    end
end)


