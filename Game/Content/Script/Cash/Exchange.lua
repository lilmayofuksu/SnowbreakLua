-- ========================================================
-- @File	: Exchange.lua
-- @Brief	: 代币置换相关
-- ========================================================

---@class 货币置换
---@field tbConfig table 货币置换配置
---@field GetInfo table<number, function> 获取各货币置换信息的方法
CashExchange =
    CashExchange or
    {
        tbConfig = {},
        GetInfo = {}
    }

---获取配置
function CashExchange.LoadEchangeConfig()
    local tbVigorConfig = {}
    local tbFile = LoadCsv("cash/vigor_exchange.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nIndex = tonumber(tbLine.Times)
        local tbInfo = {
            nCost = tonumber(tbLine.Cost),
            nVigor = tonumber(tbLine.Vigor)
        }
        tbVigorConfig[nIndex] = tbInfo
        tbVigorConfig.nMax = nIndex
    end
    CashExchange.tbConfig[Cash.MoneyType_Vigour] = tbVigorConfig

    local tbSilverConfig = {}
    local tbFile = LoadCsv("cash/silver_exchange.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nIndex = tonumber(tbLine.Times)
        local tbInfo = {
            nCost = tonumber(tbLine.Cost),
            nSilver = tonumber(tbLine.Silver)
        }
        tbSilverConfig[nIndex] = tbInfo
        tbSilverConfig.nMax = nIndex
    end
    CashExchange.tbConfig[Cash.MoneyType_Silver] = tbSilverConfig

    tbFile = LoadCsv("cash/cash_exchange.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nIdx = tonumber(tbLine.BeEchanged)
        CashExchange.tbConfig[nIdx] = CashExchange.tbConfig[nIdx] or {}
        local tbCfg = {
            nCashType = tonumber(tbLine.Exchage),
            nRate = tonumber(tbLine.Rate)
        }
        table.insert(CashExchange.tbConfig[nIdx], tbCfg)
        local nShop = tonumber(tbLine.Shop)
        if nShop then
            CashExchange.tbConfig[nIdx].nShop = nShop
        end
        local nMall = tonumber(tbLine.Mall)
        if nMall then
            CashExchange.tbConfig[nIdx].nMall = nMall
        end
    end
end

CashExchange.LoadEchangeConfig()

------------------------------- 获取置换信息 ---------------------------------------------

--- 默认获取货币置换配置的方法
local function GetInfoBase(nCashType, nNeed, nExchangeCash, bMutable, funBack)
    local tbCfg = nil
    for _, tb in ipairs(CashExchange.tbConfig[nCashType]) do
        if (not nExchangeCash) or (tb.nCashType == nExchangeCash) then
            tbCfg = tb
            break
        end
    end
    if not tbCfg then
        return UI.ShowMessage("tip.exchange_invaild")
    end
    if CountTB(tbCfg) == 0 then
        return
    end
    local tbCount = {1, tbCfg.nRate}
    if nNeed then
        local nCost = nNeed // tbCfg.nRate
        if nNeed % tbCfg.nRate > 0 then
            nCost = nCost + 1
        end
        tbCount = {nCost, nCost * tbCfg.nRate}
    end
    return {
        tbExchange = {
            nCashID = tbCfg.nCashType,
            nCount = tbCount[1]
        },
        tbExhcangTarget = {
            nCashID = nCashType,
            nCount = tbCount[2]
        },
        nRate = tbCfg.nRate,
        funBack = funBack,
        bMutable = bMutable
    }
end

CashExchange.GetInfo[Cash.MoneyType_Vigour] = function(nNeed, nExchangeCash, bMutable, funBack)
    local nIndex = me:GetAttribute(70, 1) + 1
    local tbConfig = CashExchange.tbConfig[Cash.MoneyType_Vigour][nIndex]
    if not tbConfig then
        return nil
    end
    return {
        tbExchange = {
            nCashID = Cash.MoneyType_Gold,
            nCount = tbConfig.nCost
        },
        tbExhcangTarget = {
            nCashID = Cash.MoneyType_Vigour,
            nCount = tbConfig.nVigor
        },
        tbLimit = {me:GetAttribute(70, 1), CashExchange.tbConfig[Cash.MoneyType_Vigour].nMax},
        funBack = funBack
    }
end

CashExchange.GetInfo[Cash.MoneyType_Gold] = function(nNeed, nExchangeCash, bMutable, funBack)
    return GetInfoBase(Cash.MoneyType_Gold, nNeed, nExchangeCash, bMutable, funBack)
end

CashExchange.GetInfo[Cash.MoneyType_Silver] = function(nNeed, nExchangeCash, bMutable, funBack)
    local nIndex = me:GetAttribute(70, 2) + 1
    local tbConfig = CashExchange.tbConfig[Cash.MoneyType_Silver][nIndex]
    if not tbConfig then
        return nil
    end
    return {
        tbExchange = {
            nCashID = Cash.MoneyType_Gold,
            nCount = tbConfig.nCost
        },
        tbExhcangTarget = {
            nCashID = Cash.MoneyType_Silver,
            nCount = tbConfig.nSilver
        },
        tbLimit = {me:GetAttribute(70, 2), CashExchange.tbConfig[Cash.MoneyType_Silver].nMax},
        funBack = funBack
    }
end

-------------------------------- 对外接口 -------------------------------------------------

---置换货币接口
---@param nExhcangeCash number 所用置换货币
---@param nCost number 花费多少置换货币置换
---@param nExhcangTarget number 置换目标货币
---@param funBack function 置换成功后执行的函数（可选）
function CashExchange.Exchange(nExhcangeCash, nCost, nExhcangTarget, funBack)
    EventSystem.RemoveAllByTarget(CashExchange)
    if not CashExchange.tbConfig[nExhcangTarget] then
        return UI.ShowMessage("tip.exchange_invaild")
    end
    me:CallGS(
        "Cash_Exchange",
        json.encode({nExhcangeCash = nExhcangeCash, nCost = nCost, nExhcangTarget = nExhcangTarget})
    )
    UI.ShowConnection()
    CashExchange.nExchangeCallBack =
        EventSystem.OnTarget(
        CashExchange,
        "Exchange_Callback",
        function()
            if funBack then
                funBack()
            end
            UI.CloseConnection()
            EventSystem.RemoveAllByTarget(CashExchange)
        end
    )
end

---显示提示界面 提示是否置换货币
---@param nCashID integer 货币ID
---@param nNeed integer 所需数量（可选）
---@param nExchangeCash interger 用什么货币置换（可选）
---@param bImmutable boolean 是否禁止选择置换数量
---@param funBack function 置换成功后执行的函数（可选）
function CashExchange.ShowUIExchange(nCashID, nNeed, nExchangeCash, bImmutable, funBack)
    -- 跳转商店的货币置换
    if CashExchange.tbConfig[nCashID] and CashExchange.tbConfig[nCashID].nShop then
        local ui = UI.GetUI("Shop")
        if ui and ui:IsOpen() then
            ui:GotoShop(CashExchange.tbConfig[nCashID].nShop)
        else
            UI.Open("Shop", CashExchange.tbConfig[nCashID].nShop)
        end
        return
    end

    -- 跳转商城的货币置换
    if CashExchange.tbConfig[nCashID] and CashExchange.tbConfig[nCashID].nMall then
        IBLogic.GotoMall(CashExchange.tbConfig[nCashID].nMall)
        return
    end

    if not CashExchange.CanExchange(nCashID) then
        return UI.ShowMessage("tip.exchange_invaild")
    end
    local tbInfo = CashExchange.GetInfo[nCashID](nNeed, nExchangeCash, not bImmutable, funBack)
    if not tbInfo then
        return UI.ShowMessage("tip.exchange_invaild")
    end
    UI.Open("PurchaseExchange", tbInfo)
end

---判断是否可置换
---@param nCashID number 货币ID
---@return boolean 是否可兑换
function CashExchange.CanExchange(nCashID)
    return nCashID == Cash.MoneyType_Money or
        (CashExchange.tbConfig[nCashID] ~= nil) and (CashExchange.GetInfo[nCashID] ~= nil)
end

---显示提示界面 提示是否跳转界面
---@param nCashID integer 货币ID
---@param nNeed integer 所需数量（可选）
---@param funClose function 点击跳转后部分界面要关闭
---@param sTips string 提示key
function CashExchange.ShowCheckExchange(nCashID, nNeed, funClose, sKey)
    nNeed = nNeed or 0
    if Cash.GetMoneyCount(nCashID) >= nNeed then
        return true
    end

    if not CashExchange.tbConfig[nCashID] or not CashExchange.tbConfig[nCashID].nMall then 
        if sKey then
            UI.ShowTip(sKey)
        end
        return false 
    end

    -- 跳转商店的货币置换
    UI.Open("MessageBox", string.format(Text("tip.exchange_jump_mall"), Text(Cash.GetMoneyCfgInfo(nCashID).sName)),
            function() --跳转数据金商店
                if funClose then
                    funClose()
                end
                IBLogic.GotoMall(CashExchange.tbConfig[nCashID].nMall)
            end
    )

    return false
end

------------------------------------ S2C接口 -----------------------------------------------

s2c.Register(
    "Cash_Exchange",
    function(tbParam)
        EventSystem.TriggerTarget(CashExchange, "Exchange_Callback")
        UI.Open("GainItem", {{tbParam.nCashType, tbParam.nCount}})
    end
)
