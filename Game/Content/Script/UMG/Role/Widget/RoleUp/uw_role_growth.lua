-- ========================================================
-- @File    : umg_tbClass.lua
-- @Brief   : 养成界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")
tbClass.AttrPath = "UMG/Role/Widget/uw_role_attribute_data"

--技能数据
local SkillItem = {"SkillName", "ActiveTag", "SkillIcon"}

tbClass.tbItemDes = {
    UE4.EAttributeType.Health,
    UE4.EAttributeType.Attack,
    UE4.EAttributeType.Defence,
    UE4.EAttributeType.Vigour,
    UE4.EAttributeType.Criticalvalue,
    UE4.EAttributeType.Criticaldamage
}

function tbClass:Construct()
    self.tbSkill = {self.Skill1,self.Skill1,self.Skill3,self.Qte,self.Rush,}
    self.NewSkillItem = Model.Use(self)
    BtnAddEvent(self.RoleBtn,  function()
            if self.CurCard then
                UI.Open("RoleUpLv", self.CurCard)
                return
            else
                UI.ShowMessage("tip.no_current_card")
                return
            end
        end
    )
    self.TxtReUp:SetText(Text("TxtReUp"))

    BtnAddEvent(self.BtnFashion, function()
        local RoleUI = UI.GetUI("role")
        if RoleUI and RoleUI:IsOpen() then
            RoleUI:OpenFashion()
        end
    end)
end

function tbClass:OnInit()
    EventSystem.Remove(self.ChangeSkillDetailHandle)
    self.ChangeSkillDetailHandle = EventSystem.OnTarget(RoleCard, RoleCard.ShowSkillDetailHandle, function(Target, bShow)
        self:ChangeActorState(not bShow)
        self:ShowPanelBtn(bShow)
    end)
end

function tbClass:ShowPanelBtn(bShow)
    if not self.CurCard or self.CurCard:IsTrial() then
        bShow = false
    elseif bShow == nil then
        bShow = true
    end
    if bShow then
        WidgetUtils.Visible(self.CultiSys)
    else
        WidgetUtils.Collapsed(self.CultiSys)
    end
end

--- 预览信息界面
function tbClass:InfoDes(InCard)
    self:Updatecarddate(InCard)
end

function tbClass:OnActive(pRole, InForm, Click, pCard)
    if pCard then
        self.CurTemplate = UE4.UItem.FindTemplateForID(pCard:TemplateId())
        if InForm == 5 then
            self.CurCard = nil
        else
            self.CurCard = pCard
        end
    else
        self.CurTemplate = pRole
        self.CurCard = RoleCard.GetItem({pRole.Genre,pRole.Detail,pRole.Particular,pRole.Level})
    end

    if FunctionRouter.IsOpenById(FunctionType.RoleLevelUP) then
        WidgetUtils.Visible(self.RoleBtn)
        -- WidgetUtils.Visible(self.BtnFashion)
    else
        WidgetUtils.Collapsed(self.RoleBtn)
        -- WidgetUtils.Collapsed(self.BtnFashion)
    end
    WidgetUtils.Collapsed(self.BtnFashion)
    self:SkillItem(self.CurTemplate)
    self:ShowPanelBtn()

    --- 角色展示模型
    RoleCard.ModifierModel(self.CurTemplate, self.CurCard, PreviewType.role_lvup, UE4.EUIWidgetAnimType.Role_LvUp, function()
        self.RoleRotate:SetModel(Preview.GetModel())
        if not self.CurCard then
            self:UpdateDefaultSkin(self.CurTemplate)
        end
    end)

    local pParent = UI.GetUI("Role")
    if not pParent then return end
    pParent:ShowSortWidget("Show")
    self:OnInit()

    if self.CurCard then
        self:ChangeActorState(false)
        self:ChangeLockState(1)
        self.SkillWidget:OnActive(self.CurTemplate, InForm, Click, pCard)
        --- 角色名描述
        self.SkillWidget:ShowRoleName(self.CurCard)
        --- 武器信息
        self.SkillWidget:ShowWeaponInfo(self.CurCard:GetSlotWeapon())
        --- 突破等级
        self.AttWidget:ShowActived(self.CurCard)
        --- 战力描述
        self.AttWidget:Updatecarddate(self.CurCard)
        --- 属性列表
        self.AttWidget:LvAttrItem(self.CurCard)
        --- 点击是事件
        self.AttWidget:DetailClickCall(function()
            UI.Open("Detail", self.CurTemplate, self.CurCard)
        end)
    else
        self:ChangeActorState(true)
        self:ChangeLockState(2)
        self.UnLockSys:OnOpen(pRole, Click, InForm)
    end

    --- 动画刷新
    self:PlayAnimation(self.AllEnter)
    self:UpdateRedDot()
end

---手动刷新一下默认皮肤
function tbClass:UpdateDefaultSkin(Template)
    if not Template then
        return
    end
    local skilitem = UE4.UItem.FindTemplate(7, Template.Detail, Template.Particular, 1)
    if skilitem then
        Preview.UpdateCharacterSkin(skilitem.AppearID)
    end
