-- ========================================================
-- @File    : uw_widgets_weapon_skill_list_item.lua
-- @Brief   : 武器技能条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(InObj)
    if InObj == nil or InObj.Data == nil then
        return
    end

    local SkillID = InObj.Data.Id

    if SkillID == -1 then
        WidgetUtils.SelfHitTestInvisible(self.Not)
        WidgetUtils.Collapsed(self.ON)
        return
    else
        WidgetUtils.SelfHitTestInvisible(self.ON)
        WidgetUtils.Collapsed(self.Not)
    end

    local SkillTemplate = UE4.UItemLibrary.GetSkillTemplate(SkillID)
    self.TxtName:SetText(Text(SkillTemplate.SkillName))
    self.TxtLV:SetText(InObj.Data.Lv)
end

return tbClass
