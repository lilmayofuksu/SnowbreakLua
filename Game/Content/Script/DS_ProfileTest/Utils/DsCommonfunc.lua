-- ========================================================
-- @File    : DS_ProfileTest/Utils/DsCommonfunc.lua
-- @Brief   : DS机器人通用逻辑
-- ========================================================

DSCommonfunc = DSCommonfunc or {}

-- 当前操作执行的最长时间
DSCommonfunc.OperationHoldTime = 0.02
-- 当前操作计时
DSCommonfunc.OperationTimeCount = 0

-- 关卡总时长
DSCommonfunc.LevelCountDownTotalTime = 0

-- 可交互对象列表
DSCommonfunc.InteractList = {}

-- 区域计数
DSCommonfunc.movetime = 0
-- 区域目标
DSCommonfunc.ExecuteDes = {}

-- 交互次数
DSCommonfunc.InteractCount = 0

-- beginplay绑定列表
DSCommonfunc.BeginPlayList = {}

DSCommonfunc.AllComplete = false
DSCommonfunc.currentMapIdIndex = 1 
DSCommonfunc.MapIdList = {
    110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,130,131,132,133,134,135,136,137,138,140,141,142,143,144,145,146,147,148,149,150,151,152,153,160,161,162,163,164,165,166,167,170,171,172
}
DSCommonfunc.StoreInfoDic = {}

local DelayPrintDic = {}

DSCommonfunc.FirstTimeRandomMapID = true
local designatedMap = nil
local allPlayerLocation =UE4.TArray(UE4.FVector)
local CheckAllPlayerPositionCurrTime = 0
local checkAttackMonster={
    Monster = nil,
    Health = 0,
    Sheild = 0,
    CurrentWaitTime = 0,
    PrintDelay = 100
}

function DSCommonfunc.IsOperationDone()
    return DSCommonfunc.OperationTimeCount >= DSCommonfunc.OperationHoldTime
end

