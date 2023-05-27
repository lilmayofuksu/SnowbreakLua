-- ========================================================
-- @File    : ItemSort.lua
-- @Brief   : 道具排序筛选的方法集
-- ========================================================
ItemSort = ItemSort or {
    SortHandle = {},
    FilterHandle = {},
    CardSortHandle = {},
    TemplateSortHandle = {},
    SupportSortHandle = {},
}

--筛选类型
ItemSort.tbFilters = 
{
    ['WeaponType'] = 1,
    ['Damage'] = 2,
    ['Team'] = 3,
    ['PartType'] = 4,
}

---常用筛选逻辑
ItemSort.ItemQuality1Filter     = {1,1}       -- 品质1筛选
ItemSort.ItemQuality2Filter     = {1,2}       -- 品质2筛选
ItemSort.ItemQuality3Filter     = {1,3}       -- 品质3筛选
ItemSort.ItemQuality4Filter     = {1,4}       -- 品质4筛选
ItemSort.ItemQuality5Filter     = {1,5}       -- 品质5筛选
ItemSort.ItemBreak1Filter       = {2,1}       -- 突破1筛选
ItemSort.ItemBreak2Filter       = {2,2}       -- 突破2筛选
ItemSort.ItemBreak3Filter       = {2,3}       -- 突破3筛选
ItemSort.ItemBreak4Filter       = {2,4}       -- 突破4筛选
ItemSort.ItemBreak5Filter       = {2,5}       -- 突破5筛选

-------Template---------------
ItemSort.TemplateDefaultSort    = {1,13,2,4}           --- Template默认排序(解锁->等级->品质)
ItemSort.TemplateIdSort         = {1,13,9}             --- Template获取顺序
ItemSort.TemplateLevelSort      = {1,13,2,4}           --- Template等级降序(解锁->等级->品质)
ItemSort.TemplateCombatSort     = {1,13,3,4,2}           --- Template战力降序
ItemSort.TemplateRareSort       = {1,13,4,2}             --- Template品质降序
ItemSort.TemplateDefenceSort    = {1,13,5,4,2}             --- Template防御降序
ItemSort.TemplateAttackSort     = {1,13,6,4,2}             --- Template攻击力排序
ItemSort.TemplateHealthSort     = {1,13,7,4,2}             --- Template生命排序
ItemSort.TemplateBreakSort      = {1,13,8,4,2}             --- Template天启排序
ItemSort.TemplateArmsSort       = {1,13,10,4,2}            --- Template武装排序
ItemSort.TemplateSpineSort      = {1,13,11,4}              --- Template神经排序



-----------Support筛选----------------
ItemSort.SupportTechnologyFilter    = {1}               -- 等级排序
ItemSort.SupportMedicalcareFilter   = {2}               -- 突破排序
ItemSort.SupportEquipFilter         = {3}               -- 品质排序
-----------Support排序----------------
ItemSort.SupportLevelSort           = {1,4,6,5,7}       -- 等级排序
ItemSort.SupportColorSort           = {4,1,6,5,7}       -- 品质排序
ItemSort.SupportExpSort           = {11,4,1,6,5,7}       -- 经验排序
ItemSort.SupportSelectLevelSort           = {1,9,4,6,5,7}       -- 选择界面等级排序
ItemSort.SupportSelectColorSort           = {4,9,1,6,5,7}       -- 选择界面品质排序
ItemSort.UpdateItemColorSort           = {4}       -- 后勤狗粮道具品质排序

ItemSort.WeaponLevelSort            = {1,4,6,5,7}       -- 等级排序
ItemSort.WeaponColorSort            = {4,1,6,5,7}       -- 品质排序
ItemSort.WeaponExpSort              = {11,1,4,6,5,7}    -- 经验排序

---仓库所用排序逻辑
ItemSort.BagItemIdSort     = {7,4,1,5,6}

ItemSort.BagWeaponQualitySort     = {4,1,5,6,7}
ItemSort.BagWeaponLevelSort     = {1,4,5,6,7}

