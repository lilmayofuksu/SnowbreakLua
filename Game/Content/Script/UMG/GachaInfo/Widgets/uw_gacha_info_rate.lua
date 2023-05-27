-- ========================================================
-- @File    : uw_gacha_info_rate.lua
-- @Brief   : 抽奖概率展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")


 --类别名称
 local tbClassName = {}
 tbClassName[UE4.EItemType.CharacterCard] = Text("ui.character")
 tbClassName[UE4.EItemType.Weapon] = Text("ui.weapon")


 local tbColor = {}
 tbColor[5] = 'F2A73DFF'
 tbColor[4] = 'A15CE5FF'
 tbColor[3] = '4460ECFF'


function tbClass:Construct()
    self.Factory = Model.Use(self)
end

function tbClass:OnActive(nId)
    local tbCfg = Gacha.GetCfg(nId)

    if not tbCfg then return end
    self.tbPoolInfo = self.tbPoolInfo or {}

    self:Calc(tbCfg)

    local tbDisplayInfo = {}

    local nBaseRate = 0
    local nAllNum = 0

    local bRolePool = false

    for nG = 1, 2 do
        local tbInfo = self.tbPoolInfo[nG]
        if tbInfo then
            local sType = tbClassName[nG]
            for i = 5, 1, -1 do
                local info = tbInfo[i]
                local tbParam = {}
                tbParam.Color = tbColor[i] or '4460ECFF'
                tbParam.nColor = i
                if info then
                    local nRate = info.nRate or 0
                    local nPNum = 0
                    local nPRate = 0
                    if i == 5 then
                        nPNum = tbCfg.tbProtectNum[1][1] or 0
                        nPRate = nRate / (1 - UE4.UKismetMathLibrary.MultiplyMultiply_FloatFloat(1 - nRate, nPNum))
                        nAllNum = nAllNum + nPRate
                    elseif i == 4 then
                        nPNum = 10
                        nPRate = nRate / (1 - UE4.UKismetMathLibrary.MultiplyMultiply_FloatFloat(1 - nRate, nPNum))
                        nAllNum = nAllNum + nPRate
                    elseif i == 3 then
                        nPNum = 0
                        nBaseRate = nBaseRate + nRate
                    end

                    tbParam.nRate = nRate
                    tbParam.nPRate = nPRate
                    tbParam.sType = sType
                    tbParam.G = nG

                    tbParam.tbItemInfo = info.tbInfo

                    if nG == 1 then
                        bRolePool = true
                    end

                    table.insert(tbDisplayInfo, tbParam)
                else
                    tbParam.nRate = 0
                    tbParam.nPRate = 0
                    tbParam.sType = sType
                    tbParam.G = nG
                    table.insert(tbDisplayInfo, tbParam)
                end
            end
        end
    end

    for _, param in ipairs(tbDisplayInfo) do
        if param.nColor < 4 then
            local nNewRate = (param.nRate / nBaseRate ) * (1 - nAllNum)
            param.nPRate = nNewRate
        end
    end

    local function GetList(param)
        if param.G == 1 then
            local tb = {nil, nil, nil, self.UpList2, self.UpList1}
            return tb[param.nColor]
        else
            local tb = {nil, nil, self.UpList5, self.UpList4, self.UpList3}
            return tb[param.nColor]
        end
    end

    local function GetText(param)
        local nColor = param.nColor or 3
        if param.G == 1 then
            local tb = {nil, nil, nil, self.RateTxt2, self.RateTxt1}
            return tb[nColor]
        else
            local tb = {nil, nil, self.RateTxt5, self.RateTxt4, self.RateTxt3}
            return tb[nColor]
        end
    end

    local function GetPanel(param)
        if param.G == 1 then
            local tb = {nil, nil, nil, self.PanelTitle2, self.PanelTitle1}
            return tb[param.nColor]
        else
            local tb = {nil, nil, self.PanelTitle5, self.PanelTitle4, self.PanelTitle3}
            return tb[param.nColor]
        end
    end

    local tbTxt = {'ui.TxtGachaRateTip5', 'ui.TxtGachaRateTip5', 'ui.TxtGachaRateTip5', 'ui.TxtGachaRateTip4', 'ui.TxtGachaRateTip3'}


    local GetRateTxt = function(nColor)
        local tbInfo = tbCfg.tbUIPro or {}
        for _, info in pairs(tbInfo) do
            if info[1] and info[2] and info[1] == nColor then
                return info[2] .. '%'
            end
        end
        return ''
    end

    local function SetText(param)
        local txt = GetText(param)
        if txt then
            local rarityCfg = Gacha.GetPoolRarityCfg(tbCfg.nProbability)
            local nRate = 0
            if rarityCfg then
                nRate = rarityCfg.tbRarity[param.nColor] / rarityCfg.nSumWeight
            end
            txt:SetText(Text(tbTxt[param.nColor], string.format('%.2f', nRate * 100) .. '%', GetRateTxt(param.nColor)))
        end
    end

    if bRolePool then
        WidgetUtils.Visible(self.PanelRoles)
    else
        WidgetUtils.Collapsed(self.PanelRoles)
    end

    for _, param in ipairs(tbDisplayInfo) do
        local bEmpty = (CountTB(param.tbItemInfo or {}) <= 0)
        local list = GetList(param)

        local panel = GetPanel(param)

        if list then
            list:ClearChildren()

            table.sort(param.tbItemInfo or {}, function(a, b)
                return (a.nUPTag or 0) > (b.nUPTag or 0)
            end)
            local bRoleFlag = (param.G == 1)

            local sItemPath = bRoleFlag and '/Game/UI/UMG/GachaInfo/Widgets/uw_gacha_info_rate_item.uw_gacha_info_rate_item_C' or '/Game/UI/UMG/GachaInfo/Widgets/uw_gacha_info_rate_weapon.uw_gacha_info_rate_weapon_C'

            if not bEmpty then
                WidgetUtils.SelfHitTestInvisible(list)
                for _, info in pairs(param.tbItemInfo or {}) do
                    local tbParam = {pTemplate = info.pTemplate, nUPTag = info.nUPTag}
                    local pItem = LoadWidget(sItemPath)
                    if pItem then
                        list:AddChild(pItem)
                        pItem:Display(tbParam)
                    end
                end
                SetText(param)
                WidgetUtils.SelfHitTestInvisible(panel)
            else
               WidgetUtils.Collapsed(panel)
            end
        end
       
    end
