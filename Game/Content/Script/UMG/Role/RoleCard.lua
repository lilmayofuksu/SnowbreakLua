-- ========================================================
-- @File    : RoleCard.lua
-- @Brief   : 角色养成数据管理器
-- @Author  :
-- @Date    :
-- ========================================================

---@class RoleCard
RoleCard = RoleCard or {
        tbGrow = {},
        tbBreakCondition = {},
        tbConsumes = {},
        tbTipDate = {},
        tbShowSkills = {}
    }

------------------------------//-----------------------------
RoleCard.Index = 0
RoleCard.SeleCard = nil
RoleCard.tbLvData = {}
RoleCard.SecExp = 0
---选择道具变化通知
RoleCard.MaterialsChangeHandle = "ON_COSTMATCOIN_CHANGE"
---角色卡升级失败提示
RoleCard.RoleLvUpFailTipHandle = "ON_ROLELVUPTIP_FAIL"
---角色卡突破失败提示
RoleCard.RoleBreakFailTipHandle = "ON_ROLEBREAKTIP_FAIL"
--- 展示技能详情界面
RoleCard.ShowSkillDetailHandle = "SKILL_DETAIL_HANDLE"
--- 职级提升后通知
RoleCard.ProLevelPromoteHandle = "ON_PROLEVEL_PROMOTE"
---是否可以升级或者突破
RoleCard.IsChange = false
---记录升级前的角色卡等级
RoleCard.ItemProEnhanceLv = 1
--- 角色卡升级材料
RoleCard.UpMat = {{5,1,1,1},{5,1,1,2},{5,1,1,3},{5,1,1,4}}
--- 角色等级上限
RoleCard.ROLEMINLIMIT = 15
RoleCard.ROLEMAXLIMIT = 80

--- 角色列表页签
RoleCard.pPage ={
    nMin    = 1,       --- 页签最小索引
    nMax    = 5,       --- 页签最大索引
    nPage   = 1,       --- 当前页签索引

    Refresh = function(InMin, InMax, InPage)
        RoleCard.pPage.nMin = InMin or RoleCard.pPage.nMin
        RoleCard.pPage.nMax = InMax or RoleCard.pPage.nMax
        RoleCard.pPage.nPage = InPage or RoleCard.pPage.nPage
        if not RoleCard.pPage.nPage or RoleCard.pPage.nPage < RoleCard.pPage.nMin or RoleCard.pPage.nPage > RoleCard.pPage.nMax then
            RoleCard.pPage.nPage = RoleCard.pPage.nMin
        end
        return RoleCard.pPage
    end
}

--- 解锁天启
RoleCard.BreakGID = 80
RoleCard.BreakSubId = 1
RoleCard.SysWidget = {
    Detail = "RoleDetial",
    Arm = "RoleArm",
    LogisDetial = "Logistic",
    LvWidget = "RoleLv",
    BreakWidget = "RoleBreak",
    Spine = "RoleSpine",
}

local var = { pCard = nil, pTemplate = nil , nPage =0, nFrom = 1,nSeneType = PreviewType.role_lvup}

--- 缓存展示角色模型信息
RoleCard.CachRole = {
    --角色卡ID
    Id = 0,
    --角色卡GDPL
    tbGDPL = {},
    --模型
    Model = nil
}

--- 技能类型
RoleCard.SkillType = {
    NormalSkill = "NORMAL_SKILL", --普通技能
    BigSkill = "BIG_SKILL",         -- 大招
    QTESkill = "QTE_SKILL",         --  QTE
    PassiveType = "PASSIVE_SKILL"               -- 被动技能（天启技能）
}

RoleCard.ExpState = {
    ExpAdd = 1,
    ExpSub = 2,
}

--- 红点检测函数
local tbCheckRedFunc = {}
tbCheckRedFunc[0] = function(Template)
    local tbgdpln = Template.PiecesGDPLN
    if tbgdpln and tbgdpln:Length() >= 5 then
        if me:GetItemCount(tbgdpln:Get(1), tbgdpln:Get(2), tbgdpln:Get(3), tbgdpln:Get(4)) >= tbgdpln:Get(5) then
            return true
        end
    end
    return false
end
tbCheckRedFunc[1] = function(Card)
    return not Card:HasFlag(Item.FLAG_READED)
end
tbCheckRedFunc[2] = function(Card)
    if not FunctionRouter.IsOpenById(FunctionType.RoleBreak) then
        return false
    end
    return not RBreak.IsLimit(Card) and RBreak.CheckBreakMat(Card)
end
tbCheckRedFunc[3] = function(Card)
    return not RoleCard.IsMaxLimit(Card) and RoleCard.CanToNextLevel(Card)
end
tbCheckRedFunc[4] = function(Card)
    if not FunctionRouter.IsOpenById(FunctionType.Nerve) then
        return false
    end
    return RoleCard.CheckSpine(Card)
end
tbCheckRedFunc[5] = function(Card)
    if not FunctionRouter.IsOpenById(FunctionType.Logistics) then
        return false
    end

    local tbEquipped = {Card:GetSupporterCardForIndex(1), Card:GetSupporterCardForIndex(2), Card:GetSupporterCardForIndex(3)}
    if tbEquipped[1] and tbEquipped[2] and tbEquipped[3] then
        return false
    end

    local tbEquipInfo  = Logistics.GetEquipInfo()
    local tbHave = {false, false, false}
    local tbSCard = Logistics.GetAllSupportCards()
    for _, SCard in pairs(tbSCard) do
        local SlotType = SCard:GetSlotType()
        if not tbEquipped[SlotType] and not tbHave[SlotType] and not tbEquipInfo[SCard] then
            tbHave[SlotType] = true
            if tbHave[1] and tbHave[2] and tbHave[3] then
                break
            end
        end
    end
    local data = {false, false, false}
    local bRed = false
    for i = 1, 3 do
        if not tbEquipped[i] and tbHave[i] then
            data[i] = true
            bRed = true
        end
    end
    if bRed then
        return data
    end
    return false
