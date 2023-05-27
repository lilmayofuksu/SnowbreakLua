-- ========================================================
-- @File    : ChessLogic.lua
-- @Brief   : 棋盘关卡
-- ========================================================
local tbClass = Launch.Class(LaunchType.CHESS)

function tbClass:OnStart()
    self.pCall = nil
    local fightId = ChessClient.GetFightID()
    local activityId, activityType, moduleName = ChessLogic.GetOpenID(), ChessClient.activityType, ChessClient.moduleName
    local cfg = ChessConfig:GetFightDefineByMoudleName(moduleName).tbId2Data[fightId]
    local fFun = function()
        if Map.IsCanOpen(cfg.nMapId) then
            UI.SnapShoot({"formation"})
            Map.Open(cfg.nMapId, cfg:GetOption())
        end
    end

    if Login.bOffLine then
        fFun()
    else
        self:Register("Chess_EnterLevel", fFun)
        ChessClient.Req_EnterLevel(activityId, activityType, fightId)
    end
end

function tbClass:OnEnd()
    -- goto chess level
    print("chess level")
    ChessClient.bFightReturn = true
    ChessClient:ReturnMap(self.pCall)
end

function tbClass:OnSettlement(nResult, nTime, nReason)
    self.pCall = nil
    local fightId = ChessClient.GetFightID()
    local activityId, activityType, moduleName = ChessLogic.GetOpenID(), ChessClient.activityType, ChessClient.moduleName
    local cfg = ChessConfig:GetFightDefineByMoudleName(moduleName).tbId2Data[fightId]
    if nResult == UE4.ELevelFinishResult.Success then
        ---结算
        self.pCall = function() ChessClient:NotifyFightSuccess(ChessClient.FightParam) end
        local fun = function() UI.Open("Success") end
        if Login.bOffLine then
            fun()
        else
            self:Register("Chess_LevelSettlement", function(tbData)
                Launch.tbAward = tbData
                fun()
            end)
            ChessClient.Req_LevelSettlement(activityId, activityType, fightId)
        end
    else
        ChessClient.Req_LevelFail(activityId, activityType, fightId)
        if nReason == UE4.ELevelFailedReason.ManualExit then
            Launch.End()
        else
            UI.Open("Fail")
        end
    end
end

function tbClass:Again()
    self.pCall = nil
    if UI.tbRecover and #UI.tbRecover > 0 then
        table.insert(UI.tbRecover, "formation")
    end
    Launch.End()
end

return tbClass