ItemSort.BagSupportQualitySort    = {4,1,6,5,7}
ItemSort.BagSupportLevelSort    = {1,4,6,5,7}

ItemSort.BagItemQualitySort       = {9,4,10,6,7}
ItemSort.BagItemTypeSort        = {9,10,4,6,7}

ItemSort.BagWeaponPartQualitySort = {4,5,6,7}
ItemSort.BagWeaponPartTypeSort  = {6,10,4,7}

--图鉴用的排序逻辑
ItemSort.RikItemQualitySort         = {4,5,6,7}
ItemSort.RikiItemDetailSort         = {5,4,6,7}
ItemSort.RikiItemParticularSort     = {6,4,5,7}

---筛选
---@param tbArry table 筛选的对象
---@param tbFilters table 筛选条件集合
---@return table 筛选的结果
function ItemSort:Filter(tbArry, tbFilters)
    if not tbFilters or #tbFilters <= 0 then
        return Copy(tbArry); -- 过滤条件为空时不进行过滤
    end

    local tbResult = {};

    for _, tbPair in ipairs(tbFilters) do
        if #tbArry <= 0 then break end;

        local handle = self.FilterHandle[tbPair[1]];
        local nParam = tbPair[2] or 0;
        for _, it in ipairs(tbArry) do
            local ret = handle(it)
            if type(ret) == 'number' then
                if nParam == 0 or ret == nParam then
                    table.insert(tbResult, it)
                end
            elseif type(ret) == 'table' then
                for _, value in ipairs(ret) do
                    if nParam == 0 or value == nParam then
                        table.insert(tbResult, it)
                        break
                    end
                end
            end
        end
    end

    return tbResult
end

---排序
---@param tbArry table 排序的对象
---@param tbSorts table 排序条件集合
---@return table 排序的结果
function ItemSort:Sort(tbArry, tbSorts)
    local tbResult = Copy(tbArry);
    local function handle(l, r)
        local len = #tbSorts
        for i, key in ipairs(tbSorts) do
            if self.SortHandle[key] then
                local nDiff = self.SortHandle[key](l, r);
                if nDiff > 0 then return true end;
                if nDiff < 0 or i == len then return false end;
            end
        end
    end
    table.sort(tbResult, handle)
    return tbResult;
end

---逆序
---@param tbArry table 排序的对象
function ItemSort:Reverse(tbArry)
    if #tbArry > 1 then
        local nLeft = 1
        local nRight = #tbArry
        while (nLeft < nRight) do
            tbArry[nLeft], tbArry[nRight] = tbArry[nRight], tbArry[nLeft]
            nLeft = nLeft + 1
            nRight = nRight - 1
        end
    end
end

---------------------------------- 排序方法 ---------------------------------------

---道具等级降序
ItemSort.SortHandle[1] = function(l, r)
    return l:EnhanceLevel() - r:EnhanceLevel();
end

---道具品质降序
ItemSort.SortHandle[2] = function(l, r)
    return l:Quality() - r:Quality();
end

---道具突破降序
ItemSort.SortHandle[3] = function(l,r)
    return l:Break() - r:Break();
end

---道具稀有度降序
ItemSort.SortHandle[4] = function(l,r)
    return l:Color() - r:Color();
end

---根据道具GDPL中的Detail排序，Detail越小越靠前
ItemSort.SortHandle[5] = function(l, r)
    return r:Detail() - l:Detail()
end

---根据道具GDPL中的Particular排序，Particular越大越靠前
ItemSort.SortHandle[6] = function(l, r)
    return l:Particular() - r:Particular()
end

---根据道具的唯一ID排序，ID越大越靠前
ItemSort.SortHandle[7] = function(l, r)
    return l:Id() - r:Id()
end

---根据道具GDPL中的Genre排序，Genre越大越靠前
ItemSort.SortHandle[8] = function(l, r)
    return l:Genre() - r:Genre()
end

--根据道具时限升序排序 
ItemSort.SortHandle[9] = function(l, r)
    local n1 = l:Expiration()
    local n2 = r:Expiration()
    if n1 == 0 or n2 == 0 then
        return n1 - n2
    end

    return n2 - n1