end

function tbClass:UpdateRedDot()
    if RoleCard.CheckCardRedDot(self.CurCard, {3}) then
        WidgetUtils.HitTestInvisible(self.RedPoint)
    else
        WidgetUtils.Collapsed(self.RedPoint)
    end

    if Fashion.CheckRedPointByCard(self.CurCard) then
        WidgetUtils.HitTestInvisible(self.RedPoint1)
    else
        WidgetUtils.Collapsed(self.RedPoint1)
    end
end

function tbClass:ChangeLockState(InLock)
    WidgetUtils.Collapsed(self.UnLockSys)
    WidgetUtils.Collapsed(self.PanelSkill)
    WidgetUtils.Collapsed(self.AttWidget)
    WidgetUtils.Collapsed(self.SkillWidget)

    if InLock == 1 then
        WidgetUtils.SelfHitTestInvisible(self.AttWidget)
        WidgetUtils.SelfHitTestInvisible(self.SkillWidget)
    else
        WidgetUtils.SelfHitTestInvisible(self.UnLockSys)
    end
end

--- 属性列表
function tbClass:LvAttrItem(InItem)
    local AttrItem = Model.Use(self,self.AttrPath)
    self.ListAtt:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden);
    self.ListAtt:ClearListItems()
    for index, value in pairs(self.tbItemDes) do
        local sCate = UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", value)
        local function ShowUnit(Index)
            if Index == 6 then
                return TackleDecimal(self:InitRoleData(InItem,value))
            else
                return TackleDecimal(self:InitRoleData(InItem,value))
            end
        end
        local tbParam = {
            Cate = sCate, --self:InitRoleCate(Cate),
            ECate = sCate,
            Data = ShowUnit(index),
        }
        local NewAttrInfo = AttrItem:Create(tbParam)  -- NewObject(AttrItem, self, nil)
        self.ListAtt:AddItem(NewAttrInfo)
    end
end

--- 技能列表
function tbClass:SkillItem(InItem)
    -- print('g-d-p-l',InItem)-- InItem:Genre(),InItem:Detail(),InItem:Particular(),InItem:Level())
    if not InItem then return end
    local Skills, SkillTags = RoleCard.GetItemShowSkills(InItem)
    for index, value in ipairs(self.tbSkill) do
        local tbParam = {
            bTag = true,
            --- 需要确保添加技能为5种
            nSkillId = Skills[index] or 0,
            sSkillTag = SkillTags[index] or '',
            fClickFun = function(Id)
                UI.Open("SkillTip",InItem, Id,index)
            end
        }
        value:SetStyleBySkill(index)
        value:SetTxtTag(SkillTags[index] or '')
        self.tbSkill[index]:OnOpen(tbParam)
    end
end

function tbClass:InitRoleCate(InValue)
    local sTxt = Text("attribute." .. InValue)
    return sTxt
end

-- function tbClass:InitRoleData(InCard,InValue)
--     local strRoleAttr, strWeaponAttr, strLogisticAttr , strTotal = UE4.UItemLibrary.GetSingleTotalValueToStr(InValue,InCard)
--     local data = strTotal --TackleDecimal(fRoleAttr + fWeaponAttr + fLogisticAttr)
--     return data
-- end

-- function tbClass:SetSingleText(InText, InValue)
--     InText:SetText(InValue)
-- end

function tbClass:SetComplexText(InText, InCurValue, InSumValue)
    InText:SetText(InCurValue .. "/" .. InSumValue)
end


--- 角色名描述
function tbClass:ShowRoleName(InCard)
    self.TxtName:SetText(Text(InCard:I18N()))
    self.TxtTitle:SetText(Text(InCard:I18N()..'_title'))
end


-- --角色战力展示界面数据
-- function tbClass:Updatecarddate(InCard)
--     if not InCard then return end
--     self:SetSingleText(self.TexBatPower, Item.Zhanli_CardTotal(InCard))
-- end


function tbClass:ChangeState(Index)
    local Item = self.LeftList:GetItemAt(Index)
    Item.bSelect = true
end

function tbClass:ChangeActorState(InShowTip)
    if InShowTip then
        WidgetUtils.Collapsed(self.AttWidget)
        WidgetUtils.Collapsed(self.SkillWidget)
        WidgetUtils.Collapsed(self.UnLockSys)
    else
        if self.CurCard then
            WidgetUtils.SelfHitTestInvisible(self.AttWidget)
            WidgetUtils.SelfHitTestInvisible(self.SkillWidget)
        else
            WidgetUtils.SelfHitTestInvisible(self.UnLockSys)
        end
    end
end

function tbClass:Clear()
    self.RoleRotate:SetModel(nil)
    self:ChangeActorState(true)
    EventSystem.Remove(self.ChangeSkillDetailHandle)
    self.ChangeSkillDetailHandle = nil
end

function tbClass:OnDestruct()
    self:Clear()
end

function tbClass:OnDisable()
    self:Clear()
end

function tbClass:OnClose()
    self:Clear()
end

return tbClass
