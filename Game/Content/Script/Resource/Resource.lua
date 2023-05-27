-- ========================================================
-- @File    : Resource.lua
-- @Brief   : UI资源
-- ========================================================

Resource = Resource or { tbResource = {}, tbResourceStr = {}, tbPainting = {},tbAttrIconId = {}, tbEffect = {}}

---属性Icon的路径
---@param InAttr string 属性名字段
function Resource.GetAttrPaint(InAttr)
    if not InAttr then
        return print('err cate',InAttr)
    end
    local sAttr = string.lower(tostring(InAttr))
    if not Resource.tbAttrIconId[sAttr] then
        return print('err key',sAttr)
    end

    if not Resource.tbAttrIconId[sAttr].IconId then
        return print('not config id')
    end
    return Resource.tbResource[Resource.tbAttrIconId[sAttr].IconId]
end

---获取特效资源
---@param nID number 资源ID
---@return string 资源路劲
function Resource.GetEffectCfg(nID)
    return Resource.tbEffect[nID]
end

---获取资源
---@param nID number 资源ID
---@return string 资源路劲
function Resource.Get(nID)
    if not nID or nID <= 0 then
        return 
    end
    return Resource.tbResource[nID]
end

---获取样式资源ID
function Resource.GetPaintingID(nID, sType)
    if not nID or not sType then return 0 end
    if Resource.tbPainting[nID] then
        return Resource.tbPainting[nID][sType]
    end
end

---获取资源
---@param nID string 资源ID
---@return string 资源路劲
function Resource.GetByStrId(nID)
    if not nID then
        return 
    end
    return Resource.tbResourceStr[nID]
end

-------------------------------------------------------------------------------------
function Resource.Load()
    ---加载资源配置
    local tbInfo = LoadCsv("resource/resource.txt", 1)
    for _, tbLine in ipairs(tbInfo) do
        local nID = tonumber(tbLine.ID) or 0;
        if tbLine.path then
            Resource.tbResource[nID] = string.format('/Game/UI/%s', tbLine.path or '')
        end
    end

    --- 加载字符串配置
    local aFiles = UE4.UUMGLibrary.FindFilesInFolder("Settings/resource/resource_str", ".txt")
    for i = 1, aFiles:Length() do
        local sFile = aFiles:Get(i);
        local pFile = string.gsub(sFile, ".txt", "")

        local tbInfo = LoadCsv(string.format("resource/resource_str/%s", sFile), 1)
        for _, tbLine in ipairs(tbInfo) do
            if tbLine.ID then
                local key = string.format("%s.%s", pFile, tbLine.ID)
                Resource.tbResourceStr[key] = string.format('/Game/UI/%s', tbLine.path or '')
            end
        end
    end

    ---加载特效配置
    local tbInfo = LoadCsv("resource/effect.txt", 1)
    for _, tbLine in ipairs(tbInfo) do
        local nID = tonumber(tbLine.ID) or 0;
        Resource.tbEffect[nID] = {
            sPath   = string.format('/Game/UI/Effect/%s', tbLine.Path or ''),
            tbSize  = Eval(tbLine.Size) or {0,0}
        }
    end

    ---
    local tbPaintingCfg = {
        'item/support/painting',
        'item/weapon/painting',
        'item/weapon_parts/painting',
        'item/card/painting',
        'item/suplies/painting',
        'cash/painting',
        'item/card_skin/painting',
        'item/dorm_gift/painting',
    }
    for _, sPath in ipairs(tbPaintingCfg) do
        local tbInfo = LoadCsv(sPath .. ".txt", 1)
        for _, tbLine in ipairs(tbInfo) do
            local nID = tonumber(tbLine.ID) or 0;
            local tbData = {}
            for skey, nSubID in pairs(tbLine) do
                if skey ~= 'ID' and skey ~= 'Comment' and skey ~= 'Define' then
                    tbData[string.lower(skey)] = tonumber(nSubID) or 0
                end
            end
            Resource.tbPainting[nID] = tbData 
        end
    end
    print('Load ../settings/.../painting.txt')
end


function Resource.LoadAttrConfig()
    local tbFile = LoadCsv("item/attribute_painting.txt", 1)
    for _, tbLine in pairs(tbFile) do
        local sKey =string.lower(tostring(tbLine.ECate or nil))
        local tbData = {
            IconId = tonumber(tbLine.IconId) or 0
        } 
        Resource.tbAttrIconId[sKey] = tbData
    end
    print('Load ../settings/item/attribute_painting.txt')
end

Resource.Load()
Resource.LoadAttrConfig()