-- ========================================================
-- @File    : uw_dlcrogue_map1.lua
-- @Brief   : 肉鸽活动 起点map
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Show(AllNode, Index)
    local tbNode = AllNode[Index]
    if not tbNode then return end
    self:PlayAnimation(self.AllEnter)

    if self.EventMove then
        EventSystem.Remove(self.EventMove)
        self.EventMove = nil
    end
    self.EventMove = EventSystem.OnTarget(RogueLogic, RogueLogic.MoveToNext, function()
        self:UpdateLine(AllNode, Index)
    end)

    for i = 1, self.Node:GetChildrenCount() do
        if tbNode[i] then
            WidgetUtils.SelfHitTestInvisible(self["MapNode"..i])
            self["MapNode"..i]:Show(tbNode[i])
        else
            WidgetUtils.Collapsed(self["MapNode"..i])
        end
    end
    self:UpdateLine(AllNode, Index)
end

function tbClass:UpdateLine(AllNode, Index)
    local tbNode = AllNode[Index]
    if not tbNode then return end

    local bToNext = false
    if tbNode[1] then
        bToNext = RogueLogic.CheckNodeComplete(tbNode[1].nMapID, tbNode[1].nID)
    end
    if bToNext then
        WidgetUtils.Collapsed(self.Lock1)
        WidgetUtils.HitTestInvisible(self.Completed1)
    else
        WidgetUtils.Collapsed(self.Completed1)
        WidgetUtils.HitTestInvisible(self.Lock1)
    end
end

return tbClass
