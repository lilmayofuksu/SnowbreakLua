-- ========================================================
-- @File    : uw_role_original.lua
-- @Brief   : 未解锁角色界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbLockClass = Class("UMG.BaseWidget")

function tbLockClass:Construct()
    self.BtnUnlock.OnClicked:Add(self, function()
        if self.Click then
            self.Click()
        end
    end)

    self.BtnGet.OnClicked:Add(self, function()
        UI.ShowTip("tip.expect next version")
        -- FunctionRouter.GoTo(7)
    end)

    self.BtnUnlockGrey.OnClicked:Add(self, function()
        UI.ShowTip(Text("tip.role_material_not_enough"))
    end)

    self.tbSkill = {self.Skill1, self.Skill1, self.Skill2, self.Qte, self.Rush}
    self.tbSkillType = {RoleCard.SkillType.NormalSkill, RoleCard.SkillType.NormalSkill, RoleCard.SkillType.BigSkill, RoleCard.SkillType.QTESkill, RoleCard.SkillType.NormalSkill}
end

function tbLockClass:OnOpen(InCharacter, InClick, InForm)
    if not InCharacter then return end
    self.Template = InCharacter
    self.Click = InClick

    local gdplArr = InCharacter.PiecesGDPLN
    local function gdpln(InArr)
        if InArr:Length()>1 then
            return InArr:Get(1), InArr:Get(2), InArr:Get(3), InArr:Get(4),InArr:Get(5)
        end
    end
    local g,d,p,l,n = gdpln(gdplArr)
    local function bEnough(G,D,P,L,N)
        if me:GetItemCount(G,D,P,L)>0 then
            return me:GetItemCount(G,D,P,L)>=N
        else
            return false
        end
    end
    if InForm == 5 then
        WidgetUtils.Collapsed(self.Image_5)
        WidgetUtils.Collapsed(self.UnLock)
        WidgetUtils.Collapsed(self.BtnUnlockGrey)
    else
        WidgetUtils.HitTestInvisible(self.Image_5)
        self:ChangeBtnState(bEnough(g,d,p,l,n))
    end
    self:SetRoleDes(InCharacter)
    self:SetRoleNameDetail(InCharacter)
    self:SkillItem(InCharacter)
    self:UpdateRedDot()
end

function tbLockClass:UpdateRedDot()
    if RoleCard.CheckTemplateRedDot(self.Template, {0}) then
        WidgetUtils.HitTestInvisible(self.Red)
    else
        WidgetUtils.Collapsed(self.Red)
    end
end

--- 角色名描述
function tbLockClass:SetRoleNameDetail(InCharacter)
    self.TxtName:SetText(Text(InCharacter.I18N))
    self.TxtName2:SetText(Text(InCharacter.I18N..'_title'))
end

--- 角色描述
function tbLockClass:SetRoleDes(InCharacter)
    self:ContentDes(InCharacter)
    --self:ShowWeapon(InCharacter)
end

function tbLockClass:ContentDes(InCharacter)
    local sDes = InCharacter.I18N..'_des'
    self.TxtDes:SetText(Text(sDes))
end

function tbLockClass:ShowWeapon(InCharacter)
    local WeaponTemplateId = InCharacter.DefaultWeaponGPDL
    SetTexture(self.ImgWeapon,Item.WeaponTypeIcon[WeaponTemplateId.Detail])
end

--- Btn按键状态
function tbLockClass:ChangeBtnDes()
    self.Txt1:SetText(Text('TxtRoleGet'))
    self.Txt2:SetText(Text('TxtRoleUnlock'))
end

function tbLockClass:ChangeBtnState(InShow)
    self:ChangeBtnDes()
    if InShow then
        WidgetUtils.Collapsed(self.BtnUnlockGrey)
        WidgetUtils.Visible(self.Unlock)
    else
        WidgetUtils.Collapsed(self.UnLock)
        WidgetUtils.Visible(self.BtnUnlockGrey)
    end
end

--- 技能列表
function tbLockClass:SkillItem(InItem)
    if not InItem then return end
    local Skills, SkillTags = RoleCard.GetItemShowSkills(InItem)
    for index, value in ipairs(self.tbSkill) do
        local SkillId = Skills[index] or 0
        local tbParam = {
            bTag = true,
            nSkillId = SkillId,
            sSkillTag = SkillTags[index] or '',
            fClickFun = function()
                UI.Open("SkillTip", InItem, SkillId, index, self.tbSkillType[index])
                EventSystem.TriggerTarget(RoleCard, RoleCard.ShowSkillDetailHandle, false)
            end
        }
        --- 技能描述控件是否存在
        if value.ShowSkillInfo then
            value:ShowSkillInfo(tbParam)
        end
    end
end

return tbLockClass
