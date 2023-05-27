-- ========================================================
-- @File    : uw_activitytry_skill.lua
-- @Brief   : 扭蛋角色试玩 技能界面
-- ========================================================

local tbClass = Class('UMG.BaseWidget')
tbClass.CardItemPath = "/Game/UI/UMG/Role/Widgets/uw_role_role_data.uw_role_role_data"
tbClass.tbActiveType = {
    RoleCard.SkillType.NormalSkill,
    RoleCard.SkillType.NormalSkill,
    RoleCard.SkillType.BigSkill,
    RoleCard.SkillType.QTESkill,
}
tbClass.tbQuality = {1700001, 1700002, 1700003, 1700004, 1700005, 1700006}

function tbClass:OnInit()
    self.ListFactory = self.ListFactory or Model.Use(self)
    BtnAddEvent(self.BtnClose, function() UI.Close(self) end)
    self.CurSelect = 1
    self.bShowSp = false

    self.tbSkillWidget, self.tbSpSkillWidget = {}, {}
end

function tbClass:OnOpen()
    self:DoClearListItems(self.RightList)
    self.RightList:AddItem(self.ListFactory:Create({'ui.TxtRoleSkill.title', true, function(selectTab) self:ChangeTab(false, selectTab) end}))
    if FunctionRouter.IsOpenById(FunctionType.RoleBreak) then
        self.RightList:AddItem(self.ListFactory:Create({'ui.TxtRoleSpSkill.title', false, function(selectTab) self:ChangeTab(true, selectTab) end}))
    end

    RuntimeState.ChangeInputMode(true)
    UE4.UUIGameInstanceSubsystem.SwitchMouseEventNotice()

    self:DoClearListItems(self.RoleList)
    local pCardItem = LoadClass(self.CardItemPath)
    local formation = Formation.GetCurrentLineup()
    if formation then
        local cards = formation:GetCards()
        local tbCard = {}
        for i = 1, cards:Length() do
            table.insert(tbCard, cards:Get(i))
        end
        self.pCard = tbCard[1]
        self.pTemplate = UE4.UItem.FindTemplateForID(self.pCard:TemplateId())
        for key, card in ipairs(tbCard) do
            local CardItem = NewObject(pCardItem, self, nil)
            local bSelect = false
            if self.pCard and card:Id() == self.pCard:Id() then
                self.SwitchRoleObj = CardItem
                self.CurSelect = key
                bSelect = true
            end
            CardItem:Init(key, bSelect, nil, function(Target, InSelectId)
                self.pCard = card
                self.pTemplate = UE4.UItem.FindTemplateForID(card:TemplateId())
                self:OnSwitchRoleChange(CardItem)
            end, card)
            CardItem.nForm = self.Form
            CardItem.nTemplateId = card:TemplateId()
            self.RoleList:AddItem(CardItem)
        end
        self.RoleList:ScrollIndexIntoView(self.CurSelect-1)
    end
    self:ShowInfo(self.pCard)
end

function tbClass:OnSwitchRoleChange(InObj)
    if self.SwitchRoleObj == InObj then return end

    if self.SwitchRoleObj then
        self.SwitchRoleObj:SetSelect(false)
    end

    self.SwitchRoleObj = InObj
    if self.SwitchRoleObj then
        self.SwitchRoleObj:SetSelect(true)
        local ActiveWidget = self.RoleList:GetItemAt(InObj.ShowPos-1)
        self.CurSelect = InObj.Index
        if ActiveWidget then
            self:ShowInfo(self.pCard)
        end
    end
end

function tbClass:ShowInfo(pCard)
    local I18N = pCard:I18N();
    self.TxtName:SetText(Text(I18N))
    self.TxtDesc:SetText(Text(I18N..'_des'))
    self.TxtIntro:SetText(Text(I18N..'_title'))

    local Mat = self.ImgRole:GetDynamicMaterial()
    if Mat then
        Mat:SetTextureParameterValue("Image", GetTexture(self.ImgRole, pCard:Icon()))
    end

    SetTexture(self.ImgQuality, self.tbQuality[pCard:Color()])
    self.Quality:Set(pCard:Color())
    self:ChangeTab()
end

