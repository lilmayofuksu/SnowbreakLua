-- ========================================================
-- @File    : uw_role_role.lua
-- @Brief   : 角色展示界面
-- ========================================================

local tbRoleClass = Class("UMG.SubWidget")

tbRoleClass.Obj = nil
tbRoleClass.nTagIdx = -1

function tbRoleClass:Construct()
    BtnAddEvent(self.SelClick, function()
        if self.Obj and self.Obj.Click then
            self.Obj:Click(self.Obj.SelectId)
        end
    end)

    if UE4.UDeviceProfileLibrary.GetDeviceProfileLevel() <= 0 then
        --低端机
        self:SetClipping(UE4.EWidgetClipping.Inherit)
        self.PanelRole1:SetRenderTransformAngle(0.1)
        self.PanelRole2:SetRenderTransformAngle(0.1)
    else
        self:SetClipping(UE4.EWidgetClipping.ClipToBoundsAlways)
        self.PanelRole1:SetRenderTransformAngle(0)
        self.PanelRole2:SetRenderTransformAngle(0)
    end
end

function tbRoleClass:Display(InObj)
    WidgetUtils.Collapsed(self.PanelSelect)
    WidgetUtils.Collapsed(self.ImgLock2)
    WidgetUtils.Collapsed(self.PanelLock)
    WidgetUtils.Collapsed(self.PanelLevel)

    if InObj == nil then
        self:UnLock()
        return
    end

    self.Obj = InObj
    self:UnLockMat(self.Obj.tbUnLockMat)
    self:SetIcon(self.Obj.Icon)
    WidgetUtils.Collapsed(self.Red)
    self:UpdateHP()
    ---显示试玩角色标记
    if not self.Obj.pCard or not self.Obj.pCard:IsTrial() then
        WidgetUtils.Collapsed(self.TrialNode)
        WidgetUtils.Collapsed(self.TrialNode2)
    end
end

function tbRoleClass:SetLevel()
    local sLv = Text('ui.roleup')..self.Obj.nLv
    self.TxtNum:SetText(sLv)
    if self.TxtNum2 then
        self.TxtNum2:SetText(sLv)
    end
end

function tbRoleClass:OnListItemObjectSet(InObj)
    if InObj == nil then
        return
    end
    self.Obj = InObj
    EventSystem.Remove(self.nSelectHandle)
    if self.Obj.SelectChange then
        self.nSelectHandle = EventSystem.OnTarget(self.Obj, self.Obj.SelectChange, function()
            self:OnSelectChange(self.Obj.bSelect)
        end)
    end
    EventSystem.Remove(self.nLevelChangeHandle)
    if self.Obj.LevelChange then
        self.nLevelChangeHandle = EventSystem.OnTarget(self.Obj, self.Obj.LevelChange, function()
            self:SetLevel()
        end)
    end

    self:UnLockMat(self.Obj.tbUnLockMat)
    self:UnLock(self.Obj.nTagLock)
    self:OnSelectChange(self.Obj.bSelect, true)
    self:SetIcon(self.Obj.Icon)
    self:SetLevel()

    self.Obj.funUpdateRedDot = function()
        self:UpdateRedDot()
    end
    if self.Obj.nForm == 1 then
        --刷新红点
        self:UpdateRedDot()
    else
        WidgetUtils.Collapsed(self.Red)
    end

    self.TemplateId = UE4.UItemLibrary.GetTemplateId(self.Obj.Template.Genre,self.Obj.Template.Detail,self.Obj.Template.Particular,self.Obj.Template.Level)
    self.Obj.funUpdateMemberSelected = function()
        if self.Obj.bTowerFormation and self.Obj.bSelect then
            WidgetUtils.HitTestInvisible(self.TowerSelected)
        elseif self.Obj.nForm == 2 and self.Obj.pCard and Formation.IsInTowerFormation(Formation.GetCurLineupIndex(), self.Obj.pCard) then
            WidgetUtils.HitTestInvisible(self.TowerSelected)
        else
            WidgetUtils.Collapsed(self.TowerSelected)
        end
    end
    self.Obj.funUpdateMemberSelected()

    if self.Obj.bTowerFormation then    --爬塔编队中的
        WidgetUtils.Collapsed(self.PanelSelect)
    end

    self:UpdateHP()
    self:ShowOnlineLeader()

    ---显示试玩角色标记
    if not self.Obj.pCard or not self.Obj.pCard:IsTrial() then
        WidgetUtils.Collapsed(self.TrialNode)
        WidgetUtils.Collapsed(self.TrialNode2)
    end
