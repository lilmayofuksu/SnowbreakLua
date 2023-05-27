-- ========================================================
-- @File    : uw_suitskill_des_data.lua
-- @Brief   : 后勤养成套装技能描述
-- @Author  :
-- @Date    :
-- ========================================================

local  tbData = Class("UMG.SubWidget")

function tbData:OnInit(tbParam)
     self.nSkillId = tbParam.tbSkillId
     self.InCol = tbParam.InCol
end

return tbData
