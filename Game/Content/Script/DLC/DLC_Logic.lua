-- ========================================================
-- @File    : DLC_Logic.lua
-- @Brief   : dlc活动外围逻辑
-- ========================================================

DLC_Logic = DLC_Logic or {}

DLC_Logic.nGID = 15             -- GID
DLC_Logic.ActId = 1             -- 当前期数id
DLC_Logic.OpFinish = 9          -- 是否看完Op 客户端修改

DLC_Logic.DailyMission = 10    -- 每日任务
DLC_Logic.WeeklyMission = 100  -- 每周任务

function DLC_Logic.Init()
    DLC_Logic.tbActivityConf = {}
    local tbFile = LoadCsv('dlc/dlc_activities.txt', 1)
    for _, tbLine in ipairs(tbFile) do
        local nId = tonumber(tbLine.ID) or 0
        local Coverage = tonumber(tbLine.Coverage) or 0
        if nId > 0 and CheckCoverage(Coverage) then
            local tb = {}
            tb.nId = nId
            tb.sDes = tbLine.Des
            tb.tbCondition = Eval(tbLine.Condition)
            tb.nIcon = tonumber(tbLine.Icon) or 0
            tb.sMainUI = tbLine.MainUI
            tb.nShopId = tonumber(tbLine.ShopID)
            tb.sShopDes = tbLine.ShopDes
            tb.tbMissionGroup = Eval(tbLine.MissionID)
            tb.sMissionDes = tbLine.MissionDes
            tb.sOP = tbLine.OP

            tb.nStartTime = ParseTime(string.sub(tbLine.StarTime or '', 2, -2), tb, 'nStartTime')
            tb.nEndTime = ParseTime(string.sub(tbLine.EndTime or '', 2, -2), tb, 'nEndTime')
            tb.nEnterStartTime = ParseTime(string.sub(tbLine.EnterStartTime or '', 2, -2), tb, 'nEnterStartTime')
            tb.nCloseEndTime = ParseTime(string.sub(tbLine.CloseEndTime or '', 2, -2), tb, 'nCloseEndTime')

            DLC_Logic.tbActivityConf[nId] = tb
        end
    end
end

function DLC_Logic.GetCurConf()
    local id = me:GetAttribute(DLC_Logic.nGID, DLC_Logic.ActId)
    if id > 0 then
        return DLC_Logic.tbActivityConf[id]
    else
        for _, v in ipairs(DLC_Logic.tbActivityConf) do
            if IsInTime(v.nEnterStartTime, v.nCloseEndTime) then
                return v
            end
        end
    end
end

function DLC_Logic.GetMissionGroup(nGroupId)
    local tbLimit = DLC_Logic.GetLimitMission()
    local tb = {}
    local group = AchievementDLC.GetGroupConf(nGroupId)
    if not group then return tb end
    for _, conf in pairs(group) do
        if conf.nRefreshRule == 0 then
            if conf.nPreId then
                local PreConf = AchievementDLC.GetConfig(conf.nPreId)
                if not PreConf or AchievementDLC.CheckAchievementReward(PreConf) == 2 then
                    table.insert(tb, conf)
                end
            else
                table.insert(tb, conf)
            end
        else
            for _, id in ipairs(tbLimit) do
                if id == conf.nId then
                    table.insert(tb, conf)
                end
            end
        end
    end
    return tb
end

function DLC_Logic.GetLimitMission()
    local tb = {}
    for i = 1, 20 do
        local id = me:GetAttribute(DLC_Logic.nGID, DLC_Logic.DailyMission + i)
        if id > 0 then table.insert(tb, id) end
        id = me:GetAttribute(DLC_Logic.nGID, DLC_Logic.WeeklyMission + i)
        if id > 0 then table.insert(tb, id) end
    end
    return tb
end

function DLC_Logic.HasCanGetMission()
    local tbConf = DLC_Logic.GetCurConf()
    if not tbConf then return false end
    for _, groupId in ipairs(tbConf.tbMissionGroup) do
        local tbMissions = DLC_Logic.GetMissionGroup(groupId)
        if tbMissions then
            for _, mission in ipairs(tbMissions) do
                if AchievementDLC.CheckAchievementReward(mission) == 1 then
                    return true
                end
            end
        end
    end
    return false
end

function DLC_Logic.CheckFirst(str)
    return UE4.UUserSetting.GetBool(string.format('%s_%d', str, me:Id()), true)
end

function DLC_Logic.SetFirstCheck(str)
    UE4.UUserSetting.SetBool(string.format('%s_%d', str, me:Id()), false)
    UE4.UUserSetting.Save()
end

function DLC_Logic.IsOpFinish()
    return me:GetAttribute(DLC_Logic.nGID, DLC_Logic.OpFinish) == 1
end

function DLC_Logic.SetOpFinish()
    me:SetAttribute(DLC_Logic.nGID, DLC_Logic.OpFinish, 1)
end

function DLC_Logic.CheckOpenAct()
    UI.ShowConnection()
    me:CallGS("DLCLogic_CheckOpenAct")
end

s2c.Register('DLCLogic_CheckOpenAct', function(tbParam)
    UI.CloseConnection()
    if tbParam and tbParam.bOpen then
        local conf = DLC_Logic.GetCurConf()
        if not conf then return UI.ShowTip(Text("ui.TxtNotOpen")) end
        if Condition.Check(conf.tbCondition) then
            if conf.sOP and conf.sOP ~= '' and not DLC_Logic.IsOpFinish() then
                PreviewMain.HiddenCard(true)
                local ui = UI.GetTop()
                if ui then WidgetUtils.Collapsed(ui) end
                UE4.UMapManager.PauseMusic()
                UE4.UGameLocalPlayer.SetAutoAdapteToScreen(false)
                local pLoadWidget = LoadWidget(conf.sOP)
                pLoadWidget:AddToViewport(1)
                UI.bInSequenceWidget = true
                pLoadWidget:SetEndCallback({GetGameIns(), function()
                    UE4.UGameLocalPlayer.SetAutoAdapteToScreen(true)
                    UI.bInSequenceWidget = false
                    DLC_Logic.SetOpFinish()
                    pLoadWidget:RemoveFromViewport()
                    UE4.UMapManager.ResumeMusic()
                    local ui = UI.GetTop()
                    if ui then WidgetUtils.SelfHitTestInvisible(ui) end
                    UI.Open(conf.sMainUI, conf)
                end})
            else
                UI.Open(conf.sMainUI, conf)
            end
        end
    else
        UI.ShowTip(Text("ui.TxtNotOpen"))
        UI.Call2('Main', 'ShowBtnDlc')
    end
end)

s2c.Register('DLC_SyncTime', function(tbParam)
    for _, tb in ipairs(tbParam) do
        local conf = DLC_Logic.tbActivityConf[tb.nId]
        if conf then
            conf.nStartTime = tb.nStartTime
            conf.nEndTime = tb.nEndTime
            conf.nEnterStartTime = tb.nEnterStartTime
            conf.nCloseEndTime = tb.nCloseEndTime
        end
    end
end)

DLC_Logic.Init()

return DLC_Logic