end

function tbRoleClass:UpdateHP()
    if self.Obj.pCard and self.Obj.ShowHP then
        WidgetUtils.HitTestInvisible(self.PanelHp)
        WidgetUtils.HitTestInvisible(self.PanelSlHp)
        local hp, fullhp = RogueLogic.GetHPByCard(self.Obj.pCard)
        if hp <= 0 then
            WidgetUtils.Collapsed(self.Hp)
            WidgetUtils.Collapsed(self.SlHp)
            WidgetUtils.Collapsed(self.HpLow)
            WidgetUtils.Collapsed(self.SlHpLow)
            WidgetUtils.HitTestInvisible(self.PanelDisable)
        else
            local percent = hp / fullhp
            if percent < 0.3 then
                WidgetUtils.Collapsed(self.Hp)
                WidgetUtils.Collapsed(self.SlHp)
                WidgetUtils.HitTestInvisible(self.HpLow)
                WidgetUtils.HitTestInvisible(self.SlHpLow)
                self.HpLow:SetPercent(percent)
                self.SlHpLow:SetPercent(percent)
            else
                WidgetUtils.Collapsed(self.HpLow)
                WidgetUtils.Collapsed(self.SlHpLow)
                WidgetUtils.HitTestInvisible(self.Hp)
                WidgetUtils.HitTestInvisible(self.SlHp)
                self.Hp:SetPercent(percent)
                self.SlHp:SetPercent(percent)
            end
            WidgetUtils.Collapsed(self.PanelDisable)
        end
    else
        WidgetUtils.Collapsed(self.PanelHp)
        WidgetUtils.Collapsed(self.PanelSlHp)
        if Launch.GetType() == LaunchType.BOSS and self.Obj.nForm == 2 and BossLogic.CheckCard(self.TemplateId) then
            WidgetUtils.HitTestInvisible(self.PanelDisable)
            WidgetUtils.HitTestInvisible(self.PanelDisableSl)
        else
            WidgetUtils.Collapsed(self.PanelDisable)
            WidgetUtils.Collapsed(self.PanelDisableSl)
        end
    end
end

function tbRoleClass:UpdateRedDot()
    if self.Obj.pCard and self.Obj.pCard:IsTrial() then
        WidgetUtils.Collapsed(self.Red)
        return
    end
    if self.Obj.ParentUIName == "growth_up" then
        if self.Obj.pCard and RoleCard.CheckCardRedDot(self.Obj.pCard, {3}) then
            WidgetUtils.HitTestInvisible(self.Red)
        else
            WidgetUtils.Collapsed(self.Red)
        end
    elseif self.Obj.ParentUIName == "fashion" then
        WidgetUtils.Collapsed(self.Red)
    else
        if self.Obj.pCard and RoleCard.CheckCardRedDot(self.Obj.pCard, {1, 2}) then
            WidgetUtils.HitTestInvisible(self.Red)
        elseif self.Obj.Template and RoleCard.CheckTemplateRedDot(self.Obj.Template, {0, 1, 2}) then
            WidgetUtils.HitTestInvisible(self.Red)
        else
            WidgetUtils.Collapsed(self.Red)
        end
    end
end

function tbRoleClass:OnDestruct()
    EventSystem.Remove(self.nSelectHandle)
    EventSystem.Remove(self.nLevelChangeHandle)
    EventSystem.Remove(self.GetNewRole)
end

