-- ========================================================
-- @File    : uw_arms_outer.lua
-- @Brief   : 武器界面
-- ========================================================
---@class tbClass : UUserWidget
---@field SkillList UTileView
---@field WeaponList UListView
local tbClass = Class("UMG.BaseWidget")
tbClass.tbCurSort = {nIdx = 1, bReverse = false}

local STATE = {}
STATE.HIDE = 0 ---武器列表隐藏
STATE.SHOW = 1 ---武器列表显示

function tbClass:Construct()
    self.ListViewFactory = Model.Use(self)
    BtnAddEvent(self.RoleBtn, function()
        UI.Open("Arms", 1, self.pWeapon, self.InFrom)
    end)
    BtnAddEvent(self.BtnDetails, function()
        if self.nState == STATE.SHOW then
            self:ReplaceWeapon()
        elseif self.nState == STATE.HIDE then
            FunctionRouter.CheckEx(FunctionType.WeaponReplace, function()
                self:ChangeState(STATE.SHOW)
            end)
        end
    end)

    self.tbMainAttr = Weapon.tbShowAttr
    self:DoClearListItems(self.WeaponList)
    self:DoClearListItems(self.ListAtt_1)
    self.AttrListFactory = Model.Use(self, 'UMG/Role/Widget/uw_role_attribute_data')

    self.ListAtt_1:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    -- 排序
    self.tbWeaponSortInfo =
    {
        tbSort = {
            sDesc = 'ui.TxtScreen1',
            tbRule={
                {'ui.TxtRareSort', ItemSort.BagWeaponQualitySort},
                {'ui.item_level', ItemSort.BagWeaponLevelSort},
                {'ui.TxtScreen2', ItemSort.BagItemIdSort}
            }
        },

        --{sDesc:标题文字，rule:筛选类型, tbRule:筛选子项 }
        tbFilter = {
            {
                sDesc='ui.TxtScreen7',
                rule=5,
                tbRule={
                    {'ui.DamageType.3', 3},
                    {'ui.DamageType.4', 4},
                    {'ui.DamageType.5', 5},
                    {'ui.DamageType.6', 6},
                    {'ui.DamageType.7', 7}
                }
            },
        }
    }
    self.WeaponCurSort = self.WeaponCurSort or {tbSort={1, false}, tbFilter=nil}

    BtnAddEvent(self.BtnScreen, function()
        UI.Open('Screen', self.tbWeaponSortInfo, self.WeaponCurSort, function ()
            self:ShowWeaponList(true, self:GetFilterItems())
        end)
    end)
end

---页签激活时调用
function tbClass:OnActive(InCard, InFrom, Click, CharacterCard)
    self.nState = self.nState or STATE.HIDE
    local pCard = nil
    if CharacterCard then
        pCard = CharacterCard
    else
        pCard = RoleCard.GetItem({InCard.Genre,InCard.Detail,InCard.Particular,InCard.Level})
    end

    if pCard == nil then
        return
    end

    ---是否替换武器
    if self.CurrentCard ~= pCard then
        self.CurrentCard = pCard
        self.pWeapon = self:GetEquipWeapon()
    else
        self.pWeapon = self.pWeapon or self:GetEquipWeapon()
    end

    self:ChangeState(self.nState, true)

    --- 详情列表
    self:ShowDetails(self.CurrentCard, self.pWeapon, self.tbMainAttr)

    --- 技能列表
    self:ShowSkillDes(self.pWeapon)

    --- 类别详情
    self:ShowTypeLogo(self.pWeapon)

    --- 角色展示模型
    RoleCard.ModifierModel(nil, self.CurrentCard, PreviewType.role_weapon, UE4.EUIWidgetAnimType.Role_Weapon, function()
        local pParent = UI.GetUI("Role")
        pParent:PlayChangeEmit()
    end)

    self:ShowWeaponList(true, self:GetFilterItems())

    self.InFrom  = InFrom

    if self.CurrentCard and self.CurrentCard:IsTrial() then
        WidgetUtils.Collapsed(self.BtnScreen)
        WidgetUtils.Collapsed(self.BtnDetails)
        WidgetUtils.Collapsed(self.RoleBtn)
    end
    self:PlayAnimation(self.AllEnter)
    self.Basic:PlayAnimation(self.Basic.AllEnter)
