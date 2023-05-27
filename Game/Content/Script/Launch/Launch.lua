-- ========================================================
-- @File    : Launch/Launch.lua
-- @Brief   : 出击
-- ========================================================
---@class Launch
Launch = Launch or { tbClasses = {}, tbAward = nil }

Launch.GID_TEMP        = 0;   -- 记录一些客户端不使用的数据，用于验证等
Launch.SID_TEMP_MASK   = 3;   -- 记录当前关卡星级达成情况
Launch.SID_TEMP_LEVEL  = 4;   -- 记录当前参与的关卡ID
Launch.SID_TEMP_TIME   = 5;   -- 记录进入的时间
Launch.SID_TEMP_SEED   = 6;   -- 一个随机数，用于验证

--[[
    GID
]]
---关卡信息存放组，每一个LevelID对应一个uint32，第0-7位存放星级达成Flag
Launch.GID        = 21;
---每一个LevelID对应一个uint32，存放通关次数
Launch.GPASSID    = 22;

-- tbPlayAgain 是否再次重玩{类型,关卡id}
local var = {nType = nil, nTaskFinishHandle = nil, nMultiple = 1, tbPlayAgain={}}

---@class LaunchType 出击类型
LaunchType = {}
---指引类型关卡
LaunchType.GUIDE        = 0
---主线类型关卡
LaunchType.CHAPTER      = 1
---每日类型关卡
LaunchType.DAILY        = 2
---爬塔类型关卡
LaunchType.TOWER        = 3
---角色碎片本类型关卡
LaunchType.ROLE         = 4
---Boss挑战类型关卡
LaunchType.BOSS         = 5
---开发世界关卡
LaunchType.OPENWORLD    = 6
---联机关卡
LaunchType.ONLINE       = 7
---防御活动关卡
LaunchType.DEFEND       = 8
---爬塔-战术考核
LaunchType.TOWEREVENT   = 9
-- 棋盘活动
LaunchType.CHESS        = 10
-- 扭蛋角色试玩
LaunchType.GACHATRY     = 11
-- dlc1复刷本
LaunchType.DLC1_CHAPTER = 12
-- dlc1肉鸽活动
LaunchType.DLC1_ROGUE   = 13

---@根据 LaunchType 记录 倍率数据
LaunchType.MaxMultiple = 9  --程序限制上限
--扫荡
LaunchType.MaxMopup = 9  --程序限制上限


Launch.LatelyTime = 0  ---保存最近的一次关卡中所用的时间

Launch.nDropType = {
    FirstDrop = 1,          --首通奖励
    BaseDrop = 2,           --固定奖励
    RandomDrop = 3,         --关卡随机奖励
    SpecialDrop = 4,        --关卡特殊奖励
    ExtraBaseDrop = 5,      --额外的奖励，如活动双倍
    ExtraRandomDrop = 6,    --额外的奖励，如活动双倍
}

---记录当前用时
function Launch.SetLatelyTime(time)
    local TaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
    Launch.LatelyTime = time or (IsValid(TaskActor) and TaskActor:GetLevelCountDownTotalTime())
end

---获取当前用时
function Launch.GetLatelyTime()
    return Launch.LatelyTime
end

--- 设置当前的类型
---@param nType LaunchType
function Launch.SetType(nType)
    if nType ~= var.nType then
        Launch.SetMultiple(1) --更换类型，清空当前选择的倍率
    end
    
    var.nType = nType
    Launch.SetPlayAgain()
end

---获取当前出击类型
function Launch.GetType()
   return var.nType
end

