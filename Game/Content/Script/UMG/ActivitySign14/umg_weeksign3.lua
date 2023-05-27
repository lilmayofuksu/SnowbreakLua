-- ========================================================
-- @File    : umg_activitysign_new14.lua
-- @Brief   : 短签活动界面   模板(uw_activity_template05)
-- ======================================================== 

local tbShortSign = Class("UMG.BaseWidget")
tbShortSign.tbTypeIcon = 
{
    --武器
    {1400004, 1400001, 1400003, 1400002, 1400000},
    --皮肤
    {1400210}
}

function tbShortSign:Construct()
    self.nPage = 1
    WidgetUtils.SelfHitTestInvisible(self.BtnClose)
    BtnAddEvent(
        self.BtnClose, 
        function() 
            UI.CloseByName("WeekSign3")
            Activity.OnOpen()
        end
    )

    BtnAddEvent(
        self.BtnSwitch, 
        function() 
            if self.nPage == 1 then
                self.nPage = 2
            else
                self.nPage = 1
            end
            self:OnOpen()
        end
    )

    if self.Info then
        self.Info:SetBtnListener(function() 
            local tbActivityCfg = Activity.GetActivityConfig(self.nActivityId)
            if tbActivityCfg and #tbActivityCfg.tbDes > 0 then
                UI.Open("Info", tbActivityCfg.tbDes[1])
            end
        end)
    end
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
            self:AddItem(tbData,InParam.ItemId)
            UI.Open('GainItem',tbData[InParam.ItemId].tbpData)
            WidgetUtils.Visible(self.BtnClose)
        end
    )
end

function tbShortSign:GetSpecItem()
    local tbData = Sign.GetShortSignConfig(self.nActivityId)
    local nIndex = 7
    if self.nPage == 1 then
        nIndex = 7
    elseif tbData[14] then
        nIndex = 14
    end

    return tbData[nIndex].tbpData[1], tbData[nIndex].param1, tbData[nIndex].sTips
end

function tbShortSign:OnOpen(tbParam)
    if tbParam then
        self.nActivityId = tbParam.nActivityId
        local tbData = Sign.GetShortSignConfig(self.nActivityId)
        if not tbData then return end
        self.nPage = 1
        if Sign.GetSginTag(self.nActivityId) >= 7 and tbData[14] then
            self.nPage = 2
        end
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
    self:CheckShortSign(tbConfig)
    self:SetTemplateContent(tbConfig)
    --self:ShowItemTips()

    if self.animation_switching then
        self:PlayAnimationForward(self.animation_switching)
    end
end

--- 短签任务条目
function tbShortSign:AddItem(tbData, Id)
    local pItemTask = Model.Use(self)
    local nIndex = 1
    for key, value in ipairs(tbData) do
        if #tbData <= 7 or ((self.nPage == 1 and key <= 7) or (self.nPage == 2 and key > 7)) then
            local tbItem={
                nActivityId     = self.nActivityId,
                nDayId       = value.nDayId,
                tbReward    = value.tbpData,
                bFinished   = Sign.GetSginTag(self.nActivityId) >= value.nDayId, --是否领取,
                Special     = value.nSpe,
                Color       = value.sCol,
                Tips        = value.sTips,
                bChannel     = Id == value.nDayId,
                icon        = value.param2,
                bNext        = Sign.GetSginTag(self.nActivityId) + 1 == value.nDayId
            }
            
            local NewTask = pItemTask:Create(tbItem)
            local pWidget = self['Day'..nIndex]
            if pWidget then
                pWidget:Init(NewTask)
            end

            nIndex = nIndex + 1
        end
    end
end

--- 活动时间
function tbShortSign:CheckShortSign(tbConfig)
    if not tbConfig then return end

    if self.PanelTime then
        if tbConfig.nEndTime > 0 then
            WidgetUtils.SelfHitTestInvisible(self.PanelTime)
            self.PanelTime:ShowNormal(tbConfig.nEndTime)
            WidgetUtils.Collapsed(self.PanelTime.ImgBg)
        else
            WidgetUtils.Collapsed(self.PanelTime)
        end
    end

    if self.Oversea then
        if Login.IsOversea() and tbConfig.nEndTime > 0 then
            WidgetUtils.SelfHitTestInvisible(self.Oversea)
        else
            WidgetUtils.Collapsed(self.Oversea)
        end
    end
end

--- 模板内容设置
function tbShortSign:SetTemplateContent(tbConfig)
    local TitleId = tbConfig.nTitle
    if self.ImgTitle and TitleId > 0 then
        SetTexture(self.ImgTitle, Resource.Get(TitleId), false)
    end

    local BgId = tbConfig.nBg
    if self.ImgBG and BgId > 0 then
        SetTexture(self.ImgBG,Resource.Get(BgId),false)
    end

    local ImgPicId = tbConfig.nImgPic
    if self.ImgPic and ImgPicId > 0 then
        SetTexture(self.ImgPic,Resource.Get(ImgPicId),false)
    end

    if self.SignInfo then
        if tbConfig.tbDes and #tbConfig.tbDes > 0 then
            self.ContInfo:SetContent(Text(tbConfig.tbDes[1]))
            WidgetUtils.Visible(self.SignInfo)
        else
            WidgetUtils.Collapsed(self.SignInfo)
        end
    end

    local tbData = Sign.GetShortSignConfig(self.nActivityId)
    if #tbData > 7 then
        WidgetUtils.Visible(self.Tab)
        if self.nPage == 1 then
            WidgetUtils.Visible(self.Checked)
            WidgetUtils.Collapsed(self.Unchecked)
        else
            WidgetUtils.Collapsed(self.Checked)
            WidgetUtils.Visible(self.Unchecked)
        end
    else
        WidgetUtils.Collapsed(self.Tab)
    end

    local tbItem, Icon, sTips = self:GetSpecItem()
    if not tbItem then
        return
    end

    local pTemplate = UE4.UItem.FindTemplate(tbItem[1], tbItem[2], tbItem[3], tbItem[4])

    if Icon and Icon > 0 then
        AsynSetTexture(self.Pose, Icon)
    end

    if sTips then
        self.PoseName:SetText(Text(sTips))
    else
        self.PoseName:SetText(Text(pTemplate.I18N))
    end


    WidgetUtils.Visible(self.PanelPoseName)
    if tbItem[1] == Item.TYPE_CARD then
        WidgetUtils.Collapsed(self.Skin)
        WidgetUtils.SelfHitTestInvisible(self.Card)
        self.Quality:Set(pTemplate.Color)
        local pItem = me:GetDefaultItem(table.unpack(tbItem))
        if pItem then
            local tbWeapon = pItem:DefaultWeaponGPDL()
            SetTexture(self.ImgType0, self.tbTypeIcon[1][tbWeapon.Detail])
        end
    elseif tbItem[1] == Item.TYPE_CARD_SKIN then
        WidgetUtils.Collapsed(self.Card)
        WidgetUtils.SelfHitTestInvisible(self.Skin)
        SetTexture(self.ImgType, self.tbTypeIcon[2][1])
    else
        WidgetUtils.Collapsed(self.PanelPoseName)
    end
end

return tbShortSign