function tbRoleClass:OnSelectChange(bSelect, bFirst)
    if self.Obj.bTowerFormation then    --爬塔编队中的选择
        if bSelect then
            WidgetUtils.HitTestInvisible(self.TowerSelected)
        else
            WidgetUtils.Collapsed(self.TowerSelected)
        end
    else
        if bSelect then
            if self.Obj.SelectId == 0 then
                WidgetUtils.Collapsed(self.ImgLock2)
            end
            self:SetUnselectedPanel(true)
            if bFirst then
                self:PlayAnimation(self.Select, self.Select:GetEndTime())
                self:FlushAnimations()
                WidgetUtils.Collapsed(self.PanelCommon)
            else
                self:UnbindAllFromAnimationFinished(self.Select)
                self:BindToAnimationFinished(self.Select, {self, function()
                    self:UnbindAllFromAnimationFinished(self.Select)
                    WidgetUtils.Collapsed(self.PanelCommon)
                end})
                self:PlayAnimation(self.Select)
            end
            WidgetUtils.HitTestInvisible(self.PanelSelect)

            self:PlayAnimation(self.Repeat, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
            WidgetUtils.Collapsed(self.PanelLock)
            if self.Obj.nTagLock == 2 then
                WidgetUtils.HitTestInvisible(self.Lock2)
                WidgetUtils.Collapsed(self.PanelLevel2)
            else
                WidgetUtils.Collapsed(self.Lock2)
                WidgetUtils.HitTestInvisible(self.PanelLevel2)
            end
            ---显示试玩角色标记
            if self.Obj.pCard and self.Obj.pCard:IsTrial() then
                WidgetUtils.Collapsed(self.TrialNode)
                WidgetUtils.HitTestInvisible(self.TrialNode2)
            end
        else
            self:StopAnimation(self.Repeat)
            local fun = function ()
                self:SetUnselectedPanel(false)
                WidgetUtils.Collapsed(self.PanelSelect)

                if self.Obj.nTagLock == 2 then
                    WidgetUtils.HitTestInvisible(self.PanelLock)
                    WidgetUtils.Collapsed(self.PanelLevel)
                else
                    WidgetUtils.Collapsed(self.PanelLock)
                    WidgetUtils.HitTestInvisible(self.PanelLevel)
                end

                ---显示试玩角色标记
                if self.Obj.pCard and self.Obj.pCard:IsTrial() then
                    WidgetUtils.Collapsed(self.TrialNode2)
                    WidgetUtils.HitTestInvisible(self.TrialNode)
                end
            end
            WidgetUtils.HitTestInvisible(self.PanelCommon)

            self:UnbindAllFromAnimationFinished(self.Select)
            self:BindToAnimationFinished(self.Select, {self, function()
                self:UnbindAllFromAnimationFinished(self.Select)
                fun()
            end})
            self:PlayAnimationReverse(self.Select)
            if bFirst then
                self:SetAnimationCurrentTime(self.Select, self.Select:GetStartTime())
                self:FlushAnimations()
            end
        end
    end
end

function tbRoleClass:SetUnselectedPanel(Select)
    if Select then
        WidgetUtils.Collapsed(self.Image_392)
        WidgetUtils.Collapsed(self.ImgRole)
        WidgetUtils.Collapsed(self.QualityBg)
        WidgetUtils.Collapsed(self.ImgQuality)
        WidgetUtils.Collapsed(self.PanelLevel)
        WidgetUtils.Collapsed(self.ImgWeapon)
        WidgetUtils.HitTestInvisible(self.ImgWeapon2)
        WidgetUtils.Collapsed(self.ImgRole)
    else
        WidgetUtils.HitTestInvisible(self.Image_392)
        WidgetUtils.HitTestInvisible(self.ImgRole)
        WidgetUtils.HitTestInvisible(self.QualityBg)
        WidgetUtils.HitTestInvisible(self.ImgQuality)
        WidgetUtils.HitTestInvisible(self.PanelLevel)
        WidgetUtils.HitTestInvisible(self.ImgWeapon)
        WidgetUtils.Collapsed(self.ImgWeapon2)
        WidgetUtils.HitTestInvisible(self.ImgRole)
    end
end

--- 角色相关:头像，角色品质，武器，克制属性,Icon
function tbRoleClass:SetIcon(InId)
    SetTexture(self.ImgRole, InId, true)
    if self.ImgRoleselect then
        SetTexture(self.ImgRoleselect, InId, true)
    end
    SetTexture(self.Logo, self.Obj.Template.Icon)

    local WeaponTemplateId = self.Obj.DefaultWeaponGPDL
    SetTexture(self.ImgWeapon, Item.WeaponTypeIcon[WeaponTemplateId.Detail] )
    SetTexture(self.ImgWeapon2, Item.WeaponTypeIcon[WeaponTemplateId.Detail] )

    if self.Obj.bUIBoss then
        SetTexture(self.ImgQuality, Item.RoleColor[self.Obj.Template.Color])
    else
        SetTexture(self.ImgQuality, Item.RoleColor2[self.Obj.Template.Color])
        SetTexture(self.ImgQuality2, Item.RoleColor2[self.Obj.Template.Color])
    end

    local  CharacterTemplateId = UE4.UItemLibrary.GetTemplateId(self.Obj.Template.Genre,self.Obj.Template.Detail,self.Obj.Template.Particular,self.Obj.Template.Level)
    local  nTriangleAttribute = UE4.UItemLibrary.GetCharacterAtrributeTemplate(CharacterTemplateId).TriangleType
    -- SetTexture(self.ImgRestraint,Item.RoleTrangleAttr[nTriangleAttribute+1])
end

function tbRoleClass:UnLock(InState)
    --WidgetUtils.Collapsed(self.ImgLock1)
    WidgetUtils.Collapsed(self.ImgLock2)
    WidgetUtils.Collapsed(self.PanelLock)
    WidgetUtils.Collapsed(self.Lock2)
    WidgetUtils.Collapsed(self.PanelWeapon)
    WidgetUtils.Collapsed(self.PanelLevel)
    -- WidgetUtils.Collapsed(self.LvImg)
    if InState == 1 then
        WidgetUtils.SelfHitTestInvisible(self.PanelWeapon)
        WidgetUtils.SelfHitTestInvisible(self.PanelLevel)
        WidgetUtils.SelfHitTestInvisible(self.LvImg)
        self.ImgRole:SetRenderOpacity(1)
        self.ImgRoleselect:SetRenderOpacity(1)
    elseif InState == 2 then
        -- WidgetUtils.SelfHitTestInvisible(self.ImgLock1)
        -- WidgetUtils.SelfHitTestInvisible(self.ImgLock2)
        WidgetUtils.SelfHitTestInvisible(self.PanelLock)
        WidgetUtils.HitTestInvisible(self.Lock2)
        self.ImgRole:SetRenderOpacity(0.5)
        self.ImgRoleselect:SetRenderOpacity(0.5)
    end
end

function tbRoleClass:UnLockMat(InMatAtt)
    self.TextCurr:SetText(InMatAtt.Need)
    self.TextMax:SetText(InMatAtt.N)
    if self.TextCurr_1 then
        self.TextCurr_1:SetText(InMatAtt.Need)
        Color.Set(self.TextCurr_1, InMatAtt.Color)
    end
    if self.TextMax_1 then
        self.TextMax_1:SetText(InMatAtt.N)
    end
    Color.Set(self.TextCurr, InMatAtt.Color)
end


--联机编队进来队长 添加标记
function tbRoleClass:ShowOnlineLeader()
    if Online.GetOnlineId() > 0 then
        local tbCard = Formation.GetCardByIndex(Online.TeamId, 0)
        if self.Obj.SelectId and tbCard and self.Obj.SelectId > 0 and self.Obj.SelectId == tbCard:Id() then
            WidgetUtils.SelfHitTestInvisible(self.FormationLeader)
            return
        end
    end

    WidgetUtils.Collapsed(self.FormationLeader)
end

return tbRoleClass