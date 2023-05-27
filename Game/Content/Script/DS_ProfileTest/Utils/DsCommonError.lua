-- ========================================================
-- @File    : DS_ProfileTest/Utils/DsCommonError.lua
-- @Brief   : DS机器人异常行为判断类
-- ========================================================

DSCommonError = DSCommonError or {}

DSCommonError.RandomPos = UE4.FVector()

--- 玩家位置异常状态
DSCommonError.PlayerUnusualPosStatus = {
    NextPosx =  0,
    NextPosy =  0,
    MaxMoveTimes = 400,
    CurMoveTimes = 0,

    --异常状态下记录切换随机移动点
    IsInRandomPosing = false,
    RandomPos = UE4.FVector(),
    RandomPosNotReachCount = 0,
    RandomPosNotReachMaxCount = 1000,
    MoveTimeOut = 0,
    MoveTimeOutMax = 1100,

    --异常状态处理2
    CurRestTime = 0,
    MaxRestTime = 6,
    LastLoc = UE4.FVector(),
    DirectionList = {},
    SearchDistance = 500,
    MoveDistance = 2000,
}

DSCommonError.MonsterPosStatus = {
    MaxLiveTimes = 45, --秒
    CurLiveTimes = 0,
    lastMonster = nil
}

--- 打印日志级别
local LogType = {
    DEBUG = false,
    INFO = true,
    WARNING = true,
    ERROR = true,
}

-- 初始化数据
function DSCommonError.Init()
    DSCommonError.PlayerUnusualPosStatus = {
        NextPosx =  0,
        NextPosy =  0,
        MaxMoveTimes = 500,
        CurMoveTimes = 0,
        IsInRandomPosing = false,
        RandomPos = UE4.FVector(),
        RandomPosNotReachCount = 0,
        RandomPosNotReachMaxCount = 1000,
        MoveTimeOut = 0,
        MoveTimeOutMax = 1100,
        CurRestTime = 0,
        MaxRestTime = 6,
        DirectionList = {},
        LastLoc = UE4.FVector(),
        SearchDistance = 500,
        MoveDistance = 2000,
    }
    DSCommonError.MonsterPosStatus = {
        MaxLiveTimes = 45, --秒
        CurLiveTimes = 0,
        lastMonster = nil
    }
end

