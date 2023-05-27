-- ========================================================
-- @File    : Logistics.lua
-- @Brief   : 后勤
-- ========================================================

---@class Logistics 后勤逻辑管理
---1：equipment，2：replace，3：disboard
LogiType = {
    LogiNone = 0, --- 无装备
    LogiEquip = 1, --- 后勤卡装备
    LogiReplace = 2, --- 后勤卡替换
    LogiDisboard = 3 --- 后勤卡卸载
}
--- 属性比较
AttrSign = {
    AttrNone = 1, --- 无比较
    AttrPluse = 2, --- 属性提升
    AttrSub = 3 --- 属性降低
}

Logistics =
    Logistics or
    {
        tbLogiData = {}, --- 所有后勤卡
        tbAllLogiSuit = {}, -- table 所有后勤套装Id-该套装下的后勤卡
        tbGrow = {}, -- 后勤卡成长属性配置
        tbLogisticType = {},
        tbConsumes = {},
        tbSkillMaterial = {},
        tbSkillSuitID = {},
        tbPaints = {},
        tbGDPLGrowupID={},---通过GDPL存储的成长ＩＤ
        tbAffixValue = {}, ---解释affix
        tbMainAttr = {},
        tbSubAttr = {},
    }

ELogiAttrType = {
    "Health", --血量
    "Shield", --护盾
    "Attack", --攻击
    "Defence", --物理防御
    "CriticalValue", --会心
    "CriticalDamage", --会心加成
    "ArmorDamageScaler", --破甲加成
    "LogiAttr_Max"
}

--- 获取养成的卡片
Logistics.Card = nil
--- 缓存选择后勤卡位
Logistics.SelectType = 0
--- 操作模式
Logistics.OptionMode = 0
--- 经验值
Logistics.SecExp = 0
Logistics.OnShowTypeHandle = "ON_SHOWTYPE_HANDLE"
--- 后勤信息弹窗
Logistics.OnLogiPopTipHandle = "ON_LOGIPOPTIP_HANDLE"
--- 刷新后勤插槽
Logistics.OnUpdataLogisticsSlot = "ON_UPDATALOGISTICSSLOT_HANDLE"
--- 选择道具数据变化
Logistics.MaterialsChangeHandle = "ON_LOGISCOST_CHANGE"
--- 后勤操作
Logistics.LogiOperation = "ON_OPERATION"
--- 后勤卡替换
Logistics.LogiCardReplace = "ON_LOGISCARD_REPLACE"
--- 后勤卡装备
Logistics.LogiCardEquip = "ON_LOGISCARD_EQUIP"
--- 后勤卡卸载
Logistics.LogiCardUnLoad = "ON_LOGISCARD_UNLOAD"
--- 选择道具不可变化(已经达到经验，金币，等其他限制上限)
Logistics.MaterialsUnChange = "ON_MAT_UNCHANGE"
--- 进化次数已达上限(技能等级)
Logistics.OnLimitEvol = "ON_EVOL_MAX"
--- 当前养成的当前卡片
Logistics.OnCultItem = "ON_CULTIVATE_ITEM"

--- 后勤插槽页签切换
Logistics.ChangePage = "CHANGE_SLOT_HANDLE"

--- 后勤插槽头像切换
Logistics.ShowHead = "MARK_HEAD"

Logistics.tbName = {"technology", "medicalcare", "equip"}

--- 进入后勤界面时选择的角色
Logistics.CurRole = nil
--- 后勤卡
Logistics.CulCard = nil

Logistics.tbTeamDes = {"ui.technology","ui.medicalcare","ui.equip"}

--- 刷新属性变化
function Logistics:GetItem(InIndex, InCard)
    if InIndex == 1 then
        return Text("ui.health"), 999 --- InCard:Health()
    elseif InIndex == 2 then
        return Text("ui.shield"), 999 ---InCard:Shield()
    elseif InIndex == 3 then
        return Text("ui.attack"), 999 ---InCard:Attack()
    elseif InIndex == 4 then
        return Text("ui.def"), 999 ---InCard:Defence()
    elseif InIndex == 5 then
        return Text("ui.criticalvalue"), 999 ---InCard:CriticalValue()
    elseif InIndex == 6 then
        return Text("ui.criticaldamage"), 999 ---InCard:CriticalDamage()
    elseif InIndex == 6 then
        return Text("ui.armordamagescaler"), 999 ---InCard:ArmorDamageScaler()
    end
end

Logistics.TypeSortHandle = function(l,r)
    local nA = 0 
    local nB = 0
    if l:CanStack() then
        nA = 1
    end

    if r:CanStack() then
        nB = 1
    end
    return nA-nB
end


Logistics.SlotSortHandle = function(l,r)
    if l:CanStack() and r:CanStack() then
        return r:Level() - l:Level()
    end
    return -1
end

--- 通用道具部分排序
function Logistics.PartSort(InItems)
    local tbSortHandle = {Logistics.TypeSortHandle, Logistics.SlotSortHandle}
    local function handle(l, r)
        for index, value in ipairs(tbSortHandle) do
            local nDiff = value(l, r)
            if nDiff > 0 then return true end
            if nDiff < 0 then return false end
        end
    end
    table.sort(InItems,handle)
    return InItems
end

--- 
function Logistics.GetSecgradeByGDPL(G, D)
    local tbRet = {}
    local AllItems = UE4.TArray(UE4.UItem)
    me:GetItems(AllItems)
    for i = 1, AllItems:Length() do
        local Item = AllItems:Get(i)
        if Item:Genre() == G or (Item:Genre() == 5 and Item:Detail() ==3) then
            table.insert(tbRet, Item)
        end
    end
    return Logistics.PartSort(tbRet)