function DSCommonfunc:Tick(DeltaTime)

    -- 操作结束, 重新随机一个操作行为
    if (self.IsOperationDone()) then
        ---[[

        -- 测试交互物
        -- if #DSCommonfunc.InteractList ~= 0 then
        --     local InteractItem
        --     for i = 1, #DSCommonfunc.InteractList do
        --         InteractItem = DSCommonfunc.InteractList[i]
        --         DSCommonfunc.UseInteract(InteractItem)
        --     end
        -- end
        ---[[
        local mosterlist = UE4.TArray(UE4.AActor)
        
        UE4.UDsProfileFunctionLib.GetMonsterList(GetGameIns(),mosterlist)
        local monster,monster_pos,playerPos,Distance
        
        playerPos = UE4.UDsProfileFunctionLib.GetPlayerLocation()
        -- DSCommonError.tfPrint("INFO","======== playerPos ========",playerPos.X,playerPos.Y,playerPos.Z)
        
        for i = 1, mosterlist:Length() do
            monster = mosterlist:Get(i)
            if not IsValid(monster) then
                goto continue
            end
            monster_pos = monster:K2_GetActorLocation()
            -- DSCommonError.tfPrint("INFO","======== monster_pos ========",monster_pos.X,monster_pos.Y,monster_pos.Z)
            Distance = UE4.FVector.Dist(monster_pos,playerPos)
            -- DSCommonError.tfPrint("INFO","======== Distance ========",Distance)
            
            if Distance < 3000 then
                break
            end
            ::continue::
        end

        local Weak = UE4.FVector()
        if IsValid(monster) then
            UE4.UDsProfileFunctionLib.GetMonsterWeakPosition(monster,Weak)
            --DSCommonError.tfPrint("INFO","======== Weak ========",Weak.X,Weak.Y,Weak.Z)
            
            Distance = UE4.FVector.Dist(monster_pos,playerPos)
            --DSCommonError.tfPrint("INFO","======== Distance ========",Distance)

            UE4.UDsProfileFunctionLib.MoveTo(Weak.X,Weak.Y,Weak.Z)
            
            if Distance < 1000 then
                UE4.UDsProfileFunctionLib.StopMove()
            end
            
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(Weak.X,Weak.Y,Weak.Z)
            UE4.UDsProfileFunctionLib.OpenFire()

            local nowhp,maxhp,nowsd,maxsd = DSCommonfunc.GetMonsterHealthAndSheild(monster)
            -- DSCommonError.tfPrint("INFO","======== monster,nowhp,maxhp,nowsd,maxsd ========",monster,nowhp,maxhp,nowsd,maxsd)
        end
        --]]

        self.OperationTimeCount = 0
        return
    end

    self.OperationTimeCount = self.OperationTimeCount + DeltaTime
end

local SendCodeToHttp = function(code, target)
    local tbServer = Login.GetServer()
    local trueAddr = tbServer.sAddr
    local url = string.format("http://%s:1234/gm/script", trueAddr)
    DSCommonError.tfPrint("INFO",string.format("http://%s:1234/gm/script", trueAddr))
    local tbParam = {
        code = code;
        target = target or 1;
        pid = me:Id();
    }
    UE4.UGMLibrary.SendJsonToHttp(url, json.encode(tbParam))
end

function DSCommonfunc.SwitchMapId(mapid)
    SendCodeToHttp(string.format("Online.GmSetLevel(%d)",mapid))
    DSCommonError.tfPrint("INFO","sent Online.GmSetLevel to ",mapid)
    UE4.Timer.Add(2, function()
        SendCodeToHttp(string.format("Online.SetGMLevelId(%d)", mapid))
        DSCommonError.tfPrint("INFO","sent Online.SetGMLevelId to ",mapid)
        DSCommonError.tfPrintf("INFO","set mapid to %d",mapid)
    end);
end

local function RaiseCurrentMapIdIndex(index)
    if index < 1 then
        return
    end

    DSAutoTestAgent.iCurrentRunTime = DSAutoTestAgent.iCurrentRunTime + 1
    if DSAutoTestAgent.iCurrentRunTime >= DSAutoTestAgent.iSpecifyTime then
        if index > #DSCommonfunc.MapIdList or DSCommonfunc.MapIdList[DSCommonfunc.currentMapIdIndex] == DSAutoTestAgent.iDsEndMapID then
            if DSAutoTestAgent.bRunLoop or DSAutoTestAgent.bRandomLoop then
                DSCommonError.tfPrint("INFO","Reset mapIdIndex")
                DSCommonfunc.currentMapIdIndex = 1
                DSAutoTestAgent.iCurrentRunTime = 0
                return
            else
                local curTime = os.date("%c")
                DSCommonfunc.AllComplete = true
            end
        end
        DSCommonfunc.currentMapIdIndex = index
        DSAutoTestAgent.iCurrentRunTime = 0
    end
end

--自动切换地图
function DSCommonfunc.AutoSwitchMap()
    if DSAutoTestAgent.iRunDone > 0 and DSAutoTestAgent.iRunDone < 3 then
        DSCommonError.tfPrint("INFO","Seems like the previous map didn't exit properly,need run again")
        -- DSCommonfunc.SwitchMapId(DSCommonfunc.MapIdList[DSCommonfunc.currentMapIdIndex])
        return true
    end
    if  DSAutoTestAgent.WaitRSP == 1 then
        return false
    end
    if DSCommonfunc.AllComplete then
        DSCommonError.tfPrint("INFO","All maps completed",curTime)
        UE4.UDsProfileFunctionLib.RecordPIDForFinishAutoTest(DSAutoTestAgent.G_TokenPid)
        return false
    end

    if DSAutoTestAgent.bRandomLoop and DSCommonfunc.FirstTimeRandomMapID then
        DSCommonfunc.currentMapIdIndex = math.random(#DSCommonfunc.MapIdList)
        DSCommonError.tfPrintf("INFO","Open randomLoop!!!")
        DSCommonfunc.FirstTimeRandomMapID = false
    end

    -- 若指定了地图，则跳过该地图前面的地图
    if designatedMap == nil and DSAutoTestAgent.iDsMapID > 0 then
        designatedMap = DSAutoTestAgent.iDsMapID 
        DSCommonError.tfPrint("INFO","Specify the map",designatedMap)
        for i = 1, #DSCommonfunc.MapIdList do
            if DSCommonfunc.MapIdList[i] == designatedMap then
                DSCommonfunc.currentMapIdIndex = i
                break
            end
        end
    end

    local needRunMapid,maplistindex = Global_GetNextOnlinelevelMapid()
    RaiseCurrentMapIdIndex(maplistindex + 1)
    DSCommonfunc.SwitchMapId(needRunMapid)
    return true
end


--- 传入百分比，当血量低于最高血量百分比将调用加血GM(mengting)
function DSCommonfunc.AutoHealSelf(per)
    local NowHealth,MaxHealth = DSCommonfunc.GetPlayerHealth()
    if (NowHealth < MaxHealth*per) then
        DSCommonfunc.HealSelf()
    end
end

-- 调用GM血量回满
function DSCommonfunc.HealSelf()
    local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    if not PlayerController then
        DSCommonError.tfPrint("ERROR","error ====== DSCommonfunc.HealSelf() PlayerController is nil !!! ======")
        return
    end
    PlayerController:GMServerCall("HealSelf")
end

-- 获取玩家当前血量和最大血量
function DSCommonfunc.GetPlayerHealth()
    local NowHealth = 0
    local MaxHealth = 0

    local GamePlayer = UE4.UGameplayStatics.GetPlayerCharacter(GetGameIns(), 0)
    local GamePlayerAbility = GamePlayer and GamePlayer.Ability
    if (not GamePlayer) or (not GamePlayerAbility) then
        DSCommonError.tfPrint("ERROR","error ====== DSCommonfunc.GetPlayerHealth() GamePlayer or GamePlayerAbility nil !!! ======")
        return NowHealth,MaxHealth
    end

    MaxHealth = GamePlayerAbility:GetRolePropertieMaxValue(UE4.EAttributeType.Health)
    NowHealth = GamePlayerAbility:GetRolePropertieValue(UE4.EAttributeType.Health)
    return NowHealth,MaxHealth
end

-- 获取怪物血量和护盾
function DSCommonfunc.GetMonsterHealthAndSheild(monster)
    if not IsValid(monster) then
        DSCommonError.tfPrint("ERROR","error ====== DSCommonfunc.GetMonsterHealthAndSheild() monster is not Valid !!! ======")
    end

    local NowHealth = 0
    local MaxHealth = 0
    local NowSheild = 0
    local MaxSheild = 0

    local MonsterAbility = monster and monster.Ability
    if MonsterAbility then
        MaxHealth = MonsterAbility:GetRolePropertieMaxValue(UE4.EAttributeType.Health)
        NowHealth = MonsterAbility:GetRolePropertieValue(UE4.EAttributeType.Health)
        MaxSheild = MonsterAbility:GetRolePropertieMaxValue(UE4.EAttributeType.Shield)
        NowSheild = MonsterAbility:GetRolePropertieValue(UE4.EAttributeType.Shield)
    end

    return NowHealth,MaxHealth,NowSheild,MaxSheild
end

-- 获取当前联机地图ID
function DSCommonfunc.GetOnlineLevelId()
    local levID = Online.GetOnlineLevelId()
    return levID
end

-- C++执行自动战斗
-- function DSCommonfunc.AutoBattle(monster)
--     DSCommonAction.AutoBattle(monster)
--     DSCommonError.tfPrint("INFO","========DSCommonfunc.AutoBattle")
-- end

-- 获取当前关卡倒计时
function DSCommonfunc.GetLevelCountDownTime()
    local LevelCountDownTime = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns()):GetLevelCountDownTime()
    return LevelCountDownTime
end

-- 获取当前关卡总时长
function DSCommonfunc.GetTotalLevelCountDownTime()
    return DSCommonfunc.LevelCountDownTotalTime
end

-- 设置关卡总时长(必须在关卡开始时调用才准确)
function DSCommonfunc.SetTotalLevelCountDownTime()
    DSCommonfunc.LevelCountDownTotalTime = DSCommonfunc.GetLevelCountDownTime()
    DSCommonError.tfPrint("INFO","====== DSCommonfunc.SetTotalLevelCountDownTime() LevelCountDownTotalTime =",DSCommonfunc.LevelCountDownTotalTime)
end

--- 获取当前关卡经过的时长
--- @param stringFormat 是否以天_时_秒字符串的方式返回
--- @return string 时间
function DSCommonfunc.GetLevelCurGoTime(stringFormat)
    local totaltime = DSCommonfunc.GetTotalLevelCountDownTime()
    if totaltime ~= 0 then
        if stringFormat then
            return DSCommonfunc.secondsToTime(totaltime - DSCommonfunc.GetLevelCountDownTime())
        else
            return totaltime - DSCommonfunc.GetLevelCountDownTime()
        end
    end
    if stringFormat then
        return DSCommonfunc.secondsToTime(0)
    else
        return totaltime - DSCommonfunc.GetLevelCountDownTime()
    end
end

-- 秒数转换成时分秒
function DSCommonfunc.secondsToTime(ts)

    local seconds = math.fmod(ts, 60)
    local min = math.floor(ts/60)
    local hour = math.floor(min/60) 
    local day = math.floor(hour/24)
    
    local str = ""
        
    if tonumber(seconds) > 0 and tonumber(seconds) < 60 then
        str = ""..seconds.."秒" ..str
    end

    if tonumber(min - hour*60)>0 and tonumber(min - hour*60)<60 then
        str = ""..(min - hour*60).."分"..str
    end

    if tonumber(hour - day*24)>0 and tonumber(hour - day*60)<24 then
        str = (hour - day*24).."时"..str
    end
    
    if tonumber(day) > 0 then
        str = day.."天"..str
    end

    return str
end

-- 添加可交互对象
function DSCommonfunc.AddInteractList(InteractItem)
    DSCommonfunc.InteractList[#DSCommonfunc.InteractList + 1] = InteractItem
end

-- 移除可交互对象
function DSCommonfunc.RemoveInteract(InteractItem)
    for i = 1, #DSCommonfunc.InteractList do
        if InteractItem == DSCommonfunc.InteractList[i] then
            table.remove(DSCommonfunc.InteractList,i)
            break
        end
    end
end

-- 使用可交互物
function DSCommonfunc.UseInteract(InteractItem)
    if not IsValid(InteractItem) then
        DSCommonError.tfPrint("ERROR","====== DSCommonfunc.UseInteract() InteractItem Not IsValid !!! ======")
        return
    end

    if DSCommonfunc.InteractCount > 300 then
        DSCommonError.tfPrint("WARNING","====== DSCommonfunc.UseInteract() Already Used !!! ======")
        return
    end
    if InteractItem.Data and InteractItem.Data.State then
        local Statedata = InteractItem.Data.State
        if Statedata == 3 then
            DSCommonError.tfPrint("INFO","====== DSCommonfunc.UseInteract() InteractItem is Using !!! ======")
            return
        end
    else
        DSCommonError.tfPrint("ERROR","====== DSCommonfunc.UseInteract() InteractItem.Data not Found !!! ======")
        return
    end
    local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    PlayerController:Server_TryInteractActor(InteractItem)
    DSCommonfunc.InteractCount = DSCommonfunc.InteractCount + 1
    DSCommonError.tfPrint("WARNING","======= DSCommonfunc.UseInteract =======")
end

-- 获取actor对象坐标,失败则返回原点坐标
function DSCommonfunc.GetActorLocation(actoritem)
    local location = UE4.FVector()

    if IsValid(actoritem) then
        location = actoritem:K2_GetActorLocation()

    else
        DSCommonError.tfPrint("ERROR","error ====== DSCommonfunc.GetActorLocation() actoritem is not Valid !!! ======")
    end

    return location
end

--- 根据任务文字筛选任务条件
--- @param ExecuteDesCountList table 手动设置需要检测的文字列表
function DSCommonfunc.GetMoveTimeByDes(ExecuteDesCountList)
    for i = 1, #DSCommonfunc.ExecuteDes do
        for key, value in pairs(ExecuteDesCountList) do
            if DSCommonfunc.ExecuteDes[i] == key then
                value.curcount = value.curcount + 1
                table.remove(DSCommonfunc.ExecuteDes,i)

                if value.curcount >= value.triggercount then
                    DSCommonfunc.movetime = value.movetime
                    break
                end
            end
        end
    end
end

--- 记录关卡任务信息
function DSCommonfunc.OnGameTaskExecuteChange(ExecuteNode)
    if not DSAutoTestAgent.bOpenAutoAgent then
        return
    end

    local ExecuteDescriptionID = ExecuteNode.ExecuteDescriptionID
    local bHiddenExectue = ExecuteNode.bHiddenExectue
    local bCanFinish = ExecuteNode.bCanFinish
    local ExecuteDes = ExecuteNode.ExecuteDes
    local TaskItemDes = ExecuteNode.TaskItemDes

    --- 记录当前关卡
    if (ExecuteDescriptionID ~= 0) then
        DSCommonfunc.movetime = ExecuteDescriptionID
    end

    if ExecuteDes and ExecuteDes ~= "" then
        DSCommonfunc.ExecuteDes[#DSCommonfunc.ExecuteDes + 1] = ExecuteDes
    end
    ExecuteDescriptionID = ExecuteDescriptionID or ""
    bHiddenExectue = bHiddenExectue or "" 
    bCanFinish = bCanFinish or ""
    ExecuteDes = ExecuteDes or ""
    DSCommonError.tfPrint("INFO","OnGameTaskExecuteChange:",ExecuteDescriptionID,bHiddenExectue,bCanFinish,ExecuteDes)
end

-- 添加beginplaylist
function DSCommonfunc.AddBeginPlay(mapid,func)
    DSCommonfunc.BeginPlayList[mapid] = func
    DSCommonError.tfPrint("INFO","DSCommonfunc.AddBeginPlay mapid=",mapid,func)
end

-- 根据mapid执行beginplay
function DSCommonfunc.DealBeginPlay()
    local mapid = DSCommonfunc.GetOnlineLevelId()
    DSCommonError.tfPrint("INFO","======== DSCommonfunc:DealBeginPlay mapid =",mapid)

    if (DSCommonfunc.BeginPlayList[mapid]) then
        local func = DSCommonfunc.BeginPlayList[mapid]
        func()
    end
end

-- 初始化任务目标
local function InitTask()
    DSCommonError.tfPrint("INFO","======== DSCommonfunc:InitTask ========")
    DSCommonfunc.movetime = 0
    DSCommonfunc.ExecuteDes = {}
    DSCommonfunc.InteractCount = 0
    DSCommonfunc.LevelCountDownTotalTime = 0

end

function DSCommonfunc.Init()
    InitTask()
    DelayPrintDic = {}
end

-- 获取可破坏物的坐标(获取失败也会返回zero坐标点，需注意处理判断)
function DSCommonfunc.GetDestroyTargetCoreLocation()
    local Targetlist = UE4.TArray(UE4.AActor)
    UE4.UDsProfileFunctionLib.GetDestroyTargetList(Targetlist)

    local TargetLocation
    local DestroyTarget
    if (Targetlist:Length() ~= 0) then
        for i = 1, Targetlist:Length() do
            DestroyTarget = Targetlist:Get(i)
            if IsValid(DestroyTarget) then
                TargetLocation = UE4.UDsProfileFunctionLib.GetDestroyTargetCoreLocation(DestroyTarget)
                return TargetLocation
            end
        end
    end
end


-- 检测坐标是否在指定范围内
function DSCommonfunc.CheckPosition(vector,scope)
    if vector.X >= scope.min_x and vector.X <= scope.max_x and vector.Y >= scope.min_y and vector.Y <= scope.max_y then
        if scope.min_z ~= nil and scope.max_z ~= nil then -- 如果还要判断z轴
            if vector.Z >= scope.min_z and vector.Z <= scope.max_z then
                return true
            end
        else -- 不判断z轴 前面条件已经达成
            return true
        end
    end
    return false
end

-- 检测所有玩家是否在指定范围内
function DSCommonfunc.CheckAllPlayerPosition(scope,updateDelay)
    CheckAllPlayerPositionCurrTime = CheckAllPlayerPositionCurrTime+BP_LocalPlayerAutoAgent2.DeltaTime
    if CheckAllPlayerPositionCurrTime > updateDelay or allPlayerLocation:Length() == 0 then
        UE4.UDsProfileFunctionLib.GetAllPlayerLocation(allPlayerLocation)
        CheckAllPlayerPositionCurrTime = 0
    end

    if allPlayerLocation:Length() == 0 then
        DSCommonError.tfPrint("ERROR","Error:Couldn't Get Players Location")
        return false
    end
    for i = 1, allPlayerLocation:Length() do
        local playerVector = allPlayerLocation:Get(i)
        if playerVector.X == -1000.000 and playerVector.Y == -1000.000 and playerVector.Z == -10000.000 then
            DSCommonError.tfPrint("ERROR","Wrong vector")
            goto continue
        end
        if playerVector.X >= scope.min_x and playerVector.X <= scope.max_x and playerVector.Y >= scope.min_y and playerVector.Y <= scope.max_y then
            if scope.min_z ~= nil and scope.max_z ~= nil then -- 如果还要判断z轴
                if playerVector.Z < scope.min_z or playerVector.Z > scope.max_z then
                    return false
                end
            end
        else
            return false
        end
        ::continue::
    end
    return true
end

-- 检测所有玩家距离指定坐标距离是否在要求距离内
-- 有点鸡肋 但还是留着了
function DSCommonfunc.CheckAllPlayerPositionWithDistance(vector,distance)
    UE4.UDsProfileFunctionLib.GetAllPlayerLocation(allPlayerLocation)
    if allPlayerLocation:Length() ==0 then
        DSCommonError.tfPrint("ERROR","Error:Could Get Players Location")
        return false
    end
    for i = 1, allPlayerLocation:Length() do
        local playerVector = allPlayerLocation:Get(i)
        if UE4.FVector.Dist(playerVector,vector) > distance then
            return false
        end
    end
    return true
end

-- 重置商店列表是否开启的状态
function DSCommonfunc.ClearStoreDicStatus()
    DSCommonfunc.StoreInfoDic = {}
    local storelist = UE4.UDsProfileFunctionLib.GetBuffShopList()
    for i = 1, storelist:Length() do
        DSCommonfunc.StoreInfoDic[i] = {store=storelist:Get(i),opened=false}
    end
end

function DSCommonfunc.refreshStorefromStoreDicStatus()
    local storelist = UE4.UDsProfileFunctionLib.GetBuffShopList()
    for i = 1, storelist:Length() do
        DSCommonfunc.StoreInfoDic[i].store = storelist:Get(i)
    end
end

-- 根据方向和距离，在原点上获取一个偏移坐标
---@param originalPoint FVector 原点
---@param direction FVector 方向
---@param distance float 距离
function DSCommonfunc.GetOffsetLocationWithDirection(originalPoint,direction,distance)
    local x = math.abs(originalPoint.X-direction.X)
    local y = math.abs(originalPoint.Y-direction.Y)
    local z = math.abs(originalPoint.Z-direction.Z)
    local xProportion = x/(x+y+z)
    local yProportion = y/(x+y+z)
    local zProportion = z/(x+y+z)
    local destination = UE4.FVector()
    if originalPoint.X>direction.X then
        destination.X = -distance*xProportion + originalPoint.X
    else
        destination.X = distance*xProportion + originalPoint.X
    end

    if originalPoint.Y>direction.Y then
        destination.Y = -distance*yProportion + originalPoint.Y
    else
        destination.Y = distance*yProportion + originalPoint.Y
    end

    if originalPoint.Z>direction.Z then
        destination.Z = -distance*zProportion + originalPoint.Z
    else
        destination.Z = distance*zProportion + originalPoint.Z
    end
    return destination
end

--获取好友列表
function DSCommonfunc.GetCanInviteFriendList()
    local tbList = {}
    local tbFriendList = Friend.GetFriends()
    local tbId = Online.GetRoomOthers()
    for _, tbFriendProfile in ipairs(tbFriendList) do
        if tbFriendProfile.bOnline and not Friend.BlacklistCheck(tbFriendProfile.nPid) and not tbId[tbFriendProfile.nPid] then
            table.insert(tbList, tbFriendProfile)
        end
    end

    return tbList
end

--处理收到组队邀请后的数据
function DSCommonfunc.DealWithInviteInfo(tbParam)
    if tbParam then
        Online.AddNewInfo(tbParam)
    end

    -- return Online.tbReceiveInviteList   -- tbInfo {邀请者名字,房间id,玩法id,角色id,头像,头像框,等级}
end

-- 清空状态退出房间
function DSCommonfunc.DoExitRoomWithClearState()
    DSCommonError.tfPrint("INFO","DSCommonfunc.DoExitRoomWithClearState()")
    UE4.UAccount.ClearOthers(1);
    Online.ClearAll()    
    Online.DoExitRoom( function() end, 0, true)
end

-- 获取可破坏物核心的血量 参数传入可破坏物object,获取失败hp=-1
function DSCommonfunc.GetDestroyTargetCoreCurHp(DestroyTarget)
    local curhp = -1
    if IsValid(DestroyTarget) then
        DestroyCore = UE4.UDsProfileFunctionLib.GetDestroyTargetCoreObj(DestroyTarget)
        curhp = DestroyCore:GetCurrentHp()
        DSCommonError.tfPrint("DEBUG","DestroyCore:GetCurrentHp() = ",curhp)
    end

    return curhp
end

-- 检测怪物是否受到攻击 0等待检测 1可攻击 2无法攻击
function DSCommonfunc.CheckMonsterIsAttackable(monster,health,sheild,duration)
    if not IsValid(checkAttackMonster.Monster) or checkAttackMonster.Monster ~= monster then
        checkAttackMonster.Monster = monster
        checkAttackMonster.Health = health
        checkAttackMonster.Sheild = sheild
        checkAttackMonster.CurrentWaitTime = 0
        return 0
    end

    if checkAttackMonster.PrintDelay > 100 then
        if IsValid(checkAttackMonster.Monster) then
            DSCommonError.tfPrint("INFO","checkAttackMonster.Monster success")
        else
            DSCommonError.tfPrint("WARNING","checkAttackMonster.Monster fail")
        end
        checkAttackMonster.PrintDelay = 0
    else
        checkAttackMonster.PrintDelay = checkAttackMonster.PrintDelay + 1
    end
    

    if checkAttackMonster.CurrentWaitTime > duration then
        if IsValid(checkAttackMonster.Monster) and
        checkAttackMonster.Monster == monster and
        (checkAttackMonster.Health ~= health or checkAttackMonster.Sheild ~= sheild) then
            checkAttackMonster.Health = health
            checkAttackMonster.Sheild = sheild
            checkAttackMonster.CurrentWaitTime = 0
            return 1
        else
            checkAttackMonster.CurrentWaitTime = 0
            return 2
        end
    else
        checkAttackMonster.CurrentWaitTime = checkAttackMonster.CurrentWaitTime + 2 * BP_LocalPlayerAutoAgent2.DeltaTime
        return 0
    end
end

function DSCommonfunc.GoToLoginLevel()
    DSCommonError.tfPrint("WARNING","DSCommonfunc.GoToLoginLevel()")
    me:Logout()
    GoToLoginLevel()
end

-- 计时输出日志 函数指针不建议使用闭包
function DSCommonfunc.RegularPrint(logLevel,message,delay,deltaTime,funcPointer,...)
    local arg = {...}
    delay = delay or 0
    local key = debug.getinfo(2).source.." "..debug.getinfo(2).currentline
    if not DelayPrintDic[key] then
        DelayPrintDic[key] = BP_LocalPlayerAutoAgent2.DeltaTime
    else
        if DelayPrintDic[key] > delay then
            DelayPrintDic[key] = 0
            if logLevel ~= nil and logLevel ~= "" then
                DSCommonError.tfPrintf(logLevel,message)
            end
            if funcPointer then 
                return funcPointer(table.unpack(arg)) 
            end
        else
            DelayPrintDic[key] = DelayPrintDic[key] + deltaTime
        end
    end
end