end

---根据道具GDPL中的Detail排序，Detail越大越靠前
ItemSort.SortHandle[10] = function(l, r)
    return l:Detail() - r:Detail()
end

---根据武器强化提供经验值排序
ItemSort.SortHandle[11] = function (l, r)
    if not (l:IsWeapon() and r:IsWeapon()) then
        return 0
    end

    local lExp = l:ProvideExp() + Item.GetExpAndSilverNum(l)
    local rExp = r:ProvideExp() + Item.GetExpAndSilverNum(r)
    return lExp - rExp
end

---------------------------------- 筛选方法 ---------------------------------------

---道具的品质
ItemSort.FilterHandle[1] = function(it) 
    return it:Quality();
end

---道具的突破等级
ItemSort.FilterHandle[2] = function(it) 
    return it:Break();
end

---道具的进化次数
ItemSort.FilterHandle[3] = function(it)
    return it:Evolue();
end

---道具的Detail
ItemSort.FilterHandle[4] = function(it)
    return it:Detail();
end

---武器的伤害类型
ItemSort.FilterHandle[5] = function(it)
    if not it:IsWeapon() or not Weapon.GetWeaponGrowConfig(it) then
        return 0
    end
    return Weapon.GetWeaponGrowConfig(it).nDamageType
end

---后勤卡的小队
ItemSort.FilterHandle[6] = function(it)
    if not it:IsSupportCard() then
        return 0
    end
    local pTemplate = UE4.UItem.FindTemplateForID(it:TemplateId())
    local SkillList2 = UE4.USupporterCard.FindSuitSkillTemplate(pTemplate.SuitSkill).TwoSkillID:ToTable()
    return SkillList2[1]
end

---配件适配的武器类型
ItemSort.FilterHandle[7] = function(it)
    if not it:IsWeaponParts() then
        return {0}
    end
    return WeaponPart.GetPartWeaponType(it)
end

--- 不可使用道具的 Classify
ItemSort.FilterHandle[8] = function(it)
    if not it:IsSupplies() then
        return 0
    end
    local template = UE4.UItem.FindTemplateForID(it:TemplateId())
    return template.Classify;
end

--- 角色卡的武器类型
ItemSort.FilterHandle[9] = function(it)
    if not it:IsCharacterCard() then
        return 0
    end
    local Weapon = it:GetSlotWeapon()
    return Weapon:Detail()
end
--- 角色Template的武器类型
ItemSort.FilterHandle[10] = function(it)
    if not it.DefaultWeaponGPDL then
        return 0
    end
    return it.DefaultWeaponGPDL.Detail
end

--- 宿舍礼物Template的D类型
ItemSort.FilterHandle[11] = function(it)
    if not it or it.Type ~= UE4.EItemType.HouseGift then
        return 0
    end
    return it:Detail()
end

---------------------------------Template-----------------------------------------
--- TemplateSort
function ItemSort:TemplateSort(tbTemplate, tbHandle)
    local tbResult = Copy(tbTemplate)
    local function handle(l, r)
        for _, key in ipairs(tbHandle) do
            if self.TemplateSortHandle[key] then
                local nDiff = self.TemplateSortHandle[key](l, r)
                if nDiff > 0 then return true end
                if nDiff < 0 then return false end
            end
        end
    end
    table.sort(tbResult,handle)
    return tbResult
end
--- CardSort
function ItemSort:CardSort(tbCard, tbHandle)
    local tbResult = Copy(tbCard)
    local function handle(l, r)
        for _, key in ipairs(tbHandle) do
            if self.CardSortHandle[key] then
                local nDiff = self.CardSortHandle[key](l, r)
                if nDiff > 0 then return true end
                if nDiff < 0 then return false end
            end
        end
    end
    table.sort(tbResult,handle)
    return tbResult
end

----------------------------------Template排序方法----------------------------------
--- 默认排序(是否解锁)
ItemSort.TemplateSortHandle[1] = function(a,b)
    local nA = 0
    local nB = 0
    if RoleCard.GetItem({a.Genre,a.Detail,a.Particular,a.Level}) then nA = 1 end
    if RoleCard.GetItem({b.Genre,b.Detail,b.Particular,b.Level}) then nB = 1 end
    return nA - nB
