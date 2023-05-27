-- ========================================================
-- @File    : FunctionRouter.lua
-- @Brief   : 功能开放判断
-- ========================================================
---@class FunctionRouter 功能开放
---@field tbFun table
---@field tbOpened table
---@field nCacheLevel Integer
FunctionRouter  = FunctionRouter or {  tbFunc = {} ,tbOpened = {}, nCacheLevel = nil}

---@class FunctionType
FunctionType = {}
FunctionType.Chapter            = 1
FunctionType.Role               = 2
FunctionType.Welfare            = 3
FunctionType.Infrastructure     = 4
FunctionType.Task               = 5
FunctionType.Bag                = 6
FunctionType.Shop               = 7
FunctionType.Mall             = 8
FunctionType.Setting            = 9
FunctionType.Mail               = 10
FunctionType.Notice             = 11
FunctionType.Challenge          = 12
FunctionType.DungeonsResourse   = 13
FunctionType.TimeActivitie      = 14
FunctionType.Activity           = 15
FunctionType.Tower              = 16

FunctionType.BossChallenge      = 17 --Boss挑战
FunctionType.WeaponReplace      = 18 --武器替换
FunctionType.Logistics          = 19 --后勤界面
FunctionType.Nerve              = 20 --角色神经
FunctionType.RoleLevel          = 21 --角色碎片
FunctionType.Photograph         = 22 --照相机

FunctionType.Friend             = 23 -- 好友界面
FunctionType.SevenDay           = 24 -- 七天乐
FunctionType.RoleBreak          = 25 -- 天启界面

FunctionType.Defend             = 26 -- 防御活动
FunctionType.BattlePass         = 27 -- bp通行证

FunctionType.TowerEvent         = 28 -- 爬塔-战术考核
FunctionType.ProLevel           = 29 -- 职级认证
FunctionType.Riki               = 30 -- 图鉴
FunctionType.ChessActive        = 31 -- 棋盘活动
FunctionType.ElemExplosion      = 32 -- 元素爆发
FunctionType.RoleLevelUP        = 33 -- 角色卡升级
FunctionType.WeaponPart         = 34 -- 武器配件

FunctionType.TaskBranch        = 35 -- 任务-主线
FunctionType.TaskTarget         = 36 -- 任务-目标
FunctionType.TaskDaily           = 37 -- 任务-日常
FunctionType.TaskWeekly       = 38 -- 任务-周常

FunctionType.ChapterDiff        = 43 -- 章节困难模式


FunctionType.Dorm               = 48 --宿舍

---各功能模块判断是否显示红点的函数
FunctionRouter.tbIsShowRedDotFun = {}
FunctionRouter.tbIsShowRedDotFun[FunctionType.Task] = Achievement.IsShowRedDot
FunctionRouter.tbIsShowRedDotFun[FunctionType.Shop] = ShopLogic.IsShowRedDot
FunctionRouter.tbIsShowRedDotFun[FunctionType.Bag] = Item.BagHaveNew
FunctionRouter.tbIsShowRedDotFun[FunctionType.Mail] = Mail.HaveNew
FunctionRouter.tbIsShowRedDotFun[FunctionType.Role] = RoleCard.IsShowRedDot
FunctionRouter.tbIsShowRedDotFun[FunctionType.Activity] = Activity.CheckMainRed
FunctionRouter.tbIsShowRedDotFun[FunctionType.Friend] = Friend.Pending
FunctionRouter.tbIsShowRedDotFun[FunctionType.Notice] = Notice.HaveNew
FunctionRouter.tbIsShowRedDotFun[FunctionType.BattlePass] = BattlePass.CheckMainRed
FunctionRouter.tbIsShowRedDotFun[FunctionType.Mall] = IBLogic.CheckMainRed


---获取运行时信息
---@param nID Interger 功能ID
function FunctionRouter.GetRuntimeInfo(nID)
    if not nID then return end

    local funCfg = FunctionRouter.Get(nID)
    if not funCfg then return end

    local tbRetInfo = {
        bUnlock = false, ---是否解锁
        nReddotNum = 0, --- 红点数量
    }

    local bOk, _ = FunctionRouter.IsOpenById(nID)
    if bOk then
        tbRetInfo.bUnlock = true
        if FunctionRouter.tbIsShowRedDotFun[nID] and FunctionRouter.tbIsShowRedDotFun[nID]() then
            tbRetInfo.nReddotNum = 1
        end
    end
    return tbRetInfo
end


---跳转
---@param nID FunctionType 功能ID
function FunctionRouter.GoTo(nID, ...)
    local param = {...}
    local fAction = function()
        local funCfg = FunctionRouter.Get(nID)
        if not funCfg then return end
        if funCfg.sUI == nil or funCfg.sUI == '' then return end

        ---TODO 条件检查
        local bOk, tbDesc = FunctionRouter.IsOpenById(nID)
        if not bOk then
            return UI.ShowMessage(tbDesc[1])
        end
        if #param == 0 then
            param = funCfg.tbParams
        end

        if nID == FunctionType.Mall then --商城强制检查
            IBLogic.OpenMallUI(table.unpack(param))
            return
        end

        UI.Open(funCfg.sUI, table.unpack(param))
    end

    fAction()
end

function FunctionRouter.GoToByUIName(sUIName, ...)
    for nId, tbInfo in pairs(FunctionRouter.tbFunc) do
        if tbInfo.sUI == sUIName then
            FunctionRouter.GoTo(nId, ...)
        end
    end
end

