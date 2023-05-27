-- ========================================================
-- @File    : Item.lua
-- @Brief   : 道具相关接口
-- ========================================================

---C++调用item脚本层的接口
---@class Item
---@field tbUpgradeExp table 升级经验配置表
---@field tbBreakMaterials table 突破材料配置表
---@field tbBreakLevelLimit table 突破次数限制最高等级
---@field tbCardLevelLimit table 指挥官等级限制道具升级突破
---@field tbCharacterCard2Piece table 角色卡同卡分解碎片
---@field tbIcon table Icon配置表
---@field tbCardLimitWeapon table 角色对应的武器
---@field tbQualIcon table 品质Icon配置表
---@field tbLogoIcon table 后勤卡LogoIcon配置表
---@field tbCardIcon table 后勤卡或者角色卡Icon配置表
---@field tbBox table 道具箱子表
---@field tbDetail2I18n table 角色Detail对应I18n表
---@field tbLockShow table 角色对应的限制显示时间
Item =
    Item or
    {
        tbUpgradeExp = {},
        tbBreakMaterials = {},
        tbBreakLevelLimit = {},
        tbCardLevelLimit = {},
        tbCharacterCard2Piece = {},
        tbIcon = {},
        tbCardLimitWeapon = {},
        tbQualIcon = {},
        tbLogoIcon = {},
        tbCardIcon = {},
        tbBox = {},
        tbExchange = {},
        tbDetail2I18n = {},
        tbLockShow = {},
        tbOthers = {},
    }

---道具类型
Item.TYPE_CARD = 1 -- 角色卡
Item.TYPE_WEAPON = 2 -- 武器卡
Item.TYPE_SUPPORT = 3 -- 后勤卡
Item.TYPE_USEABLE = 4 -- 可使用道具
Item.TYPE_SUPPLIES = 5 -- 消耗类道具
Item.TYPE_WEAPON_PART = 6 -- 武器配件
Item.TYPE_CARD_SKIN = 7 -- 角色皮肤
Item.TYPE_HOUSE = 8 -- 宿舍家具

Item.SLOT_SUPPORTERCARD1 = 1 -- 后勤卡
Item.SLOT_SUPPORTERCARD2 = 2 -- 后勤卡
Item.SLOT_SUPPORTERCARD3 = 3 -- 后勤卡
Item.SLOT_WEAPON_PARTS = 4 -- 武器配件

---道具标记
Item.FLAG_USE       = 1 -- 使用中
Item.FLAG_LOCK      = 2 -- 锁定中
Item.FLAG_READED    = 4 -- 道具已查看
Item.FLAG_LEAVE     = 8 -- 角色大招后离场

Item.MaxItemCount   = 99999  --道具的最大拥有数量

--道具使用类型
Item.AutoUse =  1 --自动使用
Item.UserUse =   2 --玩家使用

--- 武器类型图标
Item.WeaponTypeIcon = {1400004, 1400001, 1400003, 1400002, 1400000, 1400005}
--- 武器品质条
Item.WeaponColorIcon = {1700066, 1700066, 1700067, 1700068, 1700069, 1700069}
--- 后勤类型图标
Item.SupportTypeIcon = {1200000, 1200001, 1200002}
--- 道具展示列表的品质条
Item.ItemListColorIcon = {1700011, 1700012, 1700013, 1700014, 1700015, 1700016}
--- 道具信息展示的条形品质条
Item.ItemInfoColorIcon = {1700041, 1700042, 1700043, 1700044, 1700045, 1700046}
--- 道具图标展示的品质条
Item.ItemIconColorIcon = {1700001, 1700002, 1700003, 1700004, 1700005, 1700006}
--- 商店道具条形品质
Item.ItemShopColorIcon = {1701064, 1701065, 1701066, 1701067, 1701068, 1701069}
--- 商店道具条形品质2
Item.ItemShopColorIcon2 = {1701144, 1701145, 1701146, 1701147, 1701148, 1701148}
--- 商店道具条形渐变品质
Item.ItemShopChangeColorIcon = {1701070, 1701071, 1701072, 1701073, 1701074, 1701075}
--图鉴角色品质条
Item.RikiRoleColorIcon = {2100211,2100211,2100211,2100212,2100213}
--- 角色卡颜色
Item.RoleColor = {
    1700031,        -- 白
    1700032,        -- 绿
    1700033,        -- 蓝
    1700034,        -- 紫
    1700035,        -- 橙
    1700036,        -- 红
}
--- 角色卡颜色
Item.RoleColor2 = {
    1700061,        -- 白
    1700062,        -- 绿
    1700063,        -- 蓝
    1700064,        -- 紫
    1700065,        -- 橙
    1700065,        -- 橙
}
--- 角色卡颜色
Item.RoleColor3 = {
    1700047,        -- 白
    1700048,        -- 绿
    1700049,        -- 蓝
    1700050,        -- 紫
    1700051,        -- 橙
    1700052,        -- 橙
}
--- 角色卡颜色(短)
Item.RoleColor_short = {
    1700070,        -- 绿
    1700070,        -- 绿
    1700071,        -- 蓝
    1700072,        -- 紫
    1700073,        -- 橙
    1700073,        -- 橙
}
--- 角色卡颜色-武器底板
Item.RoleColorWeapon = {
    1700094,        -- 绿
    1700094,        -- 绿
    1700095,        -- 蓝
    1700096,        -- 紫
    1700097,        -- 橙
    1700097,        -- 橙
}

