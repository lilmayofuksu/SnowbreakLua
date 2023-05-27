-- ========================================================
-- @File    : uw_role_formation.lua
-- @Brief   : 选择角色进入编队
-- ========================================================
local tbClass = Class("UMG.SubWidget")
function tbClass:Construct()
    ---页面对应功能类型
    self.tbPage2FunType = {
        [2] = FunctionType.WeaponReplace,
        [3] = FunctionType.Logistics,
        [4] = FunctionType.RoleBreak,
        [5] = FunctionType.Nerve,
    }

    self.tbSupportSlot = {self.Logis1,self.Logis2,self.Logis3}
    self.tbSkill = {self.Skill1,self.Skill1,self.Skill3,self.Qte,self.Rush,}
    BtnAddEvent(self.BtnFormation, function() self:OnClickFormationBtn() end)
    self.ListFactory = Model.Use(self)

    self.FunChangePanel = function (index)
        if self.tbPage2FunType[index] then
            local bUnlock, tbTip = FunctionRouter.IsOpenById(self.tbPage2FunType[index])
            if not bUnlock then return UI.ShowTip(Text(tbTip[1] or '')) end
        end

        -- if self.pCard and self.pCard:IsTrial() then
        --     return
        -- end

        local RoleUI = UI.GetUI('Role')
        if RoleUI and RoleUI:IsOpen() then
            RoleUI:UpdatePanel(1, index or 1, self.pCard)
            RoleUI.Title:Push(function()
                RoleUI:UpdatePanel(RoleUI.LastFrom, 0, RoleUI.pCard)
            end)
        end
    end
    BtnAddEvent(self.BtnDetails, function()
        self.FunChangePanel(1)
    end)
    BtnAddEvent(self.BtnWeapon, function()
        self.FunChangePanel(2)
    end)
    BtnAddEvent(self.Btn, function()
        self.FunChangePanel(1)
    end)
    BtnAddEvent(self.BtnProLevel, function()
        self.FunChangePanel(5)
    end)

    self:BindToAnimationEvent(self.Switch, {self, function ()
        self:ShowBreakSkill()
        self:UnbindAllFromAnimationFinished(self.Switch)
    end}, UE4.EWidgetAnimationEvent.Finished)
end

---打开UI
---@param InSelectCard Template 锁定角色Template
---@param InFrom Integer 来源 1表示来源于编队 2来源于展示角色选择
---@param Card UCharacterCard 锁定角色
function tbClass:OnActive(InSelectCard, InFrom, Click, Card)
    if Card then
        self.pCard = Card
        self.CurTemplate = UE4.UItem.FindTemplateForID(Card:TemplateId())
    elseif InSelectCard then
        self.CurTemplate = InSelectCard
        self.pCard = RoleCard.GetItem({InSelectCard.Genre,InSelectCard.Detail,InSelectCard.Particular,InSelectCard.Level})
    end
    if not self.pCard and not self.CurTemplate then return end

    --- 角色展示模型
    RoleCard.ModifierModel(self.CurTemplate, self.pCard, PreviewType.role_lvup, UE4.EUIWidgetAnimType.Role_LvUp, function() self.RoleRotate:SetModel(Preview.GetModel()) end)

    self.Form = InFrom or self.Form
    self:UpdateBtn()

    if not self.pCard then return end

    self:ShowSkill1()
    self:InfoDes(self.pCard)
    self:UpdatePanelLogistics(self.pCard)

    if not self.pCard:HasFlag(Item.FLAG_READED) then
        Item.Read({self.pCard:Id()})
    end

    local bShow = FunctionRouter.IsOpenById(FunctionType.ProLevel)
    if bShow then
        if me:GetAttribute(RoleCard.BreakGID, RoleCard.BreakSubId) == 0 then
            me:SetAttribute(RoleCard.BreakGID, RoleCard.BreakSubId, 1)
            WidgetUtils.Collapsed(self.PanelProLevelLock)
            WidgetUtils.HitTestInvisible(self.PanelSkill)
            self.TextProLevel2:SetText(Text("ui.ProLevelStage", self.pCard:ProLevel()+1))
            self.TextProLevel:SetText(Text("ui.roleup_ProLevel"))
            WidgetUtils.HitTestInvisible(self.PanelSkillLock)
            self:PlayAnimation(self.Switch)
            return
        end
    end
    self:ShowBreakSkill()
