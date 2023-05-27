-- ========================================================
-- @File    : umg_fashion.lua
-- @Brief   : 角色时装主界面
-- ========================================================
--InIndex,InSelect,InTemplate,InClick,Intype
local tbFashion = Class("UMG.BaseWidget")

function tbFashion:Construct()
    self.Factory = Model.Use(self)
    self.CardItemPath = "/Game/UI/UMG/Role/Widgets/uw_role_role_data.uw_role_role_data"

    BtnAddEvent(
        self.BtnChange,
        function()
            local skinTemplate = self:GetSkinCfg(Fashion.SelectSkin)
            local pSkin = Fashion.GetSkinItem({skinTemplate.Genre, skinTemplate.Detail, skinTemplate.Particular, skinTemplate.Level})
            if not pSkin then return end
            Fashion.ChangeSkinReq(
                self.pRCard,
                pSkin,
                function()
                    self.CurEquip = Fashion.SelectSkin
                    self:PlayAnimation(self.Already_worn)
                    self:EquipItem()
                    self:SetBtnState(2)
                    self:UpdateMallState()
                end
            )
        end
    )

    BtnAddEvent(
        self.BtnBuy,
        function()
            if self.GetType ~= 2 then
                return
            end

            self:DoPurchase()
        end
    )

    BtnAddEvent(
        self.BtnSee,
        function()
            self:RefreshCharacterModel(PreviewType.role_fashion_see)
            Preview.UpdateCharacterSkin()
            UI.Open("RoleFashionSee", function()
                self:RefreshCharacterModel(PreviewType.role_fashion)
            end)
        end
    )

    BtnAddEvent(
        self.BtnSize,
        function()
            if self.CurMode == 0 then
                self:RefreshCameraType(PreviewType.role_fashion_1)
            elseif self.CurMode == 1 then
                self:RefreshCameraType(PreviewType.role_fashion)
            end
            self.CurMode = (self.CurMode + 1) % 2
        end
    )

    BtnAddEvent(
        self.Btn2D,
        function()
            Preview.Destroy()
            UI.Open("RoleFashion2D", {pRole = self.pRCard, Index = self.CurSelectItem.Data.Index}, function()
                self:RefreshCharacterModel(PreviewType.role_fashion)
            end)
        end
    )

    if IsMobile() or IsEditor then
        WidgetUtils.Visible(self.BtnSee)
    else
        WidgetUtils.Collapsed(self.BtnSee)
    end

    self.CurMode = 0

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
                rule=10,
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

function tbFashion:OnOpen(InParam, InCloseCallback)
    if not InParam then
        return
    end
    self.LeftList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self.ListFashion:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    PreviewScene.Enter(PreviewType.role_lvup)
    self.InCloseCallback = InCloseCallback
    self.EnterFromRole = InParam.EnterFromRole
    self.bInit = true

    --如果传进来模板 默认选中这个模板
    self.CharacterTemplate = InParam.CharacterTemplate or Fashion.SelectCharacterTemplate
    Fashion.SelectCharacterTemplate = self.CharacterTemplate
    self.tbMallConfig = InParam.tbMallConfig
    self.pRCard = RoleCard.GetItem({self.CharacterTemplate.Genre, self.CharacterTemplate.Detail, self.CharacterTemplate.Particular, self.CharacterTemplate.Level})

    self:UpdateRoleInfo(InParam.SkinIndex)

    if self.EnterFromRole then
        self.RoleCurSort = InParam.RoleCurSort or self.RoleCurSort
        if InParam.tbCharacterCard then
            self.tbCharacterCard = {}
            for _, card in pairs(InParam.tbCharacterCard) do
                if not card:IsTrial() then
                    table.insert(self.tbCharacterCard, card)
                end
            end
        elseif InParam.Rolelist then
            self.Rolelist = {}
            for _, template in pairs(InParam.Rolelist) do
                if RoleCard.GetItem({template.Genre, template.Detail, template.Particular, template.Level}) then
                    table.insert(self.Rolelist, template)
                end
            end
        else
            --获取拥有的角色
            self.Rolelist = RoleCard.GetAllCharacter(2)
        end
        WidgetUtils.Visible(self.BtnScreen)
    else
        self.Rolelist = {InParam.CharacterTemplate}
        WidgetUtils.Collapsed(self.BtnScreen)
    end

    if self.Rolelist then
        self:ShowCharacterList(self.Rolelist)
    else
        self:UpdateCharacterList()
    end
