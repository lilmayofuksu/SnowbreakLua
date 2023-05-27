-- ========================================================
-- @File    : uw_nerve_skill_tips.lua
-- @Brief   : 角色脊椎系统技能提示界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClose, function()
        self:UnbindAllFromAnimationFinished(self.Enter)
        UI.Close(self)
    end)
end

function tbClass:OnOpen(SkillID)
    self:UpdatePanel(SkillID)
end

function tbClass:UpdatePanel(SkillID)
    if not SkillID then
        return
    end
    self.TxtSkill:SetText(SkillName(SkillID))
    local sIcon = UE4.UAbilityLibrary.GetSkillFixInfoStaticId(SkillID)
    SetTexture(self.ImgBigIcon, sIcon)

    self:StopAnimation(self.Enter)
    self:BindToAnimationFinished(self.Enter, {self, function()
        self:UnbindAllFromAnimationFinished(self.Enter)
        UI.Close(self)
    end})
    self:PlayAnimation(self.Enter)
end

function tbClass:OnClose()
    if type(self.FunClose) == "function" then
        self.FunClose()
    end
end

return tbClass
