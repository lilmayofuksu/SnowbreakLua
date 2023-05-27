---
--- Created by wang.
--- DateTime: 2022/05/18 9:10
--- update 2022/10/26


-- require("DS_ProfileTest.Utils.DsCommonAction")


DsAutoMulti2 = DsAutoMulti2 or {}


-- 当前操作执行的最长时间
DsAutoMulti2.OperationHoldTime = 0.02
-- 当前操作计时
DsAutoMulti2.OperationTimeCount = 0
local LadderPoint = UE4.FVector(-6427.163574,2305.399902,700.103821)
local Weak = UE4.FVector()
local playerPos = UE4.FVector()
--- 最终BOSS位置
local BossPos = UE4.FVector(4912.499512,6023.750977,1250.0)
local upstairs = UE4.FVector(-4652.029297,5337.000977,992.513611) --高的怪就上楼
local upstairsOutletArea = { min_x = -4685.545898 , min_y = 3605.820312 , max_x = -4248.401367 , max_y = 5331.859863,min_z = 900,max_z = 1100}
local aim_point = UE4.FVector(-4463.219727,6096.418945,522.523621)--跳下楼用的瞄准点
local area_1 = { min_x = -6682.938965 , min_y = 5146.633301 , max_x = -2137.219971 , max_y =  7581.396973}--有二楼铁栏杆那个区域
local boss_gate = UE4.FVector(4861.168457,8218.592773,1340.155884)--boss门口 导航用的
local boss_area_before_1 = { min_x = 4701.955566 , min_y = 7121.493652 , max_x = 5038.130371 , max_y =  9260.928711}-- boss门口到区域内
local boss_area = { min_x = 2320.279785 , min_y = 3605.820312 , max_x = 7564.286133 , max_y =  8725.94043}
local spwan_area = { min_x = 6096.069336 , min_y = -6307.709961 , max_x = 9726.069336 , max_y =  -4127.709961} --120出生点 避免第一个怪在车上触发高处怪物机制
local spwanPoint_Gate = UE4.FVector(6695.279297,-4019.834229,100.155853)

function DsAutoMulti2.IsOperationDone()
    return DsAutoMulti2.OperationTimeCount >= DsAutoMulti2.OperationHoldTime
end

function DsAutoMulti2:Tick(deltaTime,AreaId,Mapid,MetaData)
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
        if DSCommonAction.RescuePartner(playerPos,monster) ~= false then
            return
        end
        if DSCommonAction.GetOpenStoreInfo(playerPos)~=nil and DSCommonfunc.CheckPosition(playerPos,upstairsOutletArea) then
            UE4.UDsProfileFunctionLib.StopMove()
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(aim_point.X,aim_point.Y,aim_point.Z)
            UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
            DSCommonAction.SwitchRandPlayer()
        elseif DSCommonAction.ComeToNearestBuffStore(playerPos) then --购买商店buff
            UE4.UDsProfileFunctionLib.StopMoveInput()
            UE4.UDsProfileFunctionLib.CeaseFire()
            UE4.UDsProfileFunctionLib.StopAim()
            MetaData.isMoveSuccess = false
        elseif DSCommonfunc.CheckPosition(playerPos,spwan_area) then
            UE4.UDsProfileFunctionLib.MoveTo(spwanPoint_Gate.X,spwanPoint_Gate.Y,spwanPoint_Gate.Z)
        elseif IsValid(monster) and monsterType ~= 2 and DSCommonfunc.CheckPosition(monster:GetTransform().Translation,area_1) and monster:GetTransform().Translation.Z>690 then
            UE4.UDsProfileFunctionLib.MoveTo(upstairs.X,upstairs.Y,upstairs.Z)
            local monster_pos = UE4.UDsProfileFunctionLib.GetMonsterWeakPosition(monster,Weak)
            UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(monster_pos.X,monster_pos.Y,monster_pos.Z)
            UE4.UDsProfileFunctionLib.OpenFire()
            DSCommonAction.UseSkill()
        elseif AreaId == 6 and not DSCommonfunc.CheckPosition(playerPos,boss_area) then --还不在boss房间里
            if DSCommonfunc.CheckPosition(playerPos,boss_area_before_1) then
                UE4.UDsProfileFunctionLib.StopMove()
                UE4.UDsProfileFunctionLib.AimAtSpecifyLocation(BossPos.X,BossPos.Y,BossPos.Z)
                UE4.UDsProfileFunctionLib.StartMoveInput(1.0,0)
            else
                UE4.UDsProfileFunctionLib.MoveTo(boss_gate.X,boss_gate.Y,boss_gate.Z)
            end
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
