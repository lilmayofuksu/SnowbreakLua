-- ========================================================
-- @File    : uw_nerve_tips.lua
-- @Brief   : 角色脊椎结算界面
-- @Author  :
-- @Date    :
-- ========================================================

local CNodeTip = Class("UMG.SubWidget")

function CNodeTip:Construct()
    self:DoClearListItems(self.MatList)
    self.pMat = Model.Use(self)

    self.tbSkillType = {
        RoleCard.SkillType.NormalSkill,
        RoleCard.SkillType.NormalSkill,
        RoleCard.SkillType.BigSkill,
        RoleCard.SkillType.QTESkill,
        RoleCard.SkillType.NormalSkill
    }

    BtnAddEvent(self.BtnUp, function()
        ---是否是正在通导的节点
        local RecordIndx = Spine.GetRecordIndx(self.tbData.pItem:Id())
        if RecordIndx ~= 0 and RecordIndx ~= self.tbData.MastIdx then
            return UI.ShowTip("error.BadParam")
        end
        local fun  = function ()
            self:Req_Active(self.tbData)
        end
        ---解锁第一个节点提示一下
        if RecordIndx == 0 and Spine.ShowActiveTip then
            UI.Open("MessageBox", Text("spine.confirmstart"), fun)
            UI.Call2("MessageBox", "SetCostTip", false, function(bCheck)
                Spine.ShowActiveTip = not bCheck
            end)
        else
            fun()
        end
    end)
end

function CNodeTip:GetActived(InData)
    local tbNodeCond = self.tbNodeMatInfo[InData.SubIdx].NodeCondition
    if not tbNodeCond then
        return 2
    end
    local bActived = InData.pItem:GetSpine(InData.MastIdx, InData.SubIdx)
    if bActived then
        return 2            --- 已经解锁
    else
        if type(tbNodeCond[2]) == "table" then
            local bPreActived = InData.pItem:GetSpine(InData.MastIdx,tbNodeCond[2][2])
            if bPreActived then
                if InData.pItem:EnhanceLevel()< tbNodeCond[1][2] then
                    return 3
                end
                return 1
            else
                return 3
            end
        end

        if not tbNodeCond[2] then
            if InData.pItem:EnhanceLevel()< tbNodeCond[1][2] then
                return 3
            else
                if InData.TipState<=2 then
                    return 1
                else
                    return 3
                end
            end
        end
    end
end

--- 进入界面接口
function CNodeTip:Open(tbData)
    WidgetUtils.SelfHitTestInvisible(self)
    self:PlayAnimation(self.AllEnter)
    self:UpdatePanel(tbData)
end

---刷新界面
function CNodeTip:UpdatePanel(tbData)
    self.tbData = tbData or self.tbData
    local tbInfo = Spine.tbKeyId[self.tbData.pItem:SpineId()]
    self.tbNodeInfo = Spine.tbSpineNode[tbInfo[self.tbData.MastIdx].SpId]
    self.tbNodeMatInfo = Spine.tbSpineNodeCond[tbInfo[Spine.GetProgresNum(self.tbData.pItem)].SpcondId]
    --- 已经突破，预览和突破状态
    self:ChangeState(self:GetActived(self.tbData))
    --- 技能信息描述
    self:SkillDesInfo(self.tbData)
    --- 材料列表
    self:SetMatList(self.tbData)

    self:ShowNodeState(self.tbData)
end

function CNodeTip:Req_Active(IntbData)
    Spine.Req_ChildNode(
        IntbData,
        function()
            local MastIdx = IntbData.MastIdx
            local nSubIdx = IntbData.SubIdx
            local NiagaraName = 'GirlNoteSmall'
            Audio.PlaySounds(3014)
            self:ShowSkillTip(nSubIdx)

            if IntbData.SubIdx == Spine.MaxSubNum then
                NiagaraName = 'GirlNoteBig'
            end
            EventSystem.TriggerTarget(Spine, Spine.UpDataNode, {Item = IntbData.pItem, Idx = MastIdx, SubId = nSubIdx})
            EventSystem.TriggerTarget(Spine, Spine.NoteActivedFinishHandle, IntbData.SubIdx)
            EventSystem.TriggerTarget(Spine, Spine.WorldNiagaraPlayHandle, NiagaraName)
        end
    )
end

--- 消耗材料列表
function CNodeTip:SetMatList(InData)
    local tbMats = nil
    local tbexNum = Spine.GetItemNum(self.tbData.pItem:Id())
    local bexItem = false
    if tbexNum[1] > 0 or tbexNum[2] > 0 then
        bexItem = true
        tbMats = self.tbNodeMatInfo[InData.SubIdx].NodeRefund or {}
    else
        tbMats = self.tbNodeMatInfo[InData.SubIdx].NodeCost or {}
    end

    self:DoClearListItems(self.MatList)
    local tbMoney = {}
    for i, value in ipairs(tbMats) do
        local nNow = 0
        if bexItem then
            nNow = tbexNum[i]
        else
            nNow = me:GetItemCount(value[1], value[2], value[3], value[4])
            table.insert(tbMoney, {value[1], value[2], value[3], value[4]})
        end
        local tbParam = {
            G = value[1],
            D = value[2],
            P = value[3],
            L = value[4],
            N = {nNeedNum = value[5], nHaveNum = nNow},
            Total = nNow,
            pItem = self.tbData.pItem,
            Name = "111",
        }
        local NewMat = self.pMat:Create(tbParam)
        self.MatList:AddItem(NewMat)
    end

    local roleUI = UI.GetUI("role")
    if roleUI and roleUI:IsOpen() then
        local NerveUI = roleUI:GetSwitcherWidget("NerveMain")
        if NerveUI and NerveUI.Money then
            WidgetUtils.SelfHitTestInvisible(NerveUI.Money)
            NerveUI.Money:Init(tbMoney)
        end
    end
