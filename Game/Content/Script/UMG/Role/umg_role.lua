-- ========================================================
-- @File    : umg_role_up.lua
-- @Brief   : 角色主界面
-- ========================================================

-- require("UMG.Role.RoleCard")
local tbClass = Class("UMG.BaseWidget")
tbClass.CardItemPath = "/Game/UI/UMG/Role/Widgets/uw_role_role_data.uw_role_role_data"

function tbClass:Construct()
    ---页面对应功能类型
    self.tbPage2FunType = {
        [2] = FunctionType.WeaponReplace,
        [3] = FunctionType.Logistics,
        [4] = FunctionType.RoleBreak,
        [5] = FunctionType.Nerve,
    }
    self.tbPageIndex = {
        Formation       = 0,
        Growth          = 1,
        Weapon          = 2,
        Logistics       = 3,
        RoleBreak       = 4,
        NerveMain       = 5,
    }
    self.tbPageName = {
        [0] = "Formation",
        [1] = "Growth",
        [2] = "Weapon",
        [3] = "Logistics",
        [4] = "RoleBreak",
        [5] = "NerveMain",
    }

    BtnAddEvent(self.BtnScreen, function()
        if self.tbCharacterCard then
            self.tbRoleSortInfo.tbFilter[1].rule = 9
        else
            self.tbRoleSortInfo.tbFilter[1].rule = 10
        end
        UI.Open('Screen', self.tbRoleSortInfo, self.RoleCurSort, function ()
            self:UpdateCharacterList()
            self:DoSwitch(self.SwitchObj)
        end)
    end)

    self.ShowSort = {
    ["Show"] = function()
        WidgetUtils.Visible(self.BtnScreen)
    end,
    ["UnShow"] = function()
        WidgetUtils.Collapsed(self.BtnScreen)
    end,
}
end

---获取子界面 没打开过获取为nil
function tbClass:GetSwitcherWidget(name)
    if name and self.tbPageIndex[name] then
        return self.Switcher:GetWidgetAtIndex(self.tbPageIndex[name])
    end
end

function tbClass:OpenFashion()
    local tbParam = {
        CharacterTemplate = self.pTemplate,
        Rolelist = self.tbItems,
        tbCharacterCard = self.tbCharacterCard,
        RoleCurSort = self.RoleCurSort,
        CurSelect = self.CurSelect,
        EnterFromRole = true,
    }
    UI.Open("RoleFashion", tbParam);
end

function tbClass:OnInit()
    -- 排序
    self.tbRoleSortInfo =
    {
        tbSort = {
            sDesc = 'ui.TxtScreen1',
            tbRule={
                {'ui.item_level', ItemSort.TemplateLevelSort},
                {'ui.TxtRareSort', ItemSort.TemplateRareSort},
                {'ui.TxtRolePower', ItemSort.TemplateCombatSort},
                {'ui.TxtScreen2', ItemSort.TemplateIdSort},
                --信赖度暂时隐藏{'ui.TxtDormPresentLove', {1}},
                {'ui.TxtBreakSort', ItemSort.TemplateBreakSort},
                {'ui.TxtScreen16', ItemSort.TemplateAttackSort},
                {'ui.TxtDefenceSort', ItemSort.TemplateDefenceSort},
                {'ui.health', ItemSort.TemplateHealthSort},
                {'ui.roleup_skill', ItemSort.TemplateSpineSort},
            }
        },

        --{sDesc:标题文字，rule:筛选类型, tbRule:筛选子项 }
        tbFilter = {
            {
                sDesc='ui.TxtScreen3',
                rule=9,
                tbRule={
                    {'weapon.type_1', 1},
                    {'weapon.type_2', 2},
                    {'weapon.type_3', 3},
                    {'weapon.type_4', 4},
                    {'weapon.type_5', 5}
                }
            },
        }
    }
    self.RoleCurSort = self.RoleCurSort or {tbSort={1, false}, tbFilter=nil}
    self.LastRoleCurSort = self.RoleCurSort

    ---显示技能详情时隐藏角色列表和页签列表
    self.ChangeSkillDetailHandle = EventSystem.OnTarget(RoleCard, RoleCard.ShowSkillDetailHandle, function(Target, bShow)
        self:ChangeWidget(not bShow)
    end)

    ---突破后刷新角色按钮上的红点
    self.UpdateRedDotHandle = EventSystem.OnTarget(RBreak, RBreak.RoleBreakHandle, function()
        if self.SwitchRoleObj and self.SwitchRoleObj.funUpdateRedDot then
            self.SwitchRoleObj.funUpdateRedDot()
        end
    end)

    local pLoadCurve = self:LoadAssetFormPath("CurveFloat'/Game/UI/UMG/Role/RotatorCurve.RotatorCurve'")
    if pLoadCurve then
        --旋转曲线
        self.CurveFloat = pLoadCurve:Cast(UE4.UCurveFloat)
    end

    if UE4.UDeviceProfileLibrary.GetDeviceProfileLevel() <= 0 then
        --低端机
        self.LeftList:SetClipping(UE4.EWidgetClipping.Inherit)
        self.e_ui_panel_glow_p:SetAutoActivate(false)
        WidgetUtils.Collapsed(self.e_ui_panel_glow_p)
    else
        self.LeftList:SetClipping(UE4.EWidgetClipping.ClipToBounds)
        self.e_ui_panel_glow_p:SetAutoActivate(true)
        WidgetUtils.SelfHitTestInvisible(self.e_ui_panel_glow_p)
    end
