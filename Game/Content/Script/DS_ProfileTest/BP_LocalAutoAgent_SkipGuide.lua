
--- 本地Player自动测试-跳过引导
local LocalPlayerAutoAgent = Class()


function LocalPlayerAutoAgent:ReceiveBeginPlay()
    DSCommonError.tfPrint("INFO",'LocalPlayerAutoAgent_SkipAllGuide:ReceiveBeginPlay() ')
    --GuideLogic.SkipAllGuide()

    self.OperationHoldTime = 5
    self.OperationTimeCount = 0
    self.SkipCount = 0
end

function LocalPlayerAutoAgent:IsOperationDone()
    return self.OperationTimeCount >= self.OperationHoldTime
end


function LocalPlayerAutoAgent:ReceiveTick(DeltaTime)
    if (not DSAutoTestAgent.bOpenAutoAgent) then
        return
    end

    if (not DSAutoTestAgent.bLoginAndInitTeam) then
        return
    end
    
    if (self:IsOperationDone()) then
        if (self.SkipCount == 0) then
            self.SkipCount = 1
            GuideLogic.SkipAllGuide()
            DSCommonError.tfPrint("INFO",'LocalPlayerAutoAgent:ReceiveTick() -> GuideLogic.SkipAllGuide()')
        end

        self.OperationTimeCount = 0
    end

    self.OperationTimeCount = self.OperationTimeCount + DeltaTime
    --DSCommonError.tfPrint("INFO",'LocalPlayerAutoAgent:ReceiveTick() OperationTimeCount = ',self.OperationTimeCount)
end



return LocalPlayerAutoAgent
