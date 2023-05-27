-- ========================================================
-- @File    : uw_skill_info_text.lua
-- @Brief   : 角色主要技能节点提示
-- @Author  :
-- @Date    :
-- ========================================================

local tbSkillInfo = Class("UMG.SubWidget")

function tbSkillInfo:Construct()
    --已激活颜色
    self.SlateColor1 = UE4.UUMGLibrary.GetSlateColor(0.054902, 0.039216, 0.541176, 1)
    --未激活颜色
    self.SlateColor2 = UE4.UUMGLibrary.GetSlateColor(0.011765, 0.011765, 0.015686, 1)
end

function tbSkillInfo:OnListItemObjectSet(InObj)
    self.pLogic = InObj.Logic or InObj.Data
    self:SetInfo(self.pLogic.Id, self.pLogic.bActived, self.pLogic.tbData)
    self:ShowActived(self.pLogic.bActived)

    self.Succ:SetColorAndOpacity(self.SlateColor1)
    self.Fail:SetColorAndOpacity(self.SlateColor2)
end

function tbSkillInfo:SetInfo(NodeId, bGet, tbData)
    local sdes = SkillDesc(NodeId)
    self.Des:SetContent(sdes)
    if bGet then
        self.Des:SetColorOpacity(self.SlateColor1)
        self.Des:SetRenderOpacity(1)
    else
        self.Des:SetColorOpacity(self.SlateColor2)
        self.Des:SetRenderOpacity(0.5)
    end
end

function tbSkillInfo:ShowActived(bShow)
    if bShow then
        WidgetUtils.Collapsed(self.Fail)
        WidgetUtils.SelfHitTestInvisible(self.Succ)
    else
        WidgetUtils.Collapsed(self.Succ)
        WidgetUtils.SelfHitTestInvisible(self.Fail)
    end
end
return tbSkillInfo
