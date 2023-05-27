-- ========================================================
-- @File    : SkillIntroControl.lua
-- @Brief   : GameTask 控制碎片本和试玩本，主要角色的技能提示
-- @Author  :
-- @Date    :
-- ========================================================
local SkillIntroControl = Class()

function SkillIntroControl:OnTrigger()
    -- print("SkillIntroControl:OnTrigger!")
    local FightUMG = UI.GetUI("Fight")
    if FightUMG and FightUMG.SkillIntro and FightUMG.TaskBtn then
        local SkillIntro = FightUMG.SkillIntro
        SkillIntro:Init(self.FirstIndex, self.MaxIndex, self.RoleId,self.DescNeedKeyName and self.KeyName or nil)
        SkillIntro:SwapShowIcon(self.bShowInfoIcon)
        --WidgetUtils.SelfHitTestInvisible(FightUMG.TaskBtn)
        if self.bShowTip then
            -- print("SkillIntroControl:OnTrigger Show!")
            WidgetUtils.SelfHitTestInvisible(SkillIntro)
            FightUMG.TaskBtn:PlayAnim(true, true)
        else
            -- print("SkillIntroControl:OnTrigger Hide!")
            FightUMG.TaskBtn:PlayAnim(false, true)
        end
        return true
    end
    return false
end

function SkillIntroControl:ShowOrHide(bIsShow)
end

function SkillIntroControl:Init()
end

return SkillIntroControl
