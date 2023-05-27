-- ========================================================
-- @File    : uw_role_skill2.lua
-- @Brief   : 技能图标
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self:SetActived()
    BtnAddEvent(self.Button, function()
        if self.fClickFun and self.nSkillId then
            self.fClickFun(self.nSkillId)
        end
    end)
end

function tbClass:UpdatePanel(InParam)
    if not InParam then
        return
    end
    self.fClickFun = InParam.fClickFun
    self.nSkillId = InParam.nSkillId
    local sIcon = UE4.UAbilityLibrary.GetSkillIcon(InParam.nSkillId)
    if InParam.EType == RoleCard.SkillType.PassiveType then
        sIcon = UE4.UAbilityLibrary.GetSkillFixInfoStaticId(InParam.nSkillId)
    end
    SetTexture(self.AttrIcon, sIcon)
    SetTexture(self.AttrIconShadow, sIcon)
    SetTexture(self.AttrIconSelected, sIcon)
end

function tbClass:SetActived(InState)
    if InState == 1 then
        WidgetUtils.Collapsed(self.Common)
        WidgetUtils.SelfHitTestInvisible(self.Selected)
    else
        WidgetUtils.Collapsed(self.Selected)
        WidgetUtils.SelfHitTestInvisible(self.Common)
    end
end

return tbClass
