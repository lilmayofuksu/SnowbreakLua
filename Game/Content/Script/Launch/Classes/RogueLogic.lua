-- ========================================================
-- @File    : RogueLogic.lua
-- @Brief   : 肉鸽挑战逻辑
-- ========================================================
local tbClass = Launch.Class(LaunchType.DLC1_ROGUE)

function tbClass:GetNodeData(nState)
    local tbData = nil
    local NodeINfo = RogueLevel.GetNodeInfo()
    if NodeINfo then
        local tbKill = {}
        local TaskSubActor = UE4.ATaskSubActor.GetTaskSubActor(GetGameIns())
        if TaskSubActor and TaskSubActor.GetAchievementData then
            local tbKillMonster = TaskSubActor:GetAchievementData()
            local tbKey = tbKillMonster:Keys()
            for i = 1, tbKey:Length() do
                local sName = tbKey:Get(i)
                tbKill[sName] = tbKillMonster:Find(tbKey:Get(i))
            end
        end

        local LevelID = RogueLevel.GetLevelID()
        if NodeINfo.nNode == 1 then
            tbData = {nID = NodeINfo.nID, nType = 1, nLevelID = LevelID, nState = nState, tbKill = tbKill}
        elseif NodeINfo.nNode == 2 then
            local RandomInfo = RogueLogic.tbRandomCfg[NodeINfo.nRandomID]
            if RandomInfo then
                local SelectIndex = 1
                for Index, Effect in ipairs(RandomInfo.tbEffect) do
                    if Effect and Effect[1]==6 and Effect[2]==LevelID then
                        SelectIndex = Index
                    end
                end
                tbData = {nID = NodeINfo.nID, nType = NodeINfo.nNode, nSelectIndex = SelectIndex, nState = nState, tbKill = tbKill}
            end
        end
    end
    return tbData
end

function tbClass:OnStart()
    local LevelID = RogueLevel.GetLevelID()
    local cfg = RogueLevel.Get(LevelID)
    if not cfg then return end
    local nMapID = cfg.nMapID
    if not nMapID then return end

    local fFun = function()
        if Map.IsCanOpen(nMapID) then
            ---UI处理
            UI.SnapShoot({"formation", "DlcRogueRandom"})
            RogueLogic.AddRefreshHPEvent()
            Map.Open(nMapID, cfg:GetOption())
        end
    end

    if Login.bOffLine or LevelID == RogueLogic.nPlotLevelID then
        fFun()
    else
        local tbData = self:GetNodeData(1)
        if tbData then
            RogueLogic.FinishNode(tbData, fFun)
        else
            fFun()
        end
    end
end

function tbClass:OnSettlement(nResult, nTime, nReason)
    local LevelID = RogueLevel.GetLevelID()
    if LevelID == RogueLogic.nPlotLevelID then
        me:CallGS("RogueLogic_ShowOpenStory")
        if UI.tbRecover and #UI.tbRecover > 0 then
            table.insert(UI.tbRecover, "DlcRogue")
        end
        Launch.End()
        return
    end

    if nResult == UE4.ELevelFinishResult.Success then
        local tbData = self:GetNodeData(2)
        if tbData then
            tbData.tbHP = RogueLogic.GetTbHP()
            RogueLogic.FinishNode(tbData, function ()
                UI.Open("Success")
            end)
        else
            UI.Open("Success")
        end
    else
        UI.CloseAll()
        local fun = function ()
            if nReason == UE4.ELevelFailedReason.ManualExit then
                Launch.End()
            else
                UI.Open("Fail")
            end
        end
        local tbData = self:GetNodeData(3)
        if tbData then
            RogueLogic.FinishNode(tbData, fun)
        else
            fun()
        end
    end
end

function tbClass:OnEnd()
    RogueLogic.RemoveDeathCard()
    RogueLogic.RemoveRefreshHPEvent()
    GoToMainLevel()
end

function tbClass:Again()
    if UI.tbRecover and #UI.tbRecover > 0 then
        table.insert(UI.tbRecover, "formation")
    end
    Launch.End()
end

return tbClass
