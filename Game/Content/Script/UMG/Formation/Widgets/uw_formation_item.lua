-- ========================================================
-- @File    : uw_formation_item.lua
-- @Brief   : 编队item
-- ========================================================
---@class tbClass : UUserWidget
---@field TileLimit UTileView
---@field Index Integer
local tbClass = Class("UMG.SubWidget")

--三角属性ID
tbClass.TrangleAttr = {
    1700092,        -- 生体属性
    1700091,        -- 精神属性
    1700093,        -- 构造属性
}


function tbClass:Construct()
    self.ListFactory = Model.Use(self)
    self.isCanEditFormation = GuideLogic.IsCanEditFormation()
    self:DoClearListItems(self.TileLimit)
end

function tbClass:OnDestruct()
    if self.EventHandel then
        EventSystem.Remove(self.EventHandel)
    end
end

function tbClass:OnMouseButtonUp(MyGeometry, InTouchEvent)
    self:OnClick()
    return UE4.UWidgetBlueprintLibrary.Handled()
end

function tbClass:OnTouchEnded(MyGeometry, InTouchEvent)
    self:OnClick()
    return UE4.UWidgetBlueprintLibrary.Handled()
end

---点击处理
function tbClass:OnClick()
    Audio.PlaySounds(3005)
    if not self.isCanEditFormation then return end
    if self.GuideEvent and GuideLogic.IsGuiding() then self.GuideEvent:Broadcast() end
    Formation.SetMemberPos(self.Index)
    if Formation.GetCurLineupIndex() == RogueLogic.TeamId then
        UI.SafeOpen("Role", 2, self.pCard, RogueLogic.GetAllCharacter(), true)
    else
        if self:IsTrail() then
            local tbCards = self.TeamRule:GetCardList()
            local pSelectCard = self.pCard or tbCards[1]
            if pSelectCard then
                UI.SafeOpen("Role", 6, pSelectCard, tbCards)
            else
                print('not role')
            end
        else
            UI.SafeOpen("Role", 2, self.pCard, me:GetCharacterCards():ToTable())
        end
    end
end

function tbClass:Init()
    local nLevelID = nil
    local pUI = UI.GetUI('Formation')
    if pUI then
        nLevelID = pUI.nLevelID
    end

    self.TeamRule = TeamRule.GetPosRule(self.Index)

    if not self.TeamRule then
        WidgetUtils.Visible(self)
        WidgetUtils.Collapsed(self.TIps)
        WidgetUtils.Collapsed(self.TileLimit)
    else
        local Member = Formation.GetMember(self.Index)

        if self.TeamRule:IsDisable() then
            if Member then
                Member:SetCard(nil)
            end
            WidgetUtils.Collapsed(self)
            return
        end
        ---试玩角色处理
        local pc = nil
        if self.TeamRule.bSet then
            pc = Formation.GetCardByIndex(Formation.TRIAL_INDEX, self.Index)
        else
            pc = TeamRule.GetSaveCard(nLevelID, self.Index)
            if not pc then
                pc = self.TeamRule:GetAutoAddCard()
            end
        end


        if Member then
            Member:SetCard(pc)
            if pc then
                TeamRule.CacheAddCard(pc)
            end
        end
        self.TeamRule.bSet = true
        WidgetUtils.Visible(self)
    end
    self:ShowMemberInfo()
end

---显示队员信息
function tbClass:ShowMemberInfo()
    local Member = Formation.GetMember(self.Index)
    self:Update()
    EventSystem.Remove(self.EventHandel)

    if Member then
        Formation.UpdateModel(self.Index, Member:GetUID())
    end
    self.EventHandel = EventSystem.OnTarget(Member, 'DATA_CHANGE_EVENT', function() self:Update() end)
end

---是否试玩
function tbClass:IsTrail()
    return self.TeamRule and self.TeamRule:IsOpenTrail() or false
end

---获取限制信息
function tbClass:GetLimitInfo()
    if self.TeamRule == nil then return false end
    if self.pCard == nil then return false end

    local pWeapon = self.pCard:GetSlotWeapon()
    if pWeapon then
        for _, type in ipairs(self.TeamRule.tbBanWeapon or {}) do
            if pWeapon:Detail() == type then
               return true, string.format("%s", Text(self.pCard:I18N()))
            end
        end
    end
    return false
end

