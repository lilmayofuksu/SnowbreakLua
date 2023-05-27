-- ========================================================
-- @File    : Gacha.lua
-- @Brief   : 扭蛋
-- ========================================================
---@class Gacha 扭蛋逻辑
---@field tbGacha table 扭蛋配置
---@field tbPool table 蛋池配置列表
---@field tbRarity table 稀有度对应的概率
---@field tbExistsItem table<number, table<string, table>> 抽奖之前已经存在的道具，作抽奖结果表现用
---@field tbWeaponExtra table 武器额外赠送配置
---@field bDisableInput boolean 是否禁止输入
Gacha = Gacha or { tbGacha = {}, tbPool = {}, tbRarity = {}, tbExistsItem = {}, tbResult = nil, tbWeaponExtra = {}, bDisableInput = false}

require('Gacha.GachaTest')

----扭蛋存储GID
Gacha.GID = 5
---总抽奖次数
Gacha.SID_TOTAL_TIME = 1

---单日总抽奖次数
Gacha.SID_DAILY_TOTAL_TIME = 2

---每个扭蛋ID存储间隔
Gacha.INTERVAL = 10

---继承保底次数记录开始ID
Gacha.SID_TIME_INHERIT_START = 20000
---没有继承保底次数记录开始ID
Gacha.SID_TIME_NOT_INHERIT_START = 10

---物品计数
Gacha.SID_ADD_TIME_ITEM  = 1
---第十抽概率计数
Gacha.SID_ADD_TIME_PROB  = 2
---保底类型标记 1 小保底 2 大保底
Gacha.SID_ADD_PROTECT_TYPE  = 3

---大保底计数
Gacha.SID_ADD_BIGGUARANTERTIME_ITEM = 4
---小保底计数
Gacha.SID_ADD_SMALLGUARANTERTIME_ITEM = 5
---是否触发了首次保底
Gacha.SID_ADD_FIRST_TRIGGERED = 6 --弃用
---池子总抽奖次数
Gacha.SID_ADD_TOTAL_TIME = 7

---抽奖记录
Gacha.RecordField = "GACHA_%s"




--------------
---扭蛋字符存储 GID
Gacha.SGID = 42

---指定UP道具存储索引
Gacha.S_UP_SELECT = 1

---指定UP道具必得标记存储索引
Gacha.S_UP_SELECT_GET_FLAG = 2


---获取视频路劲
function Gacha.GetMediaPath(sMediaName)
    local sPlatformName = UE4.UGameplayStatics.GetPlatformName()
    return string.format('./Movies/_mp4/%s/gacha/%s.mp4', sPlatformName, sMediaName)
end


function Gacha.Print(nId)
    nId = nId or 1
    local cfg = Gacha.GetCfg(nId)
    print('首次触发状态:', cfg:GetValue(Gacha.SID_ADD_FIRST_TRIGGERED))

    print('指定UP信息:', json.encode(cfg:GetStrValue()))
end


---抽卡调试使用
s2c.Register('Gacha_Launch_Gm', function(tbData)
    local allNum = tbData.allNum
    local pUI = UI.GetUI('GachaGM')
    if not pUI then
        UI.Open('GachaGM')
        pUI = UI.GetUI('GachaGM')
    end
    pUI:SetData({tbRarity = tbData.tbRarity, tbItem = tbData.tbItem, allNum = allNum})
end)

s2c.Register('Gacha_Rsp', function(tbData)
    local sCode = json.encode(tbData)
    print('Gacha_Rsp ==== > ', sCode)
end)

function Gacha.ShowCircle()
    UI.Call2('GachaTap', 'UpdateCircle', true)
end

function Gacha.HideCircle()
    UI.Call2('GachaTap', 'UpdateCircle', false)
end


function Gacha.ShowUI()
    UI.Call2('GachaTap', 'ShowUI')
end

function Gacha.PlayCircle()
    UI.Call2('GachaTap', 'PlayCircle')
end

---抽卡点位获取显示特效索引
function Gacha.GetEffectIndex(sIdx)
    local pUI = UI.GetUI('GachaTap')
    if not pUI then return -1 end
    return pUI:GetEffectIndex(sIdx)
end

---获取抽奖类型
function Gacha.GetLaunchType()
    if not Gacha.tbResult then return 0 end
    return #Gacha.tbResult == 1 and 0 or 1
end

