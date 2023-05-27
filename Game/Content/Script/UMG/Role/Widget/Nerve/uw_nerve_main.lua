-- ========================================================
-- @File    : uw_nerve_main.lua
-- @Brief   : 角色脊椎主界面 (新版)
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.tbItemNode = {
        {SPLine = self.LULine, Point = self.LUPoint, Name = self.LUName, Intro = self.LUIntro, BtnSelect = self.BtnLUSelect, PanelSelect = self.PanelLUSelect, PanelNotSelect = self.PanelLUNotSelect, PanelOn = self.PanelLUOn, PanelOff = self.PanelLUOff, PanelLock = self.PanelLULock, Icon = {self.LUOnIcon,self.LUOffIcon,self.LULockIcon}, ChangeAnim1 = self.MainChangeSynapse_LU, ChangeAnim2 = self.MainChangeSynapse_LU_2},
        {SPLine = self.RULine, Point = self.RUPoint, Name = self.RUName, Intro = self.RUIntro, BtnSelect = self.BtnRUSelect, PanelSelect = self.PanelRUSelect, PanelNotSelect = self.PanelRUNotSelect, PanelOn = self.PanelRUOn, PanelOff = self.PanelRUOff, PanelLock = self.PanelRULock, Icon = {self.RUOnIcon,self.RUOffIcon,self.RULockIcon}, ChangeAnim1 = self.MainChangeSynapse_RU, ChangeAnim2 = self.MainChangeSynapse_RU_2},
        {SPLine = self.LMLine, Point = self.LMPoint, Name = self.LMName, Intro = self.LMIntro, BtnSelect = self.BtnLMSelect, PanelSelect = self.PanelLMSelect, PanelNotSelect = self.PanelLMNotSelect, PanelOn = self.PanelLMOn, PanelOff = self.PanelLMOff, PanelLock = self.PanelLMLock, Icon = {self.LMOnIcon,self.LMOffIcon,self.LMLockIcon}, ChangeAnim1 = self.MainChangeSynapse_LM, ChangeAnim2 = self.MainChangeSynapse_LM_2},
        {SPLine = self.RMLine, Point = self.RMPoint, Name = self.RMName, Intro = self.RMIntro, BtnSelect = self.BtnRMSelect, PanelSelect = self.PanelRMSelect, PanelNotSelect = self.PanelRMNotSelect, PanelOn = self.PanelRMOn, PanelOff = self.PanelRMOff, PanelLock = self.PanelRMLock, Icon = {self.RMOnIcon,self.RMOffIcon,self.RMLockIcon}, ChangeAnim1 = self.MainChangeSynapse_RM, ChangeAnim2 = self.MainChangeSynapse_RM_2},
        {SPLine = self.LDLine, Point = self.LDPoint, Name = self.LDName, Intro = self.LDIntro, BtnSelect = self.BtnLDSelect, PanelSelect = self.PanelLDSelect, PanelNotSelect = self.PanelLDNotSelect, PanelOn = self.PanelLDOn, PanelOff = self.PanelLDOff, PanelLock = self.PanelLDLock, Icon = {self.LDOnIcon,self.LDOffIcon,self.LDLockIcon}, ChangeAnim1 = self.MainChangeSynapse_LD, ChangeAnim2 = self.MainChangeSynapse_LD_2},
        {SPLine = self.RDLine, Point = self.RDPoint, Name = self.RDName, Intro = self.RDIntro, BtnSelect = self.BtnRDSelect, PanelSelect = self.PanelRDSelect, PanelNotSelect = self.PanelRDNotSelect, PanelOn = self.PanelRDOn, PanelOff = self.PanelRDOff, PanelLock = self.PanelRDLock, Icon = {self.RDOnIcon,self.RDOffIcon,self.RDLockIcon}, ChangeAnim1 = self.MainChangeSynapse_RD, ChangeAnim2 = self.MainChangeSynapse_RD_2},
    }
    self.tbNodeWidget = {self.LU, self.RU, self.LM, self.RM, self.LD, self.RD}
    self.tbNodeWidgetPos = {}
    self.NodeWidgetDePos = UE4.FVector2D(0, 0)
    self.ChildNodeWidgetDePos = UE4.FVector2D(0, 0)
    self:UpdateNodePos()

    BtnAddEvent(self.BGBtn, function ()
        if self.bShowSync then
            self:ShowSyncMessage(false)
        end
        if self.bShowIntro then
            self:ShowPanelIntro(false)
        end
    end)

    BtnAddEvent(self.BtnUp, function ()
        self:ShowPanelIntro(false, nil, true)
        Preview.PlayCameraAnimByCallback(self.pItem:Id(), PreviewType.role_spine_inner, function ()
            self:UpdateChildNodeDePos()
        end)
        local fun = function(Anim)
            if Anim then
                self:UnbindAllFromAnimationFinished(Anim)
            end
            WidgetUtils.Collapsed(self.Main)
            WidgetUtils.SelfHitTestInvisible(self.Synapse)
            self:PlayAnimation(self.MainChangeSynapse)
            self:UpdateChildNodePanel()
        end
        local anim = self.tbItemNode[self.SelectNodeIndex].ChangeAnim1
        if anim then
            self:BindToAnimationFinished(anim, {self, function ()
                fun(anim)
            end})
            self:PlayAnimation(anim)
        else
            fun()
        end
    end)
    BtnAddEvent(self.BtnReset2, function ()
        if self.Intro:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
            local RoleUI = UI.GetUI("role")
            if RoleUI and RoleUI:IsOpen() then
                RoleUI.Title:Pop()
            end
            self.Intro:Close()
            WidgetUtils.Collapsed(self["Nerve"..self.SelectNodeIndex].BGBtn)
            self:ShowTipAnim(false)
        end

        WidgetUtils.Collapsed(self.Synapse)
        Preview.PlayCameraAnimByCallback(self.pItem:Id(), PreviewType.role_spine, function ()
            WidgetUtils.SelfHitTestInvisible(self.Main)
            self:UpdateNodeDePos()
        end)
        self:UpdateNodePanel()
        local anim = self.tbItemNode[self.SelectNodeIndex].ChangeAnim2
        if anim then
            self:PlayAnimationReverse(anim)
        end
        if not self.pItem or self.pItem:IsTrial() then
            WidgetUtils.Collapsed(self.PanelReset)
        else
            WidgetUtils.SelfHitTestInvisible(self.PanelReset)
        end
        self:PlayAnimationReverse(self.SelectMain_0)
    end)

    BtnAddEvent(self.BtnReset, function()
        if not self.pItem then
            return
        end

        local bActive = false
        for i = 1, Spine.MaxMastNum do
            for Idx = 1, Spine.MaxSubNum do
                if self.pItem:GetSpine(i, Idx) then
                    if not bActive then bActive = true end
                    if bActive then break end
                end
            end
            if bActive then break end
        end

        if not bActive then
            UI.ShowTip("spine.nospineinactivation")
            return
        end
        UI.Open("MessageBox", Text("spine.confirmreset"), function() Spine.Req_ChildNodeReset(self.pItem, function() self:UpdateNodePanel() end) end)
    end)

    for index, Item in ipairs(self.tbItemNode) do
        BtnAddEvent(Item.BtnSelect, function ()
            self:OnClickSelect(index)
        end)
    end

    BtnAddEvent(self.BtnNodeSelect, function ()
        if not FunctionRouter.IsOpenById(FunctionType.ProLevel) then
            UI.ShowTip(Text("ui.TxtNotOpen"))
            return
        end
        if not self.bShowSync then
            self:ShowSyncMessage(true)
        end
    end)

    self.RealTime = 0