end

function tbFashion:UpdateCharacterList()
    if not self.tbCharacterCard and not self.Rolelist then
        return
    end

    if self.EnterFromRole then
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
            self.Rolelist = RoleCard.GetAllCharacter(2)
            local tbItem = self:GetFilterItems(self.Rolelist)
            if #tbItem <= 0 then
                UI.ShowMessage("ui.TxtScreen5")
                self.RoleCurSort = self.LastRoleCurSort
                tbItem = self:GetFilterItems(self.Rolelist)
            end
            self.Rolelist = tbItem
            self:ShowCharacterList(tbItem)
        end
    else
        self:ShowCharacterList(self.Rolelist)
    end

    self.LastRoleCurSort = self.RoleCurSort
end

function tbFashion:GetFilterItems(tbItems)
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
function tbFashion:ShowCharacterListByTbCard(tbCard)
    if not tbCard or #tbCard == 0 then
        return
    end
    self:DoClearListItems(self.LeftList)
    if not self.pRCard or not RoleCard.CharacterCardIsInTable(self.pRCard, tbCard) then
        self.pRCard = tbCard[1]
        self.CharacterTemplate = UE4.UItem.FindTemplateForID(tbCard[1]:TemplateId())
        Fashion.SelectCharacterTemplate = self.CharacterTemplate
        self:UpdateRoleInfo()
        local UIRole = UI.GetUI("role")
        if UIRole and self.CharacterTemplate then
            UIRole.pCard = self.pRCard
            UIRole.pTemplate = self.CharacterTemplate
        end
    end
    self.CurSelect = 1
    local pCardItem = LoadClass(self.CardItemPath)
    for key, card in ipairs(tbCard) do
        local CardItem = NewObject(pCardItem, self, nil)
        local bSelect = false
        if self.pRCard and card:Id() == self.pRCard:Id() then
            self.SwitchRoleObj = CardItem
            self.CurSelect = key
            bSelect = true
        end
        CardItem:Init(key, bSelect, nil, function(Target, InSelectId)
            self.CurSelect = key
            self.pRCard = card
            self.CharacterTemplate = UE4.UItem.FindTemplateForID(card:TemplateId())
            Fashion.SelectCharacterTemplate = self.CharacterTemplate
            self:OnSwitchRoleChange(CardItem)
        end, card)
        CardItem.nForm = 1
        CardItem.ParentUIName = "fashion"
        CardItem.nTemplateId = card:TemplateId()
        self.LeftList:AddItem(CardItem)
    end
    self.LeftList:ScrollIndexIntoView(self.CurSelect-1)
end

function tbFashion:ShowCharacterList(tbItems)
    if not tbItems or #tbItems == 0 then
        return
    end
    self:DoClearListItems(self.LeftList)
    if not self.CharacterTemplate or not RoleCard.TemplateIsInTable(self.CharacterTemplate, tbItems) then
        self.pRCard = RoleCard.GetItem({tbItems[1].Genre, tbItems[1].Detail, tbItems[1].Particular, tbItems[1].Level})
        self.CharacterTemplate = tbItems[1]
        Fashion.SelectCharacterTemplate = self.CharacterTemplate
        self:UpdateRoleInfo()
        local UIRole = UI.GetUI("role")
        if UIRole and self.CharacterTemplate then
            UIRole.pCard = self.pRCard
            UIRole.pTemplate = self.CharacterTemplate
        end
    end
    self.CurSelect = 1
    local pCardItem = LoadClass(self.CardItemPath)
    for key, value in ipairs(tbItems) do
        local CardItem = NewObject(pCardItem, self, nil)
        local bSelect = false
        if self.CharacterTemplate.Genre == value.Genre and
            self.CharacterTemplate.Detail == value.Detail and
            self.CharacterTemplate.Particular == value.Particular and
            self.CharacterTemplate.Level == value.Level then
            self.SwitchRoleObj = CardItem
            self.CurSelect = key
            bSelect = true
        end
        local pTemplate =  UE4.UItemLibrary.GetItemTemplateByGDPL(value.Genre, value.Detail, value.Particular, value.Level)
        CardItem:Init(key, bSelect, pTemplate, function(Target, InSelectId)
            local Card = RoleCard.GetItem({value.Genre, value.Detail, value.Particular, value.Level})
            self.pRCard = Card
            self.CharacterTemplate = UE4.UItem.FindTemplate(value.Genre,value.Detail,value.Particular,value.Level)
            Fashion.SelectCharacterTemplate = self.CharacterTemplate
            self:OnSwitchRoleChange(CardItem)
        end)
        CardItem.nForm = 1
        CardItem.ParentUIName = "fashion"
        CardItem.nTemplateId = UE4.UItemLibrary.GetTemplateId(value.Genre, value.Detail, value.Particular, value.Level)
        self.LeftList:AddItem(CardItem)
    end
    self.LeftList:ScrollIndexIntoView(self.CurSelect-1)
