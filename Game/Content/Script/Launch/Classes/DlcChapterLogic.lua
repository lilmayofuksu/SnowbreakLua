-- ========================================================
-- @File    : ChapterLogic.lua
-- @Brief   : 剧情章节逻辑
-- ========================================================
local tbClass = Launch.Class(LaunchType.DLC1_CHAPTER)

function tbClass:OnStart()
    DLC_Chapter.bShowDetail = false
    local nLevelID = DLC_Chapter.GetLevelID()
    local tbLevelCfg = DLCLevel.Get(nLevelID)
    local fFun = function()
        ---UI处理
        if Map.IsCanOpen(tbLevelCfg.nMapID) then
            UI.SnapShoot({"formation"})
            Map.Open(tbLevelCfg.nMapID, tbLevelCfg:GetOption())
        end
    end

    if Login.bOffLine then
        fFun()
    else
        self:Register(DLC_Chapter.REQ_ENTER_LEVEL, fFun)
        DLC_Chapter.Req_EnterLevel(nLevelID)
    end
end

function tbClass:OnSettlement(nResult, nTime, nReason)
    DLC_Chapter.bShowDetail = false
    if nResult == UE4.ELevelFinishResult.Success then
        local PlaySuccess = true
        local TaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
        if TaskActor then PlaySuccess = TaskActor.PlaySuccess end
        ---结算
        if Login.bOffLine then
            if PlaySuccess then
                UI.Open("Success")
            else
                UI.OpenWithCallback("Settlement", function()
                    Audio.PlaySounds(3010)
                end)
            end
        else

            if DLC_Chapter.IsPlot() and Map.IsPlot() then
                UI.Open('PlotMask')
            end

            self:Register(DLC_Chapter.REQ_LEVEL_SETTLEMENT, function(tbData)
                Launch.tbAward = tbData
                local nLevelID = DLC_Chapter.GetLevelID()
                local tbLevelCfg = DLCLevel.Get(nLevelID)
                if DLC_Chapter.IsPlot() then
                    --UI.Open('PlotMask')
                    if Launch.tbAward and #Launch.tbAward > 0 then
                        DLC_Chapter.tbShowAward = Launch.tbAward[1]
                    else
                        Launch.tbAward = nil
                        DLC_Chapter.tbShowAward = nil
                    end
                    RedPoint.SetRedNum(RedPointType.PlotLevel, 0, string.format("%s-%s", DLC_Chapter.GetChapterID(), DLC_Chapter.GetLevelID()))
                    local nextId = DLC_Chapter.GetNextLevelID()
                    if nextId and nextId > 0 then DLC_Chapter.SetLevelID(nextId) end
                    Launch.End()
                else
                    if PlaySuccess then
                        UI.OpenWithCallback("Success", function()  end)
                    else
                        UI.OpenWithCallback("Settlement", function()
                            Audio.PlaySounds(3010)
                        end)
                    end
                    DLC_Chapter.UpdateStarAwardTip(DLC_Chapter.GetChapterID()) 
                end
                DLC_Chapter.UpdatePlotLevelTip(DLC_Chapter.GetChapterID())
            end)
            DLC_Chapter.Req_LevelSettlement(DLC_Chapter.GetLevelID())
        end
    else
        DLC_Chapter.Req_LevelFail(DLC_Chapter.GetLevelID())
        UI.CloseAll()
        if nReason == UE4.ELevelFailedReason.ManualExit then
            Launch.End()
        else
            if DLC_Chapter.IsPlot() then
                DLC_Chapter.tbShowAward = nil
                Launch.End()
            else
                UI.OpenWithCallback("Fail", function()  end)
            end
        end
    end
end


function tbClass:OnNext()
    DLC_Chapter.bShowDetail = true
    DLC_Chapter.bShowLevelInfo = true
    local nextId = DLC_Chapter.GetNextLevelID()
    if not nextId or nextId == 0 then nextId = DLC_Chapter.GetChapterID() end
    DLC_Chapter.SetLevelID(nextId)
    Launch.End()
end

function tbClass:Again()
    Chapter.bShowLevelInfo = true
    if UI.tbRecover and #UI.tbRecover > 0 then
        table.insert(UI.tbRecover, "formation")
    end
    Launch.End()
end

function tbClass:OnEnd()
    GoToMainLevel()
end

return tbClass