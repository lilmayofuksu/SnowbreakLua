-- ========================================================
-- @File    : uw_dlcrogue_map3.lua
-- @Brief   : 肉鸽活动 终点map
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

    if tbNode[1] then
        WidgetUtils.SelfHitTestInvisible(self.MapNode1)
        self.MapNode1:Show(tbNode[1])
    else
        WidgetUtils.Collapsed(self.MapNode1)
    end

    self:UpdateLine(AllNode, Index)
end

function tbClass:UpdateLine(AllNode, Index)
    local tbNode = AllNode[Index]
    if not tbNode then return end

    local bInTo = false
    if tbNode[1] then
        bInTo = RogueLogic.GetNodeState(tbNode[1].nMapID, tbNode[1].nID) >= 1
        if bInTo then
            WidgetUtils.Collapsed(self.Lock1)
            WidgetUtils.HitTestInvisible(self.Completed1)
        else
            WidgetUtils.Collapsed(self.Completed1)
            WidgetUtils.HitTestInvisible(self.Lock1)
        end
    end

    local tbLastNode = AllNode[Index-1] or {}
    for i = 1, 4 do
        if tbLastNode[i] then
            WidgetUtils.HitTestInvisible(self["Line"..i])
            if bInTo then
                WidgetUtils.Collapsed(self["LockVerLine"..i])
                WidgetUtils.HitTestInvisible(self["CompletedVerLine"..i])
            else
                WidgetUtils.Collapsed(self["CompletedVerLine"..i])
                WidgetUtils.HitTestInvisible(self["LockVerLine"..i])
            end
        else
            WidgetUtils.Collapsed(self["Line"..i])
        end
    end
end

return tbClass
