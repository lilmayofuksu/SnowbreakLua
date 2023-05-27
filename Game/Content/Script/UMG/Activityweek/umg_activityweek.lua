-- ========================================================
-- @File    : umg_activityweek.lua
-- @Brief   : 短签活动界面   模板(uw_activity_template04)
-- ========================================================

local tbShortSign = Class("UMG.BaseWidget")
tbShortSign.TaskPath="Game/UI/UMG/Activityweek/Widgets/uw_activityweek_list.uw_activityweek_list_C"
tbShortSign.tbEvent = {}
tbShortSign.sis_event_cb = {}

function tbShortSign:Construct()
    WidgetUtils.SelfHitTestInvisible(self.BtnClose)
    self:DoClearListItems(self.ListDate)
    BtnAddEvent(
        self.BtnClose, 
        function() 
            UI.CloseByName("ShortSign")
            Activity.OnOpen()
        end
    )
end

function tbShortSign:AutoSign()
    local tbParam = {
        Id          = self.nActivityId,
        Type        = Sign.AWARD_TYPE_AMOUNT,
    }
    Sign.Req_ShortSign(
        tbParam,
        function(InParam)
            if not tbParam then return end

            local tbData = Sign.GetShortSignConfig(self.nActivityId)
            if not tbData then return end
            --print("AutoSign", self.nActivityId, RewardId, tbData)
            self:AddItem(tbData,InParam.ItemId)

            WidgetUtils.Collapsed(self.BtnClose)

            UE4.Timer.Add(2.2, function()
                if InParam.ItemId and tbData[InParam.ItemId] and tbData[InParam.ItemId].tbpData then
                    UI.Open('GainItem',tbData[InParam.ItemId].tbpData)
                end
                WidgetUtils.Visible(self.BtnClose)
            end)
        end
    )
end

function tbShortSign:OnOpen(tbParam)
    if tbParam and tbParam.nActivityId then
        self.nActivityId = tbParam.nActivityId
    end
    
    WidgetUtils.Visible(self.BtnClose)

    if Sign.GetSginDayStatus(self.nActivityId) < 2 then
        self:AutoSign()
    end

    local tbData = Sign.GetShortSignConfig(self.nActivityId)
    if not tbData then return end

    self:AddItem(tbData)
    --- 模板内容描述
    local tbConfig = Activity.GetActivityConfig(self.nActivityId)
    if not tbConfig then return end

    self:CheckShortSign(tbConfig)
    self:SetTemplateContent(tbConfig)
end

--- 短签任务条目
function tbShortSign:AddItem(tbData, Id)
    local pItemTask = Model.Use(self)
    self.ListDate:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    self:DoClearListItems(self.ListDate)

    local nScrolIdx = nil
    local nIdx = 0
    for key, value in pairs(tbData) do
        local tbParam={
            nActivityId     = self.nActivityId,
            nDayId       = value.nDayId,
            tbReward    = value.tbpData,
            bFinished   = Sign.GetSginTag(self.nActivityId) >= value.nDayId, --是否领取,
            Special     = value.nSpe,
            Color       = value.sCol,
            bChannel     = Id == value.nDayId
        }
        local  NewTask = pItemTask:Create(tbParam)
        self.ListDate:AddItem(NewTask)

        nIdx = nIdx + 1
        if tbParam.bFinished then
            nScrolIdx = nIdx
        end
    end

    if nScrolIdx  and nScrolIdx > 2 then
        if nScrolIdx > nIdx - 1 then
            nScrolIdx = nIdx - 1
        end
        self.ListDate:ScrollIndexIntoView(nScrolIdx)
    end
end

--- 活动时间
function tbShortSign:CheckShortSign(tbConfig)
    if not tbConfig then return end

    if self.PanelTime and tbConfig.nEndTime > 0 then
        WidgetUtils.SelfHitTestInvisible(self.PanelTime)
        self.PanelTime:ShowNormal(tbConfig.nEndTime)
    else
        WidgetUtils.Collapsed(self.PanelTime)
    end
end

--- 模板内容设置
function tbShortSign:SetTemplateContent(tbConfig)
    SetTexture(self.ImgTitle, tbConfig.nTitle,false)
    --SetTexture(self.ImgBG, tbConfig.nBg,false)
    SetTexture(self.ImgPic, tbConfig.nImgPic,false)

    if tbConfig.tbDes and #tbConfig.tbDes > 0 then
        self.ContDes:SetContent(Text(tbConfig.tbDes[1]))
    else
        self.ContDes:SetContent("")
    end
end

return tbShortSign
