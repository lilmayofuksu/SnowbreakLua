
-- require("DS_ProfileTest.Utils.DsCommonAction")

DsAutoMulti4 = DsAutoMulti4 or {}

-- 当前操作执行的最长时间
DsAutoMulti4.OperationHoldTime = 0.02
-- 当前操作计时
DsAutoMulti4.OperationTimeCount = 0
local playerPos = UE4.FVector()

local ladder_area_1 = { min_x = -12150.254883 , min_y = -8086.785645 , max_x = -10563.270508 , max_y =  -7666.972168} -- 拐角楼梯那里
-- local boss_bridge_area_1 = { min_x = -12150.254883 , min_y = -8086.785645 , max_x = -10563.270508 , max_y =  -7666.972168} -- 前往boss区域的桥
-- local gate_area_1 = { min_x = -17528.492188 , min_y = -14157.422852 , max_x = -16578.402344 , max_y =  -13164.424805,max_z = -4389 ,min_z = -4387} -- -- 二楼大门
local boss_bridge_area_1 = { min_x = 14674.100586 , min_y = -20897.763672 , max_x = 16005.938477 , max_y =  -14877.819336} -- 前往boss区域的桥
local gate_area_1 = { min_x = -17528.492188 , min_y = -14157.422852 , max_x = -16578.402344 , max_y =  -13164.424805}  -- 二楼大门
local area_5 = { min_x = -4832.467285 , min_y = -9849.657227 , max_x = -4318.428223 , max_y = -7760.8916015625} -- 拿箱子后的那个桥.
local boss_area = { min_x = 14705.076172 , min_y = -12000.200195 , max_x = 15994.15918 , max_y =  -9849.657227} -- boss区域
local machine_area_1 = {min_x = -12791.28418 , min_y = -22966.550781 , max_x = -12611.28418 , max_y =  -22306.550781}

-- start 开始区域 end 结束区域 X坐标 Y坐标
local sYPoint_3 = -17636.789062 -- 前往boss区域的桥 导航失效的地方
local eYPoint_3 = -14195.552734

-- NavigationPoint 导航点
local nVector_1 = UE4.FVector(15052.730469,-13910.342773,-4994.844238) -- 前往boss区域的桥的导航点
local nVector_2 = UE4.FVector(-16590.119141,-13008.383789,-4389.844238) -- 二楼大门的导航点

-- AimPoint 瞄准点
local aVector_1 = UE4.FVector(-10564.801758,-7955.936523,-4994.844238) -- 拐角楼梯左下边
local aVector_2 = UE4.FVector(14365.454102,-13410.603516,-5084.851074) -- boss区域的桥对面的商店
local aVector_3 = UE4.FVector(-4006.185791,-7725.416504,-4994.61377) -- 不记得
local aVector_4 = UE4.FVector(15301.927734,-8849.657227,-4744.844238) -- boss区域瞄准点
local aVector_5 = UE4.FVector(-12721.28418,-21966.550781,-4584.843262) -- 区域1机器堆里出来的瞄准点

function DsAutoMulti4.IsOperationDone()
    return DsAutoMulti4.OperationTimeCount >= DsAutoMulti4.OperationHoldTime
end

-- todo 案例流程不该修改 MetaData.lastAreaId，应该改为BP_LocalPlayerAutoAgent2.lastAreaId，让agent2统一修改

function DsAutoMulti4:Tick(deltaTime,AreaId,mapid,MetaData)
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
        if DSCommonAction.ComeToNearestBuffStore(playerPos) then --购买商店buff
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.CeaseFire()
            UE4.UDsProfileFunctionLib.StopAim()
                if DSCommonfunc.CheckPosition(playerPos,machine_area_1) then
                    UE4.UDsProfileFunctionLib.StopMove()
                    UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_5.X,aVector_5.Y,aVector_5.Z)
                    UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
                elseif DSCommonfunc.CheckPosition(playerPos,ladder_area_1) then -- 拐角楼梯
                    -- UE4.UDsProfileFunctionLib.StopMove()
                    UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_1.X,aVector_1.Y,aVector_1.Z)
                    UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
                elseif AreaId == 6 and DSCommonfunc.CheckPosition(playerPos,boss_bridge_area_1) then -- boss桥 
                    if playerPos.Y>sYPoint_3 and playerPos.Y < eYPoint_3 then
                        UE4.UDsProfileFunctionLib.StopMove()
                        UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_2.X,aVector_2.Y,aVector_2.Z)
                        UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
                    else  -- 这段用导航
                    UE4.UDsProfileFunctionLib.MoveTo(nVector_1.X,nVector_1.Y,nVector_1.Z)
                    end
                elseif DSCommonfunc.CheckPosition(playerPos,area_5) then -- 这个地方导航有问题
                    UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_3.X,aVector_3.Y,aVector_3.Z)
                    UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
                    return -- 战斗会把怪吸过来出问题
                elseif DSCommonfunc.CheckPosition(playerPos,gate_area_1) then 
                    UE4.UDsProfileFunctionLib.MoveTo(nVector_2.X,nVector_2.Y,nVector_2.Z)
                    if UE4.FVector.Dist(nVector_2,playerPos)<50 then
                        MetaData.lastAreaId = AreaId
                    end
                else UE4.UDsProfileFunctionLib.StopMoveInput()     
            end
        elseif DSCommonfunc.CheckPosition(playerPos,machine_area_1) then
                UE4.UDsProfileFunctionLib.StopMove()
                UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_5.X,aVector_5.Y,aVector_5.Z)
                UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
        elseif DSCommonfunc.CheckPosition(playerPos,gate_area_1) then 
            UE4.UDsProfileFunctionLib.MoveTo(nVector_2.X,nVector_2.Y,nVector_2.Z)
            if UE4.FVector.Dist(nVector_2,playerPos)<50 then
                MetaData.lastAreaId = AreaId
            end
        -- elseif areaID == 3 and DSCommonfunc.CheckPosition(playerLocation,area_5) then -- 这个地方导航有问题
        elseif DSCommonfunc.CheckPosition(playerPos,area_5) then -- 这个地方导航有问题
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_3.X,aVector_3.Y,aVector_3.Z)
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
            return -- 战斗会把怪吸过来出问题
        elseif MetaData.lastAreaId ~= AreaId and DSCommonfunc.CheckPosition(playerPos,boss_area) then
            UE4.UDsProfileFunctionLib.StopMove()
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_4.X,aVector_4.Y,aVector_4.Z)
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
            if UE4.FVector.Dist(aVector_4,playerPos)<50 then
                MetaData.lastAreaId = AreaId
            end
        elseif AreaId == 6 and DSCommonfunc.CheckPosition(playerPos,boss_bridge_area_1) then -- boss桥 
            if playerPos.Y>sYPoint_3 and playerPos.Y < eYPoint_3 then
                UE4.UDsProfileFunctionLib.StopMove()
                UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aVector_2.X,aVector_2.Y,aVector_2.Z)
                UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
            else  -- 这段用导航
            UE4.UDsProfileFunctionLib.MoveTo(nVector_1.X,nVector_1.Y,nVector_1.Z)
            end
        else
            --- 正常战斗流程
            UE4.UDsProfileFunctionLib.StopMoveInput()
            DSCommonAction.UseSkill()
            DSCommonAction.DelayGetAndMoveToLevelPathPainterEndPath()
            DSCommonAction.AutoBattle(monster,monsterType)
            if mapid > 146 and mapid < 150 then
                DSCommonAction.DelayGetAndMoveToLevelPathPainterEndPath()
            end
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