--- 判定玩家位置异常状态
function DSCommonError.CheckPlayerPosStatus(curx,cury,curz)
    if DSCommonfunc.movetime == 1000001 or DSCommonAction.isGotoAttackHighAltitudeEnemy then
        return
    end

    if DSCommonAction.IsUseingElevator == true and #DSCommonfunc.InteractList ~= 0 then
        -- UE4.UDsProfileFunctionLib.StopMove()
        UE4.UDsProfileFunctionLib.CeaseFire()
        return
    end

    -- if DSCommonError.PlayerUnusualPosStatus.IsInRandomPosing == true and DSCommonAction.IsInRandomPosing == false then
    --     DSCommonError.PlayerUnusualPosStatus.RandomPosNotReachCount = DSCommonError.PlayerUnusualPosStatus.RandomPosNotReachCount + 1
    --     local playerPos = UE4.UDsProfileFunctionLib.GetPlayerLocation()
    --     local Distance = UE4.FVector.Dist(DSCommonError.PlayerUnusualPosStatus.RandomPos,playerPos)
    --     if Distance < 120.0 or DSCommonError.PlayerUnusualPosStatus.RandomPosNotReachCount > DSCommonError.PlayerUnusualPosStatus.RandomPosNotReachMaxCount then
    --         DSCommonError.PlayerUnusualPosStatus.IsInRandomPosing = false
    --     end
    --     return
    -- end

    if DSCommonError.PlayerUnusualPosStatus.IsInRandomPosing == true then
        DSCommonError.PlayerUnusualPosStatus.MoveTimeOut = DSCommonError.PlayerUnusualPosStatus.MoveTimeOut + 1
        UE4.UDsProfileFunctionLib.MoveTo(DSCommonError.RandomPos.X,DSCommonError.RandomPos.Y,DSCommonError.RandomPos.Z)
        local player_pos = UE4.FVector()
        UE4.UDsProfileFunctionLib.GetPlayerLocation(player_pos)
        local Distance = UE4.FVector.Dist(player_pos,DSCommonError.RandomPos)
        if Distance < 150.0 then
            DSCommonError.PlayerUnusualPosStatus.IsInRandomPosing = false
        elseif DSCommonError.PlayerUnusualPosStatus.MoveTimeOut >= DSCommonError.PlayerUnusualPosStatus.MoveTimeOutMax then
            DSCommonError.PlayerUnusualPosStatus.IsInRandomPosing = false
        else
            return
        end
    end


    if (math.abs(curx - DSCommonError.PlayerUnusualPosStatus.NextPosx)<50 and math.abs(cury - DSCommonError.PlayerUnusualPosStatus.NextPosy)<50 and DSCommonError.PlayerUnusualPosStatus.CurMoveTimes >= DSCommonError.PlayerUnusualPosStatus.MaxMoveTimes) then
        local info = string.format("DSCommonError:CheckPlayerPosStatus:%s,%s,%s",curx,cury,curz)
        DSCommonfunc.RegularPrint("ERROR",info,3,BP_LocalPlayerAutoAgent2.DeltaTime)
        -- DSCommonError.tfPrint("ERROR",info)

        --随机移动处理
        local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
        PlayerController:MoveForward(0)
        PlayerController:MoveRight(0)
        DSCommonError.RandomPos = UE4.UDsProfileFunctionLib.GetRandomReachablePointInRadiusByPlayer(1500.0)
        UE4.UDsProfileFunctionLib.MoveTo(DSCommonError.RandomPos.X,DSCommonError.RandomPos.Y,DSCommonError.RandomPos.Z)
        info = string.format("DSCommonError:RandomPos:%f,%f,%f",DSCommonError.RandomPos.X,DSCommonError.RandomPos.Y,DSCommonError.RandomPos.Z)
        DSCommonfunc.RegularPrint("ERROR",info,3,BP_LocalPlayerAutoAgent2.DeltaTime)
        DSCommonError.PlayerUnusualPosStatus.IsInRandomPosing = true
        DSCommonError.PlayerUnusualPosStatus.RandomPos = DSCommonError.RandomPos
        DSCommonError.PlayerUnusualPosStatus.RandomPosNotReachCount = 0
        DSCommonError.PlayerUnusualPosStatus.MoveTimeOut = 0
    elseif (math.abs(curx - DSCommonError.PlayerUnusualPosStatus.NextPosx)<50 and math.abs(cury - DSCommonError.PlayerUnusualPosStatus.NextPosy)<50  and DSCommonError.PlayerUnusualPosStatus.CurMoveTimes < DSCommonError.PlayerUnusualPosStatus.MaxMoveTimes) then
        DSCommonError.PlayerUnusualPosStatus.CurMoveTimes = DSCommonError.PlayerUnusualPosStatus.CurMoveTimes + 1
    elseif (curx~=DSCommonError.PlayerUnusualPosStatus.NextPosx and cury~=DSCommonError.PlayerUnusualPosStatus.NextPosy) then
        DSCommonError.PlayerUnusualPosStatus.NextPosx=curx
        DSCommonError.PlayerUnusualPosStatus.NextPosy=cury
        DSCommonError.PlayerUnusualPosStatus.CurMoveTimes=1
    end
    
end