end

function tbClass:UpdateCharacterList()
    if self.tbCharacterCard then
        self.tbRoleSortInfo.tbFilter[1].rule = 9
        local tbItem = self:GetFilterItems(self.tbCharacterCard)
        if #tbItem <= 0 then
            UI.ShowMessage("ui.TxtScreen5")
            self.RoleCurSort = self.LastRoleCurSort
            tbItem = self:GetFilterItems(self.tbCharacterCard)
        end
        self:ShowCharacterListByTbCard(tbItem)
    else
        self.tbRoleSortInfo.tbFilter[1].rule = 10
        self.tbItems = RoleCard.GetAllCharacter(self.Form)
        local haveItem = {}
        local NothaveItem = {}
        for _, gItem in pairs(self.tbItems) do
            if RoleCard.GetItem({gItem.Genre, gItem.Detail, gItem.Particular, gItem.Level}) then
                table.insert(haveItem, gItem)
            elseif Item.CheckCardShow({gItem.Genre, gItem.Detail, gItem.Particular, gItem.Level}) then
                table.insert(NothaveItem, gItem)
            end
        end
        local tbItem = self:GetFilterItems(haveItem, NothaveItem)
        if #tbItem <= 0 then
            UI.ShowMessage("ui.TxtScreen5")
            self.RoleCurSort = self.LastRoleCurSort
            tbItem = self:GetFilterItems(self.tbItems)
        end
        self.tbItems = tbItem
        self:ShowCharacterList(tbItem)
    end
    self.LastRoleCurSort = self.RoleCurSort
end

function tbClass:GetFilterItems(tbHave, tbNotHave)
    local nSort = 1
    local bReverse = false
    local tbFilter = {{}}

    nSort = self.RoleCurSort.tbSort[1]
    bReverse = self.RoleCurSort.tbSort[2]
    tbFilter = self.RoleCurSort.tbFilter or tbFilter

    local fun = function (tbItems)
        local tbData = Copy(tbItems or {})
        for _, tbCfg in pairs(tbFilter) do
            tbData = ItemSort:Filter(tbData, tbCfg)
        end

        if self.tbRoleSortInfo and self.tbRoleSortInfo.tbSort then
            if self.tbRoleSortInfo.tbFilter[1].rule == 9 then
                tbData = ItemSort:CardSort(tbData, self.tbRoleSortInfo.tbSort.tbRule[nSort][2])
            elseif self.tbRoleSortInfo.tbFilter[1].rule == 10 then
                tbData = ItemSort:TemplateSort(tbData, self.tbRoleSortInfo.tbSort.tbRule[nSort][2])
            end
        end
        if bReverse then
            ItemSort:Reverse(tbData)
        end
        return tbData
    end

    local tbData1 = fun(tbHave)
    if tbNotHave and #tbNotHave>0 then
        local tbData2 = fun(tbNotHave)
        for _, v in ipairs(tbData2) do
            table.insert(tbData1, v)
        end
    end

    return tbData1
end

