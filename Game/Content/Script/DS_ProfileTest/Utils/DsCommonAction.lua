-- ========================================================
-- @File    : DS_ProfileTest/Utils/DsCommonAction.lua
-- @Brief   : DS机器人行为类
-- ========================================================
require("DS_ProfileTest.DSAutoAgentConfig")
require("DS_ProfileTest.Utils.DsCommonError")
require("DS_ProfileTest.Utils.DsCommonfunc")
require("DS_ProfileTest.BP_LocalPlayerAutoAgent2")

DSCommonAction = DSCommonAction or {}

DSCommonAction.CurAttackTimes = 0
DSCommonAction.MaxAttackTimes = 1000
DSCommonAction.MaxAttackTimes2 = 1500

DSCommonAction.CurNoMoster = 0
DSCommonAction.MaxNoMoster = 500

DSCommonAction.posindex = {'north',0}

DSCommonAction.RandomPos = UE4.FVector()
DSCommonAction.IsInRandomPosing = false
DSCommonAction.RandomPosNotReachCount = 0
DSCommonAction.RandomPosNotReachMaxCount = 1000

DSCommonAction.IsUseingElevator = false
DSCommonAction.UseingElevatorCount = 0
DSCommonAction.UseingElevatorCountMax = 500

DSCommonAction.StopUseSkill = false
DSCommonAction.UseElevatorWaitCount = 0
DSCommonAction.UseSkillCount = 0
DSCommonAction.UseSkillMaxCount = 150
DSCommonAction.UseDodgeCount = 0
DSCommonAction.UseDodgeMaxCount = 160

DSCommonAction.isGotoAttackHighAltitudeEnemy = false

DSCommonAction.SwitchPlayerCount = 0
DSCommonAction.SwitchPlayerMaxCount = 5000
DSCommonAction.WaitTime = 0
DSCommonAction.BuyBuffAttemptCount = 3
DSCommonAction.BuyBuffDelay = 2 --购买buff商店每次等待时间

DSCommonAction.MaxDistanceOfStore = 20000 -- 商店最远距离
DSCommonAction.MaxComeToStoreTime = 40 -- 购买商店Buff最大耗时
DSCommonAction.CurrentComeToStoreTime = 0

DSCommonAction.SearchElevatorMaxTime = 5 -- 队长到达电梯控制台后寻找电梯的时间限制
DSCommonAction.SearchElevatorCurrentTime = 0

local CurGetRandomLocationTime = 0 -- 随机获取怪物附近导航点的间隙时间
local MaxGetRandomLocationTime = 1 --秒
local CurAttackLocation = UE4.FVector()

local elevatorOffsetDistance = 320

local directionOffset = 100
local initialDistance

local elevatorOffset = UE4.FVector()

local canMoveTo = nil
local currentMonster
local currentMonsterPos
local xProportion -- 这两个是自动战斗打高处怪用的
local yProportion
local attackHighAltitudeDestintaion = UE4.FVector()
local playerPosWithoutZ = UE4.FVector()
local monsterPosWithoutZ = UE4.FVector()

local CheckLocationMethodInitialLocation
local CheckLocationMethodInitialDestination
local CheckLocationMethodCurrentTime = 0

local GetAndMoveEndPathMaxTime = 3

local MoveToMonsterPos

---  战斗逻辑
--[[
1.针对普通怪物的战斗逻辑封装成一个函数:直接冲
2.针对有护盾的怪物战斗逻辑封装：远处将护盾打破再近身
3.针对BOSS战的战斗逻辑封装：远处攻击]]

--todo:攻击高于自己的敌人逻辑需要特殊处理:检测是否可射击，不可射击时需要切换位置找到可射击角度后停止移动进行攻击

