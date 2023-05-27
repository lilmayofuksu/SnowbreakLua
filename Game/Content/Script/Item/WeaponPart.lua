-- ========================================================
-- @File    : WeaponPart.lua
-- @Brief   : 武器配件
-- ========================================================
----@class WeaponPart
---@field tbPartConfig table
---@field tbGrow table 配件属性配置
WeaponPart = WeaponPart or {tbPartConfig = {}, tbGrow = {}}


local TYPE_ICON = {
    [UE4.EWeaponSlotType.Muzzle]        = 1400102,
    [UE4.EWeaponSlotType.TopGuide]      = 1400101,
    [UE4.EWeaponSlotType.Ammunition]    = 1400104,
    [UE4.EWeaponSlotType.LowerGuide]    = 1400103,
}

---百分比数值
local tbPercentType = {['BulletNum'] = 0, ['Health'] = 0, ['Attack'] = 0, ['Defence'] = 0}


function WeaponPart.GetAllowWeaponType(cfg)
    if not cfg or not cfg.tbWeaponAllow then return 1 end
    return cfg.tbWeaponAllow[1] or 1
end

---获取配件类型图标
function WeaponPart.GetTypeIcon(nType)
    return TYPE_ICON[nType]
end

---配件是否查看了
function WeaponPart.IsRead(pPart)
    if not pPart then return true end
    return pPart:HasFlag(Item.FLAG_READED) == true
end


---标记查看了武器配件
function WeaponPart.Read(g, d, p, l)
    local pPart = WeaponPart.GetPart(g, d, p, l)
    if not pPart then return end
    if WeaponPart.IsRead(pPart) then return end
    Item.Read({pPart:Id()})
end


---获取武器配件
---@param G integer
---@param D integer
---@param P integer
---@param L integer
function WeaponPart.GetPart(G, D, P, L)
    local Parts = UE4.TArray(UE4.UWeaponParts)
    me:GetWeaponPartsItems(Parts)
    for i = 1, Parts:Length() do
        local pPart = Parts:Get(i)
        if pPart:Genre() == G and pPart:Detail() == D and pPart:Particular() == P and pPart:Level() == L then
            return pPart
        end
    end
    return nil
end

---获取稀有度描述
---@param InColor Integer
function WeaponPart.GetColorDes(InColor)
    return UE4.UUMGLibrary.GetEnumValueAsString("EWeaponQuality", InColor)
end

---获取活动的配件列表
function WeaponPart.GetGainPartsByType(nType)
    return me:GetWeaponPartsItemsForIndex(nType):ToTable()
end

---获取某类型的所有配件
---@param InType EWeaponSlotType
function WeaponPart.GetPartsByType(InType)
    local tbRet = {}
    for _, tbInfo in pairs(WeaponPart.tbPartConfig) do
        if tbInfo.D == InType then
            table.insert(tbRet, tbInfo)
        end
    end
    return tbRet
end

---获取配件配置
---@param InPart UWeaponParts
function WeaponPart.GetPartConfig(InPart)
    return WeaponPart.GetPartConfigByGDPL(InPart:Genre(), InPart:Detail(), InPart:Particular(), InPart:Level())
end

---获取配件适配武器类型
---@param InPart UWeaponParts
function WeaponPart.GetPartWeaponType(InPart)
    local cfg = WeaponPart.GetPartConfigByGDPL(InPart:Genre(), InPart:Detail(), InPart:Particular(), InPart:Level())
    if not cfg or not cfg.tbWeaponAllow then
        return {0}
    end

    local mapType = {}
    for _, d in ipairs(cfg.tbWeaponAllow) do
        mapType[d] = true
    end

    local tbRet = {}
    for index, _ in pairs(mapType) do
        table.insert(tbRet, index)
    end

    return tbRet
end


---根据GDPL获取配件配置
function WeaponPart.GetPartConfigByGDPL(g, d, p, l)
    local sGDPL = string.format("%s-%s-%s-%s", g, d, p, l)
    return WeaponPart.tbPartConfig[sGDPL]
end

function WeaponPart.ConvertType(sType, sDes)
    if not sType or not sDes then return '' end
    if sType == 'BreathShaking' then
        return string.format('-%s', sDes .. '%')
    end
    if tbPercentType[sType] == nil then
        return sDes .. '%'
    end
    return sDes
end


---获取配件属性配置
---@param InPartConfig table 配件的配置
function WeaponPart.GetPartAttr(InPartConfig)
    local tbRet = {}
    if not InPartConfig then return tbRet end
    local tbAttr = WeaponPart.tbGrow[InPartConfig.GrowupID]
    if not tbAttr then return tbRet end
    for k, v in pairs(tbAttr) do
        if v ~= 0 then tbRet[k] = v   end
    end
    return tbRet
end


---------------------配置加载-------------------------------
---加载配件配置表
function WeaponPart.LoadPartConfig()
    local tbFile = LoadCsv("item/templates/weapon_parts.txt", 1)
    for _, tbLine in ipairs(tbFile) do
        local nClose = tonumber(tbLine.Close)
        if (not nClose) or nClose == 0 then
            local sGDPL = string.format("%s-%s-%s-%s", tbLine.Genre, tbLine.Detail, tbLine.Particular, tbLine.Level)
            if sGDPL and #sGDPL > 0 then
                local tbInfo = {
                    G = tonumber(tbLine.Genre),
                    D = tonumber(tbLine.Detail),
                    P = tonumber(tbLine.Particular),
                    L = tonumber(tbLine.Level),
                    Color = tonumber(tbLine.Color),
                    GrowupID = tonumber(tbLine.GrowupID),
                    AppearID = tonumber(tbLine.AppearID),
                    tbWeaponAllow = Eval(tbLine.WeaponAllow),
                    tbClassAllow = Eval(tbLine.ClassAllow),
                }
                WeaponPart.tbPartConfig[sGDPL] = tbInfo
            end
        end
    end
end


---加载属性配置
function WeaponPart.LoadGrowConfig()
    local tbConfig = LoadCsv("item/weapon_parts/grow.txt", 1)
    for _, tbLine in ipairs(tbConfig) do
        local ID = tonumber(tbLine.ID) or 0
        local tbInfo = {}
        for skey, value in pairs(tbLine) do
            if skey ~= 'ID' and skey ~= 'Des' then
                local nValue = tonumber(value)
                if nValue and nValue > 0 then
                    tbInfo[skey] = nValue
                end
            end
        end

        WeaponPart.tbGrow[ID] = tbInfo
    end
end

WeaponPart.LoadPartConfig()
WeaponPart.LoadGrowConfig()
