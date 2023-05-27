-- ========================================================
-- @File    : uw_rolebreaklv.lua
-- @Brief   : 职级界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    self.tbTitle = {
        "ui.TxtRolebreaklv1",
        "ui.TxtRolebreaklv2",
        "ui.TxtRolebreaklv3",
    }
    self.tbBarValue = {0.21, 0.46, 0.73, 1}

    BtnAddEvent(self.BtnGo, function ()
        if self.CurCard and not self.CurCard:IsTrial() then
            RoleCard.ProLevelPromote(self.CurCard:Id(), function()
                if self.SkillId then
                    UI.Open("ProLevelTip", self.SkillId)
                end
                self:UpdateProLevelPanel()
            end)
        end
    end)
end

function tbClass:OnActive(pRole, InForm, Click, pCard)
    if pCard then
        self.CurTemplate = UE4.UItem.FindTemplateForID(pCard:TemplateId())
        self.CurCard = pCard
    else
        self.CurTemplate = pRole
        self.CurCard = RoleCard.GetItem({pRole.Genre,pRole.Detail,pRole.Particular,pRole.Level})
    end

    --- 角色展示模型
    RoleCard.ModifierModel(self.CurTemplate, self.CurCard, PreviewType.role_synchronize, UE4.EUIWidgetAnimType.Role_Break)

    self:UpdateProLevelPanel()
end

function tbClass:UpdateProLevelPanel()
    local key = ""
    local ProLevel = 0
    if self.CurCard then
        ProLevel = self.CurCard:ProLevel()
        key = table.concat({self.CurCard:Genre(), self.CurCard:Detail(), self.CurCard:Particular(), self.CurCard:Level()}, "-")
    elseif self.CurTemplate then
        key = table.concat({self.CurTemplate.Genre, self.CurTemplate.Detail, self.CurTemplate.Particular, self.CurTemplate.Level}, "-")
    end
    local Data = RoleCard.tbProLevelData[key]
    if not Data then return end

    self.Bar:SetPercent(self.tbBarValue[ProLevel+1])
    if ProLevel >= 3 then
        WidgetUtils.Collapsed(self.Info)
        WidgetUtils.Collapsed(self.BtnGo)
    else
        WidgetUtils.HitTestInvisible(self.Info)
        self.SkillId = Data.tbSkillID[ProLevel+1][1]
        self.TxtName:SetText(Text(self.tbTitle[ProLevel+1]))
        local sIcon = UE4.UAbilityLibrary.GetSkillFixInfoStaticId(self.SkillId)
        SetTexture(self.ImgSkill, sIcon)
        self:UpdateCondition(Data.tbCondition[ProLevel+1])
    end

    for i = 1, 3 do
        local Widget = self["Item"..i]
        if Widget then
            local info = {
                Index = i,
                CurCard = self.CurCard,
                tbSkillID = Data.tbSkillID[i],
                tbCondition = Data.tbCondition[i],
            }
            Widget:UpdatePanel(info)
        end
    end
end

function tbClass:UpdateCondition(tbCondition)
    if not tbCondition then return end
    local bAllOk = true
    for i = 1, 3 do
        local Widget = self["State"..i]
        if Widget then
            local con = tbCondition[i]
            if con and #con > 0 then
                WidgetUtils.HitTestInvisible(Widget)
                local bOk, Des = Condition.CheckCondition(con)
                if Des then
                    self["Text"..i]:SetText(Des)
                end
                if bOk then
                    self["Text"..i]:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0.057805, 0.040915, 0.53948, 1))
                else
                    bAllOk = false
                    self["Text"..i]:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0.045186, 0.046665, 0.064803, 0.8))
                end
            else
                WidgetUtils.Collapsed(Widget)
            end
        end
    end

    if bAllOk and self.CurCard and not self.CurCard:IsTrial() then
        WidgetUtils.Visible(self.BtnGo)
    else
        WidgetUtils.Collapsed(self.BtnGo)
    end
end

function tbClass:UpdateRedDot()
    if RoleCard.CheckCardRedDot(self.CurCard, {3}) then
        --WidgetUtils.HitTestInvisible(self.RedPoint)
    else
        --WidgetUtils.Collapsed(self.RedPoint)
    end
end

function tbClass:OnDisable()
end

function tbClass:OnClose()
end

return tbClass
