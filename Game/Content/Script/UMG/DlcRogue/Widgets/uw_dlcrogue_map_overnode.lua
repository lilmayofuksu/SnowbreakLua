-- ========================================================
-- @File    : uw_dlcrogue_map_overnode.lua
-- @Brief   : 肉鸽活动 下一页节点
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSl, function ()
        if not self.NodeInfo then
            return
        end
        local bok, desc = RogueLogic.CheckNodeOpen(self.NodeInfo.nMapID, self.NodeInfo.nID)
        if bok then
            local tbData = {nID = self.NodeInfo.nID, nType = self.NodeInfo.nNode}
            RogueLogic.FinishNode(tbData, function ()
                local uiRogue = UI.GetUI("DlcRogue")
                if uiRogue and uiRogue:IsOpen() then
                    uiRogue:UpdateMapPanel()
                end
            end)
        else
            UI.ShowMessage(desc)
        end
    end)
end

function tbClass:Show(AllNode, Index)
    local tbNode = AllNode[Index]
    if not tbNode then return end
    self:PlayAnimation(self.AllEnter)

    if self.EventMove then
        EventSystem.Remove(self.EventMove)
        self.EventMove = nil
    end

    self.NodeInfo = tbNode[1]
    if not self.NodeInfo then
        return
    end

    local nState = RogueLogic.GetNodeState(self.NodeInfo.nMapID, self.NodeInfo.nID)
    local bActivate = RogueLogic.CheckNodeActivate(self.NodeInfo.nID)
    if nState >= 1 or bActivate then
        self:SetRenderOpacity(1)
    else
        self:SetRenderOpacity(0.4)
    end

    self.EventMove = EventSystem.OnTarget(RogueLogic, RogueLogic.MoveToNext, function()
        self:UpdateLine(AllNode, Index)
        self:SetSelected(RogueLogic.CheckNodeActivate(self.NodeInfo.nID))
    end)

    self:UpdateLine(AllNode, Index)
    self:SetSelected(bActivate)
end

function tbClass:SetSelected(bSelected)
    if bSelected then
        WidgetUtils.HitTestInvisible(self.ImgSl)
    else
        WidgetUtils.Collapsed(self.ImgSl)
    end
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