end
tbCheckRedFunc[6] = function(Card, pWeapon)
    if not Card then return false end
    return Weapon.CheckRedPointByCard(Card, pWeapon)
end
tbCheckRedFunc[7] = function(Card)
    if not FunctionRouter.IsOpenById(FunctionType.ProLevel) then
        return false
    end

    if not Card then return false end
    local key = table.concat({Card:Genre(), Card:Detail(), Card:Particular(), Card:Level()}, "-")
    local ProLevel = Card:ProLevel()
    if RoleCard.tbProLevelData[key] then
        local cond = RoleCard.tbProLevelData[key].tbCondition[ProLevel+1]
        if cond and Condition.Check(cond) then
            return true
        end
    end
    return false
end

---主界面角色按钮是否显示红点
function RoleCard.IsShowRedDot()
    local ItemTemplates = UE4.TArray(UE4.FItemTemplate)
    UE4.UItemLibrary.GetCharacterTemplates(ItemTemplates)
    for i = 1, ItemTemplates:Length() do
        local template = ItemTemplates:Get(i)
        if RoleCard.CheckTemplateRedDot(template, {0, 1 ,2}) then
            return true
        end
    end
    return false
end
---检查角色template是否能显示红点
---@param template UE4.FItemTemplate 角色template，不能传试玩角色的template，否则会出错
---@param tbType table 要检查的类型
--[[0是否可用角色碎片兑换获得 
    1是否是新角色未查看
    2是否可天启升级
    3是否可角色升级
    4是否可神经升级
    5是否可装备后勤卡
    6是否可装配武器红点
    7是否可职级认定]]
---@return boolean 是否能显示红点
function RoleCard.CheckTemplateRedDot(template, tbType)
    if not template or not tbType then return false end
    local Card = RoleCard.GetItem({template.Genre, template.Detail, template.Particular, template.Level})
    for _, type in pairs(tbType) do
        if type == 0 and not Card then
            if tbCheckRedFunc[0](template) then
                return true
            end
        else
            local Results = RoleCard.CheckCardRedDot(Card, {type})
            if Results then
                return Results
            end
        end
    end
    return false
end
---检查已获得的角色卡是否显示红点
---@param Card UE4.UCharacterCard 角色卡
---@param tbType table 要检查的类型
--[[1是否是新角色未查看
    2是否可天启升级
    3是否可角色升级
    4是否可神经升级
    5是否可装备后勤卡
    6是否可装配武器红点
    7是否可职级认定]]
---@return boolean
function RoleCard.CheckCardRedDot(Card, tbType, ...)
    if not Card or not tbType or Card:IsTrial() then return false end
    for _, type in pairs(tbType) do
        if type ~= 0 and tbCheckRedFunc[type] then
            local Results = tbCheckRedFunc[type](Card, ...)
            if Results then
                return Results
            end
        end
    end
    return false
end

function RoleCard:GetCache()
    if var.nSeneType then
        Preview.Destroy()
    end
    return var
end

function RoleCard:SetCache(InCard, InTemplate, InScene, InFrom)
    var.pCard = InCard
    var.pTemplate = InTemplate
    var.nSeneType = InScene
    var.nFrom = InFrom
end

function RoleCard:Init()
    RoleCard:LoadSkillId()
    ---RoleCard:LoadRoleData()
    RoleCard:LoadRecommendData()
    RoleCard:LoadProLevelData()
    RoleCard:LoadSkillData()
    RoleCard:LoadSkillTagData()

    ---获得角色卡时更新缓存的角色卡
    EventSystem.On(Event.ItemChanged, function(Item)
        if Item and Item:Cast(UE4.UCharacterCard) then
            RoleCard.UpdateHaveCard()
        end
    end)
    ---登录时更新缓存的角色卡
    EventSystem.On(Event.Logined, function()
        RoleCard.UpdateHaveCard()
    end)
end

function RoleCard:GetShowRoleIndex(InIndex)
    RoleCard.Index = InIndex
    --print("RoleCard.Index:", RoleCard.Index)
    return InIndex
end

function RoleCard:GetShowRole()
    return RoleCard.SeleCard
end

--- 检查账号下角色卡的升级材料
function RoleCard.CkeckUpMat()
    for index, value in ipairs(RoleCard.UpMat) do
        local nItemNum = me:GetItemCount(value[1],value[2],value[3],value[4])
        if nItemNum>0 then
            return true
        end
    end
    return false
end

---角色模型当前的动作状态
RoleCard.WidgetAnimType = nil
---角色界面模型加载或者切换动作
function RoleCard.ModifierModel(InTemplate, InCard, ViewType, UIWidgetAnimType, FunBack)
    RoleCard.WidgetAnimType = UIWidgetAnimType
    if InCard  then
        if RoleCard.CachRoleInfo(InCard:Id()) or ViewType == PreviewType.role_spine then
            Preview.PreviewByItemID(InCard:Id(), ViewType, nil, function ()
                if RoleCard.WidgetAnimType and RoleCard.WidgetAnimType ~= UIWidgetAnimType then
                    local Model = Preview.GetModel()
                    if Model and Model:GetModel() then
                        Model:GetModel():SetPreviewCharacterAnimStateType(RoleCard.WidgetAnimType)
                    end
                end
                if FunBack then FunBack() end
            end)
            RoleCard.ResetCach(InCard:Id())
        else
            Preview.PlayCameraAnimByCallback(InCard:Id(), ViewType)
            local Model = Preview.GetModel()
            if Model and Model:GetModel() then
                Model:GetModel():SetPreviewCharacterAnimStateType(UIWidgetAnimType)
            end
            local pUI = UI.GetUI("role")
            if pUI then
                pUI:ResetRotation(Model, ViewType)
            end
            if FunBack then FunBack() end
        end
    elseif InTemplate then
        Preview.PreviewByGDPL(UE4.EItemType.CharacterCard, InTemplate.Genre, InTemplate.Detail, InTemplate.Particular, InTemplate.Level, ViewType, InTemplate.Level, nil, function()
            if RoleCard.WidgetAnimType and RoleCard.WidgetAnimType ~= UIWidgetAnimType then
                local Model = Preview.GetModel()
                if Model and Model:GetModel() then
                    Model:GetModel():SetPreviewCharacterAnimStateType(RoleCard.WidgetAnimType)
                end
            end
            if FunBack then FunBack() end
        end)
        RoleCard.ResetCach()
    end