---更新显示
---@param InCard UCharacterCard
function tbClass:Update(InCard)
    WidgetUtils.Collapsed(self.Try)
    if InCard == nil then
        local Member = Formation.GetMember(self.Index)
        if Member then InCard = Member:GetCard() end
    end
    self.pCard = InCard
    WidgetUtils.Collapsed(self.Captain)

    if InCard then
        local  InCardID = UE4.UItemLibrary.GetTemplateId(InCard:Genre(),InCard:Detail(),InCard:Particular(),InCard:Level())
        WidgetUtils.SelfHitTestInvisible(self.Role)
        WidgetUtils.Collapsed(self.NoneRole)
        self.Name:SetText(Text(InCard:I18N()))
        self.TxtLevel:SetText(InCard:EnhanceLevel())
        if self.Index == 0 then
            WidgetUtils.SelfHitTestInvisible(self.Captain)
        end
        WidgetUtils.Collapsed(self.New)
        local tbQTESkills = UE4.UItemLibrary.GetCharacterAtrributeTemplate(InCardID).QTESkillIDs:ToTable()
        local bAsStaySkill =  UE4.UAbilityComponentBase.K2_GetSkillInfoStatic(tbQTESkills[1]).bAsStaySkill
        ---QTE释放条件
        local tbQTECastCondition = UE4.UAbilityComponentBase.K2_GetSkillInfoStatic(tbQTESkills[1]).CastCondition:ToTable()
        --local   = nil
        self:ShowQTECastCondition(tbQTECastCondition)
        --local  nId = tonumber(InCard:Genre()..InCard:Detail()..InCard:Particular()..InCard:Level())
        --local SkillID = RBreak.tbBreakId[nId].SkillId[1][1]
        if bAsStaySkill then
            Color.SetTextColor(self.Image,'#00A8FF66' )
            ---强袭
        else
            Color.SetTextColor(self.Image,'#FFFFFF66' )
            ---闪击
        end
        self:SetInfoPop(InCard)
    else
        ---红点提示
        if Formation.HasNewCardTip(self.Index) then
            WidgetUtils.HitTestInvisible(self.New)
        else
            WidgetUtils.Collapsed(self.New)
        end

        if self.isCanEditFormation then
            WidgetUtils.SelfHitTestInvisible(self.NoneRole)
        else
            WidgetUtils.Collapsed(self.NoneRole)
            WidgetUtils.Collapsed(self.New)
        end
        WidgetUtils.Collapsed(self.Role)
        WidgetUtils.Collapsed(self.TIps)
    end

    ---显示限制信息
    if self.TeamRule then
        if self.TeamRule:IsUseSelfCard() == false then
            WidgetUtils.Collapsed(self.New)
        end
        WidgetUtils.SelfHitTestInvisible(self.TileLimit)
        self:DoClearListItems(self.TileLimit)
        ---武器限制信息
        if self.pCard then
            local pWeapon = self.pCard:GetSlotWeapon()
            if pWeapon then
                for _, nType in ipairs(self.TeamRule.tbBanWeapon or {}) do
                    if pWeapon:Detail() == nType then
                        local tbParam = { bLimit = true , nId = nType }
                        local pObj = self.ListFactory:Create(tbParam)
                        self.TileLimit:AddItem(pObj)
                    end
                end 
            end
            if self.pCard:IsTrial() then
                WidgetUtils.HitTestInvisible(self.Try)
            end

            if self.TileLimit:GetNumItems() > 0 then
                WidgetUtils.SelfHitTestInvisible(self.TIps)
            else
                if not self:IsTrail() then
                    WidgetUtils.Collapsed(self.TIps)
                end
            end
        else
            for _, v in ipairs(self.TeamRule.tbBanWeapon or {}) do
                local tbParam = { bLimit = true , nId = v }
                local pObj = self.ListFactory:Create(tbParam)
                self.TileLimit:AddItem(pObj)
            end
        end
    end

    self:UpdatePanelHp()
end

---更新位置
function tbClass:UpdatePos()
    if not self:IsVisible() then return end
    self.WorldPos = self.WorldPos or Formation.GetPos(self.Index)
    if self.WorldPos then
        local ScreenPos = UE4.FVector2D()
        UE4.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(self:GetOwningPlayer(), self.WorldPos, ScreenPos, true)
        local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self)
        local MakePos = UE4.FVector2D()
        MakePos.Y = ScreenPos.Y - 450
        MakePos.X = ScreenPos.X
        Slot:SetPosition(MakePos)
    else
    end
end

