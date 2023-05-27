-- ========================================================
-- @File    : umg_tbClass.lua
-- @Brief   : 养成界面
-- ========================================================

local tbClass = Class("UMG.BaseWidget")
tbClass.AttrPath = "UMG/Role/Widget/uw_role_attribute_data"

tbClass.tbItemDes = {
    UE4.EAttributeType.Health,
    UE4.EAttributeType.Attack,
    UE4.EAttributeType.Defence,
    UE4.EAttributeType.Vigour,
    UE4.EAttributeType.Criticalvalue,
    UE4.EAttributeType.Criticaldamage
}

function tbClass:Construct()
    self.NewSkillItem = Model.Use(self)
    BtnAddEvent(self.RoleBtn,  
        function() 
            if self.CurCard then
                UI.Open("RoleUpLv", self.CurCard)
                EventSystem.TriggerTarget(RoleCard,RoleCard.ShowSkillDetailHandle,true)
                return
            else
                UI.ShowMessage("tip.no_current_card")
                return
            end

        end
    )

    local tbskillBG = {self.BG,self.BG_1,self.BG_2}
    local tbSkillImg = {self.SkillImg,self.SkillImg_1,self.SkillImg_2}
    local tbSkillTag = {self.SkillTag,self.SkillTag_1,self.SkillTag_2}
    self.tbskillInfo = {}
    for i = 1, 3 do
        local skillInfo = {
            Click = nil,
            BGSkill = tbskillBG[i], 
            SkillImg = tbSkillImg[i],
            SkillTag = tbSkillTag[i]
        }
       table.insert(self.tbskillInfo,skillInfo)
    end

    BtnAddEvent(self.BtnClick,function()
        self.tbskillInfo[1].Click(self.tbskillInfo[1].SkillId)
        print('BtnClick')
    end)

    BtnAddEvent(self.BtnClick2,function()
        self.tbskillInfo[2].Click(self.tbskillInfo[2].SkillId)
    end)


    BtnAddEvent(self.BtnClick3,function()
        self.tbskillInfo[3].Click(self.tbskillInfo[3].SkillId)
    end)
end

--- 预览信息界面
function tbClass:InfoDes(InCard)
    self:Updatecarddate(InCard)
end

function tbClass:OnActive(pRole, InForm, Click, pCard)
    if pCard then
        self.CurTemplate = UE4.UItem.FindTemplateForID(pCard:TemplateId())
        self.CurCard = pCard
    else
        self.CurTemplate = pRole
        self.CurCard = RoleCard.GetItem({pRole.Genre,pRole.Detail,pRole.Particular,pRole.Level})
    end
    self.Quality:Set(self.CurTemplate.Color)

    self.tbSkill = {self.Skill1, self.Skill1, self.Skill2, self.Qte, self.Rush}
    self.tbSkillType = {RoleCard.SkillType.NormalSkill, RoleCard.SkillType.NormalSkill, RoleCard.SkillType.BigSkill, RoleCard.SkillType.QTESkill, RoleCard.SkillType.NormalSkill}

    self:SkillItem(pRole)
    self:ShowSkills(pRole)
    -- if self.CurCard then
    --     self:SetRoleLogo(self.CurCard)
    -- end
end

function tbClass:ChangeLockState(InLock)
    WidgetUtils.Collapsed(self.UnLockSys)
    WidgetUtils.Collapsed(self.CultiSys)
    WidgetUtils.Collapsed(self.PanelSkill)
    if InLock == 1 then
        WidgetUtils.SelfHitTestInvisible(self.CultiSys)
        WidgetUtils.SelfHitTestInvisible(self.PanelSkill)
    else
        WidgetUtils.SelfHitTestInvisible(self.UnLockSys)
    end
end

