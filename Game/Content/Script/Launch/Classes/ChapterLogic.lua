-- ========================================================
-- @File    : ChapterLogic.lua
-- @Brief   : 剧情章节逻辑
-- ========================================================
local tbClass = Launch.Class(LaunchType.CHAPTER)

function tbClass:OnStart()
    Chapter.bShowDetail = false
    local nLevelID = Chapter.GetLevelID()
    local tbLevelCfg = ChapterLevel.Get(nLevelID)
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
        self:Register(Chapter.REQ_ENTER_LEVEL, fFun)
        Chapter.Req_EnterLevel(nLevelID)
    end
end

function tbClass:OnSettlement(nResult, nTime, nReason)
    Chapter.bShowDetail = false
    if nResult == UE4.ELevelFinishResult.Success then
        ---结算
        if Login.bOffLine then
            UI.Open("Success")
        else

            if Chapter.IsPlot() and Map.IsPlot() then
                UI.Open('PlotMask')
            end

            self:Register(Chapter.REQ_LEVEL_SETTLEMENT, function(tbData)
                Launch.tbAward = tbData
                --print("[ChapterLogic]", Chapter.GetChapterDifficult(), Chapter.GetChapterID(), Chapter.GetLevelID());
                local nLevelID = Chapter.GetLevelID()
                local tbLevelCfg = ChapterLevel.Get(nLevelID)
                if tbLevelCfg then
                    --print("[ChapterLogic] PassTime:", tbLevelCfg:GetPassTime())
                    EventSystem.TriggerTarget(
                        Survey,
                        Survey.PRE_SURVEY_EVENT,
                        Survey.CHAPTER,
                        tbLevelCfg:GetPassTime(),
                        Chapter.GetChapterDifficult(), Chapter.GetChapterID(), Chapter.GetLevelID()
                    )
                end
                if Chapter.IsPlot() then
                    --UI.Open('PlotMask')
                    if Launch.tbAward and #Launch.tbAward > 0 then
                        Chapter.tbShowAward = Launch.tbAward[1]
                    else
                        Launch.tbAward = nil
                        Chapter.tbShowAward = nil
                    end
                    RedPoint.SetRedNum(RedPointType.PlotLevel, 0, string.format("%s_%s-%s", Chapter.GetChapterID(), CHAPTER_LEVEL.EASY, Chapter.GetLevelID()))
                    local nextId = Chapter.GetNextLevelID()
                    if nextId and nextId > 0 then Chapter.SetLevelID(nextId) end
                    Launch.End()
                else
                    Launch.LevelHasFinished = true
                    UI.OpenWithCallback("Success", function()  end)
                    Chapter.UpdateStarAwardTip(Chapter.IsMain(), Chapter.GetChapterDifficult(), Chapter.GetChapterID()) 
                end
                Chapter.UpdatePlotLevelTip(Chapter.GetChapterID())
                Adjust.ChapterRecord(tbLevelCfg)
            end)
            Chapter.Req_LevelSettlement(Chapter.GetLevelID())
        end
    else
        Chapter.Req_LevelFail(Chapter.GetLevelID())
        UI.CloseAll()
        if nReason == UE4.ELevelFailedReason.ManualExit then
            Launch.End()
        else
            if Chapter.IsPlot() then
                Chapter.tbShowAward = nil
                Launch.End()
            else
                UI.OpenWithCallback("Fail", function()  end)
            end
        end
    end
end


function tbClass:OnNext()
    Chapter.bShowDetail = true
    Chapter.bShowLevelInfo = true
    local nextId = Chapter.GetNextLevelID()
    if not nextId or nextId == 0 then nextId = Chapter.GetChapterID() end
    Chapter.SetLevelID(nextId)
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