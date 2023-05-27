-- ========================================================
-- @File	: Purchase/IBShop.lua
-- @Brief	: IB商店逻辑
-- ========================================================
IBLogic = IBLogic or {}

--Task Group
IBLogic.BuyGroupId = 26

IBLogic.nMonthCardTask = 0  --月卡时间

--月卡物品
IBLogic.tbMonthSignItem = {4,3,4,1}
--月卡赠送数据金道具
IBLogic.tbMonthGiveItem = {4,3,2,1}

--比特金 负数限制消费基数
IBLogic.LimitBuy = 0

--商店类型
IBLogic.Tab_Recommend = 1   --推荐类型
IBLogic.Tab_IBMoney = 2   --比特金
IBLogic.Tab_IBMonth = 3 --月卡
IBLogic.Tab_IBGift = 4 --礼包
IBLogic.Tab_IBSkin = 5 --皮肤
IBLogic.Tab_IBGold = 6 --数据金

--商品类型
IBLogic.Type_IBMoney = 1   --比特金
IBLogic.Type_IBMonth = 2 --月卡
IBLogic.Type_IBBP = 3 --bp道具
IBLogic.Type_IBGift = 4 --礼包
IBLogic.Type_IBSkin = 5 --皮肤
IBLogic.Type_IBGold = 6 --数据金

--获取当前系统区域
IBLogic.XGSDK_Area = nil

--xgsdk区域对应语言
IBLogic.tbXgsdkArea = nil

--默认货币符号
IBLogic.tbDefaultCN = {"CNY", "¥"}
IBLogic.tbDefaultUS = {"USD", "$"}


--是否跳过年龄限制
IBLogic.GMSkipAgeLimit = false

--月卡默认天数
IBLogic.DefaultMonthlyDay = 30

function IBLogic.LoadIBConf()
    IBLogic.LoadIBShopTab()
    IBLogic.LoadIBGoods()
    IBLogic.LoadPirceList()
    IBLogic.LoadAreaList()
end

--加载充值商店
function IBLogic.LoadIBShopTab()
    IBLogic.tbIbShopList = {}
    IBLogic.tbIbShopGroup = {}
    local tbFile = nil
    if Login.IsOversea() then
        tbFile = LoadCsv('purchase/ibshoptab_oversea.txt', 1);
    else
        tbFile = LoadCsv('purchase/ibshoptab.txt', 1);
    end

    if not tbFile then
        print('Load ibshoptab error')
        return
    end

    for _, tbLine in ipairs(tbFile) do
        local nShopId = tonumber(tbLine.Id) or 0;
        if nShopId > 0 then
            local tbInfo = {
                nShopId          = nShopId,
                nGroupId        = tonumber(tbLine.GroupId),
                sGroupName  = tbLine.GroupName,
                nGroupIcon  = tonumber(tbLine.GroupIcon),

                sLabel        = tbLine.Label,
                sName       = tbLine.Name,
                nIndex     = tonumber(tbLine.Index) or 999999,
                nWidgetType = tonumber(tbLine.WidgetType),
                nBG                = tonumber(tbLine.BG),
                sTitle              = tbLine.Title,
                sInfo              = tbLine.Info,
                nPic               = tonumber(tbLine.Pic),

                sGotoUI        = tbLine.GotoUI,
                tbUIParam    = Eval(tbLine.tbParam) or {},
                nAId              = tonumber(tbLine.AId),
            };
            IBLogic.tbIbShopList[nShopId] = tbInfo
            if tbInfo.nGroupId > 0 then
                IBLogic.tbIbShopGroup[tbInfo.nGroupId] = IBLogic.tbIbShopGroup[tbInfo.nGroupId] or {}
                table.insert(IBLogic.tbIbShopGroup[tbInfo.nGroupId], tbInfo)
            end
        end
    end

    for k,v in pairs(IBLogic.tbIbShopGroup) do
        table.sort(v, function(a, b) 
            if a.nIndex == b.nIndex then
                return a.nShopId < b.nShopId
            else
                return a.nIndex < b.nIndex
            end
        end)
    end
end