end

function tbClass:GetFilterItems()
    local nSort = 1
    local bReverse = false
    local tbFilter = {{}}

    nSort = self.WeaponCurSort.tbSort[1]
    bReverse = self.WeaponCurSort.tbSort[2]
    tbFilter = self.WeaponCurSort.tbFilter or tbFilter

    local tbItems = Copy(Weapon.GetAllWeaponByCard(self.CurrentCard))
    for _, tbCfg in pairs(tbFilter) do
        tbItems = ItemSort:Filter(tbItems, tbCfg)
    end

    if self.tbWeaponSortInfo and self.tbWeaponSortInfo.tbSort then
        tbItems = ItemSort:Sort(tbItems, self.tbWeaponSortInfo.tbSort.tbRule[nSort][2])
    end

    if bReverse then
        ItemSort:Reverse(tbItems)
    end
    return tbItems
end

function tbClass:UpdateBtnState(pCard, pWeapon)
    if not pCard or not pWeapon then return end
    local pEquippedWeapon = pCard:GetSlotWeapon()
    if self.nState == STATE.SHOW then
        if pEquippedWeapon == pWeapon then
            WidgetUtils.Collapsed(self.BtnDetails)
        else
            if not pCard:IsTrial() then
                WidgetUtils.Visible(self.BtnDetails)
            end
            self.TxtJoin:SetText(Text('ui.TxtDialogueConfirm'))
        end
    else
        if not pCard:IsTrial() then
            WidgetUtils.Visible(self.BtnDetails)
        end
        self.TxtJoin:SetText(Text('ui.TxtChange'))
    end
end

--- 详情列表
function tbClass:ShowDetails(InCard, pWeapon, IntbAttr)
    if not pWeapon or not InCard then return end
    self:ShowAttrDes(IntbAttr, pWeapon)

    self:UpdateBtnState(InCard, pWeapon)

    if RoleCard.CheckCardRedDot(InCard, {6}, pWeapon) then
        WidgetUtils.HitTestInvisible(self.RedPoint)
    else
        WidgetUtils.Collapsed(self.RedPoint)
    end
end

--- 技能列表
function tbClass:ShowSkillDes(Weapon)

end

--- 类别详情
function tbClass:ShowTypeLogo(Weapon)

end

function tbClass:SortWeapon(nIdx, tbItems, bReverse)
    local tbSortInfo = self.tbSortInfo[nIdx]
    local tbRes = ItemSort:CardSort(tbItems, tbSortInfo.tbSorts)
    if bReverse and #tbRes > 1 then
        local nLeft = 1
        local nRight = #tbRes
        while (nLeft < nRight) do
            tbRes[nLeft], tbRes[nRight] = tbRes[nRight], tbRes[nLeft]
            nLeft = nLeft + 1
            nRight = nRight - 1
        end
    end
    return tbRes
end

function tbClass:OnClear()
end

function tbClass:OnDisable()
    --self:ChangeState(STATE.HIDE, true)
    self.pWeapon = self:GetEquipWeapon()
end

function tbClass:OnDestruct()
    Weapon.ReplaceCallBack = nil
    Weapon.ExchangeCallBack = nil
    self:OnClear()
end

function tbClass:OnClose()
    self:OnClear()
end

-----------------------------------------------------------------


