-- ========================================================
-- @File    : uw_role_growth_lvup.lua
-- @Brief   : 角色养成界面
-- @Author  :
-- @Date    :
-- ========================================================

local umg_RoleGrowthLvUp = Class("UMG.BaseWidget")
local RoleLvUp = umg_RoleGrowthLvUp
RoleLvUp.Path = "/Game/UI/UMG/Widgets/uw_general_props_list_item_data"

function RoleLvUp:Construct()
    self.CardItemPath = "/Game/UI/UMG/Role/Widgets/uw_role_role_data.uw_role_role_data"

    self.RoleDoBtn.OnClicked:Add(
        self,
        function()
            RoleCard.Req_LevelUp(
                RoleCard:GetShowRole(),
                function()
                    self:InitRoleUpItems()
                    self:ShowUpLvTip()
                    self:InitRoleCardInfo()
                    self:SetConsumRate()
                    self:UpdateOneKeyText()
                    Audio.PlaySounds(3014)
                    if self.SwitchRoleObj then
                        self.SwitchRoleObj:UpdateLevel()
                    end
                end
            )
        end
    )

    self.MaterialsChangeHandle = EventSystem.OnTarget(RoleCard, RoleCard.MaterialsChangeHandle, function(Target,Model)
        self:UpdateSelectShowDate()
        self:UpDateItemsList(Model)
        self:UpdateOneKeyText()
    end)

    self.CustomAttrHandle = EventSystem.On(Event.CustomAttr, function()
        self:UpdateSelectShowDate()
        self:SetConsumRate(0, Cash.GetMoneyCount(Cash.MoneyType_Silver))
    end)

    -- self.OnLvUpFailHandle = EventSystem.OnTarget( RoleCard, RoleCard.RoleLvUpFailTipHandle, function()
    -- end)

    local IconId = Cash.GetMoneyInfo(Cash.MoneyType_Silver)
    SetTexture(self.ImgIcon, IconId)

    BtnAddEvent(self.BtnMethod, function()
        Daily.OpenByID(2)
    end)

    BtnAddEvent(self.BtnOneKey, function() self:OneKeySelect() end)


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
    BtnAddEvent(self.BtnScreen, function()
        if self.tbCharacterCard then
            self.tbRoleSortInfo.tbFilter[1].rule = 9
        else
            self.tbRoleSortInfo.tbFilter[1].rule = 10
        end
        UI.Open('Screen', self.tbRoleSortInfo, self.RoleCurSort, function ()
            local RoleUI = UI.GetUI("role")
            if RoleUI then
                RoleUI.RoleCurSort = Copy(self.RoleCurSort)
            end
            self:UpdateCharacterList()
        end)
    end)
end

function RoleLvUp:OnActive(InCard)
    if PreviewScene.sLastType ~= PreviewType.role_lvup then
        PreviewScene.Enter(PreviewType.role_lvup)
    end
    self.LeftList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:ChangeCard(InCard)

    local RoleUI = UI.GetUI("role")
    if RoleUI then
        self.RoleCurSort = Copy(RoleUI.RoleCurSort)
        self.tbCharacterCard = nil
        self.tbItems = nil
        if RoleUI.tbCharacterCard then
            self.tbCharacterCard = {}
            for _, card in pairs(RoleUI.tbCharacterCard) do
                if not card:IsTrial() then
                    table.insert(self.tbCharacterCard, card)
                end
            end
            self:UpdateCharacterList()
        elseif RoleUI.tbItems then
            self.tbItems = {}
            for _, gItem in pairs(RoleUI.tbItems) do
                if RoleCard.GetItem({gItem.Genre, gItem.Detail, gItem.Particular, gItem.Level}) then
                    table.insert(self.tbItems, gItem)
                end
            end
            self:ShowCharacterList(self.tbItems)
        end
    else
        self.tbItems = {}
        self:UpdateCharacterList()
    end
end

function RoleLvUp:ChangeCard(InCard)
    if InCard and self.CurCard ~= InCard then
        RoleCard.tbConsumes = {}
    end
    self.CurCard = InCard or self.CurCard
    if not self.CurCard then
        return
    end
    RoleCard.SeleCard = self.CurCard
    RoleCard.ItemProEnhanceLv = self.CurCard:EnhanceLevel()

    self:PlayAnimation(self.AllEnter)
    self:ChangePreviewRole()
    self:ShowRoleName(self.CurCard)
    self:InitRoleUpItems()

    -- self:UpDateItemsList()
    self:InitRoleCardInfo()
    self:UpdateSelectShowDate()
    -- self:MaxLvShow(self.CurCard)

    self:UpdateUpLvList()
    self:UpdateOneKeyText()
