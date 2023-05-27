-- ========================================================
-- @File    : uw_nerve_child_node.lua
-- @Brief   : 角色脊椎树图
-- @Author  :
-- @Date    :
-- ========================================================

local ChildSpine = Class("UMG.SubWidget")
ChildSpine.StarPath = "UMG.Role.Widget.Vertebra.uw_general_star_data"

function ChildSpine:Construct()
    self.tbAnim = {
        self.Anim_1,
        self.Anim_2,
        self.Anim_3,
        self.Anim_4,
        self.Anim_5,
        self.Anim_6,
        self.Anim_7,
        self.Anim_8,
        self.Anim_9,
        self.Anim_10
    }

    self.pStar = Model.Use(self, self.SatrPath)
    WidgetUtils.Collapsed(self)
    WidgetUtils.Collapsed(self.BGBtn)

    BtnAddEvent(self.BGBtn, function()
        self:CloseTip()
    end)
end

function ChildSpine:CloseTip(bPop)
    local RoleUI = UI.GetUI("role")
    if RoleUI and RoleUI:IsOpen() then
        local NerveUI = RoleUI:GetSwitcherWidget("NerveMain")
        if NerveUI and NerveUI.Intro and NerveUI.Intro:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
            NerveUI.Intro:BindToAnimationFinished(NerveUI.Intro.AnimClose, {NerveUI.Intro, function()
                NerveUI.Intro:UnbindAllFromAnimationFinished(NerveUI.Intro.AnimClose)
                NerveUI.Intro:Close(bPop)
            end})
            NerveUI.Intro:PlayAnimation(NerveUI.Intro.AnimClose)
        end
    end
    Preview.PlayCameraAnimByCallback(self.NodeDate.Item:Id(), PreviewType.role_spine_inner)
    WidgetUtils.Collapsed(self.BGBtn)
    EventSystem.TriggerTarget(Spine, Spine.ShowPreviewNote, false)
end

--- 子界面入口
---@param InNodeId integer 主节点Id
function ChildSpine:OnOpen(InNodeInfo)
    if self.EventActive then
        EventSystem.Remove(self.EventActive)
    end
    self.EventActive = EventSystem.OnTarget(Spine, Spine.UpDataNode, function(Target, tbData)
        self:ActivedCalllBack(tbData)
    end)

    self.NodeDate = InNodeInfo or self.NodeDate
    self.tbInfo = Spine.tbKeyId[InNodeInfo.Item:SpineId()][InNodeInfo.MastIdx]
    self:PlayShow(self.Appear)
    local nCanActived = 1
    for i = 1, Spine.MaxSubNum do
        --- 激活激活状态下的连线
        local bActive = self.NodeDate.Item:GetSpine(self.NodeDate.MastIdx, i)
        self:ShowActivedNode(i, bActive)
        if bActive then
            if i < Spine.MaxSubNum then
                nCanActived = i+1
            else
                nCanActived = Spine.MaxSubNum
            end
        end
        local tbParam = self:InitChildNoteParam(i, self.NodeDate)
        if self["Child"..i] then
            self["Child"..i]:OnOpen(tbParam)
        end
    end

    local RoleUI = UI.GetUI("role")
    if RoleUI and RoleUI:IsOpen() then
        local NerveUI = RoleUI:GetSwitcherWidget("NerveMain")
        if NerveUI and NerveUI.Intro and NerveUI.Intro:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
            self:InitTipParam(nCanActived, 1)
        end
    end
end

function ChildSpine:GetSpecialNote(InIdx)
    return Spine.GetNoteType(InIdx)
end

function ChildSpine:ActivedCalllBack(InData)
    self.NodeDate = {
        Item = InData.Item,
        MastIdx = InData.Idx,
    }

    local nCanActived = 1
    if InData.SubId < Spine.MaxSubNum then
        nCanActived = InData.SubId + 1
    else
        nCanActived = Spine.MaxSubNum
    end

    self:InitTipParam(nCanActived, 1)
    self:UpDataActived(InData)
