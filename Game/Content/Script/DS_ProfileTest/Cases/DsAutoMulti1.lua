---
--- Created by wang.
--- DateTime: 2022/05/18 9:10
---
---

-- require("DS_ProfileTest.Utils.DsCommonAction")


DsAutoMulti1 = DsAutoMulti1 or {}

-- 当前操作执行的最长时间
DsAutoMulti1.OperationHoldTime = 0.02
-- 当前操作计时
DsAutoMulti1.OperationTimeCount = 0
local playerPos = UE4.FVector()
-- 电梯入口1 位置
local elevatorentry_pos_1 = UE4.FVector(73878.289062,60670.421875,-10304.849609)
-- 电梯1 位置
local elevator_pos_1 = UE4.FVector(74305.851562,60463.640625,-10355.001953)
-- 电梯1范围坐标
local elevator_area_1 = { min_x = 73882 , min_y = 60366 , max_x = 74450 , max_y =  60934 }

-- 电梯入口2 位置
local elevatorentry_pos_2 = UE4.FVector(70446.320312,60626.679688,-7809.326172)
-- 电梯2 位置
local elevator_pos_2 = UE4.FVector(71118.648438,60841.980469,-7891.51709)
-- 电梯2范围坐标
local elevator_area_2 = { min_x = 70636 , min_y = 60366 , max_x = 71104 , max_y =  60934 }
-- 前往boss区域导航丢失的地方
local bug_area_1 = { min_x = 70607.960938 , min_y = 34641.765625 , max_x = 73237.960938 , max_y =  37121.828125 }
--boss脸前的区域
local area_1 = { min_x = 71772.335938 , min_y = 33601.429688 , max_x = 73202.335938 , max_y =  34071.429688 }
-- 区域2到第一个电梯路上的导航断层
local area_2 = { min_x = 72199.085938 , min_y = 62845.730469 , max_x = 72900.21875 , max_y =  63223.773438 }
-- boss区域入口透明墙的导航断层
local area_3 = { min_x = 70575.875 , min_y = 36605.96875 , max_x = 71455.875 , max_y =  37811.136719 }
-- 导航有误的地方
local area_4 = { min_x = 71632.15625 , min_y = 55156.050781 , max_x = 71842.15625 , max_y =  55356.050781 }
-- 这四个都是区域2高台下面的无导航区域
local area_5 = { min_x = 72941.53125 , min_y = 60459.535156 , max_x = 73034 , max_y =  60819.535156 , min_z =-10385.241211 , max_z = -10265.241211 }
local area_6 = { min_x = 72080.65625 , min_y = 60459.535156 , max_x = 72196.515625 , max_y =  60819.535156 , min_z =-10385.241211 , max_z = -10265.241211 }
local area_7 = { min_x = 72362.671875 , min_y = 60216.707031 , max_x = 72742.671875 , max_y =  60333.480469 , min_z =-10385.241211 , max_z = -10265.241211 }
local area_8 = { min_x = 72362.671875 , min_y = 60926.507812 , max_x = 72742.671875 , max_y =  60995.449219 , min_z =-10385.241211 , max_z = -10265.241211 }
-- 第一个电梯旁边的商店后面那块地方
local area_9 = { min_x = 73948.828125 , min_y = 60907.421875 , max_x = 74348.828125 , max_y =  61327.421875}
local aVector_1 = UE4.FVector(72529.085938,62643.773438,-10309.799805) -- 区域2到第一个电梯路上的导航断层瞄准点

-- 触发战斗位置1
local trrigerBattle_pos_1 = UE4.FVector(71720.0 , 58310.0, -2899.936523)
-- NavigationPoint 导航点
local nVector_1 = UE4.FVector(73503.546875,60646.449219,-10304.849609) -- 第一个电梯门前
local nVector_2 = UE4.FVector(72525.75,60591.4375,-10014.783203) -- 118 区域2的高台
local nVector_3 = UE4.FVector(71322.148438,36886.789062,-2809.786377) -- boss区域导航线终点
local nVector_4 = UE4.FVector(72062.867188,55214.132812,-2809.786377)
local nVector_5 = UE4.FVector(73148.828125,61237.421875,-10304.849609) -- 用来走出第一个电梯旁边的商店后面那块地方


local aVector_2 = UE4.FVector(71395.875,36085.96875,-2809.786621) -- boss区域入口过透明墙瞄准点
local aVector_3 = UE4.FVector(72531.085938,59135.113281,-10304.849609) -- area_5的标准点
local aVector_4 = UE4.FVector(73705.875,60647.871094,-10298.799805) -- area_6的标准点
--- 最终BOSS位置
local BossPos = UE4.FVector(72483.851562,31519.519531,-2809.982666)


function DsAutoMulti1.IsOperationDone()
    return DsAutoMulti1.OperationTimeCount >= DsAutoMulti1.OperationHoldTime
end

