local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
	self.Factory = Model.Use(self)
	local tbParam = pObj and pObj.Data
	if not tbParam then
		return
	end
    local achievementId = tbParam.achieveId
    local actId = tbParam.actId;
    local dayId = tbParam.dayId;
    if not achievementId or not actId then
        return
    end
	local cfg = Achievement.GetQuestConfig(achievementId);

	if not cfg then
		return
	end
	self.cfg = cfg;
	self.Txtname:SetText(Text(cfg.sName))
    self.TxtDetail:SetText(Achievement.GeDescribe(cfg))

    self:DoClearListItems(self.ListProps)
    for i,reward in ipairs(cfg.tbRewards) do
    	if type(reward) == 'table' then
    		local obj = self.Factory:Create({G = reward[1],D = reward[2],P = reward[3],L = reward[4],N = reward[5]})
    		self.ListProps:AddItem(obj)
    	end
    end
    self:UpdateState(achievementId,actId,dayId)
end

function tbClass:UpdateState(achievementId,actId,dayId)
	local nId = achievementId
    local state = Achievement.CheckAchievementReward(nId,true)

    BtnClearEvent(self.ButtonGo)
    BtnClearEvent(self.ButtonOver)

    local now, num = Achievement.GetProgresAndSum(nId,true)
        self.ProgressBar_13:SetPercent(now / num)
        self.TxtFinish:SetText(now)
        self.TxtSum:SetText(num)

    if state == 0 then
        WidgetUtils.Hidden(self.PanelReceive)
        WidgetUtils.Hidden(self.PanelNo)
        WidgetUtils.Visible(self.PanelMission)
        WidgetUtils.SelfHitTestInvisible(self.ImgBG)
        WidgetUtils.Collapsed(self.ImgBGOver)
        WidgetUtils.Collapsed(self.PanelOver)

        BtnAddEvent(self.ButtonGo, function()
	        Achievement.GoToUI(self.cfg,true)
	    end)

        --[[if self.cfg.sGotoUI or self.cfg.sConditionGoto then
            WidgetUtils.HitTestInvisible(self.TxtGo)
        else
            WidgetUtils.Collapsed(self.TxtGo)
        end]]
        Color.SetTextColor(self.Txtname, '000000FF')
        Color.SetTextColor(self.TxtDetail, '000000FF')
        Color.SetTextColor(self.TxtFinish, '000000FF')
        Color.SetTextColor(self.TxtSlash, '000000FF')
        Color.SetTextColor(self.TxtSum, '000000FF')
        self.ListProps:SetRenderOpacity(1)
    elseif state == 1 then
        WidgetUtils.Hidden(self.PanelMission)
        WidgetUtils.Hidden(self.PanelNo)
        WidgetUtils.Visible(self.PanelReceive)
        WidgetUtils.SelfHitTestInvisible(self.ImgBG)
        WidgetUtils.Collapsed(self.ImgBGOver)
        WidgetUtils.Collapsed(self.PanelOver)

        BtnAddEvent(self.ButtonOver, function()
	        if not nId then return end
            SevenDay:GetAcheveimentAward(actId,dayId,nId)
	        --Activity.Quest_GetAward({nId = actId,nQuestId = nId})
	    end)

        Color.SetTextColor(self.Txtname, '000000FF')
        Color.SetTextColor(self.TxtDetail, '000000FF')
        Color.SetTextColor(self.TxtFinish, '000000FF')
        Color.SetTextColor(self.TxtSlash, '000000FF')
        Color.SetTextColor(self.TxtSum, '000000FF')
        self.ListProps:SetRenderOpacity(1)
    elseif state == 2 then
        WidgetUtils.Hidden(self.PanelMission)
        WidgetUtils.Hidden(self.PanelReceive)
        WidgetUtils.Visible(self.PanelNo)
        WidgetUtils.SelfHitTestInvisible(self.ImgBGOver)
        WidgetUtils.SelfHitTestInvisible(self.PanelOver)
        WidgetUtils.Collapsed(self.ImgBG)

        Color.SetTextColor(self.Txtname, 'FFFFFF66')
        Color.SetTextColor(self.TxtDetail, 'FFFFFF66')
        Color.SetTextColor(self.TxtFinish, 'FFFFFF66')
        Color.SetTextColor(self.TxtSlash, 'FFFFFF66')
        Color.SetTextColor(self.TxtSum, 'FFFFFF66')

        self.ListProps:SetRenderOpacity(0.4)
    end
end

return tbClass