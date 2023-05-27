-- ========================================================
-- @File    : uw_fight_level_task_list_item.lua
-- @Brief   : 战斗界面 任务面板条目
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_level_task_list_item = Class("UMG.SubWidget")
local Item = uw_fight_level_task_list_item

Item.Obj = nil
Item.ExecutePtr = nil
Item.bTriggerFightTip = false

function Item:OnListItemObjectSet(InObj)
    if InObj == nil or not InObj.Data then
        return
    end

    if not self.DataChange then
        return
    end

    self.ExecutePtr = InObj.Data.Execute
    self:DataChange(InObj.Data.Execute, true, InObj.Data.bNoStarTip)

    self.NodeChangedHandle =
        EventSystem.On(
        Event.OnExecuteChange,
        function(Execute)  
            self:DataChange(Execute, nil, true)
        end
    )
    TaskCommon.AddHandle(self.NodeChangedHandle)

    local bShowUIAnim = InObj.Data.ShowUIAnim
    if bShowUIAnim == UE4.EExecuteUIAnimType.Big then
            --[[local Widgets_Task = self.ItemList:GetDisplayedEntryWidgets()
            for i=1,Widgets_Task:Length() do
                local Widget_Task = Widgets_Task:Get(i)
                if IsValid(Widget_Task) then
                    Widget_Task:PlayAnimFromAnimation(Widget_Task.task_refresh)
                end
            end--]]
            self:PlayAnimation(self.task_refresh)
        elseif bShowUIAnim == UE4.EExecuteUIAnimType.Little then
            --[[local Widgets_Task = self.ItemList:GetDisplayedEntryWidgets()
            for i=1,Widgets_Task:Length() do
                local Widget_Task = Widgets_Task:Get(i)
                if IsValid(Widget_Task) then
                    Widget_Task:PlayAnimFromAnimation(Widget_Task.task_refreshsmall)
                end
            end--]]
            self:PlayAnimation(self.task_refreshsmall)
        end
end

function Item:DataChange(Execute,delayShow)
    if self.ExecutePtr ~= Execute or not Execute then
        return
    end
    local CurrentState = Execute:GetNodeState()
    local Des = Execute:GetExecuteDescription()
    -- local DesWithoutRich = Execute:GetTitleDescription()
    -- local bShowUIAnim = Execute.showUIAnimType;
    -- local bShowCompleteTip = Execute.ShowCompleteTip;

    WidgetUtils.Collapsed(self.Progress)
    WidgetUtils.Collapsed(self.Fail)
    WidgetUtils.Collapsed(self.Succ)
    WidgetUtils.Collapsed(self.Disable)
    WidgetUtils.Collapsed(self.ImgDown)
    WidgetUtils.Collapsed(self.ImgIcon)

    if Execute.Icon ~= -1 then
        SetTexture(self.ImgIcon, Execute.ImgIcon)
        WidgetUtils.SelfHitTestInvisible(self.ImgIcon)
    end

    if Execute.IconBG ~= -1 then
        SetTexture(self.ImgDown, Execute.IconBG)
        WidgetUtils.SelfHitTestInvisible(self.ImgDown)
    end


    if CurrentState == UE4.ENodeState.Normal then
        WidgetUtils.SelfHitTestInvisible(self.Disable)
    elseif CurrentState == UE4.ENodeState.Succeeded then
        WidgetUtils.SelfHitTestInvisible(self.Succ)
        if not self.bTriggerFightTip then
            --EventSystem.Trigger(Event.FightTip, {Type = 1, Msg = DesWithoutRich,bShowUIAnim = bShowUIAnim, bShowCompleteTip = bShowCompleteTip})
            self.bTriggerFightTip = true
        end
    elseif CurrentState == UE4.ENodeState.Failed then
        WidgetUtils.SelfHitTestInvisible(self.Succ)
        if not self.bTriggerFightTip then
            --EventSystem.Trigger(Event.FightTip, {Type = 0, Msg = DesWithoutRich,bShowUIAnim = bShowUIAnim, bShowCompleteTip = bShowCompleteTip})
            self.bTriggerFightTip = true
        end
    elseif CurrentState == UE4.ENodeState.InProgress then
        WidgetUtils.HitTestInvisible(self)
        WidgetUtils.SelfHitTestInvisible(self.Progress)
    end
    if self.DesTimer then 
        UE4.Timer.Cancel(self.DesTimer)
        WidgetUtils.Visible(self.Des)
    end
    self.DesTimer = nil;
    if delayShow then
        WidgetUtils.Collapsed(self.Des)
        self.DesTimer = UE4.Timer.Add(0.1,function ( ... )
            WidgetUtils.Visible(self.Des)
            self.Des:SetText(Des)
        end)
    else
        self.Des:SetText(Des)
    end
    local StateImg = self:GetStateImg(CurrentState)
    if StateImg then
        self.Flag:SetBrushFromAtlasInterface(StateImg, true)
    end
    self:SetState(CurrentState)

    if Execute:IsTaskFinishExecute() and Launch.GetType() == LaunchType.CHAPTER then
        local FightUMG = UI.GetUI("Fight")
        if FightUMG then
            FightUMG:HideStarInfoTip()
        end
    end
end

function Item:GetStateImg(InState)
    if InState == UE4.ENodeState.Normal then
        return self.DisableImg
    elseif InState == UE4.ENodeState.Succeeded then
        return self.FinishImg
    elseif InState == UE4.ENodeState.InProgress then
        return self.ProgressImg
    end
    return self.DisableImg
end

function Item:OnDestruct()
    EventSystem.Remove(self.NodeChangedHandle)
end
return Item