end
function tbFashion:OnSwitchRoleChange(InObj)
    if self.SwitchRoleObj == InObj then
        return
    end
    if self.SwitchRoleObj then
        self.SwitchRoleObj:SetSelect(false)
    end
    if InObj then
        InObj:SetSelect(true)
    end
    if not self.bInit then
        self:PlayAnimation(self.tab_animation)
    else
        self.bInit = false
    end
    self.SwitchRoleObj = InObj
    local UIRole = UI.GetUI("role")
    if UIRole and self.CharacterTemplate then
        UIRole.pCard = self.pRCard
        UIRole.pTemplate = self.CharacterTemplate
    end
    self:UpdateRoleInfo()
end

---初始化所选择的皮肤
function tbFashion:InitSelectSkin()
    if self.pRCard then
        local pSkinItem = self.pRCard:GetSlotItem(5)
        self.CurEquip = pSkinItem and pSkinItem:Level() or 1
    else
        self.CurEquip = 1
    end
    self:SetBtnState()
end

---更新皮肤list
function tbFashion:UpdateList(InSelect)
    self:DoClearListItems(self.ListFashion)
    self.tbAllFashionList = {}
    for _, v in pairs(self.SkinList or {}) do
        local HaveSkin = me:GetItemCount(v.Genre, v.Detail, v.Particular, v.Level) > 0
        local tbParam = {
            Index = v.Level,
            Equip = self.CurEquip or 1,
            Skin = v,
            HaveSkin = HaveSkin,
            bShow = InSelect == v.Level,
            Click = function(InItem, bInit)
                self:OnSelect(InItem, bInit)
                self:UpdateMallState()
            end,
            SetEquipItem = function(InItem)
                self:SetEquipItem(InItem)
            end
        }
        local newFashion = self.Factory:Create(tbParam)
        self.ListFashion:AddItem(newFashion)
        table.insert(self.tbAllFashionList, newFashion)
    end
    self.ListFashion:PlayAnimation()
end

---设置按钮状态
---@param InState integer 数字对应的按钮 1->更换按钮 2->更换按钮(灰色) 3->去获取按钮 4->获取按钮(灰色) 
--- 5->购买按钮  6->未获取角色
function tbFashion:SetBtnState(InState)
    WidgetUtils.Collapsed(self.BtnChange)
    WidgetUtils.Collapsed(self.BtnNoChange)
    WidgetUtils.Collapsed(self.BtnBuy)
    WidgetUtils.Collapsed(self.BtnNoBuy)
    WidgetUtils.Collapsed(self.BtnNoRole)
    if InState == 1 then
        WidgetUtils.Visible(self.BtnChange)
    elseif InState == 2 then
        WidgetUtils.Visible(self.BtnNoChange)
    elseif InState == 3 then
        WidgetUtils.Visible(self.BtnBuy)
        self.TxtObtain:SetText(Text("TxtShopFashion3"))
    elseif InState == 4 then
        WidgetUtils.Visible(self.BtnNoBuy)
    elseif InState == 5 then
        WidgetUtils.Visible(self.BtnBuy)
        self.TxtObtain:SetText(Text("TxtShopPurchase"))
    elseif InState == 6 then
        WidgetUtils.Visible(self.BtnNoRole)
    end