---获取记录IDs
function Gacha.GetRecordIDs(nId)
    local cfg = Gacha.GetCfg(nId)
    if (not cfg) or (not cfg.nProtectTag) then return {nId} end
    
    local tbID = {}

    for id, info in pairs(Gacha.tbGacha or {}) do
        if info.nProtectTag == cfg.nProtectTag  then
            table.insert(tbID, id)
        end
    end
    return tbID
end


function Gacha.PullOpenTime()
    if Gacha.bReqOpenTime then
        return
    end
    Gacha.bReqOpenTime = true
    me:CallGS('Gacha_GetOpenTime', {})
end


---获取抽卡是否提示
function Gacha.GetIsTip()
    return UE4.UUserSetting.GetBool('GachaTip', true)
end

---开关抽卡是否提示
function Gacha.SetIsTip(bTip)
    UE4.UUserSetting.SetBool('GachaTip', bTip)
    return bTip
end

---获取兑换信息
function Gacha.GetExchangeInfo(tbGDPL)
    local g, d, p, l, nNeedItem = table.unpack(tbGDPL)
    local nHave = me:GetItemCount(g, d, p, l)
    local exchangeInfo = Item.tbExchange[string.format("%s-%s-%s-%s", g, d, p, l)]
    if not exchangeInfo then return end
    local cashId, nRatio =  exchangeInfo.tbCash[1],  exchangeInfo.tbCash[2]
    local nNeedGold = (nNeedItem - nHave) * nRatio
    local icon , _ , nHaveGold = Cash.GetMoneyInfo(cashId)
    return nNeedItem, nNeedGold, nHaveGold, cashId, icon
end

---缓存所关心的已有道具列表
function Gacha.DoCacheExists()
    -- 缓存已存在的角色卡
    local pCardList = UE4.TArray(UE4.UItem)
    me:GetItemsByType(UE4.EItemType.CharacterCard, pCardList)
    local tbCards = {}
    for i = 1, pCardList:Length() do
        local pItem = pCardList:Get(i)
        if not pItem:IsTrial() then
            local sGDPL = string.format("%d-%d-%d-%d", pItem:Genre(), pItem:Detail(), pItem:Particular(), pItem:Level())
            tbCards[sGDPL] = {
                nCount = pItem:Count()
            }
        end
    end
    Gacha.tbExistsItem[UE4.EItemType.CharacterCard] = tbCards
end

---清除已有道具列表的缓存
function Gacha.CleanCacheExists()
    Gacha.tbExistsItem = {}
end

---------------------------------------

local nReq_LaunchIdx = 3

---请求抽奖
---@param nId Integer 蛋池Id
---@param nTime Integer 数量
function Gacha.Req_Launch(nId, nTime)
    if not Cash.CheckCanDo() then
        UI.ShowTip(Text("tip.Cost_Limit_Money"))
        return
    end

    if Gacha.bDisableInput then return end

    local cfg = Gacha.GetCfg(nId)
    print('Gacha.Req_Launch:', nId, nTime)
    local bCan, _ = cfg:CheckCost(nTime)
    if not bCan then return  end
    local tbCmd = {nId = nId,  nTime = nTime,}
    UI.ShowConnection()
    Gacha.bDisableInput = true
    Gacha.bCurIsNewPool = (cfg:IsNewPool())
    me:CallGS('Gacha_Launch', json.encode(tbCmd))
    nReq_LaunchIdx = nReq_LaunchIdx + 1
end

s2c.Register('Gacha_Launch', function(tbRsp)

    Gacha.bDisableInput = false
    UI.CloseConnection()

    nReq_LaunchIdx = nReq_LaunchIdx - 1

    if nReq_LaunchIdx < 3 then
        return
    end

    if tbRsp.sErr then  UI.ShowTip(tbRsp.sErr) return end
    if tbRsp.tbAwards then
        UI.Call2('Gacha', "LaunchRsp", tbRsp.tbAwards)
        --
        EventSystem.TriggerTarget(
            Survey,
            Survey.PRE_SURVEY_EVENT,
            Survey.GACHA,
            tbRsp.tbAwards,
            tbRsp.tbTrigger
        )
    end
    if Gacha.bCurIsNewPool then EventSystem.Trigger(Event.BannerCheck) end
end)

---请求选择UP
function Gacha.Req_UpSelect(nId, gdpl)
    if not nId or not gdpl then return end
    UI.ShowConnection()
    local cmd = { nId = nId,  gdpl = gdpl }
    local sCmd = json.encode(cmd)
    print('Gacha.Req_UpSelect', sCmd)
    me:CallGS('Gacha_UpSelect', sCmd)
end