--- 切换角色展示模型
function tbClass:ModifierModel(InTemplate)
    if not InTemplate  then return end
    local ShowCharacter = RoleCard.GetItem({InTemplate.Genre,InTemplate.Detail,InTemplate.Particular,InTemplate.Level})
    if ShowCharacter  then
        Preview.PreviewByItemID(ShowCharacter:Id(), PreviewType.role_lvup)
    else
        Preview.PreviewByGDPL(UE4.EItemType.CharacterCard ,InTemplate.Genre,InTemplate.Detail,InTemplate.Particular,InTemplate.Level, PreviewType.role_lvup, InTemplate.Level)
    end
end

function tbClass:ShowSkills(InItem)
    if not InItem then return end
    local Skills, SkillTags = RoleCard.GetItemShowSkills(InItem)
    for i = 1, 3 do
        self.tbskillInfo[i].SkillId = Skills[i+1]
        self.tbskillInfo[i].Click = function(Id)
            print("id:",Id,debug.traceback())
            UI.Open("SkillTip",InItem, Id,i+1,self.tbSkillType[i+1])
            EventSystem.TriggerTarget(RoleCard,RoleCard.ShowSkillDetailHandle,false)
        end
        --local sIcon = UE4.UAbilityLibrary.GetSkillIcon(Skills[i+1])
        --SetTexture(self.tbskillInfo[i].SkillImg,sIcon)
    end
end

--- 技能列表
function tbClass:SkillItem(InItem)
    if not InItem then return end
    local Skills, SkillTags = RoleCard.GetItemShowSkills(InItem)
    for index, value in ipairs(self.tbSkill) do
        local SkillId = Skills[index] or 0
        print("SkillId:",SkillId)
        local tbParam = {
            bTag = true,
            nSkillId = SkillId,
            sSkillTag = SkillTags[index] or '',
            fClickFun = function()
                UI.Open("SkillTip", InItem, SkillId, index, self.tbSkillType[index])
                EventSystem.TriggerTarget(RoleCard,RoleCard.ShowSkillDetailHandle,false)
            end
        }
        --- 技能描述控件是否存在
        if value.ShowSkillInfo then
            value:ShowSkillInfo(tbParam)
        end
    end
end

function tbClass:InitRoleCate(InValue)
    local sTxt = Text("attribute." .. InValue)
    return sTxt
end

function tbClass:InitRoleData(InCard,sCate)
    print("===============2222==========================>", sCate)
    return UE4.UItemLibrary.GetCharacterCardAbilityValueByStrToStr("Total_" .. sCate,InCard)

end

function tbClass:SetSingleText(InText, InValue)
    InText:SetText(InValue)
end

function tbClass:SetComplexText(InText, InCurValue, InSumValue)
    InText:SetText(InCurValue .. "/" .. InSumValue)
end


--- 角色名描述
function tbClass:ShowRoleName(InCard)
    self.TxtName:SetText(Text(InCard:I18N()))
    self.TxtTitle:SetText(Text(InCard:I18N()..'_title'))
    SetTexture(self.RoleIcon, InCard:Icon())
    SetTexture(self.ImgQuality, Item.RoleColor_short[InCard:Color()])
    SetTexture(self.ImgQuality2, Item.RoleColorWeapon[InCard:Color()])
    --- 武器等级
    self.Level:SetText(InCard:EnhanceLevel())
    self:PlayAnimation(self.name_refresh)
end

--- 武器类型和等级
function tbClass:ShowWeaponInfo(InWeapon)
    --- 武器类型
    SetTexture(self.TypeGun, Weapon.GetTypeIcon(InWeapon))
end



--角色战力展示界面数据
function tbClass:Updatecarddate(InCard)
    if not InCard then return end
    self:SetSingleText(self.TexBatPower, Item.Zhanli_CardTotal(InCard))
end


function tbClass:ChangeState(Index)
    local Item = self.LeftList:GetItemAt(Index)
    Item.bSelect = true
end

function tbClass:SetRoleLogo(InItem)
    if not InItem then return end
    SetTexture(self.ImgLogo, InItem:Icon())
    SetTexture(self.ImgLogoShadow, InItem:Icon())
end

function tbClass:OnDisable()
    -- body
end

return tbClass