end

--- 获得所有的后勤狗粮道具
--- @return table UItem table
function Logistics.GetSupportUpdateItems()
    local tbRet = {}
    local AllItems = UE4.TArray(UE4.UItem)
    me:GetItems(AllItems)
    for i = 1, AllItems:Length() do
        local Item = AllItems:Get(i)
        if Item:Genre() == 5 and Item:Detail() ==3 then
            table.insert(tbRet, Item)
        end
    end
    return Logistics.PartSort(tbRet)
end

function Logistics.AddConsume(InItem)
    if not Logistics.tbConsumes[InItem] then
        Logistics.tbConsumes[InItem] = 1
    else
        Logistics.tbConsumes[InItem] = Logistics.tbConsumes[InItem] + 1
    end
    EventSystem.TriggerTarget(Logistics, Logistics.MaterialsChangeHandle,RoleCard.ExpState.ExpAdd)
end

function Logistics.SubConsume(InItem)
    if Logistics.tbConsumes[InItem] then
        Logistics.tbConsumes[InItem] = math.max(Logistics.tbConsumes[InItem] - 1, 0)
        -- if Logistics.tbConsumes[InItem] <= 0 then
        --     RemoveElementByKey(Logistics.tbConsumes, InItem)
        -- end
    end
    EventSystem.TriggerTarget(Logistics, Logistics.MaterialsChangeHandle,RoleCard.ExpState.ExpSub)
end

function Logistics.AddExp(pItem, nAdd)
    local nOldLevel = pItem:EnhanceLevel()
    local nMaxLevel = Item.GetMaxLevel(pItem)
    local nOldExp = pItem:Exp()
    local nRemain = nOldExp + nAdd
    local nUpdateNeed = Item.GetUpgradeExpByLevel(pItem,nOldLevel)

    while nUpdateNeed > 0 and nRemain >= nUpdateNeed do
        -- if pItem:EnhanceLevel() == nMaxLevel then
        --     nRemain = math.min(nUpdateNeed - 1, nRemain)
        --     break
        -- end
        nOldLevel = nOldLevel + 1
        nRemain = nRemain - nUpdateNeed
        nUpdateNeed = Item.GetUpgradeExpByLevel(pItem,nOldLevel)
    end
    return nOldLevel, nRemain, nUpdateNeed 
end
---通过GDPL获得到成长ID
function Logistics.GetSupportGrowupIDByGDPL(g, d, p, l)
    local sGDPL = string.format("%s-%s-%s-%s", g, d, p, l)
    return Logistics.tbGDPLGrowupID[sGDPL].GrowupID
end


--- 获取节能ID
---@param pItem  UE4.UItem 后勤卡
function Logistics.GetSkillID(InItem)
    local Skills = UE4.TArray(UE4.int32)
    InItem:GetSkills(1, Skills)
    if Skills:Length() > 0 then
        local id = Skills:Get(1)
        return id
    end
    print("not skill id")
end

function Logistics.GetSkillEvolutMats(InItem, Num)
    local tbMat = Logistics.tbSkillMaterial[InItem:EvolutionMatID()][Num]
    return tbMat
end

---@return nCost integry 消耗金币
---@return nExp  integry 增加经验
function Logistics.GetConsumeExpAndGold()
    local Exp = 0
    local Gold = 0
    Logistics.SecExp = 0
    for k, v in pairs(Logistics.tbConsumes) do
        if v > 0 then
            Exp = Exp + k:Param1() * v
            Gold = Gold + math.abs(k:Param2()) * v
        end
    end
    Logistics.SecExp = Exp
    return Exp, Gold
end

--- 获取等级经验
---@return integer 返回当前经验值，下一级需要的经验值
function Logistics.GetExpByLv(InCard, InLv)
    return InCard:Exp(), Item.tbUpgradeExp[Item.TYPE_SUPPORT][InLv]
end

--- 获取角色当前已经装备的后勤卡
---@return tbSlotCard table={UE4.UItem}
function Logistics.GetLogisticsSlot(InSlot)
    local pSlot = Logistics.Card:GetSupporterCard(InSlot)
    return pSlot
end

--- 获取角色的Slot
function Logistics.GetSlotByCard(InCard,SlotIdx)
    local pSlot = InCard:GetSupporterCard(SlotIdx)
    return pSlot
end

--- 获取当前装备的所有后勤卡
function Logistics.GetSlots()
    local tbSlot = {}
    for i = 1, 3 do
        local pSlot = Logistics.GetLogisticsSlot(i)
        if pSlot then
            table.insert(tbSlot, pSlot)
        end
    end
    return tbSlot
end

--- 获取花费金币
---@param InCard UE4.UItem 需要提升的卡
function Logistics.GetCostGold(InCard)
    local nCost = 0
    local tbCost = Item.GetBreakMaterials(InCard)
    if tbCost and #tbCost > 0 then
        for i = 1, #tbCost do
            local pItem = tbCost[i]
            local nHaveBreakItem = me:GetItemCount(pItem[1], pItem[2], pItem[3], pItem[4])
            local pMat = UE4.UItem.FindTemplate(pItem[1], pItem[2], pItem[3], pItem[4])
            if nHaveBreakItem > tbCost[i][5] then
                nCost = nCost + tbCost[i][5] * pMat.Param2
            end
        end
    end
    return nCost
end