---获取当前levelID
function Launch.GetLevelID()
    if var.nType == LaunchType.DAILY then
        return Daily.GetLevelID()
    elseif var.nType == LaunchType.ROLE then
        return Role.GetLevelID()
    elseif var.nType == LaunchType.TOWER then
        return Map.GetCurrentID()
    elseif var.nType == LaunchType.BOSS then
        return Map.GetCurrentID()
    elseif var.nType == LaunchType.GUIDE and GuideLogic.nNowStep then
        return GuideLogic.PrologueMapID
    elseif var.nType == LaunchType.ONLINE then
        return Online.GetOnlineLevelId()
    elseif var.nType == LaunchType.DEFEND then
        return DefendLogic.GetLevelID()
    elseif var.nType == LaunchType.TOWEREVENT then
        return TowerEventChapter.GetLevelID()
    elseif var.nType == LaunchType.CHESS then
        return ChessClient.GetLevelID()
    elseif var.nType == LaunchType.GACHATRY then
        return GachaTry.GetLevelID()
    elseif var.nType == LaunchType.DLC1_CHAPTER then
        return DLC_Chapter.GetLevelID()
    elseif var.nType == LaunchType.DLC1_ROGUE then
        return RogueLevel.GetLevelID()
    else
        return Chapter.GetLevelID()
    end
end

---获取当前level配置
function Launch.GetLevelConf()
    if var.nType == LaunchType.DAILY then
        return DailyLevel.Get(Daily.GetLevelID())
    elseif var.nType == LaunchType.ROLE then
        return RoleLevel.Get(Role.GetLevelID())
    elseif var.nType == LaunchType.TOWER then
        return TowerLevel.Get(ClimbTowerLogic.GetLevelCfg().nLevelID)
    elseif var.nType == LaunchType.BOSS then
        return BossLogic.GetBossLevelCfg(BossLogic.GetBossLevelID())
    elseif var.nType == LaunchType.ONLINE then
        return OnlineLevel.GetConfig(Online.GetLevelId())
    elseif var.nType == LaunchType.DEFEND then
        return DefendLogic.GetLevelConf(DefendLogic.GetIDAndDiff())
    elseif var.nType == LaunchType.TOWEREVENT then
        return TowerEventLevel.Get(TowerEventChapter.GetLevelID())
    elseif var.nType == LaunchType.CHAPTER then
        return ChapterLevel.Get(Chapter.GetLevelID())
    elseif var.nType == LaunchType.GACHATRY then
        return GachaTry.GetLevelConf(GachaTry.GetLevelID())
    elseif var.nType == LaunchType.DLC1_CHAPTER then
        return DLCLevel.Get(DLC_Chapter.GetLevelID())
    elseif var.nType == LaunchType.DLC1_ROGUE then
        return RogueLevel.Get(RogueLevel.GetLevelID())
    end
end

---获取当前level的强度
function Launch.GetLevelStrength()
    local curConf = Launch.GetLevelConf();
    if curConf == nil then
        return 0;
    end

    return curConf.LevelStrength;
end

function Launch.GetLevelStarConf(nLevelID)
    if Launch.GetType() == LaunchType.ROLE then
        return Role.GetLevelStarCfg(nLevelID)
    elseif Launch.GetType() == LaunchType.CHAPTER then
        local tbLevel = ChapterLevel.Get(nLevelID, true)
        if tbLevel then 
            return tbLevel.sStarCondition 
        end
    elseif Launch.GetType() == LaunchType.DLC1_CHAPTER then
        local tbLevel = DLCLevel.Get(nLevelID)
        if tbLevel then 
            return tbLevel.sStarCondition 
        end
    end
    return ""
end

 --- 设置当前的倍率
function Launch.SetMultiple(nMultiple)
    var.nMultiple = nMultiple
end

---获取当前的倍率
function Launch.GetMultiple()
   return var.nMultiple
end

 ---检查当前关卡是否支持多倍收益
