-- ========================================================
-- @File    : Weapon.lua
-- @Brief   : 武器
-- ========================================================

---@class Weapon 武器逻辑管理
---@field tbGrow table 武器成长配置
---@field tbBreakCondition table 武器突破配置
---@field tbEvolutionMaterials table 武器进化配置
---@field tbWeaponConfig table 武器配置信息
---@field tbDisplayConfig table 武器配件镜头参数
---@field tbAbilityConfig table 武器配件属性配置
Weapon = Weapon or { tbGrow = {}, tbBreakCondition = {}, tbEvolutionMaterials = {} , tbWeaponConfig = {}, tbDisplayConfig = {}, tbAbilityConfig = {}, tbCacheArgs = {}}

Weapon.tbQualityIcon = {1700041, 1700042, 1700043, 1700044, 1700045, 1700046}
--3动能,4高热,5低温,6电击,7特异
Weapon.tbRestraintIcon = {0, 0, 1400201, 1400203, 1400204, 1400205, 1400202}
--3动能,4高热,5低温,6电击,7特异
Weapon.tbRestraintName = {"", "", "ui.TxtDamageType.3", "ui.TxtDamageType.4", "ui.TxtDamageType.5", "ui.TxtDamageType.6", "ui.TxtDamageType.7"}

--- 材质颜色
Weapon.WeaponColor = {
    1700115,        -- 白
    1700115,        -- 绿
    1700116,        -- 蓝
    1700117,        -- 紫
    1700118,        -- 橙
    1700118,        -- 橙
}

---武器满级配件解锁存储ID
Weapon.PART_LOCK_GID = 2
Weapon.PART_LOCK_SID = 1

---武器显示的部件
Weapon.tbShowPart = {UE4.EWeaponSlotType.Muzzle, UE4.EWeaponSlotType.TopGuide, UE4.EWeaponSlotType.Ammunition, UE4.EWeaponSlotType.LowerGuide}

---显示的属性
Weapon.tbShowAttr = {
    UE4.EWeaponAttributeType.Attack,
    UE4.EWeaponAttributeType.FireSpeed,
    UE4.EWeaponAttributeType.BulletNum,
    UE4.EWeaponAttributeType.DamageCoefficient,
    UE4.EWeaponAttributeType.ReloadSpeed,
    UE4.EWeaponAttributeType.CriticalDamage,
}

--[[

    武器预览模型处理
]]

local CacheModel = {}

function Weapon.GetPreviewModel()
    return CacheModel.pModel
end

function Weapon.ResetRotate()
    if CacheModel.pModel then
        CacheModel.pModel:SetStage(UE4.EPreviewWeaponStage.Reset)
    end
end

function Weapon.ResetRotate2()
    if CacheModel.pModel then
        CacheModel.pModel:SetStage(UE4.EPreviewWeaponStage.Rotate)
    end
end


---更新配件
---@param pWeapon UWeaponItem 武器
---@param nType EWeaponSlotType 配件类型
---@param nTemplateID Integer 模板ID
function Weapon.UpdatePart(pWeapon, nType, nTemplateID)
    if not CacheModel.pModel or not pWeapon then return end

    if Weapon.IsShowDefaultPart(pWeapon) then return end

    local pModel = CacheModel.pModel:GetPreviewActor()
    if pModel and pModel:GetModel() then
        pModel:GetModel():UpdateWeaponPart(nType, nTemplateID)
    end
end

local tbPartPostValue = {0, 0, 253, 254, 255}

local nAlphaTimer = nil

function Weapon.PlayPartEffect(pWeapon, nType, nColor)
    local pModel = CacheModel.pModel 
    if not IsValid(pModel) then return end
    local pPartActor = pModel:GetPartActor(nType)
    if not pPartActor then return end
    local tbOpen = Weapon.GetOpenPartSlot(pWeapon) or {}
    for _, nType in ipairs(tbOpen) do
        local pa = pModel:GetPartActor(nType) 
        if pa then
            local pComp = pa:K2_GetMeshComponent()
            if pComp then
                pComp:SetRenderCustomDepth(false)
            end
        end
    end

    local pPartComp = pPartActor:K2_GetMeshComponent()
    if not pPartComp then return end

    pPartComp:SetRenderCustomDepth(true)
    local partItem = pWeapon:GetWeaponSlot(nType)
    local nColor = nColor or (partItem and partItem:Color() or 3)
    pPartComp:SetCustomDepthStencilValue(tbPartPostValue[nColor] or 253)
    pModel:Start()
    local actorArray = UE4.TArray(UE4.AActor)
    actorArray:Add(pPartActor)

    if nAlphaTimer then
        UE4.Timer.Cancel(nAlphaTimer)
        nAlphaTimer = nil
    end

    pModel:StartAlpha(actorArray, tbPartPostValue[nColor] or 253)
    nAlphaTimer = UE4.Timer.Add(pModel.ShowTime, function()
        if pModel then
            pModel:EndAlpha()
        end
    end)
end

function Weapon.CloseRenderCustomDepth(pWeapon)
    local pActor = CacheModel.pModel 
    if not pActor then return end

    local tbOpen = Weapon.GetOpenPartSlot(pWeapon) or {}
    for _, nType in ipairs(tbOpen) do
        local pPartActor = pActor:GetPartActor(nType)
        local partItem = pWeapon:GetWeaponSlot(nType)
        if pPartActor and partItem then
            local pPartComp = pPartActor:K2_GetMeshComponent();
            if pPartComp then
                pPartComp:SetRenderCustomDepth(false)
            end
        end
    end
