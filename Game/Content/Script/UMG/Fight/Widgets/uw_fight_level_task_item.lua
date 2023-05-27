-- ========================================================
-- @File    : uw_fight_level_task_item.lua
-- @Brief   : 战斗界面 任务面板条目
-- @Author  :
-- @Date    :
-- ========================================================

local uw_fight_level_task_item = Class("UMG.SubWidget")

local LevelTaskItem = uw_fight_level_task_item

LevelTaskItem.Path="/Game/UI/UMG/Fight/Widgets/uw_fight_level_task_list_item_data"
LevelTaskItem.RefObj = nil

function LevelTaskItem:Initialize()
    local actor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
    if not IsValid(actor) then
        return
    end
    local task = actor:GetGameTask()
    if not task then
        return
    end
    local InFlow = task:GetCurrentFlowNode()
    if not IsValid(InFlow) then
        return
    end
    --local ItemClass = LoadClass(self.Path)
    --local NewItem = NewObject(ItemClass, self, nil)
    --NewItem:Test()
    self.Factory = Model.Use(self)
    local NewItem = self.Factory:Create({Flow = InFlow,GameTask = task})
    self:OnListItemObjectSet(NewItem)

end

function LevelTaskItem:OnListItemObjectSet(InObj)
    if InObj ==nil or InObj.Data == nil then
        return
    end
    if not self.DataChange then
        return
    end
    self.GameTask = InObj.Data.GameTask
    self.RefObj = InObj.Data.Flow
    if self.NodeChangedHandle then
        EventSystem.Remove(self.NodeChangedHandle)
    end
    self.NodeChangedHandle = EventSystem.On(
        Event.OnFlowChange,
        function(Flow)
            if IsValid(self) then
                self:DataChange(Flow)
            else
                print("LevelTaskItem Event OnFlowChange CallBack, self invalid!")
            end
        end
    )
    self:DataChange(InObj.Data.Flow)
    BtnAddEvent(self.BtnTask, self.OnClickItem)
    TaskCommon.AddHandle(self.NodeChangedHandle)

    --[[if self.NodeChangedAnimHandle then
        EventSystem.Remove(self.NodeChangedAnimHandle)
    end
    self.NodeChangedAnimHandle = EventSystem.On(Event.FightTip,function ( tbMsg )
        --{Type = 1, Msg = DesWithoutRich}
        if tbMsg and tbMsg.Type == 1 then
            if tbMsg.bShowUIAnim then
                self:PlayAnimation(self.task_refresh)
            else
                self:PlayAnimation(self.task_refreshsmall)
            end
        end
    end)
    TaskCommon.AddHandle(self.NodeChangedHandle)
    TaskCommon.AddHandle(self.NodeChangedAnimHandle)]]
    --self:PlayAnimation(self.task_refresh)
end

function LevelTaskItem:OnClickItem()
end

function LevelTaskItem:DataChange(Flow)
    if not Flow or not Flow.GetUIDescription then
        return
    end
    if IsValid(self.Title) and IsValid(Flow) then
        self.Title:SetText(Flow:GetUIDescription())
    end

    if IsValid(self.ItemList) and IsValid(Flow) then
        self:DoClearListItems(self.ItemList)
        self.ItemList:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
        local AllExecuteNodes = self:GetAllExeceteNodes()
        if AllExecuteNodes == nil then
            return
        end
        local bShowUIAnim = 0;

        if not self.Factory then
            self.Factory = Model.Use(self)
        end

        for i = 1,AllExecuteNodes:Length() do
            if self.Factory then
                local one = AllExecuteNodes:Get(i)
                if one and not one.bHiddenExectue then
                    if one and one.showUIAnimType > bShowUIAnim then
                        bShowUIAnim = one.showUIAnimType;
                    end
                end
            end
        end
        for i = 1,AllExecuteNodes:Length() do
            if self.Factory then
                local one = AllExecuteNodes:Get(i)
                if one and not one.bHiddenExectue then
                    local NewItem = self.Factory:Create({Execute = one,ShowUIAnim = bShowUIAnim})
                    self.ItemList:AddItem(NewItem)
                end
            end
        end
    end
end

function LevelTaskItem:GetAllExeceteNodes()
    if IsValid(self.GameTask) and self.GameTask.GetAllInProgressExecuteNodes then
        return self.GameTask:GetAllInProgressExecuteNodes()
    end
end

function LevelTaskItem:OnDestruct()
    print("LevelTaskItem OnDestruct()")
    EventSystem.Remove(self.NodeChangedHandle)
    --EventSystem.Remove(self.NodeChangedAnimHandle)
    BtnRemoveEvent(self.BtnTask, self.OnClickItem)
end

return LevelTaskItem