---重新刷新界面-改变InFrom时
function tbClass:UpdatePanel(InFrom, Index, Card)
    if self.Form == InFrom then return end

    self.LastFrom = self.Form
    self.Form = InFrom

    if self.tbPage2FunType[Index] and not FunctionRouter.IsOpenById(self.tbPage2FunType[Index]) then
        Index = 1
    end

    local PageData = nil
    if self.Form == 1 then
        PageData = RoleCard.pPage.Refresh(1, 5, Index)
    end

    if self.Form == 2 then
        WidgetUtils.Collapsed(self.RightList)
        PageData = RoleCard.pPage.Refresh(0, 0, 0)
    else
        WidgetUtils.SelfHitTestInvisible(self.RightList)
    end

    if self.Form == 3 then
        PageData = RoleCard.pPage.Refresh(1, 1, 1)
    end

    if self.Form == 4 then
        PageData = RoleCard.pPage.Refresh(0, 0, 0)
    end

    if not self.Form or not PageData then
        PageData = RoleCard.pPage.Refresh(1, 5, Index)
    end

    if self.SwitchObj then
        local pLastWidget = self.Switcher:GetWidgetAtIndex(self.SwitchObj.Index)
        if pLastWidget and pLastWidget.OnDisable then
            pLastWidget:OnDisable()
        end
    end
    self:ShowLeftList(PageData.nMin, PageData.nMax)
    if Card and (not self.pCard or self.pCard:Id() ~= Card:Id()) then
        ---要刷新角色列表
        self.pCard = Card
        self.pTemplate = UE4.UItem.FindTemplateForID(self.pCard:TemplateId())
        self:UpdateCharacterList()
        self:UpdateRoleFlagAndRed()
    else
        ---只刷新角色按钮状态
        for _, CardObj in ipairs(self.tbCardItemObj) do
            CardObj:SetInForm(self.Form)
            if CardObj.funUpdateRedDot then
                CardObj.funUpdateRedDot()
            end
            if CardObj.funUpdateMemberSelected then
                CardObj.funUpdateMemberSelected()
            end
        end
    end
end

---打开UI
---@param InFrom integer 来源 1:主界面进 2:编队 3:预览展示 4:试玩角色 5:肉鸽活动增益角色预览 6:编队试玩角色选择
---@param InCard UE4.UCharacterCard 锁定角色，当InFrom == 3时，InCard为{g,d,p,l}
---@param tbCard table 角色列表
---@param bShowHp boolean 角色列表角色是否显示血条
function tbClass:OnOpen(InFrom, InCard, tbCard, bShowHp)
    ---列表滑动设置
    self.LeftList:SetScrollable(true)
    self.LeftList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.RightList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)

    PreviewScene.Enter(PreviewType.role_lvup)

    --来源 1:主界面进 2:编队 3:预览展示 4:试玩角色 5:肉鸽活动增益角色预览
    self.Form = InFrom or self.Form
    self.tbCharacterCard = tbCard or self.tbCharacterCard

    if bShowHp ~= nil then
        ---角色列表角色是否显示血条
        self.bShowHp = bShowHp
    end

    if self.Form == 1 then
        if InCard then
            self.pCard = InCard
            self.pTemplate = UE4.UItem.FindTemplateForID(self.pCard:TemplateId())
        end
        if InFrom then
            RoleCard.pPage.Refresh(1, 5, 1)
        else
            if self.pCard then
                RoleCard.pPage.Refresh(1, 5)
            else
                RoleCard.pPage.Refresh(1, 1, 1)
            end
        end
    elseif self.Form == 2 then
        WidgetUtils.Collapsed(self.RightList)
        if InCard then
            self.pCard = InCard
            self.pTemplate = UE4.UItem.FindTemplateForID(self.pCard:TemplateId())
        end
        RoleCard.pPage.Refresh(0, 0, 0)
    elseif self.Form == 3 then
        self.pTemplate = UE4.UItem.FindTemplate(InCard[1], InCard[2], InCard[3], InCard[4])
        RoleCard.pPage.Refresh(1, 1, 1)
    elseif (self.Form == 4 or self.Form == 6) then
        if InCard then
            self.pCard = InCard
            self.pTemplate = UE4.UItem.FindTemplateForID(self.pCard:TemplateId())
        end
        WidgetUtils.Collapsed(self.RightList)
        RoleCard.pPage.Refresh(0, 0, 0)
    elseif not self.Form and not InCard and not self.pTemplate then
        local CachaeInfo = RoleCard:GetCache()
        if CachaeInfo.pCard then
            self.pCard = CachaeInfo.pCard
            self.pTemplate = UE4.UItem.FindTemplateForID(self.pCard:TemplateId())
            self.Form = CachaeInfo.nFrom
        elseif CachaeInfo.pTemplate then
            self.pTemplate = CachaeInfo.pTemplate
            self.pCard = RoleCard.GetItem({self.pTemplate.Genre, self.pTemplate.Detail, self.pTemplate.Particular, self.pTemplate.Level})
            self.Form = CachaeInfo.nFrom
        end
    elseif self.Form == 5 then
        if InCard then
            self.pCard = InCard
            self.pTemplate = UE4.UItem.FindTemplateForID(self.pCard:TemplateId())
        end
        RoleCard.pPage.Refresh(1, 1, 1)
    end

    if not self.Form and not self.pTemplate then
        self.Form = 1
        RoleCard.pPage.Refresh(1, 5, 1)
    end

    --显示角色列表并排序
    self:UpdateCharacterList()
    --显示页签列表
    self:ShowLeftList(RoleCard.pPage.nMin, RoleCard.pPage.nMax)
    --标记角色查看
    self:UpdateRoleFlagAndRed()
    self:PlayAnimation(self.AllEnter)

    self:StreamingScene(PreviewType.weapon)