s2c.Register('Gacha_UpSelect', function(tbRsp)
    UI.CloseConnection()
    if tbRsp.sErr then UI.ShowTip(tbRsp.sErr) return end
    UI.Call2('UpSelect', 'OnSelectRsp')
end)

s2c.Register('Gacha_GetOpenTime', function(tbRsp)
    local tbOpenTime = tbRsp.tbOpenTime
    if tbOpenTime then
        for id, info in pairs(Gacha.tbGacha or {}) do
            info.tbPoolTime = tbOpenTime[id]
        end
    end
end)


---获取扭蛋配置
---@param nId Integer 扭蛋ID
---@return GachaTemplate
function Gacha.GetCfg(nId)
    return Gacha.tbGacha[nId]
end

---获取蛋池配置
---@param sName string 蛋池配置名称
function Gacha.GetPoolCfg(sName)
    return Gacha.tbPool[sName]
end

---获取蛋池稀有度对应的配置
---@param nRarity Integer 稀有度
---@return GachaRarityTemplate
function Gacha.GetPoolRarityCfg(nRarity)
    return Gacha.tbRarity[nRarity]
end


---获取UP道具
function Gacha.GetUps(cfg)
    local tbShow = {}
    if not cfg then return tbShow end
    for _, sPool in ipairs(cfg.tbPool) do
        local tbCfg = Gacha.GetPoolCfg(sPool)
        for _, tb in pairs(tbCfg) do
            if tb.nUPSelectTag == 1 then
                table.insert(tbShow, tb.tbGDPL)
            end
        end
    end
    table.sort(tbShow, function(a, b) return a[3] > b[3] end)
    return tbShow
end



---提审版本做法 取单个蛋池最大数量
---获取单日最大限制次数
function Gacha.Check_GetDailyMaxLimit()
    local nMax = 0
    for _, cfg in pairs(Gacha.tbGacha or {}) do
        if nMax < cfg.nDailyTimeLimit then
            nMax = cfg.nDailyTimeLimit
        end
    end
    return nMax
end

---获取每日累计计数
function Gacha.Check_GetDailyTotalTime()
    return me:GetAttribute(Gacha.GID, Gacha.SID_DAILY_TOTAL_TIME)
end

---获取每日剩余次数
function Gacha.Check_GetDailyLeftTime()
    local nMaxTime = Gacha.Check_GetDailyMaxLimit()
    if nMaxTime <= 0 then return 0 end
    return nMaxTime - Gacha.Check_GetDailyTotalTime()
end


--[[
    加载扭蛋配置  
]]

