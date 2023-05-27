-- ========================================================
-- @File    : umg_activitycharge.lua
-- @Brief   : 首充界面  弹窗和活动 子窗口用同一个脚本
-- ========================================================
local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
end

--活动内显示
--打脸图规则 弹出
function tbClass:OnOpen(tbParam)
    self.nActivityId = tbParam and tbParam.nActivityId or self.nActivityId
    self.ListReward:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)

    if self.BtnClose then --弹窗
        local tbConfig = Activityface.GetConfig(self.nActivityId)
        if not tbConfig or not IsInTime(tbConfig.tStarttime, tbConfig.tEndtime) then
            UI.Close(self)
            return
        end

        --弹窗用打脸图 配置
        if self.ImgAD and tbConfig.sBg then
            SetTexture(self.ImgAD, tbConfig.sBg)
        end

        self:InitPopBtn()
    else
        self:InitBtn()
    end

    self:ShowMain()
end

function tbClass:OnClose()
end

--初始化按钮事件
function tbClass:InitBtn()
    if not self.BtnGo then return end

    BtnClearEvent(self.BtnGo)
    BtnAddEvent(
        self.BtnGo, 
        function()
            local tbConfig = Activity.GetActivityConfig(self.nActivityId)
            if tbConfig and tbConfig.sGotoUI then
                UI.Open(tbConfig.sGotoUI, table.unpack(tbConfig.tbUIParam))
            end
        end
    )
end

--初始化弹窗按钮事件
function tbClass:InitPopBtn()
    if not self.BtnClose then return end

    BtnClearEvent(self.BtnClose)
    BtnAddEvent(
        self.BtnClose, 
        function()
            local nNextId = Activityface.GetNextFaceId(self.nActivityId)
            Activityface.UpDataCallBack(nNextId)
            UI.CloseByName("ActivityCharge")
        end
    )

    BtnClearEvent(self.BtnAD)
    BtnAddEvent(
        self.BtnAD, 
        function()
            local tbConfig = Activity.GetActivityConfig(self.nActivityId)
            if tbConfig and tbConfig.sGotoUI then
                UI.Open(tbConfig.sGotoUI, table.unpack(tbConfig.tbUIParam))
                UI.CloseByName("ActivityCharge")
            end
        end
    )

    BtnClearEvent(self.BtnSelect)
    BtnAddEvent(
        self.BtnSelect, 
        function()
            local tbConfig = Activity.GetActivityConfig(self.nActivityId)
            if tbConfig and tbConfig.sGotoUI then
                UI.Open(tbConfig.sGotoUI, table.unpack(tbConfig.tbUIParam))
            end
        end
    )
end

--显示当前界面
function tbClass:ShowMain()
    local tbConfig = Activity.GetActivityConfig(self.nActivityId)
    if not tbConfig then
        return
    end

    if self.ImgTitle and tbConfig.nTitle then
        SetTexture(self.ImgTitle, tbConfig.nTitle)
    end

    self:ShowAward(tbConfig.tbCustomData)
    self:DoGetAward()
    self:SetDes(tbConfig)
    self:ShowRightInfo(tbConfig.tbCustomData)
    self:ShowCheckFlag(self.nActivityId)
end

function tbClass:ShowAward(tbRewards)
    local bGet =  (Activity.GetDiyData(self.nActivityId, 1) > 0)
    if bGet then
        WidgetUtils.Collapsed(self.BtnGo)
    end

    if not self.Factory then
        self.Factory = Model.Use(self)
    end

    self:DoClearListItems(self.ListReward)
    if tbRewards and #tbRewards > 0 then
        for _, item in ipairs(tbRewards) do
            local cfg = {G = item[1], D = item[2], P = item[3], L = item[4], N = item[5], bGeted = bGet}
            local pObj = self.Factory:Create(cfg)
            self.ListReward:AddItem(pObj)
        end
    end
end