Item.RoleTrangleAttr = {
    1700092,        -- 生体属性
    1700091,        -- 精神属性
    1700093,        -- 构造属性
}

--- 数字缩略（多语言化）
Item.ConvertNumLocalization = {
    ["en_US"] = 0.001,
    ["it_IT"] = 0.001,
    ["fr_FR"] = 0.001,
    ["es_ES"] = 0.001,
    ["de_DE"] = 0.001,
    ["ru_RU"] = 0.001,
    ["ko_KR"] = 0.0001,
    ["ja_JP"] = 0.0001,
    ["zh_TW"] = 0.0001,
    ["zh_CN"] = 0.0001,
    ["th_TH"] = 0.0001,
    ["id_ID"] = 0.0001,
}

--- 道具类型文本
Item.TypeText = {}
Item.TypeText[Item.TYPE_CARD] = "ui.character"
Item.TypeText[Item.TYPE_WEAPON] = "ui.weapon"
Item.TypeText[Item.TYPE_SUPPORT] = "ui.supporter"
Item.TypeText[Item.TYPE_USEABLE] = "ui.item"
Item.TypeText[Item.TYPE_SUPPLIES] = "ui.item"
Item.TypeText[Item.TYPE_WEAPON_PART] = "ui.weapon_part"
Item.TypeText[Item.TYPE_CARD_SKIN] = "ui.character_skin"
Item.TypeText[Item.TYPE_HOUSE] = "ui.dorm_gift"

--背包的黄点提示
Item.tbBagDot = 
{
    nBagDotGruop = 100,
    nBagDotId = 1,
    tbDot = 
    {
        PAGE_WEAPON = 1,
        PAGE_SUPPORT = 2,
        PAGE_ITEM = 3,
        PAGE_PART = 4,
        PAGE_SUPLIES = 5,
    }
}

----------------------------------Lua 接口---------------------------------------

---获得后勤或武器消耗后返还的经验和通用银
---@param pItem LuaItem 道具
---@return integer 经验数量，通用银数量
function Item.GetExpAndSilverNum(pItem)
    if not pItem:IsWeapon() and not pItem:IsSupportCard() then
        return 0,0
    end

    local tbCfg = ItemRecycle.GetConfig(pItem)
    if not tbCfg or not tbCfg.nRecycleRatio or not tbCfg.nRecycleBase then
        return 0,0
    end

    local nExp = tbCfg.nRecycleBase + (ItemRecycle.tbLevelExp[pItem:Genre()][pItem:EnhanceLevel()] or 0)
    nExp = nExp * tbCfg.nRecycleRatio

    --- 经验打7折并返还通用银，返还公式为 “折算后经验值 X 0.5”
    local nSilver = math.modf(nExp * 0.5)
    return nExp, math.max(0, nSilver)
end

---取得升级需要的经验（忽略已有经验值）
---@param pItem UE4.UItem 道具对象
---@return integer 当前等级升级到下一级需要的经验
function Item.GetUpgradeExp(pItem)
    local tbLevels = Item.tbUpgradeExp[pItem:Genre()]
    if tbLevels then
        return tbLevels[pItem:EnhanceLevel()] or -1
    end
    return -1
end

---跨n个等级升级动态刷新等级以及NextLv经验
---@param pItem UE4.UItem 道具对象
---@return nItemLv integer 当前等级升级到下一级需要的经验
function Item.GetUpgradeExpByLevel(pItem, nItemLv)
    local tbLevels = Item.tbUpgradeExp[pItem:Genre()]
    if tbLevels then
        return tbLevels[nItemLv] or -1
    end
    return -1
end

---取得升级需要的经验，无Item版本
---@param InType integer 道具类型Item.TYPE_xxxx
---@param InLevel integer 当前等级
---@return integer 当前等级升级到下一级需要的经验
function Item.GetExp(InType, InLevel)
    local tbLevels = Item.tbUpgradeExp[InType]
    if tbLevels then
        return tbLevels[InLevel] or -1
    end
    return -1
end

---取得升星材料
---@param InItem UItem 需要突破的卡
---@return table 突破需要的材料
function Item.GetBreakMaterials(InItem)
    local tbCfg = Item.tbBreakMaterials[InItem:BreakMatID()]
    if tbCfg then
        return tbCfg[InItem:Break() + 1]
    end
    return nil
end