local function CheckPos(playerPosition)
    local _ = UE4.FVector()
    if UE4.UNavigationSystemV1.K2_ProjectPointToNavigation(GetGameIns():GetWorld(),UE4.FVector(playerPosition.X+DSCommonError.PlayerUnusualPosStatus.SearchDistance,playerPosition.Y,playerPosition.Z),_) then
        table.insert(DSCommonError.PlayerUnusualPosStatus.DirectionList,1,UE4.FVector(playerPosition.X+DSCommonError.PlayerUnusualPosStatus.MoveDistance,playerPosition.Y,playerPosition.Z))
    else
        table.insert(DSCommonError.PlayerUnusualPosStatus.DirectionList,UE4.FVector(playerPosition.X+DSCommonError.PlayerUnusualPosStatus.MoveDistance,playerPosition.Y,playerPosition.Z))
    end
    if UE4.UNavigationSystemV1.K2_ProjectPointToNavigation(GetGameIns():GetWorld(),UE4.FVector(playerPosition.X-DSCommonError.PlayerUnusualPosStatus.SearchDistance,playerPosition.Y,playerPosition.Z),_) then
        table.insert(DSCommonError.PlayerUnusualPosStatus.DirectionList,1,UE4.FVector(playerPosition.X-DSCommonError.PlayerUnusualPosStatus.MoveDistance,playerPosition.Y,playerPosition.Z))
    else
        table.insert(DSCommonError.PlayerUnusualPosStatus.DirectionList,UE4.FVector(playerPosition.X-DSCommonError.PlayerUnusualPosStatus.MoveDistance,playerPosition.Y,playerPosition.Z))
    end
    if UE4.UNavigationSystemV1.K2_ProjectPointToNavigation(GetGameIns():GetWorld(),UE4.FVector(playerPosition.X,playerPosition.Y+DSCommonError.PlayerUnusualPosStatus.SearchDistance,playerPosition.Z),_) then
        table.insert(DSCommonError.PlayerUnusualPosStatus.DirectionList,1,UE4.FVector(playerPosition.X,playerPosition.Y+DSCommonError.PlayerUnusualPosStatus.MoveDistance,playerPosition.Z))
    else
        table.insert(DSCommonError.PlayerUnusualPosStatus.DirectionList,UE4.FVector(playerPosition.X,playerPosition.Y+DSCommonError.PlayerUnusualPosStatus.MoveDistance,playerPosition.Z))
    end
    if UE4.UNavigationSystemV1.K2_ProjectPointToNavigation(GetGameIns():GetWorld(),UE4.FVector(playerPosition.X,playerPosition.Y-DSCommonError.PlayerUnusualPosStatus.SearchDistance,playerPosition.Z),_) then
        table.insert(DSCommonError.PlayerUnusualPosStatus.DirectionList,1,UE4.FVector(playerPosition.X,playerPosition.Y-DSCommonError.PlayerUnusualPosStatus.MoveDistance,playerPosition.Z))
    else
        table.insert(DSCommonError.PlayerUnusualPosStatus.DirectionList,UE4.FVector(playerPosition.X,playerPosition.Y-DSCommonError.PlayerUnusualPosStatus.MoveDistance,playerPosition.Z))
    end
end