end

---------------------------------
---检查角色是否被锁定
function tbClass:CheckCardIsLock(InCard)
    if Launch.GetType() == LaunchType.BOSS then ---boss挑战编队检查
        local islock, msg = BossLogic.CheckCardIsLock(InCard)
        if islock then
            return true, msg
        end
    end

    return false
end

---上阵处理
function tbClass:OnClickFormationBtn()
    if self.pCard == nil then return end

    local pFindCard = Formation.GetCardByIndex(Formation.GetCurLineupIndex(), Formation.GetMemberPos())
    --如果是联机
    if Online.GetPreId() > 0 and Online.GetOnlineState() ~= Online.STATUS_INVALID then
        if Formation.GetMemberPos() == 0 and self.pCard == pFindCard then --不允许删掉队长
            UI.ShowTip("tip.not_exitcaptain")
            return
        elseif Formation.GetMemberPos() > 0 then
            local pMainCard = Formation.GetCardByIndex(Formation.GetCurLineupIndex(), 0)
            if not pFindCard and (not pMainCard or pMainCard:Id() == self.pCard:Id())  then --如果队长和null对换
                UI.ShowTip("tip.not_exitcaptain")
                return
            end
        end
    end

    if pFindCard ~= self.pCard then ---是上阵的话 检查是否满足上阵条件
        local islock, message = self:CheckCardIsLock(self.pCard)
        if islock then
            return UI.ShowMessage(message)
        end

        --肉鸽活动判断队伍中是否有相同角色
        if Launch.GetType() == LaunchType.DLC1_ROGUE then
            if RogueLogic.GetHPByCard(self.pCard) == 0 then
                return UI.ShowMessage("tip.character_die")
            end
            local LineupIndex = Formation.GetCurLineupIndex()
            local Lineup = Formation.GetLineup(LineupIndex)
            if Lineup then
                for i = 0, 2 do
                    local card = Lineup:GetMember(i):GetCard()
                    if card and card:Genre() == self.pCard:Genre() and card:Detail() == self.pCard:Detail() and card:Particular() == self.pCard:Particular() and card:Level() == self.pCard:Level() then
                        Formation.SetLineupMember(LineupIndex, i, nil)
                        break
                    end
                end
            end
        end

        ---试玩数量上限判断
        if Formation.bTrial then
            local nPos = Formation.GetMemberPos()
            local rule = TeamRule.GetPosRule(nPos)
            if not rule then
                print('rule is nil', nPos)
                return
            end

            ---角色被锁定了
            if TeamRule.IsLockCard(self.pCard, Formation.GetMemberPos()) then
                return UI.ShowTip('tip.the_role_is_locked')
            end

            ---如果是试玩角色 判断是否达到试玩数量上限
            if self.pCard:IsTrial() then
                if TeamRule.IsMaxTrialNum(self.pCard, Formation.GetMemberPos()) then
                    UI.ShowTip('tip.trials_reached_limit')
                    return
                end
            else
                ---在队伍中
                local nExistIndex = Formation.GetRoleIndex(Formation.TRIAL_INDEX, self.pCard) or -1
                if nExistIndex >= 0 then
                    local existRule = TeamRule.GetPosRule(nExistIndex)
                    if existRule and existRule:IsOpenTrail() and existRule:IsUseSelfCard() == false then
                        return UI.ShowTip('tip.the_role_is_locked')
                    end
                end
            end
        end
    end

    if Launch.GetType() == LaunchType.TOWER then
        --爬塔活动队伍特殊判断条件
        local LineupIndex = Formation.GetCurLineupIndex()
        if pFindCard == self.pCard then
            --离队
            Formation.SetLineupMember(LineupIndex, Formation.GetMemberPos(), nil)
            for i = 0, 1 do
                if not Formation.GetCardByIndex(LineupIndex, i) and Formation.GetCardByIndex(LineupIndex, i+1) then
                    Formation.ChangePos(LineupIndex, i, i+1)
                end
            end
            Formation.Req_UpdateLineup(LineupIndex, function() UI.CloseTop() end)
            return
        else
            local fun = function() UI.CloseTop() end
            local tb = {}
            tb[7] = 8
            tb[8] = 7
            if tb[LineupIndex] then
                local Lineup = Formation.GetLineup(tb[LineupIndex])
                if Lineup then
                    for i = 0, 2 do
                        local card = Lineup:GetMember(i):GetCard()
                        if card and card:Id() == self.pCard:Id() then
                            Formation.SetLineupMember(tb[LineupIndex], i, pFindCard)
                            fun = function()
                                UI.CloseTop()
                                Formation.Req_UpdateLineup(tb[LineupIndex])
                            end
                            break
                        end
                    end
                end
            end
            Formation.UpdateCurrentFormation(self.pCard, fun)
        end
    else
        Formation.UpdateCurrentFormation(self.pCard, function() UI.CloseTop() end)
    end