---取得道具当前可达到的最大等级
---@param pItem UE4.UItem 道具
---@return integer 返回当前可达到的最大等级
function Item.GetMaxLevel(pItem)
    local CheckLevelLimit = function (LevelLimitID)
        local tbCfg = Item.tbCardLevelLimit[1][LevelLimitID]
        if tbCfg then
            local nNearestAccountLevel = 0
            local nNearestItemLevel = 0
            for _, tbInfo in ipairs(tbCfg) do
                if tbInfo[1] < me:Level() then
                    nNearestAccountLevel = tbInfo[1]
                    nNearestItemLevel = tbInfo[2]
                elseif tbInfo[1] == me:Level() then
                    return tbInfo[2]
                else
                    local nDistance = tbInfo[1] - nNearestAccountLevel
                    local nPercent = (me:Level() - nNearestAccountLevel) * 1.0 / nDistance
                    return math.floor(Lerp(nNearestItemLevel, tbInfo[2], nPercent))
                end
            end
        end
    end
    if pItem:IsCharacterCard() then
        return CheckLevelLimit(pItem:LevelLimitID()) or pItem:EnhanceLevel()
    elseif pItem:IsWeapon() or pItem:IsSupportCard() then
        local BreakLevelLimit = pItem:EnhanceLevel()
        local tbCfg = Item.tbBreakLevelLimit[pItem:BreakLimitID()]
        if tbCfg and tbCfg[pItem:Break() + 1] then
            BreakLevelLimit = tbCfg[pItem:Break() + 1]
        end
        return BreakLevelLimit
    elseif pItem:CanEnhance() then
        return pItem:EnhanceLevel()
    else
        return pItem:Level()
    end
end

--- 设置虚拟道具的属性
function Item.ChangeItemAttr(pItem, bMax)
    if bMax then
        local nBreakMax = Item.GetMaxBreak(pItem)
        local tbCfg = Item.tbBreakLevelLimit[pItem:BreakLimitID()]
        if tbCfg and tbCfg[nBreakMax + 1] then
            local nLvMax = tbCfg[nBreakMax + 1]
            pItem:SetDefaultItemData(nLvMax, nBreakMax, 4)
        end
    else
        pItem:SetDefaultItemData(1, 0, 0)
    end
end

---获取模板道具最大等级
---@param pTemplate FItemTemplate
function Item.GetMaxLevlByTemplate(pTemplate)
    if pTemplate.Genre == 1 then
        local tbCfg = Item.tbCardLevelLimit[1][pTemplate.LevelLimitID]
        return tbCfg and tbCfg[1] or 1 or 1
    elseif pTemplate.Genre == 2 or pTemplate.Genre == 3 then
        local BreaktbCfg = Item.tbBreakLevelLimit[pTemplate.BreakLimitID]
        local BreakLimit = BreaktbCfg and BreaktbCfg[1] or 1 or 1
        return BreakLimit
    else
        return 1
    end
end

---是否突破到最大等级
---@param pItem UItem
function Item.IsBreakMax(pItem)
    local tbCfg = Item.tbBreakLevelLimit[pItem:BreakLimitID()]
    if not tbCfg then
        return true
    end
    if pItem:Break() >= #Item.tbBreakLevelLimit[pItem:BreakLimitID()] - 1 then
        return true
    end
    return false
end

--标记物品已读
function Item.Read(tbItemId)
    if not tbItemId or type(tbItemId) ~= 'table' or #tbItemId == 0 then return end
    local itemList = UE4.TArray(UE4.int64)
    for _, id in ipairs(tbItemId) do
        itemList:Add(id)
    end
    me:ReadItem(itemList)
end

---获得突破最大等级
---@param pItem UItem
function Item.GetMaxBreak(pItem)
    local tbCfg = Item.tbBreakLevelLimit[pItem:BreakLimitID()]
    if not tbCfg then
        return 0
    end
    
    return #Item.tbBreakLevelLimit[pItem:BreakLimitID()] - 1
end

---是否可以突破
function Item.CanBreak(pItem)
    if not pItem then
        return false, "tip.BadParam"
    end


    if pItem:Break() >= #Item.tbBreakLevelLimit[pItem:BreakLimitID()] - 1 then
        return false, "tip.break_condition_inconformity"
    end

    local tbCfg = Item.tbCardLevelLimit[2][pItem:LevelLimitID()]
    if not tbCfg then
        return true
    end
    local maxBreak = 0
    for _, tbInfo in ipairs(tbCfg) do
        if tbInfo[1] <= me:Level() then
            maxBreak = tbInfo[2]
        end
    end
    if maxBreak <= pItem:Break() then
        return false, "tip.break_condition_inconformity"
    end
    return true
end

---得到突破需求的账号等级
function Item.GetBreakDemandLevel(pItem, nBreakNum)
    if not pItem then
        return 0
    end
    local tbCfg = Item.tbCardLevelLimit[2][pItem:LevelLimitID()]
    if not tbCfg then
        return 0
    end
    for _, tbInfo in ipairs(tbCfg) do
        if tbInfo[2] == nBreakNum then
            return tbInfo[1]
        end
    end
    return 0
end

---添加经验后的等级和经验
---@param srcLevel number 当前等级
---@param srcExp number 当前经验
---@param nAdd number 添加的经验
---@param nExpType number 经验类型
---@param maxLevel number 最大等级
---@return number number
function Item.GetItemDestLevel(srcLevel, srcExp, nAdd, nExpType, maxLevel)
    if nAdd == 0 then
        return srcLevel, srcExp
    end
    if maxLevel and srcLevel >= maxLevel then
        return maxLevel, srcExp + nAdd
    end
    local destLevel = srcLevel
    local destExp = srcExp + nAdd
    local needExp = Item.GetExp(nExpType, destLevel)

    while (needExp > 0 and destExp >= needExp) do
        destExp = destExp - needExp
        destLevel = destLevel + 1

        if maxLevel and destLevel >= maxLevel then
            -- 到了当前满级
            return maxLevel, destExp
        else
            -- 没到满级
            needExp = Item.GetExp(nExpType, destLevel)
            if needExp == 0 then
                return destLevel, destExp
            end
        end
    end
    return destLevel, destExp