end

function tbClass:LoadingCurve()
    if not self.tbNodeCurve or #self.tbNodeCurve == 0 then
        --节点浮动曲线
        self.tbNodeCurve = {}
        for i = 1, 6 do
            self.tbNodeCurve[i] = self:LoadAssetFormPath("CurveFloat'/Game/UI/UMG/Role/Widgets/Nerve/NodeCurve/NodeCurve_".. i ..".NodeCurve_".. i .."'")
        end
    end
    if not self.PanelNodeMianCurve then
        --中间节点浮动曲线
        self.PanelNodeMianCurve = self:LoadAssetFormPath("CurveFloat'/Game/UI/UMG/Role/Widgets/Nerve/NodeCurve/PanelNodeMianCurve.PanelNodeMianCurve'")
    end
    if not self.SynapseNodeCurve then
        --内层中间节点浮动曲线
        self.SynapseNodeCurve = self:LoadAssetFormPath("CurveFloat'/Game/UI/UMG/Role/Widgets/Nerve/NodeCurve/SynapseNodeCurve.SynapseNodeCurve'")
    end
end

--- 脊椎养成入口
--- @param Target UItem
function tbClass:OnActive(Template, Form, fun, Card)
    self.Model = nil
    self.pItem = Card or RoleCard.GetItem({Template.Genre, Template.Detail, Template.Particular, Template.Level}) or self.pItem
    if not self.pItem then
        return
    end

    self:LoadingCurve()
    self:UpdatePanelLevel()

    local AtrrTemplate = UE4.UItemLibrary.GetCharacterAtrributeTemplate(self.pItem:TemplateId())
    local tbID = AtrrTemplate.ShowSkills:ToTable() or {}
    self.tbSkillID = {tbID[2], tbID[2], tbID[4], tbID[4], tbID[3], tbID[3]}

    self:PlayAnimation(self.AllEnter)

    if self.pItem:IsTrial() then
        WidgetUtils.Collapsed(self.PanelReset)
        WidgetUtils.Collapsed(self.BtnUp)
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelReset)
        WidgetUtils.Visible(self.BtnUp)
    end
    WidgetUtils.Collapsed(self.PanelIntro)

    if self.SelectNodeIndex and self.tbItemNode[self.SelectNodeIndex] then
        local anim = self.tbItemNode[self.SelectNodeIndex].ChangeAnim2
        self:PlayAnimationReverse(anim)
        self:SetAnimationCurrentTime(anim, anim:GetStartTime())
    end

    WidgetUtils.Collapsed(self.Main)
    WidgetUtils.Collapsed(self.Synapse)
    local RecordIndx = Spine.GetRecordIndx(self.pItem:Id())
    if RecordIndx > 0 then
        self.SelectNodeIndex = RecordIndx
    else
        self:UnbindAllFromAnimationFinished(self.SelectMain_0)
        self:PlayAnimationReverse(self.SelectMain_0)
        self:SetAnimationCurrentTime(self.SelectMain_0, self.SelectMain_0:GetStartTime())
    end

    local nAnimLength = UE4.UUICameraLibrary.GetCameraAnimTime(Preview.GetCameraIDByItemID(self.pItem:Id()), Preview.GetCameraType(), PreviewType.role_spine)
    Preview.PreviewByCardAndWeapon(self.pItem:Id(), 0, PreviewType.role_spine, true, function()
        RoleCard.ResetCach(self.pItem:Id())
        local pParent = UI.GetUI("Role")
        pParent:PlayChangeEmit()
        local Model = Preview.GetModel()
        if Model and Model:GetModel() then
            self.Model = Model:GetModel()

            if RecordIndx > 0 then
                WidgetUtils.Collapsed(self.Main)
                self:UpdateChildNodePanel()
                Preview.PlayCameraAnimByCallback(self.pItem:Id(), PreviewType.role_spine_inner, function ()
                    WidgetUtils.SelfHitTestInvisible(self.Synapse)
                    self:UpdateChildNodeDePos()
                end)
            else
                self.nDelayTimer = UE4.Timer.Add(nAnimLength, function()
                    self.bReviseNodeDePos = true
                    self:UpdateNodeDePos()
                    WidgetUtils.Collapsed(self.Synapse)
                    WidgetUtils.SelfHitTestInvisible(self.Main)
                    self:UpdateNodePanel()
                end)
            end
        end
    end)

    self:ClearEvent()
    self.PreviewNodeAnim = EventSystem.OnTarget(Spine, Spine.ShowPreviewNote, function(Target, bShow)
        self:ShowTipAnim(bShow)
    end)
    self.EventActive = EventSystem.OnTarget(Spine, Spine.UpDataNode, function(Target, tbData)
        self:UpdateState(tbData.Idx, tbData.Item)
        if tbData and tbData.SubId == Spine.MaxSubNum then
            local fun = function ()
                if self.Intro:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
                    WidgetUtils.Collapsed(self.PanelNode)
                    Preview.PlayCameraAnimByCallback(tbData.Item:Id(), PreviewType.role_spine, function()
                        self.Intro:Close()
                        self.bReviseNodeDePos = true
                        WidgetUtils.SelfHitTestInvisible(self.PanelNode)
                    end)
                    WidgetUtils.Collapsed(self["Nerve"..self.SelectNodeIndex].BGBtn)
                    self:ShowTipAnim(false)
                end

                WidgetUtils.Collapsed(self.Synapse)
                WidgetUtils.SelfHitTestInvisible(self.Main)
                self:UpdateNodePanel()
                local anim = self.tbItemNode[self.SelectNodeIndex].ChangeAnim2
                if anim then
                    self:PlayAnimationReverse(anim)
                end
                if not self.pItem or self.pItem:IsTrial() then
                    WidgetUtils.Collapsed(self.PanelReset)
                else
                    WidgetUtils.SelfHitTestInvisible(self.PanelReset)
                end
                self:PlayAnimationReverse(self.SelectMain_0)
            end
            local UISkillTip = UI.GetUI("SpineSkillTip")
            if UISkillTip and UISkillTip:IsOpen() then
                UISkillTip.FunClose = fun
            else
                fun()
            end
        end
    end)
