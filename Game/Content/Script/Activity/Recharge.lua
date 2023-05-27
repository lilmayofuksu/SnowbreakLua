-- ========================================================
-- @File    : Recharge.lua
-- @Brief   : 充值返还活动
-- ========================================================

RechargeLogic = RechargeLogic or {};

--活动自定义数据存储信息
--1号位 存储 是否已经领取
RechargeLogic.Award_TaskId = 1

---加载配置
function RechargeLogic.LoadConf()
    RechargeLogic.tbRechargeConf = {}
    local tbPreInfo = nil
    local tbFile = LoadCsv('activity/recharge/recharge.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nNum = tonumber(tbLine.Num)
        if nNum and nNum >= 0 then
            local tbInfo = {
                nNum        = nNum,
                nMaxNum  = nPreNum,
                nMoney = tonumber(tbLine.MoneyProportion) or 0,
                nGold = tonumber(tbLine.GoldProportion) or 0,
            }

            if tbPreInfo then
                tbPreInfo.nMaxNum = nNum
            end
            tbPreInfo = tbInfo
            table.insert(RechargeLogic.tbRechargeConf, tbInfo)
        end
    end
end

function RechargeLogic.LoadRestitutionListConf()
    RechargeLogic.tbRestitutionListConf = {}
    local tbFile = LoadCsv('activity/recharge/restitutionlist.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local sUId = tbLine.UId
        local nRecharge = tonumber(tbLine.Recharge) or 0
        if sUId and nRecharge > 0 then
            local tbInfo = {
                sUId        = sUId,
                nRecharge = nRecharge,
                tbSubchannel = Eval(tbLine.Subchannel) or {},
            }

            RechargeLogic.tbRestitutionListConf[sUId] = tbInfo
        end
    end
end

-- 获取配置信息
function RechargeLogic.GetAllConfig()
    return RechargeLogic.tbRechargeConf
end

--获取返还数据
function RechargeLogic.GetRestitutionConfig(sUId)
    if not sUId then return end

    return RechargeLogic.tbRestitutionListConf[sUId]
end

--- 获取领奖标记
---@param tbConfig table 活动配置
---@return  integer 领奖标记
function RechargeLogic.GetAwardFlag(nId)
    if not nId then return 0 end

   return Activity.GetDiyData(nId, RechargeLogic.Award_TaskId)
end

---获取充值金额
function RechargeLogic.GetRechargeNum(tbConfig)
    if not tbConfig then return 0 end

    local bRet,nRecharge = RechargeLogic.CheckShow(tbConfig)
    if bRet then
        return nRecharge or 0
    else
        return me:Charged()
    end
end

--计算奖励
function RechargeLogic.CalculationAward(nRecharge)
    nRecharge = nRecharge or 0
    local tbList = RechargeLogic.GetAllConfig()
    if not tbList then return end

    local tbAll = {0, 0}
    local nLen = #tbList
    for i=nLen,1, -1 do
        local tbConfig = tbList[i]
        if tbConfig then
            if nRecharge > tbConfig.nNum then
                local nLeft = nRecharge - tbConfig.nNum
                tbAll[1] = tbAll[1] + math.floor(nLeft * tbConfig.nMoney * 0.01)
                tbAll[2] = tbAll[2] + math.floor(nLeft * tbConfig.nGold * 0.01)
                nRecharge = tbConfig.nNum
            end
        end
    end

    return tbAll
end

--检查是否显示充值领奖
function RechargeLogic.CheckShow(tbConf)
    if not me or not tbConf then return end
    if not tbConf.tbCustomData or #tbConf.tbCustomData == 0 then return true, me:Charged() end
    if tbConf.tbCustomData[1] == 0 then return true, me:Charged() end
    if tbConf.tbCustomData[1] ~= 1 then return end

    local tbReConfig = RechargeLogic.GetRestitutionConfig(me:AccountId())
    if not tbReConfig then return end

    local sRechargeChannel = string.format("%s.%s", me:Channel(), me:SubChannel())
    for i,v in ipairs(tbReConfig.tbSubchannel) do
        if v == sRechargeChannel then
            return true, tbReConfig.nRecharge
        end
    end

    return false
end

----初始化
function RechargeLogic._OnInit()
    RechargeLogic.LoadConf()
    RechargeLogic.LoadRestitutionListConf()
end

RechargeLogic._OnInit()
return RechargeLogic