end

function tbClass:OnClickChangeRoleBtn()
    PlayerSetting.Req_ChangeRole(self.pCard:Id())
end

---设置按钮文字
function tbClass:SetBtnText()
    if self.pCard == nil then return end
    WidgetUtils.Visible(self.BtnFormation)
    local pFindCard = Formation.GetCardByIndex(Formation.GetCurLineupIndex(), Formation.GetMemberPos())
    ---试玩角色处理
    if self.pCard:IsTrial() then
        if pFindCard == nil then
            self.TxtJoin:SetText(Text("join"))
        elseif self.pCard == pFindCard then
            self.TxtJoin:SetText(Text("leave"))
        else
            self.TxtJoin:SetText(Text("join"))
        end
    else
        local bInFormation = Formation.IsInFormation(Formation.GetCurLineupIndex(), self.pCard)
        if pFindCard == nil then
            if bInFormation then
                self.TxtJoin:SetText(Text("exchange"))
            else
                self.TxtJoin:SetText(Text("join"))
            end
        elseif self.pCard == pFindCard then
            self.TxtJoin:SetText(Text("leave"))
        elseif bInFormation then
            self.TxtJoin:SetText(Text("exchange"))
        elseif Launch.GetType() == LaunchType.TOWER and Formation.IsInTowerFormation(Formation.GetCurLineupIndex(), self.pCard) then
            self.TxtJoin:SetText(Text("exchange"))
        else
            self.TxtJoin:SetText(Text("join"))
        end
    end
end

---试玩特殊处理
function tbClass:SetBtnText2()
    if self.pCard == nil then return end
    local nPos = Formation.GetMemberPos()
    local nLineupIdx = Formation.GetCurLineupIndex()

    local pOldCard = Formation.GetCardByIndex(nLineupIdx, nPos)

    ---试玩角色处理
    if self.pCard:IsTrial() then
        if self.Form == 6 then
            if pOldCard == nil then
                WidgetUtils.Visible(self.BtnFormation)
                self.TxtJoin:SetText(Text("join"))
            elseif self.pCard == pOldCard then
                WidgetUtils.Collapsed(self.BtnFormation)
                return
            else
                WidgetUtils.Visible(self.BtnFormation)
                self.TxtJoin:SetText(Text("join"))    
            end
        else
            WidgetUtils.Collapsed(self.BtnFormation)
            return
        end
    else
        WidgetUtils.Visible(self.BtnDetails)
        ---在队伍中
        local bInFormation = Formation.IsInFormation(nLineupIdx, self.pCard)
        local rule = TeamRule.GetPosRule(nPos)
        if pOldCard == nil then
           if bInFormation then
                if rule then
                    if rule:CanIn(self.pCard) == false then
                        WidgetUtils.Collapsed(self.BtnFormation)
                        return
                    else
                        self.TxtJoin:SetText(Text("exchange"))
                    end
                end
            else
                self.TxtJoin:SetText(Text("join"))
           end
        elseif self.pCard == pOldCard then
            if rule and rule:IsAssignCard(self.pCard) then
                WidgetUtils.Collapsed(self.BtnFormation)
            else
                self.TxtJoin:SetText(Text("leave"))
                WidgetUtils.Visible(self.BtnFormation)
            end
            return
        elseif bInFormation then
            self.TxtJoin:SetText(Text("exchange"))
        else
            self.TxtJoin:SetText(Text("join"))
        end
    end