function DSCommonAction.AutoBattle(monster,monsterType)
    if DSCommonAction.StopUseSkill == true then
        UE4.UDsProfileFunctionLib.StopMove()
        UE4.UDsProfileFunctionLib.CeaseFire()
        return
    end
    
    if IsValid(monster) then
        -- DSCommonError.tfPrint('DEBUG',"DSCommonAction.AutoBattle Inter!!")

        DSCommonAction.CurNoMoster = 0

        local monster_pos = monster:K2_GetActorLocation()
        -- UE4.UDsProfileFunctionLib.GetMonsterWeakPosition(monster,monster_pos)
        local NowHealth,MaxHealth,NowSheild,MaxSheild = DSCommonfunc.GetMonsterHealthAndSheild(monster)
        local player_x,player_y

        if DSCommonAction.IsInRandomPosing == true then
            DSCommonAction.RandomPosNotReachCount = DSCommonAction.RandomPosNotReachCount + 1
            UE4.UDsProfileFunctionLib.MoveTo(DSCommonAction.RandomPos.X,DSCommonAction.RandomPos.Y,DSCommonAction.RandomPos.Z)
            local playerPos = UE4.UDsProfileFunctionLib.GetPlayerLocation()
            local Distance = UE4.FVector.Dist(DSCommonAction.RandomPos,playerPos)
            if Distance < 120.0 or DSCommonAction.RandomPosNotReachCount > DSCommonAction.RandomPosNotReachMaxCount then
                DSCommonAction.IsInRandomPosing = false
            end
            return
        end

        local playerPos = UE4.UDsProfileFunctionLib.GetPlayerLocation()
        playerPosWithoutZ.X = playerPos.X
        playerPosWithoutZ.Y = playerPos.Y
        monsterPosWithoutZ.X = monster_pos.X
        monsterPosWithoutZ.Y = monster_pos.Y

        if not ((monster_pos.Z - playerPos.Z) > 200 and BP_LocalPlayerAutoAgent2.AGameTaskActor.AreaId ~=6 and UE4.FVector.Dist(playerPosWithoutZ,monsterPosWithoutZ) < 2000) then --如果不是高处怪物 就重置变量
            canMoveTo = nil
            currentMonsterPos = nil
            DSCommonAction.isGotoAttackHighAltitudeEnemy = false
        end
        MoveToMonsterPos = MoveToMonsterPos or function(monster,monster_pos)
            if CurGetRandomLocationTime > MaxGetRandomLocationTime then
                    for i = 1, 3 do
                        CurAttackLocation = UE4.UDsProfileFunctionLib.GetRandomReachablePointInRadiusByMonster(monster,400*i)
                        if  CurAttackLocation.X~=0 and  CurAttackLocation.Y~=0 and CurAttackLocation.Z~=0 then break end
                    end
                    if CurAttackLocation.X == 0 and CurAttackLocation.Y == 0 and CurAttackLocation.Z == 0 then
                        if DSCommonfunc.CheckMonsterIsAttackable(monster,NowHealth,NowSheild,5)==2 then
                            UE4.UDsProfileFunctionLib.GetAndMoveToLevelPathPainterEndPath(GetGameIns())
                            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(monster_pos.X,monster_pos.Y,monster_pos.Z)
                            UE4.UDsProfileFunctionLib.OpenFire()
                            DSCommonAction.UseSkill()
                            return
                        end
                    end
                    CurAttackLocation = DSCommonfunc.GetOffsetLocationWithDirection(UE4.FVector(monster_pos.X,monster_pos.Y,CurAttackLocation.Z),CurAttackLocation,800)
                    CurGetRandomLocationTime = 0
            end
            UE4.UDsProfileFunctionLib.MoveTo(CurAttackLocation.X,CurAttackLocation.Y,CurAttackLocation.Z)
        end

        --- BOSS
        if (monsterType == 1) then
            local portPos = UE4.TArray(UE4.FVector)
            UE4.UDsProfileFunctionLib.GetBossPartHurtPos(monster,portPos)
            local closestDist = 10000000.0
            for i = 1, portPos:Length() do
                local pos = portPos:Get(i)
                local dist = UE4.FVector.Dist(pos,playerPos)
                if dist < closestDist then
                    closestDist = dist
                    monster_pos = pos
                end
            end

            if CurGetRandomLocationTime > MaxGetRandomLocationTime then
                local Randompos = UE4.UDsProfileFunctionLib.GetRandomReachablePointInRadiusByMonster(monster,2000)
                UE4.UDsProfileFunctionLib.MoveTo(Randompos.X,Randompos.Y,Randompos.Z)
                CurGetRandomLocationTime = 0
            end
            -- UE4.UDsProfileFunctionLib.MoveTo(player_x,player_y,monster_pos.Z)
            DSCommonError.tfPrint("DEBUG","[tick flow]curr monster type:3")
        --- 高处怪物
        elseif (monster_pos.Z - playerPos.Z) > 200 and BP_LocalPlayerAutoAgent2.AGameTaskActor.AreaId ~=6 and UE4.FVector.Dist(playerPosWithoutZ,monsterPosWithoutZ) < 2000 then --路程太远的话也不视为高处怪物
            if canMoveTo == false and currentMonster == monster then
                if  UE4.FVector.Dist(attackHighAltitudeDestintaion,playerPos) > 100 then --如果玩家没到达目的地
                    UE4.UDsProfileFunctionLib.MoveTo(attackHighAltitudeDestintaion.X,attackHighAltitudeDestintaion.Y,attackHighAltitudeDestintaion.Z)
                end
            -- elseif not UE4.UDsProfileFunctionLib.IsAimTarget() then --已经到达目的地 还是瞄不到怪
            
            elseif currentMonster ~= monster then
                DSCommonAction.isGotoAttackHighAltitudeEnemy = true
                if currentMonsterPos == nil then
                    currentMonsterPos = monster_pos
                end
                canMoveTo = DSCommonAction.LocationValidCheckAndMove(playerPos,currentMonsterPos,300,8,BP_LocalPlayerAutoAgent2.DeltaTime)
                if canMoveTo ~= nil then --已经知道是否能够到达
                    currentMonster = monster
                    local height = monster_pos.Z - playerPos.Z
                    local width =  height*1.8 + UE4.FVector.Dist(UE4.FVector(monster_pos.X,monster_pos.Y,playerPos.Z),playerPos) --加的是玩家和怪的距离 
                    -- local width =  height*1.8
                    local x = math.abs(playerPos.X-monster_pos.X)
                    local y = math.abs(playerPos.Y-monster_pos.Y)
                    xProportion = x/(x+y)
                    yProportion = y/(x+y)
                    if playerPos.X>monster_pos.X then
                        attackHighAltitudeDestintaion.X = width*xProportion + playerPos.X
                    else
                        attackHighAltitudeDestintaion.X = -width*xProportion + playerPos.X
                    end

                    if playerPos.Y>monster_pos.Y then
                        attackHighAltitudeDestintaion.Y = width*yProportion + playerPos.Y
                    else
                        attackHighAltitudeDestintaion.Y = -width*yProportion + playerPos.Y
                    end
                    attackHighAltitudeDestintaion.Z = playerPos.Z
                    currentMonsterPos = nil
                end
            end
            DSCommonError.tfPrint("DEBUG","High Altitude Enemy!!")
            DSCommonError.tfPrint("DEBUG","[tick flow]curr monster type:4")
        elseif (MaxSheild==0) then
            -- player_x,player_y = DSCommonAction.GetAttackPos(monster_pos.X,monster_pos.Y,500)
            MoveToMonsterPos(monster,monster_pos)
            DSCommonError.tfPrint("DEBUG","[tick flow]curr monster type:1")
        --- 带护盾怪物
        elseif (MaxHealth<300000 and MaxSheild ~= 60000) then
            MoveToMonsterPos(monster,monster_pos)
            DSCommonError.tfPrint("DEBUG","[tick flow]curr monster type:2")
        end
        local Weak
        if monsterType == 0 then --小怪
            Weak = UE4.UDsProfileFunctionLib.GetMonsterWeakPosition(monster)
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(Weak.X,Weak.Y,Weak.Z)
            -- UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(monster_pos.X,monster_pos.Y,monster_pos.Z)
        elseif monsterType == 1 then --boss
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(monster_pos.X,monster_pos.Y,monster_pos.Z)
        elseif monsterType == 2 then -- 建筑物
            local targetLocation = UE4.UDsProfileFunctionLib.GetDestroyTargetCoreLocation(monster)
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(targetLocation.X,targetLocation.Y,targetLocation.Z)
        end
        
        DSCommonError.tfPrint("DEBUG","[tick flow]OpenFire")
        UE4.UDsProfileFunctionLib.OpenFire()
        if (UE4.UDsProfileFunctionLib.IsAimTarget()) then
            -- if DSCommonAction.CurAttackTimes > DSCommonAction.MaxAttackTimes then
            --     UE4.UDsProfileFunctionLib.StopMove()
            -- end
            DSCommonAction.CurAttackTimes = 0
            DSCommonError.tfPrint("DEBUG","DSCommonAction.CurAttackTimes = 0")
        else
            DSCommonAction.CurAttackTimes = DSCommonAction.CurAttackTimes + 1
            if math.fmod(DSCommonAction.CurAttackTimes,100) == 0 then
                DSCommonError.tfPrint("INFO","DSCommonAction.CurAttackTimes = ",DSCommonAction.CurAttackTimes)
            end
        end

        -- 没有可瞄准的怪物
        
        if (DSCommonAction.CurAttackTimes > DSCommonAction.MaxAttackTimes2) and (UE4.FVector.Dist(monster_pos,playerPos) < 1500.0) then
            local RandomPos = UE4.UDsProfileFunctionLib.GetAndMoveToLevelPathPainterEndPath(GetGameIns())
            -- local RandomPos = UE4.UDsProfileFunctionLib.GetRandomReachablePointInRadiusByPlayer(1500)
            UE4.UDsProfileFunctionLib.MoveTo(RandomPos.X,RandomPos.Y,RandomPos.Z)
            DSCommonfunc.RegularPrint("ERROR","DSCommonAction:Not IsAimTarget,Try to Change Position222!!",2,BP_LocalPlayerAutoAgent2.DeltaTime)
            DSCommonAction.IsInRandomPosing = true
            DSCommonAction.RandomPos = RandomPos
        -- elseif DSCommonAction.CurAttackTimes > DSCommonAction.MaxAttackTimes then
        --     player_x,player_y = DSCommonAction.GetAttackPos(monster_pos.X,monster_pos.Y,1600)
        --     UE4.UDsProfileFunctionLib.MoveTo(player_x,player_y,monster_pos.Z)
        --     DSCommonError.tfPrint("ERROR","DSCommonAction:Not IsAimTarget,Try to Change Position!!")
        --     DSCommonAction.IsInRandomPosing = true
        --     DSCommonAction.RandomPos = UE4.FVector(player_x,player_y,monster_pos.Z)
        end

        -- 适时闪避
        local dist = UE4.FVector.Dist(monster_pos,playerPos)
        if dist < 600 then
            DSCommonAction.UseDodge()
        end

        DSCommonAction.SwitchRandPlayer()
    else
        DSCommonError.tfPrint("WARNING","DSCommonAction.AutoBattle monster is not Valid!!")

        --todo:长时间找不到怪物时，需要通过玩家坐标系判断当前玩家所在的区域，然后推导出玩家进行到什么任务阶段，进而继续任务

        -- DSCommonAction.CurNoMoster = DSCommonAction.CurNoMoster + 1
        -- if DSCommonAction.CurNoMoster >= DSCommonAction.MaxNoMoster then
        --     DSCommonfunc.movetime = DSCommonfunc.movetime + 1
        --     DSCommonAction.CurNoMoster = 0
        -- end

        DSCommonAction.CurNoMoster = DSCommonAction.CurNoMoster + 1
        if DSCommonAction.CurNoMoster >= DSCommonAction.MaxNoMoster and DSCommonError.PlayerUnusualPosStatus.IsInRandomPosing ~= true then
            UE4.UDsProfileFunctionLib.GetAndMoveToLevelPathPainterEndPath(GetGameIns())
            DSCommonAction.CurNoMoster = 0
        end
    end
    CurGetRandomLocationTime = CurGetRandomLocationTime + BP_LocalPlayerAutoAgent2.DeltaTime