end

---刷新职级信息
function tbClass:UpdatePanelLevel()
    if not self.pItem then
        return
    end
    local proLevel = self.pItem:ProLevel()
    local showProLevel = 0
    if FunctionRouter.IsOpenById(FunctionType.ProLevel) then
        showProLevel = proLevel+1
    end
    for i = 1, 4 do
        if i>showProLevel then
            WidgetUtils.Collapsed(self["ImgLevel" .. i .. "_1"])
            WidgetUtils.HitTestInvisible(self["ImgLevel" .. i])
            WidgetUtils.Collapsed(self["ImgSynapseLevel" .. i .. "_1"])
            WidgetUtils.HitTestInvisible(self["ImgSynapseLevel" .. i])
        else
            WidgetUtils.Collapsed(self["ImgLevel" .. i])
            WidgetUtils.HitTestInvisible(self["ImgLevel" .. i .. "_1"])
            WidgetUtils.Collapsed(self["ImgSynapseLevel" .. i])
            WidgetUtils.HitTestInvisible(self["ImgSynapseLevel" .. i .. "_1"])
        end
    end
    if showProLevel>=4 then
        WidgetUtils.Collapsed(self.PanelNormal)
        WidgetUtils.HitTestInvisible(self.PanelSuccess)
        WidgetUtils.Collapsed(self.PanelSynapseNormal)
        WidgetUtils.HitTestInvisible(self.PanelSynapseSuccess)
    else
        WidgetUtils.Collapsed(self.PanelSuccess)
        WidgetUtils.HitTestInvisible(self.PanelNormal)
        WidgetUtils.Collapsed(self.PanelSynapseSuccess)
        WidgetUtils.HitTestInvisible(self.PanelSynapseNormal)
    end

    local key = table.concat({self.pItem:Genre(), self.pItem:Detail(), self.pItem:Particular(), self.pItem:Level()}, "-")
    local Data = RoleCard.tbProLevelData[key]
    if Data and Data.tbSkillID[proLevel] then
        local sIcon = UE4.UAbilityLibrary.GetSkillFixInfoStaticId(Data.tbSkillID[proLevel][1])
        SetTexture(self.ImgSkillSuc, sIcon)
        SetTexture(self.ImgSkillNor, sIcon)
        SetTexture(self.ImgSynapseSkillSuc, sIcon)
        SetTexture(self.ImgSynapseSkillNor, sIcon)
    end
end

---刷新职级红点
function tbClass:UpdateProLevelRedDot()
    if RoleCard.CheckCardRedDot(self.pItem, {7}) then
        WidgetUtils.HitTestInvisible(self.PanelNodeOn)
        self:PlayAnimation(self.InProgressSync, 0, 0)
    else
        WidgetUtils.Collapsed(self.PanelNodeOn)
        self:StopAnimation(self.InProgressSync)
    end
