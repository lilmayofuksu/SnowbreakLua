-- ========================================================
-- @File    : uw_nerve_sync_tips.lua
-- @Brief   : 
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function ()
        UI.Close(self)
    end)
end

function tbClass:OnOpen(InId)
    if not InId then return end
    SetTexture(self.ImgSkill, UE4.UAbilityLibrary.GetSkillFixInfoStaticId(InId))
    self.TxtName:SetText(SkillName(InId))
    self.TxtSkillIntro:SetContent(SkillDesc(InId))
    self:PlayAnimation(self.AllEnter)
end

return tbClass
