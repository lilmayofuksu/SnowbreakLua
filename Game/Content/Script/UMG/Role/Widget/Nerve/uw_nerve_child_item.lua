-- ========================================================
-- @File    : uw_nerve_child_item.lua
-- @Brief   : 角色脊椎树图
-- @Author  :
-- @Date    :
-- ========================================================

local CSNode = Class("UMG.SubWidget")

function CSNode:Construct()
    self:OnActive(false)
    WidgetUtils.Collapsed(self.PanelSelect)
    BtnAddEvent(self.BtnSelect, function()
        self.CallFun(self.Idx, self.nState)
        EventSystem.TriggerTarget(Spine, Spine.ShowPreviewNote, true)
        PlayEffect(self.EffectPanel, 27)
    end)
    self:ShowNodeState(3)

    self.ResetProgressHandle = EventSystem.OnTarget(Spine, Spine.ResetProgressHandle, function()
            Spine.ActivedProgress.MastId = 1
            Spine.ActivedProgress.SubId = 0
        end)
    self.FinishHandle = EventSystem.OnTarget(Spine, Spine.NoteActivedFinishHandle, function(Target,InIdx)
        if InIdx == self.Idx then
            if InIdx == Spine.MaxSubNum then
                PlayEffect(self.EffectPanel, 28)
            else
                PlayEffect(self.EffectPanel, 29)
            end
        end
    end)
end

function CSNode:OnOpen(InParam)
    self.Card = InParam.Card
    self.MastIdx = InParam.MastIdx
    self.Idx = InParam.InIdx
    self.CallFun = InParam.ClickFun
    self.NodeInfo = InParam.NodeInfo
    self:ShowNodeIcon(self.NodeInfo)

    --- 刷新子节点状态
    self.nState = self:CheckNodeState()
    self:ShowNodeState(self.nState)
end

function CSNode:CheckNodeState()
    if self.Card and self.Card:GetSpine(self.MastIdx, self.Idx) then
        Spine.ActivedIdx = self.Idx + 1
        return 1
    end

    while Spine.ActivedIdx == 1 do
        local StateTag = 3
        if self.Idx == 1 then
            StateTag = 2
        end
        return StateTag
    end

    if Spine.ActivedIdx == self.Idx then
        return 2
    end

    return 3
end

function CSNode:ShowNodeIcon(NodeInfo)
    if NodeInfo.AttributeID then
        WidgetUtils.Collapsed(self.ImgBigIcon)
        WidgetUtils.Collapsed(self.ImgMidIcon)
        WidgetUtils.HitTestInvisible(self.ImgSmallIcon)
    elseif NodeInfo.tbSkillId then
        WidgetUtils.Collapsed(self.ImgBigIcon)
        WidgetUtils.Collapsed(self.ImgSmallIcon)
        WidgetUtils.HitTestInvisible(self.ImgMidIcon)
    elseif NodeInfo.Skilfix then
        WidgetUtils.Collapsed(self.ImgMidIcon)
        WidgetUtils.Collapsed(self.ImgSmallIcon)
        WidgetUtils.HitTestInvisible(self.ImgBigIcon)
    end
end

--- 当前节点信息刷新
function CSNode:NodeUpData(InData, i)
    --- 提取当前节点信息
    self.tbData = {
        pItem = InData.InItem,
        InIdx = InData.NodeId,
        InSubIndx = i
    }
    local bActive= self.tbData.pItem:GetSpine(self.tbData.InIdx, self.tbData.InSubIndx)
    self:OnActive(bActive)
    self:NodeName()
    self:PerProgress()
end

--- 子节点命名
function CSNode:NodeName()

end

--- 子节点暂不考虑进度
function CSNode:PerProgress()
    local nProgress = math.random(1, 10)
    local Per = "+" .. nProgress .. "%"
    self.TxtProgress:SetText(Per)
end

--- 节点解锁状态切换
function CSNode:OnActive(InState)
    if InState then
        WidgetUtils.Hidden(self.MaskNot)
        WidgetUtils.Visible(self.MaskOn)
    else
        WidgetUtils.Hidden(self.MaskOn)
        WidgetUtils.Visible(self.MaskNot)
    end
end

--- 子节点是否可以激活，预览
---@return bCan boolean true 激活，false 预览
function CSNode:CanActive()
    local SpineFrameId = Spine.tbKeyId[10001][Spine.GetProgresNum(self.tbData.pItem)].SpcondId
    local tbSpineCond = Spine.tbSpineNodeCond[SpineFrameId][self.tbData.InSubIndx].NodeCondition
    local bCanLv = self.tbData.pItem:EnhanceLevel()>=tbSpineCond[1][2]
    return bCanLv
end

--- 是否点击选中
function CSNode:GetSelect(InSelect)
    if InSelect then
        WidgetUtils.SelfHitTestInvisible(self.PanelSelect)
        self:PlayAnimation(self.Select, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    else
        WidgetUtils.Collapsed(self.PanelSelect)
    end
end


--- 未激活，激活，激活并解锁
---@param InState interge 1:激活并解锁，2：激活 3：未激活
function CSNode:ShowNodeState(InState)
    if not InState then
        self.nState = self:CheckNodeState()
        InState = self.nState
    end

    if InState == 1 then
        WidgetUtils.Collapsed(self.PanelOff)
        WidgetUtils.Collapsed(self.PanelLock)
        WidgetUtils.SelfHitTestInvisible(self.PanelOn)
    end

    if InState == 2 then
        WidgetUtils.Collapsed(self.PanelOn)
        WidgetUtils.Collapsed(self.PanelLock)
        WidgetUtils.SelfHitTestInvisible(self.PanelOff)
        self:PlayAnimation(self.Next,0,999, UE4.EUMGSequencePlayMode.Forward, 1, true)
    end

    if InState == 3 then
        WidgetUtils.Collapsed(self.PanelOn)
        WidgetUtils.Collapsed(self.PanelOff)
        WidgetUtils.SelfHitTestInvisible(self.PanelLock)
    end
end

function CSNode:OnClear()
    EventSystem.Remove(self.FinishHandle)
    self.FinishHandle = nil
    EventSystem.Remove(self.ResetProgressHandle)
    self.ResetProgressHandle = nil
    EventSystem.RemoveAllByTarget(self)
end

function CSNode:OnDestruct()
    self:OnClear()
end

return CSNode