function DSCommonError.CheckPlayerPosStatus2(playerPosition) --此只用于从无导航地区走到有导航地区 高低差太大或者头顶很近有导航网格可能失效
    if #DSCommonError.PlayerUnusualPosStatus.DirectionList == 0 then
        if DSCommonError.PlayerUnusualPosStatus.CurRestTime == 0 then
            DSCommonError.PlayerUnusualPosStatus.LastLoc = playerPosition
        end
        if DSCommonError.PlayerUnusualPosStatus.CurRestTime > DSCommonError.PlayerUnusualPosStatus.MaxRestTime then
            if UE4.FVector.Dist(DSCommonError.PlayerUnusualPosStatus.LastLoc,playerPosition) < 100 then
                if UE4.UNavigationSystemV1.K2_ProjectPointToNavigation(GetGameIns():GetWorld(),playerPosition,UE4.FVector()) then return end -- 如果在导航坐标上就直接退出
                DSCommonError.tfPrint("ERROR","Player Position abnormal!")
                CheckPos(playerPosition)
            else
                DSCommonError.PlayerUnusualPosStatus.LastLoc = playerPosition
                DSCommonError.PlayerUnusualPosStatus.CurRestTime = 0
                DSCommonError.PlayerUnusualPosStatus.DirectionList = {}
            end
        end
    else
        local index = math.floor(DSCommonError.PlayerUnusualPosStatus.CurRestTime / DSCommonError.PlayerUnusualPosStatus.MaxRestTime) 
        local pos = DSCommonError.PlayerUnusualPosStatus.DirectionList[index]
        if UE4.UNavigationSystemV1.K2_ProjectPointToNavigation(GetGameIns():GetWorld(),playerPosition,UE4.FVector())
        or pos == nil then --玩家回到导航网格上或者跑完全部方向
            DSCommonError.PlayerUnusualPosStatus.DirectionList = {}
            DSCommonError.PlayerUnusualPosStatus.CurRestTime = 0
            UE4.UDsProfileFunctionLib.StopMoveInput()
            return
        end
        UE4.UDsProfileFunctionLib.StopMove()
        UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(pos.X,pos.Y,pos.Z)
        UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
    end
    DSCommonError.PlayerUnusualPosStatus.CurRestTime = DSCommonError.PlayerUnusualPosStatus.CurRestTime + BP_LocalPlayerAutoAgent2.DeltaTime
end

local GetOwningPlayer = function() 
    local ui = UI.GetUI("AdinGM")
    if ui then 
        return ui:GetOwningPlayer()
    end
end

function DSCommonError.CheckMonsterPosStatus(monster)
    local NowHealth,MaxHealth,NowSheild,MaxSheild = DSCommonfunc.GetMonsterHealthAndSheild(monster)
    if DSCommonfunc.CheckMonsterIsAttackable(monster,NowHealth,NowSheild,DSCommonError.MonsterPosStatus.MaxLiveTimes) == 2 then
        local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
        local Character = UE4.UGameplayStatics.GetPlayerCharacter(PlayerController, 0)
        if Character then 
            Character:ApplyKillAllEnemy()
            DSCommonError.tfPrint("WARNING","调用了怪物自杀")
        end
    end

    -- if monster ~= DSCommonError.MonsterPosStatus.lastMonster then -- 切换了攻击的怪物
    --     DSCommonError.MonsterPosStatus.CurLiveTimes = 0
    --     DSCommonError.MonsterPosStatus.lastMonster = monster
    -- elseif DSCommonError.MonsterPosStatus.CurLiveTimes > DSCommonError.MonsterPosStatus.MaxLiveTimes then -- 超时，怪物自杀
    --     DSCommonError.MonsterPosStatus.CurLiveTimes = 0
    --     local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    --     local Character = UE4.UGameplayStatics.GetPlayerCharacter(PlayerController, 0)
    --     if Character then 
    --         Character:ApplyKillAllEnemy()
    --         DSCommonError.tfPrint("WARNING","调用了怪物自杀")
    --     end
    -- else
    --     DSCommonError.MonsterPosStatus.CurLiveTimes = DSCommonError.MonsterPosStatus.CurLiveTimes + BP_LocalPlayerAutoAgent2.DeltaTime
    -- end
end


--- log优先级分类(DEBUG\INFO\WARNING\ERROR)
function DSCommonError.tfPrint(type,...)
    if (type == 'DEBUG' and LogType.DEBUG) then
        print("[".. os.date("%Y.%m.%d-%X") .. "]" .. "[DSAutoTest LOG][DEBUG]" .. "[Pid:" .. DSAutoTestAgent.G_TokenPid .. "]" .." ->>>",...)
    elseif (type == 'INFO' and LogType.INFO) then
        print("[".. os.date("%Y.%m.%d-%X") .. "]" .. "[DSAutoTest LOG][INFO]" .. "[Pid:" .. DSAutoTestAgent.G_TokenPid .. "]" .." ->>>",...)
    elseif (type == 'WARNING' and LogType.WARNING) then
        print("[".. os.date("%Y.%m.%d-%X") .. "]" .. "[DSAutoTest LOG][WARNING]" .. "[Pid:" .. DSAutoTestAgent.G_TokenPid .. "]" .." ->>>",...)
    elseif (type == 'ERROR' and LogType.ERROR) then
        print("[".. os.date("%Y.%m.%d-%X") .. "]" .. "[DSAutoTest LOG][ERROR]" .. "[Pid:" .. DSAutoTestAgent.G_TokenPid .. "]" .." ->>>",...)
    end