---@class GachaTemplate 抽奖模板
---@field nId               Integer     ID
---@field tbCastOne         table       单抽价格{{g,d,p,l,n}}
---@field tbCastTen         table       十连价格{{g,d,p,l,n}}
---@field tbPool            table       具体蛋池内容配置{表名，表名}
---@field tbProtectNum      table       保底必得{{抽卡次数,{{表名,稀有度,（具体序号）},{表名,稀有度,（具体序号）}...}},{抽卡次数,{{表名,稀有度,（具体序号）},{表名,稀有度,（具体序号）}...}}}
---@field tbProtectNumLimit table       限制次数保底{{抽卡次数,{{表名,稀有度,（具体序号）},{表名,稀有度,（具体序号）}...},限制次数},{抽卡次数,{{表名,稀有度,（具体序号）},{表名,稀有度,（具体序号）}...},限制次数}}
---@field nProtectTag       Integer     保底继承序列
---@field tbPoolTime        table       蛋池限定时间
---@field nProbability      Integer     概率
---@field tbProtectCount    table       十连重置标记{{表名,稀有度,（具体序号）},{表名,稀有度,（具体序号）}...}
---@field nProbabilityTen   Integer     第十抽保底概率
local GachaTemplate = {
    ---是否继承计数
    __IsInheritTime = function(self)
        return self.nProtectTag ~= nil
    end,

    ---继承保存起始ID
    __GetInheritSaveID = function(self)
        return Gacha.SID_TIME_INHERIT_START + self.nProtectTag * Gacha.INTERVAL
    end,

    ---无继承保存起始ID
    __GetNotInheritSaveID = function(self)
        return Gacha.SID_TIME_NOT_INHERIT_START + self.nId * Gacha.INTERVAL
    end,

    ---输出保存ID
    PrintSaveID = function(self)
        print('是否继承', self:__IsInheritTime())
        print(self:GetValue(Gacha.SID_ADD_TIME_ITEM), self:GetValue(Gacha.SID_ADD_PROTECT_TYPE), self:GetValue(Gacha.SID_ADD_TIME_PROB))
    end,

    ---获取保存的数据
    GetValue = function(self, sid)
        if self:__IsInheritTime() then
            return me:GetAttribute(Gacha.GID, self:__GetInheritSaveID() + sid)
        else
            return me:GetAttribute(Gacha.GID, self:__GetNotInheritSaveID() + sid)
        end
    end,

    ---获取字符保存数据
    GetStrValue = function(self)
        local sAttr = me:GetStrAttribute(Gacha.SGID, self.nId)
        if not sAttr then return nil end
        return json.decode(sAttr)
    end,

    ---获取字符指定索引保存数据
    GetStrValueByIndex = function(self, nIndex)
        local sAttr = me:GetStrAttribute(Gacha.SGID, self.nId)
        if not sAttr then return nil end
        local tbInfo = json.decode(sAttr)
        if not tbInfo then return nil end
        return tbInfo[nIndex]
    end,

    ---是否新手池
    IsNewPool = function(self)
        return self.nType == 0
    end,

    ---获取触发保底次数
    GetProtectNum = function(self)
        local nTime = self:GetTime()
        return (self.tbProtectNum[1][1] or 100) - nTime
    end,

    GetSureTriggerNum = function(self)
        return self.tbProtectNum[1][1] or 100
    end,

    ---获取累计抽奖次数
    GetTotalTime = function(self)
        return self:GetValue(Gacha.SID_ADD_TOTAL_TIME) or 0
    end,

    ---获取保底类型
    GetProtectType = function(self)
        local nType = self:GetValue(Gacha.SID_ADD_PROTECT_TYPE)
        return nType > 0 and nType or 1
    end,

    ---获取保底计数
    GetTime = function(self)
        return self:GetValue(Gacha.SID_ADD_TIME_ITEM) or 0
    end,

    ---获取十抽计数
    GetTenTime = function(self)
        return self:GetValue(Gacha.SID_ADD_TIME_PROB) or 0
    end,

    ---是否在抽奖时间范围
    IsInTime = function(self)
        if not self.tbPoolTime then  return false end ---服务器时间不对， 不开放
        return IsInTime(ParseTime(self.tbPoolTime[1]), ParseTime(self.tbPoolTime[2]), GetTime())
    end,

    ---蛋池是否开放
    IsOpen = function(self)
        if not self:IsInTime() then return false end
        if self:IsNewPool() then
            local nTotalTime = self:GetTotalTime()
            if nTotalTime >= self.nFreshmanTime then
                return false
            end
        end
        return true
    end,

    ---是否开启UP选择功能
    IsOpenUpSelect = function(self)
        return self.nUpSelectFlag == 1
    end,

    ---获取选择的UP
    GetSelectUp = function(self)
        return self:GetStrValueByIndex(Gacha.S_UP_SELECT)
    end,

    ---获取时间描述
    GetOpenTimeStr = function(self)
        if not self.tbPoolTime then  return '' end
        return string.format("%s-%s", os.date("%Y.%m.%d", ParseTime(self.tbPoolTime[1])), os.date("%Y.%m.%d", ParseTime(self.tbPoolTime[2])))
    end,

    ---根据抽奖次数检查材料 返回成功 和 材料
    CheckCost = function(self, nTime)
        local tbCost = nTime == 1 and self.tbCastOne or self.tbCastTen
        if not tbCost then return false, nil end
        local tbTemp = nil
        ---优先使用后面的材料
        for _, tbGDPLN in ipairs(tbCost) do
            local g, d, p, l, n = table.unpack(tbGDPLN)
            local nHave = me:GetItemCount(g, d, p, l)
            if nHave >= n then
                tbTemp = tbGDPLN
            end
        end
        if tbTemp then
            return true, tbTemp
        else
            return false, tbCost[1]
        end
    end,
}