end

function DSCommonAction.GetAttackPos(x,y,n)
    if (DSCommonAction.posindex[1]=='north' and DSCommonAction.posindex[2] < 20) then
        -- DSCommonAction.posindex = 'east'
        DSCommonAction.posindex[2] = DSCommonAction.posindex[2] + 1
        if DSCommonAction.posindex[2] == 20 then
            DSCommonAction.posindex[1] = 'east'
            DSCommonAction.posindex[2] = 0
        end
        return x+n,y
    elseif (DSCommonAction.posindex[1]=='east' and DSCommonAction.posindex[2] < 20) then
        -- DSCommonAction.posindex = 'south'
        DSCommonAction.posindex[2] = DSCommonAction.posindex[2] + 1
        if DSCommonAction.posindex[2] == 20 then
            DSCommonAction.posindex[1] = 'south'
            DSCommonAction.posindex[2] = 0
        end
        return x-n,y
    elseif (DSCommonAction.posindex[1]=='south' and DSCommonAction.posindex[2] < 20) then
        -- DSCommonAction.posindex = 'west'
        DSCommonAction.posindex[2] = DSCommonAction.posindex[2] + 1
        if DSCommonAction.posindex[2] == 20 then
            DSCommonAction.posindex[1] = 'west'
            DSCommonAction.posindex[2] = 0
        end
        return x,y-n
    elseif (DSCommonAction.posindex[1]=='west' and DSCommonAction.posindex[2] < 20) then
        -- DSCommonAction.posindex='north'
        DSCommonAction.posindex[2] = DSCommonAction.posindex[2] + 1
        if DSCommonAction.posindex[2] == 20 then
            DSCommonAction.posindex[1] = 'north'
            DSCommonAction.posindex[2] = 0
        end
        return x,y+n
    end