end

---获取皮肤的Template
---@param Level integer 皮肤的Level
---@return table 指定皮肤的Template
function tbFashion:GetSkinCfg(Level)
    if not self.SkinList then
        return
    end
    for _, v in pairs(self.SkinList) do
        if v.Level == Level then
            return v
        end
    end
end

---选择皮肤
function tbFashion:OnSelect(FashionItem, bInit)
    if self.CurSelectItem == FashionItem or not FashionItem then
        return
    end
    if self.CurSelectItem then
        self.CurSelectItem:OnSelect(false, bInit)
    end
    FashionItem:OnSelect(true, bInit)
    self.CurSelectItem = FashionItem
    local Index = FashionItem.Data.Index
    local template = self:GetSkinCfg(Index)
    local pItem = Fashion.GetSkinItem({template.Genre, template.Detail, template.Particular, template.Level})
    self.GetType = template.GetType

    --- 原皮需隐藏查看立绘按钮 其他显示
    if Index == 1 then
        WidgetUtils.Collapsed(self.Btn2D)
    else
        WidgetUtils.Visible(self.Btn2D)
    end

    Preview.UpdateCharacterSkin(template.AppearID)
    self:PlayChangeEmit()
    self.TxtName:SetText(Text(template.I18n))
    self.TxtDetail:SetText(Text(template.I18n.."_des"))
    self.TxtNum:SetText(Text(string.format("%02d", template.Level)))
    if self.pRCard then
        if pItem then
            if self.CurEquip == Index then
                self:SetBtnState(2)
            else
                self:SetBtnState(1)
            end
        else
            self.GetWay = template.GetWay
            if self.GetType == 2 then
                local info = IBLogic.GetIBGoods(self.GetWay)
                if info then
                    self:SetBtnState(3)
                else
                    self:SetBtnState(4)
                end
            else
                self:SetBtnState(4)
            end
        end
    else
        self:SetBtnState(6)
    end
    self.TxtInitiate:SetText(Text(Fashion.EGetType[self.GetType]))
    Fashion.SelectSkin = Index
end

--旋转
function tbFashion:OnRotate(Value)
    if self.Actor then
        local NowRot = self.Actor:K2_GetActorRotation()
        local NewRot = NowRot + UE4.FRotator(0, 1, 0) * Value * 0.5
        self.Actor:K2_SetActorRotation(NewRot, false)
    end
end

--选择特效
function tbFashion:PlayChangeEmit()
    local EmitLoc = UE4.FVector(0,0,0)
    if Preview.GetModel() then
        EmitLoc = Preview.GetModel():K2_GetActorLocation()
        EmitLoc.Z = 0
    end
    local tbTransform = {EmitLoc = EmitLoc, EmitRot = UE4.FRotator(0,0,0), EmitScale = UE4.FVector(1, 1, 1)}
    UE4.UGameLibrary.SpawnEmitterAtLocation(GetGameIns(), self.SpawnEmit, tbTransform.EmitLoc, tbTransform.EmitRot, tbTransform.EmitScale)
    Audio.PlaySounds(3006)
end

function tbFashion:UpdateRoleInfo(SkinIndex)
    --初始化角色皮肤列表
    self.SkinList = Fashion.GetCharacterSkinTemplates(self.CharacterTemplate.Detail, self.CharacterTemplate.Particular)

    --筛选
    self:FilterMallSkinList()

    -- 刷新模型
    Preview.PreviewByGDPL(UE4.EItemType.CharacterCard ,self.CharacterTemplate.Genre,self.CharacterTemplate.Detail,self.CharacterTemplate.Particular,self.CharacterTemplate.Level, PreviewType.role_fashion)
    self:PlayChangeEmit()

    -- 记录初始Rotation
    self.Actor = Preview.GetModel()
    self.DefaultRot = self.Actor:K2_GetActorRotation()
    self.Interaction:Init(self, self.Actor)

    --初始化皮肤列表
    Fashion.SelectSkin = 0
    self:InitSelectSkin()
    self:UpdateList(SkinIndex or self.CurEquip)
    self:UpdateMallState()