end

--- 等级排序
ItemSort.TemplateSortHandle[2] =  function(a, b)
    local function nLevel(InItem)
        if InItem.Type and InItem.Type > 0 then
            return InItem:EnhanceLevel()
        else
            local pItem = RoleCard.GetItem({InItem.Genre,InItem.Detail,InItem.Particular,InItem.Level})
            if pItem then
                return pItem:EnhanceLevel()
            else
               return InItem.Level
            end
        end
    end
    return nLevel(a) - nLevel(b)
end

--- 战力排序
ItemSort.TemplateSortHandle[3] = function(a,b)
    local  a_power = 0
    local  b_power = 0
    local aItem = RoleCard.GetItem({a.Genre,a.Detail,a.Particular,a.Level})
    local bItem = RoleCard.GetItem({b.Genre,b.Detail,b.Particular,b.Level})
    if aItem then
        a_power = Item.Zhanli_CardTotal(aItem)
    end
    if bItem then
        b_power = Item.Zhanli_CardTotal(bItem)
    end
    return a_power - b_power
end

--- 品质排序
ItemSort.TemplateSortHandle[4] = function(a,b)
    local nColor = function(InItem)
        if InItem.Type and InItem.Type >0 then
            return InItem:Color()
        else
            return InItem.Color
        end
        return 0
    end
    return nColor(a) - nColor(b)
end

--- 防御力排序
ItemSort.TemplateSortHandle[5] = function(a,b)
    local nDefenceA = a.Defence or 0
    local nDefenceB = b.Defence or 0
    local pItemA = RoleCard.GetItem({a.Genre,a.Detail,a.Particular,a.Level})
    local pItemB = RoleCard.GetItem({b.Genre,b.Detail,b.Particular,b.Level})
    if pItemA then nDefenceA = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Defence",pItemA) end
    if pItemB then nDefenceB = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Defence",pItemB) end
    return nDefenceA - nDefenceB
end

--- 攻击力排序
ItemSort.TemplateSortHandle[6] = function(a,b)
    local nAttackA = a.Attack or 0
    local nAttackB = b.Attack or 0
    local pItemA = RoleCard.GetItem({a.Genre,a.Detail,a.Particular,a.Level})
    local pItemB = RoleCard.GetItem({b.Genre,b.Detail,b.Particular,b.Level})
    if pItemA then nAttackA = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Attack",pItemA) end
    if pItemB then nAttackB = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Attack",pItemB) end
    return nAttackA - nAttackB
end

--- 生命上限排序
ItemSort.TemplateSortHandle[7] = function(a,b)
    local nHealthA = a.Health or 0
    local nHealthB = b.Health or 0
    local pItemA = RoleCard.GetItem({a.Genre,a.Detail,a.Particular,a.Level})
    local pItemB = RoleCard.GetItem({b.Genre,b.Detail,b.Particular,b.Level})
    if pItemA then nHealthA = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Health",pItemA) end
    if pItemB then nHealthB = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Health",pItemB) end
    return nHealthA - nHealthB
end

--- 天启阶段排序
ItemSort.TemplateSortHandle[8] = function(a,b)
    local nBreakA = a.Break or 0
    local nBreakB = b.Break or 0
    local pItemA = RoleCard.GetItem({a.Genre,a.Detail,a.Particular,a.Level})
    local pItemB = RoleCard.GetItem({b.Genre,b.Detail,b.Particular,b.Level})
    if pItemA then nBreakA = pItemA:Break() end
    if pItemB then nBreakB = pItemB:Break() end
    return nBreakA - nBreakB
end

ItemSort.TemplateSortHandle[9] = function(a,b)
    local nIdA = a.Id or 0
    local nIdB = b.Id or 0
    local pItemA = RoleCard.GetItem({a.Genre,a.Detail,a.Particular,a.Level})
    local pItemB = RoleCard.GetItem({b.Genre,b.Detail,b.Particular,b.Level})
    if pItemA then nIdA = pItemA:Id() end
    if pItemB then nIdB = pItemB:Id () end
    return nIdA - nIdB
    -- body
