-- ========================================================
-- @File    : uw_activitytry_skilllist.lua
-- @Brief   : 扭蛋角色试玩 技能界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.ListFactory = self.ListFactory or Model.Use(self)
    WidgetUtils.Collapsed(self.PanelOn)
    BtnClearEvent(self.BtnStory)
    BtnAddEvent(self.BtnStory, function() if self.tbParam.pFunc then self.tbParam.pFunc(self) end end)
end

function tbClass:ShowSkill(tbParam)
    self.tbParam = tbParam
    local bSp = UI.GetUI('TrySkill').bShowSp
    local nSkillId, eType, nLevel = tbParam.nSkillId, tbParam.eType, tbParam.nLevel
    self.pCard = tbParam.pCard
    local sIcon = UE4.UAbilityLibrary.GetSkillIcon(nSkillId)
    if eType == RoleCard.SkillType.PassiveType then
        sIcon = UE4.UAbilityLibrary.GetSkillFixInfoStaticId(nSkillId)
    end
    SetTexture(self.ImgSkillIcon, sIcon)
    self.TxtSkill:SetText(SkillName(nSkillId))
    self.TxtName:SetText(SkillName(nSkillId))
    self:UpdateSkillTag(nSkillId)

    if bSp then
        self.SkillTxt:SetContent(SkillDesc(nSkillId, nil, nLevel))
    else
        self:SkillCD(nSkillId, nLevel)
        local spinesID = UE4.TArray(UE4.int32)
        self.pCard:GetAllSpineNode(spinesID)
        self.SkillTxt:SetContent(SkillDesc(nSkillId, spinesID, nLevel))
        self.TxtPowerIntro:SetText(self:Tagenemegy(eType, true, nSkillId, nLevel))
        if not FunctionRouter.IsOpenById(FunctionType.Nerve) then
            WidgetUtils.Collapsed(self.SPSkill)
        else
            WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.SPSkill, eType == RoleCard.SkillType.NormalSkill
            or eType == RoleCard.SkillType.BigSkill or eType == RoleCard.SkillType.QTESkill)
        end
        self:ShowSkillItems(nSkillId)
    end
    WidgetUtils.Collapsed(self.PanelOn)
end

--刷新技能标签
function tbClass:UpdateSkillTag(SkillID)
    self:DoClearListItems(self.TxtType)
    if not SkillID then return end
    local tbTag = RoleCard.GetSkillTagID(SkillID)
    for _, TagID in ipairs(tbTag) do
        local pObj = self.ListFactory:Create({nID = TagID})
        self.TxtType:AddItem(pObj)
    end
end

function tbClass:SkillCD(nSkillId, nLevel)
    local Info  = UE4.UItemLibrary.GetSkillTemplate(nSkillId)
    local sCD = UE4.UAbilityLibrary.GetMapValueForLevel(Info.CDTimes, nLevel or 1)
    if sCD and sCD > 0 then
        WidgetUtils.HitTestInvisible(self.PanelCD)
        --self.TxtNum:SetText(sCD)
        local v1, v2 = math.modf(sCD)
        if v2==0 then
            self.TxtNum:SetText(v1)
        else
            self.TxtNum:SetText(string.format("%.1f", math.floor(sCD*10 + 0.5)/10))
        end
    else
        WidgetUtils.Collapsed(self.PanelCD)
    end
end

function tbClass:Tagenemegy(eType, bAuto, nSkillId, nLevel)
    if eType == RoleCard.SkillType.BigSkill and bAuto then
        WidgetUtils.HitTestInvisible(self.PanelEnergy)
        local fEnergy = 0
        if self.pCard then
            fEnergy = UE4.UAbilityLibrary.GetSkillCharacterEnergyCost(nSkillId, RoleCard.GetSkillLv(_, nSkillId, self.pCard))
        else
            fEnergy = UE4.UAbilityLibrary.GetSkillCharacterEnergyCost(nSkillId, 1)
        end
        local v1, v2 = math.modf(fEnergy)
        if v2==0 then
            self.TxtNum2:SetText(v1)
        else
            self.TxtNum2:SetText(fEnergy)
        end
        return Text("TxtPowerIntroconsump")
    else
        self.TxtNum2:SetText(self:SkillKillEnergy(nSkillId, nLevel))
        return Text("TxtPowerIntro")
    end
end

function tbClass:SkillKillEnergy(nSkillId, nLevel)
    local strValueArr = Localization.Get("skill_describe." .. nSkillId .. "_energy")
    local OutValue = UE4.UAbilityLibrary.GetSkillValue(strValueArr, nLevel or 1)
    if OutValue:Length() >= 1 and #OutValue:Get(1).StrValue>0 then
        WidgetUtils.HitTestInvisible(self.PanelEnergy)
        return OutValue:Get(1).StrValue
    else
        WidgetUtils.Collapsed(self.PanelEnergy)
        return '/'
    end
end

function tbClass:ShowSkillItems(nSkillId)
    if not self.pCard then return end
    self.ShowSkillList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.ShowSkillList)
    local tbnodeID = RoleCard.tbShowSkills[nSkillId]
    if not tbnodeID then
        return print("SkillId err", nSkillId)
    end
    for _, value in pairs(tbnodeID) do
        if Spine.tbSpineNode[value] then
            local mastID = value%10
            local ID = Spine.tbSpineNode[value][Spine.MaxSubNum].Nodedes
            local Active = self.pCard:GetSpine(mastID, Spine.MaxSubNum)
            self.ShowSkillList:AddItem(self.ListFactory:Create({Id = ID, bActived = Active}))
        end
    end
end

function tbClass:GetSkillNode(pCard)
    if not pCard then return {} end
    local tbNode = {}
    for i = 1, Spine.MaxMastNum do
        local tbInfo = Spine.tbKeyId[pCard:SpineId()][i]
        local SKillIds = Spine.tbSpineNode[tbInfo.SpId][7].Skilfix
        table.insert(tbNode,{Id = SKillIds, bActived = pCard:GetSpine(i, Spine.MaxSubNum)})
    end
    return tbNode
end

return tbClass