function DsAutoMulti1:Tick(deltaTime,AreaId,Mapid,MetaData)
    
    if (self:IsOperationDone()) then
        if DSCommonfunc.movetime == 1000001 then
            -- 结束战斗
            UE4.UDsProfileFunctionLib.StopAim()
            UE4.UDsProfileFunctionLib.CeaseFire()
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.StopMove()
            return
        end

        -- 获取怪物id
        local monster,monsterType = DSCommonAction.GetClosedMonster()
        -- 战斗流程
        -- DSCommonfunc.AutoHealSelf(0.9)
        playerPos = UE4.UDsProfileFunctionLib.GetPlayerLocation()
        if DSCommonAction.RescuePartner(playerPos,monster) ~= false then
            return
        end 
        if DSCommonfunc.CheckPosition(playerPos,area_1) then -- boss脸前 让角色停止前进
            MetaData.isMoveSuccess = true
        end
        local temp = DSCommonAction.GetOpenStoreInfo(playerPos)
        if temp ~=nil and temp.store:GetTransform().Translation.X == 70973.765625
        and (AreaId == 3 and playerPos.Z < -3000 and monster==nil) then
            -- DSCommonAction.AutoUseElevator(elevator_pos_2,elevator_area_2,elevatorentry_pos_2,4)
            DSCommonAction.UseReachedElevator(elevator_pos_2,elevator_area_2,elevatorentry_pos_2,4)
            return
        end
        if DSCommonfunc.CheckPosition(playerPos,area_4) then
            UE4.UDsProfileFunctionLib.StopMove()
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(nVector_4.X,nVector_4.Y,nVector_4.Z)
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
            return
        elseif DSCommonfunc.CheckPosition(playerPos,area_5) or DSCommonfunc.CheckPosition(playerPos,area_6) then
            UE4.UDsProfileFunctionLib.StopMove()
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_3.X,aVector_3.Y,aVector_3.Z)
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
            return
        elseif DSCommonfunc.CheckPosition(playerPos,area_7) or DSCommonfunc.CheckPosition(playerPos,area_8) then
            UE4.UDsProfileFunctionLib.StopMove()
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_4.X,aVector_4.Y,aVector_4.Z)
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
            return
        end
        if DSCommonAction.ComeToNearestBuffStore(playerPos) then --购买商店buff
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.CeaseFire()
            UE4.UDsProfileFunctionLib.StopAim()
            MetaData.isMoveSuccess = false
        elseif DSCommonfunc.CheckPosition(playerPos,area_9) then
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.StopAim()
            UE4.UDsProfileFunctionLib.MoveTo(nVector_5.X,nVector_5.Y,nVector_5.Z)
        -- elseif DSCommonfunc.CheckPosition(playerPos,area_2) then
        --     UE4.UDsProfileFunctionLib.StopMove()
        --     UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_1.X,aVector_1.Y,aVector_1.Z)
        --     UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
        elseif Mapid > 117 and AreaId == 2 and not MetaData.isMoveSuccess then
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.StopAim()
            UE4.UDsProfileFunctionLib.MoveTo(nVector_2.X,nVector_2.Y,nVector_2.Z)
            if UE4.FVector.Dist(nVector_2,playerPos)<150 then
                MetaData.isMoveSuccess = true
            end
        elseif AreaId == 2 and monster == nil and not MetaData.isMoveSuccess then
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.StopAim()
            UE4.UDsProfileFunctionLib.MoveTo(nVector_1.X,nVector_1.Y,nVector_1.Z)
            if UE4.FVector.Dist(nVector_1,playerPos)<150 then
                MetaData.isMoveSuccess = true
                UE4.UDsProfileFunctionLib.GetAndMoveToLevelPathPainterEndPath(GetGameIns())
            end
        elseif (AreaId == 2 and playerPos.Z < -8000 and monster == nil) then
            DSCommonError.tfPrint("DEBUG","InteractList1:",#DSCommonfunc.InteractList)
            -- DSCommonError.PlayerUnusualPosStatus.IsInRandomPosing = false
            DSCommonAction.UseReachedElevator(elevator_pos_1,elevator_area_1,elevatorentry_pos_1,3)
            return
        elseif (AreaId == 3 and playerPos.Z < -3000 and monster==nil) then
            DSCommonAction.UseReachedElevator(elevator_pos_2,elevator_area_2,elevatorentry_pos_2,4)
            return
        elseif (AreaId == 4 and playerPos.Z > -2820 and playerPos.Y >  58370.0 ) then
            UE4.UDsProfileFunctionLib.MoveTo(trrigerBattle_pos_1.X,trrigerBattle_pos_1.Y,trrigerBattle_pos_1.Z)
        elseif AreaId == 6 and DSCommonfunc.CheckPosition(playerPos,bug_area_1) and not MetaData.isMoveSuccess then
            UE4.UDsProfileFunctionLib.StopMove()
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(BossPos.X,BossPos.Y,BossPos.Z)
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
        elseif AreaId == 6 and DSCommonfunc.CheckPosition(playerPos,area_3) then
            UE4.UDsProfileFunctionLib.StopMove()
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_2.X,aVector_2.Y,aVector_2.Z)
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
        else
            UE4.UDsProfileFunctionLib.StopMoveInput()
            DSCommonAction.UseSkill()
            DSCommonAction.DelayGetAndMoveToLevelPathPainterEndPath()
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