function FunctionRouter.CheckEx(nId, fSucExe)
    local bUnlock, tbTip = FunctionRouter.IsOpenById(nId)
    if not bUnlock then
        UI.ShowTip(tbTip[1] or '')
        return
    end
    if fSucExe then fSucExe() end
end


---获取功能配置
function FunctionRouter.Get(nID)
    return FunctionRouter.tbFunc[nID]
end

---获取是否满足开放条件
function FunctionRouter.IsOpen(tbCondition)
    if not tbCondition or type(tbCondition) ~= "table" then
        return true
    end
    local bUnlock, tbDes = Condition.Check(tbCondition)
    return bUnlock, tbDes
end

---活动是否打开
---@param InId 活动ID
---@return boolean 是否打开
---@return table 提示消息
function FunctionRouter.IsOpenById(InId)
    if InId == FunctionType.TimeActivitie then 
        local tbOpen = Online.GetAllOpenList()
        if not tbOpen or CountTB(tbOpen) == 0 then 
            return false, {'ui.TxtOnlineEvent10'}
        end
    end


    local tbCfg = FunctionRouter.Get(InId)
    if not tbCfg then
        return false
    end
    if not tbCfg.tbCondition or type(tbCfg.tbCondition) ~= "table" then
        return true
    end
    local bUnlock, _ = Condition.Check(tbCfg.tbCondition)
    return bUnlock, {Text(tbCfg.sTip)}
end

---是否能显示红点
---@param funCfg table 配置
---@return boolean 能显示红点
function FunctionRouter.IsShowRedDot(funCfg)
    if not funCfg or not FunctionRouter.IsOpen(funCfg.tbCondition) then
        return false
    end
    if FunctionRouter.tbIsShowRedDotFun[funCfg.nID] then
        return FunctionRouter.tbIsShowRedDotFun[funCfg.nID]()
    end
    return false
end

--防止任务面板一键领取，多次弹升级界面，
--增加bSkip，默认判定"Achievement" 界面行为
function FunctionRouter.ShowLevelUpTip(nNewLevel, nOldLevel, bSkip)
    if not bSkip then
        if UI.IsOpen("Achievement") then
            return
        end
    end

    UI.Open('LevelUp', nOldLevel, nNewLevel)
    FunctionRouter.nCacheLevel = nNewLevel
end

---更新功能开放列表&显示功能开放提示
function FunctionRouter.UpdateOpenFunction()
    local fUnLockTip = function()
        local tbNewOpen = {}
        for _, info in pairs(FunctionRouter.tbFunc or {}) do
            local nType = info.nID
            local cfg = FunctionRouter.Get(nType)
            if cfg and cfg.sUnlocktip and cfg.sUnlocktip ~= '' and not FunctionRouter.tbOpened[nType] then
                local bUnlock, _ = FunctionRouter.IsOpenById(nType)
                if bUnlock then
                    FunctionRouter.tbOpened[nType] = true
                    table.insert(tbNewOpen, nType)
                end
            end
        end
        if #tbNewOpen > 0 then
            UI.Open('SystemUnlock', tbNewOpen)
        end
    end


    local nNewLevel = me:Level()
    local nOldLevel = FunctionRouter.nCacheLevel or nNewLevel
    
    ---是否升级提示
    if nOldLevel < nNewLevel then
        UI.Open('LevelUp', nOldLevel, nNewLevel, fUnLockTip)
    else
        fUnLockTip()
    end
    FunctionRouter.nCacheLevel = nNewLevel
end

---登录缓存功能开放数据
EventSystem.On(Event.Logined, function()
    if not me then return end
    FunctionRouter.tbOpened = {}

    for _, info in pairs(FunctionRouter.tbFunc or {}) do
        local nType = info.nID
        local bUnlock, _ = FunctionRouter.IsOpenById(nType)
        if bUnlock then
            FunctionRouter.tbOpened[nType] = true
        end
    end
end)


--[[
    配置
]]
function FunctionRouter.LoadCfg()
    local tbInfo = LoadCsv("function/function.txt", 1)
    for _, tbLine in ipairs(tbInfo) do
        local nID = tonumber(tbLine.id) or 0;
        FunctionRouter.tbFunc[nID] = {
            nID         = nID,
            sName       = tbLine.name or '',
            nIcon       = tonumber(tbLine.icon) or 0,
            tbCondition = Eval(tbLine.condition) or {},
            sTip        = tbLine.tip or "ui.TxtNotOpen",
            sUI         = tbLine.ui,
            tbParams    = Eval(tbLine.params) or {},
            sUnlocktip  = tbLine.unlocktip,
            nUnlockpic  = tonumber(tbLine.unlockpic) or 0,
        }
    end
end

--------一些特殊解锁判定--------------
function FunctionRouter.CheckBreakSkillsUnLock()
    if not me or not RunFromEntry then
        return true
    else
        return FunctionRouter.IsOpenById(25)
    end
end



--- 元素爆发是否开启
function FunctionRouter.IsOpenElemExplosion()
    if me and me:IsOfflineLogin() then
        return true
    end
    local bUnlock, Tip = FunctionRouter.IsOpenById(FunctionType.ElemExplosion)
    return bUnlock
end
------------------------------------

--------DS使用--------------
--元素爆发 task
function FunctionRouter.GetOpenElemExplosionTask()
    local tbCfg = FunctionRouter.Get(FunctionType.ElemExplosion)
    if not tbCfg or type(tbCfg.tbCondition) ~= "table" then
        return
    end

    local nGroup, nTask = Condition.GetTask(tbCfg.tbCondition)
    if nGroup and nTask then
        return nGroup,nTask
    end
end


FunctionRouter.LoadCfg()