end

---获得道具
function Item.Gain(tbItems)
    if not tbItems or type(tbItems) ~= 'table' then return end
    if next(tbItems) ~= nil then
        UI.Open("GainItem", tbItems)
    end
end

--道具过期提示
--param luaItem数组 {pItem,...}
function Item.Expiration(tbItems)
    if next(tbItems) == nil then
        return
    end

    local tbShowItem = {} --展示用GDPL
    local tbRecycleItem = {} --回收用ID
    for _, pItem in ipairs(tbItems) do
        table.insert(tbShowItem, {pItem:Genre(), pItem:Detail(), pItem:Particular(), pItem:Level(), pItem:Count()})
        table.insert(tbRecycleItem, {nId=pItem:Id(), nCount=pItem:Count()})
    end

    local function ItemRecycle()
        me:CallGS("Item_Recycle", json.encode({tbItems = tbRecycleItem}))
    end

    UI.Open("GainItem", tbShowItem, ItemRecycle, false, false, true)
end

--- 数据显示
function Item.AboveNum(InNum)
    if InNum>999 then
        return "999+"
    end
    return InNum
end

--将大于等于10000的数字转换为x.x万/ x.x k的形式
function Item.ConvertNum(nNum)
    if not nNum then return 0 end

    if nNum < 10000 then
        return nNum
    end

    local sCurLan = Localization.GetCurrentLanguage()
    if Item.ConvertNumLocalization[sCurLan] then  
        nNum = nNum * Item.ConvertNumLocalization[sCurLan]
    end
    return string.format("%.1f", nNum).. Text("ui.TenThousand")
end

---是否为可选的道具箱
---@param pItem UE4.UItem 道具对象
function Item.IsSelectBox(pItem)
    local info = UE4.UItem.FindTemplate(pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level())
    if info.LuaType ~= "itembox" or info.Param1 == nil then
        return false
    end
    local tbObtainType = Item.tbBox[info.Param1]
    if tbObtainType and tbObtainType["Select"] and next(tbObtainType["Select"])~=nil then
        return true
    end
    return false
end

---是否为道具箱
---@param pItem UE4.UItem 道具对象
function Item.IsItemBox(pItem)
    local info = UE4.UItem.FindTemplate(pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level())
    if info.LuaType ~= "itembox" or info.Param1 == nil then
        return false
    end
    return true
end

--是否体力恢复药剂
---@param pItem UE4.UItem 道具对象
function Item.IsVigorItem(pItem)
    local info = UE4.UItem.FindTemplate(pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level())
    if info.LuaType ~= "vigor_box" or info.Param1 == nil then
        return false
    end
    return true
end

--是否货币兑换箱
---@param pItem UE4.UItem 道具对象
function Item.IsCashBox(pItem)
    local info = UE4.UItem.FindTemplate(pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level())
    if info.LuaType ~= "token_box" or info.Param1 == nil then
        return false
    end
    return true
end

--是否月卡手动使用箱子
---@param pItem UE4.UItem 道具对象
function Item.IsMonthlyCardBox(pItem)
    if not pItem then return false end

    local info = UE4.UItem.FindTemplate(pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level())
    if info.LuaType ~= "itembox" or info.Param1 == nil then
        return false
    end

    local nUseMode = Item.GetOthersUseMode(pItem:Genre(),pItem:Detail(),pItem:Particular(),pItem:Level()) or 0
    if nUseMode ~= Item.UserUse then
        return false
    end

    local tbConfig = Item.tbBox[info.Param1]
    if not tbConfig then return false end

    for _, tbInfo in pairs(tbConfig) do
        for _, tbcfg in pairs(tbInfo) do
            for _, item in ipairs(tbcfg) do
                local data = item.tbGDPLN or {}
                local info1 = UE4.UItem.FindTemplate(data[1], data[2], data[3], data[4])
                if info1.LuaType == "monthcard_box" and info1.Param1 then
                    return true
                end
            end
        end
    end

    return false
end

---获取角色开的武器类型
---@param pCard UCharacterCard
function Item.GetCardWeaponType(pCard)
    local sGDPL = string.format("%s-%s-%s-%s", pCard:Genre(), pCard:Detail(), pCard:Particular(), pCard:Level())
    return Item.tbCardLimitWeapon[sGDPL]
end

--- 获取角色的I18n
--- @param iDetail
function Item.GetI18nByDetail(iDetail)
    return Item.tbDetail2I18n[iDetail]
end

function Item.Zhanli_CharacterCard(InItem, InLevel, InBreak, InEvolue, InTrust)
    return ItemPower.Card(InItem, InLevel, InBreak, InEvolue, InTrust)
end

function Item.Zhanli_Weapon(InItem, InLevel, InBreak, InEvolue)
   return ItemPower.Weapon(InItem, InLevel, InBreak)
end

function Item.Zhanli_WeaponParts(InItem)
    return ItemPower.WeaponPart(InItem)
end

function Item.Zhanli_SupportCard(InItem, InLevel, InEvolue, InTrust)
   return 0
end

function Item.Zhanli_SupportCardSuit(InItem)
    return 0
end