end


---武器界面预览处理
function Weapon.PreviewShow(pWeapon)
    Preview.Destroy(true)
    if not pWeapon then return end
    if CacheModel.pModel then
        CacheModel.pModel:SetActorHiddenInGame(false)

        if IsValid(CacheModel.pWeaponLight) then
            CacheModel.pWeaponLight:SetActorHiddenInGame(false)
        end
        return 
    end
    local pos = UE4.FVector(0, 0, 10)
    local pActor = UE4.APreviewWeapon.SpawnPreviewWeapon(GetGameIns(), pWeapon, pos)
    if not pActor then return end
    
    CacheModel.pModel = pActor
    pActor.OnWeaponPartRotateFinish:Clear()
    pActor.OnWeaponPartRotateFinish:Add(GetGameIns(), function()
       
    end)

    local ActorClass = UE4.UClass.Load("/Game/Blueprints/Weapons/BP_wpbase/Bp_wplight_preview.Bp_wplight_preview_C")
    local pLightActor = GetGameIns():GetWorld():SpawnActor(ActorClass)
    pLightActor:K2_SetActorLocation(pActor:K2_GetActorLocation())
    CacheModel.pWeaponLight = pLightActor
end

---关闭武器界面预览
function Weapon.PreviewClose(bDestroy)
    if nAlphaTimer then
        UE4.Timer.Cancel(nAlphaTimer)
        nAlphaTimer = nil
    end
    if bDestroy then
        if CacheModel.pModel then
            CacheModel.pModel:K2_DestroyActor()
            CacheModel.pModel.OnWeaponPartRotateFinish:Clear()
            CacheModel.pModel = nil
        end
    
        if IsValid(CacheModel.pWeaponLight) then
            CacheModel.pWeaponLight:K2_DestroyActor()
            CacheModel.pWeaponLight = nil
        end
    else
        if CacheModel.pModel then
            CacheModel.pModel:SetActorHiddenInGame(true)
        end
    
        if IsValid(CacheModel.pWeaponLight) then
            CacheModel.pWeaponLight:SetActorHiddenInGame(true)
        end
    end
end

---@deprecated
function Weapon.AttachToSequenceActor(pSequenceActor)
end


--[[
    武器显示默认配件保存获取逻辑
]]

---获取保存信息
function Weapon.GetSavePartInfo(pWeapon)
    if not me or not pWeapon then return end
    return json.decode(me:GetStrAttribute(PlayerSetting.SGID, PlayerSetting.SSID_WEAPON_PART)) or {}
end

---是否显示默认配件
function Weapon.IsShowDefaultPart(pWeapon)
    local tbInfo = Weapon.GetSavePartInfo(pWeapon)
    if not tbInfo then return false end
    return tbInfo[pWeapon:Id()] == 1
end

---设置
function Weapon.SetShowDefaultPart(pWeapon, bDefault)
    local tbInfo = Weapon.GetSavePartInfo(pWeapon)
    if not tbInfo then return end

    local nId = pWeapon:Id()

    local bOldShow = (tbInfo[nId] == 1)
    
    if bOldShow == bDefault then
        return
    end

    tbInfo[nId] = (bDefault and 1 or 0)
    me:SetStrAttribute(PlayerSetting.SGID, PlayerSetting.SSID_WEAPON_PART, json.encode(tbInfo))

    if CacheModel and CacheModel.pModel then
        local pModel = CacheModel.pModel:GetPreviewActor()
        if pModel and pModel:GetModel() then
            pModel:GetModel():UpdateWeaponAllPart(pWeapon, bDefault)
        end
    end
end


--[[
    ***************************************
    武器红点
    ***************************************
]]

---是否查看过
function Weapon.IsRead(pWeapon)
    if not pWeapon then return false end
    return pWeapon:HasFlag(Item.FLAG_READED) == true
end

---角色卡装备武器红点
function Weapon.CheckRedPointByCard(pCard, pWeapon)
    if not pCard then return false end
    local weapon = pWeapon or pCard:GetSlotWeapon()
    if not weapon then return false end

    if Weapon.CheckPartCanEquip(weapon) then
        return true
    end
    return false
end

---是否有新的配件
function Weapon.CheckPartCanEquip(pWeapon)
   ---武器配件解锁判断
   local bUnlock, _ =  FunctionRouter.IsOpenById(FunctionType.WeaponPart)
   if not bUnlock then return false end

    local tbOpen = Weapon.GetOpenPartSlot(pWeapon) or {}
    for _, nSlot in ipairs(tbOpen) do
       if Weapon.CheckSlotRed(pWeapon, nSlot) then
            return true
       end
    end
    return false
end

---武器是否可以装配此配件
function Weapon.CanEquipPart(pWeapon, pPart)
    if not pWeapon or not pPart then return false end
    local partCfg = WeaponPart.GetPartConfig(pPart)
    if not partCfg then return false end
    return Weapon.CanEquipPartByCfg(pWeapon, partCfg)
end