function tbClass:ChangeState(nState, bForce)
    bForce = bForce or false
    if self.nState == nState and not bForce then return end
    self.nState = nState

    local pParent = UI.GetUI("Role")
    if not pParent then return end

    if self.nState == STATE.HIDE then
        WidgetUtils.Collapsed(self.PanelWeaponList)
        WidgetUtils.Collapsed(self.BtnScreen)
        pParent:ShowSortWidget("Show")
        WidgetUtils.SelfHitTestInvisible(pParent.LeftList)
        WidgetUtils.SelfHitTestInvisible(pParent.RightList)
        WidgetUtils.SelfHitTestInvisible(pParent.RoleBlank1)
        WidgetUtils.SelfHitTestInvisible(pParent.RoleBlank2)
        if self.pWeapon ~= self:GetEquipWeapon() then
            self.pWeapon = self:GetEquipWeapon()
            self:ShowDetails(self.CurrentCard, self.pWeapon, self.tbMainAttr)
            self:ShowSkillDes(self.pWeapon)
            self:ShowWeaponList(true, self:GetFilterItems())
            Preview.PreviewByCardAndWeapon(self.CurrentCard:Id(), self.pWeapon:Id(), PreviewType.role_weapon)
            RoleCard.ResetCach(self.CurrentCard:Id())
        end
    elseif self.nState == STATE.SHOW then
        WidgetUtils.Collapsed(pParent.LeftList)
        WidgetUtils.Collapsed(pParent.RightList)
        WidgetUtils.Collapsed(pParent.RoleBlank1)
        WidgetUtils.Collapsed(pParent.RoleBlank2)
        pParent:ShowSortWidget("UnShow")
        WidgetUtils.SelfHitTestInvisible(self.PanelWeaponList)
        WidgetUtils.Visible(self.BtnScreen)
        if pParent.Title.Push then
            pParent.Title:Push(function() self:ChangeState(STATE.HIDE) end)
        end
    end
    self:UpdateBtnState(self.CurrentCard, self.pWeapon)
end

---恢复
function tbClass:Recover()
    if self.CurrentSelect then
        local pWeapon = self.CurrentSelect.Data.pItem
        local pCurrentWeapon = self:GetEquipWeapon()
        if pWeapon ~= pCurrentWeapon then
            self.pWeapon = pCurrentWeapon
            self.CurrentSelect = nil
            self:ShowDetails(self.CurrentCard, pCurrentWeapon, self.tbMainAttr)
            self:ShowSkillDes(pCurrentWeapon)
            Preview.UpdateWeapon(pCurrentWeapon:Id())
        end
    end
end


---显示武器列表
function tbClass:ShowWeaponList(bAnim,InItems)
    self:DoClearListItems(self.WeaponList)
    local tbW2C = Weapon.GetWeapon2Card()
    local nJumpIndex = 0
    for nIdx, pItem in ipairs(InItems) do
        local tbParam = { pItem = pItem, bSelect = false, pCard = self.CurrentCard, pEquipped = tbW2C[pItem] or nil , bCanSlect = true, uiType = "role"}

        tbParam.SetSelected = function(tb)
            EventSystem.TriggerTarget(tb, "SET_SELECTED")
        end
        local NewObj = self.ListViewFactory:Create(tbParam)

        if self.pWeapon and self.pWeapon:Id() == pItem:Id() then
            tbParam.bSelect = true
            self.CurrentSelect = NewObj
            nJumpIndex = nIdx - 1
        end
        tbParam.OnTouch = function()
            Weapon.Read(pItem)
            EventSystem.TriggerTarget(tbParam, "SET_NEW")
            self:Select(NewObj)
        end
        tbParam.PlayAnimation = function(self)
            EventSystem.TriggerTarget(self, "PLAY_ANIMATION")
        end

        if bAnim then
            UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                {
                    self,
                    function()
                        tbParam:PlayAnimation()
                    end
                },
                0.03 * nIdx,
                false
            )
        end
        self.WeaponList:AddItem(NewObj)
    end
    self.WeaponList:NavigateToIndex(nJumpIndex)
end

function tbClass:ShowAttrDes(IntbAttr, InWeapon)
    ---技能显示
    self.Skilllist:ShowSkillPanel(InWeapon)
    self.Skilllist:ShowAttributePanel(IntbAttr, InWeapon)

    ---1技能显示 2属性显示
    self.ShowType = self.ShowType or 1
    self.Skilllist:SetSelect(self.ShowType)
    self.Skilllist:SetClickEvent(function ()
        if self.ShowType == 1 then
            self.ShowType = 2
        else
            self.ShowType = 1
        end
        self.Skilllist:SetSelect(self.ShowType)
    end)
    ---武器名 武器品质 克制标记
    self.Basic:UpdatePanel(InWeapon)