end

function tbFashion:SetEquipItem(InItem)
    self.CurEquipItem = InItem
end

function tbFashion:EquipItem()
    if self.CurEquipItem and self.CurEquipItem.UpdateEquipState then
        self.CurEquipItem:UpdateEquipState(false)
    end

    self.CurEquipItem = self.CurSelectItem
    if self.CurEquipItem and self.CurEquipItem.UpdateEquipState then
        self.CurEquipItem:UpdateEquipState(true)
    end
end

function tbFashion:OnClose()
    Fashion.SelectSkin = 0
    self:GetOwningPlayer():FOV(0)
    Preview.Destroy()
    if self.InCloseCallback then
        self.InCloseCallback()
    end
end

function tbFashion:RefreshCharacterModel(InPreviewType)
    Preview.PreviewByGDPL(UE4.EItemType.CharacterCard ,self.CharacterTemplate.Genre,self.CharacterTemplate.Detail,self.CharacterTemplate.Particular,self.CharacterTemplate.Level, InPreviewType)
    self.Actor = Preview.GetModel()
    self.Interaction:BindActor(self.Actor)
    local template = self:GetSkinCfg(Fashion.SelectSkin)
    if template then
        Preview.UpdateCharacterSkin(template.AppearID)
    end
end

function tbFashion:RefreshCameraType(InPreviewType)
    Preview.PlayCameraAnimByCfgByID(0, InPreviewType)
end

function tbFashion:OnByGoodsUpdate()
    self:UpdateList()
    if self.pRCard then
        self:SetBtnState(1)
    else
        self:SetBtnState(6)
    end
    self:UpdateMallState()
    WidgetUtils.Collapsed(self.ShopTips)
end

----商城购买相关处理
--判断商城显示 
function tbFashion:CheckMallShow()
    if not self.tbMallConfig then --是否商城跳转的界面
        return
    end

    local tbSkinItem = nil
    local tbItemList = IBLogic.GetSkinItem(self.tbMallConfig)
    if tbItemList and #tbItemList > 0 then
        tbSkinItem = tbItemList[1]
        if not tbSkinItem or tbSkinItem[1] ~= Item.TYPE_CARD_SKIN then 
            tbSkinItem = nil
        end
    end

    if not tbSkinItem then return end

    --已购买
    if Fashion.CheckSkinItem(tbSkinItem) then
        return false, tbSkinItem
    end

    return true, tbSkinItem
end

--筛选皮肤  只留初始皮肤和购买的皮肤
function tbFashion:FilterMallSkinList()
    if not self.SkinList then return end

    local bRet, tbSkinItem = self:CheckMallShow()
    if not bRet then --是否商城需要的显示
        return
    end

    --获取商城购买的物品
    local tbList = {}
    for k,v in pairs(self.SkinList) do
        if v.Level == 1 then
            table.insert(tbList, v)
        elseif v.Particular == tbSkinItem[3] and v.Level == tbSkinItem[4] then
            table.insert(tbList, v)
        end
    end
    self.SkinList = tbList
end

--设置商城相关的状态
function tbFashion:UpdateMallState()
    local bRet, tbSkinItem = self:CheckMallShow()
    if not bRet then --是否商城需要的显示
        return
    end

    if not self.CurSelectItem then return end

    local template = self.CurSelectItem.Data.Skin
    if template.Genre ~= tbSkinItem[1] or template.Detail~= tbSkinItem[2]
        or template.Particular ~= tbSkinItem[3] or template.Level ~= tbSkinItem[4] then
            return
    end

    --购买
    self:SetBtnState(5)
end

--设置商城进来初始选中皮肤
function tbFashion:ShowOne()
    local _, tbSkinItem = self:CheckMallShow()
    if not self.tbMallConfig or not tbSkinItem then --是否商城跳转的界面
        return
    end

    if not self.tbAllFashionList then return end
    if self.CurSelectItem then return end --目前没有选中的皮肤

    for i,v in ipairs(self.tbAllFashionList) do --选中跳转的皮肤
        if v.Data.Skin.Genre == tbSkinItem[1] and v.Data.Skin.Detail== tbSkinItem[2]
        and v.Data.Skin.Particular == tbSkinItem[3] and v.Data.Skin.Level == tbSkinItem[4] then
                v.Data.bShow = true
                break
        end
    end
