-- ========================================================
-- @Brief   : 关卡星级进度提示
-- ========================================================
local tbClass = Class("UMG.SubWidget");

---打开界面
function tbClass:Construct()
    self.tbList = {}
end

function tbClass:OnDestruct()
end

function tbClass:LevelStarUpdate(taskStar)
    -- 如果是同一星级条件直接更新不加入队列
    if self.Playing and self.CurTask and taskStar.Description == self.CurTask.Description then
        self.CurTask = {Description = taskStar.Description, CurrentState = taskStar.CurrentState, Progress = taskStar.Progress, bAchieveFailed = taskStar.bAchieveFailed}
        self:PlayTip()
        return
    end

    -- 这里的taskStar拿着就得取数据不然就等着崩吧
    table.insert(self.tbList, {Description = taskStar.Description, CurrentState = taskStar.CurrentState, Progress = taskStar.Progress, bAchieveFailed = taskStar.bAchieveFailed})
    if not self.Playing then
        self:TryPlay()
    end
end

function tbClass:OnListItemObjectSet(InObj)
    if InObj == nil then
        return
    end

    self.InObj = InObj

    local IsTower = Launch.GetType() == LaunchType.TOWER

    InObj.Data.Refresh = function (tbParam)
        self:Refresh(tbParam)
        if tbParam.bPlayAnim and not IsTower then
            self:PlayAnimation(self.Appear)
        end
    end

    self:Refresh(InObj.Data)
    if not IsTower then
        self:PlayAnimation(self.Appear)
    end
end

function tbClass:Refresh(tbParam)
    WidgetUtils.Collapsed(self.PanelNormal)
    WidgetUtils.Collapsed(self.PanelSuccess)
    WidgetUtils.Collapsed(self.PanelFail)
    WidgetUtils.Collapsed(self.PanelProgress)

    if tbParam.Progress >= 100 or tbParam.bFinished or tbParam.bAchieveFailed then
        if tbParam.bAchieveFailed and tbParam.Progress >= 100 and not tbParam.bHasFinished then
            WidgetUtils.SelfHitTestInvisible(self.PanelFail)
        else
            WidgetUtils.SelfHitTestInvisible(self.PanelSuccess)
        end

        if tbParam.Progress >= 100 or tbParam.bHasFinished then
            WidgetUtils.Collapsed(self.TxtTarget)
        else
            WidgetUtils.SelfHitTestInvisible(self.TxtTarget)
        end
    elseif tbParam.Progress >= 50 then
        WidgetUtils.SelfHitTestInvisible(self.PanelProgress)
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelNormal)
    end
    
    self.Des:SetText(tbParam.Description)
    self.TxtTarget:SetText(tbParam.CurrentState)
end

function tbClass:TryPlay()
    if self.InObj then return end

    WidgetUtils.Collapsed(self.PanelNormal)
    WidgetUtils.Collapsed(self.PanelSuccess)
    WidgetUtils.Collapsed(self.PanelFail)
    WidgetUtils.Collapsed(self.PanelProgress)

    if self.CurTask then 
        table.remove(self.tbList, 1)
        self.CurTask = nil
    end

    if #self.tbList == 0 then
        self.Playing = false
        WidgetUtils.Collapsed(self)
        return
    else
        WidgetUtils.SelfHitTestInvisible(self)
    end

    local fightUI = UI.GetUI("Fight")
    if not fightUI or not WidgetUtils.IsVisible(fightUI) then
        return
    end

    self.Playing = true;

    self.CurTask = self.tbList[1]

    self:PlayTip()
end

function tbClass:PlayTip()
    self:PlayAnimation(self.Appear)
    if self.CurTask.Progress == 100 or (self.CurTask.Progress == 0 and self.CurTask.bAchieveFailed) then
        if self.CurTask.bAchieveFailed and self.CurTask.Progress == 100 then
            WidgetUtils.SelfHitTestInvisible(self.PanelFail)
        else
            WidgetUtils.SelfHitTestInvisible(self.PanelSuccess)
        end
        
        -- 非常驻任务面板提示性更新状态
        if Launch.GetType() ~= LaunchType.TOWER then
            EventSystem.Trigger(Event.OnStarTaskChange, false, true, false)
        end
    elseif self.CurTask.Progress >= 50 then
        WidgetUtils.SelfHitTestInvisible(self.PanelProgress)
    else
        WidgetUtils.SelfHitTestInvisible(self.PanelNormal)
    end
    
    self.Des:SetText(self.CurTask.Description)
    self.TxtTarget:SetText(self.CurTask.CurrentState)
end

function tbClass:OnAnimationFinished(Anim)
    self:TryPlay()
end

return tbClass;