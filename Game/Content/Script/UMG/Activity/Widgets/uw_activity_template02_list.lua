-- ========================================================
-- @File    : uw_activity_template02_list.lua
-- @Brief   : 活动Task 单个任务显示
-- ========================================================

local tbTask=Class("UMG.SubWidget")

function tbTask:Construct()
    self.pTaskItem = Model.Use(self)
end

function tbTask:OnListItemObjectSet(pObj)
    local tbParam = pObj.Data
    self:ShowMain(tbParam)
end

function tbTask:ShowMain(tbParam)
    local tbQuest = tbParam.tbQuestInfo
    --任务名字
    self.TxtMask:SetText(Achievement.GeDescribe(tbQuest))
    --描述
    --self.TaskTxt:SetText(Achievement.GeDescribe(tbQuest))
    WidgetUtils.Collapsed(self.TaskTxt)
    --进度
    local nSub,nDen = Achievement.GetProgresAndSum(tbQuest, true)
    self.TxtPlayerNum:SetText(nSub..'/'..nDen)
    self.BarTitle:SetPercent(nSub / nDen)

    --显示按钮
    local bGet = self:ShowBtn(tbQuest, tbParam)
    --显示奖励
    self:ShowTaskItem(tbQuest.tbRewards, bGet)

    --显示标签
    self:ShowFlag(tbParam.nShowType)

    --显示锁定标签
    self:ShowLock(tbParam.nLockDay)
end

--显示任务标签
function tbTask:ShowFlag(nShowType)
    if nShowType == 1 then
        WidgetUtils.SelfHitTestInvisible(self.Day)
        WidgetUtils.Collapsed(self.Common)
        WidgetUtils.Collapsed(self.Week)
    elseif nShowType == 2 then
        WidgetUtils.SelfHitTestInvisible(self.Week)
        WidgetUtils.Collapsed(self.Common)
        WidgetUtils.Collapsed(self.Day)
    elseif nShowType == 3 then
        WidgetUtils.SelfHitTestInvisible(self.Common)
        WidgetUtils.Collapsed(self.Day)
        WidgetUtils.Collapsed(self.Week)
    else
        WidgetUtils.Collapsed(self.Common)
        WidgetUtils.Collapsed(self.Day)
        WidgetUtils.Collapsed(self.Week)
    end
end

function tbTask:ShowTaskItem(tbRewards, bGet)
   self.PanelItem:ClearChildren()
    if not tbRewards then
        return
    end

    for index, value in ipairs(tbRewards) do
        local widget = LoadWidget("/Game/UI/UMG/Widgets/uw_widgets_item_list.uw_widgets_item_list_C")
        local tbParam = {
            G = value[1],
            D = value[2],
            P = value[3],
            L = value[4],
            N = value[5],
            bGeted = bGet,
        }
        local pItem=self.pTaskItem:Create(tbParam)
        self.PanelItem:AddChildToWrapBox(widget)
        widget:Display(tbParam)
    end
end

function tbTask:ShowBtn(tbQuest, tbParam)
    if not tbQuest then return end

    local nRet = Achievement.CheckAchievementReward(tbQuest)
    if nRet == Achievement.STATUS_GOT then
        WidgetUtils.Collapsed(self.BtnJump)
        WidgetUtils.Collapsed(self.BtnGet)

        WidgetUtils.SelfHitTestInvisible(self.PanelReceived)
        return true
    elseif nRet == Achievement.STATUS_CAN then
        WidgetUtils.Collapsed(self.BtnJump)
        WidgetUtils.Collapsed(self.PanelReceived)

        WidgetUtils.Visible(self.BtnGet)
        self.BtnGet.OnClicked:Clear()
        self.BtnGet.OnClicked:Add(
            self,
            function()
                Activity.Quest_GetAward(
                    {
                        nId = tbParam.nActivityId,
                        nQuestId = tbParam.tbQuestInfo.nId,
                    })
            end
        )
    else
        WidgetUtils.Collapsed(self.BtnGet)
        WidgetUtils.Collapsed(self.PanelReceived)

        WidgetUtils.Visible(self.BtnJump)
        self.BtnJump.OnClicked:Clear()
        self.BtnJump.OnClicked:Add(
            self,
            function()
                Achievement.GoToUI(tbParam.tbQuestInfo)
            end
        )
    end
end

function tbTask:ShowLock(nLockDay)
    if not nLockDay or nLockDay <= 0 then 
        WidgetUtils.Collapsed(self.Locked)
    else
        WidgetUtils.SelfHitTestInvisible(self.Locked)
        self.TxtLock:SetText(string.format(Text("ui.TxtDayUnlock"), nLockDay))
    end
end

return tbTask