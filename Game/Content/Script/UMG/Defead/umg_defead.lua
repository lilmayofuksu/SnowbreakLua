-- ========================================================
-- @File    : umg_defead.lua
-- @Brief   : 战斗失败界面
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.ReturnBtn, function()
        Launch.End()
    end)

    BtnAddEvent(self.ReFightBtn, function()
        Launch.Again()
    end)

    self.ListFactory = self.ListFactory or Model.Use(self)
    self:DoClearListItems(self.ListWarn)
end

function tbClass:OnOpen()
    --Audio.PlaySounds(3012)
    local nType = Launch.GetType()
    local cfg = Launch.GetLevelConf()
    self.TxtNum:SetText("")
    self.TxtLevelName:SetText("")
    if nType == LaunchType.CHAPTER or nType == LaunchType.ROLE or nType == LaunchType.DAILY then
        if cfg then
            self.TxtNum:SetText(GetLevelName(cfg))
            self.TxtLevelName:SetText(Text(cfg.sFlag))
        end
    elseif nType == LaunchType.TOWER then
        self.TxtLevelName:SetText(Text("climbtower.name", ClimbTowerLogic.GetNowLayer()))
    end
    if cfg and (not cfg.nTeamRuleID or cfg.nTeamRuleID == 0) and nType ~= LaunchType.BOSS then
        self:ShowTips(cfg)
    end
    UE4.ULevelLibrary.DestroyAllCharacter(GetGameIns());
end

function tbClass:ShowTips(levelConf)
    self:DoClearListItems(self.ListWarn)
    if levelConf.nTeamRuleID then return end
    if not levelConf.GetRecommendPowerId then return end
    local powerId = levelConf:GetRecommendPowerId()
    local tbRecommendFormation = ItemPower.tbRecommandPower[powerId]
    if not tbRecommendFormation then return end

    WidgetUtils.SelfHitTestInvisible(self.ListWarn)
    local tbFormation = Formation.GetCurrentLineup()
    local memberCount = 0
    local cardLevelAvg, weaponLevelAvg, supportLevelAvg, minSupportColor = 0, 0, 0, 0
    local tbSpineNum, tbSupportNum, tbSupportSuit, tbProLevel, tbCardBreak = {}, {}, {}, {}, {}
    for _, member in pairs(tbFormation.tbMember) do
        if not member:IsNone() then
            local pCard = member:GetCard()
            memberCount = memberCount + 1
            -- 角色等级 神经 同步率 突破
            cardLevelAvg = cardLevelAvg + pCard:EnhanceLevel()
            local allNode = pCard:GetAllActiveSpineNode(true)
            table.insert(tbSpineNum, allNode:Length())
            table.insert(tbProLevel, pCard:ProLevel())
            table.insert(tbCardBreak, pCard:Break())

            -- 武器等级
            local pWeapon = pCard:GetSlotWeapon()
            if pWeapon then
                weaponLevelAvg = weaponLevelAvg + pWeapon:EnhanceLevel()
            end

            -- 后勤等级 套装
            local supporterCards = pCard:GetSupporterCards()
            table.insert(tbSupportNum, supporterCards:Length())
            local tbSuit = {}
            for i = 1, supporterCards:Length() do
                local pSupporterCard = supporterCards:Get(i)
                if minSupportColor == 0 or pSupporterCard:Color() < minSupportColor then
                    minSupportColor = pSupporterCard:Color()
                end
                supportLevelAvg = supportLevelAvg + pSupporterCard:EnhanceLevel()
                tbSuit[pSupporterCard:Particular()] = (tbSuit[pSupporterCard:Particular()] or 0) + 1
            end
            local maxSuit = 0
            for _, suitNum in pairs(tbSuit) do
                if suitNum > maxSuit then maxSuit = suitNum end
            end
            table.insert(tbSupportSuit, maxSuit)
        end
    end

    table.sort(tbSpineNum, function(a, b) return a > b end)
    table.sort(tbSupportSuit, function(a, b) return a > b end)
    table.sort(tbProLevel, function(a, b) return a > b end)
    table.sort(tbCardBreak, function(a, b) return a > b end)
    table.sort(tbSupportNum, function(a, b) return a > b end)

    local supportNum = 0
    for _, num in ipairs(tbRecommendFormation.tbSupportNum) do supportNum = supportNum + num end

    cardLevelAvg = cardLevelAvg / memberCount
    weaponLevelAvg = weaponLevelAvg / memberCount
    supportLevelAvg = supportLevelAvg / supportNum

    local tbTips = {}
    if memberCount < tbRecommendFormation.nCardNum then             -- 角色卡数量不足
        table.insert(tbTips, 'ui.DefeatText1')
    end
    for i, num in ipairs(tbRecommendFormation.tbSupportNum) do      -- 后勤数量不足
        if (tbSupportNum[i] or 0) < num then
            table.insert(tbTips, 'ui.DefeatText2')
            break
        end
    end
    if cardLevelAvg < tbRecommendFormation.nCardLevel then          -- 角色等级不足
        table.insert(tbTips, 'ui.DefeatText3')
    end
    if weaponLevelAvg < tbRecommendFormation.nWeaponLevel then      -- 武器等级不足
        table.insert(tbTips, 'ui.DefeatText4')
    end
    if supportLevelAvg < tbRecommendFormation.nSupportLevel then    -- 后勤等级不足
        table.insert(tbTips, 'ui.DefeatText5')
    end

    for i, suit in ipairs(tbRecommendFormation.tbSupportSuit) do    -- 后勤套装不足
        if (tbSupportSuit[i] or 0) < suit then
            table.insert(tbTips, 'ui.DefeatText6')
            break
        end
    end

    if minSupportColor < tbRecommendFormation.nSupportColor then    -- 后勤稀有度不足
        table.insert(tbTips, 'ui.DefeatText7')
    end

    for i, nodeNum in ipairs(tbRecommendFormation.tbNodeNum) do     -- 神经激活不足
        if (tbSpineNum[i] or 0) < nodeNum then
            table.insert(tbTips, 'ui.DefeatText8')
            break
        end
    end

    for i, prolevel in ipairs(tbRecommendFormation.tbProLevel) do   -- 同步率不足
        if (tbProLevel[i] or 0) < prolevel then
            table.insert(tbTips, 'ui.DefeatText9')
            break
        end
    end

    for i, cardbreak in ipairs(tbRecommendFormation.tbCardBreak) do  -- 天启不足
        if (tbCardBreak[i] or 0) < cardbreak then
            table.insert(tbTips, 'ui.DefeatText10')
            break
        end
    end

    if #tbTips > 0 then
        for i, v in pairs(tbTips) do
            if i <= 4 then self.ListWarn:AddItem(self.ListFactory:Create({v})) end
        end
    else
        self.ListWarn:AddItem(self.ListFactory:Create({'ui.DefeatText11'}))
    end
end

function tbClass:CanEsc()
    return false
end

return tbClass