end

function ChildSpine:InitChildNoteParam(Idx, InNodeInfo)
    local tbParam = {
            NodeInfo = Spine.tbSpineNode[self.tbInfo.SpId],
            Card = InNodeInfo.Item,
            MastIdx = InNodeInfo.MastIdx,
            InIdx = Idx,
            -- Cate = self:GetSpecialNote(Idx),
            ClickFun = function(InIdx, InState)
                self:InitTipParam(InIdx, InState)
            end,
        }
    return tbParam
end

function ChildSpine:InitTipParam(InIdx, InState)
    local tbTipParam = {
        pItem = self.NodeDate.Item,
        MastIdx = self.NodeDate.MastIdx,
        SubIdx = InIdx,
        TipState = InState or 1,
    }

    --先隐藏角色列表和页签列表
    local RoleUI = UI.GetUI("role")
    if RoleUI and RoleUI:IsOpen() then
        local NerveUI = RoleUI:GetSwitcherWidget("NerveMain")
        if NerveUI and NerveUI.Intro then
            local IntroUI = NerveUI.Intro
            if IntroUI:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
                IntroUI:UpdatePanel(tbTipParam)
            else
                if RoleUI:IsAnimationPlaying(RoleUI.AllEnter) then
                    RoleUI:SetAnimationCurrentTime(RoleUI.AllEnter, RoleUI.AllEnter:GetEndTime())
                end
                WidgetUtils.HitTestInvisible(RoleUI.LeftList)
                WidgetUtils.Collapsed(RoleUI.RightList)
                WidgetUtils.Collapsed(RoleUI.BtnScreen)
                RoleUI.Title:Push(function ()
                    self:CloseTip(true)
                end)
                RoleUI:BindToAnimationEvent(RoleUI.Anim, {RoleUI, function()
                    RoleUI:UnbindAllFromAnimationFinished(RoleUI.Anim)
                    WidgetUtils.Collapsed(RoleUI.LeftList)
                end}, UE4.EWidgetAnimationEvent.Finished)
                RoleUI:PlayAnimation(RoleUI.Anim)
                RoleUI:PlayAnimation(RoleUI.VertebraEnter)
                RoleUI:PlayAnimation(RoleUI.NerveIntro)

                --再打开Tip界面
                Preview.PlayCameraAnimByCallback(self.NodeDate.Item:Id(), PreviewType.role_spine_point_detail, function()
                    IntroUI:Open(tbTipParam)
                end)
            end
        end
    end

    WidgetUtils.Visible(self.BGBtn)
    self:UpDataChildNode(InIdx)
end

--- 刷新子节点
--- @param InSelectId interge ==InId 选中
function ChildSpine:UpDataChildNode(InSelectId)
    for i = 1, Spine.MaxSubNum do
        local ChildItem = self["Child"..i]
        if ChildItem then
            if i == InSelectId then
                ChildItem:GetSelect(1)
            else
                ChildItem:GetSelect()
            end
            ChildItem:ShowNodeState()
        end
    end
end

--- 刷新子节点激活状态
function ChildSpine:UpDataActived(InData)
    for i = 1, Spine.MaxSubNum do
        local bActive = InData.Item:GetSpine(InData.Idx, i)
        if bActive then
            self["Child"..i]:ShowNodeState(1)
            self:ShowActivedNode(i, true)
        end
    end
end

function ChildSpine:ShowActivedNode(InIdx, bActive)
    local pWidget = self.PanelLine:GetChildAt(InIdx-1)
    local pShadowWidget = self.PanelLineShadow:GetChildAt(InIdx-1)
    pWidget:SetDesaturate(not bActive)
    pShadowWidget:SetDesaturate(not bActive)
end