end

function tbClass:OnClickSelect(index)
    if not self.pItem then
        return
    end
    local tbInfo = Spine.tbKeyId[self.pItem:SpineId()][index]
    if not tbInfo then
        return
    end

    if self.SelectNodeIndex and self.tbItemNode[self.SelectNodeIndex] then
        WidgetUtils.Collapsed(self.tbItemNode[self.SelectNodeIndex].PanelSelect)
        WidgetUtils.HitTestInvisible(self.tbItemNode[self.SelectNodeIndex].PanelNotSelect)
    end
    if self.tbItemNode[index] then
        WidgetUtils.Collapsed(self.tbItemNode[index].PanelNotSelect)
        WidgetUtils.HitTestInvisible(self.tbItemNode[index].PanelSelect)
    end
    self.SelectNodeIndex = index

    self:ShowPanelIntro(true)

    self.Txtname:SetText(SkillName(tbInfo.SpDes))
    local NodeInfo = Spine.tbSpineNode[tbInfo.SpId][Spine.MaxSubNum]
    self.SkillDes:SetContent(SkillDesc(NodeInfo.Nodedes))
    local SkillId = self.tbSkillID[index]
    if SkillId then
        SetTexture(self.ImgIcon, UE4.UAbilityLibrary.GetSkillIcon(SkillId))
    end
end

function tbClass:ShowSyncMessage(bShow, bTitlePop)
    self.bReviseNodeDePos = false
    if not self.pItem then
        return
    end

    if self.bShowSync == bShow then
        return
    end
    --是否显示职级详情界面
    self.bShowSync = bShow

    if bShow and self.bShowIntro then
        WidgetUtils.Collapsed(self.PanelIntro)
        self:StopAnimation(self.SelectMainNode)
        if self.SelectNodeIndex and self.tbItemNode[self.SelectNodeIndex] then
            WidgetUtils.Collapsed(self.tbItemNode[self.SelectNodeIndex].PanelSelect)
            WidgetUtils.HitTestInvisible(self.tbItemNode[self.SelectNodeIndex].PanelNotSelect)
        end
        self.bShowIntro = false
        self.SyncMessage:Open(self.pItem, function ()
            self:UpdatePanelLevel()
            self:UpdateProLevelRedDot()
        end)
        return
    end

    --隐藏或显示角色列表和页签列表
    local RoleUI = UI.GetUI("role")
    local fun = function (bshow)
        if RoleUI and RoleUI:IsOpen() then
            if bshow then
                if RoleUI:IsAnimationPlaying(RoleUI.AllEnter) then
                    RoleUI:SetAnimationCurrentTime(RoleUI.AllEnter, RoleUI.AllEnter:GetEndTime())
                end
                WidgetUtils.HitTestInvisible(RoleUI.LeftList)
                WidgetUtils.Collapsed(RoleUI.RightList)
                WidgetUtils.Collapsed(RoleUI.BtnScreen)
                RoleUI.Title:Push(function()
                    if self.bShowSync then
                        self:ShowSyncMessage(false, true)
                    end
                    if self.bShowIntro then
                        self:ShowPanelIntro(false, true)
                    end
                end)
                RoleUI:BindToAnimationEvent(RoleUI.Anim, {RoleUI, function()
                    RoleUI:UnbindAllFromAnimationFinished(RoleUI.Anim)
                    WidgetUtils.Collapsed(RoleUI.LeftList)
                end}, UE4.EWidgetAnimationEvent.Finished)
                RoleUI:PlayAnimation(RoleUI.Anim)
                RoleUI:PlayAnimation(RoleUI.VertebraEnter)
            else
                if RoleUI:IsAnimationPlaying(RoleUI.Anim) then
                    RoleUI:UnbindAllFromAnimationFinished(RoleUI.Anim)
                end
                RoleUI:PlayAnimationReverse(RoleUI.Anim)
                RoleUI:SetAnimationCurrentTime(RoleUI.Anim, RoleUI.Anim:GetStartTime())
                RoleUI:PlayAnimationReverse(RoleUI.VertebraEnter)
                WidgetUtils.SelfHitTestInvisible(RoleUI.RightList)
                WidgetUtils.SelfHitTestInvisible(RoleUI.LeftList)
                WidgetUtils.Visible(RoleUI.BtnScreen)
                WidgetUtils.Collapsed(self.Money)
                if not bTitlePop and #RoleUI.Title.eventStack > 1 then
                    RoleUI.Title:Pop()
                end
            end
        end
    end

    if bShow then
        RoleUI:PlayAnimation(RoleUI.NerveIntro)
        fun(true)
        self.SyncMessage:Open(self.pItem, function ()
            self:UpdatePanelLevel()
            self:UpdateProLevelRedDot()
        end)
        self:StopAnimation(self.SelectMain_0)
        self:PlayAnimation(self.SelectMain)
        Preview.PlayCameraAnimByCallback(self.pItem:Id(), PreviewType.role_spine_point)
    else
        RoleUI:PlayAnimationReverse(RoleUI.NerveIntro)
        self:StopAnimation(self.SelectMain)
        self.SyncMessage:Close(function ()
            fun(false)
        end)
        if self.pItem:IsTrial() then
            WidgetUtils.Collapsed(self.PanelReset)
        else
            WidgetUtils.SelfHitTestInvisible(self.PanelReset)
        end
        self:PlayAnimationReverse(self.SelectMain_0)
        Preview.PlayCameraAnimByCallback(self.pItem:Id(), PreviewType.role_spine)
    end
end