end

function tbClass:UpDataGetSortOption()
    self.SelType[1].Option = Text('ui.sort_get')
end


--- 是否显示排序规则界面
function tbClass:ShowSortWidget(InStr)
    if self.pCard and self.pCard:IsTrial() then
        self.ShowSort["UnShow"]()
        return
    end
    if InStr and self.ShowSort and self.ShowSort[InStr] then
        self.ShowSort[InStr]()
    end
end

function tbClass:ShowCharacterList(tbItems)
    if not tbItems or #tbItems == 0 then
        return
    end
    self:DoClearListItems(self.LeftList)
    self.tbCardItemObj = {}

    if not self.pTemplate or not RoleCard.TemplateIsInTable(self.pTemplate, tbItems) then
        self.pTemplate = tbItems[1]
        self.pCard = RoleCard.GetItem({tbItems[1].Genre, tbItems[1].Detail, tbItems[1].Particular, tbItems[1].Level})
    end

    local pCardItem = LoadClass(self.CardItemPath)
    for key, value in ipairs(tbItems) do
        local CardItem = NewObject(pCardItem, self, nil)
        local bSelect = false
        if self.pTemplate.Genre == value.Genre and
            self.pTemplate.Detail == value.Detail and
            self.pTemplate.Particular == value.Particular and
            self.pTemplate.Level == value.Level then
            self.SwitchRoleObj = CardItem
            self.CurSelect = key
            bSelect = true
        end
        CardItem:Init(key, bSelect, value, function(Target, InSelectId)
            local bRefresh = false
            local Card = RoleCard.GetItem({value.Genre, value.Detail, value.Particular, value.Level})
            if (Card and not self.pCard) or (not Card and self.pCard) then
                bRefresh = true
            end
            self.pCard = Card
            self.pTemplate = UE4.UItem.FindTemplate(value.Genre,value.Detail,value.Particular,value.Level)
            if bRefresh then
                if self.pCard then
                    if self.Form == 1 then
                        RoleCard.pPage.Refresh(1, 5)
                    elseif self.Form == 2 or self.Form == 4 then
                        RoleCard.pPage.Refresh(0, 0, 0)
                    elseif self.Form == 3 then
                        RoleCard.pPage.Refresh(1, 1, 1)
                    end
                else
                    if self.Form == 2 or self.Form == 4 then
                        RoleCard.pPage.Refresh(0, 0, 0)
                    else
                        RoleCard.pPage.Refresh(1, 1, 1)
                    end
                end
                self:ShowLeftList(RoleCard.pPage.nMin, RoleCard.pPage.nMax)
            else
                self:UpdateRightListInfo()
            end
            self:OnSwitchRoleChange(CardItem, bRefresh)
        end)
        CardItem.nForm = self.Form
        CardItem.nTemplateId = UE4.UItemLibrary.GetTemplateId(value.Genre, value.Detail, value.Particular, value.Level)
        self.LeftList:AddItem(CardItem)
        table.insert(self.tbCardItemObj, CardItem)
    end
    self.LeftList:ScrollIndexIntoView(self.CurSelect-1)