function Weapon.CanEquipPartByCfg(pWeapon, partCfg)
    if not pWeapon or not partCfg then return false end
    local weaponCfg = Weapon.GetWeaponConfig(pWeapon)
    if not weaponCfg then return false end

    local bCanAdd = false
    for _, d in ipairs(partCfg.tbWeaponAllow or {}) do
        if d == pWeapon:Detail() then
            bCanAdd = true
            break
        end
    end
    if bCanAdd == false then
        return false
    end

    for _, c in ipairs(partCfg.tbClassAllow or {}) do
        if c == weaponCfg.nClass then
            return true
        end
    end

    return false
end


---插槽是否可以装备
function Weapon.CheckSlotRed(pWeapon, nSlot)
    --已经装备了
    local pEquipPart = pWeapon:GetWeaponSlot(nSlot)
    if pEquipPart then return false end

    ---有没有可以装备的
    local allPart = UE4.TArray(UE4.UWeaponParts)
    me:GetWeaponPartsItemsForIndex(nSlot, allPart, false)
    for i = 1, allPart:Length() do
        if Weapon.CanEquipPart(pWeapon, allPart:Get(i)) then
            return true
        end
    end
    return false
end

---标记查看了武器
---@param pWeapon UWeaponItem
function Weapon.Read(pWeapon)
    if not pWeapon:HasFlag(Item.FLAG_READED) then
        Item.Read({pWeapon:Id()})
    end
end

---*********************************************************************
---*********************************************************************

---获取最大等级解锁的配件
---@param pWeapon UWeaponItem
function Weapon.GetMaxLvPart(pWeapon)
    local tbCfg = Weapon.GetWeaponConfig(pWeapon)
    if not tbCfg then return nil end
    return tbCfg.WeaponPartsAward
end

---获取开放的配件槽位
---@param pWeapon UWeaponItem
---@return table
function Weapon.GetOpenPartSlot(pWeapon)
    local tbRet = {}
    local tbLimit = Weapon.GetWeaponPartsLimit(pWeapon) or {0, 0, 0, 0, 0}
    for nIdx, nType in ipairs(Weapon.tbShowPart) do if tbLimit[nType] == 1 then table.insert(tbRet, nType) end  end
    return tbRet
end

---显示的属性
local tbSubAttrType = {'CriticalValue', 'HealthPer_break', 'AttackPer_break',
                        'ArmsPer_break', 'DefencePer_break', 'Command_break',
                        'CharacterEnergyEfficiency_break', 'CriticalDamageAddtion_break',
                        'SkillIntensity_break', 'SkillCDQuick_break', 'NormalEnergySpeed_break', 'SkillMastery_break'}

local GetGrowValue = function(pWeapon, sType, nLevel,  nDefault)
    nDefault = nDefault or 0
    local tbGrow = Weapon.GetWeaponGrowConfig(pWeapon)
    if not tbGrow then return nDefault end

    local str = tbGrow.tbAttrStr[sType]
    if not str then return nDefault end

    local value = UE4.UAbilityLibrary.GetFloatValueStringForLevel(str, nLevel)
    local a, b = math.modf(value)
    if b <= 0 then
        return a
    end
    return tonumber(string.format("%.2f", value))
end

---获取副属性
---@param pWeapon UWeaponItem
function Weapon.GetSubAttr(pWeapon, nLevel, nBreakLv)
    local nBreakLv = nBreakLv or pWeapon:Quality()
    for _, sType in ipairs(tbSubAttrType) do
        local nTempValue =  GetGrowValue(pWeapon, sType, nBreakLv, 0)
        if nTempValue > 0 then
            if sType ~= 'SkillCDQuick_break' and sType ~= 'SkillMastery_break' then
                nTempValue = nTempValue .. '%'
            end
            return nTempValue, sType
        end
    end
    return 0, 'CriticalValue'
end

---获取 武器对应的卡
function Weapon.GetWeapon2Card()
    local tbW2C = {}
    local cards = me:GetCharacterCards()
    for i = 1, cards:Length() do
        local pCard = cards:Get(i)
        local pWeapon = pCard:GetSlotWeapon()
        tbW2C[pWeapon] = pCard
    end
    return tbW2C
end

---输出武器信息
---@param pWeapon UWeaponItem
function Weapon.Print(pWeapon)
    local str = string.format('gdpl=%s', pWeapon:Genre() .. pWeapon:Detail() .. pWeapon:Particular() .. pWeapon:Level())
    print(str)
end

---显示配件信息
---@param pWeapon UWeaponItem
---@param pWidget UUserWidget
function Weapon.ShowPartInfo(pWeapon, pWidget)
    local tbLimit = Weapon.GetWeaponPartsLimit(pWeapon) or {0, 0, 0, 0, 0}
    if pWidget["Active1"] then
        for nIdx = 1, 5 do
            if pWidget["arms_s" .. nIdx] then
                local nType =  Weapon.tbShowPart[nIdx]
                if not nType or tbLimit[nType] == 0 then
                    WidgetUtils.Collapsed(pWidget["arms_s" .. nIdx])
                else
                    WidgetUtils.SelfHitTestInvisible(pWidget["arms_s" .. nIdx])
                    if pWeapon:GetSlotItem(nType) then
                        WidgetUtils.SelfHitTestInvisible(pWidget["Active" .. nIdx])
                    else
                        WidgetUtils.Collapsed(pWidget["Active" .. nIdx])
                    end
                end
            end
        end
    else
        for nIdx, nType in ipairs(Weapon.tbShowPart) do
            if tbLimit[nType] == 0 then
                WidgetUtils.Collapsed(pWidget["arms_s" .. nIdx])
                WidgetUtils.Collapsed(pWidget["arms_s" .. nIdx .. "_1"])
            else
                if pWeapon:GetSlotItem(nType) then
                    WidgetUtils.SelfHitTestInvisible(pWidget["arms_s" .. nIdx])
                    WidgetUtils.Collapsed(pWidget["arms_s" .. nIdx .. "_1"])
                else
                    WidgetUtils.Collapsed(pWidget["arms_s" .. nIdx])
                    WidgetUtils.SelfHitTestInvisible(pWidget["arms_s" .. nIdx .. "_1"])
                end
            end
        end
    end