end

---检查是否需要重新创建角色模型
function RoleCard.CachRoleInfo(InId, InGDPL)
    if not Preview.GetModel() or Preview.GetModel() ~= RoleCard.CachRole.Model then
        return true
    end

    if InId and InId ~= RoleCard.CachRole.Id then
        return true
    end

    if InGDPL and #InGDPL == #RoleCard.CachRole.tbGDPL then
        for index, _value in ipairs(value or {}) do
            if _value ~= InGDPL[index] then
                return true
            end
        end
    end

    return false
end

--- 记录角色模型信息
function RoleCard.ResetCach(InId, InGDPL)
    RoleCard.CachRole.Id = InId or 0
    RoleCard.CachRole.tbGDPL = InGDPL or {}
    RoleCard.CachRole.Model = Preview.GetModel()
end

function RoleCard:GetUpData(InLv, InCate)
    local Coin = 0
    local Exp = 0
    if InCate == 1 then
        Coin = RoleCard.tbLvData[InLv].LvCardCoin
        Exp = RoleCard.tbLvData[InLv].LvCardExp
    elseif InCate == 2 then
        Coin = RoleCard.tbLvData[InLv].LvSusCoin
        Exp = RoleCard.tbLvData[InLv].LvSusExp
    elseif InCate == 3 then
        Coin = RoleCard.tbLvData[InLv].LvWeaCoin
        Exp = RoleCard.tbLvData[InLv].LvWeaExp
    end
    return Coin, Exp
end

--- 战力排序
---@param tbCard table 需要排序的table
---@param InMode integer 排序模式[1:稀有度排序,2:等级排序,3:战力排序,4:属性排序]
---@return table ArrRole 排序后的Arr 
function RoleCard.SortByMode(InMode)
    local  tbRoles = RoleCard.GetAllCharacter()
    local tbSortFun = {
        function(a,b)
            return a.Detail>b.Detail
        end,
        function(a,b)
            return a.Level>b.Level
        end,
        function(a,b)
            print('sort->Power')
            return a.Level>b.Level  -- Item.Zhanli_CardTotal(a)>Item.Zhanli_CardTotal(b)
        end,
        function(a,b)
            return a.Color> b.Color
        end,
        function(a,b)
            print('sort->Attr')
            return a.Color> b.Color
        end
    }
    table.sort(tbRoles,tbSortFun[InMode])
    return tbRoles
end

---根据GDPL获取拥有的角色卡
function RoleCard.GetItem(tbGDPL)
    if not tbGDPL or #tbGDPL < 4 or type(tbGDPL[1]) ~= "number" then
        return nil
    end
    if not RoleCard.tbHaveCard then
        RoleCard.UpdateHaveCard()
    end
    local key = table.concat(tbGDPL, "-")
    local card = RoleCard.tbHaveCard[key]
    if card and card:IsTrial()then
        RoleCard.UpdateHaveCard()
    end
    return RoleCard.tbHaveCard[key]
end
---更新拥有的角色卡
function RoleCard.UpdateHaveCard()
    --缓存拥有的角色卡，key为"g-d-p-l"
    RoleCard.tbHaveCard = {}

    --- DS服务器无需处理
    if me then
        local Cards = UE4.TArray(UE4.UCharacterCard)
        me:GetCharacterCards(Cards)
        for _, value in pairs(Cards:ToTable() or {}) do
            local key = value:Genre() .. "-" .. value:Detail() .. "-" .. value:Particular() .. "-" .. value:Level()
            RoleCard.tbHaveCard[key] = value
        end
    end
end

--------------------------//------------------------------------
function RoleCard.GetGrowConfig(InID, InLevel)
    if RoleCard.tbGrow[InID] == nil or RoleCard.tbGrow[InID][InLevel] == nil then
        return
    end
    return RoleCard.tbGrow[InID][InLevel]
end

function RoleCard.GetSecgradeByGDPL(InG, InD)
    local tbRet = {}
    local AllItems = UE4.TArray(UE4.UItem)
    me:GetItems(AllItems)
    for i = 1, AllItems:Length() do
        local Item = AllItems:Get(i)
        if Item:Genre() == InG and Item:Detail() == InD then
            table.insert(tbRet, Item)
        end
    end
    return tbRet
end

function RoleCard.GetItemByGDPL(InG,InD,InP,InL)
    local tbSuplies = UE4.TArray(UE4.UItem)
    me:GetItemsByType(UE4.EItemType.Suplies, tbSuplies)
    for index, value in ipairs(tbSuplies:ToTable() or {}) do
        if value:Genre() == InG and
            value:Detail() == InD and 
            value:Particular() == InP and
            value:Level() == InL then
            return value
        end
    end
    return nil
end

---暂时选择的升级材料
RoleCard.tbConsumes = {}
function RoleCard.AddConsume(InItem)
    -- print('g-d-p-l',InItem:Genre(),InItem:Detail(),InItem:Particular(),InItem:Level())
    if not RoleCard.tbConsumes[InItem] then
        RoleCard.tbConsumes[InItem] = 1
    else
        RoleCard.tbConsumes[InItem] = RoleCard.tbConsumes[InItem] + 1
    end
    RoleCard.ItemProEnhanceLv = RoleCard.GetShowRole():EnhanceLevel()
    EventSystem.TriggerTarget(RoleCard, RoleCard.MaterialsChangeHandle,RoleCard.ExpState.ExpAdd)
    -- for key, value in pairs(RoleCard.tbConsumes) do
    --     print("g-d-p-l",key:Genre(),key:Detail(),key:Particular(),key:Level())
    -- end