--- 数据变化List
---@param InItem UE4.UItem 后勤卡
---@param Index number (1：升级，2：突破)
function Logistics.GetAttrListChange(InSlot, InItem, Index)
    local tbAttribChangeDate = {}
    for i = 0, UE4.EAttributeType.AttributeType_Max - 1 do
        local Type = UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", i)
        -- print(Type)
        for key, value in pairs(ELogiAttrType) do
            if Type == value then
                local nNow, nNew = Logistics.GetAttrChange(i, InItem, Index)
                if  nNow>0 then
                    local tbItem = {
                        Name = Text("ui." .. tostring(value)),
                        Now = nNow,
                        New = nNew,
                        -- ESign = Logistics.GetAttrChangeByItem(InSlot, InItem, i),
                        EName = Type
                    }
                    table.insert(tbAttribChangeDate, tbItem)
                end
            end
        end
    end
    -- Dump(tbAttribChangeDate)
    return tbAttribChangeDate
end

function Logistics.GetShowAttrList(InSupportCard)
    local tbShowAttr = {}
    local tbAttr = {
        nNow = UE4.UItemLibrary.GetCharacterCardAbilityValueByIndexToStr(1, InSupportCard),
        sName = "Name",
        sEName = "EName",
    }
    table.insert(tbShowAttr,tbAttr)
    return tbShowAttr
end


---获取突破等级对应的等级上限
function Logistics.GetMaxLv(InSupportCard, nBreakLv)
    if not InSupportCard then return 0 end
    local tbCfg = Item.tbBreakLevelLimit[InSupportCard:BreakLimitID()]
    if not tbCfg then
        return InSupportCard:EnhanceLevel()
    else
        return tbCfg[nBreakLv] or InSupportCard:EnhanceLevel()
    end
end

--- 获取后勤卡的属性
function Logistics.GetAttr(InSupportCard)
    local tbAllAttr = {}
    for i = 0, UE4.EAttributeType.AttributeType_Max - 1 do
        local Info = {
            sType = UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", i),
            nIconId = string.format('IconId-%d',i),
            Attr = UE4.UItemLibrary.GetCharacterCardAbilityValueByIndexToStr(i, InSupportCard,InSupportCard:EnhanceLevel(),InSupportCard:Break())
        }
        table.insert(tbAllAttr,Info)
    end
    return tbAllAttr
end

--- 获取后勤卡的主属性
function Logistics.GetMainAttr(InSupportCard)
    local MainAttrs = {}
    if not InSupportCard then return MainAttrs end
    for k, i in pairs(Logistics.tbMainAttr) do
        local Info = {
            sType = i,
            Attr = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr(i, InSupportCard,InSupportCard:EnhanceLevel(),InSupportCard:Break() + 1)
        }
        if tonumber(Info.Attr) ~= 0 then
            table.insert(MainAttrs, Info)
        end
    end
    return MainAttrs
end

--- 获取后勤卡的副属性
function Logistics.GetSubAttr(InSupportCard)
    local tbAllAttr = {}
    for k, i in pairs(Logistics.tbSubAttr) do
        local Info = {
            sType = i,
            Attr = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr(i, InSupportCard,InSupportCard:EnhanceLevel(),InSupportCard:Break() + 1),
            IsPercent = true,
        }
        if tonumber(Info.Attr) ~= 0 then
            return Info
        end
    end
end

--- 获取当前角色的所有后勤插槽位的属性
---@param InSupportsCard table 后勤卡tble
function Logistics.GetAllSlotAttr(InSupportsCard)
    local  tbAllSlotAttr = {}
    for i = 1, UE4.EAttributeType.AttributeType_Max - 1 do
        local Data = {sType = "",nIconId = 0,Attr = 0}
        for index, value in ipairs(InSupportsCard or {}) do
            local tbInfo = Logistics.GetAttr(value)
            Data.sType = tbInfo[i].sType -- UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", i)
            Data.nIconId = tbInfo[i].nIconId
            Data.Attr = Data.Attr + tonumber(tbInfo[i].Attr)
        end
        table.insert(tbAllSlotAttr,Data)
        --- CriticalDamage
    end
    return tbAllSlotAttr
end

--- 获取当前装备的后勤卡数量
--- @param InSupportCard USupportCard 选择的后勤卡
--- @param InCharacterCard UCharacter 选择的角色卡
function Logistics.GetSuitEquipNum(InSupportCard, InCharacterCard)
    if (not InSupportCard) or (not InCharacterCard) then return 0 end
    local function GetSuitId(InCard)
        local pTemplate = UE4.UItem.FindTemplateForID(InCard:TemplateId())
        return pTemplate.SuitSkill
    end

    --- 获取当前套装装备了几个
    local function GetSuitEquipNum(InCharacterCard)
        local EquipSuitNum = 0
        local EquipSelect = false
        for i = 1, 3 do
            local SupportSlot = InCharacterCard:GetSupporterCardForIndex(i)
            if SupportSlot and GetSuitId(SupportSlot) == GetSuitId(InSupportCard) then
                EquipSuitNum = EquipSuitNum + 1
                if i == tonumber(InSupportCard:GetSlotType()) then
                    EquipSelect = true
                end
            end
            if SupportSlot == InSupportCard then
                EquipSelect = true
            end
        end
        return {EquipSuitNum = EquipSuitNum, EquipSelect = EquipSelect}
    end
    return GetSuitEquipNum(InCharacterCard)
end

--- 筛选一维二维table有效属性
function Logistics.CheckAttr(InAttrs)
    local Data = {}
    for index, Info in ipairs(InAttrs) do
        if type(Info)=="table" then
            if Info.Attr and (tonumber(Info.Attr) > 0) then
                local Cell = {
                    sType = Info.sType,
                    nIconId = Info.nIconId,
                    Attr = tostring(Info.Attr)
                }
                table.insert(Data,Cell)
            end
        else
            table.insert(Data,Info)
        end
    end
    return Data