end

---显示配件信息
---@param table tbGDPL g,d,p,l
---@param pWidget UUserWidget
function Weapon.ShowPartInfoByGDPL(tbGDPL, pWidget, tbPart)
    local sGDPL = table.concat(tbGDPL, "-")
    if not Weapon.tbWeaponConfig[sGDPL] then return end
    local tbLimit = Weapon.tbWeaponConfig[sGDPL].WeaponPartsLimit or {0, 0, 0, 0, 0}

    for nIdx, nType in ipairs(Weapon.tbShowPart) do
        if tbLimit[nType] == 0 then
            WidgetUtils.Collapsed(pWidget["arms_s" .. nIdx])
            WidgetUtils.Collapsed(pWidget["arms_s" .. nIdx .. "_1"])
        else
            if tbPart and tbPart[nType] and tbPart[nType] == 1 then
                WidgetUtils.SelfHitTestInvisible(pWidget["arms_s" .. nIdx])
                WidgetUtils.Collapsed(pWidget["arms_s" .. nIdx .. "_1"])
            else
                WidgetUtils.Collapsed(pWidget["arms_s" .. nIdx])
                WidgetUtils.SelfHitTestInvisible(pWidget["arms_s" .. nIdx .. "_1"])
            end
        end
    end
end

---获取武器伤害对应距离
---@param pWeapon UWeaponItem
function Weapon.GetDamageDisValue(pWeapon)
    local tbGrow = Weapon.GetWeaponGrowConfig(pWeapon)
    if not tbGrow then return 0, 0 end
    return tbGrow.nFiringRangeStartAttenuation or 3000, tbGrow.nFiringRangeUltimateLimit or 4000
end


---百分比数值
local PercentType = {
    UE4.EWeaponAttributeType.WeaknessDamage,
    UE4.EWeaponAttributeType.DamageCoefficient,
    UE4.EWeaponAttributeType.CriticalDamage,
}

---描述转换
function Weapon.ConvertDes(eType, sDes)
    if eType == UE4.EWeaponAttributeType.FiringRangeUltimateLimit then
        local nDis = tonumber(sDes) or 1000
        sDes = TackleDecimal(nDis / 100) .. Text('ui.TxtDisUnit')
    end

    for _, type in ipairs(PercentType) do
        if eType == type then
            return sDes .. '%'
        end
    end
    return sDes
end


---获取武器类型图标
---@param pWeapon UWeaponItem
function Weapon.GetTypeIcon(pWeapon)
    return Item.WeaponTypeIcon[pWeapon:Detail()]
end

---获取武器类型名称
---@param pWeapon UWeaponItem
function Weapon.GetTypeName(pWeapon)
    local d = pWeapon:Detail()
    return Text('weapon.type_' .. d)
end

---获取品质条
---@param nQuality Integer 品质
function Weapon.GetQualityIcon(nQuality)
    return Weapon.tbQualityIcon[nQuality]
end


---获取武器配件限制配置
---@param InWeapon UWeaponItem
---@return table
function Weapon.GetWeaponPartsLimit(InWeapon)
    local tbConfig = Weapon.GetWeaponConfig(InWeapon)
    return tbConfig and tbConfig.WeaponPartsLimit or nil
end

---获取武器可以装配的配件
---@param InWeapon UWeaponItem
---@param InType EWeaponSlotType
function Weapon.GetShowPartsByType(InWeapon, InType)
    local tbParts = WeaponPart.GetPartsByType(InType)
    local tbAllow = {}
    for _, cfg in ipairs(tbParts) do
        local bCan = Weapon.CanEquipPartByCfg(InWeapon, cfg)
        if bCan then
            table.insert(tbAllow, cfg)
        end
    end
    return tbAllow
end

---获得武器使用者
---@param pWeapon UWeaponItem
function Weapon.FindCardByWeapon(pWeapon)
    local Cards = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(Cards)
    for i = 1, Cards:Length() do
       local pw = Cards:Get(i):GetSlotWeapon()
       if pw and pw:Id() == pWeapon:Id() then
            return Cards:Get(i)
       end
    end
    return nil
end

---获取配件属性
function Weapon.GetPartAttr(pWeapon)
    local Parts = UE4.TArray(UE4.UWeaponParts)
    pWeapon:GetWeaponSlots(Parts)
    local tbRet = {}
    for i = 1, Parts:Length() do
        local partCfg = WeaponPart.GetPartConfig(Parts:Get(i))
        local tbAttr = WeaponPart.GetPartAttr(partCfg)
        for k, v in pairs(tbAttr) do
            tbRet[k] =(tbRet[k] or 0) + v
        end
    end
    return tbRet
