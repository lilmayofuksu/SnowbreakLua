TowerEvent = TowerEvent or {}

TowerEvent.GID             = 13     --战术考核GID

TowerEvent.SubIDStart      = 0   --1开始保存每层的信息（4-7要求一奖励 8-11要求二奖励 12-15要求三奖励）

--- 加载奖励配置
function TowerEvent.LoadAwardConf()
    TowerEvent.tbAwardConf = {}
    local tbFile = LoadCsv('challenge/tower_event/award.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nChapterID = tonumber(tbLine.ChapterID);
        if nChapterID then
            local tbCount = {}
            local tbAward = {}
            for i = 1, 3 do
                tbCount[i] = tonumber(tbLine["LevelCount"..i] or 1)
                tbAward[i] = Eval(tbLine["Award"..i]) or {}
            end
            local tbInfo = {
                nID             = nChapterID,
                tbLevelCount     = tbCount,
                tbChapterAward     = tbAward
            };
            TowerEvent.tbAwardConf[nChapterID] = tbInfo
        end
    end
    print('challenge/tower_event/award.txt')
end

---获取章节完成度
function TowerEvent.GetChapterPassNum(nChapterID)
    local Chapter = TowerEventChapter.tbChapter[nChapterID]
    local nPassLevel = 0
    if not Chapter or #Chapter.tbLevel == 0 then return nPassLevel end
    for _, LevelID in pairs(Chapter.tbLevel) do
        local Level = TowerEventLevel.Get(LevelID)
        if Level and Level:IsPass() then
            nPassLevel = nPassLevel + 1
        end
    end
    return nPassLevel, nPassLevel/#Chapter.tbLevel
end

---检查某层是否领取奖励
---@param nChapterID integer 层
---@param nGroup integer 第几个奖励
---@return boolean 返回是否领奖
function TowerEvent.IsReceive(nChapterID, nGroup)
    if not nChapterID or not nGroup then return true end
    local v = me:GetAttribute(TowerEvent.GID, TowerEvent.SubIDStart + nChapterID)
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

---领取奖励
---@param nChapter integer 层
---@param nGroup integer 第几个奖励,nil为领取所有
function TowerEvent.GetReward(nChapterID, nGroup)
    if not nChapterID then
        return
    end
    local data = {
        nChapterID = nChapterID,
        nGroup = nGroup
    }
    UI.ShowConnection()
    me:CallGS("TowerEventLogic_GetReward", json.encode(data))
end

function TowerEvent.CheckOpenAct()
    FunctionRouter.CheckEx(FunctionType.TowerEvent, function()
            UI.Open("TowerEvent", true)
        end)
end

-- 领取奖励后供服务端调用的回调
s2c.Register('TowerEventLogic_GetReward', function(tbParam)
    UI.CloseConnection()
    if tbParam.tbRewards then
        Item.Gain(tbParam.tbRewards)
    end
    local sUI = UI.GetUI("TowerEventNode")
    if sUI and sUI:IsOpen() then
        sUI:OnReceiveCallback()
    end
end)

TowerEvent.LoadAwardConf()