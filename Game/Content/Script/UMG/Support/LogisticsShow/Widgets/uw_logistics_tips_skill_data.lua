-- ========================================================
-- @File    : uw_logistics_tips_skill_data.lua
-- @Brief   : 角色后勤技能Item
-- @Author  :
-- @Date    :
-- ========================================================

local  tbSkillData = Class("UMG.SubWidget")


function tbSkillData:OnInit(tbParam)
    self.Level = tbParam.Level
    self.Icon = tbParam.Icon
    self.TxtDex = tbParam.TxtDex
end

return tbSkillData