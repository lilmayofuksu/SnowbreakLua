-- ========================================================
-- @File    : RoleBreak.lua
-- @Brief   : 角色卡突破数据管理
-- ========================================================

---@class RoleBreak 角色卡突破管理

---技能Id
RBreak = RBreak or {
    tbBreakId = {},
    tbBreakMat = {},    -- 突破材料table{Id,tbMat}
    tbBreakGrowth = {}  --- 突破属性
}

--- 当前突破的角色卡
RBreak.InCard = nil
--- 当前突破的被动技能提示
RBreak.OnShowTip = "ON_SHOW_SKILL_TIP"
--- 延时开启突破可点击事件
RBreak.AbleClick = "ABLED_CLICK_HANDLE"

RBreak.ShowStarAnim = "SHOW_STAR_ANIM"

---角色卡突破提示
RBreak.RoleBreakHandle = "RBreak_ROLEBREAKFINISH"

--- 天启等阶
RBreak.NBreak = 5
--- 天启小节点         
RBreak.NBreakLv = 9

---复合按钮状态
RBreak.MulBtn = {
    None = 1,
    PreViewTip = 2, --- 预览Tip
    ComfirmUp = 3 --- 确认突破
}
RBreak.MulState = {
    None = 1, --- 当前不显示
    On = 2, --- 当前显示On状态
    Lock = 3 --- 当前显示Lock状态
}

--- 天启等级界面状态
RBreak.BreakState = {
    Actived         = 0,      -- 完全激活
    InActivated     = 1,      -- 激活中 
    PreActive       = 2,      -- 预览中
    UnActive        = 3       -- 未激活
}

--- 显示百分号的类型
RBreak.PercentageType = {
    Health = true,
    Attack = true,
    Defence = true,
    CriticalValue = true,
    CriticalDamageAddtion = true,
    SkillIntensity = true,
    CharacterEnergyEfficiency = true,
    ShieldDynamicAddtion = true,
    AbnormalStrength = true,
    SkillCDReducePer = true,
    HealBonus = true,
}

--- 获取需要突破的角色卡
function RBreak.GetCard()
    RBreak.InCard = RoleCard:GetShowRole()
end

function RBreak.GetAttrs()
    local tbAttr = {
        UE4.EAttributeType.Health,
        --UE4.EAttributeType.Shield,
        UE4.EAttributeType.Defence,
        UE4.EAttributeType.Arms,
        UE4.EAttributeType.Attack,
        UE4.EAttributeType.CriticalValue,
        UE4.EAttributeType.CriticalDamage
    }
    return tbAttr
end

--- 刷新属性变化
function RBreak.Attrs(InIndex, InCard, ...)
    --突破展示数据
    local Cate = UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", InIndex)
    local tbData = {
        sName = Text(string.format("ui.%s", Cate)),
        nNow = TackleDecimal(
            UE4.UItemLibrary.GetCharacterCardAbilityValueByIndex(InIndex, InCard, nil, InCard:Quality())
        ),
        nNew = TackleDecimal(
            UE4.UItemLibrary.GetCharacterCardAbilityValueByIndex(InIndex, InCard, nil, InCard:Quality() + 1)
        )
    }
    local arg = ...
    if arg then
        tbData = {
            sName = Text(string.format("ui.%s", Cate)),
            nNow = TackleDecimal(
                UE4.UItemLibrary.GetCharacterCardAbilityValueByIndex(InIndex, InCard, nil, InCard:Quality() - 1)
            ),
            nNew = TackleDecimal(
                UE4.UItemLibrary.GetCharacterCardAbilityValueByIndex(InIndex, InCard, nil, InCard:Quality())
            )
        }
    end
    return tbData
end
--- 获取当前需要突破的角色卡的突破材料
function RBreak.GetBreakMat(InItem)
    if InItem then
        local tbMat = Item.GetBreakMaterials(InItem)
        return tbMat
    end
end

--- 获取消耗道具类Item
function RBreak.GetSuppliItem()
    local tbSuppli = me:GetItemsByType(UE4.EItemType.Suplies)
    return tbSuppli:ToTable()
end

function RBreak.GetRoleSuppliItemPieceId(InG,InD,InP,InL)
    for index, value in ipairs(RBreak.GetSuppliItem()) do
        if value:Genre() == InG and 
            value:Detail() == InD and 
            value:Particular() == InP and
            value:Level() == InL then
            return value:EXIcon()
        end
    end
end

function RBreak.GetBreakSkillId(InCard)
    local gdpl = InCard:Genre() .. InCard:Detail() .. InCard:Particular() .. InCard:Level()
    local nBreak,temp = math.modf(InCard:Break()/RBreak.NBreakLv)
    if RBreak.tbBreakId[tonumber(gdpl)] then
        local tbSkill = {
            CurSkillId = RBreak.tbBreakId[tonumber(gdpl)].SkillId[nBreak],
            PreSkillId = RBreak.tbBreakId[tonumber(gdpl)].SkillId[nBreak+1] or nil
        }
        return tbSkill
    end
end


--- 获取角色突破等级突破材料
---@param InRole UE4.Item Item
---@param InBreakLv interge 角色当前BreakLv
---@return tbMats table 突破材料
function RBreak.GetBreakMats(InItem)
    local MatId = InItem:BreakMatID()
    local nBreak = InItem:Break()+1
    return RBreak.tbBreakMat[MatId][nBreak]
end

--- 获取等级进度
---@param InItem UE4.Item 角色卡
---@return integer 天启等级(1-5)
function RBreak.GetProcess(InItem)
    if InItem then
        local nBreak = math.modf(InItem:Break()/RBreak.NBreakLv)
        return nBreak
    end
    return 1
