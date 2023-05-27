-- ========================================================
-- @File    : BossLogic.lua
-- @Brief   : boss挑战逻辑
-- ========================================================
local tbClass = Launch.Class(LaunchType.BOSS)

function tbClass:OnStart()
    local nMapID = BossLogic.GetMapID(BossLogic.GetBossLevelID())
    if not nMapID then return end
    BossLogic.FinishTime = 0

    local fFun = function()
        if BossLogic.DeathHandle then
            EventSystem.Remove(BossLogic.DeathHandle)
            BossLogic.DeathHandle = nil
        end
        local roleLimit = BossLogic.GetRoleLimit()  --角色倒下数量限制
        if roleLimit > 0 then
            BossLogic.DeathHandle = EventSystem.On(Event.CharacterDeath, function(InMonster)
                if InMonster then
                    local playerCharacter = InMonster:Cast(UE4.AGameCharacter)
                    if playerCharacter and playerCharacter:IsPlayer() then
                        local controller = playerCharacter:GetCharacterController()
                        if controller then
                            local lineup = controller:GetPlayerCharacters()
                            if lineup:Length() > roleLimit then
                                local deadnum = 0
                                for i = 1, lineup:Length() do
                                    local tmp = lineup:Get(i)
                                    if tmp:IsDead() then
                                        deadnum = deadnum + 1
                                    end
                                end
                                if deadnum >= roleLimit then  --失败 结束
                                    local pTaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
                                    if pTaskActor then
                                        pTaskActor:LevelFinishBroadCast(UE4.ELevelFinishResult.Failed, UE4.ELevelFailedReason.Dead)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        if Map.IsCanOpen(nMapID) then
            ---UI处理
            UI.SnapShoot({"formation"})
            Map.Open(nMapID)
        end
    end

    if Login.bOffLine then
        fFun()
    else
        self:Register("BossLogic_EnterLevel", fFun)
        BossLogic.Req_EnterLevel()
    end
end

function tbClass:OnSettlement(nResult, nTime, nReason)
    if BossLogic.DeathHandle then
        EventSystem.Remove(BossLogic.DeathHandle)
        BossLogic.DeathHandle = nil
    end

    --挑战耗时
    BossLogic.FinishTime = nTime

    local timecfg = BossLogic.GetTimeCfg()
    if not timecfg or not IsInTime(timecfg.nStartTime, timecfg.nEndTime) then
        UI.Open("MessageBox", Text("bossentries.BeOverdue"), function() Launch.End() end, "Hide")
        return
    end

    if nResult == UE4.ELevelFinishResult.Success then
        ---结算
        BossLogic.Req_LevelEnd()
    else
        BossLogic.Req_LevelFail(nReason)
        UI.CloseAll()
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