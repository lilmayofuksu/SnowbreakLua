-- ========================================================
-- @File    : uw_gacha_extra.lua
-- @Brief   : 附加赠送
-- ========================================================
---@class tbClass
local tbClass = Class("UMG.SubWidget")

local function GetExtra(g, d, p, l)
    local tbRet = {}
    if g == 1 then
        local sGDPL = string.format('%s-%s-%s-%s', g, d, p, l)
        if Gacha.tbExistsItem[UE4.EItemType.CharacterCard] and Gacha.tbExistsItem[UE4.EItemType.CharacterCard][sGDPL] then
            local tbConvert = Item.tbCharacterCard2Piece[sGDPL]
            for _, info in ipairs(tbConvert) do
                ---额外产出物G=5 D=13
                if info[1] == 5 and info[2] == 13 then
                    table.insert(tbRet, info)
                end
            end
        end
    elseif g == 2 then
        ---@type FItemTemplate
        local pTemplate = UE4.UItemLibrary.GetItemTemplateByGDPL(g, d, p, l)
        tbRet = Gacha.tbWeaponExtra[pTemplate.Color] or {}
    end

    return tbRet
end


function tbClass:SetByGDPL(g, d, p, l)
    local tbAllExtra = {}
    local tbExtra = GetExtra(g, d, p, l)
    for _, info in ipairs(tbExtra) do
        local key = string.format('%s-%s-%s-%s', info[1], info[2], info[3], info[4])
        if not tbAllExtra[key] then
            tbAllExtra[key] = {info[1], info[2], info[3], info[4], info[5]}
        else
            tbAllExtra[key][5] =  tbAllExtra[key][5] + info[5]
        end
    end
    WidgetUtils.Collapsed(self.GreyTxt)
    WidgetUtils.HitTestInvisible(self.WhiteTxt)
    self:ShowInfo(tbAllExtra)
end

---
function tbClass:SetByTb(tbInfo)
    local tbAllExtra = {}
    for _, gdpl in ipairs(tbInfo) do
        local tbExtra = GetExtra(table.unpack(gdpl)) or {}
        for _, value in ipairs(tbExtra) do
            local key = string.format('%s-%s-%s-%s', value[1], value[2], value[3], value[4])
            if not tbAllExtra[key] then
                tbAllExtra[key] = {value[1], value[2], value[3], value[4], value[5]}
            else
                tbAllExtra[key][5] =  tbAllExtra[key][5] + value[5]
            end
        end
    end
    WidgetUtils.HitTestInvisible(self.GreyTxt)
    WidgetUtils.Collapsed(self.WhiteTxt)
    self:ShowInfo(tbAllExtra)
end

---
function tbClass:ShowInfo(tbInfo)
    if tbInfo and next(tbInfo) ~= nil then
        local tbSort = {}
        for _, info in pairs(tbInfo or {}) do
            table.insert(tbSort, info)
        end
        table.sort(tbSort, function(a, b)   
           return a[4] > b[4]  
        end)

        for idx, val in ipairs(tbSort) do
            WidgetUtils.HitTestInvisible(self['Prop' .. idx])
            ---@type FItemTemplate
            local pTemplate = UE4.UItemLibrary.GetItemTemplateByGDPL(val[1], val[2], val[3], val[4])
            SetTexture(self['Icon' .. idx], pTemplate.Icon)
            self['TxtNum' .. idx]:SetText(val[5] or 0)
        end
    else
        WidgetUtils.Collapsed(self)
    end
end

return tbClass