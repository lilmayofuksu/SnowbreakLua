-- ========================================================
-- @File    : umg_dlcrogue_award.lua
-- @Brief   : 小肉鸽活动任务界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class('UMG.BaseWidget')

function tbClass:OnInit()
    self.ListFactory = Model.Use(self)
    self:DoClearListItems(self.ListTask)
    self:DoClearListItems(self.ListTab)
    BtnAddEvent(self.BtnQuick, function() self:QuickGetReward() end)
    self.nSelectIdx = 1

end

function tbClass:OnOpen()
    local _, cfg = RogueLogic.GetActivitieID()
    if not cfg then
        return
    end
    self.cfg = cfg
    -- local AllTask = {cfg.tbDailyTask, cfg.tbWeeklyTask}
    -- self:DoClearListItems(self.ListTab)
    -- for idx, tbTask in ipairs(AllTask) do
    --     local tb = {}
    --     tb.sName = idx
    --     tb.bSelect = idx == self.nSelectIdx
    --     tb.pCall = function(InObj)
    --         if self.SelectObj ~= InObj then
    --             if self.SelectObj then self.SelectObj:UpdateState(false) end
    --             InObj:UpdateState(true)
    --             self.SelectObj = InObj
    --             self:UpdateAwardGroup(tbTask)
    --             self:PlayAnimation(self.Enter)
    --         end
    --     end
    --     self.ListTab:AddItem(self.ListFactory:Create(tb))
    --     if idx == self.nSelectIdx then self:UpdateAwardGroup(tbTask) end
    -- end
    self.ListTask:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:UpdateAwardList()
    self:UpdateTime()
    me:CallGS("RogueLogic_SetDailyRefreshFlag")
end

function tbClass:UpdateAwardList()
    local tbTask = {}
    for _, ID in ipairs(self.cfg.TaskList) do
        local taskcfg = Achievement.GetQuestConfig(ID)
        if taskcfg then
            local bShow = true
            if taskcfg.nPreId then
                local PreCfg = Achievement.GetQuestConfig(taskcfg.nPreId)
                if PreCfg and Achievement.CheckAchievementReward(PreCfg) ~= Achievement.STATUS_GOT then
                    bShow = false
                end
            end
            if bShow then
                taskcfg.nEndTime = self.cfg.nEndTime
                table.insert(tbTask, taskcfg)
            end
        end
    end
    self:UpdateAwardGroup(tbTask)
end

function tbClass:UpdateAwardGroup(tbTask)
    self:DoClearListItems(self.ListTask)
    local tbCanGet, tbNoComp, tbGot = {}, {}, {}
    local fnum = 0
    self.tbCanGetID = {}
    for _, cfg in ipairs(tbTask) do
        local state = Achievement.CheckAchievementReward(cfg)
        if state == Achievement.STATUS_NOT then
            table.insert(tbNoComp, cfg)
        elseif state == Achievement.STATUS_CAN then
            table.insert(tbCanGet, cfg)
            table.insert(self.tbCanGetID, cfg.nId)
        elseif state == Achievement.STATUS_GOT then
            fnum = fnum + 1
            table.insert(tbGot, cfg)
        end
    end
    for _, cfg in ipairs(tbCanGet) do self.ListTask:AddItem(self.ListFactory:Create(cfg)) end
    for _, cfg in ipairs(tbNoComp) do self.ListTask:AddItem(self.ListFactory:Create(cfg)) end
    for _, cfg in ipairs(tbGot) do self.ListTask:AddItem(self.ListFactory:Create(cfg)) end
    self.TxtNum1:SetText(fnum)
    self.TxtNum2:SetText("/"..#tbTask)
end

function tbClass:UpdateTime()
    if not self or not self.cfg then return end
    local now = GetTime()
    if self.cfg.nEndTime > now then
        local nDay, nHour, nMin, nSec = TimeDiff(self.cfg.nEndTime, now)
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
    self.TimerIdx = UE4.Timer.Add(1, function() self:UpdateTime() end)
end

function tbClass:OnClose()
    if self.TimerIdx then
        UE4.Timer.Cancel(self.TimerIdx)
    end
end

function tbClass:QuickGetReward()
    if self.tbCanGetID and #self.tbCanGetID > 0 then
        RogueLogic.QuickGetReward(self.tbCanGetID, function ()
            self:UpdateAwardList()
        end)
    else
        UI.ShowMessage(Text('tip.reward_not_exist'))
    end
end

return tbClass
