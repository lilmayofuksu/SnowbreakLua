-- require("DS_ProfileTest.Utils.DsCommonAction")
-- require("DS_ProfileTest.Utils.DsCommonfunc")

DsAutoMulti3 = DsAutoMulti3 or {}

function DsAutoMulti3.ReceiveBeginPlay()
    DsAutoMulti3.ExecuteDesCountList = {}
    DsAutoMulti3.ExecuteDesCountList["清理区域2的敌人"] = { curcount = 0 , triggercount = 2 , movetime = 10101 }
    DsAutoMulti3.ExecuteDesCountList["消灭驻守的敌人13/13"] = { curcount = 0 , triggercount = 1 , movetime = 10102 }
    DsAutoMulti3.ExecuteDesCountList["清理区域5的敌人"] = { curcount = 0 , triggercount = 2 , movetime = 10103 }
    DsAutoMulti3.ExecuteDesCountList["消灭驻守的敌人4/7"] = { curcount = 0 , triggercount = 1 , movetime = 10104 }
    
end

local beginfunc = DsAutoMulti3.ReceiveBeginPlay

-- DSCommonfunc.AddBeginPlay(103,beginfunc)

-- print("======DSCommonfunc.AddBeginPlay=======")

-- 电梯1 位置
--local elevator_pos_1 = UE4.FVector(-4720.452148,-7575.0,1172.0)
local elevator_pos_1 = UE4.FVector(-4734.633789,-7575.442871,1175.956177)
-- 电梯1 交互位置
-- local elevatorentry_pos_1 = UE4.FVector(-4784.633789,-7525.442871,1175.956177)
local elevatorentry_pos_1 = UE4.FVector(-4624.633789,-7895.442871,1175.956177)
-- 电梯2 位置
-- local elevator_pos_2 = UE4.FVector(-4716.71875,6415.300293,28.252501)
-- 电梯2 交互位置
local elevator_pos_2 = UE4.FVector(-4700.71875,6410.300293,28.252501)
--local elevatorentry_pos_2 = UE4.FVector(-4716.71875,6415.300293,28.252501)
local elevatorentry_pos_2 = UE4.FVector(-4595.268555,6040.147949,118.136131)

local playerPos = UE4.FVector()
-- 第一个电梯区域
local elevator_area_1 = { min_x = -4730.997559 , min_y = -7840.981445 , max_x = -4477 , max_y =  -7541.464355,min_z = 1200,max_z = 1280}
-- 第二个电梯区域
local elevator_area_2 = { min_x = -4714.07959 , min_y = 6131.827148 , max_x = -4400.842773 , max_y =  6452.246094}
--去第二个电梯的区域
local comeToelevator_area2 = { min_x = -4955.510742 , min_y = 4722.925293 , max_x = -4200.733398 , max_y =  6511.702148}
-- boss门口
local boss_gate_area = { min_x = 480.629395 , min_y = 8842.943359375 , max_x = 1557.096436 , max_y =  9100.3798828125}
-- boss区域
local boss_area = { min_x = 1201.847656 , min_y = 5403.393555 , max_x = 7861.847656 , max_y =  12463.393555}

local ZPoint_2 = 119.231812


-- AimPoint 瞄准点
local aVector_1 = UE4.FVector(-4612.343262,6990.476074,1251.550171) -- 第二个电梯上去后的瞄准点


--- 最终BOSS位置
local BossPos = UE4.FVector(4326.449707,8896.349609,2333.929932)

-- 当前操作执行的最长时间
DsAutoMulti3.OperationHoldTime = 0.02
-- 当前操作计时
DsAutoMulti3.OperationTimeCount = 0

DsAutoMulti3.ExecuteDesCountList = {}


function DsAutoMulti3.IsOperationDone()
    return DsAutoMulti3.OperationTimeCount >= DsAutoMulti3.OperationHoldTime
end



function DsAutoMulti3:Tick(deltaTime,AreaId,Mapid,MetaData)

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
        DsAutoMulti3.OperationHoldTime = 0.02
        playerPos = UE4.UDsProfileFunctionLib.GetPlayerLocation()

        if DSCommonAction.RescuePartner(playerPos,monster) ~= false then
            return
        end
        -- local PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(),0)
        if DSCommonAction.ComeToNearestBuffStore(playerPos) then --购买商店buff
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.CeaseFire()
            UE4.UDsProfileFunctionLib.StopAim()
        elseif AreaId == 1 and monster == nil and playerPos.Z > 1000 then
            if not DSCommonAction.UseReachedElevator(elevator_pos_1,elevator_area_1,elevatorentry_pos_1,1) then -- 如果没使用成功 直接退出
                return
            end
        elseif AreaId == 4 and DSCommonfunc.CheckPosition(playerPos,comeToelevator_area2) then -- 到达第二个电梯地点
            if playerPos.Z < ZPoint_2 then -- 如果还没使用电梯
                UE4.UDsProfileFunctionLib.CeaseFire()
                if not DSCommonAction.UseReachedElevator(elevator_pos_2,elevator_area_2,elevatorentry_pos_2,1) then -- 如果没使用成功 直接退出
                    return
                end
            else -- 已经使用过了电梯
                if UE4.FVector.Dist(playerPos,aVector_1) > 100 then
                    UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_1.X,aVector_1.Y,aVector_1.Z)
                    UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
                    return
                end
            end
        elseif DSCommonfunc.CheckPosition(playerPos,boss_gate_area) then -- boss门口
            UE4.UDsProfileFunctionLib.StopMove()
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(BossPos.X,BossPos.Y,BossPos.Z)
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
        elseif AreaId == 6 and not DSCommonfunc.CheckPosition(playerPos,boss_area) then --不在boss区域内
            DSCommonAction.DelayGetAndMoveToLevelPathPainterEndPath()
        else
            UE4.UDsProfileFunctionLib.StopMoveInput()
            DSCommonAction.UseSkill()
            DSCommonAction.DelayGetAndMoveToLevelPathPainterEndPath()
            DSCommonAction.AutoBattle(monster,monsterType)
            
        end
        -- DSCommonAction.UseNearlyElevator()

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