--加载商品列表
function IBLogic.LoadIBGoods()
    IBLogic.tbIbGoods = {}
    IBLogic.tbIosGoods = {}
    IBLogic.tbAndroidGoods = {}
    IBLogic.tbShopGoods = {}
    IBLogic.tbBPList = {} --bp通行证商品
    local tbFile = nil
    if Login.IsOversea() then
        tbFile = LoadCsv('purchase/ibgoods_oversea.txt', 1);
    else
        tbFile = LoadCsv('purchase/ibgoods.txt', 1);
    end

    if not tbFile then
        print('Load ibgoods error')
        return
    end

    for _, tbLine in ipairs(tbFile) do
        local nGoodsId = tonumber(tbLine.GoodsId) or 0;
        if nGoodsId > 0 then
            local tbInfo = {
                nShopId     = tonumber(tbLine.Id) or 0,
                nGoodsId    = nGoodsId,
                nPreId     = tonumber(tbLine.PreId) or 0,
                sIosId          = tbLine.IosId,
                sAndroidId  = tbLine.AndroidId,
                nType          = tonumber(tbLine.Type) or 0,
                tbItem         = Eval(tbLine.Item) or {},
                nLimitType  = tonumber(tbLine.LimitType) or 0,
                nLimitTimes  = tonumber(tbLine.LimitTimes) or 0,
                tbCost           = Eval(tbLine.Cost) or {},
                sItemName    = tbLine.ItemName,
                tbCondition    = Eval(tbLine.Condition) or {},
                nOffRate    = tonumber(tbLine.OffRate) or 0,
                nAddiction      = tonumber(tbLine.Addiction or 0),
                tbParam         = Eval(tbLine.tbParam) or {},
                nVersion     = tonumber(tbLine.Version),
                nAId              = tonumber(tbLine.AId),
                nIndex     = tonumber(tbLine.Index) or 999999,
                nItemBg  =  tonumber(tbLine.ItemBg) or 0,
            };

            tbInfo.nOffStartTime      = ParseTime(string.sub(tbLine.OffStartTime or '', 2, -2), tbInfo, "nOffStartTime")
            tbInfo.nOffEndTime       = ParseTime(string.sub(tbLine.OffEndTime or '', 2, -2), tbInfo, "nOffEndTime")

            tbInfo.nStartTime      = ParseTime(string.sub(tbLine.StartTime or '', 2, -2), tbInfo, "nStartTime")
            tbInfo.nEndTime       = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), tbInfo, "nEndTime")

            IBLogic.tbIbGoods[nGoodsId] = tbInfo
            if tbInfo.sIosId then
                IBLogic.tbIosGoods[tbInfo.sIosId] = tbInfo
            end
            if tbInfo.sAndroidId then
                IBLogic.tbAndroidGoods[tbInfo.sAndroidId] = tbInfo
            end
            if tbInfo.nShopId > 0 then
                local tbShopList = IBLogic.tbShopGoods[tbInfo.nShopId]
                if not tbShopList then
                    IBLogic.tbShopGoods[tbInfo.nShopId] = {}
                    tbShopList = IBLogic.tbShopGoods[tbInfo.nShopId]
                end

                table.insert(tbShopList, tbInfo)
            end
            --bp
            if tbInfo.nType == IBLogic.Type_IBBP and #tbInfo.tbParam > 0 then
                local nBPId = tbInfo.tbParam[1]
                local tbBPTable = IBLogic.tbBPList[nBPId]
                if  not tbBPTable then
                    IBLogic.tbBPList[nBPId] = {}
                    tbBPTable = IBLogic.tbBPList[nBPId]
                end
                table.insert(tbBPTable, tbInfo)
            end
        end
    end
end

--加载价格列表
function IBLogic.LoadPirceList()
    IBLogic.tbPriceList = {}
    IBLogic.tbEuPriceList = {}
    local tbFile = LoadCsv('purchase/pricelist.txt', 0);
    for _, tbLine in ipairs(tbFile) do
        local sId  = tbLine.Id
        if sId then
            local tb = {}
            tb.sId = sId
            tb.tbPrice = {}

            local nCNPrice = 0
            local nEUPrice = 0
            for k,v in pairs(tbLine) do
                if k ~= "LevelId" then
                    local _,_,sKey = string.find(k or "", '%((%w+)%)')
                    if sKey and not tb.tbPrice[sKey] then
                        tb.tbPrice[sKey] = tonumber(tbLine[k]) or 0
                        if sKey == "CNY" then
                            nCNPrice = tonumber(tbLine[k]) or 0
                        elseif sKey == "USD" then
                            nEUPrice = (tonumber(tbLine[k]) or 0)  * 100
                        end
                    end
                end
            end

            if nCNPrice > 0 and not IBLogic.tbPriceList[nCNPrice] then
                IBLogic.tbPriceList[nCNPrice] = tb
            end

            if nEUPrice > 0 and not IBLogic.tbEuPriceList[nEUPrice] then
                IBLogic.tbEuPriceList[nEUPrice] = tb
            end
        end
    end