end

function RoleCard.SubConsume(InItem)
    if RoleCard.tbConsumes[InItem] then
        RoleCard.tbConsumes[InItem] = math.max(RoleCard.tbConsumes[InItem] - 1, 0)
        if RoleCard.tbConsumes[InItem] == 0 then
            RoleCard.tbConsumes[InItem] = nil
        end
    end
    EventSystem.TriggerTarget(RoleCard, RoleCard.MaterialsChangeHandle,RoleCard.ExpState.ExpSub)
end

function RoleCard.CheckConsumAdd(InItem, InCurrentNum,bTip)
    local Exp, Gold = RoleCard.GetConsumeExpAndGold()
    local pCard = RoleCard.GetShowRole()
    local CostGold = math.abs(InItem:ConsumeGold())
    local MaxLevel,stip = RoleCard.GetMaxLevel(pCard) -- Item.GetMaxLevel(pCard)
    local Level, DestExp = Item.GetItemDestLevel(pCard:EnhanceLevel(), pCard:Exp(), Exp, Item.TYPE_CARD, MaxLevel)
    if Level >= MaxLevel then
        UI.ShowTip(stip)
        return false
    end
    ---金币是否足够
    -- if Cash.GetMoneyCount(Cash.MoneyType_Silver) < Gold + CostGold then
    --     UI.ShowTip("error.gold_not_enough")
    --     return false
    -- end
    return true
end

function RoleCard.GetSelectConsumes()
    local tbMats = {}
    for k, v in pairs(RoleCard.tbConsumes or {}) do
        if v > 0 then
            table.insert(tbMats, {Id = k:Id(), Num = v})
        end
    end
    return tbMats
end

-- ---@return nCost integry 消耗金币
-- ---@return nExp  integry 增加经验
function RoleCard.GetConsumeExpAndGold()
    local Exp = 0
    local Gold = 0
    RoleCard.SecExp = 0
    for k, v in pairs(RoleCard.tbConsumes or {}) do
        if v > 0 then
            Exp = Exp + k:ProvideExp() * v
            Gold = Gold + math.abs(k:ConsumeGold()) * v
        end
    end
    RoleCard.SecExp = Exp
    return Exp, Gold
end
--- @param nAdd number 动态选择道具时刷新的经验
--- @return nOldLevel integry 等级变化
--- @return nRemain number 升级后刷新当前经验值
function RoleCard.AddExp(nAdd)
    local pItemCard = RoleCard.GetShowRole()
    local nOldLevel = pItemCard:EnhanceLevel()
    local nOldExp = pItemCard:Exp()
    local nRemain = nOldExp + nAdd
    local nUpdateNeed = Item.GetUpgradeExpByLevel(pItemCard, nOldLevel)
    while nUpdateNeed > 0 and nRemain >= nUpdateNeed do
        nOldLevel = nOldLevel + 1
        nRemain = nRemain - nUpdateNeed
        ---当前经验值升级时一定获取的是下一级需要的经验值，
        --- 在动太刷新后可能需要显示的是lv+2的经验值(对接服务器解决)
        nUpdateNeed = Item.GetUpgradeExpByLevel(pItemCard, nOldLevel)
    end
    return nOldLevel, nRemain, nUpdateNeed 
end

---获取等级属性变化值
---@param pItem UE4.UItem 道具卡
---@param InIndex number --(1:升级，2：突破)
---@return DeltaVal integer 属性变化值
function RoleCard.GetAttrChange(InCate, pItem, InIndex)
    if not RoleCard.GetShowRole() then
        return
    end
    ---当前等级
    local ItemLv = pItem:EnhanceLevel()
    ---当前品质
    local ItemQua = pItem:Quality()
    ---当前突破次数
    local ItemEvol = pItem:Evolue()
    if InIndex == 1 then
        local CurVal = tonumber(UE4.UItemLibrary.GetCharacterCardAbilityValueByIndexToStr(InCate, pItem, ItemLv, ItemQua))
        local DeltaVal =
            CurVal -
            tonumber(UE4.UItemLibrary.GetCharacterCardAbilityValueByIndexToStr(InCate, pItem, RoleCard.ItemProEnhanceLv, ItemQua))
        return CurVal, DeltaVal
    elseif InIndex == 2 then
        local CurVal = tonumber(UE4.UItemLibrary.GetCharacterCardAbilityValueByIndexToStr(InCate, pItem, ItemLv, ItemQua))
        local DeltaVal =
            CurVal - tonumber(UE4.UItemLibrary.GetCharacterCardAbilityValueByIndexToStr(InCate, pItem, ItemLv, ItemQua - 1))
        return CurVal, DeltaVal
    end
end