end

--根据传进来的tbCard显示角色列表
function tbClass:ShowCharacterListByTbCard(tbCard)
    if not tbCard or #tbCard == 0 then
        return
    end
    self.CurSelect = 1
    self:DoClearListItems(self.LeftList)
    self.tbCardItemObj = {}
    local pCardItem = LoadClass(self.CardItemPath)

    if self.Form == 2 then
        if not self.pCard then
            for _, card in pairs(tbCard) do
                if not Formation.IsInFormation(Formation.GetCurLineupIndex(), card) then
                    self.pCard = card
                    break
                end
            end
        end
    end
    if not self.pCard or not RoleCard.CharacterCardIsInTable(self.pCard, tbCard) then
        self.pCard = tbCard[1]
    end

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
            self:UpdateRightListInfo()
            self:OnSwitchRoleChange(CardItem)
        end, card)
        CardItem.nForm = self.Form
        CardItem.nTemplateId = card:TemplateId()
        if self.bShowHp then
            CardItem.ShowHP = true
        end
        self.LeftList:AddItem(CardItem)
        table.insert(self.tbCardItemObj, CardItem)
    end
    self.LeftList:ScrollIndexIntoView(self.CurSelect-1)
end

function tbClass:OnSwitchRoleChange(InObj, bNotRefreshTab)
    if self.SwitchRoleObj == InObj then
        return
    end

    self:DoSwitchRole(InObj, bNotRefreshTab)
    self:UpdateRoleFlagAndRed()
end

---标记角色已查看并刷新红点
function tbClass:UpdateRoleFlagAndRed()
    if self.pCard and not self.pCard:IsTrial() and not self.pCard:HasFlag(Item.FLAG_READED) then
        Item.Read({self.pCard:Id()})
        if self.SwitchRoleObj and self.SwitchRoleObj.funUpdateRedDot then
            self.SwitchRoleObj.funUpdateRedDot()
        end
    end
end

---刷新页签列表红点
function tbClass:UpdateRightListInfo()
    for i = 0, self.RightList:GetNumItems()-1 do
        local Obj = self.RightList:GetItemAt(i)
        Obj.pTemplate = self.pTemplate
        Obj.pCard = self.pCard
        if Obj.UpdateRedDot then
            Obj.UpdateRedDot()
        end
    end
end

--- 选择角色切换
function tbClass:DoSwitchRole(InObj, bNotRefreshTab)
    if self.SwitchRoleObj then
        self.SwitchRoleObj:SetSelect(false)
    end

    self.SwitchRoleObj = InObj
    if self.SwitchRoleObj then
        self.SwitchRoleObj:SetSelect(true)
        local ActiveWidget = self.LeftList:GetItemAt(InObj.ShowPos-1)
        self.CurSelect = InObj.Index
        if ActiveWidget then
            self:PlayChangeEmit()
            if bNotRefreshTab then
                return
            end

            if self.Switcher:GetActiveWidgetIndex() ~= RoleCard.pPage.nPage then
                local pLastWidget = self.Switcher:GetActiveWidget()
                if pLastWidget and pLastWidget.OnDisable then
                    pLastWidget:OnDisable()
                end
                self.Switcher:SetActiveWidgetIndex(RoleCard.pPage.nPage)
                local Widget = self.Switcher:GetActiveWidget()
                if Widget then
                    if self.tbPageName[RoleCard.pPage.nPage] then
                        self[self.tbPageName[RoleCard.pPage.nPage]] = Widget
                    end
                    Widget:OnActive(self.pTemplate, self.Form, function() self:UnLockClickFun(self.pTemplate) end, self.pCard)
                end
            else
                local Widget = self.Switcher:GetActiveWidget()
                if Widget then
                    if Widget.ChangeRoleCard then
                        Widget:ChangeRoleCard(self.pTemplate, self.Form, function() self:UnLockClickFun(self.pTemplate) end, self.pCard)
                    else
                        Widget:OnActive(self.pTemplate, self.Form, function() self:UnLockClickFun(self.pTemplate) end, self.pCard)
                    end
                end
            end
        end
    end
end

function tbClass:OnState(InFrom)
    WidgetUtils.Hidden(self.RightList)
    self.Form = InFrom
    if InFrom ~= 1 then
        WidgetUtils.SelfHitTestInvisible(self.RightList)
    end