end


--- 当前天启所有属性(属性详情)
function RBreak.GetBreakAttrs(InItem, InPreview)
    local tbAttrs = {}
    if InItem and InPreview then
        local gdpl = tonumber(InItem:Genre()..InItem:Detail()..InItem:Particular()..InItem:Level())
        local nAttId = RBreak.tbBreakId[gdpl].AttId
        tbAttrs = RBreak.tbBreakGrowth[nAttId][InPreview]
    end
    return tbAttrs
end

--- 获取突破等阶属性
---@param InLv Interge 突破等阶
function RBreak.GetBreakLvAttr(InItem)
    if InItem then
        local gdpl = tonumber(InItem:Genre()..InItem:Detail()..InItem:Particular()..InItem:Level())
        local nAttId = RBreak.tbBreakId[gdpl].AttId
        local nBreak = RBreak.GetProcess(InItem)
        local nBreakLv = InItem:Break()%RBreak.NBreakLv
        return RBreak.tbBreakGrowth[nAttId][nBreak+1][nBreakLv]
    end
end

--- 是否达到最大突破限制等级
function RBreak.IsLimit(InItem)
    local tbMat = RBreak.tbBreakMat[InItem:BreakMatID()]
    if tbMat and InItem and InItem:Break()< #tbMat then
        return false
    end
    return true
end


--- 检查突破材料
function RBreak.CheckBreakMat(InItem)
    local tbBreakItem = RBreak.GetBreakMats(InItem)
    --- 当前材料是突破材料
    if not tbBreakItem then
        print("not consumes")
        return false
    end

    ---当前突破材料至少一种
    if #tbBreakItem < 0 then
       return false
    end

    ---当前突破材料数目足够
    if #tbBreakItem > 0 then
        for i = 1, #tbBreakItem do
            local pItem = tbBreakItem[i]
            local nHaveBreakItem = me:GetItemCount(pItem[1], pItem[2], pItem[3], pItem[4])
            if nHaveBreakItem < tbBreakItem[i][5] then
                return false
            end
        end
    end
    return true
end

--角色突破(被动技能突破)
RBreak.ByBreakCallBack = nil
function RBreak.Req_ByBreak(InItem, InCallBack)
    --- 是否达到突破上限
    if RBreak.IsLimit(InItem) then
        return UI.ShowTip("tip.Limit_Times")
    end

    if not RBreak.CheckBreakMat(InItem) then
        return UI.ShowTip("tip.not_material_for_break")
    end

    local pBreakItem = RBreak.GetBreakMats(InItem)

    local cmd = {
        pId = InItem:Id(),
        nBreakLv = InItem:Break() + 1,
        tbMaterials = pBreakItem,
    }

    RBreak.ByBreakCallBack = InCallBack
    UI.ShowConnection()
    me:CallGS("GirlCard_UpByBreak", json.encode(cmd))
end

s2c.Register("GirlCard_UpByBreak", function(InParam)
    UI.CloseConnection()
    if RBreak.ByBreakCallBack then
        RBreak.ByBreakCallBack(InParam)
        RBreak.ByBreakCallBack = nil
    end
    EventSystem.TriggerTarget(RBreak, RBreak.RoleBreakHandle)
end)

function RBreak.LoadSkillDesConfig()
    local tbConfig = LoadCsv("item/cardbreak/breakskill.txt", 1)
    for _, data in pairs(tbConfig) do
        local GDPL = tonumber(data.Genre..data.Detail..data.Particular..data.Level)
        RBreak.tbBreakId[GDPL] = {}
        local tbSkillId = {}
        for i = 1, 5 do
            tbSkillId[i] = Eval(data['breakskill'..i]) or nil
        end
        RBreak.tbBreakId[GDPL] = {
            SkillId = tbSkillId,
            AttId = tonumber(data.breakgrow or 0),
        }
    end
end

function RBreak.LoadBreakMatConfig()
    local tbMatConfig = LoadCsv("item/cardbreak/break.txt", 1)
    for key, value in ipairs(tbMatConfig) do
        local Id = tonumber(value.ID or 0)
        RBreak.tbBreakMat[Id] = {}
        local tbItemsMats = {}
        for i = 1, RBreak.NBreak do
            local tbMat = {}
            for j = 1, RBreak.NBreakLv do
                local Mats = Eval(value[i..'Items'..j])
                table.insert(RBreak.tbBreakMat[Id],Mats)
                -- table.insert(tbMat,Mats)
            end
            table.insert(tbItemsMats,tbMat)
        end
    end
    -- Dump(RBreak.tbBreakMat)
end

function RBreak.LoadNodeGrowthConfig()
    RBreak.tbBreakGrowth = {}
    local tbGrowthConfig = LoadCsv("item/cardbreak/breaknode.txt", 1)
    for index, tbLine in ipairs(tbGrowthConfig) do
        local Id = tonumber(tbLine.ID)
        local nBreakAtts = {}
        for i = 1, 5 do
            local tbAtts = {}
            for j = 1, 8 do
                local Atts = {}
                Atts = Eval(tbLine[i.."break"..j])
                table.insert(tbAtts,Atts)
            end
            table.insert(nBreakAtts,tbAtts)
        end
        RBreak.tbBreakGrowth[Id] = {}
        RBreak.tbBreakGrowth[Id] = nBreakAtts
    end
    -- Dump(RBreak.tbBreakGrowth[1001][1][1])
end

function RBreak.__Init()
    RBreak.LoadSkillDesConfig()
    RBreak.LoadBreakMatConfig()
    RBreak.LoadNodeGrowthConfig()
end
RBreak.__Init()

return RBreak