function Item.Zhanli_CardTotal(InItem)
   return Item.Zhanli_CharacterCard(InItem)
end

--- 获取道具的名称
function Item.GetName(InItem)
    return Text(InItem:I18N())
end

--- 获取道具的描述
function Item.GetDes(InItem)
    if InItem:Genre() == Item.TYPE_HOUSE then
        return Text("dormgift.type"..InItem:Detail())
    end
    return Text(InItem:I18N() .. "_des")
end

--- 获取道具的功能说明
function Item.GetUse(InItem)
    return Text(InItem:I18N() .. "_use")
end

--- 获取道具的Title
function Item.GetTitle(InItem)
    return Text(InItem:I18N() .. "_title")
end

---获取同卡分解物品
function Item.Character2Piece(nG, nD, nP, nL)
    local sGDPL = string.format("%d-%d-%d-%d", nG, nD, nP, nL)
    return Item.tbCharacterCard2Piece[sGDPL]
end

---获取角色卡碎片所对应的角色卡
---@return UE4.FItemTemplate 角色卡Template
---@return table 角色卡GDPL
function Item.Piece2Character(nG, nD, nP, nL)
    for sGDPL, tbPiece in pairs(Item.tbCharacterCard2Piece) do
        for _, tbItem in ipairs(tbPiece) do
            if tbItem[1] == nG and tbItem[2] == nD and tbItem[3] == nP and tbItem[4] == nL then
                local tbsGDPL = Split(sGDPL, "-")
                local tbGDPL = {tonumber(tbsGDPL[1]), tonumber(tbsGDPL[2]), tonumber(tbsGDPL[3]), tonumber(tbsGDPL[4])}
                return UE4.UItem.FindTemplate(table.unpack(tbGDPL)), tbGDPL
            end
        end
    end
end

--------------------------------- S2C接口注册 -------------------------------------

---获得道具
s2c.Register("Item_Gain", Item.Gain)

---道具出售, 参数为出售后获得的道具列表
s2c.Register(
    "Item_Recycle",
    function(tbRewards)
        -- 如果仓库页面是打开的，则刷新物品页面
        local BagUI = UI.GetUI("Bag")
        if BagUI then
            BagUI:OnRecycleEnd()
        end

        -- 弹出道具获取面板
        Item.Gain(tbRewards)
    end
)

---道具锁定的服务器回调，参数为道具ID和锁定状态
s2c.Register(
    "Item_SetLock",
    function(tbParam)
        --- 如果仓库页面是打开的，则刷物品状态
        local BagUI = UI.GetUI("Bag")
        if BagUI then
            BagUI:OnItemLocked(tbParam.ItemId)
        end
        local LogiSelect = UI.GetUI("LogiShow")
        if LogiSelect then
            local pItem = me:GetItem(tbParam.ItemId)
            LogiSelect:UpdatePanelState(pItem)
        end
    end
)

---道具兑换
s2c.Register(
    "Item_Exchange",
    function(tbParam)
        EventSystem.Trigger(Event.ExchangeSuc)
    end
)

---打开道具箱
s2c.Register(
    "Item_OpenBox",
    function(tbParam)
        EventSystem.Trigger(Event.GetBoxItem,tbParam)
        Item.Gain(tbParam.tbAward)
    end
)


s2c.Register(
    "Item_ConvertGirlPieces",
    function(tbParam)
        -- EventSystem.Trigger(Event.GetBoxItem,tbParam)
        --Dump(tbParam)
        Item.Gain(tbParam.tbAward)
    end
)
--------------------------------- 内部使用 ----------------------------------------

---加载升级经验配置表
function Item.LoadUpgradeExp()
    local tbFile = LoadCsv("item/upgrade_exp.txt", 1)

    Item.tbUpgradeExp[Item.TYPE_CARD] = {}
    Item.tbUpgradeExp[Item.TYPE_WEAPON] = {}
    Item.tbUpgradeExp[Item.TYPE_SUPPORT] = {}

    for _, tbLine in ipairs(tbFile) do
        local nLevel = tonumber(tbLine.Lv or "0")
        Item.tbUpgradeExp[Item.TYPE_CARD][nLevel] = tonumber(tbLine.CardNeedExp or "0")
        Item.tbUpgradeExp[Item.TYPE_WEAPON][nLevel] = tonumber(tbLine.WeaponNeedExp or "0")
        Item.tbUpgradeExp[Item.TYPE_SUPPORT][nLevel] = tonumber(tbLine.SusNeedExp or "0")
    end
end

---加载突破配置表
function Item.LoadBreakMaterials()
    local tbFile = LoadCsv("item/break.txt", 1)

    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID or "0")
        Item.tbBreakMaterials[nId] = {
            Eval(tbLine.Items1),
            Eval(tbLine.Items2),
            Eval(tbLine.Items3),
            Eval(tbLine.Items4),
            Eval(tbLine.Items5),
            Eval(tbLine.Items6),
        }
    end
end

---加载突破限制等级配置表
function Item.LoadBreakLevelLimits()
    local tbFile = LoadCsv("item/break_level_limit.txt", 1)

    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID or "0")
        Item.tbBreakLevelLimit[nId] = {
            tonumber(tbLine.Break0),
            tonumber(tbLine.Break1),
            tonumber(tbLine.Break2),
            tonumber(tbLine.Break3),
            tonumber(tbLine.Break4),
            tonumber(tbLine.Break5),
            tonumber(tbLine.Break6),
        }
    end
