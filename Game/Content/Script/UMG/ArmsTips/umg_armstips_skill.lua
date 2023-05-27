-- ========================================================
-- @File    : umg_armstips_skill.lua
-- @Brief   : 武器技能信息界面
-- ========================================================
---@class tbClass
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function() UI.Close(self) end)
end

---UI打开
---@param nSkillID number 技能ID
---@param nLevel number 技能等级
function tbClass:OnOpen(nSkillID, nLevel)
    print('skill id == ', nSkillID)
    self.TxtSkillName:SetText(SkillName(nSkillID))
    self.TxtSkillDes:SetText(SkillDesc(nSkillID, nil, nLevel or 1))
end

return tbClass