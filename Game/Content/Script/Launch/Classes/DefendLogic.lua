-- ========================================================
-- @File    : DefendLogic.lua
-- @Brief   : 防御活动Launch逻辑
-- ========================================================
local tbClass = Launch.Class(LaunchType.DEFEND)

function tbClass:OnStart()
    local nLevelId, nDiff = DefendLogic.GetIDAndDiff()
    local tbLevelConf = DefendLogic.GetLevelConf(nLevelId, nDiff)

    local fFun = function()
        if Map.IsCanOpen(tbLevelConf.nMapID) then
            UI.SnapShoot({"formation"})
            Map.Open(tbLevelConf.nMapID, tbLevelConf:GetOption())
        end
    end

    if Login.bOffLine then
        fFun()
    else
        self:Register("DefendLogic_EnterLevel", fFun)
        DefendLogic.Req_EnterLevel(nLevelId, nDiff)
    end
end

function tbClass:OnSettlement(nResult, nTime, nReason)
    local nLevelId, nDiff = DefendLogic.GetIDAndDiff()
    local fun = function()
        UI.OpenWithCallback("Fail", function()  end)
    end
    if Login.bOffLine then
        fun()
    else
        DefendLogic.Req_LevelSettlement(nLevelId, nDiff, nResult)
        if nReason == UE4.ELevelFailedReason.ManualExit then
            Launch.End()
        else
            self:Register('DefendLogic_LevelSettlement', function() fun() end)
        end
    end
end

function tbClass:Again()
    -- if UI.tbRecover and #UI.tbRecover > 0 then
    --     table.insert(UI.tbRecover, "formation")
    -- end 
    Launch.End()
end

return tbClass