end

--- 获取后勤卡的技能
---@param InSupportCard UE4.USupportCard 后勤卡
---@return Skill[1] Id 返回后勤卡的第一技能（暂定返回第一技能）
function Logistics.GetSKill(InSupportCard)
    local Skills = UE4.TArray(0)
    InSupportCard:GetSkills(InSupportCard:EnhanceLevel(),Skills)
    if Skills:Length() == 0 then
        print('skillId error')
        return
    end
    return Skills:Get(1)
end

function Logistics.GetAllSlotSkills(tbSupportCard)
    local  tbAllSkill = {}
    for index, value in ipairs(tbSupportCard or {}) do
        if Logistics.GetSKill(value) then
            table.insert(tbAllSkill,Logistics.GetSKill(value))
        end
    end
    return tbAllSkill
end
--- 属性变化
---@param pItem UE4.UItem 道具卡
---@param InIndex number --(1:升级，2：突破)
---@return DeltaVal integer 属性变化值
function Logistics.GetAttrChange(InCate, pItem, InIndex)
    ---当前等级
    local ItemLv = pItem:EnhanceLevel()
    ---当前品质
    local ItemQua = pItem:Quality()
    ---当前突破次数
    local nBreak = pItem:Break() + 1

    local nExp, nGold = Logistics.GetConsumeExpAndGold()
    local NewLevel, NewExp =
        Item.GetItemDestLevel(pItem:EnhanceLevel(), pItem:Exp(), nExp, Item.TYPE_SUPPORT, Item.GetMaxLevel(pItem))
    if NewLevel - pItem:EnhanceLevel() == 0 then
        NewLevel = pItem:EnhanceLevel() + 1
    end
    if InIndex == 1 then
        local nNow = UE4.UItemLibrary.GetCharacterCardAbilityValueByIndex(InCate, pItem, ItemLv, ItemQua)
        local nNew = UE4.UItemLibrary.GetCharacterCardAbilityValueByIndex(InCate, pItem, NewLevel, ItemQua)
        -- print("nNow",nNow,"nNew", nNew,"nBreak",nBreak,"InCate",InCate)
        return nNow, nNew
    elseif InIndex == 2 then
        local nNow = UE4.UItemLibrary.GetCharacterCardAbilityValueByIndex(InCate, pItem, ItemLv, nBreak)
        local nNew = UE4.UItemLibrary.GetCharacterCardAbilityValueByIndex(InCate, pItem, ItemLv, nBreak + 1)
        -- print("nNow, nNew,nBreak",nNow, nNew,nBreak)
        return nNow, nNew
    end
end

--- 相同类型卡的相同属性比较
---@param InItem1 UItem 卡一
---@param InItem2 UItem 卡二
---@param InCate ELogiAttrType 属性类别
function Logistics.GetAttrChangeByItem(InItem1, InItem2, InCate)
    local ECompare = AttrSign.AttrNone
    if (not InItem1) or (not InItem2) then
        return
    end
    local nAtt1 = UE4.UItemLibrary.GetCharacterCardAbilityValue(InCate, InItem1)
    local nAtt2 = UE4.UItemLibrary.GetCharacterCardAbilityValue(InCate, InItem2)
    if nAtt1 == nAtt2 then
        return ECompare
    elseif nAtt1 > nAtt2 then
        ECompare = AttrSign.AttrSub
        return ECompare
    elseif nAtt1 < nAtt2 then
        ECompare = AttrSign.AttrPluse
        return ECompare
    end
end

--- 账号下的所有后勤卡
---@return AllSupportCard UE4.USupporterCard table
function Logistics.GetAllSupportCards()
    local AllSupportCard = UE4.TArray(UE4.USupporterCard)
    me:GetSupporterCards(AllSupportCard)
    return AllSupportCard:ToTable()
end

---对应插槽可装备的后勤卡
---@return slotSupportCards UE4.USupporterCard 对应插槽下的后勤卡table
function Logistics.GetSlotSupportCards(InType)
    local slotSupportCards = UE4.TArray(UE4.USupporterCard)
    me:GetSupporterCardsForType(InType,slotSupportCards)
    return slotSupportCards:ToTable()
end

--- 获取角色卡装备后勤卡信息
---@return tbale [UCharacterCard,USupportCard]
function Logistics.GetEquipInfo()
    local tbCharacterCard = UE4.TArray(UE4.UCharacterCard)
    local tbEquip = {}
    me:GetCharacterCards(tbCharacterCard)
    for i = 1, tbCharacterCard:Length() do
        local tbSlot = UE4.TArray(UE4.USupporterCard)
        tbCharacterCard:Get(i):GetSupporterCards(tbSlot)
        for j = 1, tbSlot:Length() do
            tbEquip[tbSlot:Get(j)] = tbCharacterCard:Get(i)
        end
    end
    return tbEquip
end

--- 获取角色卡装备后勤卡信息 key指为道具Id
---@return tbale [USupportCard Id,UCharacterCard]
function Logistics.GetEquipInfoWithId()
    local tbCharacterCard = UE4.TArray(UE4.UCharacterCard)
    local tbEquip = {}
    me:GetCharacterCards(tbCharacterCard)
    for i = 1, tbCharacterCard:Length() do
        local tbSlot = UE4.TArray(UE4.USupporterCard)
        tbCharacterCard:Get(i):GetSupporterCards(tbSlot)
        for j = 1, tbSlot:Length() do
            tbEquip[tbSlot:Get(j):Id()] = tbCharacterCard:Get(i)
        end
    end
    return tbEquip
end