end

--- 显示技能描述信息
function CNodeTip:ShowSkillTip(SubId)
    local NodeInfo = self.tbNodeInfo[SubId]
    if NodeInfo and NodeInfo.Skilfix and NodeInfo.Skilfix > 0 then
        UI.Open("SpineSkillTip", NodeInfo.Nodedes)
    else
        if UI.IsOpen("SpineSkillTip") then
            UI.Close("SpineSkillTip")
        end
        UI.ShowTip('tip.rolespine_ok')
    end
end

--- 预览信息状态切换
---@param InForm Interge 1：升级技能2：预览
function CNodeTip:ChangeState(InForm)
    local tbNodeCond = self.tbNodeMatInfo[self.tbData.SubIdx].NodeCondition
    WidgetUtils.Collapsed(self.PanelUp)
    WidgetUtils.Collapsed(self.TxtSkillNotActive)

    if InForm == 2 then
        WidgetUtils.SelfHitTestInvisible(self.TxtSkillNotActive)
        self.TxtSkillNotActive:SetText(Text('spine.spineactived'))
        Color.SetTextColor(self.TxtSkillNotActive, "#010104")
        return
    end

    local RecordIndx = Spine.GetRecordIndx(self.tbData.pItem:Id())
    if RecordIndx ~= 0 and RecordIndx ~= self.tbData.MastIdx then
        WidgetUtils.SelfHitTestInvisible(self.TxtSkillNotActive)
        Color.SetTextColor(self.TxtSkillNotActive, "#010104")
        self.TxtSkillNotActive:SetText(Text('spine.spineinactivation'))
        return
    end

    if InForm == 1 then
        WidgetUtils.SelfHitTestInvisible(self.PanelUp)
        return
    end

    if InForm == 3 then
        WidgetUtils.SelfHitTestInvisible(self.TxtSkillNotActive)
        if self.tbData == nil then return end
        Color.SetTextColor(self.TxtSkillNotActive, "#DA1009")
        if type(tbNodeCond[2]) == "table" then
            if self.tbData.pItem:GetSpine(self.tbData.MastIdx,tbNodeCond[2][2]) then
                if self.tbData.pItem:EnhanceLevel()<= tbNodeCond[1][2] then
                    self.TxtSkillNotActive:SetText(Text('spine.nodelv')..tbNodeCond[1][2])
                    return
                end
            else
                self.TxtSkillNotActive:SetText(Text('spine.prespinenotactived'))
                return
            end
        else
            if self.tbData.pItem:EnhanceLevel()<= tbNodeCond[1][2] then
                self.TxtSkillNotActive:SetText(Text('spine.nodelv')..tbNodeCond[1][2])
                return
            end
        end
    end
end

--- 技能名及其描述
---@param InId Interge 技能Id
function CNodeTip:SkillDesInfo(InData)
    local NodeInfo = self.tbNodeInfo[InData.SubIdx]
    local InId = NodeInfo.Nodedes
    self.Txtname:SetText(SkillName(InId))

    if NodeInfo.AttributeID and NodeInfo.AttributeID[1] then
        local type = NodeInfo.AttributeID[1][1]
        local ParamArray = UE4.TArray(UE4.FString)
        ParamArray:Add(tostring(NodeInfo.AttributeID[1][2]))
        self.SkillDes:SetContent(UE4.UAbilityLibrary.FormatDescribe(Text("spine."..type), ParamArray))
    else
        local level = 1
        if NodeInfo.tbSkillId and NodeInfo.tbSkillId[1] then
            level = RoleCard.GetSkillLv(nil, NodeInfo.tbSkillId[1], self.tbData.pItem)
            if not self.tbData.pItem:GetSpine(InData.MastIdx, InData.SubIdx) then
                level = level + 1
            end
        end
        self.SkillDes:SetContent(SkillDesc(InId, nil, level))
    end
end

--- 节点和外部节点类型一致
function CNodeTip:ShowNodeState(InData)
    local NodeInfo = self.tbNodeInfo[InData.SubIdx]
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

function CNodeTip:Close(bPop)
    WidgetUtils.Collapsed(self)
    local RoleUI = UI.GetUI("role")
    if RoleUI and RoleUI:IsOpen() then
        if not bPop and #RoleUI.Title.eventStack > 1 then
            RoleUI.Title:Pop()
        end
        RoleUI:UnbindAllFromAnimationFinished(RoleUI.Anim)
        RoleUI:StopAnimation(RoleUI.Anim)
        RoleUI:PlayAnimationReverse(RoleUI.Anim)
        RoleUI:PlayAnimationReverse(RoleUI.NerveIntro)
        RoleUI:SetAnimationCurrentTime(RoleUI.Anim, RoleUI.Anim:GetStartTime())
        WidgetUtils.SelfHitTestInvisible(RoleUI.RightList)
        WidgetUtils.SelfHitTestInvisible(RoleUI.LeftList)
        WidgetUtils.Visible(RoleUI.BtnScreen)
        local NerveUI = RoleUI:GetSwitcherWidget("NerveMain")
        if NerveUI and NerveUI.Money then
            WidgetUtils.Collapsed(NerveUI.Money)
        end
    end
end

return CNodeTip