end

---加载指挥官等级限制角色卡等级配置表
function Item.LoadCardLevelLimits()
    local tbFile = LoadCsv("item/level_limit.txt", 1)
    Item.tbCardLevelLimit[1] = {}   --1:账号等级对道具升级的限限制
    Item.tbCardLevelLimit[2] = {}   --2:账号等级对道具突破的限制
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID) or "0"
        local nType = tonumber(tbLine.Type) or "1"
        if nType == 2 then
            Item.tbCardLevelLimit[2][nId] = Eval(tbLine.Limit)
        else
            Item.tbCardLevelLimit[1][nId] = Eval(tbLine.Limit)
        end
    end
    for _, tb in pairs(Item.tbCardLevelLimit) do
        for _, Limit in pairs(tb) do
            table.sort(Limit, function(a, b) return a[1] < b[1] end)
        end
    end
end

---加载卡对应分解碎片GDPL
function Item.LoadCharacterCard2Frags()
    local tbFile = LoadCsv("item/templates/card.txt", 1)

    for _, tbLine in ipairs(tbFile) do
        local nClose = tonumber(tbLine.Close)
        if (not nClose) or nClose == 0 then
            local sGDPL = string.format("%s-%s-%s-%s", tbLine.Genre, tbLine.Detail, tbLine.Particular, tbLine.Level)
            if sGDPL and #sGDPL > 0 then
                Item.tbCharacterCard2Piece[sGDPL] = Eval(tbLine.SameConvert)
                Item.tbCardLimitWeapon[sGDPL] = tonumber(tbLine.LimitWeapon) or 1
                if tbLine.StartTime then
                    Item.tbLockShow[sGDPL] = string.sub(tbLine.StartTime or '', 2, -2)
                end
                local d = tonumber(tbLine.Detail) or 0
                if d > 0 then
                    Item.tbDetail2I18n[d] = tbLine["I18n"]
                end
            end
        end
    end
