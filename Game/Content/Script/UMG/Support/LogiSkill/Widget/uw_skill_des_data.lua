

-- ========================================================
-- @File    : uw_skill_des_data.lua
-- @Brief   : 后勤技能描述展示条目
-- @Author  :
-- @Date    :
-- ========================================================

local DesData = Class("UMG.SubWidget")

function DesData:OnInit(tbParam)
    self.InItem = tbParam.SupportCard
    self.Id = tbParam.SkillId
    self.SkillLv=tbParam.SkillLv
end

return DesData