--- 获取消耗的道具
---@return tbMats pItems 当前选择的道具
function Logistics.GetSelectComsumes()
    local tbMats = {}
    for k, v in pairs(Logistics.tbConsumes) do
        table.insert(tbMats, {Id = k:Id(), Num = v})
    end
    return tbMats
end

---清除消耗
function Logistics.ClearConsume()
    Logistics.tbConsumes = {}
end

function Logistics.GetBreakMax(InItem)
    if InItem and Item.tbBreakLevelLimit[InItem:BreakLimitID()] then
        return #Item.tbBreakLevelLimit[InItem:BreakLimitID()]
    end
    return 0
end

---@param pItem UE4.Item 升级或突破的后勤卡
---@return CultType 返回后勤卡养成类型(1:升级，2：突破)
function Logistics.GetCultType(pItem)
    local CultType = 0
    if pItem:EnhanceLevel() < Item.GetMaxLevel(pItem) then
        CultType = 1
        return CultType
    end
    if pItem:EnhanceLevel() == Item.GetMaxLevel(pItem) then
        CultType = 2
        return CultType
    end
end

function Logistics.GetBeCharacterCard(InSupportCard)
    if InSupportCard then
        Logistics.RoleCards = UE4.TArray(UE4.UCharacterCard)
        me:GetCharacterCards(Logistics.RoleCards)
        for i = 1, Logistics.RoleCards:Length() do
            local TempSupport = Logistics.RoleCards:Get(i):GetSupporterCard(InSupportCard:Detail())
            if TempSupport and TempSupport:Id() == InSupportCard:Id() then
                local pBeRoleCard = Logistics.RoleCards:Get(i)
                return pBeRoleCard
            end
        end
    end
end

--- 获取后勤卡套装技能
---@param InItem  UE4.UItem 后勤卡
function Logistics.GetSuitSkill(InItem)
    local TwoSuitSkill = UE4.TArray(UE4.int32)
    local ThirdSuitSkill = UE4.TArray(UE4.int32)
    InItem:GetSuitSkills(2, TwoSuitSkill)
    InItem:GetSuitSkills(3, ThirdSuitSkill)
    return TwoSuitSkill, ThirdSuitSkill
end

--- 获取后勤卡套装ID
function Logistics.GetSkillSuitId(InCard)
    local pTemplate = UE4.UItem.FindTemplateForID(InCard:TemplateId())
    return pTemplate.SuitSkill
end

--- 获得词缀显示
--- @param affixInput Tarray 词缀数组
--- @param affixIndex number 第几个词缀
--- @return string 词缀的描述
function Logistics.GetAffixShowNameByTarray(affixInput, affixIndex)
    if affixInput:Length() <= 0 or affixInput:Get(1) == 0 or affixInput:Get(2) == 0 then
        if affixIndex == 1 then
            return Text("ui.TxtLogisAffixUnlockCondition1")
        elseif affixIndex == 2 then
            return Text("ui.TxtLogisAffixUnlockCondition2")
        else
            return Text("ui.TxtLogisAffixUnlockCondition3")
        end
    end

    local affixValue = Logistics.tbAffixValue[affixInput:Get(1)]
    if not affixValue then
        if affixIndex == 1 then
            return Text("ui.TxtLogisAffixUnlockCondition1")
        elseif affixIndex == 2 then
            return Text("ui.TxtLogisAffixUnlockCondition2")
        else
            return Text("ui.TxtLogisAffixUnlockCondition3")
        end
    end
    return Logistics.GetAffixShowName(affixValue.key, affixValue.value[affixInput:Get(2)][1], affixIndex)
end

--- 获得词缀ID和数值
--- @param affixInput Table 词缀table
--- @return int, float 词缀等级, 数值
function Logistics.GetAffixValue(affixInput)
    if affixInput:Length() <= 0 or affixInput:Get(1) == 0 or affixInput:Get(2) == 0 then 
        return 0
    end
    local affixValue = Logistics.tbAffixValue[affixInput:Get(1)]
    if not affixValue then return 0 end
    return affixInput:Get(2), affixValue.value[affixInput:Get(2)][1]
end

function Logistics.GetAffixShowName(affixKey, affixValue, affixIndex)
    if (not affixKey) or (not affixValue) or affixKey == "" or affixValue == "" then
        if affixIndex == 1 then
            return Text("ui.TxtLogisAffixUnlockCondition1")
        elseif affixIndex == 2 then
            return Text("ui.TxtLogisAffixUnlockCondition2")
        else
            return Text("ui.TxtLogisAffixUnlockCondition3")
        end
    end
    return string.format(Text(string.format("supportattribute.%s", affixKey)), affixValue)
end