---@param bMopUp bool  是否扫荡
 function Launch.CheckLevelMutipleOpen(bMopUp)
    if bMopUp then
        local tbList = Player.GetMoppingUpConfig(var.nType)
        if not tbList then return end
    else
        local tbList = Player.GetMultipleList(var.nType)
        if not tbList or #tbList == 0 then return end
    end

    if var.nType == LaunchType.CHAPTER then
        local tbConfig = ChapterLevel.Get(Chapter.GetLevelID())
        if not tbConfig then return end

       return tbConfig:IsCompleted()
    elseif var.nType == LaunchType.DAILY then
        local tbConfig = DailyLevel.Get(Daily.GetLevelID())
        if not tbConfig then return end
        if tbConfig.nType == DailyLevel.TeachingLevelType then return end --排除教学关卡

       return tbConfig:IsPass()
    elseif var.nType == LaunchType.ROLE then
        local tbConfig = RoleLevel.Get(Role.GetLevelID())
        if not tbConfig then return end
        if not tbConfig:IsLevel02() then return end

       return tbConfig:IsPass()
    elseif var.nType == LaunchType.DLC1_CHAPTER then
        if DLC_Chapter.GetChapterID() == 1 then
            return
        end
        local tbConfig = DLCLevel.Get(DLC_Chapter.GetLevelID())
        if not tbConfig then return end
        return tbConfig:IsCompleted()
    end
end

 --- 设置当前可重玩关卡
function Launch.SetPlayAgain(nType, nLeveId)
    var.tbPlayAgain = {nType, nLeveId}
end

---获取当前可重玩关卡
function Launch.GetPlayAgain()
   return var.tbPlayAgain
end

--检查当前可重玩关卡
function Launch.CheckPlayAgain(nType, nLeveId)
    if not nType or not nLeveId then return end
    if type(var.tbPlayAgain) ~= "table" or #var.tbPlayAgain ~= 2 then return end

    if nType == var.tbPlayAgain[1] and nLeveId == var.tbPlayAgain[2] then
        return true
    end
end

--[[
    出击流程逻辑处理
]]

---@class tbTemplateLogic 出击界面流程控制
---@field tbResponse table 注册的响应函数
local tbTemplateLogic = {
    tbResponse = {},
    Register = function(self, sType, fResp) self.tbResponse[sType] = fResp end,
    UnRegister = function(self, sType) self.tbResponse[sType] = nil end,
    ---响应服务器回调
    OnResponse = function(self, sType, ...) 
        if self.tbResponse[sType] then self.tbResponse[sType](...) end
        self:UnRegister(sType) 
    end,
    ---开始
    OnStart = function(self, ...)  end,
    ---结算
    OnSettlement = function(self, ...) end,
    ---结束
    OnEnd = function(self, ...) GoToMainLevel() end,
    ---下一关
    OnNext = function(self)  end,
    ---再次挑战
    Again = function(self) Launch.End() end,
}

---注册出击逻辑
---@param nType LaunchType
function Launch.Class(nType)
    if nType == nil then return tbTemplateLogic end
    if Launch.tbClasses[nType] then return Launch.tbClasses[nType] end;
    local tbLogic = Inherit(tbTemplateLogic);
    tbLogic.nType = nType;
    Launch.tbClasses[nType] = tbLogic;
    return tbLogic;
end

---出击开始之前
function Launch.PreStart()
    ---设置队伍信息到关卡 --
    if Launch.GetType() ~= LaunchType.TOWER then --爬塔的队伍在TowerLogic中设置
        local tbteam = Formation.GetCurrentLineup()
        if tbteam then UE4.UUMGLibrary.SetTeamCharacters(tbteam:GetCards()) end
        ---保存经验值信息 用于结算的动态变化
        Launch.SaveExpData(tbteam)
    end
    Launch.SetLatelyTime(0)
    ---注册关卡任务结束通知
    EventSystem.Remove(var.nTaskFinishHandle)
    Launch.LevelHasFinished = false
    var.nTaskFinishHandle = EventSystem.On(Event.OnLevelFinish , function(nResult, nTime, nReason)
        Launch.SetLatelyTime()
        local pFightUI = UI.GetUI('Fight')
        if pFightUI and Launch.GetType() ~= LaunchType.TOWER then
            WidgetUtils.Collapsed(pFightUI)
            Launch.LevelHasFinished = true
            --UI.ShowConnection()
        end

        if not Settlement.LoadSeqLevel(function() Launch.Class(Launch.GetType()):OnSettlement(nResult, nTime, nReason) end) then
            Launch.Class(Launch.GetType()):OnSettlement(nResult, nTime, nReason)
        end
    end)
