-- ========================================================
-- @File	: Cash.lua
-- @Brief	: 代币信息相关接口
-- ========================================================

Cash = Cash or {}
---存放代币信息的自定义属性GroupId
Cash.GroupId = 1

--货币类型枚举
Cash.MoneyType_Money = 1 --比特金
Cash.MoneyType_Gold = 2 --数据金
Cash.MoneyType_Silver = 3 --通用银
Cash.MoneyType_Vigour = 4 --体力
Cash.MoneyType_TOKEN = 5 --雪之形
Cash.MoneyType_PayGold = 8 --付费数据金
Cash.MoneyType_RMB = 100 --人民币

---加载配置
function Cash.LoadConf()
    Cash.tbMoneyCfg = {}

    local tbFile = LoadCsv("cash/cash.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID) or 0
        local tbInfo = {
            nId = nId,
            sName = tbLine.Name,
            sDesc = tbLine.Desc,
            sUse = tbLine.Use,
            nIcon = tonumber(tbLine.Icon),
            nColor = tonumber(tbLine.Color)
        }
        if tbLine.GDPL and string.len(tbLine.GDPL) > 0 then
            tbInfo.tbItem = {}
            for n in string.gmatch(tbLine.GDPL, "[%d]*") do
                table.insert(tbInfo.tbItem, tonumber(n))
            end
        end
        Cash.tbMoneyCfg[nId] = tbInfo
    end
end

---获取代币数量
---@param nId int 代币Id
---@return int 拥有数量
function Cash.GetMoneyCount(nId)
    if nId == Cash.MoneyType_Money then
        return Cash.HasMoney()
    elseif nId == Cash.MoneyType_Vigour then
        return me:Vigor()
    else
        return me:GetAttributeSigned(Cash.GroupId, nId * 2 + 1)
    end
end

---获取代币配置信息
---@param nId int 代币Id
---@return table 代币配置信息
function Cash.GetMoneyCfgInfo(nId)
    if not nId then
        return nil
    end
    return Cash.tbMoneyCfg[nId]
end

---获取代币信息
---@param nId int 代币Id
---@return string,string,int 代币图标，名字，拥有数量
function Cash.GetMoneyInfo(nId)
    local tbCfg = Cash.tbMoneyCfg[nId]
    if tbCfg then
        return tbCfg.nIcon, tbCfg.sName, Cash.GetMoneyCount(nId)
    end
end

---检查指定代币是否足够，不够时呼出置换选项
---@param nCashID int 代币Id
---@param nNeedMoney int 需要的数量
---@param funIfenough function 货币充足的情况下的回调
---@return boolean 数量是否足够
function Cash.CheckMoney(nCashID, nNeedMoney, funIfenough)
    if nCashID == Cash.MoneyType_Money and not Cash.CheckCanDo() then
        UI.ShowTip(Text("tip.Cost_Limit_Money"))
        return false
    end

    if nCashID == Cash.MoneyType_RMB or Cash.GetMoneyCount(nCashID) >= nNeedMoney then
        if funIfenough then
            funIfenough()
        end
        return true
    end

    --- 留存测屏蔽比特金兑换数据金
    -- if nCashID == Cash.MoneyType_Gold then
    --     UI.ShowTip(Text("tip.cash_not_enough"))
    --     return false
    -- end

    if not CashExchange.CanExchange(nCashID) then
        UI.ShowTip(Text("tip.cash_not_enough"))
        return false
    end

    local tbExchangeInfo = CashExchange.GetInfo[nCashID] and CashExchange.GetInfo[nCashID](nNeedMoney)
    if not tbExchangeInfo then
        UI.ShowTip(Text("tip.cash_not_enough"))
        return false
    end

    local sCashName = Text(Cash.GetMoneyCfgInfo(nCashID).sName)
    local sExchangeName = Text(Cash.GetMoneyCfgInfo(tbExchangeInfo.tbExchange.nCashID).sName)
    UI.Open(
        "MessageBox",
        string.format(Text("tip.need_exchange"), sCashName, tbExchangeInfo.tbExchange.nCount, sExchangeName),
        function()
            CashExchange.ShowUIExchange(nCashID, nNeedMoney - Cash.GetMoneyCount(nCashID))
        end
    )

    return false
end

---比特金限制行为
function Cash.CheckCanDo()
    return Cash.HasMoney() >= IBLogic.LimitBuy
end

--计算比特金数量
function Cash.HasMoney()
    if not me then return 0 end

    local sRechargeChannel = string.format("%s.%s", me:Channel(), me:SubChannel())
    local tbChannelList = Cash.GetMixChannelConf(sRechargeChannel)
    if not tbChannelList or #tbChannelList == 0 then
        return me:GetMoney(sRechargeChannel)
    end

    local nAll = 0
    for _,v in ipairs(tbChannelList) do
        nAll = nAll + me:GetMoney(v)
    end

    return nAll
end

-----渠道相关
---混合使用渠道配置
function Cash.LoadMixChannelConf()
    Cash.tbChannelConf = {};

    local tbFile = LoadCsv('cash/mixchannel.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nId       = tonumber(tbLine.Id) or 0;
        local tbRechargeChannel = Eval(tbLine.RechargeChannel) or {}
        local nCoverage = tonumber(tbLine.Coverage)
        if nId > 0 and #tbRechargeChannel > 0 and CheckCoverage(nCoverage) then
            for i,v in ipairs(tbRechargeChannel) do
                if type(v) == "string" and #v > 0 then
                    Cash.tbChannelConf[v] = tbRechargeChannel
                end
            end
        end
    end

    print('Load ../settings/cash/mixchannel.txt');
end

function Cash.GetMixChannelConf(sChannel)
    if not sChannel then return end

    return Cash.tbChannelConf[sChannel]
end

Cash.LoadConf()
Cash.LoadMixChannelConf()