end

function RoleLvUp:PlayChangeEmit()
    local EmitLoc = UE4.FVector(0,0,0)
    if Preview.GetModel() then
        EmitLoc = Preview.GetModel():K2_GetActorLocation()
        EmitLoc.Z = 0
    end
    local tbTransform = {EmitLoc = EmitLoc, EmitRot = UE4.FRotator(0,0,0), EmitScale = UE4.FVector(1, 1, 1)}
    UE4.UGameLibrary.SpawnEmitterAtLocation(GetGameIns(), self.SpawnEmit, tbTransform.EmitLoc, tbTransform.EmitRot, tbTransform.EmitScale)
    Audio.PlaySounds(3006)
end

function RoleLvUp:UpdateCharacterList()
    if not self.tbCharacterCard and not self.tbItems then
        return
    end

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
        self.tbItems = RoleCard.GetAllCharacter(2)
        local tbItem = self:GetFilterItems(self.tbItems)
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

function RoleLvUp:GetFilterItems(tbItems)
    local nSort = 1
    local bReverse = false
    local tbFilter = {{}}

    nSort = self.RoleCurSort.tbSort[1]
    bReverse = self.RoleCurSort.tbSort[2]
    tbFilter = self.RoleCurSort.tbFilter or tbFilter

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

--根据传进来的tbCard显示角色列表
function RoleLvUp:ShowCharacterListByTbCard(tbCard)
    if not tbCard or #tbCard == 0 then
        return
    end
    self:DoClearListItems(self.LeftList)
    local pCardItem = LoadClass(self.CardItemPath)

    if not self.CurCard or not RoleCard.CharacterCardIsInTable(self.CurCard, tbCard) then
        self:ChangeCard(tbCard[1])
        local UIRole = UI.GetUI("role")
        if UIRole and tbCard[1] then
            UIRole.pCard = tbCard[1]
            UIRole.pTemplate = UE4.UItem.FindTemplateForID(tbCard[1]:TemplateId())
        end
    end
    self.CurSelect = 1

    for key, card in ipairs(tbCard) do
        local CardItem = NewObject(pCardItem, self, nil)
        local bSelect = false
        if self.CurCard and card:Id() == self.CurCard:Id() then
            self.SwitchRoleObj = CardItem
            self.CurSelect = key
            bSelect = true
        end
        CardItem:Init(key, bSelect, nil, function(Target, InSelectId)
            self.CurSelect = key
            self:OnSwitchRoleChange(CardItem, card)
        end, card)
        CardItem.nForm = 1
        CardItem.ParentUIName = "growth_up"
        CardItem.nTemplateId = card:TemplateId()
        self.LeftList:AddItem(CardItem)
    end
    self.LeftList:ScrollIndexIntoView(self.CurSelect-1)
end

function RoleLvUp:ShowCharacterList(tbItems)
    if not tbItems or #tbItems == 0 then
        return
    end
    self:DoClearListItems(self.LeftList)
    local pCardItem = LoadClass(self.CardItemPath)

    if not self.CurCard or not RoleCard.TemplateIsInTable(UE4.UItem.FindTemplateForID(self.CurCard:TemplateId()), tbItems) then
        local Card = RoleCard.GetItem({tbItems[1].Genre, tbItems[1].Detail, tbItems[1].Particular, tbItems[1].Level})
        self:ChangeCard(Card)
        local UIRole = UI.GetUI("role")
        if UIRole and tbItems[1] then
            UIRole.pCard = Card
            UIRole.pTemplate = tbItems[1]
        end
    end
    self.CurSelect = 1

    for key, value in ipairs(tbItems) do
        local CardItem = NewObject(pCardItem, self, nil)
        local bSelect = false
        local Card = RoleCard.GetItem({value.Genre, value.Detail, value.Particular, value.Level})
        if self.CurCard and Card:Id() == self.CurCard:Id() then
            self.SwitchRoleObj = CardItem
            self.CurSelect = key
            bSelect = true
        end
        CardItem:Init(key, bSelect, value, function(Target, InSelectId)
            self.CurSelect = key
            self:OnSwitchRoleChange(CardItem, Card)
        end)
        CardItem.nForm = 1
        CardItem.ParentUIName = "growth_up"
        CardItem.nTemplateId = UE4.UItemLibrary.GetTemplateId(value.Genre, value.Detail, value.Particular, value.Level)
        self.LeftList:AddItem(CardItem)
    end
    self.LeftList:ScrollIndexIntoView(self.CurSelect-1)