function tbClass:DoGetAward()
    if me:Charged() <= 0 or Activity.GetDiyData(self.nActivityId, 1) > 0 then
        return
    end

    local cmd = {nId = self.nActivityId, }
    Activity.Quest_GetAward(cmd, true)
end

--- 当前模板活动介绍
function tbClass:SetDes(tbConfig)
    if not tbConfig then return end
    if not self.TxtDesc then return end

    local nTypeID = type(tbConfig.tbDes)
    if nTypeID == "table" and #tbConfig.tbDes > 0 then
        WidgetUtils.SelfHitTestInvisible(self.TxtDesc)
        self.TxtDesc:SetContent(Text(tbConfig.tbDes[1]))
    elseif nTypeID == "string" then
        WidgetUtils.SelfHitTestInvisible(self.TxtDesc)
        self.TxtDesc:SetContent(Text(tbConfig.tbDes))
    else
        WidgetUtils.Collapsed(self.TxtDesc)
        self.TxtDesc:SetContent("")
    end
end

--显示右下角 信息
function tbClass:ShowRightInfo(tbRewards)
    if not tbRewards then 
        WidgetUtils.Collapsed(self.PanelPoseName)
        return
    end

    if #tbRewards == 0 then 
        WidgetUtils.Collapsed(self.PanelPoseName)
        return 
    end

    local tbItem,tbGDPL = nil
    for _, item in ipairs(tbRewards) do
        if item[1] == Item.TYPE_CARD or item[1] == Item.TYPE_CARD_SKIN then
            local infoItem = UE4.UItem.FindTemplate(item[1], item[2], item[3], item[4])
            if infoItem then
                tbItem =  infoItem
                tbGDPL = item
                break
            end
        end
    end

    if not tbItem or not tbGDPL then
        WidgetUtils.Collapsed(self.PanelPoseName)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.PanelPoseName)

    local sNameStr = Text(tbItem.I18N)
    if tbGDPL[1] == Item.TYPE_CARD_SKIN then
        WidgetUtils.SelfHitTestInvisible(self.Skin)
        WidgetUtils.Collapsed(self.Card)
        local CardInfo = UE4.UItem.FindTemplate(1, tbGDPL[2], tbGDPL[3], 1)
        if CardInfo  then
            sNameStr = string.format("%s·%s", Text(CardInfo.I18N .. "_suits"), Text(tbItem.I18N))
        end
    else
        WidgetUtils.Collapsed(self.Skin)
        WidgetUtils.SelfHitTestInvisible(self.Card)
        self.Quality:Set(tbItem.Color)
    end

    self.PoseName:SetText(sNameStr)
end

-- 显示勾选
function tbClass:ShowCheckFlag()
    local tbConfig = Activityface.GetConfig(self.nActivityId)
    if not tbConfig or tbConfig.nPopFlag == 0 then
        WidgetUtils.Collapsed(self.Tip)
        return
    end

    WidgetUtils.SelfHitTestInvisible(self.Tip)

    local nFlag = Activityface.GetPopFlag(self.nActivityId)
    if nFlag == 0 then
        WidgetUtils.Collapsed(self.Check)
        return
    end

    local nDateTime = Activityface.GetPopTime(self.nActivityId)
    local nDissDay = Activityface.CheckTimeDay(nDateTime, GetTime())
    if nDissDay < Activityface.nShowDay then
        WidgetUtils.SelfHitTestInvisible(self.Check)
        return
    end

    WidgetUtils.Collapsed(self.Check)
end

--勾选
function tbClass:DoCheck()
    if not self.nActivityId then return end

    if WidgetUtils.IsVisible(self.Check) then
        WidgetUtils.Collapsed(self.Check)
        Activityface.SetPopFlag(self.nActivityId, false)
    else
        WidgetUtils.SelfHitTestInvisible(self.Check)
        Activityface.SetPopFlag(self.nActivityId, true)
    end
end

return tbClass