end

function tbClass:UpdateSkillPanel(pWeapon)
    local cfg = Weapon.GetWeaponConfig(pWeapon)
    local tbSkillID = cfg and cfg.DefaultSkillID or nil
    if tbSkillID then
        local nSkillID = tbSkillID[1]
        local nLevel = pWeapon:Evolue() + 1
        self.TxtSkillName:SetText(Localization.GetSkillName(nSkillID))
        self.TxtSkillInfo:SetContent(SkillDesc(nSkillID, nil, nLevel))
    end

    self.Atktype:ShowSubAttr(pWeapon)
end

--- 武器属性列表
function tbClass:ShowAttrItem(IntbAttr, InWeapon)
    self:DoClearListItems(self.ListAtt_1)
    ---副属性
    --local nNow, sSubType = Weapon.GetSubAttr(InWeapon, InWeapon:EnhanceLevel(), InWeapon:Quality())
    -- local tbParam = {
    --     Cate = sSubType,
    --     ECate = sSubType,
    --     Data = nNow,
    --     ShowBG = idx % 2 ~= 0
    -- }
    -- local pObj = self.AttrListFactory:Create(tbParam)
    -- self.ListAtt_1:AddItem(pObj)


    for _, nType in ipairs(IntbAttr) do
        local Cate = UE4.UUMGLibrary.GetEnumValueAsString("EWeaponAttributeType", nType)
        local tbParam = {
            Cate = Cate,
            ECate = Cate,
            Data = Weapon.ConvertDes(nType, UE4.UItemLibrary.GetWeaponAbilityValueToStr(nType, InWeapon)),
            ShowBG = false
        }
        local pObj = self.AttrListFactory:Create(tbParam)
        self.ListAtt_1:AddItem(pObj)
    end
end

---选择条目更改
---@param InObj UObject 武器条目
function tbClass:Select(InObj)
    if self.CurrentSelect ~= InObj then
        if self.CurrentSelect then
            self.CurrentSelect.Data.bSelect = false
            self.CurrentSelect.Data:SetSelected()
        end
        self.CurrentSelect = InObj
        if self.CurrentSelect  then
            self.CurrentSelect.Data.bSelect = true
            self.CurrentSelect.Data:SetSelected()
        end
        self.pWeapon = self.CurrentSelect.Data.pItem

        self:ShowDetails(self.CurrentCard,self.pWeapon,self.tbMainAttr)
        self:ShowSkillDes(self.pWeapon)

        Preview.UpdateWeapon(self.pWeapon:Id())
    end
end

function tbClass:GetEquipWeapon()
    if not self.CurrentCard then
        print('Error not CurrentCard')
        return
    end
    return self.CurrentCard:GetSlotWeapon()
end

---替换武器
function tbClass:ReplaceWeapon()
    if self.CurrentSelect then
        local pWeapon = self.CurrentSelect.Data.pItem
        if pWeapon == self:GetEquipWeapon() then return end

        if pWeapon:HasFlag(Item.FLAG_USE) then
            local pCard = Weapon.FindCardByWeapon(pWeapon)
            if not pCard then return end
            UI.Open('MessageBox', Text("ui.TxtWeaponTips1", Text(pCard:I18N() .. "_suits")), function()
                Weapon.Req_Exchange(self.CurrentCard, pCard)
            end)
        else
            Weapon.Req_Replace(self.CurrentCard, pWeapon:Id())
        end
    end
end

function tbClass:RefreshUI()
    if not self.pWeapon then return end
    self:ShowDetails(self.CurrentCard, self.pWeapon, self.tbMainAttr)
    self:ShowSkillDes(self.pWeapon)
    UI.ShowTip("tip.replace_weapon_succ")
    self:ShowWeaponList(true, self:GetFilterItems())
end

function tbClass:OnReciveExchange()
    self:RefreshUI()
end

function tbClass:OnReciveReplace()
    self:RefreshUI()
end

return tbClass
