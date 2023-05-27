-- ========================================================
-- @File    : VigourSupply.lua
-- @Brief   : 两餐体力补给活动相关接口
-- ========================================================

VigourSupply = VigourSupply or{}

VigourSupply.GID = 105
--领取体力
VigourSupply.EventReceiveVigour = "ON_Receive_Vigour"
--0：存下次重置的时间 当天晚上12点
--1：存领取情况

--配置信息
function VigourSupply.LoadConfig()
    VigourSupply.tbVigourSupplyCfg = {}
    local tbFile = LoadCsv('activity/vigour_supply/vigour_supply.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.Id);
        if nId then
            local tbInfo    = {
                nId             = nId,
                sTitle          = tbLine.Title,
                sTimeStart      = string.sub(tbLine.TimeStart or '', 2, -2),
                sTimeEnd        = string.sub(tbLine.TimeEnd or '', 2, -2),
                nVigourNum      = tonumber(tbLine.VigourNum) or 0,
            };
            VigourSupply.tbVigourSupplyCfg[nId] = tbInfo;
        end
    end
    print('Load activity/vigour_supply/vigour_supply.txt')
end

---获取配置信息
function VigourSupply.GetVigourSupplyCfg(ID)
    if not ID then
        return nil
    end
    return VigourSupply.tbVigourSupplyCfg[ID]
end

---检查是否已经领取
function VigourSupply.IsReceive(ID)
    local v = me:GetAttribute(VigourSupply.GID, 1)
    return GetBits(v, ID, ID) > 0
end

---获取下次刷新时间
function VigourSupply.GetNextRefreshTime()
    return me:GetAttribute(VigourSupply.GID, 0)
end

---检查是否有可领取的体力
function VigourSupply:CheckReceive()
    local time = GetTime()
    for _, cfg in pairs(VigourSupply.tbVigourSupplyCfg) do
        if not VigourSupply.IsReceive(cfg.nId) and IsInTime(ParseBriefTime(cfg.sTimeStart), ParseBriefTime(cfg.sTimeEnd), time) then
            return true
        end
    end
    return false
end

---检查是否刷新领取 每天24：00刷新
function VigourSupply.CheckRefresh(funBack)
    VigourSupply.CheckRefreshFunBack = funBack
    UI.ShowConnection()
    me:CallGS("VigourSupply_CheckRefresh")
end
s2c.Register('VigourSupply_CheckRefresh',function()
    UI.CloseConnection()
    if VigourSupply.CheckRefreshFunBack then
        VigourSupply.CheckRefreshFunBack()
        VigourSupply.CheckRefreshFunBack = nil
    end
end)

---领取
function VigourSupply.ReceiveVigour(nId, funBack)
    VigourSupply.ReceiveVigourFunBack = funBack
    UI.ShowConnection()
    me:CallGS("VigourSupply_ReceiveVigour", json.encode({nId = nId}))
end
s2c.Register('VigourSupply_ReceiveVigour',function(tbParam)
    UI.CloseConnection()
    if VigourSupply.ReceiveVigourFunBack then
        VigourSupply.ReceiveVigourFunBack()
        VigourSupply.ReceiveVigourFunBack = nil
    end
    if tbParam and #tbParam >= 2 then
        UI.Open("GainItem", {tbParam})
    end
    EventSystem.TriggerTarget(VigourSupply, VigourSupply.EventReceiveVigour)
end)

VigourSupply.LoadConfig()

return VigourSupply
