-- ========================================================
-- @File    : uw_dlc1_award_mission.lua
-- @Brief   :dlc活动任务条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = self.Factory or Model.Use(self)
end

function tbClass:OnListItemObjectSet(pObj)
	local cfg = pObj and pObj.Data
	if not cfg then return end
    self.cfg = cfg
	self.Txtname:SetText(Text(cfg.sName))
    self.TxtDetail:SetText(Achievement.GeDescribe(cfg))

    self:DoClearListItems(self.ListProps)
    for i, reward in ipairs(cfg.tbRewards) do
    	if type(reward) == 'table' then
    		local obj = self.Factory:Create({G = reward[1],D = reward[2],P = reward[3],L = reward[4],N = reward[5]})
    		self.ListProps:AddItem(obj)
    	end
    end
    self:UpdateState(cfg)
    self:UpdateTime()
end

function tbClass:UpdateState(cfg)
    BtnClearEvent(self.ButtonGo)
    BtnClearEvent(self.ButtonOver)

    local cur, sum = AchievementDLC.GetProgresAndSum(cfg)
    local state = AchievementDLC.CheckAchievementReward(cfg)

    self.ProgressBar:SetPercent(cur / sum)
    self.TxtFinish:SetText(cur)
    self.TxtSum:SetText(sum)

    if state == 0 then
        WidgetUtils.Hidden(self.PanelReceive)
        WidgetUtils.Visible(self.PanelMission)
        WidgetUtils.Collapsed(self.ImgBGOver)
        WidgetUtils.Collapsed(self.PanelOver)
        WidgetUtils.SelfHitTestInvisible(self.ImgBG)

        if cfg.sGotoUI or cfg.sConditionGoto then
            WidgetUtils.Visible(self.ButtonGo)
            BtnAddEvent(self.ButtonGo, function() AchievementDLC.GoToUI(cfg) end)
        else
            WidgetUtils.Collapsed(self.ButtonGo)
        end

        Color.SetTextColor(self.Txtname, '000000FF')
        Color.SetTextColor(self.TxtDetail, '000000FF')
        Color.SetTextColor(self.TxtFinish, '000000FF')
        Color.SetTextColor(self.TxtSlash, '000000FF')
        Color.SetTextColor(self.TxtSum, '000000FF')
        self.ListProps:SetRenderOpacity(1)
    elseif state == 1 then
        WidgetUtils.Hidden(self.PanelMission)
        WidgetUtils.Visible(self.PanelReceive)
        WidgetUtils.SelfHitTestInvisible(self.ImgBG)
        WidgetUtils.Collapsed(self.ImgBGOver)
        WidgetUtils.Collapsed(self.PanelOver)

        BtnAddEvent(self.ButtonOver, function() AchievementDLC.GetReward(cfg.nId,
            function(tbParam)
                UI.Open('GainItem', tbParam.tbRewards)
                UI.Call2('Dlc1Award', 'UpdateAllPrecess')
                UI.Call2('Dlc1Award', 'UpdateAwardGroup')
            end)
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

function tbClass:UpdateTime()
    if not self then return end
    if self.TimerIdx then UE4.Timer.Cancel(self.TimerIdx); self.TimerIdx = nil end
    if not self.cfg then return end
    local now = GetTime()
    if self.cfg.nEndTime > now then
        local nDay, nHour, nMin, nSec = TimeDiff(self.cfg.nEndTime, now)
        if nDay >= 1 then  --大于一天
            self.Txtname_1:SetText(Text("ui.TxtDungeonsTowerTime1", nDay, nHour))
        elseif nHour >= 1 then   --大于一小时
            self.Txtname_1:SetText(Text("ui.TxtDungeonsTowerTime2", nHour, nMin))
        elseif nMin >= 1 then  --分钟
            self.Txtname_1:SetText(Text("ui.TxtDungeonsTowerTime3", nMin))
        else
            self.Txtname_1:SetText(Text("ui.TxtDungeonsTowerTime5", nSec))
        end
    else
        self.Txtname_1:SetText(Text("ui.TxtDLC1Over"))
        WidgetUtils.Collapsed(self.ButtonGo)
        return
    end
    self.TimerIdx = UE4.Timer.Add(1, function() if self then self:UpdateTime() end end)
end

function tbClass:OnDestruct()
    if self.TimerIdx then
        UE4.Timer.Cancel(self.TimerIdx)
        self.TimerIdx = nil
    end
end

return tbClass