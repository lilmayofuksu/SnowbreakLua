-- ========================================================
-- @File    : uw_role_skill.lua
-- @Brief   : 技能控件
-- @Author  :
-- @Date    :
-- ========================================================

local tbAttrDetail = Class("UMG.SubWidget")

function tbAttrDetail:Construct()
    BtnAddEvent(self.Button, function ()
        if self.fClickFun then
            self.fClickFun()
        end
    end)
end

function tbAttrDetail:ShowSkillInfo(tbParam)
    local sName = SkillName(tbParam.nSkillId)
    self.Text_Cate:SetText(sName)
    local sIcon = UE4.UAbilityLibrary.GetSkillIcon(tbParam.nSkillId)
    SetTexture(self.AttrIcon, sIcon)
    if tbParam.fClickFun then
        self.fClickFun = tbParam.fClickFun
    end
end

return tbAttrDetail