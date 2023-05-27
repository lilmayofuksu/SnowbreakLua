-- ========================================================
-- @File    : GacahTryLogic.lua
-- @Brief   : 扭蛋角色试玩活动Launch逻辑
-- ========================================================
local tbClass = Launch.Class(LaunchType.GACHATRY)

function tbClass:OnStart()
    local nActId, nGirlIdx, nLevelID = GachaTry.GetActId(), GachaTry.GetGirlIdx(), GachaTry.GetLevelID()
    local tbLevelConf = GachaTry.GetLevelConf(nLevelID)

    local fFun = function()
        if Map.IsCanOpen(tbLevelConf.nMapID) then
            UI.SnapShoot({"formation"})
            Map.Open(tbLevelConf.nMapID, tbLevelConf:GetOption())
        end
    end

    if Login.bOffLine then
        fFun()
    else
        self:Register("GachaTry_EnterLevel", fFun)
        GachaTry.Req_EnterLevel(nActId, nGirlIdx, nLevelID)
    end
end

function tbClass:OnSettlement(nResult, nTime, nReason)
    local nActId, nGirlIdx, nLevelID = GachaTry.GetActId(), GachaTry.GetGirlIdx(), GachaTry.GetLevelID()
    if nResult == UE4.ELevelFinishResult.Success then
        ---结算
        local fun = function() UI.OpenWithCallback("Success", function()  end) end
        --UI.Open("Success")
        if Login.bOffLine then
            fun()
        else
            self:Register("GachaTry_LevelSettlement", function(tbData)
                Launch.tbAward = tbData
                fun()
            end)
            GachaTry.Req_LevelSettlement(nActId, nGirlIdx, nLevelID)
        end
    else
        GachaTry.Req_LevelFail(nActId, nLevelID, nLevelID)
        if nReason == UE4.ELevelFailedReason.ManualExit then
            Launch.End()
        else
            UI.OpenWithCallback("Fail", function()  end)
        end
    end
end

function tbClass:Again()
    if UI.tbRecover and #UI.tbRecover > 0 then
        table.insert(UI.tbRecover, "formation")
    end
    Launch.End()
end

return tbClass