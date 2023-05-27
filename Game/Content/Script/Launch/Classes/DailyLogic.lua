-- ========================================================
-- @File    : DailyLogic.lua
-- @Brief   : 每日章节逻辑
-- ========================================================
local tbClass = Launch.Class(LaunchType.DAILY)

function tbClass:OnStart()
    local nLevelID = Daily.GetLevelID()
    local tbLevelCfg = DailyLevel.Get(nLevelID)
    if tbLevelCfg then
        self:Register(Daily.REQ_ENTER_LEVEL, function()
            ---UI处理
            if Launch.CheckPlayAgain(LaunchType.DAILY, nLevelID) then
                Map.Open(tbLevelCfg.nMapID, tbLevelCfg:GetOption(), nil, true)
            elseif Map.IsCanOpen(tbLevelCfg.nMapID) then
                UI.SnapShoot({"formation"})
                Map.Open(tbLevelCfg.nMapID, tbLevelCfg:GetOption())
            end
       end)
        Daily.Req_EnterLevel(Daily.GetLevelID())
    end
end


function tbClass:OnSettlement(nResult, nTime, nReason)
    if nResult == UE4.ELevelFinishResult.Success then
        ---结算
        if Login.bOffLine then
            UI.OpenWithCallback("Success", function()  end)
        else
            self:Register(Daily.REQ_LEVEL_SETTLEMENT, function(tbData)
                Launch.tbAward = tbData
                UI.OpenWithCallback("Success", function()  end)
            end)
            Daily.Req_LevelSettlement(Daily.GetLevelID())
        end
    else
        Daily.Req_LevelFail(Daily.GetLevelID())
        UI.CloseAll()
        if nReason == UE4.ELevelFailedReason.ManualExit then
            Launch.End()
        else
            UI.OpenWithCallback("Fail", function()  end)
        end
    end
end

function tbClass:OnNext()
    Daily.bShowLevelInfo = true
    Daily.SetLevelID(Daily.GetNextLevelID())
    Launch.End()
end

function tbClass:Again()

    local canFight, msg = Formation.CanFight()
    if not canFight then
        UI.ShowTip(msg)
        return
    end

    local cfg = DailyLevel.Get(Daily.GetLevelID())
    local nVigor = cfg:GetConsumeVigor()
    nVigor = nVigor * Launch.GetMultiple()
    if nVigor and Cash.GetMoneyCount(Cash.MoneyType_Vigour) < nVigor then
        UI.ShowTip("ui.TxtEnergyTips")
        return
    end

    local tbChapterCfg = Daily.GetChapterByID(Daily.GetID())
    if tbChapterCfg then
        local value = me:GetAttribute(102, tbChapterCfg.nID)
        local nGuarantee = GetBits(value, 0, 15)
        if tbChapterCfg.Guarantee > 0 and nGuarantee and tbChapterCfg.Guarantee <= nGuarantee then
            UI.Open("MessageBox", Text("ui.TxtSmapTip6"), function()
                Launch.SetPlayAgain(LaunchType.DAILY, Daily.GetLevelID())
                Launch.Start()
            end)
            return
        end
    end

    Launch.SetPlayAgain(LaunchType.DAILY, Daily.GetLevelID())
    Launch.Start()
end

return tbClass