---判断角色卡属性变化
---@param Index number (1:升级，2：突破)
---@return tbCtbChange table 返回变化属性数据（加入服务器数据后需要打开判断）
function RoleCard.CheckAttrChange(Index)
    local tbItemChangeDate = {}
    local AttrCard = RoleCard.GetShowRole()
    for i = 0, UE4.EAttributeType.AttributeType_Max - 1 do
        local CurVal, DeltaVal = RoleCard.GetAttrChange(i, AttrCard, Index)
        local fRoleAttr, fWeaponAttr, fLogisticAttr = UE4.UItemLibrary.GetSingleTotalValueToStr(i,AttrCard)
        local data = tonumber(fRoleAttr) + tonumber(fWeaponAttr) + tonumber(fLogisticAttr)
        if DeltaVal and DeltaVal > 0 then
            --- 调整为(附带其他附件：武器和后勤)升级前数据---升级后数据
            local tbData = {
                sName = Text("attribute." .. UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", i)),
                nNow = data - DeltaVal,
                nAdd = data,
                ECate = UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", i)
            }
            table.insert(tbItemChangeDate, tbData)
        end
    end
    return tbItemChangeDate
end
---Tip数据
---@param Index  integer 1=升级，2=突破
function RoleCard.UpGradeTip(Index)
    local CurCard = RoleCard.GetShowRole()
    local tbData = {
        Lv = 0,
        CurExp = 0,
        nDeltaExp = 0,
        nNextExp = 0
    }
    if Index == 1 then
        tbData.Lv = CurCard:EnhanceLevel()
        tbData.CurExp = CurCard:Exp()
        tbData.nDeltaExp = RoleCard.SecExp
        tbData.nNextLvExp = Item.GetUpgradeExpByLevel(CurCard, tbData.Lv)
        return tbData
    elseif Index == 2 then
        tbData.Lv = CurCard:EnhanceLevel()
        tbData.CurExp = CurCard:Exp()
        tbData.nDeltaExp = tbData.CurExp
        tbData.nNextLvExp = Item.tbUpgradeExp[Item.TYPE_CARD][self.CurLv]
        return tbData
    end
end

--- 获取展示技能
function RoleCard.GetItemShowSkills(InTemplate)
    if not InTemplate then return end
    local TemplateId = UE4.UItemLibrary.GetTemplateId(InTemplate.Genre,InTemplate.Detail,InTemplate.Particular,InTemplate.Level)
    local Template = UE4.UItemLibrary.GetCharacterAtrributeTemplate(TemplateId)
    local ShowSkills = Template.ShowSkills
    local SkillTags = Template.SkillTagName
    local tbQTESkillIds = Template.QTESkillIDs
    return ShowSkills:ToTable(), SkillTags:ToTable(),tbQTESkillIds:ToTable()
end
--- 获取技能Id
function RoleCard.GetId(tbShowSkills, InIndex)
    local Id = tbShowSkills:Get(InIndex)
    return Id
end

--- 获取技能等级
function RoleCard.GetSkillLv(InpTemplate, InSkillId, Card)
    if not InpTemplate and not Card then return end
    local pItem = nil
    if Card then
        pItem = Card
    else
        pItem = RoleCard.GetItem({InpTemplate.Genre,InpTemplate.Detail,InpTemplate.Particular,InpTemplate.Level})
    end
    if not pItem then return end
    local SkillLv = 1
    local tbSkillLv = pItem:GetAllSpineSkill():ToTable()
    for key, value in pairs(tbSkillLv or {}) do
       if InSkillId == key then
            SkillLv = value
            break
       end
    end
    local FixArray = UE4.TArray(UE4.int32)
    pItem:GetBreakSkillFixs(FixArray)
    for i = 1, FixArray:Length() do
        local tbLevelFix = UE4.UAbilityComponentBase.K2_GetSkillFixInfoStatic(FixArray:Get(i)).SkillLevelFixMap:ToTable()
        for key, value in pairs(tbLevelFix) do
            if InSkillId == key then
                SkillLv = SkillLv + value
            end
        end
    end
    return SkillLv
end

function RoleCard.GetMaxSkillLv(InpTemplate, InSkillId, Card)
    if not InpTemplate and not Card then return end
    local pItem = nil
    local nSpineId = 0
    if Card then
        nSpineId = Card:SpineId()
    else
        nSpineId = InpTemplate.SpineID
        -- pItem = RoleCard.GetItem({InpTemplate.Genre,InpTemplate.Detail,InpTemplate.Particular,InpTemplate.Level})
        -- if pItem ~= nil then
        --     nSpineId = pItem:SpineId()
        -- else

        -- end
    end
    -- if not pItem then 
    --     print("no pItem")
    --     return 
    -- end
    local SkillLv = 1
    local  tbSpConfig = Spine.tbKeyId[nSpineId]

    for _,SpConfig in pairs(tbSpConfig or {}) do
        if type(SpConfig) == "table" and SpConfig.SpId then
            local SpNodeConfig = Spine.tbSpineNode[SpConfig.SpId]
            for _,tbNodeConfig in pairs(SpNodeConfig or {}) do
                for _,SkillId in pairs(tbNodeConfig.tbSkillId or {}) do
                    if SkillId == InSkillId then
                        SkillLv = SkillLv + 1;
                    end
                end
            end
        end
    end

    local nGDPL = tonumber(InpTemplate.Genre..InpTemplate.Detail..InpTemplate.Particular..InpTemplate.Level)
    local tbBreakConfig = RBreak.tbBreakId[nGDPL]
    for _,breakSkillID in pairs(tbBreakConfig.SkillId or {}) do
        local tbLevelFix = UE4.UAbilityComponentBase.K2_GetSkillFixInfoStatic(breakSkillID[1]).SkillLevelFixMap:ToTable()
        for key,value in pairs(tbLevelFix or {}) do
            if key == InSkillId then
                SkillLv = SkillLv + value
            end
        end
    end

    return SkillLv
end

---获取所有角色Template
---@param InFrom integer 等于2时只获取拥有的角色Template
---@return table
function RoleCard.GetAllCharacter(InFrom)
    local  ItemTemplates = UE4.TArray(UE4.FItemTemplate)
    UE4.UItemLibrary.GetCharacterTemplates(ItemTemplates)
    local tbTemplate = {}
    for i = 1, ItemTemplates:Length() do
        if InFrom == 2 then --只获取拥有的角色Template
            local tpl = ItemTemplates:Get(i)
            local bHaveCard = RoleCard.GetItem({tpl.Genre,tpl.Detail,tpl.Particular,tpl.Level})
            if bHaveCard then
                table.insert(tbTemplate,tpl)
            end
        else
            table.insert(tbTemplate,ItemTemplates:Get(i))
        end
    end
    return tbTemplate
end

---角色卡是否在Table中
function RoleCard.CharacterCardIsInTable(Item, tbItems)
    if not Item then return false end
    for _, value in pairs(tbItems or {}) do
        if value:Id() == Item:Id() then
            return true
        end
    end
    return false
end

---角色Templat是否在Table中
function RoleCard.TemplateIsInTable(Item, tbItems)
    if not Item then return false end
    for _, value in pairs(tbItems or {}) do
        if Item.Genre == value.Genre and Item.Detail == value.Detail and Item.Particular == value.Particular and Item.Level == value.Level then
            return true
        end
    end
    return false
end

--QTE技能类型展示
function RoleCard.GetQTEType(InId)
    -- print('nQTESkillID',InId)
    local tbQTEData = {1300100 ,1300101 ,1300102,1300103,1300104 }
    if not InId then return  end
    local SkillInfo = UE4.UItemLibrary.GetSkillTemplate(InId)
    local bAsStaySkill =  SkillInfo.bAsStaySkill
    local tbConditionSetting = SkillInfo.CastCondition:ToTable()
    if tbConditionSetting[1] and tbConditionSetting[1].ConditionsInfo:ToTable()[1] then
        local ConditionTypeSoftPath = tbConditionSetting[1].ConditionsInfo:ToTable()[1].ConditionTypePath
        if not ConditionTypeSoftPath then return end
        local ConditionTypePath =  UE4.UKismetSystemLibrary.BreakSoftClassPath(ConditionTypeSoftPath)
        if not ConditionTypePath then return end
        local ConditionTypeClass = UE4.UClass.Load(ConditionTypePath)
        if not ConditionTypeClass then return end
        local sParam4 = tbConditionSetting[1].ConditionsInfo:ToTable()[1].Param4.ParamValue
        local QTEIcoID = tbQTEData[1]
        if ConditionTypeClass:GetName() == "ApplyHit_HitType_C" then ---追击或者斩杀
            if sParam4 == "全" then
                QTEIcoID = tbQTEData[1]    ---追击
            else
                QTEIcoID = tbQTEData[5]    ---斩杀
            end
        elseif ConditionTypeClass:GetName() == "Condition_CharacterState_C" then QTEIcoID = tbQTEData[2] ---守护
        elseif ConditionTypeClass:GetName() == "Condition_Friend_SkillCast_C" then  QTEIcoID = tbQTEData[3] ---连续
        elseif ConditionTypeClass:GetName() == "Condition_ReloadBullet_C" then  QTEIcoID = tbQTEData[4]---精械
        end
        return QTEIcoID ,SkillInfo.bQTEEndSwitchBack
    end
end

--- 获取角色卡等级上限
function RoleCard.GetMaxLevel(InItem)
    local sTip = "tip.girlcard_level_limit"
    if InItem:IsCharacterCard() then
        local level = me:Level()
        if level <= RoleCard.ROLEMINLIMIT then
            return RoleCard.ROLEMINLIMIT, Text(sTip, InItem:EnhanceLevel()+1)
        elseif level > RoleCard.ROLEMINLIMIT and level < RoleCard.ROLEMAXLIMIT then
            return level, Text(sTip, me:Level()+1)
        else
            sTip = "tip.card_max_level"
            return RoleCard.ROLEMAXLIMIT, sTip
        end
    end
end

--- 是否已经达到等级限制
function RoleCard.IsMaxLimit(InItem)
    local nLimit = RoleCard.GetMaxLevel(InItem)
    return InItem:EnhanceLevel() >= nLimit
end

--- 检查现有材料是否足够角色卡升一级
function RoleCard.CanToNextLevel(InCard)
    if not InCard then return false end
    local nNeedExp = Item.GetUpgradeExpByLevel(InCard, InCard:EnhanceLevel()) - InCard:Exp()
    local Exp = 0
    local Gold = 0
    for _, v in ipairs(RoleCard.UpMat) do
        local nItemNum = me:GetItemCount(v[1], v[2], v[3], v[4])
        if nItemNum > 0 then
            local iteminfo = UE4.UItem.FindTemplate(v[1], v[2], v[3], v[4])
            local nNeedNum = math.ceil((nNeedExp - Exp)/iteminfo.ProvideExp)
            nNeedNum = math.min(nNeedNum, nItemNum)
            Exp = Exp + iteminfo.ProvideExp * nNeedNum
            Gold = Gold + math.abs(iteminfo.ConsumeGold) * nNeedNum
            if Exp >= nNeedExp and Cash.GetMoneyCount(Cash.MoneyType_Silver) >= Gold then
                return true
            end
        end
    end
    return false
end

--- 检查天启红点
function RoleCard.CheckBreak(InItem)
    return RBreak.CheckBreakMat(InItem)
end

---检查脊椎红点
function RoleCard.CheckSpine(InItem)
    local SpineId = InItem:SpineId()
    local tbNodeCond = nil
    local RecordIndx = Spine.GetRecordIndx(InItem:Id())
    local SPId = Spine.tbKeyId[SpineId][Spine.GetProgresNum(InItem)].SpcondId
    if RecordIndx == 0 then
        for i = 1, Spine.MaxMastNum do
            for j = 1, Spine.MaxSubNum do
                tbNodeCond = Spine.tbSpineNodeCond[SPId][j].NodeCondition
                if not InItem:GetSpine(i,j) then
                    return Spine.CheckLv(InItem, tbNodeCond) and Spine.CheckMat(SPId,j,InItem)
                end
            end
        end
    else
        for j = 1, Spine.MaxSubNum do
            tbNodeCond = Spine.tbSpineNodeCond[SPId][j].NodeCondition
            if not InItem:GetSpine(RecordIndx,j) then
                return Spine.CheckLv(InItem, tbNodeCond) and Spine.CheckMat(SPId,j,InItem)
            end
        end
    end
    return false
end

------------------------------------req--------------------------------------------
--角色升级Req
RoleCard.LvUpCallBack = nil
function RoleCard.Req_LevelUp(InItem, InCallBack)
    if not InItem or InItem:IsTrial() then
        UI.ShowTip("tip.girlcard_update_failed")
        return
    end

    local tbMats = RoleCard.GetSelectConsumes()

    ---当前账号等级限制
    local nLimit ,stip = RoleCard.GetMaxLevel(InItem)
    if InItem:EnhanceLevel() > nLimit then
        UI.ShowTip(stip)
        return
    end

    if #tbMats <= 0 then
        RoleCard.IsChange = false
        UI.ShowTip("tip.material_not_enough")
        --EventSystem.TriggerTarget(RoleCard, RoleCard.RoleLvUpFailTipHandle)
        print("not consumes")
        return
    end

    local cmd = {
        Id = InItem:Id(),
        tbMaterials = tbMats
    }
    RoleCard.IsChange = true
    RoleCard.LvUpCallBack = InCallBack
    UI.ShowConnection()
    me:CallGS("GirlCard_UpdateLevel", json.encode(cmd))
end

s2c.Register("GirlCard_UpdateLevel", function(rsp)
    UI.CloseConnection()
    RoleCard.tbConsumes = {}
    if RoleCard.LvUpCallBack then
        RoleCard.LvUpCallBack()
        RoleCard.LvUpCallBack = nil
    end
end)

--角色突破
RoleCard.BreakCallBack = nil
function RoleCard.Req_Break(InItem, InCallBack)
    -- local pBreakItem = Item.GetBreakMaterials(InItem)
    -- Dump(pBreakItem)
    -- ---当前材料是突破材料
    -- if not pBreakItem then
    --     RoleCard.IsChange = false
    --     --EventSystem.TriggerTarget(RoleCard, RoleCard.RoleBreakFailTipHandle)
    --     UI.ShowTip("tip.not_material_for_break")
    --     print("not consumes")
    --     return
    -- end
    -- ---当前突破材料至少一种
    -- if #pBreakItem < 0 then
    --     RoleCard.IsChange = false
    --     --EventSystem.TriggerTarget(RoleCard, RoleCard.RoleBreakFailTipHandle)
    --     UI.ShowTip("tip.not_material")
    --     print("not consumes")
    -- end

    -- ---当前突破材料数目足够
    -- if #pBreakItem > 0 then
    --     for i = 1, #pBreakItem do
    --         local pItem = pBreakItem[i]
    --         local nHaveBreakItem = me:GetItemCount(pItem[1], pItem[2], pItem[3], pItem[4])
    --         if nHaveBreakItem < pBreakItem[i][5] then
    --             RoleCard.IsChange = false
    --             --EventSystem.TriggerTarget(RoleCard, RoleCard.RoleBreakFailTipHandle)
    --             UI.ShowTip("tip.material_not_enough")
    --             print("not consumes")
    --         end
    --     end
    -- end

    -- local cmd = {
    --     Id = InItem:Id(),
    --     tbMaterials = pBreakItem
    -- }
    -- RoleCard.IsChange = true
    -- RoleCard.BreakCallBack = InCallBack
    -- me:CallGS("GirlCard_UpdateBreak", json.encode(cmd))
end

s2c.Register(
    "GirlCard_UpdateBreak",
    function(rsp)
        if RoleCard.BreakCallBack then
            RoleCard.BreakCallBack()
            RoleCard.BreakCallBack = nil
        end
    end
)

--- 解锁新角色
RoleCard.UnLockPlayerCallBack = nil
function RoleCard.Req_UnLockPlayer(InParam,InCallBack)
    local  cmd = {
        g = InParam.G,
        d = InParam.D,
        p = InParam.P,
        l = InParam.L,
    }
    RoleCard.UnLockPlayerCallBack = InCallBack
    me:CallGS("GirlCard_UnLockCharacter",json.encode(cmd))
end

s2c.Register(
    "GirlCard_UnLockCharacter",
    function()
        if RoleCard.UnLockPlayerCallBack then
            RoleCard.UnLockPlayerCallBack()
            RoleCard.UnLockPlayerCallBack = nil
        end
    end
)


----------------------------load date----------------
--加载角色等级数据表
function RoleCard:LoadRoleData()
    local tbConfig = LoadCsv("item/upgradeexp.txt", 1)
    for _, Data in pairs(tbConfig) do
        local tbInfo = {
            Lv = tonumber(Data.Lv) or 0,
            LvCardCoin = tonumber(Data.CardNeedCoin) or 0,
            LvCardExp = tonumber(Data.CardNeedExp) or 0,
            LvSusCoin = tonumber(Data.SusNeedCoin) or 0,
            LvSusExp = tonumber(Data.SusNeedExp) or 0,
            LvWeaCoin = tonumber(Data.WeaponNeedCoin) or 0,
            LvWeaExp = tonumber(Data.WeaponNeedExp) or 0
        }
        local Lv = tbInfo.Lv
        RoleCard.tbLvData[Lv] = RoleCard.tbLvData[Lv] or {}
        if tbInfo.Lv then
            RoleCard.tbLvData[Lv] =
                {
                Lv = tbInfo.Lv,
                LvCardCoin = tbInfo.LvCardCoin,
                LvCardExp = tbInfo.LvCardExp,
                LvSusCoin = tbInfo.LvSusCoin,
                LvSusExp = tbInfo.LvSusExp,
                LvWeaCoin = tbInfo.LvWeaCoin,
                LvWeaExp = tbInfo.LvWeaExp
            } or {}
        end
        RoleCard.tbLvData[Lv] = tbInfo
    end
end

function RoleCard:LoadSkillId()
    local tbConfig = LoadCsv("item/skill/skill.txt", 1)
    for _, tbLine in pairs(tbConfig) do
        local TitleId = tonumber(tbLine.skillID)
        if TitleId then
            RoleCard.tbShowSkills[TitleId] = {}
            for i = 1, 6 do
                RoleCard.tbShowSkills[TitleId][i] = tonumber(tbLine["nodeID" .. i]) or nil
            end
        end
    end
end

--加载角色推荐装备配置
function RoleCard:LoadRecommendData()
    RoleCard.tbRecommendData = {}
    local tbFile = LoadCsv("item/Recommend.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local tbGDPL = Eval(tbLine.GDPL);
        if tbGDPL then
            local sGDPL = table.concat(tbGDPL, "-")
            local tbInfo = {
                tbGDPL      = tbGDPL,
                Weapon1     = Eval(tbLine.Weapon1),
                Logistics1  = Eval(tbLine.Logistics1) or {},
                Weapon2     = Eval(tbLine.Weapon2),
                Logistics2  = Eval(tbLine.Logistics2) or {},
            };
            RoleCard.tbRecommendData[sGDPL] = tbInfo
        end
    end
end
---获取角色的推荐装备信息
---gdpl角色的GDPL
function RoleCard:GetRoleRecommendData(g, d, p, l)
    local key = table.concat({g, d, p, l}, "-")
    return RoleCard.tbRecommendData[key]
end

--加载角色职级配置
function RoleCard:LoadProLevelData()
    RoleCard.tbProLevelData = {}
    local tbFile = LoadCsv("item/card/prolevel.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local tbGDPL = Eval(tbLine.GDPL);
        if tbGDPL then
            local sGDPL = table.concat(tbGDPL, "-")
            local tbInfo = {
                tbGDPL      = tbGDPL,
                tbSkillID   = {},
                tbCondition = {}
            };
            for i = 0, 3 do
                tbInfo.tbSkillID[i]   = Eval(tbLine["SkillID"..i])
                tbInfo.tbCondition[i] = Eval(tbLine["Condition"..i])
            end
            RoleCard.tbProLevelData[sGDPL] = tbInfo
        end
    end
end

---获取角色职级对应的团队技能
function RoleCard.GetProLevelSkillID(Card)
    local SkillID = UE4.TArray(UE4.int32)
    if not Card then return SkillID end
    if not FunctionRouter.IsOpenById(FunctionType.ProLevel) then
        return SkillID
    end
    local ProLevel = Card:ProLevel()
    local key = table.concat({Card:Genre(), Card:Detail(), Card:Particular(), Card:Level()}, "-")
    if RoleCard.tbProLevelData[key] then
        for _, id in pairs(RoleCard.tbProLevelData[key].tbSkillID[ProLevel] or {}) do
            SkillID:Add(id)
        end
    end
    return SkillID
end

---职级提升
function RoleCard.ProLevelPromote(nID, funBack)
    if not nID then return end
    RoleCard.ProLevelPromoteBack = funBack
    UI.ShowConnection()
    me:CallGS("GirlCard_ProLevelPromote", json.encode({nID = nID}))
end
---注册职级提升的回调
s2c.Register("GirlCard_ProLevelPromote", function()
    UI.CloseConnection()
    if RoleCard.ProLevelPromoteBack then
        RoleCard.ProLevelPromoteBack()
        RoleCard.ProLevelPromoteBack = nil
    end
    EventSystem.TriggerTarget(RoleCard, RoleCard.ProLevelPromoteHandle)
end)

---设置角色大招后驻场或离场
function RoleCard.SetRoleLeave(Card, bLeave, funBack)
    if not Card or Card:HasFlag(Item.FLAG_LEAVE) == bLeave then return end
    local nID = Card:Id()
    local value = 0
    if bLeave then
        value = 1
    end
    RoleCard.SetRoleLeaveBack = funBack
    UI.ShowConnection()
    me:CallGS("GirlCard_SetRoleLeave", json.encode({tbID = {nID}, nValue = value}))
end
---设置所有角色大招后驻场或离场
---@param nValue integer 0驻场 1离场
---@param funBack function 设置后的回调 可以为nil
function RoleCard.SetAllRoleLeave(nValue, funBack)
    if not RoleCard.tbHaveCard then
        RoleCard.UpdateHaveCard()
    end
    local tbID = {}
    for _, Card in pairs(RoleCard.tbHaveCard) do
        table.insert(tbID, Card:Id())
    end
    if #tbID>0 then
        RoleCard.SetRoleLeaveBack = funBack
        me:CallGS("GirlCard_SetRoleLeave", json.encode({tbID = tbID, nValue = nValue}))
    end
end
---设置大招后驻场或离场的回调
s2c.Register("GirlCard_SetRoleLeave", function()
    UI.CloseConnection()
    if RoleCard.SetRoleLeaveBack then
        RoleCard.SetRoleLeaveBack()
        RoleCard.SetRoleLeaveBack = nil
    end
end)

--加载角色技能配置
function RoleCard:LoadSkillData()
    ---角色技能信息
    RoleCard.SkillData = {}
    local tbFile = LoadCsv("item/card/skill.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local ID = tonumber(tbLine.ID);
        if ID then
            local tbInfo = {
                nID         = ID,
                tbTagID     = Eval(tbLine.TbTagID) or {},
            };
            RoleCard.SkillData[ID] = tbInfo
        end
    end
end
--获取技能标签信息
function RoleCard.GetSkillTagID(SkillID)
    if not SkillID or not RoleCard.SkillData[SkillID] then
        return {}
    end
    return RoleCard.SkillData[SkillID].tbTagID
end
--加载技能标签配置
function RoleCard:LoadSkillTagData()
    ---角色技能标签配置
    RoleCard.SkillTagData = {}
    local tbFile = LoadCsv("item/card/skilltag.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local ID = tonumber(tbLine.ID);
        if ID then
            local tbInfo = {
                nID         = ID,
                sDes        = tbLine.Des or "tip.congif_err",
                sColor      = tbLine.Color or "FFFFFFFF",
            };
            RoleCard.SkillTagData[ID] = tbInfo
        end
    end
end

RoleCard:Init()

return RoleCard
