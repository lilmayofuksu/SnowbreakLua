-- ========================================================
-- @File    : uw_logistics_assemble.lua
-- @Brief   : 角色后勤list显示套装装备情况的item
-- @Author  :
-- @Date    :
-- ========================================================

local  tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    WidgetUtils.SelfHitTestInvisible(self.NonePic)
    WidgetUtils.Collapsed(self.Set)
end

--- 设置状态
--- @param SkillEquiped bool 当前位置是否装备了同技能套装的后勤卡
function tbClass:SetState(SkillEquiped)
    WidgetUtils.SelfHitTestInvisible(SkillEquiped and self.Set or self.NonePic)
    WidgetUtils.Collapsed(SkillEquiped and self.NonePic or self.Set)
end

return tbClass