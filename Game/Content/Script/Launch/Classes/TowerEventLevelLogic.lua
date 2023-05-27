-- ========================================================
-- @File    : TowerEventLevelLogic.lua
-- @Brief   : 爬塔-战术考核章节逻辑
-- ========================================================
local tbClass = Launch.Class(LaunchType.TOWEREVENT)

function tbClass:OnStart()
    local nLevelID = TowerEventChapter.GetLevelID()
    local tbLevelCfg = TowerEventLevel.Get(nLevelID)
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
        self:Register(TowerEventChapter.REQ_ENTER_LEVEL, fFun)
        TowerEventChapter.Req_EnterLevel(nLevelID)
    end
end

function tbClass:OnSettlement(nResult, nTime, nReason)
    if nResult == UE4.ELevelFinishResult.Success then
        ---结算
        if Login.bOffLine then
            UI.OpenWithCallback("Success", function()  end)
        else
            self:Register(TowerEventChapter.REQ_LEVEL_SETTLEMENT, function(tbData)
                Launch.tbAward = tbData
                UI.OpenWithCallback("Success", function()  end)
            end)
            TowerEventChapter.Req_LevelSettlement(TowerEventChapter.GetLevelID())
        end
    else
        TowerEventChapter.Req_LevelFail(TowerEventChapter.GetLevelID())
        UI.CloseAll()
        if nReason == UE4.ELevelFailedReason.ManualExit then
            Launch.End()
        else
            UI.OpenWithCallback("Fail", function()  end)
        end
    end
end


function tbClass:OnNext()
    local nextId = TowerEventChapter.GetNextLevelID()
    if not nextId or nextId == 0 then nextId = TowerEventChapter.GetLevelID() end
    TowerEventChapter.SetLevelID(nextId)
    Launch.End()
end

function tbClass:Again()
    if UI.tbRecover and #UI.tbRecover > 0 then
        table.insert(UI.tbRecover, "formation")
    end
    Launch.End()
end

return tbClass
