-- ========================================================
-- @File    : uw_skill_info_text_data.lua
-- @Brief   : 角色主要技能节点提示
-- @Author  :
-- @Date    :
-- ========================================================

local tbSkillData = Class("UMG.SubWidget")

function tbSkillData:OnInit(tbParam)
    --  Dump(tbParam)
    self.Id = tbParam.Id
    self.bActived = tbParam.bActived
    self.tbData = tbParam.tbInfo
end

return tbSkillData
