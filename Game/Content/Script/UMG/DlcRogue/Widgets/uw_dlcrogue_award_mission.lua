-- ========================================================
-- @File    : uw_dlcrogue_award_mission.lua
-- @Brief   :肉鸽任务条目
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = self.Factory or Model.Use(self)

    BtnAddEvent(self.ButtonGo, function()
        if self.cfg then
            Achievement.GoToUI(self.cfg)
        end
    end)
    BtnAddEvent(self.ButtonOver, function()
        if self.cfg then
            RogueLogic.QuickGetReward({self.cfg.nId}, function ()
                local ui = UI.GetUI("DlcRogueAward")
                if ui and ui:IsOpen() then
                    ui:UpdateAwardList()
                end
            end)
        end
    end)
end

function tbClass:OnListItemObjectSet(pObj)
	local cfg = pObj and pObj.Data
	if not cfg then return end
    self.cfg = cfg
	self.Txtname:SetText(Text(cfg.sName, cfg.nCheckValue))
    self.TxtDetail:SetText(Text(cfg.sDescribe, cfg.nCheckValue))

    self:DoClearListItems(self.ListProps)
    for _, reward in ipairs(cfg.tbRewards) do
    	if type(reward) == 'table' then
    		local obj = self.Factory:Create({G = reward[1],D = reward[2],P = reward[3],L = reward[4],N = reward[5]})
    		self.ListProps:AddItem(obj)
    	end
    end
    self:UpdateState()
    self:UpdateTime()
end

function tbClass:UpdateState()
    if not self.cfg then
        return
    end
    local cur, sum = Achievement.GetProgresAndSum(self.cfg)
    local state = Achievement.CheckAchievementReward(self.cfg)

    self.ProgressBar:SetPercent(cur / sum)
    self.TxtFinish:SetText(cur)
    self.TxtSum:SetText(sum)

    if state == 0 then
        WidgetUtils.Hidden(self.PanelReceive)
        WidgetUtils.Visible(self.PanelMission)
        WidgetUtils.Collapsed(self.ImgBGOver)
        WidgetUtils.Collapsed(self.PanelOver)
        WidgetUtils.SelfHitTestInvisible(self.ImgBG)

        if self.cfg.sGotoUI or self.cfg.sConditionGoto then
            WidgetUtils.Visible(self.ButtonGo)
        else
            WidgetUtils.Collapsed(self.ButtonGo)
        end
        self.ListProps:SetRenderOpacity(1)
    elseif state == 1 then
        WidgetUtils.Hidden(self.PanelMission)
        WidgetUtils.Visible(self.PanelReceive)
        WidgetUtils.SelfHitTestInvisible(self.ImgBG)
        WidgetUtils.Collapsed(self.ImgBGOver)
        WidgetUtils.Collapsed(self.PanelOver)
        self.ListProps:SetRenderOpacity(1)
    elseif state == 2 then
        WidgetUtils.Hidden(self.PanelMission)
        WidgetUtils.Hidden(self.PanelReceive)
        WidgetUtils.SelfHitTestInvisible(self.ImgBGOver)
        WidgetUtils.SelfHitTestInvisible(self.PanelOver)
        WidgetUtils.Collapsed(self.ImgBG)
        self.ListProps:SetRenderOpacity(0.4)
    end
end

function tbClass:UpdateTime()
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
    end
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.detime then self.detime = 0 end
    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end
    self.detime = 0

    self:UpdateTime()
end

return tbClass