end

local function IsHaveValidInteractItem()
    if #DSCommonfunc.InteractList == 0 then
        return false
    end

    for i = 1, #DSCommonfunc.InteractList do
        if IsValid(DSCommonfunc.InteractList[i]) then
            return true
        end
    end
    return false
end

local function UseElevatorInteract()
    local InteractItem
    -- local InteractItem_Pos = UE4.FVector()
    DSCommonError.tfPrintf("INFO","DSCommonfunc.InteractList Length:%d",#DSCommonfunc.InteractList)
    for i = 1, #DSCommonfunc.InteractList do
        InteractItem = DSCommonfunc.InteractList[i]
        if not IsValid(InteractItem) then
            DSCommonError.tfPrint("WARNING","inValid InteractItem")
           goto continue
        end
        -- InteractItem_Pos = DSCommonfunc.GetActorLocation(InteractItem)
        -- if (UE4.FVector.Dist(InteractItem_Pos,elevator_pos) < 30.0 ) then
            DSCommonfunc.UseInteract(InteractItem)
            DSCommonAction.StopUseSkill = true
            UE4.Timer.Add(15.0, function()
                DSCommonAction.StopUseSkill = false
            end)
        -- end
        ::continue::
    end
end

-- 使用无法导航到达的电梯
---@param elevator_pos FVector 电梯控制台坐标
---@param elevator_area table 电梯平台区域
---@param elevatorentry_pos FVector 电梯入口坐标
function DSCommonAction.AutoUseElevator(elevator_pos,elevator_area,elevatorentry_pos,offset)
    if DSCommonError.PlayerUnusualPosStatus.IsInRandomPosing == true then
        return
    end

    -- DsAutoMulti1.OperationHoldTime = 0
    -- 判断玩家是否走到电梯口
    
    local playerPos = UE4.UDsProfileFunctionLib.GetPlayerLocation()

    -- 判断玩家不在电梯内
    if not DSCommonfunc.CheckPosition(playerPos,elevator_area) then
        DSCommonfunc.InteractCount = 0.01
        DSCommonError.tfPrint("DEBUG","====== DSCommonAction.AutoUseElevator not in area!! =====")
        local Distance = UE4.FVector.Dist(elevatorentry_pos,playerPos)
        if Distance < 200.0 then --如果已经到达电梯门口
            UE4.UDsProfileFunctionLib.StopMove()
            if not BP_LocalPlayerAutoAgent2.IsCaptain then --不是队长就靠一边去
                -- 不想重新实例化一个FVector,直接赋值的话又是拿的指针
                elevatorOffset.X = elevator_pos.X
                elevatorOffset.Y = elevator_pos.Y
                elevatorOffset.Z = elevator_pos.Z
                if offset==1 then
                    elevatorOffset.X = elevatorOffset.X+elevatorOffsetDistance
                elseif offset==2 then
                    elevatorOffset.X = elevatorOffset.X-elevatorOffsetDistance
                elseif offset==3 then
                    elevatorOffset.Y = elevatorOffset.Y+elevatorOffsetDistance
                elseif offset==4 then
                    elevatorOffset.Y = elevatorOffset.Y-elevatorOffsetDistance
                else
                    DSCommonError.tfPrint("DEBUG","ERRRO:DSCommonAction.AutoUseElevator  ERROR INPUT！")
                    return
                end
                UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(elevatorOffset.X,elevatorOffset.Y,elevatorOffset.Z + 50)
                if UE4.FVector.Dist(playerPos,elevatorOffset) < 150 then
                    UE4.UDsProfileFunctionLib.StopMoveInput()
                else
                    UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
                    UE4.UDsProfileFunctionLib.UseDodgeSkill()
                    DSCommonAction.SwitchRandPlayer()
                end
            else --队长直接去控制台
                UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(elevator_pos.X,elevator_pos.Y,elevator_pos.Z + 50)
                UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
                UE4.UDsProfileFunctionLib.UseDodgeSkill()
                DSCommonAction.SwitchRandPlayer()
            end
            DSCommonError.tfPrint("DEBUG","====== DSCommonAction.AutoUseElevator not in area PlayerController:MoveForward(1)!! =====")
        else
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.StopAim()
            UE4.UDsProfileFunctionLib.MoveTo(elevatorentry_pos.X,elevatorentry_pos.Y,elevatorentry_pos.Z)
            DSCommonError.tfPrint("DEBUG","====== DSCommonAction.AutoUseElevator not in area MoveTo elevatorentry_pos!! =====")
        end
    elseif BP_LocalPlayerAutoAgent2.IsCaptain then -- 如果是队长，直接去电梯控制台
        -- body
        DSCommonError.tfPrint("DEBUG","====== DSCommonAction.AutoUseElevator is in area!! =====")
        --在电梯内
        local Distance = UE4.FVector.Dist(elevator_pos,playerPos)
        if Distance < 200.0 then
            UE4.UDsProfileFunctionLib.CeaseFire()
            --使用电梯
            if #DSCommonfunc.InteractList == 0 then -- 如果没有电梯(卡了)，就走开再回来
                if DSCommonAction.SearchElevatorCurrentTime > DSCommonAction.SearchElevatorMaxTime then
                    DSCommonAction.SearchElevatorCurrentTime = 0
                    UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(elevatorentry_pos.X,elevatorentry_pos.Y,elevatorentry_pos.Z+50)
                    UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
                else
                    DSCommonAction.SearchElevatorCurrentTime = DSCommonAction.SearchElevatorCurrentTime + BP_LocalPlayerAutoAgent2.DeltaTime
                end
            elseif IsHaveValidInteractItem() then
                if #DSCommonfunc.InteractList ~= 0 then
                    UE4.UDsProfileFunctionLib.StopMoveInput() --相较于moveto，StartMoveInput还需要自己手动停一下
                end
                if DSCommonfunc.CheckAllPlayerPosition(elevator_area,2) then
                    DSCommonAction.SearchElevatorCurrentTime = 0
                    UseElevatorInteract()
                    UE4.UDsProfileFunctionLib.StopAim()
                else
                    DSCommonfunc.RegularPrint("INFO","Wait members enter elevator",2,BP_LocalPlayerAutoAgent2.DeltaTime)
                end
            end
        else
            if UE4.FVector.Dist(playerPos,elevator_pos) < 200 then
                UE4.UDsProfileFunctionLib.StopMoveInput()
            else
                UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(elevator_pos.X,elevator_pos.Y,elevator_pos.Z + 50)
                UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
                DSCommonAction.SwitchRandPlayer()
            end
        end
    else
        if UE4.FVector.Dist(playerPos,elevatorOffset) < 150 then
            UE4.UDsProfileFunctionLib.StopMoveInput()
            if not DSCommonfunc.CheckAllPlayerPosition(elevator_area,2) then
                DSCommonfunc.RegularPrint("INFO","Wait members enter elevator",2,BP_LocalPlayerAutoAgent2.DeltaTime)
            end
        else
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
        end
        
    end
end

--使用有导航的电梯
function DSCommonAction.UseReachedElevator(elevator_pos,elevator_area,elevatorentry_pos,offset)
    
    UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(elevator_pos.X,elevator_pos.Y,elevator_pos.Z + 120.0)
    local playerPos = UE4.UDsProfileFunctionLib.GetPlayerLocation()

    --判断是否走到电梯边
    local Distance = UE4.FVector.Dist(elevator_pos,playerPos)

    if not BP_LocalPlayerAutoAgent2.IsCaptain then
        elevatorOffset.X = elevator_pos.X
        elevatorOffset.Y = elevator_pos.Y
        elevatorOffset.Z = elevator_pos.Z
        if offset==1 then
            elevatorOffset.X = elevatorOffset.X+elevatorOffsetDistance-100
        elseif offset==2 then
            elevatorOffset.X = elevatorOffset.X-elevatorOffsetDistance-100
        elseif offset==3 then
            elevatorOffset.Y = elevatorOffset.Y+elevatorOffsetDistance-100
        elseif offset==4 then
            elevatorOffset.Y = elevatorOffset.Y-elevatorOffsetDistance-100
        else
            DSCommonError.tfPrint("DEBUG","ERRRO:DSCommonAction.AutoUseElevator  ERROR INPUT！")
            return
        end
        if UE4.FVector.Dist(elevatorOffset,playerPos)>100 then
            UE4.UDsProfileFunctionLib.MoveTo(elevatorOffset.X,elevatorOffset.Y,elevatorOffset.Z)
        elseif not DSCommonfunc.CheckAllPlayerPosition(elevator_area,2) then
            DSCommonfunc.RegularPrint("INFO","Wait members enter elevator",2,BP_LocalPlayerAutoAgent2.DeltaTime)
        end
    
    else
        if Distance < 240.0 then
            UE4.UDsProfileFunctionLib.CeaseFire()
        --使用电梯
            if #DSCommonfunc.InteractList == 0  then -- 如果没有电梯(卡了)，就走开再回来
                if DSCommonAction.SearchElevatorCurrentTime > DSCommonAction.SearchElevatorMaxTime then
                    DSCommonAction.SearchElevatorCurrentTime = 0
                    UE4.UDsProfileFunctionLib.MoveTo(elevatorentry_pos.X,elevatorentry_pos.Y,elevatorentry_pos.Z)
                else
                    DSCommonAction.SearchElevatorCurrentTime = DSCommonAction.SearchElevatorCurrentTime+BP_LocalPlayerAutoAgent2.DeltaTime
                end
            elseif IsHaveValidInteractItem() and DSCommonfunc.CheckAllPlayerPosition(elevator_area,2) then
                DSCommonAction.SearchElevatorCurrentTime = 0
                UE4.UDsProfileFunctionLib.StopMove()
                UseElevatorInteract()
                UE4.UDsProfileFunctionLib.StopAim()
                return true
            else
                DSCommonfunc.RegularPrint("INFO","Wait members enter elevator",2,BP_LocalPlayerAutoAgent2.DeltaTime)
            end
        else
            UE4.UDsProfileFunctionLib.MoveTo(elevator_pos.X,elevator_pos.Y,elevator_pos.Z)
        end
    end
    
    
    
end

--检测身边是否有电梯并使用
function DSCommonAction.UseNearlyElevator()
    if DSCommonAction.StopUseSkill and DSCommonAction.UseElevatorWaitCount < 150 then
        DSCommonAction.UseElevatorWaitCount = DSCommonAction.UseElevatorWaitCount + 1
        return
    end

    if #DSCommonfunc.InteractList == 0 then
        DSCommonAction.UseingElevatorCount = 0
        DSCommonAction.IsUseingElevator = false
        DSCommonAction.StopUseSkill = false
    end

    if DSCommonAction.IsUseingElevator == false and #DSCommonfunc.InteractList ~= 0 then
        DSCommonAction.IsUseingElevator = true
        local InteractItem
        for i = 1, #DSCommonfunc.InteractList do
            InteractItem = DSCommonfunc.InteractList[i]
            DSCommonfunc.UseInteract(InteractItem)
            DSCommonAction.StopUseSkill = true
            DSCommonAction.UseElevatorWaitCount = 0
        end
    elseif #DSCommonfunc.InteractList ~= 0 then
        DSCommonAction.UseingElevatorCount = DSCommonAction.UseingElevatorCount + 1
        DSCommonError.tfPrint("INFO","====== DSCommonAction.UseingElevatorCount =" ,DSCommonAction.UseingElevatorCount)
    end

    if DSCommonAction.UseingElevatorCount > DSCommonAction.UseingElevatorCountMax then
        DSCommonAction.UseingElevatorCount = 0
        DSCommonAction.IsUseingElevator = false
    end
end

-- 获取最近的怪物 0是小怪 1是boss 2是建筑物
function DSCommonAction.GetClosedMonster()
    local mosterlist = UE4.TArray(UE4.AActor)
    UE4.UDsProfileFunctionLib.GetMonsterList(GetGameIns(),mosterlist)
    DSCommonError.tfPrint('DEBUG',string.format("DSCommonAction:GetClosedMonster mosterlist:Length() = %d",mosterlist:Length()))
    local monster
    local closed_monster
    if (mosterlist:Length() ~= 0) then
        local Distance = -1
        for i = 1, mosterlist:Length() do
            monster = mosterlist:Get(i)
            -- if monster.__name=="ABP_Mon_906_C" then
            --     goto continue
            -- end
            local monster_pos = DSCommonfunc.GetActorLocation(monster)
            local playerPos = UE4.UDsProfileFunctionLib.GetPlayerLocation()
            local curDist = UE4.FVector.Dist(monster_pos,playerPos)
            if Distance == -1 and i == 1 then
                Distance = curDist
                closed_monster = monster
            elseif Distance > curDist then
                closed_monster = monster
                Distance = curDist
            end
            -- ::continue::
        end
    else
        local bosspart = UE4.UDsProfileFunctionLib.GetClosedBossPart()
        closed_monster = bosspart
        if closed_monster~=nil then
            return closed_monster,1
        else -- 如果怪物无效 检测是否有建筑物
            local Targetlist = UE4.TArray(UE4.AActor)
            UE4.UDsProfileFunctionLib.GetDestroyTargetList(Targetlist)
            if Targetlist:Length()>0 then
                local DestroyTarget
                for i = 1, Targetlist:Length() do
                    DestroyTarget = Targetlist:Get(i)
                    if DSCommonfunc.GetDestroyTargetCoreCurHp(DestroyTarget) > 0 then
                        closed_monster = DestroyTarget
                        return closed_monster,2
                    end
                end
            end
        end
    end
    return closed_monster,0
end

--释放技能
function DSCommonAction.UseSkill()
    if DSCommonAction.StopUseSkill == true or #DSCommonfunc.InteractList ~= 0 then
        return
    end

    if DSCommonAction.UseSkillCount < DSCommonAction.UseSkillMaxCount then
        DSCommonAction.UseSkillCount = DSCommonAction.UseSkillCount + 1
        return
    
    else
        DSCommonAction.UseSkillCount = 0
    end

    local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    if IsValid(PlayerController) then
        PlayerController:UseSkill(1, UE4.ESkillCastType.Press)
        PlayerController:UseSkill(1, UE4.ESkillCastType.Release)
        PlayerController:UseSkill(2, UE4.ESkillCastType.Press)
        PlayerController:UseSkill(2, UE4.ESkillCastType.Release)
        PlayerController:UseSkill(4, UE4.ESkillCastType.Press)
        PlayerController:UseSkill(4, UE4.ESkillCastType.Release)

        --释放QTE技能
        -- PlayerController:SwitchNextPlayerCharacter(false, false, true)
        -- PlayerController:SwitchPrePlayerCharacter(true)
        local index = math.random(0, 2)
        PlayerController:QTESwitchPlayerCharacter(index)

        -- 重新设置无敌 TODO:调用频繁，待项目组修改无敌失效BUG后观察
        -- if PlayerController:GetPlayerCharacters() then
        --     local GMPlayerCharacters=PlayerController:GetPlayerCharacters():ToTable()
        --     for index, value in ipairs(GMPlayerCharacters) do
        --         -- local Location=UE4.FVector(0,0,0)
        --         -- UE4.UModifier.MakeModifier(3301001,value.Ability,value.Ability,value.Ability,nil,Location,Location)
        --         PlayerController:Server_DebugAddModifier(3301001,value,value)
        --         UE4.Timer.Add(6, function()
        --             PlayerController:Server_DebugAddModifier(3301001,value,value)
        --         end);
        --     end
        -- end
    end
    
end

-- 如果有离的很近的怪物，则优先击杀
function DSCommonAction.ShootClosedMonster(monster)
    if IsValid(monster) then
        local monster_pos = monster:K2_GetActorLocation()
        local playerPos = UE4.UDsProfileFunctionLib.GetPlayerLocation()
        local Distance = UE4.FVector.Dist(DSCommonAction.RandomPos,playerPos)
        if Distance < 200 then
            local Weak = UE.FVector()
            UE4.UDsProfileFunctionLib.GetMonsterWeakPosition(monster,Weak)
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(Weak.X,Weak.Y,Weak.Z)
            if (UE4.UDsProfileFunctionLib.IsAimTarget()) then
                UE4.UDsProfileFunctionLib.OpenFire()
            end
        end
    end
end

-- 初始化数据
function DSCommonAction.Init()
    DSCommonAction.RandomPos = UE4.FVector()
    DSCommonAction.IsInRandomPosing = false
    DSCommonAction.RandomPosNotReachCount = 0

    DSCommonAction.IsUseingElevator = false
    DSCommonAction.UseingElevatorCount = 0
    
    DSCommonAction.StopUseSkill = false
    DSCommonAction.UseElevatorWaitCount = 0

    DSCommonAction.UseSkillCount = 0
    DSCommonAction.UseDodgeCount = 0

    DSCommonAction.SwitchPlayerCount = 0
    DSCommonAction.BuyBuffAttemptCount = 3

    currentMonster = nil
    currentMonsterPos = nil
    
end

--设置间隔
function DSCommonAction.SetMaxAttackTimes2(internal)
    DSCommonAction.MaxAttackTimes2 = internal
end

-- 使用闪避技能
function DSCommonAction.UseDodge()
    if DSCommonAction.StopUseSkill == true or #DSCommonfunc.InteractList ~= 0 then
        return
    end

    if DSCommonAction.UseDodgeCount < DSCommonAction.UseDodgeMaxCount then
        DSCommonAction.UseDodgeCount = DSCommonAction.UseDodgeCount + 1
        return
    
    else
        DSCommonAction.UseDodgeCount = 0
    end

    local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    if IsValid(PlayerController) then
        local dodgeforward = math.random(1,4)
        if dodgeforward == 1 then
            PlayerController:MoveRight(1)
        elseif dodgeforward == 2 then
            PlayerController:MoveRight(-1)
        elseif dodgeforward == 3 then
            PlayerController:MoveForward(-1)
        end
        
        if dodgeforward <= 3 and dodgeforward >= 1 then
            UE4.UDsProfileFunctionLib.UseDodgeSkill()
        end
    end
end

-- 随机切换角色
function DSCommonAction.SwitchRandPlayer()
    if DSCommonAction.StopUseSkill == true or #DSCommonfunc.InteractList ~= 0 then
        return
    end

    if DSCommonAction.SwitchPlayerCount < DSCommonAction.SwitchPlayerMaxCount then
        DSCommonAction.SwitchPlayerCount = DSCommonAction.SwitchPlayerCount + 1
        return
    
    else
        DSCommonAction.SwitchPlayerCount = 0
    end

    UE4.UDsProfileFunctionLib.SwitchRandomPlayerCharacter()
end


--获取一个离玩家最近的开放中的商店
-- function DSCommonAction.GetOpenStore(playerLocation)
--     local BuffShopList = UE4.UDsProfileFunctionLib.GetBuffShopList()
--     if UE4.UDsProfileFunctionLib.GetBuffShopList():Length() == 0 then --若没有buff商店，则直接退出
--         return nil
--     end
--     local store = nil
--     local minDistance = DSCommonAction.MaxDistanceOfStore
--     for i = 1, BuffShopList:Length(), 1 do
--         local disance = UE4.FVector.Dist(playerLocation,BuffShopList:Get(i):GetTransform().Translation)
--         if UE4.UDsProfileFunctionLib.GetBuffShopState(BuffShopList:Get(i)) == 1 and disance < minDistance then
--             minDistance = disance
--             store = BuffShopList:Get(i)
--         end
--     end
--     return store
-- end

--获取一个离玩家最近的开放中的商店(无视掉线导致的重新开放商店)
function DSCommonAction.GetOpenStoreInfo(playerLocation)
    local storeInfo = nil
    local minDistance = DSCommonAction.MaxDistanceOfStore
    -- local storeList = UE4.UDsProfileFunctionLib.GetBuffShopList()
    local unOpenedStoreStatusList = {}
    for i = 1, #DSCommonfunc.StoreInfoDic do
        if DSCommonfunc.StoreInfoDic[i].opened == false then
            table.insert(unOpenedStoreStatusList,DSCommonfunc.StoreInfoDic[i])
        end
    end

    for i = 1, #unOpenedStoreStatusList do
        if not IsValid(unOpenedStoreStatusList[i].store) then
            goto continue
        end
        local distance = UE4.FVector.Dist(playerLocation,unOpenedStoreStatusList[i].store:GetTransform().Translation)
        if UE4.UDsProfileFunctionLib.GetBuffShopState(unOpenedStoreStatusList[i].store) == 1 and distance < minDistance then
            minDistance = distance
            storeInfo = unOpenedStoreStatusList[i]
        end
        ::continue::
    end
    return storeInfo
end

-- 前往一个离玩家最近的开放的buff商店，并购买
function DSCommonAction.ComeToNearestBuffStore(playerLocation)
    local storeInfo = DSCommonAction.GetOpenStoreInfo(playerLocation)
    if not storeInfo then return false end
    local Store = storeInfo.store
    -- local Store= UE4.UDsProfileFunctionLib.GetClosedBuffShopObj()
    if Store ~= nil and UE4.FVector.Dist(Store:GetTransform().Translation,playerLocation) > DSCommonAction.MaxDistanceOfStore  then--在最远距离外
        DSCommonError.tfPrint("ERROR","Store too far")
        UE4.UDsProfileFunctionLib.SetBuffShopState(UE4.EBufferShopStateEnum.Complete,Store) -- 将商店状态设置为售罄
        storeInfo.opened = true
        return false
    end
    if not IsValid(Store) or UE4.UDsProfileFunctionLib.GetBuffShopState(Store) ~= 1 then --没有商店或商店未开启
        return false
    end
    local offset
    if string.find(Store:GetName(),"Reward") then --箱子型
        offset = Store:GetTransform().Rotation:GetForwardVector() * 100 --获取商店向前的坐标 *100是为了增加一米的距离 正常箱子不会乱摆，只有商店才会反着摆
    else -- 商店型
        offset = Store:GetTransform().Rotation:GetRightVector() * directionOffset
    end
    offset = offset + Store:GetTransform().Translation
    UE4.UDsProfileFunctionLib.MoveTo(offset.x,offset.y,offset.z)
    local dist = UE4.FVector.Dist(playerLocation,offset)
    if dist<270 then
        DSCommonAction.WaitTime = DSCommonAction.WaitTime + BP_LocalPlayerAutoAgent2.DeltaTime
        DSCommonAction.CurrentComeToStoreTime = 0
        if DSCommonAction.WaitTime > DSCommonAction.BuyBuffDelay then
            DSCommonAction.WaitTime = 0
            if DSCommonAction.BuyBuffAttemptCount > 0 then
                DSCommonAction.BuyBuffAttemptCount = DSCommonAction.BuyBuffAttemptCount - 1
                local isSuccess = UE4.UDsProfileFunctionLib.BuyRandomBuffFromShop(Store) --购买buff
                if isSuccess then
                    UE4.UDsProfileFunctionLib.SetBuffShopState(UE4.EBufferShopStateEnum.Complete,Store) -- 将商店状态设置为售罄
                    storeInfo.opened = true
                    DSCommonAction.BuyBuffAttemptCount = 3
                    directionOffset = math.abs(directionOffset) --重置偏移量为正数
                    DSCommonError.tfPrint("INFO","Buy buff success")
                    return false
                end
                if DSCommonAction.BuyBuffAttemptCount > 0 then  -- 如果还有重试次数
                    DSCommonError.tfPrint("WARNING","Retry BuyBuff")
                end
                else -- 重试机会用完
                    UE4.UDsProfileFunctionLib.SetBuffShopState(UE4.EBufferShopStateEnum.Complete,Store) -- 将商店状态设置为售罄
                    storeInfo.opened = true
                    DSCommonAction.BuyBuffAttemptCount = 3
                    DSCommonError.tfPrint("WARNING","Abandon this store")
                    directionOffset = math.abs(directionOffset) --重置偏移量为正数
            end
        end
    else
        if DSCommonAction.CurrentComeToStoreTime == 0 then
            DSCommonError.tfPrint("INFO","Go to buffStore")
        elseif DSCommonAction.CurrentComeToStoreTime == 2 then --储存离商店的距离，不用0是因为角色可能还在移动
            initialDistance = dist
        elseif DSCommonAction.CurrentComeToStoreTime == 4 and initialDistance == dist then -- 距离没有变化
            directionOffset = directionOffset * -1 --反转偏移量
        end
    end
    if DSCommonAction.CurrentComeToStoreTime > DSCommonAction.MaxComeToStoreTime then -- 超时
        UE4.UDsProfileFunctionLib.SetBuffShopState(UE4.EBufferShopStateEnum.Complete,Store)
        storeInfo.opened = true
        DSCommonError.tfPrint("WARNING","Time out for Come to Store")
        DSCommonAction.CurrentComeToStoreTime = 0
        return false
    end
     --保证DSCommonAction.CurrentComeToStoreTime到达过2和4
    if DSCommonAction.CurrentComeToStoreTime< 2 and DSCommonAction.CurrentComeToStoreTime + BP_LocalPlayerAutoAgent2.DeltaTime > 2 then
        DSCommonAction.CurrentComeToStoreTime = 2
    elseif DSCommonAction.CurrentComeToStoreTime< 4 and DSCommonAction.CurrentComeToStoreTime + BP_LocalPlayerAutoAgent2.DeltaTime > 4 then
        DSCommonAction.CurrentComeToStoreTime = 4
    else
        DSCommonAction.CurrentComeToStoreTime = DSCommonAction.CurrentComeToStoreTime + BP_LocalPlayerAutoAgent2.DeltaTime
    end
    return true
end

-- 去救嗝屁了的队友
function DSCommonAction.RescuePartner(playerLocation,monster)
    local deadLocation = UE4.FVector()
    local distance
    if UE4.UDsProfileFunctionLib.IsHasTombstoneWithLocation(deadLocation) then
        if monster ~= nil then
            local weak = UE4.FVector()
            local monster_pos = UE4.UDsProfileFunctionLib.GetMonsterWeakPosition(monster,weak)
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(monster_pos.X,monster_pos.Y,monster_pos.Z)
            UE4.UDsProfileFunctionLib.OpenFire()
        end
        distance = UE4.FVector.Dist(playerLocation,deadLocation)
        if distance > 200 then
            return DSCommonAction.LocationValidCheckAndMove(playerLocation,deadLocation,200,6,BP_LocalPlayerAutoAgent2.DeltaTime)
        else
            return true
        end
    else
        return false
    end 
end

--尝试使用导航系统前往指定地点
--注意 该方法不是线程安全的
---@param elevator_pos playerLocation 玩家坐标
---@param elevator_area destination 目的地坐标
---@param elevatorentry_pos distance 移动多少米算和距离多少米成功
---@param elevatorentry_pos deadline 时限 秒
---@param elevatorentry_pos deltaTime 增量时间
function DSCommonAction.LocationValidCheckAndMove(playerLocation,destination,distance,deadline,deltaTime)
    if CheckLocationMethodInitialDestination ~= destination then -- 如果目的地变了
        CheckLocationMethodCurrentTime = 0
    end
    if CheckLocationMethodCurrentTime == 0 then
        CheckLocationMethodInitialLocation = playerLocation -- 保存玩家最初的位置
        CheckLocationMethodInitialDestination = destination -- 保存目的地 免得后面你有两个不同的地方想去
    end

    CheckLocationMethodCurrentTime = CheckLocationMethodCurrentTime + deltaTime
    UE4.UDsProfileFunctionLib.MoveTo(destination.X,destination.Y,destination.Z)
    -- if UE4.FVector.Dist(playerLocation,CheckLocationMethodInitialLocation) > distance or UE4.FVector.Dist(playerLocation,destination) < distance then -- 检测玩家当前位置和最初位置距离是否超过2米 或 和已经到达目的地
    if UE4.FVector.Dist(playerLocation,destination) < distance then -- 检测玩家是否已经到达目的地 不检测移动距离
        CheckLocationMethodCurrentTime = 0
        return true
    end
    if CheckLocationMethodCurrentTime > deadline then
        CheckLocationMethodCurrentTime = 0
        return false -- 超时
    else
        return nil -- 还没超时 不确定是否能到达
    end
end



function DSCommonAction.DelayGetAndMoveToLevelPathPainterEndPath()
    if GetAndMoveEndPathMaxTime > 0 then
        GetAndMoveEndPathMaxTime = GetAndMoveEndPathMaxTime - BP_LocalPlayerAutoAgent2.DeltaTime
    else
        UE4.UDsProfileFunctionLib.GetAndMoveToLevelPathPainterEndPath(GetGameIns())
        GetAndMoveEndPathMaxTime = 3
    end
end