---拖拽处理
function tbClass:DropChange(Target)
    if not self.isCanEditFormation then return end

    if self.TeamRule and self.TeamRule:CanIn(Target.pCard) == false then
        UI.ShowTip('tip.exchange_conditions_not_met')
        return
    end

    if Target.TeamRule and Target.TeamRule:CanIn(self.pCard) == false then
        UI.ShowTip('tip.exchange_conditions_not_met')
        return
    end

    Formation.ChangePos(Formation.GetCurLineupIndex(), self.Index, Target.Index)
end

---设置编队是否能编辑
function tbClass:SetCanEditFormation(isEdit)
    self.isCanEditFormation = isEdit
    local InCard = Formation.GetMember(self.Index):GetCard()
    if InCard then return end
    if self.isCanEditFormation then
        WidgetUtils.SelfHitTestInvisible(self.NoneRole)
    else
        WidgetUtils.Collapsed(self.NoneRole)
        WidgetUtils.Collapsed(self.New)
    end
end

---设置QTE触发条件显示
---@param tbConditionSetting FConditionSetting 
function tbClass:ShowQTECastCondition(tbConditionSetting)
    if tbConditionSetting[1] and tbConditionSetting[1].ConditionsInfo:ToTable()[1] then
        local ConditionTypeSoftPath = tbConditionSetting[1].ConditionsInfo:ToTable()[1].ConditionTypePath
        local ConditionTypePath =  UE4.UKismetSystemLibrary.BreakSoftClassPath(ConditionTypeSoftPath)
        local ConditionTypeClass = UE4.UClass.Load(ConditionTypePath)
        local nIcoID=0
        if ConditionTypeClass:GetName() == "ApplyHit_HitType_C" then ---追击或者斩杀
            local sParam4 = tbConditionSetting[1].ConditionsInfo:ToTable()[1].Param4.ParamValue
            if sParam4 == "全" then
                nIcoID = 1300100    ---追击
            else
                nIcoID = 1300104    ---斩杀
            end
        elseif ConditionTypeClass:GetName() == "Condition_CharacterState_C" then nIcoID = 1300101 ---守护
        elseif ConditionTypeClass:GetName() == "Condition_Friend_SkillCast_C" then  nIcoID = 1300102 ---连续
        elseif ConditionTypeClass:GetName() == "Condition_ReloadBullet_C" then  nIcoID = 1300103  ---精械
        end
        if nIcoID ~= 0 then
            SetTexture(self.IconQTE2,nIcoID)
        end
    end
end

---设置InfoPop子控件中的信息
function tbClass:SetInfoPop(pCard)
    if pCard:ProLevel() == 0 then
        WidgetUtils.Collapsed(self.InfoPop.TxtContent)
        WidgetUtils.Collapsed(self.InfoPop.Title)
        WidgetUtils.HitTestInvisible(self.InfoPop.ImgLock)
        WidgetUtils.HitTestInvisible(self.InfoPop.TxtLock)
    else
        WidgetUtils.Collapsed(self.InfoPop.ImgLock)
        WidgetUtils.Collapsed(self.InfoPop.TxtLock)
        WidgetUtils.HitTestInvisible(self.InfoPop.TxtContent)
        WidgetUtils.HitTestInvisible(self.InfoPop.Title)
        local ArrayID = RoleCard.GetProLevelSkillID(self.pCard)
        if ArrayID and ArrayID:Length() > 0 then
            local id = ArrayID:Get(1)
            self.InfoPop.TxtContent:SetContent(SkillDesc(id))
            self.InfoPop.TxtTitle:SetText(SkillName(id))
        end
    end
end

---血量显示
function tbClass:UpdatePanelHp()
    if Formation.GetCurLineupIndex() == RogueLogic.TeamId and self.pCard then
        WidgetUtils.HitTestInvisible(self.PanelHp)
        local HP, FullHp = RogueLogic.GetHPByCard(self.pCard)
        if HP == 0 then
            WidgetUtils.Collapsed(self.Hp)
            WidgetUtils.Collapsed(self.HpLow)
        else
            local percent = HP / FullHp
            if percent < 0.3 then
                WidgetUtils.Collapsed(self.Hp)
                WidgetUtils.HitTestInvisible(self.HpLow)
                self.HpLow:SetPercent(percent)
            else
                WidgetUtils.Collapsed(self.HpLow)
                WidgetUtils.HitTestInvisible(self.Hp)
                self.Hp:SetPercent(percent)
            end
        end
    else
        WidgetUtils.Collapsed(self.PanelHp)
    end
end

return tbClass