--- 获得后勤卡的最大等级
--- @param InItem  UE4.UItem 后勤卡
--- @return number 可以到达的最大等级(无视突破次数)
function Logistics.GetMaxLevel(InItem)
    local cfg = Item.tbBreakLevelLimit[InItem:BreakLimitID()]
    if not cfg then
        return nil
    end
    return cfg[#cfg] or nil
end

--- 检查是否解锁了突破立绘
function Logistics.CheckUnlockBreakImg(Incard)
    local MaxBreak = Logistics.GetBreakMax(Incard)
    if Incard:Break() >= MaxBreak - 1 then
        return true
    end
    return false
end

--- 后勤卡装备
---@param EquipItem UE4.UItem 需要装备的角色卡
---@param beEquipItem UE4.UItem 被装备的后勤卡
---@param InMode Model 操作模式
Logistics.EquipCallBack = nil
Logistics.ForceEquipCallBack = nil
function Logistics.Req_Equip(InParam, InCallBack, InUnCallback)
    --InParam
    --- 请求模式
    if not InParam.Model then
        print("err.logi_operation")
    end
    --- 需要装备的角色卡是否存在
    if not InParam.pRCard then
        UI.ShowTip("tip.equip Role card err")
    end

    ---当前后勤卡存在
    if not InParam.pSCard then
        UI.ShowTip("tip.not_the_logistics_card")
        return
    end
    ---当前账户不存在该后勤卡
    if not me:GetItem(InParam.pSCard:Id()) then
        UI.ShowTip("tip.not_the_logistics_card")
        return
    end
    --- 确定是否可以装备该后勤卡
    if InParam.pSCard:Detail() ~= Logistics.SelectType then
        UI.ShowTip("tip.logistics_card_category_not_match")
        return
    end
    local cmd = {
        EqId = InParam.pRCard:Id(),
        beEqId = InParam.pSCard:Id(),
        EqSlot = InParam.pSCard:Detail(),
        Model = InParam.Model,
        bForce = InParam.bForce,
        BEqId = InParam.BEqId
    }
    Logistics.EquipCallBack = InCallBack
    Logistics.ForceEquipCallBack = InUnCallback
    UI.ShowConnection()
    me:CallGS("SupporterCard_Equip", json.encode(cmd))
end

s2c.Register(
    "Logistics_Equip",
    function()
        UI.CloseConnection()
        if Logistics.EquipCallBack then
            Logistics.EquipCallBack()
            Logistics.EquipCallBack = nil
        end
    end
)

s2c.Register(
    "Logistics_Confirm",
    function()
        UI.CloseConnection()
        if Logistics.ForceEquipCallBack then
            Logistics.ForceEquipCallBack()
            Logistics.ForceEquipCallBack = nil
        end
    end
)

--- 后勤卡更换(待定)
Logistics.ChangeCallBack = nil
---@param InRoleCard UE4.UItem 角色卡
---@param InLogiID UE4.UItem 后勤卡
---@param InCallBack any
function Logistics.Req_EquipChange(InRoleCard, InLogiID, InCallBack)
    --- 需要装备的角色卡是否存在
    if not InRoleCard then
        UI.ShowTip("tip.equip Role card err")
    end
    ---当前后勤卡存在
    if not InLogiID then
        UI.ShowTip("tip.not_the_logistics_card")
        return
    end
    ---当前账户存在该后勤卡
    if not me:GetItem(InLogiID:Id()) then
        UI.ShowTip("tip.not_the_logistics_card")
        return
    end
    --- 确定该账户是否装备有后勤卡
    -- local IsLogiCard = InItem:GetSlotItem(UE4.ESlotType.SupporterCard)
    -- if not IsLogiCard then
    --     InItem:AddSlotItem(UE4.ESlotType.SupporterCard, LogisticCard)
    -- end
    local cmd = {
        EqId = InRoleCard:Id(),
        beEqId = InLogiID:Id(),
        EqSlot = Logistics.SelectType
    }

    Logistics.EquipCallBack = InCallBack
    UI.ShowConnection()
    me:CallGS("SupporterCard_Equip", json.encode(cmd))
end

s2c.Register(
    "Logistics_Change",
    function()
        UI.CloseConnection()
        if Logistics.ChangeCallBack then
            Logistics.ChangeCallBack()
            Logistics.ChangeCallBack = nil
        end
    end
)
--- 后勤卡卸载（待定）
Logistics.UnLoadCallBack = nil
function Logistics.Req_LogisticsUnLoad(InItem, InCallBack)
    -- body
end

s2c.Register(
    "Logitic_UnLoad",
    function()
        if Logistics.UnLoadCallBack then
            Logistics.UnLoadCallBack()
            Logistics.UnLoadCallBack = nil
        end
    end
)

---后勤卡升级
Logistics.UpGradeCallBack = nil
function Logistics.Req_UpLogistics(InItem,InMat, InCallBack)
    local cmd = {
        Id = InItem:Id(),
        tbMaterials = InMat
    }
    Logistics.UpGradeCallBack = InCallBack
    UI.ShowConnection()
    me:CallGS("SupporterCard_Upgrade", json.encode(cmd))
end

s2c.Register("Logistics_Upgrade", function()
    UI.CloseConnection()
    if Logistics.UpGradeCallBack then
        Logistics.UpGradeCallBack()
        Logistics.ClearConsume()
        Logistics.UpGradeCallBack = nil
    end
end)

---后勤卡进化
Logistics.EvolutionCallBack = nil
function Logistics.Req_Evolution(InLogistics, InCallBack)
    local tbMats = Logistics.GetSelectComsumes()
    if #tbMats <= 0 then
        UI.ShowTip("tip.logistic materal not enough")
    end

    local cmd = {}
    me:CallGS("Logistics_Evolution", json.encode(cmd))
end

s2c.Register(
    "Logistics_Evolution",
    function()
        if Logistics.EvolutionCallBack then
            Logistics.EvolutionCallBack()
            Logistics.EvolutionCallBack = nil
        end
    end
)

---后勤卡突破
Logistics.BreakCallBack = nil
function Logistics.Req_BreakLogistics(InItem, InCallBack)

    local pBreakItem = Item.GetBreakMaterials(InItem)
    if not pBreakItem then
        -- if not pBreakItem then
        EventSystem.TriggerTarget(Logistics, Logistics.OnLimitEvol)
        UI.ShowTip("tip.logistic_material_not_enough_cost")
        return
    --     else
    --         UI.ShowTip("tip.support_max_level")
    --         return
    --     end
    -- else
    --     if not pBreakItem then
    --         EventSystem.TriggerTarget(Logistics, Logistics.OnLimitEvol)
    --         UI.ShowTip("tip.logistic_material_not_enough")
    --         return
    --     end
    end

    if #pBreakItem <= 0 then
        UI.ShowTip("tip.logistic_material_not_enough_cost")
        return
    end

    ---当前突破材料数目足够
    if #pBreakItem > 0 then
        for i = 1, #pBreakItem do
            local pItem = pBreakItem[i]
            local nHaveBreakItem = me:GetItemCount(pItem[1], pItem[2], pItem[3], pItem[4])
            if nHaveBreakItem < pBreakItem[i][5] then
                UI.ShowTip("error.logistic_material_not_enough_cost")
                return
            end
        end
    end

    local cmd = {
        Id = InItem:Id(),
        tbMaterials = pBreakItem
    }
    Logistics.BreakCallBack = InCallBack
    UI.ShowConnection()
    me:CallGS("SupporterCard_Break", json.encode(cmd))
end

s2c.Register(
    "Logistics_Break",
    function()
        UI.CloseConnection()
        if Logistics.BreakCallBack then
            Logistics.BreakCallBack()
            Logistics.BreakCallBack = nil
        end
    end
)

--- 后勤技能进化
---@param InSkillId integer 技能Id
Logistics.LogiSkillEvolutCallBack = nil
function Logistics.Req_Evolut(InItem, InCallBack)
    local SkillId = Logistics.GetSkillID(InItem)
    if not SkillId then
        print(Text("skill id%s err"), SkillId)
    end
    --- 升级材料
    local num = 1
    local tbMat = Logistics.GetSkillEvolutMats(InItem, num)

    for k, v in pairs(tbMat) do
        if tbMat[k][5] > me:GetItemCount(tbMat[k][1], tbMat[k][2], tbMat[k][3], tbMat[k][4]) then
            return UI.ShowTip("tip.material_not_enough")
        end
    end
    local cmd = {
        Id = InItem:Id(),
        MatID = tbMat
    }
    Logistics.LogiSkillEvolutCallBack = InCallBack
    me:CallGS("SupporterSkill_Evolut", json.encode(cmd))
end

function Logistics.GetBgTexture(Incard)
    if not Incard then
        return
    end
    local gerne = Incard:Genre()
    local level = Incard:Level()
    local particular = Incard:Particular()
    local Detail = Incard:Detail()

    for key, value in pairs(Logistics.tbLogiData) do
        if gerne == value._G and level == value._L and particular == value._P and Detail == value._D then
            return Resource.Get(value.Backgrounds)
        end
    end
end

s2c.Register(
    "LogiSkill_Evolut",
    function()
        if Logistics.LogiSkillEvolutCallBack then
            Logistics.LogiSkillEvolutCallBack()
            Logistics.LogiSkillEvolutCallBack = nil
        end
    end
)

--- 后勤词缀重置
Logistics.LogiAffixResetCallBack = nil
--- @param Incard table 后勤卡
function Logistics.Req_ResetAffix(Incard, Mat, InCallBack)
    if not Incard then
        return
    end
    local cmd = {
        Id = Incard:Id(),
        Mat = Mat,
    }
    Logistics.LogiAffixResetCallBack = InCallBack
    UI.ShowConnection()
    me:CallGS("SupporterCard_ResetAffix", json.encode(cmd))
end

s2c.Register(
    "SupporterCard_ResetAffix",
    function()
        UI.CloseConnection()
        if Logistics.LogiAffixResetCallBack then
            Logistics.LogiAffixResetCallBack()
            Logistics.LogiAffixResetCallBack = nil
        end
    end
)

--- 后勤词缀选择
Logistics.LogiAffixSelectCallBack = nil
--- @param Incard table 后勤卡
--- @param SelectNew boolean 是否选择新的词缀
function Logistics.Req_SelectAffix(Incard, SelectNew, InCallBack)
    if not Incard then
        return
    end
    local cmd = {
        Id = Incard:Id(),
        SelectNew = SelectNew,
    }
    Logistics.LogiAffixSelectCallBack = InCallBack
    UI.ShowConnection()
    me:CallGS("SupporterCard_SelectAffix", json.encode(cmd))
end

s2c.Register(
    "SupporterCard_SelectAffix",
    function()
        UI.CloseConnection()
        if Logistics.LogiAffixSelectCallBack then
            Logistics.LogiAffixSelectCallBack()
            Logistics.LogiAffixSelectCallBack = nil
        end
    end
)
-----------------------------load SupportCard--------------
function Logistics.LoadRoleConfig()
    local tbConfig = LoadCsv("item/templates/support_card.txt", 1)
    for _, Data in pairs(tbConfig) do
        local nClose = tonumber(Data.Close)
        if (not nClose) or nClose == 0 then
            local tbInfo = {
                _G = tonumber(Data.Genre) or 0,
                _D = tonumber(Data.Detail) or 0,
                _P = tonumber(Data.Particular) or 0,
                _L = tonumber(Data.Level) or 0,
                I18n = Data.I18n or nil,
                Icon = tonumber(Data.Icon),
                Color = tonumber(Data.Color),
                Backgrounds = tonumber(Data.Backgrounds),
                BreakMatID = tonumber(Data.BreakMatID) or 0,
                LevelLimitID = tonumber(Data.LevelLimitID) or 0,
                BreakLimitID = tonumber(Data.BreakLimitID) or 0,
                EvolutionMatID = tonumber(Data.EvolutionMatID), -- 技能升级材料配置ID
                GrowupID = tonumber(Data.GrowupID), -- 成长属性ID
                DefaultSkillsID = tonumber(Data.DefaultSkills), -- 后勤卡默认技能ID
                SuitSkillID = tonumber(Data.SuitSkillID), -- 套装技能对应ID
                AffixCost = Eval(Data.AffixCost), --洗练需要的材料
                StoryUnlock = Eval(Data.StoryUnlock) --档案解锁条件
            }
            ---通过GDPL存储成长ID
            local sGDPL = string.format("%s-%s-%s-%s", Data.Genre, Data.Detail, Data.Particular, Data.Level)
            Logistics.tbLogiData[sGDPL] = tbInfo

            Logistics.tbAllLogiSuit[tbInfo._P] = Logistics.tbAllLogiSuit[tbInfo._P] or {}
            Logistics.tbAllLogiSuit[tbInfo._P][tbInfo._D] = tbInfo

            if sGDPL and #sGDPL > 0 then
                local tbGrowupInfo = {
                    GrowupID = tonumber(Data.GrowupID) or 0
                }
                Logistics.tbGDPLGrowupID[sGDPL] = tbGrowupInfo
            end
        end
    end
end

--- 读取成长属性配置
function Logistics.LoadGrowConfig()
    local tbConfig = LoadCsv("item/support/grow.txt", 1)
    Logistics.tbMainAttr = {}
    Logistics.tbSubAttr = {}
    local tbAttr = {}
    for _, tbLine in pairs(tbConfig) do
        local ID = tonumber(tbLine.ID)
        local tbInfo = {}
        for key, value in pairs(tbLine) do
            if key ~= "ID" and key ~= "Comment" then
                tbInfo[key] = Eval(value)
                if not tbAttr[key] then
                    if string.find(key, "break") then
                        table.insert(Logistics.tbSubAttr, key)
                    else
                        table.insert(Logistics.tbMainAttr, key)
                    end
                    tbAttr[key] = true
                end 
            end
        end
        Logistics.tbGrow[ID] = tbInfo
    end
end

--- 技能升级消耗配置
function Logistics.LoadSkillConfig()
    local tbFile = LoadCsv("item/support/skill_upgrade.txt", 1)
    for _, tbLine in pairs(tbFile) do
        local nId = tonumber(tbLine.ID or "0")
        Logistics.tbSkillMaterial[nId] =
            {
            Eval(tbLine.Items1),
            Eval(tbLine.Items2),
            Eval(tbLine.Items3),
            Eval(tbLine.Items4),
            Eval(tbLine.Items5)
        } or nil
    end
    -- Dump(Logistics.tbSkillMaterial)
end

---技能套装ID配置表
function Logistics.LoadSkillIDConfig()
    local tbConfig = LoadCsv("item/support/suit_skill.txt", 1)
    for _, tbLine in pairs(tbConfig) do
        local nId = tonumber(tbLine.ID) or 0
        local tbInfo = {
            Id = tonumber(tbLine.ID) or 0,
            TwoSkillID = Eval(tbLine.TwoSkillID),
            ThreeSId = Eval(tbLine.ThreeSkillID)
        }
        if tbInfo.Id and tbInfo.Id > 0 then
            Logistics.tbSkillSuitID[nId] = tbInfo or {}
        end
    end
    -- Dump(Logistics.tbSkillSuitID)
end

--获取套装技能列表
--策划要求按品质、P 降序排列
function Logistics.GetSuitSkillList()
    Logistics.tbSuitSKillList = {}
    local tbMap = {}
    local tbList = {}
    for _, info in pairs(Logistics.tbLogiData) do
        if not tbMap[info.SuitSkillID] then
            tbMap[info.SuitSkillID] = true
            table.insert(tbList, {info.SuitSkillID, info.Color, info._P})
        end
    end

    table.sort(tbList, 
        function (l, r)
            if l[2] ~= r[2] then
                return l[2] > r[2]
            end

            return l[3] > r[3]
        end
    )

    for _, tb in pairs(tbList) do
        local tbInfo = Logistics.tbSkillSuitID[tb[1]]
        table.insert(Logistics.tbSuitSKillList, {SkillName(tbInfo.TwoSkillID[1]), tbInfo.TwoSkillID[1]})
        print(SkillName(tbInfo.TwoSkillID[1]))
    end
    

    return Logistics.tbSuitSKillList
end

---技能套装ID配置表
function Logistics.LoadAffixValuePool()
    local tbFile = LoadCsv('item/support/affix.txt', 1);

    for _, tbLine in ipairs(tbFile) do 
        local Id;
        local AttrKey, AttrValue;
        for key, value in pairs(tbLine) do 
            if key ~= "" then 
                if key == "ID" then 
                    Id = tonumber(value);
                else 
                    AttrKey = key
                    AttrValue = Eval(value)
                end
            end
        end
        if Id > 0 then
            Logistics.tbAffixValue[Id] = {key = AttrKey, value = AttrValue}
        end
    end
end

function Logistics.__Init()
     Logistics.LoadRoleConfig()
    Logistics.LoadSkillConfig()
    Logistics.LoadSkillIDConfig()
    Logistics.LoadGrowConfig()
    Logistics.LoadAffixValuePool()
end
Logistics.__Init()

---登录初始化
EventSystem.On(Event.Logined, function(bReconnected, bNeedRename)
    if bReconnected then return end
    Logistics.Card = nil
    Logistics.CurRole = nil
    Logistics.CurCard = nil
end)

---获取一个套装的所有后勤卡信息
function Logistics.GetSuitLogisticsCfg(Particular)
    local tb = {}
    for _, cfg in pairs(Logistics.tbAllLogiSuit[Particular] or {}) do
        table.insert(tb, cfg)
    end
    return tb
end




return Logistics