end
--- 加载Icon信息列表
function Item.LoadIconConfig()
    local tbFile = LoadCsv("supporticon/Icon.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID or "0")
        if nId and nId > 0 then
            Item.tbIcon[nId] = {
                LogoId = tonumber(tbLine.LogoId) or nil,
                Icon = tonumber(tbLine.Icon) or nil,
                IconPose = Eval(tbLine.IconPose or nil),
                ImgL2d = tbLine.ImgL2d or nil,
                ImgL2dData = tbLine.ImgL2dData or nil,
                ImgL2dPos = Eval(tbLine.ImgL2dPos) or nil,
                ImgCard1 = tbLine.ImgCard1 or nil,
                ImgCard2 = tbLine.ImgCard2 or nil,
                L2dAtlas = tbLine.L2dCardIdAtlas or nil,
                L2dData = tbLine.L2dCardIdData or nil,
                L2dCardPos = Eval(tbLine.L2dCardPos) or nil
            }
        end
    end
end

function Item.LoadQualIcon()
    local tbdata = LoadCsv("supporticon/qualIcon.txt", 1)
    for index, tbLine in ipairs(tbdata) do
        local nQual = tonumber(tbLine.QualIcon or "")
        Item.tbQualIcon[nQual] = {
            IconA = tbLine.IconA or nil,
            IconB = tbLine.IconB or nil
        }
    end
end

--- 后勤卡所属公司Logo配置表
function Item.LoadLogoIcon()
    local tbdata = LoadCsv("supporticon/logoIcon.txt", 1)
    for index, tbLine in ipairs(tbdata) do
        local Id = tonumber(tbLine.Id or nil)
        Item.tbLogoIcon[Id] = {
            LogoIcon = tbLine.LogoIcon or nil,
            LogoDes = tbLine.LogoDes or nil
        }
    end
    -- Dump( Item.tbLogoIcon)
end

function Item.LoadCardPaintingConf()
    local tbFile = LoadCsv("item/card/painting.txt", 1)
    for index, tbLine in ipairs(tbFile) do
        local Id = tonumber(tbLine.ID or nil)
        Item.tbCardIcon[Id] = {
            nP1 = tonumber(tbLine.P1 or nil),
            nP2 = tonumber(tbLine.P2 or nil),
            nP3 = tonumber(tbLine.P3 or nil),
            nP4 = tonumber(tbLine.P4 or nil),
            nP5 = tonumber(tbLine.P5 or nil),
            nP6 = tonumber(tbLine.P6 or nil),
            nP7 = tonumber(tbLine.P7 or nil),
            nP8 = tonumber(tbLine.P8 or nil)
        }
    end
    -- Dump(Item.tbCardIcon)
end


---获取当前版本中角色卡的数量
---@return number 数量
function Item.GetCardsNum()
    local allCardTemplate = UE4.UItemLibrary.GetCharacterTemplates()
    return allCardTemplate:Length()
end

--- 加载道具箱配置
function Item.LoadBoxConf()
    local tbFile = LoadCsv("item/box.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nIndex = tonumber(tbLine.Index) or 0;
        Item.tbBox[nIndex] = Item.tbBox[nIndex] or {}
        local tbData = {
            tbGDPLN = Eval(tbLine.GDPLN),
            sObtainType = tbLine.ObtainType,
            nWeight = tonumber(tbLine.Weight),
            nGroup = tonumber(tbLine.Group) or 1,
        }
        Item.tbBox[nIndex][tbData.sObtainType]= Item.tbBox[nIndex][tbData.sObtainType] or {}
        local tbBox = Item.tbBox[nIndex][tbData.sObtainType]
        tbBox[tbData.nGroup] = tbBox[tbData.nGroup] or {}

        table.insert(tbBox[tbData.nGroup], tbData)
    end
end

--- 加载道具置换表
function Item.LoadExchangeConf()
    local tbFile = LoadCsv("item/exchange.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local g = tonumber(tbLine.G) or 0;
        local d = tonumber(tbLine.D) or 0;
        local p = tonumber(tbLine.P) or 0;
        local l = tonumber(tbLine.L) or 0;

        Item.tbExchange[string.format('%s-%s-%s-%s', g, d, p, l)] = {
            tbCash = Eval(tbLine.Cash),
            tbItem = Eval(tbLine.Item),
        }
    end
end

function Item.LoadGirlPiecesConvert()
    local tbFile = LoadCsv('item/pieces_convert.txt', 1);
    Item.tbPiecesConvert = {}
    for _,tbLine in ipairs(tbFile) do
        local nColor = tonumber(tbLine["Color"])
        local tbItem = Eval(tbLine["Item"])
        local sIcon = tbLine["Icon"]
        Item.tbPiecesConvert[nColor] = {["tbItem"]=tbItem,["sIcon"]=sIcon}
    end
    --Dump(Item.tbPiecesConvert)
    print('../settings/item/pieces_convert.txt');
end

function Item.LoadBanItems()
    Item.tbBanItem = {}
    local tbFiles = {
        "item/templates/weapon_parts.txt",
        "item/templates/weapon.txt",
        "item/templates/support_card.txt",
        "item/templates/suplies.txt",
        "item/templates/others.txt",
        "item/templates/dorm_gift.txt",
        "item/templates/card_skin.txt",
        "item/templates/card.txt",
    }
    for idx, sFile in ipairs(tbFiles) do
        local tbFile = LoadCsv(sFile, 1)
        for _, tbLine in ipairs(tbFile) do
            local nClose = tonumber(tbLine.Close) or 0
            if nClose == 1 then
                local sGDPL = string.format("%s-%s-%s-%s", tbLine.Genre, tbLine.Detail, tbLine.Particular, tbLine.Level)
                if sGDPL and #sGDPL > 0 then
                    Item.tbBanItem[sGDPL] = true
                end

                --武器析出配件也屏蔽
                if idx == 2 and tbLine.WeaponPartsAward then
                    local tb = Eval(tbLine.WeaponPartsAward)
                    sGDPL = string.format("%s-%s-%s-%s", table.unpack(tb))
                    if sGDPL and #sGDPL > 0 then
                        Item.tbBanItem[sGDPL] = true
                    end
                end
            end
        end
    end
end

function Item.IsBanItem(tbGDPL)
    if not tbGDPL or type(tbGDPL) ~= 'table' or #tbGDPL < 4 then
        return false
    end

    local sGDPL = string.format("%s-%s-%s-%s", table.unpack(tbGDPL))
    return Item.tbBanItem[sGDPL]
end

--读取others 的usemode
function Item.LoadOthers()
    local tbFile = LoadCsv("item/templates/others.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local sGDPL = string.format("%s-%s-%s-%s", tbLine.Genre, tbLine.Detail, tbLine.Particular, tbLine.Level)
        if sGDPL and #sGDPL > 0 then
            local tb ={}
            tb.nUseMode = tonumber(tbLine.UseMode) or 0
            Item.tbOthers[sGDPL] = tb
        end
    end
end

---获取others 的usemode
function Item.GetOthersUseMode(nG, nD, nP, nL)
    local sGDPL = string.format("%d-%d-%d-%d", nG, nD, nP, nL)
    if not Item.tbOthers[sGDPL] then return end

    return Item.tbOthers[sGDPL].nUseMode
end

-- 是否有新道具
function Item.HaveNew()
    local pItemList = UE4.TArray(UE4.UItem)
    me:GetItems(pItemList)
    for i = 1, pItemList:Length() do
        local pItem = pItemList:Get(i)
        if (not pItem:HasFlag(Item.FLAG_READED)) and (pItem:IsWeapon() or pItem:IsSupportCard() or pItem:IsSupplies() or pItem:IsWeaponParts() or pItem:IsUseable()) then
            return true
        end
    end
    return false
end

-- 是否有新道具 仓库显示用 
function Item.BagHaveNew()
    for i=Item.tbBagDot.tbDot.PAGE_WEAPON, Item.tbBagDot.tbDot.PAGE_SUPLIES do
        if Item.GetDotState(i) then
            return true
        end
    end
    
    return false
end

--获取黄点状态
function Item.GetDotState(key)
    if not key or (type(key) ~= 'number' and not Item.tbBagDot.tbDot[key]) then 
        return false
    end
    
    Item.nBagVal = Item.nBagVal or me:GetAttribute(Item.tbBagDot.nBagDotGruop, Item.tbBagDot.nBagDotId)
    if type(key) ~= 'number'  then
        return GetBits(Item.nBagVal, Item.tbBagDot.tbDot[key], Item.tbBagDot.tbDot[key]) == 1
    end
    return GetBits(Item.nBagVal, key, key) == 1
end

--设置黄点状态
function Item.SetDotState(key, val)
    if not key or (type(key) ~= 'number' and not Item.tbBagDot.tbDot[key]) then 
        return 
    end
    Item.nBagVal = Item.nBagVal or me:GetAttribute(Item.tbBagDot.nBagDotGruop, Item.tbBagDot.nBagDotId)
    local oldVal = Item.nBagVal
    if type(key) ~= 'number'  then
        Item.nBagVal = SetBits(Item.nBagVal, val and 1 or 0, Item.tbBagDot.tbDot[key], Item.tbBagDot.tbDot[key])
    end
    Item.nBagVal = SetBits(Item.nBagVal, val and 1 or 0, key, key)
    if oldVal ~= Item.nBagVal then
        me:SetAttribute(Item.tbBagDot.nBagDotGruop, Item.tbBagDot.nBagDotId, Item.nBagVal)
    end
end

---物品列表 按品质排序 高--低
---@param tbList table 物品列表
---@return table 处理后的物品列表
function Item.HandleItemListRank(tbList, bG)
    if not tbList then return end

    local fCompareGDPL = function(ltb, rTb)
        for idx, nValue in ipairs(ltb) do
            if nValue ~= rTb[idx] then
                return nValue < rTb[idx]
            end
       end
       return false
    end

    if bG then
        table.sort(tbList, function (infoA, infoB)
            local g, d, p, l = infoA.G,infoA.D,infoA.P,infoA.L
            local lItem = UE4.UItemLibrary.GetItemTemplateByGDPL(g, d, p, l)
            g, d, p, l = infoB.G, infoB.D,infoB.P,infoB.L
            local rItem = UE4.UItemLibrary.GetItemTemplateByGDPL(g, d, p, l)
            if not lItem then return true end
            if not rItem then return false  end

            if lItem.Color == rItem.Color then
                return fCompareGDPL({infoA.G, infoA.D, infoA.P, infoA.L}, {infoB.G, infoB.D, infoB.P, infoB.L})
            end

            return lItem.Color > rItem.Color;
        end);
    else
        table.sort(tbList, function (infoA, infoB)
            local g, d, p, l = table.unpack(infoA)
            local lItem = UE4.UItemLibrary.GetItemTemplateByGDPL(g, d, p, l)
            local g1, d1, p1, l1 = table.unpack(infoB)
            local rItem = UE4.UItemLibrary.GetItemTemplateByGDPL(g1, d1, p1, l1)

            if not lItem then return true end
            if not rItem then return false  end

            if lItem.Color == rItem.Color then
                return fCompareGDPL({g, d, p, l}, {g1, d1, p1, l1})
            end

            return lItem.Color > rItem.Color;
        end);
    end

    return tbList
end

---判定角色是否可以显示(目前仅umg_role界面)
function Item.CheckCardShow(tbGDPL)
    if type(tbGDPL) ~= "table" or #tbGDPL < 4 then return true end

    local sGDPL = string.format("%s-%s-%s-%s", tbGDPL[1], tbGDPL[2], tbGDPL[3], tbGDPL[4])
    local sTime = Item.tbLockShow[sGDPL]
    if not sTime then return true end

    local nCheckTime = ParseTime(sTime) or 0
    return (GetTime() >= nCheckTime)
end

--新增道具黄点显示
EventSystem.On( Event.ItemChanged, function(pItem)
    if pItem and (not pItem:HasFlag(Item.FLAG_READED)) and
        (pItem:IsWeapon() or pItem:IsSupportCard() or pItem:IsSupplies() or pItem:IsWeaponParts() or pItem:IsUseable()) then
        Item.SetDotState(Item.tbBagDot.tbDot.MAIN_BTN, true)
        if pItem:IsWeapon() then
            Item.SetDotState(Item.tbBagDot.tbDot.PAGE_WEAPON, true)
        elseif pItem:IsSupportCard() then
            Item.SetDotState(Item.tbBagDot.tbDot.PAGE_SUPPORT, true)
        elseif pItem:IsSupplies() then
            Item.SetDotState(Item.tbBagDot.tbDot.PAGE_SUPLIES, true)
        elseif pItem:IsWeaponParts() then
            Item.SetDotState(Item.tbBagDot.tbDot.PAGE_PART, true)
        elseif pItem:IsUseable() then
            Item.SetDotState(Item.tbBagDot.tbDot.PAGE_ITEM, true)
        end
    end
end)

---登录初始化
EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    if bReconnected then return end
    Item.nBagVal = nil
end)


Item.LoadUpgradeExp()
Item.LoadBreakMaterials()
Item.LoadBreakLevelLimits()
Item.LoadCardLevelLimits()
Item.LoadCharacterCard2Frags()
Item.LoadIconConfig()
Item.LoadQualIcon()
Item.LoadLogoIcon()
Item.LoadCardPaintingConf()
Item.LoadBoxConf()
Item.LoadExchangeConf()
Item.LoadGirlPiecesConvert()
Item.LoadBanItems()
Item.LoadOthers()
