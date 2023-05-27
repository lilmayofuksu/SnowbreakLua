-- ========================================================
-- @File    : RoleLogic.lua
-- @Brief   : 角色碎片本逻辑
-- ========================================================
local tbClass = Launch.Class(LaunchType.ROLE)

function tbClass:OnStart()
    local nLevelID = Role.GetLevelID()
    local tbLevelCfg = RoleLevel.Get(nLevelID)
    local fFun = function()
        ---UI处理
        if Map.IsCanOpen(tbLevelCfg.nMapID) then
            UI.SnapShoot({"formation", "dungeonsroleInfo"})
            Map.Open(tbLevelCfg.nMapID, tbLevelCfg:GetOption())
        end
    end

    if Login.bOffLine then
        fFun()
    else
        self:Register(Role.REQ_ENTER_LEVEL, fFun)
        Role.Req_EnterLevel(nLevelID)
    end
end

function tbClass:OnSettlement(nResult, nTime, nReason)
    local LevelID = Role.GetLevelID()
    local IsPlot = Role.IsPlot()
    if nResult == UE4.ELevelFinishResult.Success then
        ---结算
        if Login.bOffLine then
            UI.OpenWithCallback("Success", function()  end)
        else
            self:Register(Role.REQ_LEVEL_SETTLEMENT, function(tbData)
                Launch.tbAward = tbData
                if IsPlot then
                    if tbData and #tbData[1] > 0 then
                        Role.tbShowAward = tbData[1]
                    else
                        Launch.tbAward = nil
                        Role.tbShowAward = nil
                    end
                    Launch.End()
                else
                    UI.OpenWithCallback("Success", function()  end)
                end
            end)
            Role.Req_LevelSettlement(LevelID)
        end
    else
        UI.CloseAll()
        Role.Req_LevelFail(LevelID, IsPlot)
        if nReason == UE4.ELevelFailedReason.ManualExit then
            Launch.End()
        else
            if IsPlot then
                Role.tbShowAward = nil
                Launch.End()
            else
                UI.OpenWithCallback("Fail", function()  end)
            end
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