function tbClass:ShowPanelIntro(bShow, bTitlePop, bFixedCamera)
    self.bReviseNodeDePos = false
    if not self.pItem then
        return
    end

    if self.bShowIntro == bShow then
        return
    end
    --是否显示神经详情界面
    self.bShowIntro = bShow

    if bShow and self.bShowSync then
        WidgetUtils.Collapsed(self.SyncMessage)
        WidgetUtils.SelfHitTestInvisible(self.PanelIntro)
        self:StopAnimation(self.SelectMain_0)
        self.bShowSync = false
        return
    end

    --隐藏或显示角色列表和页签列表
    local RoleUI = UI.GetUI("role")
    local fun = function (bshow)
        if RoleUI and RoleUI:IsOpen() then
            if bshow then
                if RoleUI:IsAnimationPlaying(RoleUI.AllEnter) then
                    RoleUI:SetAnimationCurrentTime(RoleUI.AllEnter, RoleUI.AllEnter:GetEndTime())
                end
                WidgetUtils.HitTestInvisible(RoleUI.LeftList)
                WidgetUtils.Collapsed(RoleUI.RightList)
                WidgetUtils.Collapsed(RoleUI.BtnScreen)
                RoleUI.Title:Push(function()
                    if self.bShowSync then
                        self:ShowSyncMessage(false, true)
                    end
                    if self.bShowIntro then
                        self:ShowPanelIntro(false, true)
                    end
                end)
                RoleUI:BindToAnimationEvent(RoleUI.Anim, {RoleUI, function()
                    RoleUI:UnbindAllFromAnimationFinished(RoleUI.Anim)
                    WidgetUtils.Collapsed(RoleUI.LeftList)
                end}, UE4.EWidgetAnimationEvent.Finished)
                RoleUI:PlayAnimation(RoleUI.Anim)
                RoleUI:PlayAnimation(RoleUI.VertebraEnter)
            else
                if RoleUI:IsAnimationPlaying(RoleUI.Anim) then
                    RoleUI:UnbindAllFromAnimationFinished(RoleUI.Anim)
                end
                RoleUI:PlayAnimationReverse(RoleUI.Anim)
                RoleUI:SetAnimationCurrentTime(RoleUI.Anim, RoleUI.Anim:GetStartTime())
                RoleUI:PlayAnimationReverse(RoleUI.VertebraEnter)
                WidgetUtils.SelfHitTestInvisible(RoleUI.RightList)
                WidgetUtils.SelfHitTestInvisible(RoleUI.LeftList)
                WidgetUtils.Visible(RoleUI.BtnScreen)
                WidgetUtils.Collapsed(self.Money)
                if not bTitlePop and #RoleUI.Title.eventStack > 1 then
                    RoleUI.Title:Pop()
                end
            end
        end
    end

    if bShow then
        RoleUI:PlayAnimation(RoleUI.NerveIntro)
        fun(true)
        WidgetUtils.SelfHitTestInvisible(self.PanelIntro)
        self:StopAnimation(self.SelectMain_0)
        self:PlayAnimation(self.SelectMain)
        self:PlayAnimation(self.SelectMainNode, 0, 0)
        if not bFixedCamera then
            Preview.PlayCameraAnimByCallback(self.pItem:Id(), PreviewType.role_spine_point)
        end
    else
        RoleUI:PlayAnimationReverse(RoleUI.NerveIntro)
        WidgetUtils.HitTestInvisible(self.PanelIntro)
        local funFinished = function ()
            fun(false)
            WidgetUtils.Collapsed(self.PanelIntro)
            self:StopAnimation(self.SelectMainNode)
            if self.SelectNodeIndex and self.tbItemNode[self.SelectNodeIndex] then
                WidgetUtils.Collapsed(self.tbItemNode[self.SelectNodeIndex].PanelSelect)
                WidgetUtils.HitTestInvisible(self.tbItemNode[self.SelectNodeIndex].PanelNotSelect)
            end
        end
        self:StopAnimation(self.SelectMain)
        self:UnbindAllFromAnimationFinished(self.SelectMain_0)
        if not bFixedCamera then
            self:BindToAnimationFinished(self.SelectMain_0, {self, function()
                self:UnbindAllFromAnimationFinished(self.SelectMain_0)
                funFinished()
            end})
            if self.pItem:IsTrial() then
                WidgetUtils.Collapsed(self.PanelReset)
            else
                WidgetUtils.SelfHitTestInvisible(self.PanelReset)
            end
            self:PlayAnimationReverse(self.SelectMain_0)
            Preview.PlayCameraAnimByCallback(self.pItem:Id(), PreviewType.role_spine)
        else
            WidgetUtils.Collapsed(self.PanelReset)
            funFinished()
        end
    end
end

function tbClass:ShowTipAnim(bShow)
    if bShow then
        WidgetUtils.HitTestInvisible(self.BtnReset2)
    else
        WidgetUtils.Visible(self.BtnReset2)
    end
    if bShow and not self.bShowTip then
        self:PlayAnimation(self.SelectSynapse)
    end
    if not bShow and self.bShowTip then
        self:PlayAnimationReverse(self.SelectSynapse)
    end
    self.bShowTip = bShow
end