end

--- 左侧页签刷新
---@param InMin interge
---@param InMax interge
function tbClass:ShowLeftList(InMin, InMax)
    self:DoClearListItems(self.RightList)
    local ItemDataClass = LoadClass("/Game/UI/UMG/Role/Widgets/uw_role_leftlist_item_data")
    for i = InMin, InMax do
        if not self.tbPage2FunType[i] or FunctionRouter.IsOpenById(self.tbPage2FunType[i]) then
            local NewObj = NewObject(ItemDataClass, self, nil)
            local bSelect = false
            if i == RoleCard.pPage.nPage then
                self.SwitchObj = NewObj
                bSelect = true
            end
            --- 1:角色系统，2，后勤系统
            local SysMode = 1
            NewObj:Init(i, bSelect, SysMode, function(Target, InPage)
                if self.tbPage2FunType[InPage] then
                    local bUnlock, tbTip = FunctionRouter.IsOpenById(self.tbPage2FunType[InPage])
                    if not bUnlock then return UI.ShowTip(Text(tbTip[1] or '')) end
                end
                if InPage <= InMax then
                    RoleCard.pPage.Refresh(RoleCard.pPage.nMin, RoleCard.pPage.nMax, InPage)
                else
                    RoleCard.pPage.Refresh(RoleCard.pPage.nMin, RoleCard.pPage.nMax, RoleCard.pPage.nPage or 1)
                end
                self:OnSwitchChange(NewObj)
            end)
            NewObj.pTemplate = self.pTemplate
            NewObj.pCard = self.pCard
            self.RightList:AddItem(NewObj)
        end
    end
    self:DoSwitch(self.SwitchObj)
end

function tbClass:OnSwitchChange(InObj)
    if self.SwitchObj == InObj then
        return
    end
    self:DoSwitch(InObj)
end

function tbClass:DoSwitch(InObj)
    if self.SwitchObj then
        self.SwitchObj:SetSelect(false)
        local pLastWidget = self.Switcher:GetWidgetAtIndex(self.SwitchObj.Index)
        if pLastWidget and pLastWidget.OnDisable then
            pLastWidget:OnDisable()
        end
    end
    self.SwitchObj = InObj
    if self.SwitchObj then
        self.SwitchObj:SetSelect(true)
        self.Switcher:SetActiveWidgetIndex(InObj.Index)
        local ActiveWidget = self.Switcher:GetWidgetAtIndex(InObj.Index)
        RoleCard.pPage.nPage = InObj.Index
        if ActiveWidget then
            if self.tbPageName[InObj.Index] then
                self[self.tbPageName[InObj.Index]] = ActiveWidget
            end
            local Model = Preview.GetModel()
            if Model then
                --清除模型上的特效
                local ModelActor = Model:GetModel()
                if ModelActor and ModelActor:IsPlayingMontage() then
                    UE4.UUMGLibrary.ClearAllParticles(ModelActor)
                end
            end
            if not self.pTemplate and self.pCard then
                self.pTemplate = UE4.UItem.FindTemplate(self.pCard.Genre, self.pCard.Detail, self.pCard.Particular, self.pCard.Level)
            end
            ActiveWidget:OnActive(self.pTemplate, self.Form, function() self:UnLockClickFun(self.pTemplate) end, self.pCard)
        end
    end
end

function tbClass:UnLockClickFun(InTemplate)
    local tbParam = {
        G = InTemplate.Genre,
        D = InTemplate.Detail,
        P = InTemplate.Particular,
        L = InTemplate.Level
    }
    RoleCard.Req_UnLockPlayer(tbParam, function()
        if self.pTemplate then
            self.pCard = RoleCard.GetItem({self.pTemplate.Genre, self.pTemplate.Detail, self.pTemplate.Particular, self.pTemplate.Level})
        end

        self:UpdateCharacterList()
        RoleCard.pPage.Refresh(1, 5)
        self:ShowLeftList(RoleCard.pPage.nMin, RoleCard.pPage.nMax)
        self:ChangeWidget()
        UI.ShowTip(Text("tip.role_unlock_ok"))
    end)
end