end

--- 武装排序
ItemSort.TemplateSortHandle[10] = function(a,b)
    local nArmsA = a.Arms or 0
    local nArmsB = b.Arms or 0
    local pItemA = RoleCard.GetItem({a.Genre,a.Detail,a.Particular,a.Level})
    local pItemB = RoleCard.GetItem({b.Genre,b.Detail,b.Particular,b.Level})
    if pItemA then nArmsA = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Arms",pItemA) end
    if pItemB then nArmsB = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Arms",pItemB) end
    return nArmsA - nArmsB
end

-- 神经枢组排序
ItemSort.TemplateSortHandle[11] = function(a,b)
    local  a_MaxSpine = 0
    local  b_MaxSpine = 0
    local aItem = RoleCard.GetItem({a.Genre,a.Detail,a.Particular,a.Level})
    local bItem = RoleCard.GetItem({b.Genre,b.Detail,b.Particular,b.Level})
    if aItem then
        a_MaxSpine = aItem:GetMaxSpine()
    end
    if bItem then
        b_MaxSpine = bItem:GetMaxSpine()
    end
    return a_MaxSpine - b_MaxSpine
end

-- 信赖度排序
ItemSort.TemplateSortHandle[12] = function (a, b)
    local  a_Love = HouseGirlLove:GetGirlLove(a.Detail)
    local  b_Love = HouseGirlLove:GetGirlLove(b.Detail)
    return a_Love - b_Love
end

-- 是否能解锁排序
ItemSort.TemplateSortHandle[13] = function (a, b)
    local function bEnough(Template)
        if not RoleCard.GetItem({Template.Genre,Template.Detail,Template.Particular,Template.Level}) then
            local gdplArr = Template.PiecesGDPLN
            if gdplArr:Length() >= 5 then
                return me:GetItemCount(gdplArr:Get(1), gdplArr:Get(2), gdplArr:Get(3), gdplArr:Get(4)) >= gdplArr:Get(5)
            end
        end
        return false
    end

    local nA = 0
    local nB = 0
    if bEnough(a) then nA = 1 end
    if bEnough(b) then nB = 1 end
    return nA - nB
end

----------------------------------Card排序方法----------------------------------
--- 默认排序-试玩在前面
ItemSort.CardSortHandle[1] = function(a,b)
    local nA = 0
    local nB = 0
    if a:IsTrial() then nA = 1 end
    if b:IsTrial() then nB = 1 end
    return nA - nB
end

--- 等级排序
ItemSort.CardSortHandle[2] =  function(a,b)
    return a:EnhanceLevel() - b:EnhanceLevel()
end

--- 战力排序
ItemSort.CardSortHandle[3] = function(a, b)
    local  a_power = Item.Zhanli_CardTotal(a)
    local  b_power = Item.Zhanli_CardTotal(b)
    return a_power - b_power
end

--- 品质排序
ItemSort.CardSortHandle[4] = function(a,b)
    return a:Color() - b:Color()
end

--- 防御力排序
ItemSort.CardSortHandle[5] = function(a,b)
    local nDefenceA = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Defence", a)
    local nDefenceB = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Defence", b)
    return nDefenceA - nDefenceB
end

--- 攻击力排序
ItemSort.CardSortHandle[6] = function(a,b)
    local nAttackA = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Attack", a)
    local nAttackB = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Attack", b)
    return nAttackA - nAttackB
end

--- 生命上限排序
ItemSort.CardSortHandle[7] = function(a,b)
    local nHealthA = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Health", a)
    local nHealthB = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Health", b)
    return nHealthA - nHealthB
end

--- 天启阶段排序
ItemSort.CardSortHandle[8] = function(a,b)
    return a:Break() - b:Break()
end

ItemSort.CardSortHandle[9] = function(a,b)
    return a:Id() - b:Id()
end