function tbClass:UpdateNodePanel()
    if not self.pItem then
        return
    end
    self.nShowType = 1
    local RecordIndx = Spine.GetRecordIndx(self.pItem:Id())
    if RecordIndx > 0 then
        self:PlayAnimation(self.InProgress, 0, 0)
    else
        self:StopAnimation(self.InProgress)
    end
    for i = 1, Spine.MaxMastNum do
        local WidgetItem = self.tbItemNode[i]
        local tbInfo = Spine.tbKeyId[self.pItem:SpineId()][i]
        if WidgetItem and tbInfo then
            local bActived = self.pItem:GetSpine(i, Spine.MaxSubNum)
            if not self.SelectNodeIndex or not self.tbItemNode[self.SelectNodeIndex] then
                self.SelectNodeIndex = i
            end
            if bActived then
                WidgetUtils.Collapsed(WidgetItem.PanelOff)
                WidgetUtils.Collapsed(WidgetItem.PanelLock)
                WidgetUtils.HitTestInvisible(WidgetItem.PanelOn)
            else
                WidgetUtils.Collapsed(WidgetItem.PanelOn)
                if RecordIndx == i then
                    WidgetUtils.Collapsed(WidgetItem.PanelLock)
                    WidgetUtils.HitTestInvisible(WidgetItem.PanelOff)
                else
                    WidgetUtils.Collapsed(WidgetItem.PanelOff)
                    WidgetUtils.HitTestInvisible(WidgetItem.PanelLock)
                end
            end
            WidgetUtils.Collapsed(WidgetItem.PanelSelect)
            WidgetUtils.HitTestInvisible(WidgetItem.PanelNotSelect)
            --WidgetItem.Name:SetText(i)
            WidgetItem.Intro:SetText(SkillDesc(tbInfo.SpDes))

            local SkillId = self.tbSkillID[i]
            if SkillId then
                local sIcon = UE4.UAbilityLibrary.GetSkillIcon(SkillId)
                for _, IconImg in ipairs(WidgetItem.Icon) do
                    SetTexture(IconImg, sIcon)
                end
            end
        end
    end
    self:UpdateResetPanel()
    self:UpdateProLevelRedDot()
end

--- 主节点刷新
---@param InIdx iterge 主节点Idx
function tbClass:UpDataMasterNode(InIdx)
    for p = 1, Spine.MaxMastNum do
        WidgetUtils.Collapsed(self["Nerve" .. p])
        if p == InIdx then
            WidgetUtils.SelfHitTestInvisible(self["Nerve" .. InIdx])
        end
    end
end
function tbClass:UpdateChildNodePanel()
    self.nShowType = 2
    --- 子界面打开入口
    local InIdx = self.SelectNodeIndex
    local tbSNote = {
        Item = self.pItem,
        MastIdx = InIdx,
    }
    Spine.ActivedIdx = 1
    if self.NoteRoot:GetVisibility() ~= UE4.ESlateVisibility.SelfHitTestInvisible then
        WidgetUtils.SelfHitTestInvisible(self.NoteRoot)
    end
    self:UpDataMasterNode(InIdx)
    self:UpdateSynapseNode(InIdx, self.pItem, self.tbSkillID[InIdx])
    --self.Node:UpdatePanel(InIdx, self.pItem, self.tbSkillID[InIdx])
    self["Nerve"..self.SelectNodeIndex]:OnOpen(tbSNote)
end

function tbClass:UpdateSynapseNode(Idx, pItem, SkillID)
    if SkillID then
        local icon = UE4.UAbilityLibrary.GetSkillIcon(SkillID)
        SetTexture(self.ImgOnIcon, icon)
        SetTexture(self.ImgOffIcon, icon)
    end
    if not pItem then return end
    if pItem:GetSpine(Idx, Spine.MaxSubNum) then
        WidgetUtils.Collapsed(self.ImgOffIcon)
        WidgetUtils.HitTestInvisible(self.ImgOnIcon)
    else
        WidgetUtils.Collapsed(self.ImgOnIcon)
        WidgetUtils.HitTestInvisible(self.ImgOffIcon)
    end

    self:UpdateState(Idx, pItem)
end
function tbClass:UpdateState(Idx, pItem)
    if not pItem then return end
    local RecordIndx = Spine.GetRecordIndx(pItem:Id())
    if Idx%2 ~= 0 then
        WidgetUtils.Collapsed(self.ImgOffBG2)
        WidgetUtils.Collapsed(self.ImgOnBG2)
        WidgetUtils.Collapsed(self.ImgLockBG2)
        if pItem:GetSpine(Idx, Spine.MaxSubNum) then
            WidgetUtils.Collapsed(self.ImgLockBG1)
            WidgetUtils.Collapsed(self.ImgOffBG1)
            WidgetUtils.HitTestInvisible(self.ImgOnBG1)
        elseif RecordIndx == Idx then
            WidgetUtils.Collapsed(self.ImgLockBG1)
            WidgetUtils.Collapsed(self.ImgOnBG1)
            WidgetUtils.HitTestInvisible(self.ImgOffBG1)
        else
            WidgetUtils.Collapsed(self.ImgOffBG1)
            WidgetUtils.Collapsed(self.ImgOnBG1)
            WidgetUtils.HitTestInvisible(self.ImgLockBG1)
        end
    else
        WidgetUtils.Collapsed(self.ImgOffBG1)
        WidgetUtils.Collapsed(self.ImgOnBG1)
        WidgetUtils.Collapsed(self.ImgLockBG1)
        if pItem:GetSpine(Idx, Spine.MaxSubNum) then
            WidgetUtils.Collapsed(self.ImgLockBG2)
            WidgetUtils.Collapsed(self.ImgOffBG2)
            WidgetUtils.HitTestInvisible(self.ImgOnBG2)
        elseif RecordIndx == Idx then
            WidgetUtils.Collapsed(self.ImgLockBG2)
            WidgetUtils.Collapsed(self.ImgOnBG2)
            WidgetUtils.HitTestInvisible(self.ImgOffBG2)
        else
            WidgetUtils.Collapsed(self.ImgOffBG2)
            WidgetUtils.Collapsed(self.ImgOnBG2)
            WidgetUtils.HitTestInvisible(self.ImgLockBG2)
        end
    end