end

--购买
function tbFashion:DoPurchase()
    if not self.tbMallConfig then --是否商城跳转的界面
        --跳转 皮肤商店
        if IBLogic.GotoMall(IBLogic.Tab_IBSkin) then
            UI.Close(self)
        end
        return
    end

    local tbSkinItem = nil
    local tbItemList = IBLogic.GetSkinItem(self.tbMallConfig)
    if tbItemList and #tbItemList > 0 then 
        tbSkinItem = tbItemList[1]
        if not tbSkinItem or tbSkinItem[1] ~= Item.TYPE_CARD_SKIN then 
            tbSkinItem = nil
        end
    end

    if not tbSkinItem then 
        UI.ShowTip("error.BadIBGoodId")
        return 
    end

    --已购买
    if Fashion.CheckSkinItem(tbSkinItem) then 
        UI.ShowTip("ui.Mall_Limit_Buy")
        return
    end

    if not self.CurSelectItem then return end
    local template = self.CurSelectItem.Data.Skin
    if template.Genre ~= tbSkinItem[1] or template.Detail~= tbSkinItem[2]
        or template.Particular ~= tbSkinItem[3] or template.Level ~= tbSkinItem[4] then
            UI.ShowTip("error.BadIBGoodId")
            return
    end

    local bUnlock, tbDes = Condition.Check(self.tbMallConfig.tbCondition)
    if not bUnlock then
        if tbDes and #tbDes >= 1 then
            UI.ShowTip(tbDes[1])
        end
        return
    end

    local nStartTime = self.tbMallConfig.nStartTime
    local nEndTime = self.tbMallConfig.nEndTime

    if not IsInTime(nStartTime, nEndTime) then
        UI.ShowTip("tip.ItemExpirated")
        return
    end

    local isok, id, num = self:CheckPrice()
    if isok then
        if self.tbMallConfig.nAddiction > 0 then
            UI.Open("MessageBox", Text("ui.WarningTips"),
                function()
                    self:DoRealBuy()
                end
            )
        else
            self:DoRealBuy()
        end
        return
    end

    if id == Cash.MoneyType_Gold then   --兑换
        UI.Open("MessageBox", string.format(Text("tip.exchange_jump_mall"), Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Gold).sName)),
                function() --跳转数据金商店
                    CashExchange.ShowUIExchange(Cash.MoneyType_Gold)
                end
            )
    elseif id == Cash.MoneyType_Money then   --前往商店比特金购买界面
        UI.Open("MessageBox", string.format(Text("tip.exchange_jump_shop"), Text(Cash.GetMoneyCfgInfo(Cash.MoneyType_Money).sName)),
            function() --跳转比特金商店
                CashExchange.ShowUIExchange(Cash.MoneyType_Money)
            end
        )
    else
        UI.ShowMessage("tip.gold_not_enough")
    end
end

--根据
function tbFashion:DoRealBuy()
    if IBLogic.CheckProductSellOut(self.tbMallConfig.nGoodsId) then 
        UI.ShowTip("tip.Mall_Limit_Buy")
        return 
    end

    IBLogic.DoBuyProduct(self.tbMallConfig.nType, self.tbMallConfig.nGoodsId)
end

---价格检查
function tbFashion:CheckPrice()
    local priceInfo = IBLogic.GetRealPrice(self.tbMallConfig)
    if priceInfo then
        priceInfo = {priceInfo}
    end

    if not priceInfo then return true end

    for _, v in pairs(priceInfo) do
        local havenum = 0
        local disPrice = v[#v]
        if #v >= 5 then
            havenum = me:GetItemCount(v[1], v[2], v[3], v[4])
        else
            if v[1] == Cash.MoneyType_RMB then
                return true
            end

            havenum = Cash.GetMoneyCount(v[1])
        end
        if havenum < disPrice then
            Audio.PlayVoices("NoMoney")
            return false, v[1], v[2]
        end
    end
    return true
end

return tbFashion 