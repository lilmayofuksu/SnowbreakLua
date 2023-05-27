-- ========================================================
-- @File    : uw_skill_des.lua
-- @Brief   : 角色后勤技能描述列表
-- @Author  :
-- @Date    :
-- ========================================================

local  SkillDes = Class("UMG.SubWidget")

function SkillDes:Construct()
    
end

function SkillDes:OnListItemObjectSet(InObj)
    if InObj == nil or InObj.Logic == nil then
        return
    end
    local Item =InObj.Logic
    self:SetAttrInfo(Item.Id)
    self:SkillDes(Item.Id,Item.InItem:Break()+Item.SkillLv)
end

--- 技能描述
function SkillDes:SetAttrInfo(Id)
    --- self.SkillDes:SetText(SkillDesc(Id))
end

function SkillDes:SkillDes(Id, nLevel)
   
    local sKillDes=SkillDesc(Id, nil, nLevel)
    --- 临时数据
    --local Data=23
    self.SkillTxt:SetText(sKillDes) --.. " <orange>(+"..Data.."%)</>")
end
return SkillDes