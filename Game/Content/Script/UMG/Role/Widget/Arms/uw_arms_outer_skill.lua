-- ========================================================
-- @File    : uw_arms_outer_skill.lua
-- @Brief   : 武器技能3D界面
-- ========================================================



local tbArmsSkills = Class("UMG.SubWidget")

function tbArmsSkills:Construct()
    -- body
end


function tbArmsSkills:OnOpen()
    -- body
end

function tbArmsSkills:ShowSkillDes(InWeapon)
    self.Skill:Set(InWeapon)
end


return tbArmsSkills