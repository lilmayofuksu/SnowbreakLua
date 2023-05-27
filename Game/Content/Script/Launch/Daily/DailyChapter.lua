-- ========================================================
-- @File    : Launch/Daily/DailyChapter.lua
-- @Brief   : 章节数据
-- ========================================================
DailyChapter = DailyChapter or { tbChapter = {} }


---@class DailyChapterTemplate
local DailyChapterTemplate = {

    ---是否开放
    IsOpen = function(self)
        local dailyCfg --= Daily.GetCfgByID(self.nID)
        for _,cfg in pairs (Daily.tbCfg or {}) do
            for _,nChapterID in pairs(cfg.tbChapter or {}) do
                if nChapterID == self.nID then
                    dailyCfg = cfg
                    break
                end
            end
        end
        if dailyCfg and Daily.IsInActivityOpenTime(dailyCfg.tbActivity) then
            return true
        end

        return Daily.CheckOpen(self.tbOpenDay or {})
    end,

     ---获取开放日期信息
     GetOpenDayStr = function(self)
        local str = ''
        for _, n in ipairs(self.tbOpenDay) do
            str = str .. Text('ui.TxtNum' .. n) or ""
        end
        return string.format(Text('ui.TxtDailyOpenTime'), str)
    end,

}

---获取配置
---@param nDifficult Integer 难度
---@param nID Integer 章节ID
function DailyChapter.Get(nDifficult, nID)
    return DailyChapter.tbChapter[nDifficult][nID]
end

---获取对应难度的所有章节
---@param nDifficult Integer 难度
function DailyChapter.GetChaptersByDifficult(nDifficult)
    return DailyChapter.tbChapter[nDifficult]
end


---------------------------------------- 掉落途径 --------------------------------------------------

--- 从指定的关卡列表找道具掉落情况
function DailyChapter.GetDropWayByLevels(tbLevels, g, d, p, l, count)
    for _, tb in ipairs(tbLevels) do 
        local levelId = tb[1]
        local chapterId = tb[2]
        local activityId = tb[3]
        local cfg = DailyLevel.tbLevel[levelId];
        if cfg then 
            local ok = false
            for _, gdpln in ipairs(cfg.tbShowAward) do 
                if gdpln[1] == g and gdpln[2] == d and gdpln[3] == p and gdpln[4] == l then 
                    ok = true;
                    break
                end
            end

            if ok then 
                return {levelId = levelId, chapterId = chapterId, activityId = activityId}
            end
        else 
            printf_e("can not find level id: %s", levelId);
        end
    end

    return nil;
end

--- 取得道具在主线关卡的掉落途径
function DailyChapter.GetDropWay(g, d, p, l, count)
    local tbRet = {}
    for activityId, cfg in ipairs(Daily.tbCfg) do 
        local tbLevels = {}
        for _, chapterId in ipairs(cfg.tbChapter) do 
            local chapterCfg = DailyChapter.Get(1, chapterId);
            if chapterCfg then 
                for _, levelId in ipairs(chapterCfg.tbLevel) do 
                    table.insert(tbLevels, {levelId, chapterId, activityId})
                end
            end
        end
        local tbDrop = DailyChapter.GetDropWayByLevels(tbLevels, g, d, p, l, count)
        if tbDrop then
            table.insert(tbRet, tbDrop)
        end
    end

    return tbRet; 
end




---------------------------------------- 文件加载 --------------------------------------------------

---配置加载
function DailyChapter.Load(sFile, sLanguageKey, tbStorage)
    local tbFile = LoadCsv(sFile, 1);
    for _, tbLine in ipairs(tbFile) do
        local nID           = tonumber(tbLine.ID) or 0;
        local nDifficult    = tonumber(tbLine.Difficult) or 0;
        local tbInfo        = {

            Logic       = DailyChapterTemplate,

            nID         = nID,
            nDifficult  = nDifficult,
            sName       = sLanguageKey .. '_' .. nID,
            sEnglishName = sLanguageKey .. '_english_' .. nID,
            nDifficult  = nDifficult,
            tbLevel     = Eval(tbLine.Level) or {},
            tbStarAward = Eval(tbLine.StarAward) or {},
            tbCondition = Eval(tbLine.Condition) or {},  
            GetSubID    = function(self) return self.nID << 8 | self.nDifficult end,
            DidGotStarAward = function(self, nIndex)
                local nMask = me:GetAttribute(Chapter.GID_MASK, self:GetSubID());
                return GetBits(nMask, nIndex, nIndex) == 1
            end,
            tbOpenDay   = Eval(tbLine.OpenDay) or {},
            nTime       = tonumber(tbLine.Time) or -1,
            nImg        = tonumber(tbLine.Img) or 0,
            Guarantee  = tonumber(tbLine.Guarantee) or 0,
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

DailyChapter.Load('daily/daily_chapter.txt', 'chapter.daily_chapter', DailyChapter.tbChapter)