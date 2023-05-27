--update 2022/10/26
-- require("DS_ProfileTest.Utils.DsCommonAction")
-- require("DS_ProfileTest.Utils.DsCommonfunc")

DsAutoMulti5 = DsAutoMulti5 or {}



-- 电梯1 位置
local elevator_pos_1 = UE4.FVector(-1394.146729,25500.248047,7585.402344)
-- 电梯1 入口位置
local elevatorentry_pos_1 = UE4.FVector(-1386.464844,25126.388672,7585.982422)

local elevator_area_1 = { min_x = -1586.572754 , min_y = 25157.675781 , max_x = -1238.511353  , max_y = 25511.699219}

local playerPos = UE4.FVector()

local nVector_4 = UE4.FVector(-1390.163208,25777.333984,5790.175293) -- 第一个电梯出口
local nVector_5 = UE4.FVector(-8507.001953,7234.714844,5792.000977) -- 151、153地图使用，150boss坑旁边商店附近
local aVector_1 = UE4.FVector(-9250.299805,6736.700195,5650.200195) -- boss坑边上的商店到坑里的导航断层瞄准点

--- 最终BOSS位置
local BossPos = UE4.FVector(-9700.954102,8896.349609,3492.417969)

local shop_to_boss_area = { min_x = -8950.299805 , min_y = 6796.95752 , max_x = -8340.299805 , max_y =  7446.700195} -- boss下坑的路
local boss_before = { min_x = -10307.301758 , min_y = 3428.197754 , max_x = -8695.40918 , max_y =  7447.219238} -- boss下坑的路
local boss_before_bug_area = { min_x = -10154.474609 , min_y = 3799.531738 , max_x = -8695.40918 , max_y =  4978.070801} -- boss下坑的路导航失效的地方
local boss_areaEnter = UE4.FVector(-9328.237305,3084.903076,4812.15625) -- 导航到boss区域内的点
local area_1 = { min_x = -8387.001953 , min_y = 6854.714844 , max_x = -6927.001953 , max_y =  8894.714844} -- 151最后一个商店离150的商店有一定距离，用来走到150商店判定范围内
local area_2 = { min_x = -17530.417969 , min_y = 7255.182617 , max_x = -8210.417969 , max_y =  10915.182617} -- 153最后一个商店离150的商店有一定距离，用来走到150商店判定范围内

-- 当前操作执行的最长时间
DsAutoMulti5.OperationHoldTime = 0.02
-- 当前操作计时
DsAutoMulti5.OperationTimeCount = 0

DsAutoMulti5.ExecuteDesCountList = {}


function DsAutoMulti5.IsOperationDone()
    return DsAutoMulti5.OperationTimeCount >= DsAutoMulti5.OperationHoldTime
end


function DsAutoMulti5:Tick(deltaTime,AreaId,Mapid,MetaData)

    if (self:IsOperationDone()) then
        if DSCommonfunc.movetime == 1000001 then
            -- 结束战斗
            UE4.UDsProfileFunctionLib.StopAim()
            UE4.UDsProfileFunctionLib.CeaseFire()
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.StopMove()
            return
        end
        local monster,monsterType = DSCommonAction.GetClosedMonster()
        playerPos = UE4.UDsProfileFunctionLib.GetPlayerLocation()
        -- 战斗流程
        -- DSCommonfunc.AutoHealSelf(0.9)
        --- 正常战斗流程
        DsAutoMulti5.OperationHoldTime = 0.02

        if DSCommonAction.RescuePartner(playerPos,monster) ~= false then
            return
        end
        if DSCommonAction.ComeToNearestBuffStore(playerPos) then --购买商店buff
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.CeaseFire()
            UE4.UDsProfileFunctionLib.StopAim()
            MetaData.isMoveSuccess = false
        elseif (not IsValid(monster) and AreaId == 0 and Mapid == 152) or (playerPos.Z > 7580 and AreaId==1 and Mapid == 152) then -- 152有电梯 需要特殊处理
            DSCommonAction.AutoUseElevator(elevator_pos_1,elevator_area_1,elevatorentry_pos_1,2)
            return -- 使用电梯可能需要长时间等待队员 因此不能触发CheckPlayerPosStatus的检测
        elseif DSCommonfunc.CheckPosition(playerPos,elevator_area_1) then --电梯下来后 导航不会绕开栏杆，需要提前出来
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.StopAim()
            UE4.UDsProfileFunctionLib.MoveTo(nVector_4.X,nVector_4.Y,nVector_4.Z)-------------------------------- 152 地图特殊处理结束
        elseif AreaId == 6 and not MetaData.isMoveSuccess and DSCommonfunc.CheckPosition(playerPos,area_1) then
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.StopAim()
            UE4.UDsProfileFunctionLib.MoveTo(nVector_5.X,nVector_5.Y,nVector_5.Z)
            if UE4.FVector.Dist(playerPos,nVector_5)< 100 then
                MetaData.isMoveSuccess = true
            end
        elseif AreaId == 6 and Mapid == 153 and not MetaData.isMoveSuccess and DSCommonfunc.CheckPosition(playerPos,area_2) then
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.StopAim()
            UE4.UDsProfileFunctionLib.MoveTo(nVector_5.X,nVector_5.Y,nVector_5.Z)
            if UE4.FVector.Dist(playerPos,nVector_5)< 100 then
                MetaData.isMoveSuccess = true
            end
        elseif AreaId == 6 and DSCommonfunc.CheckPosition(playerPos,shop_to_boss_area) then
            UE4.UDsProfileFunctionLib.StopMove()
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_1.X,aVector_1.Y,aVector_1.Z)
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
        elseif AreaId == 6 and DSCommonfunc.CheckPosition(playerPos,boss_before_bug_area) then
            UE4.UDsProfileFunctionLib.StopMove()
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(boss_areaEnter.X,boss_areaEnter.Y,boss_areaEnter.Z)
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
            DSCommonAction.SwitchRandPlayer()
        elseif AreaId == 6 and DSCommonfunc.CheckPosition(playerPos,boss_before) then
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.MoveTo(boss_areaEnter.X,boss_areaEnter.Y,boss_areaEnter.Z)
        else
            UE4.UDsProfileFunctionLib.StopMoveInput()
            DSCommonAction.DelayGetAndMoveToLevelPathPainterEndPath()
            DSCommonAction.UseSkill()
            DSCommonAction.AutoBattle(monster,monsterType)
        end

        if monster~= nil and AreaId ~= 6 and BP_LocalPlayerAutoAgent2.IsCaptain then
            DSCommonError.CheckMonsterPosStatus(monster)
        end
        DSCommonError.CheckPlayerPosStatus(playerPos.X,playerPos.Y,playerPos.Z)
        DSCommonError.CheckPlayerPosStatus2(playerPos)
        self.OperationTimeCount = 0
        return
    end

    self.OperationTimeCount = self.OperationTimeCount + deltaTime

end