end

--加载区域列表
function IBLogic.LoadAreaList()
    if not Login.IsOversea() then
        return
    end

    IBLogic.tbXgsdkArea = {}
    local tbFile = LoadCsv('purchase/arealist.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local sAbbr  = tbLine.Abbr
        local sLanguage  = tbLine.Language
        if sAbbr and sLanguage then
            local tb = {}
            tb.sAbbr = sAbbr        --xg 语言版本
            tb.sLanguage = sLanguage --对应的游戏内 语言
            tb.sCurrency = tbLine.Currency  --货币 缩写
            tb.sSymbol = tbLine.Symbol  ---货币 符号

            IBLogic.tbXgsdkArea[sAbbr] = tb
        end
    end
end

--获取商店信息
function IBLogic.GetShopConfig(nShopId)
    if not nShopId then return end

    return IBLogic.tbIbShopList[nShopId]
end

--获取商品信息
function IBLogic.GetIBGoods(nGoodsId)
    if not nGoodsId then return end
    return IBLogic.tbIbGoods[nGoodsId];
end

function IBLogic.GetIBConfig(sId)
    local tbConfig = IBLogic.GetIOSIBConfig(sId)
    if tbConfig then
        return tbConfig
    end

    return IBLogic.GetAndroidIBConfig(sId)
end

--获取商品信息
function IBLogic.GetIOSIBConfig(sId)
    if not sId then return end
    return IBLogic.tbIosGoods[sId];
end

--获取商品信息
function IBLogic.GetAndroidIBConfig(sId)
    if not sId then return end
    return IBLogic.tbAndroidGoods[sId];
end

--获取商店信息
function IBLogic.GetIBShopGoods(nShopId)
    if not nShopId then return end

    return IBLogic.tbShopGoods[nShopId]
end

--获取bp通行证
function IBLogic.GetBPList(nBPId)
    if not nBPId then return end

    return IBLogic.tbBPList[nBPId]
end

--获取价格
function IBLogic.GetPriceConfig(nPrice, bOversea)
    if not nPrice then return end

    if bOversea then
        return IBLogic.tbEuPriceList[nPrice]
    else
        return IBLogic.tbPriceList[nPrice]
    end
end

--获取区域信息
function IBLogic.GetAreaInfo(sLang)
    if not sLang then return end
    if not IBLogic.tbXgsdkArea then return end
    if not IBLogic.tbXgsdkArea[sLang] then return end

    return {IBLogic.tbXgsdkArea[sLang].sCurrency, IBLogic.tbXgsdkArea[sLang].sSymbol}
end

--获取货币符号
function IBLogic.GetMoneyFlag()
    local tbMoneyInfo = IBLogic.GetAreaInfo(IBLogic.GetRegion())
    if not tbMoneyInfo or #tbMoneyInfo ~= 2 then
        if Login.IsOversea() then
            tbMoneyInfo = Copy(IBLogic.tbDefaultUS)
        else
            tbMoneyInfo = Copy(IBLogic.tbDefaultCN)
        end
    end

    local tbAllPrice = IBLogic.GetPriceConfig(6)
    if not tbMoneyInfo[1] or not tbAllPrice or not tbAllPrice.tbPrice or not tbAllPrice.tbPrice[tbMoneyInfo[1]] then
        if Login.IsOversea() then
            return Copy(IBLogic.tbDefaultUS)
        else
            return Copy(IBLogic.tbDefaultCN)
        end
    end

    return tbMoneyInfo
end

--获取对应语言版本的价格
-- sKey  CNY类型
--传入价格为CNY
function IBLogic.GetPrice(nPrice, sKey)
    local sDef = "CNY"
    if Login.IsOversea() then
        sKey = sKey or "USD"
        sDef = "USD"
    else
        sKey = sKey or "CNY"

        if sKey == "CNY" then return nPrice end
    end

    local tbPriceList = IBLogic.GetPriceConfig(nPrice)
    if not tbPriceList then return 999999 end
    if not tbPriceList.tbPrice then return 999999 end

    local nDef = 999999
    for k,v in pairs(tbPriceList.tbPrice) do
        if k == sKey then return v end
        if k == sDef then nDef = v end
    end

    return nDef
end

--传入价格为美元
function IBLogic.GetPriceUSD(nPrice, sKey)
    local sDef = "CNY"
    if Login.IsOversea() then
        sKey = sKey or "USD"
        sDef = "USD"
    else
        sKey = sKey or "CNY"
    end

    nPrice = (nPrice or 0) * 100
    local tbPriceList = IBLogic.GetPriceConfig(nPrice, true)
    if not tbPriceList then return 999999 end
    if not tbPriceList.tbPrice then return 999999 end

    local nDef = 999999
    for k,v in pairs(tbPriceList.tbPrice) do
        if k == sKey then return v end
        if k == sDef then nDef = v end
    end

    return nDef
end

--获取货币对应的价格和符号
function IBLogic.GetMoneyFormat(nPrice, nType)
    local tbLanguage = IBLogic.GetMoneyFlag()
    if not tbLanguage or #tbLanguage ~= 2 then
        return string.format("%d", nPrice)
    end

    nPrice = IBLogic.GetPrice(nPrice, tbLanguage[1])
    if nType == 1 then -- "CNY 30"
        return string.format("%s %d", tbLanguage[1], nPrice)
    elseif nType == 2 then -- "CNY","¥", 30
        return tbLanguage[1], tbLanguage[2], nPrice
    end

    return string.format("%s%d", tbLanguage[2], nPrice) -- "¥30"
end

--获取价格和文字图标
function IBLogic.GetPriceInfo(tbCost)
    if not tbCost or #tbCost ~= 2 then 
        if Login.IsOversea() then
            return "USD", "$", 99999999
        else
            return "CNY", "¥", 99999999
        end
    end

    if tbCost[1] ~= Cash.MoneyType_RMB then 
        return "", "", tbCost[2]
    end

    return IBLogic.GetMoneyFormat(tbCost[2], 2)
end

--获取游戏货币的价格信息
function IBLogic.GetRealPrice(tbConfig)
    if not  tbConfig then return end

    local tbCost = Copy(tbConfig.tbCost)
    local nOffRate = tbConfig.nOffRate
    if not tbCost or #tbCost < 2 then
        return
    end

    --结束折扣？
    if nOffRate <= 0 or not IsInTime(tbConfig.nOffStartTime, tbConfig.nOffEndTime) then
        return tbCost
    end

  --  if tbCost[1] == Cash.MoneyType_RMB then return tbCost end

    local  tbRet = {tbCost[1], tbCost[2]}
    if nOffRate and nOffRate > 0 then
        tbRet[2] = math.floor(tbCost[2] * nOffRate * 0.01)
    end

    return tbRet
end

--task
function IBLogic.GetBuyNum(nGoodsId)
    if not nGoodsId then return 999999999 end

    return me:GetAttribute(IBLogic.BuyGroupId, nGoodsId)
end

function IBLogic.GetMonthCardTime()
    return me:GetAttribute(IBLogic.BuyGroupId, IBLogic.nMonthCardTask)
end

--ui相关
--- 获取所有组别
function IBLogic.GetAllGroup()
    local tbList = {}
    for k,tbInfo in pairs(IBLogic.tbIbShopGroup) do
        tbList[k] = IBLogic.GetGroupList(k) or {}
    end

    return tbList
end

--- 获取所有组别
function IBLogic.GetGroupList(nCurGroup)
    if not nCurGroup then return end

    local tbList = {}
    local tbInfo = IBLogic.tbIbShopGroup[tonumber(nCurGroup)] or {}
    for i,v in ipairs(tbInfo) do
        if v.nWidgetType == IBLogic.Tab_Recommend then
            local tbParam = v and v.tbUIParam or {}
            if #tbParam >= 2 and tbParam[1] == 2 then 
                if not IBLogic.CheckProductSellOut(tbParam[2]) then
                    table.insert(tbList, v)
                end
            end
        else
            table.insert(tbList, v)
        end
    end

    return tbList
end

--- 获取单类型商城 只取一个
function IBLogic.GetWidgetTypeShop(nWidgetType)
    if not nWidgetType then return end

    for k,v in pairs(IBLogic.tbIbShopList) do
        if v and v.nWidgetType == nWidgetType then
            return v
        end
    end
end

--购买函数
function IBLogic.BuyIbGoods(nGoodsId, nType)
    local ibItem = IBLogic.GetIBGoods(nGoodsId or 0)
    if ibItem == nil then
        return UI.ShowMessage("error.BadParam")
    else
        IBLogic.DoBuyProduct(nType or IBLogic.Type_IBMoney, ibItem.nGoodsId)
    end
end

--获取月卡可购买数量 拥有数量
function IBLogic.GetMonthCardData(tbConfig)
    local nShowNum = 0
    local nHaveNum = 0
    local nDayNum = IBLogic.GetMonthDay()
    if tbConfig then
        nShowNum = tbConfig.tbParam and tbConfig.tbParam[1] or 0
    end

    local nDisTime = math.ceil(IBLogic.GetMonthCardTime() - GetTime())
    if nDisTime > 0 then
        nHaveNum = math.ceil(math.ceil(nDisTime/86400) / nDayNum)
    end
    return nShowNum, nHaveNum
end

--获取可拥有数量(目前只有月卡有限制)
function IBLogic.GetLimitHaveNum(tbGoods)
    if not tbGoods then return 0 end

    if tbGoods.nType == IBLogic.Type_IBMonth then
        return tbGoods.tbParam and tbGoods.tbParam[1] or 0
    end

    return 0
end

--商店跳转
function IBLogic.GotoMall(nType)
    local bOk, tbDesc = FunctionRouter.IsOpenById(FunctionType.Mall)
    if not bOk then
        UI.ShowMessage(tbDesc and tbDesc[1] or "")
        return 
    end

    local sUI = UI.GetUI("Mall")
    if not nType then
        if not sUI then
            IBLogic.OpenMallUI(nMallId)
        end
        return
    end

    for k,v in pairs(IBLogic.tbIbShopList) do
        if v and v.nWidgetType == nType then
            if sUI and sUI:IsOpen() then
                sUI:GotoMall(v.nShopId)
            else
                IBLogic.OpenMallUI(v.nShopId)
            end
            return true
        end
    end
end

--获取商店信息
function IBLogic.GetIBShowGoods(nShopId)
    local tbList = IBLogic.GetIBShopGoods(nShopId)
    if not tbList or #tbList == 0 then return {} end

    local tbRetList = {}
    local tbSellOut = {{},{},{},{}}
    for i,v in ipairs(tbList) do
        if IsInTime(v.nStartTime, v.nEndTime) then
            if IBLogic.CheckProductSellOut(v.nGoodsId) then
                local tbRet = tbSellOut[4]
                if v.nLimitType > 0 and tbSellOut[v.nLimitType] then
                    tbRet = tbSellOut[v.nLimitType]
                end

                table.insert(tbRet, v)
            else
                if v.nPreId == 0 or IBLogic.CheckProductSellOut(v.nPreId) then
                    table.insert(tbRetList, v)
                end
            end
        end
    end

    table.sort(tbRetList, function(a, b) 
        if a.nIndex == b.nIndex then
            return a.nGoodsId < b.nGoodsId
        else
            return a.nIndex < b.nIndex
        end
    end)

    for i,tbRet in ipairs(tbSellOut) do
        table.sort(tbRet, function(a, b)
            if a.nIndex == b.nIndex then
                return a.nGoodsId < b.nGoodsId
            else
                return a.nIndex < b.nIndex
            end
        end)

        for i,v in ipairs(tbRet) do
            table.insert(tbRetList, v)
        end
    end

    return tbRetList
end

--判断商品是否已经购买完
function IBLogic.CheckProductSellOut(nGoodsId)
    if not nGoodsId then return true end

    local tbGoodsInfo = IBLogic.GetIBGoods(nGoodsId)
    if not tbGoodsInfo then return true end

    if tbGoodsInfo.nLimitTimes > 0 and  IBLogic.GetBuyNum(nGoodsId) >= tbGoodsInfo.nLimitTimes then
        return true
    end
end

--获取月卡签到赠送数据金数量
function IBLogic.GetMonthSignAward()
    local info = UE4.UItem.FindTemplate(table.unpack(IBLogic.tbMonthSignItem))
    if info.LuaType ~= "monthcard_box" then
        return 0
    end
    
    return info.Param2 or 0
end

--获取月卡天数
function IBLogic.GetMonthDay()
    local info = UE4.UItem.FindTemplate(table.unpack(IBLogic.tbMonthSignItem))
    if info.LuaType ~= "monthcard_box" then
        return IBLogic.DefaultMonthlyDay
    end
    
    return info.Param1 or IBLogic.DefaultMonthlyDay
end

--检查是否月卡本体
function IBLogic.CheckMonthItem(tbGDPL)
    if type(tbGDPL) ~= "table" then return end
    if #tbGDPL < 4 then return end

    local nSame = 0
    for i=1,4 do
        if tbGDPL[i] == IBLogic.tbMonthSignItem[i] then
            nSame = nSame + 1
        end
    end

    return nSame == 4
end

--检查主界面红点
function IBLogic.CheckMainRed()
    return IBLogic.CheckAllBox()
end

--检查是否有免费礼包未购买
function IBLogic.CheckAllBox()
    for i,v in pairs(IBLogic.tbIbGoods or {}) do
        if IBLogic.CheckFreeBox(v) then
            return true
        end
    end
end

--检查是否有免费礼包未购买
function IBLogic.CheckShopBox(nShopId)
    local tbList = IBLogic.GetIBShopGoods(nShopId)
    for i,v in pairs(tbList or {}) do
        if IBLogic.CheckFreeBox(v) then
            return true
        end
    end
end

--检查是否有免费礼包未购买
function IBLogic.CheckFreeBox(tbGoods)
    if not tbGoods or tbGoods.nType ~= IBLogic.Tab_IBGift then return end

    if  IBLogic.CheckProductSellOut(tbGoods.nGoodsId) then return end

    if not tbGoods.tbCost or #tbGoods.tbCost < 2 then
        return true
    elseif tbGoods.tbCost[2] == 0 then
        return true
    end
end

--获取皮肤商品
function IBLogic.GetSkinItem(tbConfig)
    if not tbConfig then return end
    if not tbConfig.tbItem or #tbConfig.tbItem < 4 then return end

    local info = UE4.UItem.FindTemplate(table.unpack(tbConfig.tbItem))
    if info.LuaType ~= "itembox" then
        return {tbConfig.tbItem}
    end

    if not info.Param1 then return end

    local tbBox = Item.tbBox[info.Param1]
    if not tbBox then
        return
    end

    local checkMoney = function(tbItem, tbInfo)
        if not tbInfo or not tbItem then return end

        if tbItem.LuaType == "money_box" and tbItem.Param1 then
            return {Cash.MoneyType_Money, tbItem.Param1 * (tbInfo[5] or 1)}
        elseif tbItem.LuaType == "gold_box" and tbItem.Param1 then
            return {Cash.MoneyType_Gold, tbItem.Param1 * (tbInfo[5] or 1)}
        end
    end

    local tbItem = {}
    for _, tbInfo in pairs(tbBox) do
        for _, tbcfg in pairs(tbInfo) do
            for _, item in ipairs(tbcfg) do
                local data = item.tbGDPLN
                data[5] = data[5] or 1
                local info1 = UE4.UItem.FindTemplate(data[1], data[2], data[3], data[4])
                local tbInfo = checkMoney(info1, data)
                if tbInfo then
                    table.insert(tbItem, tbInfo)
                elseif data[1] == Item.TYPE_CARD_SKIN then
                    table.insert(tbItem, 1, data)
                else
                    table.insert(tbItem, data)
                end
            end
        end
    end

    return tbItem
end

----登陆获取当前区域信息
function IBLogic.LoginGetRegion()
    IBLogic.XGSDK_Area = nil
    UE4.UGameLibrary.GetIpRegion({GetGameIns(),function(bp,areaCode)
        print("IBLogic.LoginGetRegion ====", areaCode)
        IBLogic.XGSDK_Area = areaCode
    end})
end

----获取当前区域信息 转换为本地一样
function IBLogic.GetRegion()
    if not Login.IsOversea() then --国服固定
        return "CN"
    end

    if not IBLogic.XGSDK_Area then
        return "US"
    end

    if IBLogic.XGSDK_Area == "CN" then
        return "US"
    end

    return IBLogic.XGSDK_Area
end


----打开商城界面
function IBLogic.OpenMallUI(nMallId)
    if not UE4.UGameLibrary.OpenGameStore then 
        print("IBLogic.OpenMallUI  function OpenGameStore nil")
        return 
    end

    IBLogic.nOpenMallID = nMallId
    UE4.UGameLibrary.OpenGameStore({GetGameIns(),function(bp,age)
        if age == "error" and not IBLogic.GMSkipAgeLimit then
            UI.ShowTip("tip.ageLimited")
        else
            UI.Open("Mall", IBLogic.nOpenMallID)
        end
        IBLogic.nOpenMallID = nil
    end})
end

function IBLogic.GMOpenAgeLimit()
    if not IBLogic.GMSkipAgeLimit then
        IBLogic.GMSkipAgeLimit = true
    else
        IBLogic.GMSkipAgeLimit = false
    end
end

--获取当前月卡天数（计算后
function IBLogic.GetHasMonthlyDay()
    local nDisTime = IBLogic.GetMonthCardTime()
    if nDisTime < GetTime() then
        return 0
    end

    local nDay = TimeDiff(nDisTime, GetTime())
    return nDay
end

---------------------------
--绑定sdk返回错误
function IBLogic.BindSdkEvent()
    local doMsg = function(sMsg, sType, nCode)  
            xpcall(function()
            if sType ~= Event.SdkPayProgress then
                IBLogic.DoClosePayUI()
            end

            if nCode == -213 then
                UI.ShowMessage("tip.purchase.Error")
                return
            end

           local tbMsg =  json.decode(sMsg)
           if tbMsg and tonumber(tbMsg.code) == -213 then
                UI.ShowMessage("tip.purchase.Error")
                return
            end
           if tbMsg and tbMsg.msg then
                UI.ShowMessage(tbMsg.msg)
            end
        end, function(err)
            if string.find(sMsg, "Succes") then
                UI.ShowMessage("ui.xgsdk.Succes")
            elseif string.find(sMsg, "canceled") then
                UI.ShowMessage("ui.xgsdk.Canceled")
            elseif string.find(sMsg, "too frequently") then
                UI.ShowMessage("ui.xgsdk.Frequently")
            elseif string.find(sMsg, "failed") then
                UI.ShowMessage("ui.xgsdk.Pailed")
            else
                print("xgsdk ---", msg)
            end
        end)
    end

    IBLogic.nSdkPaySuccess = EventSystem.On(Event.SdkPaySuccess, function(code, msg)
        doMsg(msg, Event.SdkPaySuccess,code)
    end)
    IBLogic.nSdkPayFail = EventSystem.On(Event.SdkPayFail, function(code, msg)
        doMsg(msg, Event.SdkPayFail,code)
    end)
    IBLogic.nSdkPayCancel = EventSystem.On(Event.SdkPayCancel, function(code, msg)
        doMsg(msg, Event.SdkPayCancel,code)
    end)
    IBLogic.nSdkPayProgress = EventSystem.On(Event.SdkPayProgress, function(code, msg)
        doMsg(msg, Event.SdkPayProgress,code)
    end)
    IBLogic.nSdkPayOthers = EventSystem.On(Event.SdkPayOthers, function(code, msg)
        doMsg(msg, Event.SdkPayOthers,code)
    end)
end

--购买充值商品
function IBLogic.DoBuyProduct(nType, nGoodsId)
    if not nType or not nGoodsId then return end

    -- 上报OnSelectProduct事件
    local ibItem = IBLogic.GetIBGoods(nGoodsId)
    if ibItem then 
        local productid = ibItem.sIosId
        if not IsIOS() then 
            productid = ibItem.sAndroidId
        end
        if productid then 
            UE4.UGameLibrary.ReportSelectProduct(productid)
        end
    end

    UI.ShowConnection()
    me:CallGS("IBLogic_BuyGoods", json.encode({nType = nType, nGoodsId = nGoodsId, nCount = 1}))
end

--构建PayInfo信息
function IBLogic.MakePayInfo(tbParam, payInfo)
    if not tbParam or not payInfo then
        return
    end

    local ibItem = IBLogic.GetIBConfig(tbParam.sProductId)
    if not ibItem then
        return 
    end

    local sItemName = ibItem.sItemName
    if not sItemName then
        local iteminfo = UE4.UItem.FindTemplate(ibItem.tbItem[1], ibItem.tbItem[2], ibItem.tbItem[3], ibItem.tbItem[4])
        if iteminfo then
            sItemName = iteminfo.I18N
        end
    end

    local sUnit = IBLogic.GetPriceInfo(ibItem.tbCost)
    
    payInfo.ProductId = tbParam.sProductId
    payInfo.ProductName = Text(sItemName or "Null")
    payInfo.ProductDesc = Text(sItemName or "Null")
    payInfo.Currency = "CNY"
    payInfo.Price = tbParam.nTotalPrice * 100

    local localCurrency = payInfo.Currency
    local localPrice = payInfo.Price
    if Login.IsOversea() then
        localCurrency = sUnit or "USD"
        localPrice = math.floor(IBLogic.GetPrice(tbParam.nTotalPrice or 0, localCurrency) * 100)
    end
    payInfo.CustomInfo = "political"
    payInfo.GameTradeNum = tbParam.sTradeNo
    payInfo.CallbackUrl = tbParam.sPayUrl or ""
    UE4.UGameLibrary.ReportCreateOrder(payInfo.ProductId, '1', tbParam.sTradeNo, '0', 'success')
    payInfo.AddParams = json.encode({LocalProductName = payInfo.ProductName, LocalCurrencyName = localCurrency, LocalPayAmount =  tostring(localPrice)})
    return true
end

--新增西瓜支付时的蒙版
function IBLogic.DoShowPayUI()
    if IBLogic.nShowTimer then
        return
    end

    UI.ShowConnection()
    IBLogic.nShowTimer = UE4.Timer.Add(30, IBLogic.DoClosePayUI)
end

--关闭蒙版
function IBLogic.DoClosePayUI()
    if IBLogic.nShowTimer then
        UE4.Timer.Cancel(IBLogic.nShowTimer)
    end
    IBLogic.nShowTimer = nil
    UI.CloseConnection()
end

---获取充值订单
s2c.Register('IBLogic_OpenPayment', function(tbParam)
    UI.CloseConnection()
    if not tbParam then 
        UI.ShowTip("error.BadParam")
        return 
    end

    local payInfo = UE4.FIbItemInfo()
    if not IBLogic.MakePayInfo(tbParam, payInfo) then
        return UI.ShowTip("error.BadProductId")
    end

    UE4.UGameLibrary.Pay(payInfo)
    if WITH_XGSDK then
        IBLogic.DoShowPayUI()
    end
    Adjust.DoRecord("8168l0")
end)

---获取充值订单
s2c.Register('IBLogic_ChangeLimit', function(tbParam)
    UI.CloseConnection()
    if not tbParam then 
        UI.ShowTip("error.BadParam")
        return 
    end

    if tbParam.nLimit then
        IBLogic.LimitBuy = tbParam.nLimit
    end
end)

---购买商品后刷新页面
s2c.Register('IBLogic_BuyGoods',function(tbParam)
    UI.CloseConnection()
    Audio.PlayVoices("PaySuccess")

    local sUI = UI.GetUI("RoleFashionPreview")
    if sUI and sUI:IsOpen() then
        UI.Close("RoleFashionPreview")
    end

    if tbParam and tbParam.tbGoods then
        local tbShowItems = ShopLogic.GetActualItems(tbParam.tbGoods)
        if type(tbShowItems) == "table" then
            Item.Gain(tbShowItems)
        end
    end

    sUI = UI.GetUI("Mall")
    if sUI and sUI:IsOpen() then
        sUI:OnByGoodsUpdate()
    end

    sUI = UI.GetUI("RoleFashion")
    if sUI and sUI:IsOpen() then
        sUI:OnByGoodsUpdate()
    end

    sUI = UI.GetUI("RoleFashion")
    if sUI and sUI:IsOpen() then
        sUI:OnByGoodsUpdate()
    end

    sUI = UI.GetUI("BPMain")
    if sUI and sUI:IsOpen() then
        sUI:OnReceiveUpdate()
    end

    EventSystem.Trigger(Event.IBShopBuyGoods)

    Adjust.MallRecord(tbParam and tbParam.sProductId)

    local payInfo = UE4.FIbItemInfo()
    if not IBLogic.MakePayInfo(tbParam, payInfo) then
        return
    end

    if UE4.UGameLibrary.OnPayFinish then
        UE4.UGameLibrary.OnPayFinish(payInfo)
    end
end)

---登陆获取区域信息
EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    IBLogic.LoginGetRegion()
    if IBLogic.nShowTimer then
        IBLogic.DoClosePayUI()
    end
end)

IBLogic.LoadIBConf()
IBLogic.BindSdkEvent()
