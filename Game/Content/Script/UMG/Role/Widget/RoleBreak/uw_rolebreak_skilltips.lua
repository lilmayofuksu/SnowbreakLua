-- ========================================================
-- @File    : uw_rolebreak_skilltips.lua
-- @Brief   : 突破技能提示
-- @Author  :
-- @Date    :
-- ========================================================

local SkillTip = Class("UMG.SubWidget")

function SkillTip:Construct()
    --body()
end
--- 技能描述
---@param InSkillId integer 技能ID
function SkillTip:TipSkillTxtDes(InCard, InID)
    local sSkillName = SkillName(InID)
    self.TxtName:SetText(sSkillName)
    local tbvalue = UE4.TArray(UE4.int32)
    local sSkillDes = SkillDesc(InID, tbvalue)
    if sSkillDes then
        self.SkillDes:SetText(sSkillDes)
    end
end

--- 技能图标动态描述
---@param InSkillId integer 技能ID
function SkillTip:TipSkillDes(InCard, InID)
    -- 获取技能ID，配置解锁技能时候的描述

    ---切换解锁技能位激活状态
    self.TipSkill:CheckSkill(RBreak.MulState.On)
end
--- 刷新显示内容
function SkillTip:UpData(InCard, InIndex)
    if InIndex then
        self:TipSkillDes(InCard, InIndex)
        self:TipSkillTxtDes(InCard, InIndex)
    else
        print('Skill Id err:'..string.format("%d-%d-%d-%d",InCard:Genre(),InCard:Detail(),InCard:Particular(),InCard:Level()))
        return
    end
end
return SkillTip