end

function tbClass:UpdateResetPanel()
    local limitNum = 0
    local limitLevel = nil
    local completeNum = 0
    local CondID = Spine.tbKeyId[self.pItem:SpineId()][0]
    if CondID then
        for i = 1, Spine.MaxMastNum do
            local tbCond = Spine.tbSpineCond[CondID][i]
            if self.pItem:EnhanceLevel() >= tbCond[1][2] then
                limitNum = limitNum + 1
            elseif not limitLevel then
                limitLevel = tbCond[1][2]
            end

            if self.pItem:GetSpine(i, Spine.MaxSubNum) then
                completeNum = completeNum + 1
            end
        end
    end
    if limitLevel then
        self.TxtNerveUnlockLevel:SetText(Text("ui.TxtNerveUnlockLevel", limitLevel))
    else
        self.TxtNerveUnlockLevel:SetText(Text("ui.TxtAllSpine"))
    end
    if Spine.GetRecordIndx(self.pItem:Id()) > 0 then
        self.TxtNum:SetText(math.min(completeNum+1, limitNum))
    else
        self.TxtNum:SetText(math.min(completeNum, limitNum))
    end
    self.TxtLimit:SetText(limitNum)
end

function tbClass:ClearEvent()
    if self.PreviewNodeAnim then
        EventSystem.Remove(self.PreviewNodeAnim)
        self.PreviewNodeAnim = nil
    end
    if self.EventActive then
        EventSystem.Remove(self.EventActive)
        self.EventActive = nil
    end
end

function tbClass:OnClear()
    self:ClearEvent()
    self:ShowPanelIntro(false)
    for i = 1, Spine.MaxMastNum do
        if self["Nerve" .. i] then
            self["Nerve" .. i]:OnClear()
        end
    end
    self.Model = nil
    --1Main 2Synapse
    self.nShowType = nil

    if self.nDelayTimer then
        UE4.Timer.Cancel(self.nDelayTimer)
        self.nDelayTimer = nil
    end

end

function tbClass:OnDisable()
    RoleCard.ResetCach()
    self:OnClear()
    Preview.Destroy()
end

function tbClass:OnClose()
    self:OnClear()
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.nShowType or not self.Model then
        return
    end
    if not self.RealTime then
        self.RealTime = 0
    end
    self.RealTime = self.RealTime + InDeltaTime
    if self.RealTime > 1 then
        self.RealTime = 0
    end

    if self.nShowType == 1 then
        self:TickShowMain()
    elseif self.nShowType == 2 then
        self:TickShowSynapse()
    end
end

function tbClass:UpdateNodePos()
    self.tbNodeWidgetPos = {}
    for index, Node in ipairs(self.tbNodeWidget) do
        local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(Node)
        self.tbNodeWidgetPos[index] = Slot:GetPosition()
    end

    local NoteRootSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.NoteRoot)
    self.NoteRootPos = NoteRootSlot:GetPosition()
end
function tbClass:UpdateNodeDePos()
    self.NodeWidgetDePos = UE4.FVector2D(0, 0)
    if not self.Model then
        return
    end
    local pos = UE4.FVector2D(0, 0)
    local VectorPos = self.Model:K2_GetMeshComponent():GetSocketLocation(self.NodeLine.NodeSocketName)
    UE4.UGameplayStatics.ProjectWorldToScreen(self:GetOwningPlayer(), VectorPos, pos)
    UE4.USlateBlueprintLibrary.ScreenToWidgetLocal(self, self.CenterPos:GetCachedGeometry(), pos, self.NodeWidgetDePos)
end