end


---是否装备了配件
---@param InWeapon UWeaponItem
---@param InG Integer
---@param InD Integer
---@param InP Integer
---@param InL Integer
---@return boolean
function Weapon.IsInEquipPart(InWeapon, InG, InD, InP, InL)
    local Parts = UE4.TArray(UE4.UWeaponParts)
    InWeapon:GetWeaponSlots(Parts)
    for i = 1, Parts:Length() do
        local pPart = Parts:Get(i)
        if pPart:Genre() == InG and pPart:Detail() == InD and pPart:Particular() == InP and pPart:Level() == InL then
            return true
        end
    end
    return false
end


---获取武器配置信息
---@param InWeapon UWeaponItem
function Weapon.GetWeaponConfig(InWeapon)
    local sGDPL = string.format("%s-%s-%s-%s", InWeapon:Genre(), InWeapon:Detail(), InWeapon:Particular(), InWeapon:Level())
    return Weapon.tbWeaponConfig[sGDPL]
end


---根据GDPL获取武器配置信息
function Weapon.GetWeaponConfigByGDPL(g, d, p, l)
    local sGDPL = string.format("%s-%s-%s-%s", g, d, p, l)
   return Weapon.tbWeaponConfig[sGDPL]
end

---获取武器的属性配置信息
---@param InWeapon UWeaponItem
function Weapon.GetWeaponGrowConfig(InWeapon)
    if not Weapon.GetWeaponConfig(InWeapon) or not Weapon.GetWeaponConfig(InWeapon).GrowupID then
        return
    end
    local nGrowID = Weapon.GetWeaponConfig(InWeapon).GrowupID
    return Weapon.tbGrow[nGrowID]
end

---根据GDPL获取武器的属性配置信息
function Weapon.GetWeaponGrowConfigByGDPL(g, d, p, l)
    local nGrowID = Weapon.GetWeaponConfigByGDPL(g, d, p, l).GrowupID
    return Weapon.tbGrow[nGrowID]
end

---获取当前武器的品质描述
---@param InWeapon UWeaponItem
function Weapon.GetWeaponQualityDes(InWeapon)
    return UE4.UUMGLibrary.GetEnumValueAsString("EWeaponQuality",InWeapon:Quality())
end

---获取对应进化的消耗金币数量
---@param InWeapon UWeaponItem
---@return number 金币数量
function Weapon.GetEvolutionCostGold(InWeapon)
    local tbConfig = Weapon.GetWeaponConfig(InWeapon)
    if tbConfig then
        return tbConfig.EvolutionGold
    end
    return  0
end

---获取进化配置
---@param InWeapon UWeaponItem
function Weapon.GetEvolutionMat(InWeapon)
    local nMatId = InWeapon:EvolutionMatID()
    if Weapon.tbEvolutionMaterials[nMatId] then
        return Weapon.tbEvolutionMaterials[nMatId][InWeapon:Evolue() + 1]
    end
    return nil
end

---反转
function Weapon.TableReverse(tb)
    local tbNew = {}
    for i = #tb, 1, -1 do table.insert(tbNew, tb[i])  end
    return tbNew
end

---获取武器强化的道具
---@param upWeapon UWeaponItem
---@param bOneKeySelect boolean 是否一键选择
---@param tbSort table
function Weapon.GetSecgradeByGDPL(upWeapon, bOneKeySelect, tbSort)
    local tbRet = {}
    if not upWeapon then return end

    local AllItems = UE4.TArray(UE4.UItem)
    me:GetItems(AllItems)
    ---添加材料
    for i = 1, AllItems:Length() do
        local Item = AllItems:Get(i)
        if Item:Genre() == 5 and Item:Detail() == 2 then
            table.insert(tbRet, Item)
        end
    end


    if tbSort then
        tbRet = ItemSort:Sort(tbRet, tbSort.tbSorts)
        if tbSort.bReverse then
            tbRet = Weapon.TableReverse(tbRet)
        end
    else
        table.sort(tbRet, function(a, b)  if  a:Color() ~= b:Color() then  return a:Color() < b:Color()  end  return a:Id() < b:Id() end)
    end
    
    local nNum = #tbRet
    local fAddWeapon = function(fCondition)
        local tbAddWeapon = {}
        local AllWeapon = UE4.TArray(UE4.UWeaponItem)
        me:GetWeaponItems(AllWeapon, false)
        for i = 1, AllWeapon:Length() do
            ---@type UWeaponItem
            local pWeapon = AllWeapon:Get(i)
            ---排除自己
            if pWeapon:Id() ~= upWeapon:Id() then 
                local bPass = true
                if fCondition then
                    bPass = fCondition(pWeapon)
                end
                if bPass and Weapon.CanUse(pWeapon) then
                    table.insert(tbAddWeapon, pWeapon)
                end 
            end
        end
        if tbSort then
            tbAddWeapon = ItemSort:Sort(tbAddWeapon, tbSort.tbSorts)
            if tbSort.bReverse then
                tbAddWeapon = Weapon.TableReverse(tbAddWeapon)
            end
        else
            table.sort(tbAddWeapon, function(a, b)  if  a:Color() ~= b:Color() then  return a:Color() < b:Color()  end  return a:Id() < b:Id() end)
        end
       
        for _, pWeapon in ipairs(tbAddWeapon) do
            table.insert(tbRet, pWeapon)
        end
    end
    if bOneKeySelect == false then
        fAddWeapon(nil)
    elseif nNum <= 0 then
        ---当没有强化狗粮时，一键选择功能也需要能自动选中所有紫色品质以下的枪械（紫色和金色只能手动选择来吃）
        fAddWeapon(function(pWeapon) return pWeapon:Color() < 4 end)
    end
    return tbRet