end

function tbClass:UpdateBtn()
    WidgetUtils.SelfHitTestInvisible(self.Image_70)
    if self.Form == 4 or self.Form == 6 then
        WidgetUtils.Collapsed(self.BtnDetails)
        WidgetUtils.Collapsed(self.Image_70)
        WidgetUtils.Visible(self.BtnFormation)
        self:SetBtnText2()
    elseif self.Form == 2 then
        WidgetUtils.Visible(self.BtnFormation)
        self:SetBtnText()
    elseif self.Form == 3 then
        WidgetUtils.Collapsed(self.BtnFormation)
        self:UpdataChangeRoleBtn()
    else
        WidgetUtils.Collapsed(self.BtnFormation)
    end
end

function tbClass:UpdataChangeRoleBtn()
    if self.pCard:Id() == PlayerSetting.GetShowCardID() then
        WidgetUtils.Collapsed(self.BtnChangeRole)
    else
        WidgetUtils.Visible(self.BtnChangeRole)
    end
end

function tbClass:InfoDes(InCard)
    self.TxtName:SetText(Text(InCard:I18N()))
    self.TxtTitle:SetText(Text(InCard:I18N()..'_title'))
    self.Quality:Set(self.CurTemplate.Color)

    SetTexture(self.RoleIcon, InCard:Icon())
    SetTexture(self.RedirectImage, Item.RoleColor_short[InCard:Color()])

    --- “战力”
    self.TxtPowerName:SetText(Text('TxtRolePower'))
    --- n战力
    local nPower = Item.Zhanli_CardTotal(InCard)

    self.TexBatPower:SetText(nPower)
    --- 角色名
    self.txtNAME:SetText(Text(InCard:I18N()))
    --- 武器Icon
    local pWeapon = InCard:GetSlotWeapon()

    --self.SkillLv:SetText(Text('item_level'))
    self.TxtNum_1:SetText(InCard:EnhanceLevel())
    self.TxtNum:SetText(pWeapon:EnhanceLevel())

    local GrowConfig = Weapon.GetWeaponGrowConfig(pWeapon)
    if GrowConfig then
        local damageType = GrowConfig.nDamageType
        SetTexture(self.ImgArmsType, Weapon.tbRestraintIcon[damageType])
        self.WeaponAssault:SetText(Text(Weapon.tbRestraintName[damageType]))
    end
    SetTexture(self.Weapon, Weapon.GetTypeIcon(pWeapon))

    SetTexture(self.ImgIcon, pWeapon:Icon())

    --- 武器品质
    local tbQualityIcon = {1700066, 1700066, 1700067, 1700068, 1700069}

    SetTexture(self.ImgQuality, tbQualityIcon[pWeapon:Color()] or 1700066)
    SetTexture(self.ImgQuality2, Item.RoleColorWeapon[InCard:Color()])


    --- 天启等级
    self.RoleStar:ShowActiveImg(RBreak.GetProcess(InCard))

    --- 星级
    self:ShowStar(pWeapon:Quality())

    --- 配件
    self:ShowWeaponPart(pWeapon)

    --- 后勤插槽位
    self:ShowSupportSlot(InCard)

    --- 技能展示区
    self:ShowSkillPanel(InCard)

    self:SetRoleLogo(InCard)

    if Launch.GetType() == LaunchType.BOSS and BossLogic.CheckWeapon(pWeapon) then
        WidgetUtils.SelfHitTestInvisible(self.PanelDisableSl)
    else
        WidgetUtils.Collapsed(self.PanelDisableSl)
    end
end