end


---计算配置表中的配置概率信息, 可考虑优化到Gacha
function tbClass:Calc(tbCfg)
    local tbProbability = {}
    local tbRarity = Gacha.GetPoolRarityCfg(tbCfg.nProbability)
    ---总权重
    local nWeightSum = 0
    for _, nWeight in ipairs(tbRarity.tbRarity) do
        nWeightSum = nWeightSum + nWeight
    end
    ---权重比
    for nRarity, nWeight in ipairs(tbRarity.tbRarity) do
        tbProbability[nRarity] = nWeight / nWeightSum
    end


    local tbWeightInfo = {}

    ---稀有度对应的权重
    for _, sPool in ipairs(tbCfg.tbPool) do
        local tbCfg = Gacha.GetPoolCfg(sPool)
        for _, tb in pairs(tbCfg) do
            local pTemp = UE4.UItem.FindTemplate(table.unpack(tb.tbGDPL))
            local g = pTemp.Genre
            tbWeightInfo[g] = tbWeightInfo[g] or {}

            local tbData = tbWeightInfo[g]

            local nColor = pTemp.Color
            tbData[nColor] = tbData[nColor] or {nRarity = tb.nRarity, nRate = tbProbability[tb.nRarity],  tbInfo = {}}

            local bInsert = true
            for _, tbInfo in ipairs(tbData[nColor].tbInfo) do
                if CompareList(tbInfo.tbGDPL, tb.tbGDPL) then
                    bInsert = false
                    break
                end
            end
            
            if bInsert then
                table.insert(tbData[nColor].tbInfo, {tbGDPL = tb.tbGDPL, pTemplate = pTemp, nUPTag = tb.nUpTag})
            end
        end
    end
    self.tbPoolInfo = tbWeightInfo
end

return tbClass