end

---是否升级到最大等级
---@param InWeapon UWeaponItem
function Weapon.IsMaxLevel(InWeapon)
    return InWeapon:EnhanceLevel() >= Item.GetMaxLevel(InWeapon)
end

---是否可以突破
---@param InWeapon UWeaponItem
function Weapon.IsCanBreak(InWeapon)
  if Weapon.IsMaxLevel(InWeapon) and not Item.IsBreakMax(InWeapon) then
    return true
  end
  return false
end

---是否可以使用
---@param InWeapon UE4.UWeaponItem
function Weapon.CanUse(InWeapon)
    if InWeapon:HasFlag(Item.FLAG_LOCK) or InWeapon:HasFlag(Item.FLAG_USE) then
        return false
    end
    return true
end


---获取突破等级对应的等级上限
function Weapon.GetMaxLv(pWeapon, nBreakLv)
    local tbCfg = Item.tbBreakLevelLimit[pWeapon:BreakLimitID()]
    if not tbCfg then
        return pWeapon:EnhanceLevel()
    else
        return tbCfg[nBreakLv] or pWeapon:EnhanceLevel()
    end
end

---获取所有可以装配改武器的卡
---@param pWeapon UWeaponItem
---@param tbCard table 角色列表
function Weapon.GetAllCardByWeapon(pWeapon)
    local tbCard = {}
    local allCards = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(allCards, false)
    for j = 1, allCards:Length() do
        local pCard = allCards:Get(j)
        local nWeaponType = Item.GetCardWeaponType(pCard)
        if nWeaponType == pWeapon:Detail() then
            table.insert(tbCard, pCard)
        end
    end
    return tbCard
end

---获取所有武器
---@return Weapons UE4.TArray 所有武器
function Weapon.GetAllWeapon()
    local Weapons = UE4.TArray(UE4.UWeaponItem)
    me:GetWeaponItems(Weapons)
    return Weapons:ToTable()
end

---获取角色卡可以装配的所有武器
---@param InCard UCharacterCard 角色卡
---@return Weapons UE4.TArray 所有武器
function Weapon.GetAllWeaponByCard(InCard)
    local tbWeapon = {}
    if InCard:IsTrial() then
        table.insert(tbWeapon, InCard:GetSlotWeapon())
        return tbWeapon
    end

    local nType = Item.GetCardWeaponType(InCard)
    local Weapons = Weapon.GetAllWeapon()
    
    for _, pTemp in pairs(Weapons or {}) do
        if pTemp and pTemp:Detail() == nType then
            table.insert(tbWeapon,pTemp)
        end
    end
    return tbWeapon
end

---获取所有可消耗的武器
---@return Weapons table 所有可消耗武器（未装配 未锁定）
function Weapon.GetAllCanConsumeWeapon()
    local AllWeapon = Weapon.GetAllWeapon()
    local tbWeapon = {}
    for _, pItem in ipairs(AllWeapon) do
        if Weapon.CanUse(pItem) then
            table.insert(tbWeapon, pItem)
        end
    end
    return tbWeapon
end

-------------------------返回进化材料------------------------
---@param InWeapon UWeaponItem
function Weapon.GetEvolutionCost(InWeapon, tbSortInfo)
    local tbCost = {}
    local AllWeapon = UE4.TArray(UE4.UWeaponItem)

    local fFindItem = function(g, d, p, l)
        local tbRet = {}
        local allItem = me:GetItemsByType(UE4.EItemType.Suplies)
        for i = 1, allItem:Length() do
            local pItem = allItem:Get(i)
            if pItem:Genre() == g and pItem:Detail() == d and pItem:Particular() == p and pItem:Level() == l then
                table.insert(tbRet, pItem)
                break
            end
        end
        return tbRet
    end

    local fGetWeapon = function(g, d, p, l)
        local AllWeapon = me:GetWeaponItems()
        local tbRet = {}
        for i = 1, AllWeapon:Length() do
            local pItem = AllWeapon:Get(i)
            if InWeapon ~= pItem and pItem:Genre() == g and pItem:Detail() == d and pItem:Particular() == p and pItem:Level() == l and Weapon.CanUse(pItem) then
               table.insert(tbRet, pItem)
            end
        end
        return tbRet
    end

    me:GetWeaponItems(AllWeapon)
    local tbMat= Weapon.GetEvolutionMat(InWeapon)
    if not tbMat then return nil end
    for _, Mat in ipairs(tbMat) do
        local G, D, P, L , N = 0
        if #Mat == 1 then
            G = InWeapon:Genre()
            D = InWeapon:Detail()
            P = InWeapon:Particular()
            L = InWeapon:Level()
        else
            G, D, P, L, N = table.unpack(Mat)
        end

        if G == 2 then
           tbCost = Concat(tbCost , fGetWeapon(G, D, P, L) or {})
        else
            tbCost = Concat(tbCost , fFindItem(G, D, P, L) or {})
        end
    end

    if tbSortInfo then
        tbCost = ItemSort:Sort(tbCost, tbSortInfo.tbSorts)
        if tbSortInfo.bReverse then
            tbCost = Weapon.TableReverse(tbCost)
        end
    end
   
    return tbCost