function tbClass:TickShowMain()
    local Controller = self:GetOwningPlayer()
    local ArrayPos = self.NodeLine.ArrayPos
    local ArrayPosLength = ArrayPos:Length()
    local CenterGeometry = self.CenterPos:GetCachedGeometry()

    local pos1 = UE4.FVector2D()
    local VectorPos = self.Model:K2_GetMeshComponent():GetSocketLocation(self.NodeLine.SocketName)
    UE4.UGameplayStatics.ProjectWorldToScreen(Controller, VectorPos, pos1)

    local pos1Local = UE4.FVector2D()
    UE4.USlateBlueprintLibrary.ScreenToWidgetLocal(self, CenterGeometry, pos1, pos1Local)
    if ArrayPosLength >= 1 then
        pos1Local = pos1Local + ArrayPos:Get(1)
    end
    local NodeMianSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.PanelNodeMian)
    if self.PanelNodeMianCurve and self.RealTime then
        pos1Local = pos1Local + self.NodeLine.FloatingBase * self.PanelNodeMianCurve:GetFloatValue(self.RealTime)
    end
    NodeMianSlot:SetPosition(pos1Local)

    local pos2 = UE4.FVector2D(0, 0)
    local VectorPos2 = self.Model:K2_GetMeshComponent():GetSocketLocation(self.NodeLine.NodeSocketName)
    UE4.UGameplayStatics.ProjectWorldToScreen(Controller, VectorPos2, pos2)
    local pos2Local = UE4.FVector2D()
    UE4.USlateBlueprintLibrary.ScreenToWidgetLocal(self, CenterGeometry, pos2, pos2Local)
    if self.bReviseNodeDePos and math.abs(pos2Local.Y - self.NodeWidgetDePos.Y) > 5 then
        self.NodeWidgetDePos = pos2Local
    end

    for i = 1, 6 do
        local Pos = UE4.FVector2D()
        if self.tbNodeWidgetPos[i] then
            Pos = self.tbNodeWidgetPos[i]
        end
        local Node = self.tbNodeWidget[i]
        if Pos and Node then
            local NodePos = pos2Local+Pos-self.NodeWidgetDePos
            local Curve = self.tbNodeCurve[i]
            if Curve and self.RealTime then
                NodePos = NodePos + self.NodeLine.FloatingBase * Curve:GetFloatValue(self.RealTime)
            end
            local Slot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(Node)
            Slot:SetPosition(NodePos)

            local spline = self.tbItemNode[i].SPLine
            local splineSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(spline)
            splineSlot:SetPosition(NodePos)

            local NodeGeometry = Node:GetCachedGeometry()
            local Nodesize = UE4.USlateBlueprintLibrary.GetLocalSize(NodeGeometry) * 0.5
            local NodePosView = UE4.FVector2D()
            UE4.USlateBlueprintLibrary.LocalToViewport(Node, NodeGeometry, Nodesize, UE4.FVector2D(), NodePosView)

            local pointPosView = self:GetWidgetViewportPos(self.tbItemNode[i].Point)
            if ArrayPosLength >= i+1 then
                pointPosView = pointPosView + ArrayPos:Get(i+1)
            end

            local index = spline:GetNumberOfSplinePoints()-1
            local SplinePoint = spline:GetSplinePointAtIndex(index)
            SplinePoint.Location = pointPosView-NodePosView
            spline:ChangeSplinePointAtIndex(SplinePoint, index, true)
        end
    end
end

function tbClass:UpdateChildNodeDePos()
    self.ChildNodeWidgetDePos = UE4.FVector2D(0, 0)
    if not self.Model then
        return
    end
    local pos = UE4.FVector2D(0, 0)
    local VectorPos = self.Model:K2_GetMeshComponent():GetSocketLocation(self.NodeLine.ChildNodeSocketName)
    UE4.UGameplayStatics.ProjectWorldToScreen(self:GetOwningPlayer(), VectorPos, pos)
    UE4.USlateBlueprintLibrary.ScreenToWidgetLocal(self, self.CenterPos:GetCachedGeometry(), pos, self.ChildNodeWidgetDePos)
end

function tbClass:TickShowSynapse()
    local Controller = self:GetOwningPlayer()
    local CenterGeometry = self.CenterPos:GetCachedGeometry()

    local pos1 = UE4.FVector2D()
    local VectorPos = self.Model:K2_GetMeshComponent():GetSocketLocation(self.NodeLine.ChildNodeSocketName)
    UE4.UGameplayStatics.ProjectWorldToScreen(Controller, VectorPos, pos1)

    local pos1Local = UE4.FVector2D()
    UE4.USlateBlueprintLibrary.ScreenToWidgetLocal(self, CenterGeometry, pos1, pos1Local)

    local NoteRootSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.NoteRoot)
    NoteRootSlot:SetPosition(pos1Local + self.NoteRootPos - self.ChildNodeWidgetDePos)

    local pos2 = UE4.FVector2D()
    local VectorPos2 = self.Model:K2_GetMeshComponent():GetSocketLocation(self.NodeLine.SocketName)
    UE4.UGameplayStatics.ProjectWorldToScreen(Controller, VectorPos2, pos2)
    local pos2Local = UE4.FVector2D()
    UE4.USlateBlueprintLibrary.ScreenToWidgetLocal(self, self.CenterPos:GetCachedGeometry(), pos2, pos2Local)
    local LiSynapseNodeneLSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.SynapseNode)
    if self.SynapseNodeCurve and self.RealTime then
        pos2Local = pos2Local + self.NodeLine.FloatingBase * self.SynapseNodeCurve:GetFloatValue(self.RealTime)
    end
    LiSynapseNodeneLSlot:SetPosition(pos2Local)

    local index = self.Line:GetNumberOfSplinePoints()-1
    local SplinePoint = self.Line:GetSplinePointAtIndex(index)
    local pointPosView1 = self:GetWidgetViewportPos(self.SynapseNode)
    local pointPosView2 = self:GetWidgetViewportPos(self.LineR)
    local ArrayPos = self.NodeLine.ArrayPos
    if ArrayPos:Length() >= 8 then
        pointPosView1 = pointPosView1 + ArrayPos:Get(8)
    end

    local LineSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Line)
    LineSlot:SetPosition(pointPosView2)

    SplinePoint.Location = pointPosView1-pointPosView2
    self.Line:ChangeSplinePointAtIndex(SplinePoint, index, true)
end

function tbClass:GetWidgetViewportPos(widget)
    local Geometry = widget:GetCachedGeometry()
    local size = UE4.USlateBlueprintLibrary.GetLocalSize(Geometry) * 0.5
    local Panel3D = UE4.UUMGLibrary.FindParentCanvasPanel3D(widget)
    local Pos = UE4.FVector2D()
    if Panel3D then
        UE4.USlateBlueprintLibrary.AbsoluteToViewport(self, UE4.UUMGLibrary.WidgetLocalToAbsolute3D(Panel3D, widget, size), UE4.FVector2D(), Pos)
    else
        UE4.USlateBlueprintLibrary.LocalToViewport(widget, Geometry, size, UE4.FVector2D(), Pos)
    end
    return Pos
end

return tbClass