end

---开始
function Launch.Start()
    Launch.PreStart()
    UI.ShowConnection()
    Launch.Class(Launch.GetType()):OnStart()
end

---结束之前
function Launch.PreEnd()
    GuideLogic.RemoveNotifyEvent()
    EventSystem.Remove(var.nTaskFinishHandle)
end

---结束
function Launch.End()
    Launch.PreEnd()
    Launch.Class(Launch.GetType()):OnEnd()
end

---响应请求回调
function Launch.Response(sType, ...)
    UI.CloseConnection()
    Launch.Class(Launch.GetType()):OnResponse(sType, ...)
end

-----------------------------------------------------

---下一关
function Launch.Next()
    Launch.Class(Launch.GetType()):OnNext()
end

---再次挑战
function Launch.Again()
    Launch.Class(Launch.GetType()):Again()
end

---出击导航栏打开
EventSystem.On(Event.UIOpen, function(pOpenUI)
    local pCfg = UI.GetConfig(pOpenUI.sName)

    if not pCfg then return end
    if pCfg.Type ~= UE4.EUIType.Stack then return end 

    local pNav = UI.GetUI('DungeonsMode')
    local fGoTo = function(nType)
        if nType == nil then
            if pNav then UI.Close(pNav) end
            return
        end
        if not pNav then
            UI.Open('DungeonsMode', nType)
        else
            pNav:Select(nType)
        end
    end

    if pOpenUI.sName == string.lower('Chapter') then
        fGoTo(LaunchType.CHAPTER)
    elseif pOpenUI.sName == string.lower('DungeonsRole') then
        fGoTo(LaunchType.ROLE)
    elseif pOpenUI.sName == string.lower('Challenge') then
        fGoTo(LaunchType.TOWER)
    elseif pOpenUI.sName == string.lower('DungeonsResourse') then
        fGoTo(LaunchType.DAILY)
    elseif pOpenUI.sName == string.lower('DungeonsOnline') then
        fGoTo(LaunchType.ONLINE)
    else
        if pNav then
            UI.Close(pNav)
        end
    end
end)

---加载出击逻辑
function Launch.LoadLogic()
    local allFiles = UE4.UUMGLibrary.FindFilesInFolder("Script/Launch/Classes", ".lua");
    for i = 1, allFiles:Length() do
        local sFile = allFiles:Get(i);
        local pFile = string.gsub(sFile,".lua","")
        require(string.format('Launch.Classes.%s', pFile))
    end
end

function Launch.SaveExpData(tbteam)
    Launch.ExpData = {PlayerExp = {}, CardExp = {}}
    Launch.ExpData.PlayerExp = {nNow = me:Exp(), nMax = Player.GetMaxExp(me:Level()) or 1}
    if tbteam then
        Launch.ExpData.CardExp = {}
        local tbCards = tbteam:GetCards()
        local CardNum = tbCards and tbCards:Length() or 0
        for i = 1, CardNum do
            local pCard = tbCards:Get(i)
            if pCard then
                Launch.ExpData.CardExp[string.format("%d-%d-%d-%d", pCard:Genre(), pCard:Detail(), pCard:Particular(), pCard:Level())] = {nNow = pCard:Exp(), nMax = Item.GetUpgradeExp(pCard), nLevel = pCard:EnhanceLevel()}
            end
        end
    end
end
Launch.LoadLogic()