end

function RoleLvUp:OnSwitchRoleChange(InObj, card)
    if self.SwitchRoleObj == InObj then
        return
    end
    if self.SwitchRoleObj then
        self.SwitchRoleObj:SetSelect(false)
    end
    if InObj then
        InObj:SetSelect(true)
    end
    self.SwitchRoleObj = InObj
    local UIRole = UI.GetUI("role")
    if UIRole and card then
        UIRole.pCard = card
        UIRole.pTemplate = UE4.UItem.FindTemplateForID(card:TemplateId())
    end
    self:ChangeCard(card)
    self:PlayChangeEmit()
end

--- 初始化道具列表
function RoleLvUp:InitRoleUpItems()
    self:DoClearListItems(self.UpLvList)
    local ItemDataClass = LoadClass(self.Path)
    -- local Items = RoleCard.GetSecgradeByGDPL(5, 1)
    for _, value in ipairs(RoleCard.UpMat) do
        local pTemplate =  RoleCard.GetItemByGDPL(value[1],value[2],value[3],value[4]) or UE4.UItem.FindTemplate(value[1],value[2],value[3],value[4])
        local NewObj = NewObject(ItemDataClass, self, nil)
        local DelayTime = 0.04*_
        NewObj:Init(pTemplate, RoleCard.AddConsume, RoleCard.SubConsume, RoleCard.CheckConsumAdd, DelayTime)
        NewObj.ItemName = "####"
        self.UpLvList:AddItem(NewObj)
    end
end

---一键选择 一键取消
function RoleLvUp:OneKeySelect()
    if CountTB(RoleCard.tbConsumes) == 0 then
        local MaxLevel, stip = RoleCard.GetMaxLevel(self.CurCard)
        local CurLevel = self.CurCard:EnhanceLevel()
        if CurLevel >= MaxLevel then
            UI.ShowTip(stip)
            return
        end

        local needExp = 0
        while MaxLevel > CurLevel do
            needExp = needExp + Item.GetExp(Item.TYPE_CARD, CurLevel)
            CurLevel = CurLevel + 1
        end
        needExp = needExp - self.CurCard:Exp()

        local haveGold = Cash.GetMoneyCount(Cash.MoneyType_Silver)

        local bHave = false
        for _, value in ipairs(RoleCard.UpMat) do
            local num = me:GetItemCount(value[1], value[2], value[3], value[4])
            if num > 0 then
                local pItem = RoleCard.GetItemByGDPL(value[1], value[2], value[3], value[4])
                if pItem then
                    local pGold = pItem:ConsumeGold()
                    local pExp = pItem:ProvideExp()
                    if not bHave then
                        bHave = true
                        ---金币是否足够
                        if haveGold < pGold then
                            UI.ShowTip("error.gold_not_enough")
                            return
                        end
                    end
                    if pGold > haveGold or needExp <= 0 then
                        break
                    end
                    local snum = math.min(math.ceil(needExp/pExp), math.floor(haveGold/pGold), num)
                    needExp = needExp - (pExp*snum)
                    haveGold = haveGold - (pGold*snum)
                    RoleCard.tbConsumes[pItem] = snum
                end
            end
        end
        if not bHave then
            UI.ShowTip(Text('tip.once_materal_not_enough'))
            return
        end
        EventSystem.TriggerTarget(RoleCard, RoleCard.MaterialsChangeHandle, RoleCard.ExpState.ExpAdd)
    else
        RoleCard.tbConsumes = {}
        EventSystem.TriggerTarget(RoleCard, RoleCard.MaterialsChangeHandle, RoleCard.ExpState.ExpSub)
    end
    self:UpdateUpLvList()
end