--- 武装排序
ItemSort.CardSortHandle[10] = function(a,b)
    local nArmsA = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Arms", a)
    local nArmsB = UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_Arms", b)
    return nArmsA - nArmsB
end

-- 神经枢组排序
ItemSort.CardSortHandle[11] = function(a,b)
    return a:GetMaxSpine() - b:GetMaxSpine()
end

-- 信赖度排序
ItemSort.CardSortHandle[12] = function (a, b)
    return HouseGirlLove:GetGirlLove(a:Detail()) - HouseGirlLove:GetGirlLove(b:Detail())
end

---------------------------------------------------------------------
------------------------------Support排序-----------------------------
---排序
---@param tbArry table 排序的对象
---@param tbSorts table 排序条件集合
---@return table 排序的结果
function ItemSort:SelectItemSort(tbArry, tbSorts)
    local tbResult = Copy(tbArry);
    local function handle(l, r)
        local len = #tbSorts
        for i, key in ipairs(tbSorts) do
            local nDiff = self.SortHandle[key](l.pItem, r.pItem);
            if nDiff > 0 then return true end;
            if nDiff < 0 or i == len then return false end;
        end
    end
    table.sort(tbResult, handle)
    return tbResult;
end

---排序
---@param tbTemplate table 排序的对象
---@param tbHandle table 排序条件集合
---@param Param table 排序额外参数
---@return table 排序的结果
function ItemSort:SupportSort(tbTemplate, tbHandle, Param)
    local tbResult = Copy(tbTemplate)
    local function handle(l, r)
        for i, key in ipairs(tbHandle) do
            local nDiff = self.SupportSortHandle[key](l, r, Param)
            if nDiff > 0 then return true end
            if nDiff < 0 then return false end
        end
    end
    table.sort(tbResult,handle)
    return tbResult
end

---道具等级降序
ItemSort.SupportSortHandle[1] = function(l, r)
    return l:EnhanceLevel() - r:EnhanceLevel();
end

---道具品质降序
ItemSort.SupportSortHandle[2] = function(l, r)
    return l:Quality() - r:Quality();
end

---道具突破降序
ItemSort.SupportSortHandle[3] = function(l,r)
    return l:Break() - r:Break();
end

---道具稀有度降序
ItemSort.SupportSortHandle[4] = function(l,r)
    return l:Color() - r:Color();
end

---根据道具GDPL中的Detail排序,Detail越小越靠前
ItemSort.SupportSortHandle[5] = function(l, r)
    return r:Detail() - l:Detail()
end

---根据道具GDPL中的Particular排序,Particular越大越靠前
ItemSort.SupportSortHandle[6] = function(l, r)
    return l:Particular() - r:Particular()
end

---根据道具的唯一ID排序,ID越大越靠前
ItemSort.SupportSortHandle[7] = function(l, r)
    return l:Id() - r:Id()
end

---根据道具GDPL中的Genre排序,Genre越大越靠前
ItemSort.SupportSortHandle[8] = function(l, r)
    return l:Genre() - r:Genre()
end

---根据后勤卡套装排序,有成套的靠前
---@param tbSuit table 当前装备的后勤套装
ItemSort.SupportSortHandle[9] = function(l, r, tbSuit)
    local lCount = 0
    local rCount = 0
    local lSuit =  Logistics.GetSkillSuitId(l)
    local rSuit = Logistics.GetSkillSuitId(r)
    for i = 1, 3 do
        local SkillTemplateId = tbSuit[i]
        if SkillTemplateId and lSuit and SkillTemplateId == lSuit then
            lCount = lCount + 1
        end
        if SkillTemplateId and rSuit and SkillTemplateId == rSuit then
            rCount = rCount + 1
        end
    end

    return lCount - rCount
end

--- 根据后勤卡强化提供经验排序 经验值大的靠前
ItemSort.SupportColorSort[10] = function (l, r)
    if not (l:IsSupportCard() and r:IsSupportCard()) then
        return 0
    end

    local lExp = l:ProvideExp() + Item.GetExpAndSilverNum(l)
    local rExp = r:ProvideExp() + Item.GetExpAndSilverNum(r)
    return lExp - rExp
end
