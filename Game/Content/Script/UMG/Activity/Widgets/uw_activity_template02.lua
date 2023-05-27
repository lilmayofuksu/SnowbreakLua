-- ========================================================
-- @File    : uw_activity_template02.lua
-- @Brief   : 活动模板2  活动任务模板
-- ========================================================

local tbActiveContent2 = Class("UMG.BaseWidget")

function tbActiveContent2:Construct()
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.ListTask)
end

function tbActiveContent2:OnOpen(tbParam)
    self.nActivityId = tbParam.nActivityId
    self:ShowMain()
    self:ShowTasks()
end

--显示当前界面
function tbActiveContent2:ShowMain()
    local tbConfig = Activity.GetActivityConfig(self.nActivityId)
    if not tbConfig then
        return
    end

    SetTexture(self.ImgTitle, tbConfig.nTitle, false)
    --SetTexture(self.ImgBG, Resource.Get(tbConfig.nBg), false)
    SetTexture(self.ImgPic, tbConfig.nImgPic, false)

    --暂时隐藏
    WidgetUtils.Collapsed(self.BtnIntro)
    WidgetUtils.Collapsed(self.BtnClick)

    
    self:SetTimeDes(tbConfig)
    self:SetDes(tbConfig)
end

--- ScrollRow  
function tbActiveContent2:ShowTasks()
    self.ListTask:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    self:DoClearListItems(self.ListTask)

    local tbQuestList = Activity.GetQuestList(self.nActivityId)
    if not tbQuestList then return end
    
    for i, tbQuest in ipairs(tbQuestList) do
        local tbParam ={
            nActivityId = self.nActivityId,
            tbQuestInfo = tbQuest[2],
            nShowType = tbQuest[1],
            nLockDay = tbQuest[3] or 0,
        }
        local pObj = self.Factory:Create(tbParam)
        self.ListTask:AddItem(pObj)
    end

    self.ListTask:ScrollIndexIntoView(0)
end

-- 结束结束时间戳
function tbActiveContent2:SetTimeDes(tbConfig)
    if not tbConfig then
        return
    end

    if self.PanelTime and tbConfig.nEndTime > 0 then
        WidgetUtils.SelfHitTestInvisible(self.PanelTime)
        self.PanelTime:ShowNormal(tbConfig.nEndTime)
    else
        WidgetUtils.Collapsed(self.PanelTime)
    end
end

--- 当前模板活动介绍
function tbActiveContent2:SetDes(tbConfig)
    if not tbConfig then return end

    WidgetUtils.Collapsed(self.TxtIntro1)

    local nTypeID = type(tbConfig.tbDes)
    if nTypeID == "table" and #tbConfig.tbDes > 0 then
        WidgetUtils.SelfHitTestInvisible(self.TxtIntro2)
        self.TxtIntro2:SetContent(Text(tbConfig.tbDes[1]))
    elseif nTypeID == "string" then
        WidgetUtils.SelfHitTestInvisible(self.TxtIntro2)
        self.TxtIntro2:SetContent(Text(tbConfig.tbDes))
    else
        self.TxtIntro2:SetContent("")
    end
end

function tbActiveContent2:OnClose()
--    print("OnClose")
end

return tbActiveContent2
