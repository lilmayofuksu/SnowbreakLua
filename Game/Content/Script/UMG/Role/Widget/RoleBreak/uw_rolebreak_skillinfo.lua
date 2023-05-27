
-- ========================================================
-- @File    : uw_rolebreak_skillinfo.lua
-- @Brief   : 突破技能详情
-- @Author  :
-- @Date    :
-- ========================================================

local RoleSkillDetail = Class("UMG.BaseWidget")

function RoleSkillDetail:Construc()
    --body()
end

function RoleSkillDetail:OnOpen(tbParam)
    self.TxtSkillName:SetText(SkillName(tbParam.SkillId))
    self.TxtSkillIntro:SetContent(SkillDesc(tbParam.SkillId))
    self.TxtSkillType:SetText(Text('ui.TxtPassiveSkill'))
    self.Skill:OnOpen(tbParam)
    self.BG:Init(
        function()
            UI.CloseTopChild()
            if tbParam.Click then
                tbParam.Click()
            end
        end)
end

return RoleSkillDetail