-- ========================================================
-- @File    : Fashion.lua
-- @Brief   : 时装相关接口
-- ========================================================

---@class Fashion 

---@field tbSkinTemplate table 时装配置表信息
---@field tbCharacterSkin table 单个角色的所有时装配置表信息
Fashion =
    Fashion or {
        tbSkinTemplate = {}, --时装配置表信息
        tbCharacterSkin = {}, --单个角色的时装配置表信息
        tbGainSkins = {},
    }

Fashion.EGetType = {
    "ui.TxtDefaultSkin",  --默认皮肤
    "ui.TxtShopSkin", --商店购买
    "ui.MainActivity", --活动获取
    "",
    "ui.TxtBPFashion",
}

---当前选中的角色
Fashion.SelectCharacterTemplate = nil

---当前选中的皮肤
Fashion.SelectSkin = 0

function Fashion.CheckRedPointByCard(InCard)
    if not InCard or not InCard:IsCharacterCard() then
        return
    end

    local tbSkins = Fashion.GetCharacterSkins(InCard)
    for _, pSkin in pairs(tbSkins) do
        if Fashion.CheckRedPointBySkin(pSkin) then
            return true
        end
    end
end

function Fashion.CheckRedPointBySkin(InSkin)
    if not InSkin or not InSkin:IsCharacterSkin() then
        return
    end

    if InSkin:HasFlag(Item.FLAG_READED) then
        return false
    end

    return true
end

---根据GDPL获得皮肤道具
---@param InParam table GDPL
---@return UItem 皮肤道具
function Fashion.GetSkinItem(InParam)
    local G, D, P, L = table.unpack(InParam)
    Fashion.Skins = UE4.TArray(UE4.UItem)
    me:GetItemsByGDPL(G, D, P, L, Fashion.Skins)
    for i = 1, Fashion.Skins:Length() do
        local v = Fashion.Skins:Get(i)
        if v:IsCharacterSkin() then
            return v
        end
    end
end

---获得指定角色的所有皮肤Template
---@param Detail int 角色Detail
---@param Particular int 角色Particular
---@return table 所有该角色的Template
function Fashion.GetCharacterSkinTemplates(Detail, Particular)
    local sDP = string.format("%s-%s", Detail, Particular)
    return Fashion.tbCharacterSkin[sDP]
end

function Fashion.GetCharacterSkins(InCard)
    if not InCard or not InCard:IsCharacterCard() then
        return
    end

    local tbSkins = {}
    Fashion.Skins = UE4.TArray(UE4.UItem)
    me:GetCharacterSkins(Fashion.Skins)
    for i = 1, Fashion.Skins:Length() do
        local v = Fashion.Skins:Get(i)
        if v:IsCharacterSkin() and v:Detail() == InCard:Detail() and v:Particular() == InCard:Particular() then
            table.insert(tbSkins, v)
        end
    end
    return tbSkins
end

---检查是否拥有该时装
---@param tbParam table G,D,P,L
function Fashion.CheckSkinItem(tbParam)
    local G, D, P, L = table.unpack(tbParam)
    if (not G) or (not D) or (not P) or (not L) then
        return
    end
    return me:GetItemCount(G, D, P, L) > 0
end

---弹出
function Fashion.TryPopGainTips()
    if #Fashion.tbGainSkins > 0 then
        UI.Open("FashionGainTips")
    end
end

Fashion.ChangeSkinCallBack = nil
---请求更换皮肤
---@param Incard UItem 角色卡
---@param InSkin InSkin 皮肤Item
---@param InCallBack function 回调
function Fashion.ChangeSkinReq(InCard, InSkin, InCallBack)
    if (not InCard or not InCard:IsCharacterCard()) then
        UI.ShowTip(Text("ui.TxtShopFashion4"))
        return
    end

    if (not InSkin or not InSkin:IsCharacterSkin()) then
        UI.ShowTip(Text("uiw.TxtChangeSkinFailed"))
        return
    end

    local tbParam = {
        Id = InSkin:Id(),
        CardId = InCard:Id(),
    }
    Fashion.ChangeSkinCallBack = InCallBack
    me:CallGS("GirlSkin_Change", json.encode(tbParam))
end

s2c.Register(
    "GirlSkin_Change",
    function()
        if Fashion.ChangeSkinCallBack then
            Fashion.ChangeSkinCallBack()
        end
        Fashion.ChangeSkinCallBack = nil
    end
)

-----------------------------load Fashion--------------
function Fashion.LoadCharacterSkinConfig()
    local tbConfig = LoadCsv("item/templates/card_skin.txt", 1)
    for _, Data in pairs(tbConfig) do
        local nClose = tonumber(Data.Close)
        if (not nClose) or nClose == 0 then
            local tbInfo = {
                Genre = tonumber(Data.Genre) or 0,
                Detail = tonumber(Data.Detail) or 0,
                Particular = tonumber(Data.Particular) or 0,
                Level = tonumber(Data.Level) or 0,
                I18n = Data.I18n,
                Color = tonumber(Data.Color) or 0,
                Icon = tonumber(Data.Icon) or 0,
                UseMode = tonumber(Data.UseMode) or 0,
                AppearID = tonumber(Data.AppearID),
                GetType = tonumber(Data.GetType),
                GetWay = tonumber(Data.GetWay),
            }
            local sDP = string.format("%s-%s",Data.Detail, Data.Particular)
            local sGDPL = string.format("%s-%s-%s-%s", Data.Genre, Data.Detail, Data.Particular, Data.Level)
            if not Fashion.tbCharacterSkin[sDP] then
                Fashion.tbCharacterSkin[sDP] = {}
            end
            table.insert(Fashion.tbCharacterSkin[sDP], tbInfo)
            Fashion.tbSkinTemplate[sGDPL] = tbInfo
        end
    end

    print("Load ../settings/item/template/card_skin.txt")
end


function Fashion.__Init()
    Fashion.LoadCharacterSkinConfig()
end

Fashion.__Init()

return Fashion