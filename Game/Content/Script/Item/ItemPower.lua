-- ========================================================
-- @File    : ItemPower.lua
-- @Brief   : 道具战力计算
-- ========================================================

---@class ItemPower 战力计算
ItemPower = ItemPower or {tbPower = {}}


function ItemPower.Get(sID)
    return ItemPower.tbPower[sID] or 0
end




--[[
    如果 color=3 则=0.65	
    如果 color=4 则=0.8	
    如果 color=5 则=1	
]]
---武器品阶倍率
local tbWeaponRate = {
    [3] = 0.65,
    [4] = 0.8,
    [5] = 1
}




--------------------------------------------
--------------------------------------------



---角色卡战力计算
---@param pCard UCharacterCard
---@param nLevel Integer
function ItemPower.Card(pCard, nLevel, nBreak, nEvolue, nTrust)
    if not pCard then return 0 end
    nLevel = nLevel or pCard:EnhanceLevel()
    nBreak = nBreak or pCard:Break()

    local nColor = pCard:Color() or 3

    ---稀有度分
    ---根据角色稀有度进行判断 5则读取card5 4则读取card4
    local sColorID = string.format('card%s', nColor)
    local nColorPower = ItemPower.Get(sColorID)

    ---等级分
    ---cardlvbase+角色等级*cardlv
    local nLevelPower = ItemPower.Get('cardlvbase') + nLevel * ItemPower.Get('cardlv')

    ---角色神经分
    ---神经激活数*cardnode1+神经激活数/3的商*cardnode2+神经激活数/9的商*cardnode3
    local allNode = pCard:GetAllActiveSpineNode(false)
    local nNodeActive = allNode:Length()
    local nNodePower =  nNodeActive * ItemPower.Get('cardnode1') + (nNodeActive // 3 * ItemPower.Get('cardnode2')) + (nNodeActive // 9 * ItemPower.Get('cardnode3'))

    ---角色天启分
    ---天启激活数*cardbreak1+天启激活数/9的商*cardbreak2
    local nBreakActive = nBreak
    local nBreakPower = nBreakActive * ItemPower.Get('cardbreak1') + nBreakActive // 9 * ItemPower.Get('cardbreak2')

    ---角色同步率分
    ---同步率激活数*cardpro
    local nProPower = 0;                                                    -- 
    local bOpen, _ = FunctionRouter.IsOpenById(FunctionType.ProLevel);      --
    if bOpen then                                                           --
        local nProActive = pCard:ProLevel() + 1                             --
        nProPower = nProActive * ItemPower.Get('cardpro')               --
    end                                                                     --

    ---角色部分总分=角色稀有度分*（角色等级分+角色神经分+角色天启分+角色同步率分）
    local nCardSum = nColorPower * (nLevelPower + nNodePower + nBreakPower + nProPower)

    local nWeaponSum = 0
    local pWeapon = pCard:GetSlotWeapon()
    if pWeapon then
        nWeaponSum = ItemPower.Weapon(pWeapon)
    end


    ---后勤
    local nSupporterSum = 0
    local tbRec = {}
    local supporterCards = pCard:GetSupporterCards()
    for i = 1, supporterCards:Length() do
        ---@type USupporterCard
        local pSupporterCard = supporterCards:Get(i)

        tbRec[pSupporterCard:Particular()] = tbRec[pSupporterCard:Particular()] or {nColor = pSupporterCard:Color(), nCount = 0}
        tbRec[pSupporterCard:Particular()].nCount = tbRec[pSupporterCard:Particular()].nCount + 1

        nSupporterSum = nSupporterSum + ItemPower.SupporterCard(pSupporterCard)
    end

    ---后勤套装
    local careInfo = nil
    for _, info in pairs(tbRec) do
        if not careInfo or info.nCount > careInfo.nCount then
            careInfo = info
        end
    end

    local nSupporterSuitSum = 0
    if careInfo then
        local sSupportColorID = string.format('support%s', careInfo.nColor or 0)
        local nSupportColorPower = ItemPower.Get(sSupportColorID)

        for i = 2, careInfo.nCount do
            local sSuitID = string.format('supportsuit%s', i) 
            local nSuitPower = ItemPower.Get(sSuitID)
          
            nSupporterSuitSum = nSupporterSuitSum + (nSupportColorPower * nSuitPower)
        end
    end

    return math.floor(nCardSum + nWeaponSum + nSupporterSum + nSupporterSuitSum + 0.5)
end


---后勤
---@param pSupporterCard USupporterCard
---@param nLevel number
function ItemPower.SupporterCard(pSupporterCard, nLevel, nBreak)
    nLevel = nLevel or pSupporterCard:EnhanceLevel()
    nBreak = nBreak or pSupporterCard:Break()

    local nColor = pSupporterCard:Color()

    ---稀有度分
    ---根据后勤稀有度进行判断 5则读取support5 4则读取support4 3则读取support3
    local sColorID = string.format('support%s', nColor)
    local nColorPower = ItemPower.Get(sColorID)

    ---等级分
    ---supportlvbase+后勤等级*supportlv
    local nLevelPower = ItemPower.Get('supportlvbase') + nLevel * ItemPower.Get('supportlv')

    ---突破分
    ---supportbreakbase+后勤突破数*supportbreak
    local nBreakPower = ItemPower.Get('supportbreakbase') + nBreak * ItemPower.Get('supportbreak')

    ---词缀分
    ---supportaffix*{affix1 or affix2 or affix3 or affix4 or affix5}
    ---根据词缀等级进行判断 1则读取affix1 5则读取affix5
    local nSumAffix = 0
    for i = 1, 3 do
        local key, value = pSupporterCard:GetAffixKeyAndValue(i)
        if key > 0 then 
            nSumAffix = nSumAffix + ItemPower.Get(string.format('affix%s', value))
        end
    end
    local nAffxPower = ItemPower.Get('supportaffix') * nSumAffix

    ---后勤部分总分=后勤稀有度分*（后勤等级分+后勤突破分+后勤词缀分）
    return nColorPower * (nLevelPower + nBreakPower + nAffxPower) 
end


---武器战力
---@param pWeapon UWeaponItem
function ItemPower.Weapon(pWeapon, nLevel, nBreak, nEvolution)
    if not pWeapon then return 0 end

    nLevel = nLevel or pWeapon:EnhanceLevel()
    nBreak = nBreak or pWeapon:Break()
    nEvolution = nEvolution or pWeapon:Evolue() 

    ---稀有度分
    ---根据武器稀有度进行判断 5则读取weapon5 4则读取weapon4 3则读取weapon3
    local nColor = pWeapon:Color() or 3
    local sColorID = string.format('weapon%s', nColor)
    local nColorPower = ItemPower.Get(sColorID)

    ---等级分
    ---weaponlvbase+武器等级*weaponlv
    local nLevelPower = ItemPower.Get('weaponlvbase') + nLevel * ItemPower.Get('weaponlv')

    ---突破分
    ---weaponbreakbase+武器突破数*weaponbreak
    local nBreakPower = ItemPower.Get('weaponbreakbase') + nBreak * ItemPower.Get('weaponbreak')

    ---进化分
    ---weaponskill+武器进化数*weaponskilllv
    local nEvoluePower = ItemPower.Get('weaponskill') + nEvolution * ItemPower.Get('weaponskilllv')

    ---配件分
    ---（4-武器配件插槽数）*weaponpart+武器装配配件数*weaponpart
    local parts = pWeapon:GetWeaponSlots()
    local nOpenPart = #Weapon.GetOpenPartSlot(pWeapon)
    local nEquipPart = parts:Length()
    local nPartPower = (4 - nOpenPart) * ItemPower.Get('weaponpart') + nEquipPart * ItemPower.Get('weaponpart')

    return nColorPower * (nLevelPower + nBreakPower + nEvoluePower + nPartPower)
end



-- 突破等级
local tbBreakLevel = {
    [1] = 21, [2] = 31, [3] = 41, [4] = 51, [5] = 61, [6] = 71
}

-- 获取推荐编队
function ItemPower.LoadConf()
    ItemPower.tbRecommandPower = {}
    local tbFile = LoadCsv('Chapter/chapter_power.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID) or 0
        if nId > 0 then
            local tb = {}
            tb.nId = nId
            tb.nCardNum = tonumber(tbLine.CardNum) or 1
            tb.nCardLevel = tonumber(tbLine.CardLevel) or 1
            tb.nWeaponColor = tonumber(tbLine.WeaponColor) or 1
            tb.nWeaponLevel = tonumber(tbLine.WeaponLevel) or 1
            tb.nSupportColor = tonumber(tbLine.SupportColor) or 1
            tb.tbSupportNum = Eval(tbLine.SupportNum) or {}
            tb.tbSupportSuit = Eval(tbLine.SupportSuit) or {}
            tb.nSupportLevel = tonumber(tbLine.SupportLevel) or 1
            tb.tbNodeNum = Eval(tbLine.NodeNum) or {}
            tb.tbProLevel = Eval(tbLine.ProLevel) or {}
            tb.tbCardBreak = Eval(tbLine.CardBreak) or {}
            ItemPower.tbRecommandPower[nId] = tb
        end
    end
end

function ItemPower.LoadPowerConf()
    ItemPower.tbPower = {}
    local tbFile = LoadCsv('item/power.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local sID = tbLine.ID
        if sID then
            ItemPower.tbPower[sID] = tonumber(tbLine.Score) or 0
        end
    end
end

-- 获取推荐配置的对应战力
function ItemPower.GetRecommendPower(nId)
    return 0
    -- local tbConf = ItemPower.tbRecommandPower[nId]
    -- if not tbConf then return 0 end

    -- local power = 0
    -- local cardBreak = ItemPower.GetBreakByLevel(tbConf.nCardLevel)
    -- for i = 1, tbConf.nCardNum do
    --     local nWeapon = ItemPower.CustomWeapon(tbConf.nWeaponLevel, tbConf.nWeaponColor)
    --     local nSupport = ItemPower.CustomSupport(tbConf.nSupportLevel, tbSupporterCardRate[tbConf.nSupportColor]) * (tbConf.tbSupportSuit[i] or 0)
    --     local nBreakRate = 0.65
    --     local nBasic = (10 + 3 * tbConf.nCardLevel) * nBreakRate + nWeapon + nSupport

    --     local nCardBreakRate = 0
    --     local nSpineRate = ItemPower.CustomSpine(tbConf.tbNodeNum[i] or 0)

    --     local nWeaponEvoRate =  0
    --     if tbWeaponEvoNum2Rate[tbConf.nWeaponColor] then
    --         nWeaponEvoRate = tbWeaponEvoNum2Rate[tbConf.nWeaponColor][0] or 0
    --     end

    --     local nSupporterCardAffixRate = tbSupporterCardSuit2Rate[tbConf.nSupportColor][tbConf.tbSupportSuit[i]] or 0

    --     local nRate = nCardBreakRate + nSpineRate + nWeaponEvoRate + nSupporterCardAffixRate
    --     power = power + math.floor(nBasic * (1 + nRate))
    -- end
    -- return power
end

-- 根据等级获取突破次数
function ItemPower.GetBreakByLevel(nLevel)
    local nBreak = 0
    for breakLevel, level in ipairs(tbBreakLevel) do
        if nLevel >= level then nBreak = breakLevel end
    end
    return nBreak
end

-- 自定义武器战力
function ItemPower.CustomWeapon(nLevel, nColor)
    local nBreak = ItemPower.GetBreakByLevel(nLevel)
    return (16 + 2.3 * nLevel + 60 + 10 * nBreak) * tbWeaponRate[nColor]
end

-- 自定义后勤战力
function ItemPower.CustomSupport(nLevel, nColor)
    local nBreak = ItemPower.GetBreakByLevel(nLevel)
    return (6 + 0.8 * nLevel + 7 + 1.5 * nBreak) * (nColor)
end

-- 神经
function ItemPower.CustomSpine(nSpineNum)
    local a = nSpineNum // 7
    return a * 0.025 + (nSpineNum - a) * 0.015
end


ItemPower.LoadConf()
ItemPower.LoadPowerConf()