function tbClass:PlayChangeEmit()
    local EmitLoc = UE4.FVector(0,0,0)
    if Preview.GetModel() then
        EmitLoc = Preview.GetModel():K2_GetActorLocation()
        EmitLoc.Z = 0
    end
    local tbTransform = {EmitLoc = EmitLoc, EmitRot = UE4.FRotator(0,0,0), EmitScale = UE4.FVector(1, 1, 1)}
    UE4.UGameLibrary.SpawnEmitterAtLocation(GetGameIns(), self.SpawnEmit, tbTransform.EmitLoc, tbTransform.EmitRot, tbTransform.EmitScale)
    Audio.PlaySounds(3006)
end

--- 是否隐藏父节点UI控件
function tbClass:ChangeWidget(InShow)
    if InShow then
        WidgetUtils.Collapsed(self.LeftList)
        WidgetUtils.Collapsed(self.RightList)
        WidgetUtils.Collapsed(self.BtnScreen)
        WidgetUtils.Collapsed(self.Title)
    else
        WidgetUtils.SelfHitTestInvisible(self.LeftList)
        WidgetUtils.SelfHitTestInvisible(self.RightList)
        WidgetUtils.Visible(self.BtnScreen)
        WidgetUtils.SelfHitTestInvisible(self.Title)
    end
end

function tbClass:OnClose()
    self:Clear()
    Preview.Destroy()
    RoleCard.ResetCach()
    --RoleCard.pPage.nPage = nil
    for i = 1, self.Switcher:GetChildrenCount() do
        local ChildWidget = self.Switcher:GetChildAt(i-1)
        if ChildWidget and ChildWidget.OnClose then
            ChildWidget:OnClose()
        end
    end
end

function tbClass:Clear()
    EventSystem.Remove(self.ChangeSkillDetailHandle)
    EventSystem.Remove(self.UpdateRedDotHandle)
    self.ChangeSkillDetailHandle = nil
    self.UpdateRedDotHandle = nil

    self.RoleModel = nil
    self.StartRotator = nil
    self.TargetRotator = nil
end

function tbClass:OnDisable()
    if UI.GetUI("Role") then
        RoleCard:SetCache(self.pCard, self.pTemplate, PreviewType.role_lvup, self.Form)
    end
    for i = 1, self.Switcher:GetChildrenCount() do
        local ChildWidget = self.Switcher:GetChildAt(i-1)
        if ChildWidget and ChildWidget.OnDisable then
            ChildWidget:OnDisable()
        end
    end
end

function tbClass:ResetRotation(Model, TargetType)
    self.RoleModel = nil
    self.StartRotator = nil
    self.TargetRotator = nil
    self.DeltaTime = 0

    if not Model or not TargetType or not self.pCard then
        return
    end

    local Template = UE4.UItemLibrary.GetCharacterAtrributeTemplate(self.pCard:TemplateId())
    if Template then
        local info = Template.PreviewData:Find(TargetType)
        if info then
            if info.LightDirection then
                PreviewScene.SetLightDir(info.LightDirection)
            end
            if info.Location then
                Model:K2_SetActorLocation(info.Location)
            end
            self.TargetRotator = info.Rotation
        end
    end

    if RoleCard.bRotate then
        RoleCard.bRotate = nil
        self.RoleModel = Model
        self.StartRotator = self.RoleModel:K2_GetActorRotation()
    else
        if self.TargetRotator then
            Model:K2_SetActorRotation(self.TargetRotator)
            self.TargetRotator = nil
        end
    end
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.RoleModel or not self.StartRotator or not self.TargetRotator or not self.CurveFloat then
        return
    end

    self.DeltaTime = self.DeltaTime + InDeltaTime
    local floatValue = self.CurveFloat:GetFloatValue(self.DeltaTime)

    if floatValue >= 1 or self.DeltaTime >= 1 then
        self.RoleModel:K2_SetActorRotation(self.TargetRotator)
        self.RoleModel = nil
        self.StartRotator = nil
        self.TargetRotator = nil
        self.DeltaTime = 0
        return
    end

    local startY = self.StartRotator.Yaw + 360
    local endY = self.TargetRotator.Yaw + 360

    if math.abs(startY - endY) > 180 then
        if startY > endY then
            startY = startY -360
        else
            endY = endY -360
        end
    end

    local Yaw = Lerp(startY, endY, floatValue)
    self.RoleModel:K2_SetActorRotation(UE4.FRotator(0, Yaw, 0))
end

return tbClass
