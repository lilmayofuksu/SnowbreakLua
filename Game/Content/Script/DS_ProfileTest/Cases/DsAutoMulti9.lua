
-- require("DS_ProfileTest.Utils.DsCommonAction")
-- require("DS_ProfileTest.Utils.DsCommonfunc")

DsAutoMulti9 = DsAutoMulti9 or {}


-- print("======DSCommonfunc.AddBeginPlay=======")


local playerPos = UE4.FVector()


-- 当前操作执行的最长时间
DsAutoMulti9.OperationHoldTime = 0.02
-- 当前操作计时
DsAutoMulti9.OperationTimeCount = 0

DsAutoMulti9.ExecuteDesCountList = {}


function DsAutoMulti9.IsOperationDone()
    return DsAutoMulti9.OperationTimeCount >= DsAutoMulti9.OperationHoldTime
end



function DsAutoMulti9:Tick(deltaTime,AreaId,Mapid,MetaData)

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
        DsAutoMulti9.OperationHoldTime = 0.02

        if DSCommonAction.RescuePartner(playerPos,monster) ~= false then
            return
        end
        -- if DSCommonAction.ComeToNearestBuffStore(playerLocation) then --购买商店buff
        --     UE4.UDsProfileFunctionLib.StopMoveInput()
        --     UE4.UDsProfileFunctionLib.CeaseFire()
        --     UE4.UDsProfileFunctionLib.StopAim()
        --     MetaData.isMoveSuccess = false
        -- else
            UE4.UDsProfileFunctionLib.StopMoveInput()
            DSCommonAction.DelayGetAndMoveToLevelPathPainterEndPath()
            DSCommonAction.UseSkill()
            DSCommonAction.AutoBattle(monster,monsterType)
        -- end
        
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