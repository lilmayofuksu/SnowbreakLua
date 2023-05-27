-- ========================================================
-- @File    : uw_suitskill_des.lua
-- @Brief   : 后勤养成套装技能描述
-- @Author  :
-- @Date    :
-- ========================================================

local tbSuitDes = Class("UMG.SubWidget")


function tbSuitDes:OnListItemObjectSet(InObj)
    self.tbParam = InObj.Date or InObj.Logic
    self:SetDes(self.tbParam.nSkillId,self.tbParam.InCol)
    self:SkillDes(self.tbParam.nSkillId)
end

function tbSuitDes:SetDes(tbSkillId,InCol)
    for i = 1,tbSkillId:Length() do
        self.TxtDes:SetText(SkillDesc(tbSkillId:Get(i)))
        --self.TxtDes:SetColorAndOpacity(InCol)
    end
end

function tbSuitDes:SkillDes(tbSkillId)
   
    for i = 1,tbSkillId:Length() do
        local sKillDes=SkillDesc(tbSkillId:Get(i))
        --- 临时数据
        local Data=23
        self.Des:SetText(sKillDes.. " <orange>(+"..Data.."%)</>")
    end
end
return tbSuitDes