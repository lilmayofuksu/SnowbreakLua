-- ========================================================
-- @File    : umg_dlc1_award.lua
-- @Brief   : dlc1任务界面
-- ========================================================

local tbClass = Class('UMG.BaseWidget')

function tbClass:OnInit()
    self.ListFactory = self.ListFactory or Model.Use(self)
    self:DoClearListItems(self.ListTask)
    self:DoClearListItems(self.ListTab)
    self.ListTask:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
    BtnAddEvent(self.BtnQuick, function() self:QuickGetReward() end)
    self.nGroupId = 1
    self.tbGroupWidget = {}
end

function tbClass:OnOpen(GroupId)
    self.tbConf = DLC_Logic.GetCurConf()
    if not self.tbConf then return end
    self:UpdateTime()
    self:UpdateAllPrecess()
    self:DoClearListItems(self.ListTab)
    self.nGroupId = GroupId or self.nGroupId
    for idx, groupId in ipairs(self.tbConf.tbMissionGroup) do
        local tbMissions = DLC_Logic.GetMissionGroup(groupId)
        if tbMissions and #tbMissions > 0 then
            local tb = {}
            tb.sName = tbMissions[1].sGroupDes
            tb.bSelect = groupId == self.nGroupId
            tb.pCall = function(InObj)
                if not self.SelectObj or self.SelectObj ~= InObj then
                    if self.SelectObj then self.SelectObj:UpdateState(false) end
                    InObj:UpdateState(true)
                    self.SelectObj = InObj
                    self:UpdateAwardGroup(groupId)
                    self:PlayAnimation(self.Enter)
                end
            end
            tb.pInitCall = function(InObj) self.tbGroupWidget[groupId] = InObj end
            self.ListTab:AddItem(self.ListFactory:Create(tb))
            if groupId == self.nGroupId then self:UpdateAwardGroup(groupId) end
        end
    end
    UE4.Timer.NextFrame(function() self:UpdateRed() end)
end

function tbClass:UpdateAwardGroup(nGroupId)
    self.nGroupId = nGroupId or self.nGroupId
    self:DoClearListItems(self.ListTask)
    local tbMissions = DLC_Logic.GetMissionGroup(self.nGroupId)
    local tbTopMission = nil
    local tbCanGet, tbNoComp, tbGot = {}, {}, {}
    if tbMissions and #tbMissions > 0 then
        for _, mission in ipairs(tbMissions) do
            if mission.nPriority == -1 then
                tbTopMission = mission
            else
                local state = AchievementDLC.CheckAchievementReward(mission)
                if state == 0 then
                    table.insert(tbNoComp, mission)
                elseif state == 1 then
                    table.insert(tbCanGet, mission)
                elseif state == 2 then
                    table.insert(tbGot, mission)
                end
            end
        end
    end
    for _, mission in ipairs(tbCanGet) do self.ListTask:AddItem(self.ListFactory:Create(mission)) end
    for _, mission in ipairs(tbNoComp) do self.ListTask:AddItem(self.ListFactory:Create(mission)) end
    for _, mission in ipairs(tbGot) do self.ListTask:AddItem(self.ListFactory:Create(mission)) end
    self.ListTask:ScrollToTop()

    local pSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ListTask)
    if tbTopMission then
        WidgetUtils.SelfHitTestInvisible(self.TopAward)
        local cur, sum = AchievementDLC.GetProgresAndSum(tbTopMission)
        local state = AchievementDLC.CheckAchievementReward(tbTopMission)
        self.MapNum:SetText(cur .. '/' .. sum)
        self.TxtCollect:SetText(Text(tbTopMission.sName))
        self.TxtDetail:SetText(Achievement.GeDescribe(tbTopMission))
        self.Tips:SetText(state == 0 and 'TxtChapterUnfinish' or 'TxtChapterFinish')

        if pSlot then
            local off = pSlot:GetOffsets()
            off.Top = 360
            off.Bottom = 630
            pSlot:SetOffsets(off)
        end
    else
        WidgetUtils.Collapsed(self.TopAward)

        if pSlot then
            local off = pSlot:GetOffsets()
            off.Top = 200
            off.Bottom = 850
            pSlot:SetOffsets(off)
        end
    end
end

function tbClass:UpdateTime()
    if not self then return end
    if self.TimerIdx then UE4.Timer.Cancel(self.TimerIdx); self.TimerIdx = nil end
    if not self.tbConf then return end
    local now = GetTime()
    if self.tbConf.nEndTime > now then
        local nDay, nHour, nMin, nSec = TimeDiff(self.tbConf.nEndTime, now)
        if nDay >= 1 then  --大于一天
            self.TxtTime:SetText(Text("ui.TxtDungeonsTowerTime1", nDay, nHour))
        elseif nHour >= 1 then   --大于一小时
            self.TxtTime:SetText(Text("ui.TxtDungeonsTowerTime2", nHour, nMin))
        elseif nMin >= 1 then  --分钟
            self.TxtTime:SetText(Text("ui.TxtDungeonsTowerTime3", nMin))
        else
            self.TxtTime:SetText(Text("ui.TxtDungeonsTowerTime5", nSec))
        end
    else
        self.TxtTime:SetText(Text("ui.TxtDLC1Over"))
        return
    end
    self.TimerIdx = UE4.Timer.Add(1, function() if self then self:UpdateTime() end end)
end

function tbClass:UpdateAllPrecess()
    local cur, sum = 0, 0
    self.tbCanGet = {}
    for _, groupId in ipairs(self.tbConf.tbMissionGroup) do
        local tbMissions = DLC_Logic.GetMissionGroup(groupId)
        if tbMissions then
            for _, mission in ipairs(tbMissions) do
                local state = AchievementDLC.CheckAchievementReward(mission)
                if state == 1 then table.insert(self.tbCanGet, mission.nId) end
                if state ~= 0 then cur = cur + 1 end
                sum = sum + 1
            end
        end
    end
    self.TextBlock:SetText(cur)
    self.TextBlock_355:SetText('/'..sum)
    self:UpdateRed()
end

function tbClass:QuickGetReward()
    self:UpdateAllPrecess()
    if self.tbCanGet and #self.tbCanGet > 0 then
        AchievementDLC.QuickGetReward(self.tbCanGet, function(tbParam)
            UI.Open('GainItem', tbParam.tbRewards)
            self:UpdateAllPrecess()
            self:UpdateAwardGroup(self.nGroupId)
        end)
    else
        UI.ShowMessage(Text('tip.reward_not_exist'))
    end
end

function tbClass:UpdateRed()
    for groupId, widget in pairs(self.tbGroupWidget) do
        WidgetUtils.Collapsed(widget.Red)
        local tbMissions = DLC_Logic.GetMissionGroup(groupId)
        if tbMissions and #tbMissions > 0 then
            for _, mission in ipairs(tbMissions) do
                if AchievementDLC.CheckAchievementReward(mission) == 1 then
                    WidgetUtils.SelfHitTestInvisible(widget.Red)
                    break
                end
            end
        end
    end
end

function tbClass:OnClose()
    if self.TimerIdx then
        UE4.Timer.Cancel(self.TimerIdx)
        self.TimerIdx = nil
    end
end

function tbClass:OnDisable()
    if self.TimerIdx then
        UE4.Timer.Cancel(self.TimerIdx)
        self.TimerIdx = nil
    end
end

return tbClass