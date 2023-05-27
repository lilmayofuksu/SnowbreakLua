-- ========================================================
-- @File    : uw_rolebreaklv_tips.lua
-- @Brief   : 
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    self.BG:Init(function() UI.Close(self) end)
end

function tbClass:OnOpen(InId)
    if not InId then return end
    SetTexture(self.ImgSkill, UE4.UAbilityLibrary.GetSkillFixInfoStaticId(InId))
    self.TxtSkillIntro:SetContent(SkillDesc(InId))
end

return tbClass
