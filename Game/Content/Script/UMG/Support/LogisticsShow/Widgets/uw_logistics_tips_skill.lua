-- ========================================================
-- @File    : uw_logistics_tips_skill.lua
-- @Brief   : 角色后勤技能说明列表
-- @Author  :
-- @Date    :
-- ========================================================

local  tbSkill = Class("UMG.SubWidget")


function tbSkill:OnListItemObjectSet(InObj)
    if InObj == nil or InObj.Logic == nil then
        return
    end
    local Item =InObj.Logic
    self:SetSkillInfo(Item.Level,Item.Icon,Item.TxtDex)
end

function tbSkill:SetSkillInfo(InLv,InIconId,InDes)
    self.SkillLv:SetText(InLv)
    self.SkillDes:SetText(InDes)
    SetTexture(self.SkillImg_1,Resource.Get(InIconId))
end
return tbSkill