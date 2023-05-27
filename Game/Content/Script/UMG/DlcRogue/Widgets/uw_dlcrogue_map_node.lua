-- ========================================================
-- @File    : uw_dlcrogue_map_node.lua
-- @Brief   : 肉鸽活动 map item
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnSl, function ()
        if not self.NodeInfo then
            return
        end
        local BaseInfo = RogueLogic.GetBaseInfo()
        if BaseInfo.nAvaActTimes <= 0 then
            UI.ShowMessage(Text("rogue.TxtNotMovePoint"))
            return
        end
        local fun = nil
        ---1=战斗节点，2=事件节点，3=商店节点，4=休息点
        if self.NodeInfo.nNode == RogueLogic.NodeType.Fight then
            fun = function ()
                local pUI = UI.GetUI("DlcRogue")
                if pUI and pUI:IsOpen() then
                    RogueLevel.SetNodeInfo(self.NodeInfo)
                    RogueLevel.SetLevelID(self.NodeInfo.nLevelID)
                    pUI:ShowLevelInfo()
                end
            end
        elseif self.NodeInfo.nNode == RogueLogic.NodeType.Random then
            fun = function ()
                UI.Open("DlcRogueRandom", self.NodeInfo)
            end
        elseif self.NodeInfo.nNode == RogueLogic.NodeType.Shop then
            fun = function ()
                RogueLogic.VisitShop(self.NodeInfo.nID, function ()
                    UI.Open("DlcRogueShop", self.NodeInfo)
                end)
            end
        elseif self.NodeInfo.nNode == RogueLogic.NodeType.Rest then
            fun = function ()
                UI.Open("DlcRogueRandom", self.NodeInfo)
            end
        end

        local bok, desc = RogueLogic.CheckNodeOpen(self.NodeInfo.nMapID, self.NodeInfo.nID)
        if bok then
            if fun then
                if BaseInfo.nCurNode ~= self.NodeInfo.nID then
                    UI.Open("MessageBox", Text("rogue.TxtMoveQ"), function ()
                        RogueLogic.MoveNext(self.NodeInfo.nID, fun)
                    end)
                else
                    fun()
                end
            else
                UI.ShowMessage(Text("error.204"))
            end
        else
            local bShopNext = false
            local nowNode = RogueLogic.tbMapCfg[BaseInfo.nMapID][BaseInfo.nCurNode]
            if nowNode and nowNode.nNode == RogueLogic.NodeType.Shop and nowNode.tbNext then
                for _, ID in ipairs(nowNode.tbNext) do
                    if self.NodeInfo.nID == ID then
                        bShopNext = true
                        break
                    end
                end
            end
            if bShopNext then
                UI.Open("MessageBox", Text("rogue.TxtMoveWarn"), function ()
                    local tbData = {nID = nowNode.nID, nType = nowNode.nNode}
                    RogueLogic.FinishNode(tbData, function ()
                        RogueLogic.MoveNext(self.NodeInfo.nID, fun)
                    end)
                end)
            else
                UI.ShowMessage(desc)
            end
        end
    end)
end

function tbClass:Show(tbInfo)
    if not tbInfo then
        return
    end
    self.NodeInfo = tbInfo

    local nState = RogueLogic.GetNodeState(self.NodeInfo.nMapID, self.NodeInfo.nID)
    local bActivate = RogueLogic.CheckNodeActivate(self.NodeInfo.nID)
    if nState >= 1 or bActivate then
        self:SetRenderOpacity(1)
    else
        self:SetRenderOpacity(0.4)
    end

    if nState>=2 then
        WidgetUtils.Collapsed(self.PanelNode)
        WidgetUtils.HitTestInvisible(self.ImgOver)
    else
        WidgetUtils.Collapsed(self.ImgOver)
        WidgetUtils.HitTestInvisible(self.PanelNode)
        self.TxtName1:SetText(Text(tbInfo.nName))
        if tbInfo.nIcon then
            SetTexture(self.ImgNode1, tbInfo.nIcon)
        end
    end

    if self.EventMove then
        EventSystem.Remove(self.EventMove)
        self.EventMove = nil
    end

    self.EventMove = EventSystem.OnTarget(RogueLogic, RogueLogic.MoveToNext, function()
        self:SetSelected(RogueLogic.CheckNodeActivate(self.NodeInfo.nID))
    end)
    self:SetSelected(bActivate)
end

function tbClass:SetSelected(bSelected)
    if bSelected then
        WidgetUtils.HitTestInvisible(self.ImgSl)
        self:PlayAnimation(self.AllLoop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
    else
        WidgetUtils.Collapsed(self.ImgSl)
        self:StopAnimation(self.AllLoop)
    end
end

return tbClass