---显示星级
---@param nStar number 数量
function tbClass:ShowStar(nStar)
    for i = 1, 5 do
        local pw = self["s_" .. i]
        if pw then
            if i <= nStar then
                WidgetUtils.SelfHitTestInvisible(pw.ImgStar)
                WidgetUtils.Collapsed(pw.ImgStarOff)
            else
                WidgetUtils.Collapsed(pw.ImgStar)
                WidgetUtils.SelfHitTestInvisible(pw.ImgStarOff)
            end
        end
    end
end

--- 配件信息
---@param InWeapon UE4.UItem 武器
function tbClass:ShowWeaponPart(InWeapon)
     Weapon.ShowPartInfo(InWeapon, self)
end

---刷新后勤显示
function tbClass:UpdatePanelLogistics(InCard)
    ---刷新后勤的显示

    ---刷新后勤的锁定
    if Launch.GetType() == LaunchType.BOSS then
        local islock = false
        local tbItem = UE4.TArray(UE4.USupporterCard)
        InCard:GetSupporterCards(tbItem)
        for k = 1, tbItem:Length() do
            if BossLogic.CheckSupporter(tbItem:Get(k)) then
                islock = true
                break
            end
        end
        if islock then
            WidgetUtils.SelfHitTestInvisible(self.PanelDisableSl1)
        else
            WidgetUtils.Collapsed(self.PanelDisableSl1)
        end
    end
end

--- 后勤插槽位
---@param InCard UE4.UCharacterCard 角色卡
function tbClass:ShowSupportSlot(InCard)
    if not InCard then
        return
    end
    for index, value in ipairs(self.tbSupportSlot) do
        local pSupportCard = InCard:GetSupporterCard(index)
        -- if index == 3 then
        --     if not pSupportCard then
        --         WidgetUtils.Collapsed(value)
        --         WidgetUtils.HitTestInvisible(self.No)
        --     else
        --         WidgetUtils.Collapsed(self.No)
        --         WidgetUtils.SelfHitTestInvisible(value)
        --     end
        -- end
        local tbParam = {
                SupportCard = pSupportCard,
                Slot = index,
                Click = function(Index)
                    if self.FunChangePanel then
                        self.FunChangePanel(3)
                    else
                        if not UI.IsOpen("LogiShow") then
                            UI.Open("LogiShow", InCard, Index, self.Form)
                        end
                    end
                end
            }
        value:Display(tbParam)
    end
end

--- 技能展示
---@param InCard UE4.UCharacterCard 角色卡
function tbClass:ShowSkillPanel(InItem)
end

--- 展示中心节能1
function tbClass:ShowSkill1()
    local ArrayID = RoleCard.GetProLevelSkillID(self.pCard)
    if ArrayID and ArrayID:Length() > 0 then
        local id = ArrayID:Get(1)
        self.TxtSkill:SetContent(SkillDesc(id))
        self.TxtSkillName:SetText(SkillName(id))
    end
end

function tbClass:SetRoleLogo(InCard)
    if not InCard then return end
    local RoleLogoId = InCard:Icon()
    SetTexture(self.ImgLogo,RoleLogoId)
    SetTexture(self.ImgLogoShadow,RoleLogoId)
end

function tbClass:ShowBreakSkill()
    local InShow, sTip = FunctionRouter.IsOpenById(FunctionType.ProLevel)
    WidgetUtils.Collapsed(self.PanelProLevelLock)
    if InShow then
        WidgetUtils.SelfHitTestInvisible(self.PanelSkill)
        WidgetUtils.Collapsed(self.PanelSkillLock)
        self.TextProLevel2:SetText(Text("ui.ProLevelStage", self.pCard:ProLevel()+1))
    else
        WidgetUtils.Collapsed(self.PanelSkill)
        WidgetUtils.SelfHitTestInvisible(self.PanelSkillLock)
        self.TextProLevel:SetText(Text("ui.roleup_ProLevel"))
        if sTip and sTip[1] then
            self.UnSkillTxt:SetText(sTip[1])
        end
    end
end

function tbClass:OnDisable()
    -- body
end

function tbClass:OnClose()
    self:UnbindAllFromAnimationFinished(self.Switch)
end

return tbClass