-- ========================================================
-- @File    : MonsterSpawnStatistics.lua
-- @Brief   : 任务刷怪事件执行器
-- @Author  :
-- @Date    :
-- ========================================================

---@class MonsterSpawnStatistics
MonsterSpawnStatistics =
    MonsterSpawnStatistics or
    {
        MonsterSpawns = {}
        --刷怪事件
    }

local Spawn = MonsterSpawnStatistics

Spawn.MonsterDeathFun = nil
Spawn.CurrentMaxWaveNum = 0
Spawn.CurrentWaveIndex = 0

Spawn.AllSpawnMonsterInfinite = {}

function Spawn.Init()
    Spawn.MonsterDeathFun =
        EventSystem.On(
        Event.CharacterDeath,
        function(Character)
            Spawn.ExecuteSpawn()
        end
    )
    TaskCommon.AddHandle(Spawn.MonsterDeathFun)
end

---执行刷怪事件
function Spawn.ExecuteSpawn()
    for i = #Spawn.MonsterSpawns, 1, -1 do
        local m = Spawn.MonsterSpawns[i]
        --执行了 移除
        if m and m:TrySpawn() then
            table.remove(Spawn.MonsterSpawns, i)
        end
    end
end

---添加刷怪事件
---@param InSpawn SpawnMonsterEvent
function Spawn.AddSpawn(InSpawn)
    table.insert(Spawn.MonsterSpawns, InSpawn)
    Spawn.ExecuteSpawn() 
end

---退出执行
function Spawn.Shutdown()
    EventSystem.Remove(Spawn.MonsterDeathFun)
end

-------------------New----------------------
function Spawn.SpawnNpc(InContext, InSpawnInfo, InAddTags, IsSummon)
    if GlobalDisableSpawnNpc then 
        print("debug ignore npc", InSpawnInfo.Id); 
        return 
    end 

    print("debug MonsterSpawnStatistics.SpawnNpc: ", InSpawnInfo.Id)
    local Args = UE4.FSpawnNpcPointParams()
    Args.PointName = InSpawnInfo.PointName
    Args.Id = InSpawnInfo.Id
    Args.AI = InSpawnInfo.AI
    Args.Level = InSpawnInfo.Level

    Args.Team = InSpawnInfo.Team
    Args.AIEventID = InSpawnInfo.AIEventID
    Args.SpecializedSkillsConfig = InSpawnInfo.SpecializedSkillsConfig
    Args.IdleAnimIndex = InSpawnInfo.IdleAnimIndex
    Args.CampPriority = InSpawnInfo.CampPriority
    if InSpawnInfo.SpawnNpcSpCfg then
        Args.SpawnNpcSpCfg = InSpawnInfo.SpawnNpcSpCfg;
    end

    if IsSummon then
        Args.Type = UE4.ECharacterType.Summon
    else
        Args.Type = InSpawnInfo.Type;
    end

    --- 处理出生特效
    if InSpawnInfo.SpawnEffectId and InSpawnInfo.SpawnEffectId >= 0 then
        local SpawnEffectTpl = UE4.ULevelLibrary.GetSpawnEffectTemplate(InSpawnInfo.SpawnEffectId)
        local SpawnEffect = UE4.ULevelLibrary.GetSpawnEffect(SpawnEffectTpl)
        local actor = UE4.ULevelLibrary.GetActorByName(InContext, UE4.ANPCSpawnPoint.StaticClass(), Args.PointName)
        if actor and SpawnEffectTpl then
            
            --- 关联预警UI
            local RedPoint
            if SpawnEffectTpl.ShowRedPoint then
                local FightUMG = UI.GetUI("Fight")
                if FightUMG and FightUMG.uw_fight_monster_tips then
                    RedPoint = FightUMG.uw_fight_monster_tips:CreateItem(actor, UE4.EFightMonsterTipsType.Attack)
                end
            end

            local PSC = UE4.UGameParticleBlueprintLibrary.BroadcastSpawnAtLocation(InContext, nil, SpawnEffect, actor:K2_GetActorLocation() + SpawnEffectTpl.Offset, actor:K2_GetActorRotation(), SpawnEffectTpl.Scale)
            if SpawnEffectTpl.Mode == UE4.ESpawnEffetMode.SpawnDelay then
                UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {InContext, 
                    function()
                        print("Delay Time over")
                        if RedPoint then
                            RedPoint:Reset()
                        end
                        UE4.ULevelLibrary.SpawnNpcByPoint(InContext, Args, InAddTags)
                    end}, 
                    SpawnEffectTpl.DelayTime)
                print("Delay", SpawnEffectTpl.DelayTime)
                return
            elseif PSC and SpawnEffectTpl.Mode == UE4.ESpawnEffetMode.AfterEffect then
                PSC.OnSystemFinished:Add(InContext, function()
                    UE4.ULevelLibrary.SpawnNpcByPoint(InContext, Args, InAddTags)
                end)
                return
            end
        end
    end
    UE4.ULevelLibrary.SpawnNpcByPoint(InContext, Args, InAddTags)
end

function Spawn.InitWave(InMaxWave)
    Spawn.CurrentMaxWaveNum = InMaxWave
    Spawn.CurrentWaveIndex = 0
end

function Spawn.AddWaveIndex()
    Spawn.CurrentWaveIndex = Spawn.CurrentWaveIndex + 1
    EventSystem.Trigger(Event.WaveIndexChange)
end

function Spawn.IsWaveEnd()
    return Spawn.CurrentWaveIndex >= Spawn.CurrentMaxWaveNum
end

---加入刷怪统计
function Spawn.AddInfiniteSpawn(InSpawn)
    table.insert(Spawn.AllSpawnMonsterInfinite, InSpawn)
end

---停止该盒子无限刷怪根据
function Spawn.StopInfiniteSpawn(InTagName)
    for i = #Spawn.AllSpawnMonsterInfinite, 1, -1 do
        if Spawn.AllSpawnMonsterInfinite[i]:MakeTagName(Spawn.AllSpawnMonsterInfinite[i].TagName) == Spawn.AllSpawnMonsterInfinite[i]:MakeTagName(InTagName) then
            Spawn.AllSpawnMonsterInfinite[i]:Stop()
            table.remove(Spawn.AllSpawnMonsterInfinite, i)
        end
    end
end

---
Spawn.Init()
EventSystem.On(Event.Shutdown, Spawn.Shutdown)

return Spawn