end

---是否进化最大等级
---@param InWeapon UWeaponItem
---@return boolean
function Weapon.IsEvolutionMax(InWeapon)
    local tbMat = Weapon.GetEvolutionMat(InWeapon)
    return tbMat == nil
end

------------------------武器替换--------------------------------------
function Weapon.Req_Replace(pCard, InWeaponID)
    if pCard == nil then
       print('Weapon.Req_Replace Error', InWeaponID)
        return
    end
    local OldWeapon = pCard:GetSlotWeapon()

    if OldWeapon and OldWeapon:Id() == InWeaponID then
        print("old === > New", InWeaponID)
        return
    end
    local cmd = {
        CardId = pCard:Id(),
        Id = InWeaponID
    }
    print("Replace======", json.encode(cmd))
    UI.ShowConnection()
    me:CallGS("Weapon_Replace", json.encode(cmd))
end

s2c.Register("Weapon_Replace", function()
        UI.CloseConnection()
        local pRoleUI = UI.GetUI('Role')
        if pRoleUI then
            local UIWeapon = pRoleUI:GetSwitcherWidget("Weapon")
            if UIWeapon then
                UIWeapon:OnReciveReplace()
            end
        end
    end
)

------------------------武器交换--------------------------------------
function Weapon.Req_Exchange(pCardA, pCardB)
    local cmd = {
        CardIdA = pCardA:Id(),
        CardIdB = pCardB:Id()
    }
    UI.ShowConnection()
    me:CallGS("Weapon_Exchange", json.encode(cmd))
end

s2c.Register("Weapon_Exchange", function()
        UI.CloseConnection()
        local pRoleUI = UI.GetUI('Role')
        local UIWeapon = pRoleUI:GetSwitcherWidget("Weapon")
        if UIWeapon then
            UIWeapon:OnReciveExchange()
        end
    end
)

------------------------武器升级---------------------------------------
function Weapon.Req_Upgrade(InWeapon, tbMat)
    local cmd = {
        Id = InWeapon:Id(),
        tbMaterials = tbMat
    }

    UI.ShowConnection()
    me:CallGS("Weapon_Upgrade", json.encode(cmd))
end

s2c.Register("Weapon_Upgrade", function(tbInfo)
    UI.CloseConnection()
    if tbInfo.sErr then
        UI.ShowTip(Text(tbInfo.sErr))
        return
    end
    UI.Call2('Arms', 'Call', 'LevelUp', 'OnRsp', tbInfo.bMaxUnLock or false)
end
)

-----------------------武器突破-----------------------------------------------
---武器突破
---@param InWeapon UWeaponItem
---@param InCallBack function
function Weapon.Req_Break(InWeapon)
    local cmd = {
        Id = InWeapon:Id()
    }

    UI.ShowConnection()
    me:CallGS("Weapon_Break", json.encode(cmd))
end

s2c.Register("Weapon_Break", function(sErr)
    UI.CloseConnection()
    if sErr then
        UI.ShowTip(Text(sErr))
        return
    end
    UI.Call2('Arms', 'Call', 'Break', 'OnRsp')
end
)

--------------------武器进化-------------------------------------
---武器进化消耗的武器
function Weapon.Req_Evolution(pWeapon, nId)
    local cmd = {
        Id = pWeapon:Id(),
        nItemId = nId
    }
    UI.ShowConnection()
    me:CallGS("Weapon_Evolution", json.encode(cmd))
end
s2c.Register("Weapon_Evolution", function(sErr) 
    UI.CloseConnection()
    if sErr then
        UI.ShowTip(Text(sErr))
        return
    end
    UI.Call2('Arms', 'Call', 'Evoluation', 'OnRsp')
end)

--------------------武器配件替换-------------------------------------

function Weapon.Req_ReplacePart(InWeapon, InPartID, InType)
    local cmd = {
        Id = InWeapon:Id(),
        Type = InType,
        PartId = InPartID
    }
    UI.ShowConnection()
    me:CallGS("Weapon_ReplacePart", json.encode(cmd))
end

s2c.Register("Weapon_ReplacePart", function(err)
    UI.CloseConnection()
    if err then  UI.ShowTip(err)  return end

    UI.CloseByName('ArmspartsItem')
end
)

---------------Puiblic End-----------