function RoleLvUp:UpdateOneKeyText()
    if CountTB(RoleCard.tbConsumes) == 0 then
        if not self.bOneKey then
            self.TxtOneKey:SetText("TxtOneKey")
            self.bOneKey = true
        end
    else
        if self.bOneKey then
            self.TxtOneKey:SetText("TxtOneCancle")
            self.bOneKey = false
        end
    end
end
function RoleLvUp:UpdateUpLvList()
    for i = 1, self.UpLvList:GetNumItems() do
        local Obj = self.UpLvList:GetItemAt(i-1)
        if Obj.Item and Obj.AppointNum then
            local num = RoleCard.tbConsumes[Obj.Item] or 0
            Obj:AppointNum(num)
        end
    end
end

--- 角色名描述
function RoleLvUp:ShowRoleName(InCard)
    self.TxtName:SetText(Text(InCard:I18N()))
    self.TxtTitle:SetText(Text(InCard:I18N()..'_title'))
    SetTexture(self.ImgQuality, Item.RoleColor_short[InCard:Color()])
    SetTexture(self.Logo, InCard:Icon())
end

function RoleLvUp:ChangePreviewRole()
    RoleCard.ModifierModel(nil, self.CurCard, PreviewType.role_growth_up, UE4.EUIWidgetAnimType.Role_LvUp)
end

function RoleLvUp:MaxLvShow(InCard)
    local nMaxLv = Item.GetMaxLevel(InCard)
    if InCard:EnhanceLevel() < nMaxLv then
        return
    end
    self.LvInfo:Set(InCard, 0)
end

---初始化刷新界面数据
function RoleLvUp:InitRoleCardInfo()
    local Exp = RoleCard.GetConsumeExpAndGold()
    self.LvInfo:Set(self.CurCard, Exp)
end

function RoleLvUp:SetConsumRate(InCost, InSum)
    local AddExp, CostCoin = RoleCard.GetConsumeExpAndGold()
    local ConsumRate = CostCoin -- .. "/" .. InSum
    local CurMoney = Cash.GetMoneyCount(Cash.MoneyType_Silver)
    if CurMoney < ConsumRate then
        self.TextConsumRate:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(1, 0, 0, 1))
    else
        self.TextConsumRate:SetColorAndOpacity(UE4.UUMGLibrary.GetSlateColor(0, 0, 0, 1))
    end

    self.TextConsumRate:SetText(ConsumRate)
end
--show 提示界面
---@param IsSuc boolean 升级/突破成功(服务器返回成功消息)
function RoleLvUp:ShowUpLvTip()
    if #RoleCard.CheckAttrChange(1) == 0 then
        UI.ShowTip("ui.UpdataLv_Ok")
        return
    end
    UI.Open("RoleLvTip", self.CurCard, 1000, RoleCard.CheckAttrChange(1), function()
        print("tip.....")
    end)
end

---动态刷新道具可加经验值界面显示数据
function RoleLvUp:UpDateItemsList(InModel)
    local Exp = RoleCard.GetConsumeExpAndGold()
    self.LvInfo:Set(self.CurCard, Exp)
end

---刷新道具金币消耗刷新
function RoleLvUp:UpdateSelectShowDate()
    local AddExp, CostCoin = RoleCard.GetConsumeExpAndGold()
    self:SetConsumRate(CostCoin, Cash.GetMoneyCount(Cash.MoneyType_Silver))
end

function RoleLvUp:UpDateCircleDate()
    --body()
end
---记录升级前的等级
function RoleLvUp:GetProEnhanceLv()
    RoleCard.ItemProEnhanceLv = self.CurCard:EnhanceLevel()
end

function RoleLvUp:OnDisable()
    Preview.Destroy()
    RoleCard.ResetCach()
end

---关闭界面时清除注册事件
function RoleLvUp:OnDestruct()
    --EventSystem.Remove(self.OnLvUpFailHandle)
    EventSystem.Remove(self.MaterialsChangeHandle)
    EventSystem.Remove(self.CustomAttrHandle)
    self:RemoveRegisterEvent()
end


function RoleLvUp:OnClose()
    EventSystem.Remove(self.MaterialsChangeHandle)
    EventSystem.Remove(self.CustomAttrHandle)
    self:RemoveRegisterEvent()
    --EventSystem.Remove(self.OnLvUpFailHandle)
end

return RoleLvUp