function Gacha.LoadCfg()
    local tbFile = LoadCsv('gacha/gacha.txt', 1);   
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID) or -1;
        if nId >= 0 then
            local nCoverage = tonumber(tbLine.Coverage) or 0
            local bOk = true --CheckCoverage(nCoverage)
            if bOk then
                local tbInfo = {
                    Logic               = GachaTemplate,
    
                    nId                 = nId,
                    tbTag               = Eval(tbLine.Tag),
                    nType               = tonumber(tbLine.Type),
                    nCoverage           = nCoverage,
                    nIndex              = tonumber(tbLine.Index) or 0,
                    sDes                = tbLine.Desc,
                    nTagUI              = tonumber(tbLine.TagUI),
                    nPoolUI             = tonumber(tbLine.PoolUI),

                    nTimeBan            = tonumber(tbLine.TimeBan) or 0,
   
                    tbCastOne           = Eval(tbLine.CastOne),                
                    tbCastTen           = Eval(tbLine.CastTen),                
                  
                    tbPool              = Eval(tbLine.Pool) or {},             
                    tbProtectNum        = Eval(tbLine.ProtectNum) or {},        
                    tbProtectNumLimit   = Eval(tbLine.ProtectNumLimit) or {},   
                    nProtectTag         = tonumber(tbLine.ProtectTag),       
                    tbPoolTime          = Eval(tbLine.PoolTime),             
                    nProbability        = tonumber(tbLine.Probability),        
                    tbProtectCount      = Eval(tbLine.ProtectCount),           
                    nProbabilityTen     = tonumber(tbLine.ProbabilityTen),
                    nDailyTimeLimit     = tonumber(tbLine.DailyTimeLimit) or 0,

                    tbTenProAdd         = Eval(tbLine.TenProAdd),
                    tbProtectProAdd     = Eval(tbLine.ProtectProAdd), 
                    tbAssignItem        = Eval(tbLine.AssignItem),  --指定物品
                    tbDetail            = Eval(tbLine.detail),

                    tbResourceInfo      = Eval(tbLine.ShowResource),
                    nUpSelectFlag       = tonumber(tbLine.UpSelect) or 0,
                    tbUIPro             = Eval(tbLine.UIPro) or {},
                    nFreshmanTime       = tonumber(tbLine.FreshmanTime) or 0 --新手池抽取上限次数
                }
    
                setmetatable(tbInfo, {
                    __index = function(tb, key)
                        local v = rawget(tb, key);
                        return v or tb.Logic[key];
                    end
                });
                Gacha.tbGacha[nId] = tbInfo
            end
        end
    end
    print('load ../settings/gacha/gacha.txt')
    --[[
        加载蛋池配置
        序号	备注	抽卡稀有度	GDPL	权重	UP标记（1为UP，2为New)
    ]]
    local fLoadPoolCfg = function(sName)
        if Gacha.tbPool[sName] then
            return
        end
        Gacha.tbPool[sName] =  Gacha.tbPool[sName] or {}
        local sFilePath = string.format('gacha/pool/%s.txt', sName)
        local tbFile = LoadCsv(sFilePath, 1)
        for _, tbLine in ipairs(tbFile) do
            local nId = tonumber(tbLine.ID) or 0
            Gacha.tbPool[sName][nId] = {
                nRarity     = tonumber(tbLine.Rarity),
                tbGDPL      = Eval(tbLine.GDPL),
                nWeight     = tonumber(tbLine.Weight),
                nUpTag     = tonumber(tbLine.UPTag),
                nUPSelectTag = tonumber(tbLine.UPSelectTag) or 0,
            }
        end
        print('load', sFilePath)
    end
    for _, tbInfo in pairs(Gacha.tbGacha) do
        for _, sPoolName in ipairs(tbInfo.tbPool or {}) do
            fLoadPoolCfg(sPoolName)
        end
    end

     ---加载武器额外产出代币
     local tbFile = LoadCsv('gacha/weapon_extra.txt', 1);
     for _, tbLine in ipairs(tbFile) do
         local nColor =  tonumber(tbLine.Color)
         Gacha.tbWeaponExtra[nColor] = Eval(tbLine.Extra) or {}
     end
     print('load gacha/weapon_extra.txt')
end

--[[
    加载稀有度概率配置
    ID	稀有度1概率	稀有度2概率	稀有度3概率	稀有度4概率	稀有度5概率	稀有度6概率
]]
function Gacha.LoadProbabilityCfg()
    local tbFile = LoadCsv('gacha/probability.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID);
        if nId >= 0 then
            local tbInfo = {}
            local nSum = 0
            tbInfo.tbRarity = {}
            for i = 1, 6 do
                tbInfo.tbRarity[i] = tonumber(tbLine['Rarity' .. i]) or 0
                nSum = nSum +  tbInfo.tbRarity[i]
            end
            tbInfo.nSumWeight = nSum
            Gacha.tbRarity[nId] = tbInfo
        end
    end
    print('load ../settings/gacha/probability.txt')
end


--[[
    执行配置加载
]]
Gacha.LoadCfg()
Gacha.LoadProbabilityCfg()


EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    Gacha.bDisableInput = false
    if bReconnected then return end
    Gacha.SetIsTip(true)
end)