--- 进场表现
---@param InAnim AnimInts
function ChildSpine:PlayShow(InAnim)
    if not self:IsAnimationPlaying(InAnim) then
        self:PlayAnimation(InAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end
end

function ChildSpine:OnCloseAnim()
    self:PlayShow(self.Disappear)
end
--- 子节点布局
---@param nId integer 主节点Id
---@param nChildId integer 子节点Id
function ChildSpine:SetChildLayouy(nId, nChildId)
    local FramId = Spine.tbKeyId[10001][nId].SpcondId
    local tbNodeId = Spine.tbSpineLayout[FramId]
    local tbFv = tbNodeId[nChildId].tblayout[1]
    return UE4.FVector2D(tbFv[1], tbFv[2])
end

function ChildSpine:SetData(InData)
    local NoteName = Text('ui.spinenode') --..InData.NodeId
    self.Txtname:SetText(NoteName)
    local sprogress = 66
    self.TxtProgress:SetText(sprogress .. "%")
    self:SetStarList(InData.NodeId)
end

---当前品质（置节点进度）
---@param InNodeIndex integer 节点进度
function ChildSpine:SetStarList(InNodeIndex)
    self:DoClearListItems(self.StarList)
    for i = 1, InNodeIndex do
        local tbParam = {}
        local NewStar = self.pStar:Create(tbParam)
        self.StarList:AddItem(NewStar)
    end
end

--- 子节点连线
---@param Instart integer 起始节点
---@param Inend integer 终点
---@param InNodeId integer 主节点Id
function ChildSpine:SetLine(InNodeId, Inend, Instate)
    local pLine = self.BarLine:GetChildAt(Inend - 1)
    if pLine then
        local InPos, OutPos = self:GetPosById(Spine.GetProgresNum(self.NodeDate.Item), Inend)
        local fLength = UE4.UKismetMathLibrary.VSize2D(OutPos - InPos)
        self:SetLineState(Instate, pLine,self.tbAnim[Inend])
        self:SetPosition((OutPos + InPos) / 2, pLine)
        self:SetLength(UE4.FVector2D(fLength, 10), pLine)
        pLine:SetRenderTransformAngle(Spine.SetAngle(OutPos - InPos))
    end
end

function ChildSpine:GetPosById(InNodeId, InId)
    local FramId = Spine.tbKeyId[10001][InNodeId].SpcondId
    local tbNodeId = Spine.tbSpineNodeCond[FramId][InId].NodeCondition
    if tbNodeId then
        if #tbNodeId == 1 then
            local pNode = self["Child"..InId]
            return UE4.FVector2D(0, 0), UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(pNode):GetPosition()
        end

        if #tbNodeId == 2 then
            local pInNode = self["Child"..InId]
            local poutNode = self["Child"..tbNodeId[2][2]]
            local InPos = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(pInNode):GetPosition()
            local OutPos = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(poutNode):GetPosition()
            return InPos, OutPos
        end

        --- 临时接口
        if #tbNodeId == 3 then
            return UE4.FVector2D(0, 0), UE4.FVector2D(0, 0)
        end
    end
end
--- TickTime
function ChildSpine:OnPaint(InContext)
    -- body
end
--- 设定连线的状态
---@param InState boolean 状态
---@param InLine Bar 连接线
function ChildSpine:SetLineState(InState, InLine,InAnim)
    if InState then
        InLine:SetValue(Lerp(0.0, 1.0, 1.0))
        self:PlayAnimation(InAnim, 0, 1000, UE4.EUMGSequencePlayMode.Forward, 1, true)
    else
        InLine:SetValue(0.0)
    end
end

-- 位置
function ChildSpine:SetPosition(InPos, InLine)
    UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(InLine):SetPosition(InPos)
end
-- 长度
function ChildSpine:SetLength(InFv2, InLine)
    UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(InLine):SetSize(InFv2)
end

function ChildSpine:OnClear()
    for i = 1, Spine.MaxSubNum do
        self["Child"..i]:OnClear()
    end
    EventSystem.Remove(self.EventActive)
    self.EventActive = nil
end

return ChildSpine
