-- ========================================================
-- @File    : uw_dlcrogue_map2.lua
-- @Brief   : 肉鸽活动 map
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
    if pObj and pObj.Data then
        self:Show(table.unpack(pObj.Data))
    end
end

function tbClass:GetShowLineByStart(tbNode)
    local data = {}
    local SetData = function(key, tb)
        if not data[key] then
            data[key] = tb
            return
        end
        for i, v in pairs(tb) do
            if not data[key][i] or data[key][i] < v then
                data[key][i] = v
            end
        end
    end
    for index, Node in pairs(tbNode) do
        local state = 1
        if RogueLogic.GetNodeState(Node.nMapID, Node.nID) >= 1 then
            state = 2
        end
        if index == 1 then
            SetData(1, {0, state})
            SetData(2, {state, 0})
        elseif index == 3 then
            SetData(2, {0, state})
            SetData(3, {state, 0})
        end
    end
    return data
end
function tbClass:GetShowLine(AllNode, index)
    local tbNode = AllNode[index]
    local data = {}
    local SetData = function(key, tb)
        if not data[key] then
            data[key] = tb
            return
        end
        for i, v in pairs(tb) do
            if not data[key][i] or data[key][i] < v then
                data[key][i] = v
            end
        end
    end

    local SetState = function (x1, x2, y1, y2, state)
        if y1 == y2 then
            return
        end
        if x2-x1 == 1 then
            local nstart = math.min(y1, y2)
            local nEnd = math.max(y1, y2)
            for i = nstart, nEnd do
                if i == nstart then
                    SetData(i, {0, state})
                elseif i == nEnd then
                    SetData(i, {state, 0})
                else
                    SetData(i, {state, state})
                end
            end
        else
            if y2>y1 then
                SetData(y2, {state, 0})
            else
                SetData(y2, {0, state})
            end
        end
    end

    for i = 2, index-1 do
        local tbLastNode = AllNode[i]
        for y1, LastNode in pairs(tbLastNode) do
            for y2, Node in pairs(tbNode) do
                for _, ID in ipairs(LastNode.tbNext) do
                    if ID == Node.nID then
                        local state = 1
                        if RogueLogic.GetNodeState(LastNode.nMapID, LastNode.nID) >= 2 and RogueLogic.GetNodeState(Node.nMapID, Node.nID) >= 1 then
                            state = 2
                        end
                        SetState(i, index, y1, y2, state)
                    end
                end
            end
            for _, ID in ipairs(LastNode.tbNext) do
                local x = math.floor(ID / 10)%1000
                local y = ID % 10
                if x>index then
                    local state = 1
                    if RogueLogic.GetNodeState(LastNode.nMapID, LastNode.nID) >= 2 and RogueLogic.GetNodeState(LastNode.nMapID, ID) >= 1 then
                        state = 2
                    end
                    if y-y1 == 1 then
                        SetData(y1, {0, 0, state})
                    elseif y1-y == 1 then
                        SetData(y, {0, 0, state})
                    end
                    if i==index-1 then
                        if y>y1 then
                            SetData(y1, {0, state})
                        elseif y<y1 then
                            SetData(y1, {state, 0})
                        end
                    end
                end
            end
        end
    end
    return data
end

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

    local num = self.Node:GetChildrenCount()
    for i = 1, num do
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

    local tbShowLine = {}
    if Index > 2 then
        tbShowLine = self:GetShowLine(AllNode, Index)
    else
        tbShowLine = self:GetShowLineByStart(tbNode)
    end

    local num = self.Node:GetChildrenCount()
    for i = 1, num do
        local nState = 0
        local bToNext = false
        if tbNode[i] then
            nState = RogueLogic.GetNodeState(tbNode[i].nMapID, tbNode[i].nID)
            if nState >= 1 then
                if nState >= 2 and #tbNode[i].tbNext > 1 then
                    bToNext = true
                else
                    for _, NextID in ipairs(tbNode[i].tbNext) do
                        bToNext = RogueLogic.GetNodeState(tbNode[i].nMapID, NextID) >= 1
                        if bToNext then
                            break
                        end
                    end
                end
            end

            if nState >= 1 then
                WidgetUtils.Collapsed(self["Lock_L"..i])
                WidgetUtils.HitTestInvisible(self["Completed_L"..i])
            else
                WidgetUtils.Collapsed(self["Completed_L"..i])
                WidgetUtils.HitTestInvisible(self["Lock_L"..i])
            end
            if bToNext then
                WidgetUtils.Collapsed(self["Lock_R"..i])
                WidgetUtils.HitTestInvisible(self["Completed_R"..i])
            else
                WidgetUtils.Collapsed(self["Completed_R"..i])
                WidgetUtils.HitTestInvisible(self["Lock_R"..i])
            end
        else
            WidgetUtils.Collapsed(self["Lock_L"..i])
            WidgetUtils.Collapsed(self["Completed_L"..i])
            WidgetUtils.Collapsed(self["Lock_R"..i])
            WidgetUtils.Collapsed(self["Completed_R"..i])
        end
        self:ShowLine(i, tbShowLine[i])
    end
end

-- 0不显示 1显示灰线 2显示黄线
function tbClass:ShowLine(Index, tbShow)
    tbShow = tbShow or {0, 0}
    if tbShow[1] == 0 then
        WidgetUtils.Collapsed(self["LockVerLine_LU"..Index])
        WidgetUtils.Collapsed(self["CompletedVerLine_LU"..Index])
    elseif tbShow[1] == 1 then
        WidgetUtils.Collapsed(self["CompletedVerLine_LU"..Index])
        WidgetUtils.HitTestInvisible(self["LockVerLine_LU"..Index])
    elseif tbShow[1] == 2 then
        WidgetUtils.Collapsed(self["LockVerLine_LU"..Index])
        WidgetUtils.HitTestInvisible(self["CompletedVerLine_LU"..Index])
    end

    if tbShow[2] == 0 then
        WidgetUtils.Collapsed(self["LockVerLine_LD"..Index])
        WidgetUtils.Collapsed(self["CompletedVerLine_LD"..Index])
    elseif tbShow[2] == 1 then
        WidgetUtils.Collapsed(self["CompletedVerLine_LD"..Index])
        WidgetUtils.HitTestInvisible(self["LockVerLine_LD"..Index])
    elseif tbShow[2] == 2 then
        WidgetUtils.Collapsed(self["LockVerLine_LD"..Index])
        WidgetUtils.HitTestInvisible(self["CompletedVerLine_LD"..Index])
    end

    if self["LineMiddle"..Index] then
        if not tbShow[3] or tbShow[3] == 0 then
            WidgetUtils.Collapsed(self["MiddleLock"..Index])
            WidgetUtils.Collapsed(self["MiddleCompleted"..Index])
        elseif tbShow[3] == 1 then
            WidgetUtils.Collapsed(self["MiddleCompleted"..Index])
            WidgetUtils.HitTestInvisible(self["MiddleLock"..Index])
        elseif tbShow[3] == 2 then
            WidgetUtils.Collapsed(self["MiddleLock"..Index])
            WidgetUtils.HitTestInvisible(self["MiddleCompleted"..Index])
        end
    end
end

return tbClass
