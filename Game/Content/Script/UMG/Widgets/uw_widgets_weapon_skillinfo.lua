-- ========================================================
-- @File    : uw_widgets_weapon_skillinfo.lua
-- @Brief   : 武器或后勤的技能展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Set(pItem)
    if not pItem or not Weapon.GetWeaponConfig(pItem) then return end

    local nSkillID = 0
    if pItem:IsWeapon() then
        local tbSkillID = Weapon.GetWeaponConfig(pItem).DefaultSkillID
        if tbSkillID then
            nSkillID = tbSkillID[1]
        end
    else
        nSkillID = Logistics.GetSkillID(pItem)
    end

    if not nSkillID or nSkillID == 0 then
        WidgetUtils.Hidden(self)
        return
    else
        WidgetUtils.Visible(self)
    end
    local nLevel = pItem:Evolue() + 1
    self.TextLv:SetText(nLevel)
    self.TxtSkillName:SetText(Localization.GetSkillName(nSkillID))
    self.TxtSkillInfo:SetContent(SkillDesc(nSkillID, nil, nLevel))
    self.ScrollBoxSkill:ScrollToStart()
end

function tbClass:SetTemplate(pItemTemplate,IsWeapon)
    local nSkillID = 0
    if IsWeapon then
        local tbSkillID = Weapon.GetWeaponConfigByGDPL(pItemTemplate.Genre,pItemTemplate.Detail,pItemTemplate.Particular,pItemTemplate.Level).DefaultSkillID
        if tbSkillID then
            nSkillID = tbSkillID[1]
        end
    else
        local Skills = UE4.TArray(UE4.int32)
        Skills=pItemTemplate.DefaultSkills
        if Skills:Length() > 0 then
            local id = Skills:Get(1)
            nSkillID=id
        end
    end
    if nSkillID == 0 then
        WidgetUtils.Hidden(self)
    else
        WidgetUtils.Visible(self)
    end
    local nLevel =  1
    self.TextLv:SetText(nLevel)
    self.TxtSkillName:SetText(Localization.GetSkillName(nSkillID))
    self.TxtSkillInfo:SetContent(SkillDesc(nSkillID, nil, nLevel))
end

function tbClass:OnListItemObjectSet(InParam)
    if self.PlayerLevel then
        self.PlayerLevel:SetText(InParam.Data.sTitle)
    end
    self.TextLv:SetText(InParam.Data.nLv)
    self.TxtSkillName:SetText(InParam.Data.sName)
    self.TxtSkillInfo:SetContent(InParam.Data.sDes)
end

return tbClass
