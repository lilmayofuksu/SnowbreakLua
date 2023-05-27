-- ========================================================
-- @File	: Recycle.lua
-- @Brief	: 道具回收统一流程
-- ========================================================

---道具回收相关
---@field tbConfig table 回收配置
---@field tbLevelExp table 各类物品对应等级的经验
---@field tbExpSuplies table 各类物品的经验耗材
ItemRecycle =
    ItemRecycle or
    {
        tbConfig = {},
        tbLevelExp = {},
        tbExpSuplies = {}
    }

---回收功能w初始化
function ItemRecycle.Init()
    -- 读取配置
    local tbFile = LoadCsv("item/recycle.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nID = tonumber(tbLine.ID)
        local tbCfg = {
            tbRecycleReward = Eval(tbLine.RecycleReward),
            nRecycleBase = tonumber(tbLine.RecycleBase) or 0,
            nRecycleRatio = tonumber(tbLine.RecycleRatio)
        }
        ItemRecycle.tbConfig[nID] = tbCfg
    end
    print("Load ../settings/item/recycle.txt")

    -- 整理经验材料
    local tbWeaponSuplies = {}
    local tbSupportSuplies = {}
    local tbFile = LoadCsv("item/templates/suplies.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nClose = tonumber(tbLine.Close)
        if (not nClose) or nClose == 0 then
            local nProvideExp = tonumber(tbLine.ProvideExp)
            if tbLine.Genre == "5" and tbLine.Detail == "2" and nProvideExp > 0 then
                table.insert(
                    tbWeaponSuplies,
                    {
                        tbGDPL = {
                            tonumber(tbLine.Genre),
                            tonumber(tbLine.Detail),
                            tonumber(tbLine.Particular),
                            tonumber(tbLine.Level)
                        },
                        nProvideExp = nProvideExp
                    }
                )
            elseif tbLine.Genre == "5" and tbLine.Detail == "3" and nProvideExp > 0 then
                table.insert(
                    tbSupportSuplies,
                    {
                        tbGDPL = {
                            tonumber(tbLine.Genre),
                            tonumber(tbLine.Detail),
                            tonumber(tbLine.Particular),
                            tonumber(tbLine.Level)
                        },
                        nProvideExp = nProvideExp
                    }
                )
            end
        end
    end
    local fSort = function(a, b)
        return a.nProvideExp > b.nProvideExp
    end
    table.sort(tbWeaponSuplies, fSort)
    table.sort(tbSupportSuplies, fSort)
    ItemRecycle.tbExpSuplies[Item.TYPE_WEAPON] = tbWeaponSuplies
    ItemRecycle.tbExpSuplies[Item.TYPE_SUPPORT] = tbSupportSuplies

    local nCurExp = 0
    ItemRecycle.tbLevelExp[Item.TYPE_WEAPON] = {}
    for nLevel, nExp in ipairs(Item.tbUpgradeExp[Item.TYPE_WEAPON]) do
        ItemRecycle.tbLevelExp[Item.TYPE_WEAPON][nLevel] = nCurExp
        nCurExp = nCurExp + nExp
    end

    nCurExp = 0
    ItemRecycle.tbLevelExp[Item.TYPE_SUPPORT] = {}
    for nLevel, nExp in ipairs(Item.tbUpgradeExp[Item.TYPE_SUPPORT]) do
        ItemRecycle.tbLevelExp[Item.TYPE_SUPPORT][nLevel] = nCurExp
        nCurExp = nCurExp + nExp
    end

    print("ItemRecycle initialized.")
end

---获得道具回收配置
---@param pItem UItem
---@return table 相应配置，找不到配置或不可回收则返回nil
function ItemRecycle.GetConfig(pItem)
    local pTemplate = UE4.UItem.FindTemplateForID(pItem:TemplateId())
    if not (pTemplate and pTemplate.RecycleID > 0) then
        return
    end
    return ItemRecycle.tbConfig[pTemplate.RecycleID]
end

---获得对应道具回收必得奖励
---@param pItem UItem
---@return table 奖励列表，无奖励返回nil
function ItemRecycle.GetRewards(pItem)
    local tbCfg = ItemRecycle.GetConfig(pItem)
    if not (tbCfg and tbCfg.tbRecycleReward) then
        return
    end
    return Copy(tbCfg.tbRecycleReward)
end

---获得对应物品等级回收奖励
---@param pItem UItem
---@return table 奖励列表,无奖励返回nil
function ItemRecycle.GetLevelRewards(pItem)
    if pItem:Genre() ~= Item.TYPE_WEAPON and pItem:Genre() ~= Item.TYPE_SUPPORT then
        return
    end

    local tbCfg = ItemRecycle.GetConfig(pItem)
    if not tbCfg or not tbCfg.nRecycleRatio or not tbCfg.nRecycleBase then
        return
    end

    local nExp = tbCfg.nRecycleBase + (ItemRecycle.tbLevelExp[pItem:Genre()][pItem:EnhanceLevel()] or 0)
    nExp = nExp * tbCfg.nRecycleRatio

    --- 武器与后勤返还通用银，返还公式为 “折算后经验值 X 0.5”
    local tbSilverAward = nil
    if pItem:IsWeapon() or pItem:IsSupportCard() then
        local nSilver = math.modf(nExp * 0.5)
        if nSilver > 0 then
            tbSilverAward = {3, nSilver}
        end
    end

    local tbRewards = nil

    -- 经验转换奖励
    local tbSuplies = ItemRecycle.tbExpSuplies[pItem:Genre()]
    if tbSuplies then
        local nDesire = nExp
        for _, tbCfg in ipairs(tbSuplies) do
            local nCount = math.modf(nDesire / tbCfg.nProvideExp)
            if nCount > 0 then
                nDesire = nDesire - (nCount * tbCfg.nProvideExp)
                tbRewards = tbRewards or {}
                table.insert(tbRewards, {tbCfg.tbGDPL[1], tbCfg.tbGDPL[2], tbCfg.tbGDPL[3], tbCfg.tbGDPL[4], nCount})
            end
        end
    end

    if tbSilverAward then
        tbRewards = tbRewards or {}
        table.insert(tbRewards, tbSilverAward)
    end

    return tbRewards
end

---获得对应道具突破回收奖励
---@param pItem UItem
---@return table 奖励列表,无奖励返回nil
function ItemRecycle.GetBreakRewards(pItem)
    if pItem.Break == 0 then
        return
    end
    local pTemplate = UE4.UItem.FindTemplateForID(pItem:TemplateId())
    if not (pTemplate and pTemplate.BreakMatID) then
        return
    end
    local tbMaterials = Item.tbBreakMaterials[pTemplate.BreakMatID]
    if (not tbMaterials) or #tbMaterials == 0 then
        return
    end
    local tbRewards = {}
    for nBreak, tbItems in ipairs(tbMaterials) do
        if pItem:Break() < nBreak then
            break
        end
        if tbItems then
            for _, tbItem in ipairs(tbItems) do
                table.insert(tbRewards, Copy(tbItem))
            end
        end
    end
    return tbRewards
end

--- 计算回收产出
function ItemRecycle.CalcRewards(tbItems)
    local tbRewards = {}
    local tbRecycles = {}

    local funAddAward = function(tbRes, tbTmpReward, pItem, nCount)
        if not tbTmpReward then
            return 0
        end
        local nAdded = 0
        for _, reward in ipairs(tbTmpReward) do
            if #reward >= 4 then
                reward[5] = (reward[5] or 1) * nCount
            elseif #reward == 2 then
                reward[2] = reward[2] * nCount
            end
            table.insert(tbRes, reward)
            nAdded = nAdded + 1
        end
        return nAdded
    end

    for _, tbParam in ipairs(tbItems) do
        local pItem = tbParam.pItem or me:GetItem(tbParam.nId)
        if not pItem then
            UI.ShowTip("error.Recycle.ItemNotExists")
            return
        elseif pItem:Count() < tbParam.nCount then
            UI.ShowTip("error.Recycle.ItemNotEnough")
            return
        elseif pItem:Expiration() ~= 0 and pItem:Expiration() <= GetTime() then -- 活动物品不过期不给回收
            UI.ShowTip("error.Recycle.ItemNotExpiration")
            return
        else
            local nAdded = 0
            nAdded = nAdded + funAddAward(tbRewards, ItemRecycle.GetRewards(pItem), pItem, tbParam.nCount)
            nAdded = nAdded + funAddAward(tbRewards, ItemRecycle.GetLevelRewards(pItem), pItem, tbParam.nCount)
            if not (pItem:IsWeapon() or pItem:IsSupportCard()) then
                nAdded = nAdded + funAddAward(tbRewards, ItemRecycle.GetBreakRewards(pItem), pItem, tbParam.nCount)
            end
            if nAdded == 0 then
                UI.ShowTip("error.Recycle.ItemCanNotRecycle")
                return
            end
            table.insert(tbRecycles, {pItem = pItem, nCount = tbParam.nCount})
        end
    end

    tbRewards =
        MergeSimilarList(
        tbRewards,
        function(tbA, tbB)
            if #tbA ~= #tbB then
                return #tbA - #tbB
            end
            local nEnd = #tbA - 1
            for i = 1, nEnd do
                if tbA[i] ~= tbB[i] then
                    return tbA[i] - tbB[i]
                end
            end
            return 0
        end,
        function(tbA, tbB)
            local tb = Copy(tbA)
            if #tbA == 2 and #tbB == 2 then
                tb[2] = tbA[2] + tbB[2]
            else
                tb[5] = tbA[5] + tbB[5]
            end
            return tb
        end
    )

    return tbRewards, tbRecycles
end

---------------------------------初始化----------------------------------------
ItemRecycle.Init()