end

function DSCommonError.tfPrintf(type,...)
    local param = {...}
    if (type == 'DEBUG' and LogType.DEBUG) then
        printf("[".. os.date("%Y.%m.%d-%X") .. "]" .. "[DSAutoTest LOG][DEBUG]" .. "[Pid:" .. DSAutoTestAgent.G_TokenPid .. "]" .." ->>>    " .. param[1],select(2,...))
    elseif (type == 'INFO' and LogType.INFO) then
        printf("[".. os.date("%Y.%m.%d-%X") .. "]" .. "[DSAutoTest LOG][INFO]" .. "[Pid:" .. DSAutoTestAgent.G_TokenPid .. "]" .." ->>>    " .. param[1],select(2,...))
    elseif (type == 'WARNING' and LogType.WARNING) then
        printf("[".. os.date("%Y.%m.%d-%X") .. "]" .. "[DSAutoTest LOG][WARNING]" .. "[Pid:" .. DSAutoTestAgent.G_TokenPid .. "]" .." ->>>    " .. param[1],select(2,...))
    elseif (type == 'ERROR' and LogType.ERROR) then
        printf("[".. os.date("%Y.%m.%d-%X") .. "]" .. "[DSAutoTest LOG][ERROR]" .. "[Pid:" .. DSAutoTestAgent.G_TokenPid .. "]" .." ->>>    " .. param[1],select(2,...))
    end
end


--- 断线问题处理
function DSCommonError.DealServerError()
    if DSAutoTestAgent and (DSAutoTestAgent.bIsServerError == 1) then
        DSCommonError.tfPrint("ERROR","===================DSCommonError DealServerError start===================")

        UE4.Timer.Add(5, function()
            DSAutoTestAgent.bIsServerError = 0
            if UI.IsOpen("Main") then PreviewScene.Enter(PreviewType.main) return end
            
            if not DSAutoTestAgent.bRunNullRhi then
                UI.CloseTop()
            end
            if (Map.GetCurrentID() ~= 2) then
                GoToMainLevel()
            else 
                local tbMap = Map.Class('MainMap')
                if tbMap then
                tbMap:OnlineEvent()
                end
            end
            DSCommonError.tfPrint("ERROR","===================DSCommonError DealServerError end===================")
        end)
    end
end

--- 断线重连
function DSCommonError.Reconnect()
    DSCommonError.tfPrint("ERROR","===================DSCommonError Reconnect ===================")
    me:Reconnect()
end

--- 重连超时，返回登录界面
function DSCommonError.GotoLoginLevel()
    me:Logout()
    GoToLoginLevel()
end

-- 断开连接处理
EventSystem.On(Event.ConnectBreaken, function(nReconnectCount)
    if DSAutoTestAgent.bOpenAutoAgent then
        DSCommonError.tfPrint("ERROR","===================DSCommonError ConnectBreaken !!!===================")
        DSCommonError.DealReconnect(nReconnectCount)
    end
end)

function DSCommonError.DealReconnect(nReconnectCount)
    if nReconnectCount < 3 then
        DSCommonError.tfPrint("ERROR","===================DSCommonError Reconnect !!!===================")
        UI.Close("MessageBox")
        DSCommonError.Reconnect()
    else
        DSCommonError.tfPrint("ERROR","===================DSCommonError GotoLoginLevel !!!===================")
        DSCommonError.GotoLoginLevel()
    end
end