function tbClass:ChangeTab(bShowSp, selectTab)
    self.SkillWidget = nil
    self.bShowSp = bShowSp == nil and self.bShowSp or bShowSp
    if self.SelectTab then
        WidgetUtils.Collapsed(self.SelectTab.Group_on)
        WidgetUtils.SelfHitTestInvisible(self.SelectTab.Group_off)
    end
    if selectTab then
        WidgetUtils.SelfHitTestInvisible(selectTab.Group_on)
        WidgetUtils.Collapsed(selectTab.Group_off)
        self.SelectTab = selectTab
    end
    -- self.Tab1:SelectChange(not self.bShowSp)
    -- self.Tab2:SelectChange(self.bShowSp)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.PanelSkillAll, not self.bShowSp)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.PanelSpSkillAll, self.bShowSp)
    if self.bShowSp then
        self:ShowSpSkills()
    else
        self:ShowNormalSkills()
    end
end

function tbClass:ShowNormalSkills()
    for _, widget in ipairs(self.tbSkillWidget) do WidgetUtils.Collapsed(widget) end
    self.SkillWidget = nil
    local ASkills = RoleCard.GetItemShowSkills(self.pTemplate)
    if not ASkills then return end
    local idx = 1
    for i = 1, 4 do
        if ASkills[i] and ASkills[i] > 0 then
            local tb = {
                nSkillId = ASkills[i] or 0,
                eType = self.tbActiveType[i],
                nLevel = RoleCard.GetSkillLv(self.pTemplate, ASkills[i] or 0, self.pCard),
                pCard = self.pCard,
                pFunc = function(widget) self:OnClickSkill(widget) end,
            }

            local widget = self.tbSkillWidget[idx] or LoadWidget("/Game/UI/UMG/Activitytry/Widgets/uw_activitytry_skilllist.uw_activitytry_skilllist_C")
            self.tbSkillWidget[idx] = self.tbSkillWidget[idx] or widget
            WidgetUtils.SelfHitTestInvisible(widget)
            self.SkillList:AddChild(widget)
            widget:ShowSkill(tb)
            idx = idx + 1
        end
    end
end

function tbClass:ShowSpSkills()
    for _, widget in ipairs(self.tbSpSkillWidget) do WidgetUtils.Collapsed(widget) end
    self.SkillWidget = nil
    local nId = tonumber(self.pTemplate.Genre..self.pTemplate.Detail..self.pTemplate.Particular..self.pTemplate.Level)
    local function tbSkills(InIdx)
        if RBreak.tbBreakId[nId] and RBreak.tbBreakId[nId].SkillId[InIdx] then
            return RBreak.tbBreakId[nId].SkillId[InIdx][1]
        else
            return nil
        end
    end
    local idx = 1
    for i = 1, 5 do
        local nSkillId = tbSkills(i)
        local nLevel = 1
        if nSkillId then
            if i == 4 then
                local tbLevelFix = UE4.UAbilityComponentBase.K2_GetSkillFixInfoStatic(nSkillId).SkillLevelFixMap:ToTable()
                for FixID in pairs(tbLevelFix) do
                    nLevel = RoleCard.GetSkillLv(self.pTemplate, FixID)
                    break
                end
                if self.pCard and self.pCard:Break() / RBreak.NBreakLv < 4 then
                    nLevel = nLevel + 2
                end
            end
            local tb = {
                nSkillId = nSkillId,
                eType = RoleCard.SkillType.PassiveType,
                nLevel = nLevel,
                pCard = self.pCard,
                pFunc = function(widget) self:OnClickSkill(widget) end,
            }

            local widget = self.tbSpSkillWidget[idx] or LoadWidget("/Game/UI/UMG/Activitytry/Widgets/uw_activitytry_spskilllist.uw_activitytry_spskilllist_C")
            self.tbSpSkillWidget[idx] = self.tbSpSkillWidget[idx] or widget
            WidgetUtils.SelfHitTestInvisible(widget)
            self.SpSkillList:AddChild(widget)
            widget:ShowSkill(tb)
            idx = idx + 1
        end
    end
end

function tbClass:OnClickSkill(widget)
    if self.SkillWidget == widget then
        WidgetUtils.Collapsed(widget.PanelOn)
        self.SkillWidget = nil
    else
        if self.SkillWidget then
            WidgetUtils.Collapsed(self.SkillWidget.PanelOn)
        end
        if widget then
            WidgetUtils.SelfHitTestInvisible(widget.PanelOn)
            self.SkillWidget = widget
        end
    end
end

return tbClass