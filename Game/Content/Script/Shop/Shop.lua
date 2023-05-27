-- ========================================================
-- @File	: Shop/Shop.lua
-- @Brief	: 商店逻辑
-- ========================================================

ShopLogic = ShopLogic or {}

ShopLogic.GID           = 1     --商城占用GID
ShopLogic.GoodsStart    = 1000  --前999存商店信息，1000开始存商品信息，因此商店分类不能大于999，不能修改
ShopLogic.MaxBuyNum     = 99   --单次购买数量限制
--[[
shopdata = {
    shopid = 0
    version = 0
    refreshnum = 0
    displaynum = 0
    refreshtime = 0
    tbgoods = {
        {goodsid = 0, discount = 0}
        {goodsid = 0, discount = 0}
        ...
    }
}
goodsdata = {
    buynum = 0
    invalidtime = 0 -- 部分记时间类的商品需要 如月卡
}
]]--

-- 加载商品配置
function ShopLogic.LoadGoodsConf()
    ShopLogic.tbGoodsConf = {}

    local tbFile = LoadCsv('shop/goods.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nShopId = tonumber(tbLine.ShopId);
        local nGoodsId = tonumber(tbLine.GoodsId);
        local tbInfo = {
            nShopId     = nShopId,
            nGoodsId    = nGoodsId,
            tbGDPLN     = Eval(tbLine.GDPLN),
            nExtra      = tonumber(tbLine.Extra) or 0,
            nPosIndex   = tonumber(tbLine.PosIndex or 0),
            nWeight     = tonumber(tbLine.Weight or 1),
            tbCondition = Eval(tbLine.Condition) or {},

            nCalculation   = tonumber(tbLine.Calculation or 0),
            tbPrice1       = Eval(tbLine.Price1),
            tbPrice2       = Eval(tbLine.Price2),

            nLimitType  = tonumber(tbLine.LimitType or 0),
            nLimitNum   = tonumber(tbLine.LimitNum or -1),
            nLimitHaveNum   = tonumber(tbLine.LimitHaveNum),
            nTips           = tonumber(tbLine.Tips) or 1,

            nDiscountType   = tonumber(tbLine.DiscountType or 0),
            tbDiscount      = Eval(tbLine.Discount),

            nAddiction      = tonumber(tbLine.Addiction or 0),
            tbParam         = Eval(tbLine.tbParam) or {},
        };

        tbInfo.nBegin     = ParseTime(string.sub(tbLine.Begin or '', 2, -2), tbInfo, "nBegin")
        tbInfo.nEnd        = ParseTime(string.sub(tbLine.End or '', 2, -2), tbInfo, "nEnd")

        ShopLogic.tbGoodsConf[nGoodsId] = tbInfo
        if nGoodsId > 10099 then
            UE4.UGMLibrary.ShowDialog("请找蓝蓝或者曦爷", string.format("shop/goods.txt中GoodsId：%d 有误！ 超出范围 0~20099", nGoodsId));
        end
    end
end

-- 加载商店配置
function ShopLogic.LoadShopTabConf()
    ShopLogic.tbShopTabConf = {}
    ShopLogic.tbGroupId = {}

    local tbFile = LoadCsv('shop/shop_tab.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nShopId = tonumber(tbLine.ShopId);
        if nShopId then
            local tbInfo = {
                nShopId     = nShopId,
                nGroupId    = tonumber(tbLine.GroupId or 0),
                nGroupIcon  = tonumber(tbLine.GroupIcon),
                nShopIcon   = tonumber(tbLine.ShopIcon),
                nUnselectIcon   = tonumber(tbLine.UnselectIcon),
                nGroupBg    = tonumber(tbLine.GroupBg),

                sGroupName  = tbLine.GroupName,
                sName       = tbLine.Name,
                nWidgetType = tonumber(tbLine.WidgetType) or 1,
                sBannerImg  = tbLine.BannerImg,

                nOnOff      = tonumber(tbLine.OnOff or 0),
                nFragmentLimit   = tonumber(tbLine.FragmentLimit) or 0,

                sGotoUI     = tbLine.GotoUI,
                tbParam     = Eval(tbLine.tbParam) or {},

                nColumns         = tonumber(tbLine.Columns or 0),
                nRefreshRule     = tonumber(tbLine.RefreshRule or 0),
                tbRefreshTime    = Split(string.sub(tbLine.RefreshTime or '', 2, -2), "|"),
                sActivity        = tbLine.Activity,
                tbRefreshFee     = Eval(tbLine.RefreshFee),
                nRefreshLimits   = tonumber(tbLine.RefreshLimits or 0),
                nMoneyType       = tonumber(tbLine.MoneyType or 0),

                tbShopMoneyType  = Eval(tbLine.ShopMoneyType),
                nVersion         = tonumber(tbLine.Version or 0),
                nLabel           = tonumber(tbLine.Label or 0)
            };

            tbInfo.nBegin      = ParseTime(string.sub(tbLine.Begin or '', 2, -2), tbInfo, "nBegin")
            tbInfo.nEnd        = ParseTime(string.sub(tbLine.End or '', 2, -2), tbInfo, "nEnd")

            local ishave = false
            for _, v in ipairs(ShopLogic.tbGroupId) do
                if v == tbInfo.nGroupId then ishave = true; break end
            end
            if not ishave then table.insert(ShopLogic.tbGroupId, tbInfo.nGroupId) end
            ShopLogic.tbShopTabConf[nShopId] = tbInfo
        end
    end
end

---角色碎片商品是否限制购买
function ShopLogic.GetFragmentLimit(nShopId)
    local shopInfo = ShopLogic.tbShopTabConf[nShopId]
    if shopInfo and shopInfo.nFragmentLimit and shopInfo.nFragmentLimit > 0 then
        return true
    end
end

function ShopLogic.LoadDlcShopConf()
    local tbFile = LoadCsv('dlc/dlc_shop.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nShopId = tonumber(tbLine.ShopId);
        local Coverage = tonumber(tbLine.Coverage) or 0
        if nShopId and CheckCoverage(Coverage) then
            local tbInfo = {
                nShopId     = nShopId,
                nGroupId    = nShopId,
                nGroupIcon  = tonumber(tbLine.GroupIcon),
                nShopIcon   = tonumber(tbLine.ShopIcon),

                sGroupName  = tbLine.GroupName,
                sName       = tbLine.GroupName,
                nWidgetType = tonumber(tbLine.WidgetType) or 1,
                sBannerImg  = tbLine.BannerImg,

                nOnOff      = tonumber(tbLine.OnOff or 1),

                sGotoUI     = tbLine.GotoUI,
                tbParam     = Eval(tbLine.tbParam) or {},

                nColumns         = tonumber(tbLine.Columns or 0),
                nRefreshRule     = tonumber(tbLine.RefreshRule or 0),
                tbRefreshTime    = Split(string.sub(tbLine.RefreshTime or '', 2, -2), "|"),
                tbRefreshFee     = Eval(tbLine.RefreshFee),
                nRefreshLimits   = tonumber(tbLine.RefreshLimits or 0),
                nMoneyType       = tonumber(tbLine.MoneyType or 0),

                tbCondition      = Eval(tbLine.Condition),

                tbShopMoneyType  = Eval(tbLine.ShopMoneyType),
                nVersion         = tonumber(tbLine.Version or 0),
                nLabel           = tonumber(tbLine.Label or 0),

                bDLCShop         = true,
            };

            tbInfo.nBegin      = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), tbInfo, "nBegin")
            tbInfo.nEnd        = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), tbInfo, "nEnd")

            local ishave = false
            for _, v in ipairs(ShopLogic.tbGroupId) do
                if v == tbInfo.nGroupId then ishave = true; break end
            end
            if not ishave then table.insert(ShopLogic.tbGroupId, tbInfo.nGroupId) end
            ShopLogic.tbShopTabConf[nShopId] = tbInfo
        end
    end

    tbFile = LoadCsv('dlc/dlc_goods.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nShopId = tonumber(tbLine.ShopId);
        local nGoodsId = tonumber(tbLine.GoodsId);
        if nShopId and nGoodsId then
            local tbInfo = {
                nShopId     = nShopId,
                nGoodsId    = nGoodsId,
                tbGDPLN     = Eval(tbLine.GDPLN),
                nExtra      = tonumber(tbLine.Extra) or 0,
                nPosIndex   = tonumber(tbLine.PosIndex or 0),
                nWeight     = tonumber(tbLine.Weight or 1),
                tbCondition = Eval(tbLine.Condition) or {},

                nCalculation   = tonumber(tbLine.Calculation or 0),
                tbPrice1       = Eval(tbLine.Price1),
                tbPrice2       = Eval(tbLine.Price2),

                nLimitType  = tonumber(tbLine.LimitType or 0),
                nLimitNum   = tonumber(tbLine.LimitNum or -1),
                nLimitHaveNum   = tonumber(tbLine.LimitHaveNum),
                nTips           = tonumber(tbLine.Tips) or 1,

                nDiscountType   = tonumber(tbLine.DiscountType or 0),
                tbDiscount      = Eval(tbLine.Discount),

                nAddiction      = tonumber(tbLine.Addiction or 0),
                tbParam         = Eval(tbLine.tbParam) or {},
            };

            tbInfo.nBegin     = ParseTime(string.sub(tbLine.Begin or '', 2, -2), tbInfo, "nBegin")
            tbInfo.nEnd        = ParseTime(string.sub(tbLine.End or '', 2, -2), tbInfo, "nEnd")

            ShopLogic.tbGoodsConf[nGoodsId] = tbInfo

            if nGoodsId > 20099 or nGoodsId < 10099 then
                UE4.UGMLibrary.ShowDialog("请找蓝蓝或者曦爷", string.format("dlc/dlc_goods.txt中GoodsId：%d 有误！ 超出范围10099~20099", nGoodsId));
            end
        end
    end
end

function ShopLogic.IsDlcShop(tbShopTab)
    return tbShopTab.bDLCShop == true
end

---主界面商城按钮是否显示红点
function ShopLogic.IsShowRedDot()
    for _, v in pairs(ShopLogic.tbShopTabConf) do
        if not ShopLogic.IsDlcShop(v) then
            local info = ShopLogic.GetShopInfo(v.nShopId)
            local data = ShopLogic.GetShopData(v.nShopId)
            if info and (not data or info.nVersion ~= data.version) then
                return true
            end
        end
    end
    return false
end

---主界面商城按钮是否显示月卡不足
function ShopLogic.IsShowTimeLess()
    --月卡商店开放且月卡剩余小于三天 显示红点
    if ShopLogic.GetShopInfo(21) then
        local data = ShopLogic.GetGoodsData(2101)
        local time = GetTime()
        if data and data.invalidtime and data.invalidtime > time and (data.invalidtime - time < 86400*3) then
            return true
        end
    end
    return false
end

---得到存储的商店信息
function ShopLogic.GetShopData(shopid)
    return json.decode(me:GetStrAttribute(ShopLogic.GID, shopid))
end

---得到存储的商品信息
function ShopLogic.GetGoodsData(goodsid)
    return json.decode(me:GetStrAttribute(ShopLogic.GID, ShopLogic.GoodsStart + goodsid))
end

---获取商店配置信息
function ShopLogic.GetShopInfo(nShopId)
    local shopInfo = ShopLogic.tbShopTabConf[nShopId]
    if not shopInfo or shopInfo.nOnOff <= 0 or not IsInTime(shopInfo.nBegin, shopInfo.nEnd) then return nil end
    return shopInfo
end

---获取开放的商店列表
function ShopLogic.GetAllOpenTab()
    local tbShopTab = {}
    for _, v in pairs(ShopLogic.tbShopTabConf) do
        local info = ShopLogic.GetShopInfo(v.nShopId)
        if info and not ShopLogic.IsDlcShop(v) then
            local group = v.nGroupId
            tbShopTab[group] = tbShopTab[group] or {}
            table.insert(tbShopTab[group], info)
        end
    end
    for _, v in pairs(tbShopTab) do
        if #v > 1 then
            table.sort(v, function(a, b) return a.nShopId < b.nShopId end)
        end
    end
    return tbShopTab
end

---获取开放的DLC商店列表
function ShopLogic.GetDlcOpenTab()
    local tbShopTab = {}
    for _, v in pairs(ShopLogic.tbShopTabConf) do
        local info = ShopLogic.GetShopInfo(v.nShopId)
        if info and ShopLogic.IsDlcShop(v) then
            table.insert(tbShopTab, info)
        end
    end
    table.sort(tbShopTab, function(a, b) return a.nShopId < b.nShopId end)
    return tbShopTab
end

---获取商店手动刷新次数
function ShopLogic.GetShopRefreshNnm(nShopId)
    local data = ShopLogic.GetShopData(nShopId)
    if data then
        return data.refreshnum
    end
    return 0
end

---获取剩余手动刷新次数和消耗的代币
function ShopLogic.GetShopRefreshInfo(nShopId)
    local shopInfo = ShopLogic.GetShopInfo(nShopId)
    if not shopInfo then return nil end
    local Nnm = ShopLogic.GetShopRefreshNnm(nShopId)
    if shopInfo.nRefreshLimits > 0 and shopInfo.tbRefreshFee then
        local tb = {}
        -- tb.num = shopInfo.nRefreshLimits - Nnm
        -- tb.usenum = Nnm
        -- tb.limitnum = shopInfo.nRefreshLimits
        tb.str = Nnm .. "/" .. shopInfo.nRefreshLimits
        tb.moneyid = shopInfo.nMoneyType
        tb.moneynum = shopInfo.tbRefreshFee[Nnm+1]
        return tb
    end
    return nil
end

---根据配置获取商店的下次刷新时间
function ShopLogic.GetNextRefreshTime(nShopId)
    local shopInfo = ShopLogic.GetShopInfo(nShopId)
    if not shopInfo then return 0 end
    local nowTime = GetTime()
    local NextRefreshTime = 0

    if shopInfo.nRefreshRule == 1 then
        for _, v in ipairs(shopInfo.tbRefreshTime) do
            NextRefreshTime = ParseBriefTime(v)
            if nowTime < NextRefreshTime then
                return NextRefreshTime  --今天
            end
        end
        if #shopInfo.tbRefreshTime >= 1 then
            return ParseBriefTime(shopInfo.tbRefreshTime[1]) + 86400   --明天
        end
    elseif shopInfo.nRefreshRule == 2 then
        local nowWeek = tonumber(os.date('%w', nowTime))
        if nowWeek == 1 and tonumber(os.date('%H', nowTime)) < 4 then --今天周一且没过4点
            return ParseBriefTime("0400")
        end
        if nowWeek == 0 then -- 今天周日
            NextRefreshTime = 86400 + ParseBriefTime("0400") --下周1(明天) 04:00
        else
            NextRefreshTime = (8 - nowWeek) * 86400 + ParseBriefTime("0400") --下周1 04:00
        end
    elseif shopInfo.nRefreshRule == 3 then
        if tonumber(os.date('%d', nowTime)) == 1 and tonumber(os.date('%H', nowTime)) < 4 then --今天1号且没过4点
            return ParseBriefTime("0400")
        end
        local year  = tonumber(os.date("%Y",nowTime))
        local month = tonumber(os.date("%m",nowTime))
        if month == 12 then
            year = year + 1
            month = 1
        else
            month = month + 1
        end
        local timestr = tostring(year)..string.format("%02d", month).."010400"
        NextRefreshTime = ParseTime(timestr)  --下月1号 04:00
    elseif shopInfo.nRefreshRule == 4 and shopInfo.sActivity then
        --跟随活动刷新
        if shopInfo.sActivity == "ClimbTower" then
            --爬塔活动
            NextRefreshTime = ClimbTowerLogic.GetEndTime()
        end
    end
    return NextRefreshTime
end

---获取商品信息  没有开放返回nil
function ShopLogic.GetGoodsInfo(nGoodsId)
    local goodsinfo = ShopLogic.tbGoodsConf[nGoodsId]
    --如果配了折扣信息，那么配置的时间为折扣生效的时间
    if goodsinfo and (goodsinfo.tbDiscount or IsInTime(goodsinfo.nBegin, goodsinfo.nEnd)) then   --时间和特殊条件限制
        return goodsinfo
    end
    return nil
end

---获取购买次数
function ShopLogic.GetBuyNum(nGoodsId)
    local data = ShopLogic.GetGoodsData(nGoodsId)
    if data then
        return data.buynum
    end
    return 0
end

---获取商品的最大购买数量
---@param nGoodsId integer 商品id
---@param nbuytype integer 购买方式 代币1或代币2
---@return integer 返回可购买的最大数量
function ShopLogic.GetMaxBuyNum(nGoodsId, nbuytype)
    local goodsInfo = ShopLogic.GetGoodsInfo(nGoodsId)
    if not goodsInfo then
        return 0
    end
    local limitnum = -1
    local buynum = ShopLogic.GetBuyNum(nGoodsId)
    if goodsInfo.nLimitType > 0 and goodsInfo.nLimitNum ~= -1 then
        if buynum >= goodsInfo.nLimitNum then
            return 0
        else
            limitnum = goodsInfo.nLimitNum - buynum
        end
    end

    local priceInfo = ShopLogic.GetBuyPrice(nGoodsId, 1)
    if not priceInfo then
        return math.max(limitnum, 0)
    end
    local maxnum = -1
    if goodsInfo.nCalculation == 1 then
        local havenum1 = 0
        local disPrice1
        if priceInfo[1] then
            disPrice1 = priceInfo[1][#priceInfo[1]]
            if #priceInfo[1] >= 5 then
                havenum1 = me:GetItemCount(priceInfo[1][1], priceInfo[1][2], priceInfo[1][3], priceInfo[1][4])
            else
                havenum1 = Cash.GetMoneyCount(priceInfo[1][1])
            end
        end
        local havenum2 = 0
        local disPrice2
        if priceInfo[2] then
            disPrice2 = priceInfo[2][#priceInfo[2]]
            if #priceInfo[2] >= 5 then
                havenum2 = me:GetItemCount(priceInfo[2][1], priceInfo[2][2], priceInfo[2][3], priceInfo[2][4])
            else
                havenum2 = Cash.GetMoneyCount(priceInfo[2][1])
            end
            if nbuytype and nbuytype == 2 then
                maxnum = math.floor(havenum2 / disPrice2)
            else
                maxnum = math.floor(havenum1 / disPrice1)
            end
        end
    elseif goodsInfo.nCalculation == 2 then
        for _, v in ipairs(priceInfo) do
            local havenum = 0
            local disPrice = v[#v]
            if #v >= 5 then
                havenum = me:GetItemCount(v[1], v[2], v[3], v[4])
            else
                havenum = Cash.GetMoneyCount(v[1])
            end
            local num = math.floor(havenum / disPrice)
            if maxnum == -1 or maxnum > num then
                maxnum = num
            end
        end
    else
        local havenum = 0
        local disPrice = priceInfo[1][#priceInfo[1]]
        if #priceInfo[1] >= 5 then
            havenum = me:GetItemCount(priceInfo[1][1], priceInfo[1][2], priceInfo[1][3], priceInfo[1][4])
        else
            havenum = Cash.GetMoneyCount(priceInfo[1][1])
        end
        maxnum = math.floor(havenum / disPrice)
    end

    if limitnum ~= -1 and maxnum > limitnum then
        maxnum = limitnum
    end
    return maxnum
end

---获取商品的最大购买数量（界面提示）
---@param nGoodsId int 商品id
---@return int 返回可购买的最大数量
function ShopLogic.GetMaxShowNum(nGoodsId)
    local goodsInfo = ShopLogic.GetGoodsInfo(nGoodsId)
    if not goodsInfo then
        return 0
    end
    local limitnum = 999
    local buynum = ShopLogic.GetBuyNum(nGoodsId)
    if goodsInfo.nLimitType > 0 and goodsInfo.nLimitNum ~= -1 then
        if buynum >= goodsInfo.nLimitNum then
            limitnum = 0
        else
            limitnum = goodsInfo.nLimitNum - buynum
        end
    end
    return limitnum
end

---检查商品是否上架,上架则返回id和折扣信息
function ShopLogic.GetOnLineGoodsInfo(nGoodsId)
    if not ShopLogic.tbGoodsConf[nGoodsId] then return nil end
    local nShopId = ShopLogic.tbGoodsConf[nGoodsId].nShopId
    local shopdata = ShopLogic.GetShopData(nShopId)
    if not shopdata then return nil end
    for _, v in pairs(shopdata.tbgoods) do
        if v.goodsid == nGoodsId then
            return v.goodsid, v.discountindex
        end
    end
    return nil
end

---计算价格(免费返回nil)
function ShopLogic.GetBuyPrice(nGoodsId, nCount)
    local goodsInfo = ShopLogic.GetGoodsInfo(nGoodsId)
    if not goodsInfo then
        return
    end
    if not goodsInfo.tbPrice1 and not goodsInfo.tbPrice2 then   ---免费
        return nil
    end
    --计算消耗的代币
    local priceInfo = {}
    priceInfo[1] = Copy(goodsInfo.tbPrice1)
    priceInfo[2] = Copy(goodsInfo.tbPrice2)

    --计算折扣后的消耗
    local count = nCount or 1
    local _, discount = ShopLogic.GetOnLineGoodsInfo(nGoodsId)
    if discount and discount > 0 and goodsInfo.tbDiscount and goodsInfo.tbDiscount[discount] then
        local discountinfo = goodsInfo.tbDiscount[discount]
        for k, v in pairs(priceInfo) do
            local discountValue = discountinfo[k+1] or discountinfo[2]
            if discountValue then
                if goodsInfo.nDiscountType == 1 then
                    v[#v] = math.ceil(v[#v] * (discountValue / 100)) * count
                elseif goodsInfo.nDiscountType == 2 then
                    v[#v] = math.ceil(discountValue) * count
                end
            end
        end
    else
        for _, v in pairs(priceInfo) do
            v[#v] = v[#v] * count
        end
    end

    return priceInfo
end

---向服务器请求商店的开放时间
function ShopLogic.GetOpenTime()
    UI.ShowConnection()
    me:CallGS("ShopLogic_GetOpenTime")
end
---请求商店的开放时间后刷新页面
s2c.Register('ShopLogic_GetOpenTime', function(tbParam)
    UI.CloseConnection()
    if tbParam then
        for k, v in pairs(tbParam) do
            if ShopLogic.tbShopTabConf[k] then
                ShopLogic.tbShopTabConf[k].nBegin = v.nBegin
                ShopLogic.tbShopTabConf[k].nEnd = v.nEnd
            end
        end
    end
    local sUI = UI.GetUI("Shop")
    if sUI and sUI:IsOpen() then
        sUI:UpdateShopGroup()
    end

    sUI = UI.GetUI("Dlc1Shop")
    if sUI and sUI:IsOpen() then
        sUI:UpdateShopGroup()
    end
end)

---购买商品
---@param nGoodsId integer 商品id
---@param nBuyMode integer 支付方式 代币一、代币二、代币一和代币二
---@param nCount integer 购买数量
---能购买向服务器发送购买请求，不能购买返回错误信息
function ShopLogic.BuyGoods(nGoodsId, nBuyMode, nCount)
    if not nGoodsId then
        return UI.ShowMessage("error.BadParam")
    end

    --商品信息、时间、特殊条件检查
    local goodsInfo = ShopLogic.GetGoodsInfo(nGoodsId)
    if not goodsInfo then
        return UI.ShowMessage("ui.TxtNotOpen")
    end

    --上架检查
    local _, discount = ShopLogic.GetOnLineGoodsInfo(nGoodsId)
    if not discount then
        return UI.ShowMessage("ui.TxtNotOpen")
    end

    --限购检查
    local count = nCount or 1
    local buynum = ShopLogic.GetBuyNum(nGoodsId)
    if goodsInfo.nLimitType > 0 and goodsInfo.nLimitNum ~= -1 then
        if buynum + count > goodsInfo.nLimitNum then
            return UI.ShowMessage("ui.TxtLimitBuy")
        end
    end

    --价格检查
    local priceInfo = ShopLogic.GetBuyPrice(nGoodsId, count)
    if priceInfo then
        if goodsInfo.nCalculation == 1 then
            if nBuyMode and nBuyMode == 2 then  --选择消耗代币二
                table.remove(priceInfo, 1)
            else    --选择消耗代币一
                table.remove(priceInfo, 2)
            end
        end
        for _, v in pairs(priceInfo) do
            local havenum = 0
            local disPrice = v[#v]
            if #v >= 5 then
                havenum = me:GetItemCount(v[1], v[2], v[3], v[4])
                if havenum < disPrice then
                    Audio.PlayVoices("NoMoney")
                    return UI.ShowMessage("tip.gold_not_enough")
                end
            else
                havenum = Cash.GetMoneyCount(v[1])
                if v[1] ~= Cash.MoneyType_RMB and havenum < disPrice then
                    Audio.PlayVoices("NoMoney")
                    return UI.ShowMessage("tip.gold_not_enough")
                end
            end
        end
    end
    UI.ShowConnection()
    me:CallGS("ShopLogic_BuyGoods", json.encode({nGoodsId = nGoodsId, nBuyMode = nBuyMode, nCount = count}))
end

---向服务器请求商品列表
---@param nShopId integer 商店分类id
function ShopLogic.GetGoodsList(nShopId)
    if not nShopId then
        return UI.ShowMessage("error.BadParam")
    end
    UI.ShowConnection()
    me:CallGS("ShopLogic_GetGoodsList", json.encode({nShopId = nShopId}))
end

---获取商品列表
---@param nShopId integer 商店分类id
---@param bBreak bool 防止无限循环获取
function ShopLogic.GetLocalGoodsList(nShopId, bBreak)
    local tbShopData = ShopLogic.GetShopData(nShopId)
    local list = tbShopData and tbShopData.tbgoods or nil
    if not list then
        if not bBreak then
            ShopLogic.GetGoodsList(nShopId)
        end
        return
    end
    local data = {shopId = nShopId, goodsList = list}
    return data
end


---跳转到目标界面
---@param cfg table shop_tab配置
function ShopLogic.GoToUI(cfg)
    if cfg and cfg.sGotoUI then
        UI.Open(cfg.sGotoUI, cfg.tbParam[1], cfg.tbParam[2], cfg.tbParam[3])
    end
end

---对服务器返回的id列表排序
function ShopLogic.Sort(list)
    local tb1 = {}
    local tb2 = {}
    for _, v in pairs(list) do
        local info =  ShopLogic.GetGoodsInfo(v.goodsid)
        if info then
            if info.nPosIndex > 0 then
                table.insert(tb1, info)
            else
                table.insert(tb2, info)
            end
        end
    end

    local funLimitSort = function(tb)
        local t1 = {}
        local t2 = {}
        for _, v in ipairs(tb) do
            if v.nLimitType > 0 and v.nLimitNum ~= -1 and ShopLogic.GetBuyNum(v.nGoodsId) >= v.nLimitNum then   --a售罄
                table.insert(t2, v)
            else
                table.insert(t1, v)
            end
        end
        for _, v in ipairs(t2) do
            table.insert(t1, v)
        end
        return t1
    end

    if #tb1 > 1 then
        table.sort(tb1, function(a, b) return a.nPosIndex < b.nPosIndex end)
    end
    if #tb2 > 1 then
        table.sort(tb2, function(a, b) return a.nWeight > b.nWeight end)
    end

    if #tb2 > 0 then
        for _, v in ipairs(tb1) do
            if v.nPosIndex > #tb2 + 1 then
                table.insert(tb2, v)
            else
                table.insert(tb2, v.nPosIndex, v)
            end
        end
        return funLimitSort(tb2)
    else
        return funLimitSort(tb1)
    end
end

---客户端手动刷新商店
---@param nShopId integer 商店分类id
function ShopLogic.UpdateShop(nShopId)
    if not nShopId then
        return UI.ShowMessage("error.BadParam")
    end

    --剩余次数检查
    local info = ShopLogic.GetShopInfo(nShopId)
    local num = ShopLogic.GetShopRefreshNnm(nShopId)
    if num >= info.nRefreshLimits then
        return UI.ShowMessage("tip.refresh_run_out")
    end

    --价格检查
    if info.nMoneyType and info.tbRefreshFee and info.tbRefreshFee[num+1] then
        if not Cash.CheckMoney(info.nMoneyType, info.tbRefreshFee[num+1]) then
            Audio.PlayVoices("NoMoney")
            return UI.ShowMessage("tip.gold_not_enough")
        end
    end

    me:CallGS("ShopLogic_UpdateShop", json.encode({nShopId = nShopId}))
end

---获取商品列表后刷新页面
s2c.Register('ShopLogic_GetGoodsList', function(tbParam)
    UI.CloseConnection()
    local sUI = UI.GetUI("Shop")
    if sUI then
        sUI:OnReceiveUpdate(tbParam)
    end

    sUI = UI.GetUI("Activity")
    if sUI then
        sUI:OnReceiveUpdate()
    end

    sUI = UI.GetUI('Dlc1Shop')
    if sUI then
        sUI:OnReceiveUpdate(tbParam)
    end

    -- 广播商店数据
    EventSystem.Trigger(Event.NotifyShopData, tbParam)
end)

---购买商品后刷新页面
s2c.Register('ShopLogic_BuyGoods',function(tbParam)
    UI.CloseConnection()
    if tbParam.tbGoods then
        Item.Gain(ShopLogic.GetActualItems(tbParam.tbGoods))
    end
    Audio.PlayVoices("PaySuccess")
    local sUI = UI.GetUI("Shop")
    if sUI then
        sUI:OnByGoodsUpdate()
    end

    sUI = UI.GetUI("Activity")
    if sUI then
        sUI:OnByGoodsUpdate()
    end

    sUI = UI.GetUI("RoleFashion")
    if sUI then
        sUI:OnByGoodsUpdate()
    end

    -- 广播商店数据
    EventSystem.Trigger(Event.NotifyShopRefresh, tbParam)
end)

---根据道具GDPL得到实际获得的道具
function ShopLogic.GetActualItems(gdpln)
    local checkMoney = function(tbItem, tbInfo)
        if not tbInfo or not tbItem then return end

        if tbItem.LuaType == "money_box" and tbItem.Param1 then
            return {Cash.MoneyType_Money, tbItem.Param1 * (tbInfo[5] or 1)}
        elseif tbItem.LuaType == "gold_box" and tbItem.Param1 then
            return {Cash.MoneyType_Gold, tbItem.Param1 * (tbInfo[5] or 1)}
        end
    end

    local info = UE4.UItem.FindTemplate(gdpln[1], gdpln[2], gdpln[3], gdpln[4])
    if info.LuaType == "itembox" and info.Param1 then
        local tbConfig = Item.tbBox[info.Param1]
        if tbConfig then
            local tbItem = {}
            for _, tbInfo in pairs(tbConfig) do
                for _, tbcfg in pairs(tbInfo) do
                    for _, item in ipairs(tbcfg) do
                        local data = item.tbGDPLN
                        data[5] = (data[5] or 1) * (gdpln[5] or 1)
                        local info1 = UE4.UItem.FindTemplate(data[1], data[2], data[3], data[4])
                        local tbInfo = checkMoney(info1, data)
                        if tbInfo then
                            table.insert(tbItem, tbInfo)
                        else
                            table.insert(tbItem, data)
                        end
                    end
                end
            end
            return tbItem
        end
    else
        local tbInfo = checkMoney(info, gdpln)
        if tbInfo then
            return {tbInfo}
        end
    end
    return {gdpln}
end

ShopLogic.LoadGoodsConf()
ShopLogic.LoadShopTabConf()
ShopLogic.LoadDlcShopConf()
