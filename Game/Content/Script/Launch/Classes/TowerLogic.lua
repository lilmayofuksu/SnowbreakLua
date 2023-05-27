-- ========================================================
-- @File    : TowerLogic.lua
-- @Brief   : 爬塔出击逻辑
-- ========================================================
local tbClass = Launch.Class(LaunchType.TOWER)

function tbClass:OnStart()
    -----日志相关---------
    ---记录房间完成情况
    ClimbTowerLogic.tbTaskFinishType = {0,0,0}
    ---记录房间星级情况
    ClimbTowerLogic.tbTaskFinalStar = {}
    ---记录任务用时
    ClimbTowerLogic.tbTaskTime = {0,0,0}
    ---记录任务名字
    ClimbTowerLogic.tbTaskName = {"0", "0", "0"}
    ---------------------

    ClimbTowerLogic.UpdateFight()
    local nLevelID = ClimbTowerLogic.GetLevelCfg().nLevelID
    local tbLevelCfg = TowerLevel.Get(nLevelID)

    local isDouble, isUp = ClimbTowerLogic.IsDouble()
    if isDouble then
        if isUp then
            Formation.SetCurLineupIndex(7)
        else
            Formation.SetCurLineupIndex(8)
        end
    else
        Formation.SetCurLineupIndex(6)
    end
    local tbteam = Formation.GetCurrentLineup()
    if tbteam then UE4.UUMGLibrary.SetTeamCharacters(tbteam:GetCards()) end

    local fFun = function()
        if Map.IsCanOpen(tbLevelCfg.nMapID) then
            Map.Open(tbLevelCfg.nMapID, tbLevelCfg:GetOption())
        end
    end

    if Login.bOffLine then
        fFun()
    else
        self:Register("TowerLevel_EnterLevel", fFun)
        TowerLevel.Req_EnterLevel(nLevelID)
    end
end

function tbClass:OnSettlement(nResult, nTime, nReason)
    local nLevelID = ClimbTowerLogic.GetLevelCfg().nLevelID
    local nArea = ClimbTowerLogic.GetLevelArea()
    local TaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
    -----日志相关---------
    ClimbTowerLogic.tbTaskTime[nArea] = math.ceil(nTime)
    if TaskActor then
        local Task = TaskActor:GetGameTask()
        if Task then
            ClimbTowerLogic.tbTaskName[nArea] = Task:GetName()
        end
    end
    ---------------------
    if nResult == UE4.ELevelFinishResult.Success then
        ClimbTowerLogic.tbTaskFinishType[nArea] = 1
        if TaskActor and TaskActor.ResetReconnectHandle then
            TaskActor:ResetReconnectHandle()
        end

        local nStar = 0
        local pSubSys = UE4.USubsystemBlueprintLibrary.GetWorldSubsystem(GetGameIns(), UE4.ULevelStarTaskManager)
        if pSubSys then
            nStar = pSubSys:GetStarTaskResultCache()
            local tb = {0,0,0}
            for i = 0, 2 do
                tb[i+1] = GetBits(nStar,i,i)
            end
            ClimbTowerLogic.tbTaskFinalStar[nArea] = tb
        end

        --单间结束
        if nArea < 3 then   --单间结束
            if not Login.bOffLine then
                ClimbTowerLogic.RecordProgres(ClimbTowerLogic.GetLevelID(), nArea, nStar, true)
            end
            ClimbTowerLogic.SetLevelArea(nArea + 1)
        else    --一层结束
            local fun = function()
                if ClimbTowerLogic.NextLevelID() then   --由上层进入下层
                    ClimbTowerLogic.IsToNext = true
                    local widget = Activity.LoadCaseItem("/Game/UI/UMG/Fight/Widgets/Loading/uw_fight_scene_on.uw_fight_scene_on_C")
                    widget:AddToViewport(1)
                    widget:SceneOn()
		            widget.TxtDes:SetText(Text("ui.TxtTowerAnotherTips"))
                    if widget.Time and widget.Time > 0 then
                        if widget.EffectDelayTime and widget.EffectDelayTime > 0 then
                            UE4.Timer.Add(widget.EffectDelayTime, function ()
                                widget.FightScene:ActivateSystem(true)
                            end)
                        else
                            widget.FightScene:ActivateSystem(true)
                        end
                        UE4.Timer.Add(widget.Time, function ()
                            Launch.Next()
                        end)
                    else
                        Launch.Next()
                    end
                else    --无下层进入结算
                    UI.OpenWithCallback("Success", function()  end)
                end
            end
            if Login.bOffLine then
                fun()
            else
                self:Register("TowerLevel_LevelSettlement", function(tbData)
                    Launch.tbAward = tbData
                    fun()
                end)
                TowerLevel.Req_LevelSettlement(nLevelID)
            end
        end
    else
        TowerLevel.Req_LevelFail(nLevelID, nReason)
        if nReason == UE4.ELevelFailedReason.ManualExit then
            Launch.End()
        else
            UI.OpenWithCallback("Fail", function()  end)
        end
    end
end

function tbClass:OnNext()
    local nextID = ClimbTowerLogic.NextLevelID()
    if nextID then
        local cfg = ClimbTowerLogic.GetLevelInfo(nextID)
        if cfg then
            UI.CloseAll()
            ClimbTowerLogic.SetLevelID(cfg.nID)
            ClimbTowerLogic.SetLevelArea(1)
            Launch.Start()
        end
    else
        Launch.End()
    end
end

function tbClass:OnEnd()
    ClimbTowerLogic.RemoveRefreshHPEvent()
    ClimbTowerLogic.UpdateFight(true)
    UI.tbRecover = {'main', 'dungeons', 'challenge', 'tower'}
    GoToMainLevel()
end

function tbClass:Again()
    ClimbTowerLogic.bShowLevelInfo = true
    Launch.End()
end

return tbClass