-------------Load Cofig--------------
function Weapon.LoadGrowConfig()
    local tbConfig = LoadCsv("item/weapon/grow.txt", 1)
    for _, Data in pairs(tbConfig) do
        local ID = tonumber(Data.ID) or 0
        local tbInfo = {
            Attack = Eval(Data.Attack),
            nDamageType = tonumber(Data.DamageType),
            DamageCoefficient = tonumber(Data.DamageCoefficient),
            WeaknessDamage = tonumber(Data.WeaknessDamage),
            FireSpeed = tonumber(Data.FireSpeed),
            BreathlessValue = tonumber(Data.BreathlessValue),
            HitCharacterEnergyRecover = tonumber(Data.HitCharacterEnergyRecover),
            CharacterEnergyRecoverHitCount = tonumber(Data.CharacterEnergyRecoverHitCount),


            CriticalValue = Eval(Data.CriticalValue),
            CriticalDamage = Eval(Data.CriticalDamage),
            HealthPer_break = Eval(Data.HealthPer_break),
            AttackPer_break = Eval(Data.AttackPer_break),
            ArmsPer_break = Eval(Data.ArmsPer_break),
            DefencePer_break = Eval(Data.DefencePer_break),
            Command_break = Eval(Data.Command_break),
            CharacterEnergyEfficiency_break = Eval(Data.CharacterEnergyEfficiency_break),
            CriticalDamageAddtion_break = Eval(Data.CriticalDamageAddtion_break),
            SkillIntensity_break = Eval(Data.SkillIntensity_break),
            SkillCDQuick_break = Eval(Data.SkillCDQuick_break),
            NormalEnergySpeed_break = Eval(Data.NormalEnergySpeed_break),

            tbAttrStr = {
                CriticalValue = Data.CriticalValue,
                CriticalDamage = Data.CriticalDamage,
                HealthPer_break = Data.HealthPer_break,
                AttackPer_break = Data.AttackPer_break,
                ArmsPer_break = Data.ArmsPer_break,
                DefencePer_break = Data.DefencePer_break,
                Command_break = Data.Command_break,
                CharacterEnergyEfficiency_break = Data.CharacterEnergyEfficiency_break,
                CriticalDamageAddtion_break = Data.CriticalDamageAddtion_break,
                SkillIntensity_break = Data.SkillIntensity_break,
                SkillCDQuick_break = Data.SkillCDQuick_break,
                NormalEnergySpeed_break = Data.NormalEnergySpeed_break,
                SkillMastery_break = Data.SkillMastery_break,
            },
      

            BulletNum = tonumber(Data.BulletNum),
            BulletCost = tonumber(Data.BulletCost) ,
            ReloadSpeedRatio = tonumber(Data.ReloadSpeedRatio),
            PreFire = tonumber(Data.PreFire),
            AdditionalCritDamageInAimState = tonumber(Data.AdditionalCritDamageInAimState),
            AdditionalCritPercentInAimState = tonumber(Data.AdditionalCritPercentInAimState),
            nFiringRangeStartAttenuation = tonumber(Data.FiringRangeStartAttenuation),
            nFiringRangeUltimateLimit = tonumber(Data.FiringRangeUltimateLimit),
        }
        Weapon.tbGrow[ID] = tbInfo
    end
end

---加载进化配置表
function Weapon.LoadEvolutionMaterials()
    local tbFile = LoadCsv('item/weapon/skill_upgrade.txt', 1);
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID or '0');
        Weapon.tbEvolutionMaterials[nId] = {
            Eval(tbLine.Items1),
            Eval(tbLine.Items2),
            Eval(tbLine.Items3),
            Eval(tbLine.Items4),
            Eval(tbLine.Items5),
        };
    end
end

---加载武器配置
function Weapon.LoadWeaponConfig()
    local tbFile = LoadCsv("item/templates/weapon.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nClose = tonumber(tbLine.Close)
        if (not nClose) or nClose == 0 then
            local sGDPL = string.format("%s-%s-%s-%s", tbLine.Genre, tbLine.Detail, tbLine.Particular, tbLine.Level)
            if sGDPL and #sGDPL > 0 then
                local tbInfo = {
                    DefaultSkillID = Eval(tbLine.DefaultSkillID),
                    EvolutionGold  = tonumber(tbLine.EvolutionGold) or 0,
                    WeaponPartsLimit = Eval(tbLine.WeaponPartsLimit),
                    GrowupID = tonumber(tbLine.GrowupID) or 0,
                    WeaponPartsAward = Eval(tbLine.WeaponPartsAward),
                    nClass = tonumber(tbLine.Class),
                }
                Weapon.tbWeaponConfig[sGDPL] = tbInfo
            end
        end
    end
end

---加载武器配件镜头配置
function Weapon.LoadDisplayConfig()
    local tbFile = LoadCsv("item/weapon/display.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local ID = tonumber(tbLine.ID)
        if ID then
            local tbInfo = {
                Eval(tbLine.display1),
                Eval(tbLine.display2),
                Eval(tbLine.display3),
                Eval(tbLine.display4),
                Eval(tbLine.display5)
            }
            Weapon.tbDisplayConfig[ID] = tbInfo
        end
    end
end

---加载武器配件基础值
function Weapon.LoadAbilityConfig()
    local tbFile = LoadCsv("item/weapon/ability.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local ID = tonumber(tbLine.ID)
        if ID then
            local tbInfo = {
                DamageAbility = tonumber(tbLine.DamageAbility) or 0,
                ContinuityAbility = tonumber(tbLine.ContinuityAbility) or 0,
                MotilityAbility = tonumber(tbLine.MotilityAbility) or 0,
                SkillAbility = tonumber(tbLine.SkillAbility) or 0
            }
            Weapon.tbAbilityConfig[ID] = tbInfo
        end
    end
end
-------------Load Config End-------------------------------

function Weapon.__Init()
    Weapon.LoadGrowConfig()
    Weapon.LoadEvolutionMaterials()
    Weapon.LoadWeaponConfig()
    Weapon.LoadDisplayConfig()
    Weapon.LoadAbilityConfig()
end
Weapon.__Init()

return Weapon
