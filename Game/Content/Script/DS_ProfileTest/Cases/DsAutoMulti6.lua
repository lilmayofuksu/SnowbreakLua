
-- require("DS_ProfileTest.Utils.DsCommonAction")
-- require("DS_ProfileTest.Utils.DsCommonfunc")

DsAutoMulti6 = DsAutoMulti6 or {}


-- print("======DSCommonfunc.AddBeginPlay=======")


local playerPos = UE4.FVector()

local area_1 = { min_x = -11482.797852 , min_y = 8107.355469 , max_x = -11269.524414 , max_y =  8441.866211}-- 前往boss区域路上的障碍区域
local boss_area_before_1 = { min_x = -9775.929688 , min_y = 2895.723145 , max_x = -8640.598633 , max_y =  7842.331543}-- boss区域前
local boss_area_before_2 = { min_x = -5310.663574 , min_y = 23589.417969 , max_x = -4664.8994140625 , max_y =  26141.267578}-- 162 boss区域前

-- NavigationPoint 导航点
local nVector_1 = UE4.FVector(-9291.805664,2895.723145,4812.026367) -- boss区域内
local nVector_2 = UE4.FVector(-11106.960938,7887.837402,5790.175293) -- 绕开boss区域路上的障碍点
local nVector_3 = UE4.FVector(-4942.629883,28143.71875,5811.959961) -- 162的boss点

-- AimPoint 瞄准点
local aVector_1 = UE4.FVector(-9183.881836,7037.806641,5688.020996) -- boss坑边上 配合nVector_5使用的
--- 最终BOSS位置
local BossPos = UE4.FVector(-9700.954102,8896.349609,3492.417969)


-- 当前操作执行的最长时间
DsAutoMulti6.OperationHoldTime = 0.02
-- 当前操作计时
DsAutoMulti6.OperationTimeCount = 0

DsAutoMulti6.ExecuteDesCountList = {}


function DsAutoMulti6.IsOperationDone()
    return DsAutoMulti6.OperationTimeCount >= DsAutoMulti6.OperationHoldTime
end



function DsAutoMulti6:Tick(deltaTime,AreaId,Mapid,MetaData)

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
        -- local playerPos = UE4.FVector()
        playerPos = UE4.UDsProfileFunctionLib.GetPlayerLocation()
        -- 战斗流程
        -- DSCommonfunc.AutoHealSelf(0.9)
        --- 正常战斗流程
        DsAutoMulti6.OperationHoldTime = 0.02

        if DSCommonAction.RescuePartner(playerPos,monster) ~= false then
            return
        end
        if DSCommonAction.ComeToNearestBuffStore(playerPos) then --购买商店buff
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.CeaseFire()
            UE4.UDsProfileFunctionLib.StopAim()
            MetaData.isMoveSuccess = false
            if AreaId == 6 and DSCommonfunc.CheckPosition(playerPos,area_1) then
                UE4.UDsProfileFunctionLib.MoveTo(nVector_2.X,nVector_2.Y,nVector_2.Z)
            end
        elseif DSCommonfunc.CheckPosition(playerPos,boss_area_before_1) then
            UE4.UDsProfileFunctionLib.StopMove()
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(nVector_1.X,nVector_1.Y,nVector_1.Z)
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
        elseif DSCommonfunc.CheckPosition(playerPos,boss_area_before_2) and AreaId > 4 then -- 164貌似有问题
            UE4.UDsProfileFunctionLib.StopMove()
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(nVector_3.X,nVector_3.Y,nVector_3.Z)
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
        elseif AreaId == 5 and not MetaData.isMoveSuccess then
            UE4.UDsProfileFunctionLib.GetAndMoveToLevelPathPainterEndPath(GetGameIns())
            MetaData.isMoveSuccess = true
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