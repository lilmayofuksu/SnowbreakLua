---
--- Created by wang.
--- DateTime: 2022/05/18 9:10
---
---
require("DS_ProfileTest.Cases.DsAutoMulti1")
require("DS_ProfileTest.Cases.DsAutoMulti2")
require("DS_ProfileTest.Cases.DsAutoMulti3")
require("DS_ProfileTest.Cases.DsAutoMulti4")
require("DS_ProfileTest.Cases.DsAutoMulti5")
require("DS_ProfileTest.Cases.DsAutoMulti6")
require("DS_ProfileTest.Cases.DsAutoMulti9")

BP_LocalPlayerAutoAgent2 = BP_LocalPlayerAutoAgent2 or {}

BP_LocalPlayerAutoAgent2.DeltaTime = 0.1
BP_LocalPlayerAutoAgent2.AGameTaskActor = nil
--- Player
local LocalPlayerAutoAgent = Class()
local PlayerController = nil
BP_LocalPlayerAutoAgent2.IsCaptain = false
local mapid
local captainList
local MetaData = {isMoveSuccess=false,lastAreaId=-1} -- todo 案例流程不该修改 MetaData.lastAreaId，应该改为BP_LocalPlayerAutoAgent2.lastAreaId，让agent2统一修改
local isHaveChangeDamage = false
local lastAreaId = -1 -- todo 应该使用MetaData里的lastAreaId，由于案例4和7里修改了MetaData.lastAreaId 暂时用该变量

--- 获取关卡信息
function LocalPlayerAutoAgent:GetBattleMsg()

    self.IsAlreadyBound = false
    self.AGameTaskActor = nil
    self.GameTask = nil

    self.AGameTaskActor = UE4.AGameTaskActor.GetGameTaskActor(GetGameIns())
    if IsValid(self.AGameTaskActor) then
        -- DSCommonError.tfPrint("INFO","======== LocalPlayerAutoAgent2:OnTaskFinish end Used Time =",DSCommonfunc.GetLevelCurGoTime())
        
        self.AGameTaskActor.OnTaskFinish:Add(
            self,
            function(ThisPtr,FinishResult,LevelTime,FailedReason)
                UE4.UDsProfileFunctionLib.OnlineLevelInfoSettlement(self.AGameTaskActor.AreaId)
                UE4.UDsProfileFunctionLib.RecordSnakeState("Client_EndGame")
                DSAutoTestAgent.iRunDone = 3
                UE4.UDsProfileFunctionLib.PrintOnlineLevelLog()
                DSCommonAction.StopUseSkill = true
                UE4.UDsProfileFunctionLib.StopAim()
                UE4.UDsProfileFunctionLib.CeaseFire()
                UE4.UDsProfileFunctionLib.StopMoveInput()
                UE4.UDsProfileFunctionLib.StopMove()
                DSCommonError.tfPrintf("INFO","======== LocalPlayerAutoAgent2:OnTaskFinish end Used Time = %s , mapid = %s",DSCommonfunc.GetLevelCurGoTime(true),mapid)

                UE4.Timer.Add(25, function()
                    DSCommonError.tfPrint("INFO","======== LocalPlayerAutoAgent2:OnTaskFinish delay end =========")
                    -- UE4.UDsProfileFunctionLib.StopMoveInput()
                    if Map.InFight() then
                    	DSCommonError.tfPrint("INFO","======== LocalPlayerAutoAgent2:OnTaskFinish Launch.End() =========")
                        Online.bGiveUp = true
                        DSCommonError.tfPrint("INFO","======== LocalPlayerAutoAgent2:OnTaskFinish Online.bGiveUp = true =========")
                    	Launch.End()
                    end
                    -- DSCommonError.tfPrint("INFO","======== LocalPlayerAutoAgent2:OnTaskFinish DoRealExit =========")
                    -- Online.DoRealExit()

                    -- 尝试退出
                    DSCommonError.tfPrint("INFO","======== LocalPlayerAutoAgent2:OnTaskFinish DoRealExit =========")
                    DSCommonfunc.DoExitRoomWithClearState()

                    -- 清空场景信息,避免ClearSeq报错的处理
                    PreviewScene.Reset()
                    DSCommonError.tfPrint("INFO","======== LocalPlayerAutoAgent2:OnTaskFinish PreviewScene.Reset() =========")
                end);
            end
        )
        
    end
    captainList =Online.GetCaptain()
    BP_LocalPlayerAutoAgent2.IsCaptain = captainList[1]
    
end



function LocalPlayerAutoAgent:UpdataBattleMsg()
    if self.GameTask == nil then
        self.GameTask = self.AGameTaskActor:GetGameTask()
    end

    if IsValid(self.GameTask) and self.IsAlreadyBound == false then
        DSCommonfunc.SetTotalLevelCountDownTime()
        self.IsAlreadyBound = true

        -- 呼出鼠标,处理无渲染模式下鼠标锁定问题
        if PlayerController then 
            DSCommonError.tfPrint("INFO","PlayerController:ExhaleMouse(true)")
            PlayerController:ExhaleMouse(true)
        end
    end
end

function LocalPlayerAutoAgent:OnGameTaskExecuteChange(ExecuteNode)

    local ExecuteDescriptionID = ExecuteNode.ExecuteDescriptionID
    local bHiddenExectue = ExecuteNode.bHiddenExectue
    local bCanFinish = ExecuteNode.bCanFinish
    local ExecuteDes = ExecuteNode.ExecuteDes
    local TaskItemDes = ExecuteNode.TaskItemDes

    --- 记录当前关卡
    if (ExecuteDescriptionID~=0) then
        DSCommonfunc.movetime = ExecuteDescriptionID
    end

    if ExecuteDes and ExecuteDes ~= "" then
        DSCommonfunc.ExecuteDes[#DSCommonfunc.ExecuteDes + 1] = ExecuteDes
    end

    DSCommonError.tfPrint("INFO","OnGameTaskExecuteChange:",ExecuteDescriptionID,bHiddenExectue,bCanFinish,ExecuteDes)
end

--- 主流程
function LocalPlayerAutoAgent:ReceiveBeginPlay()
    DSCommonError.tfPrint("INFO","======== [tick flow]LocalPlayerAutoAgent2:OnTaskFinish start =========")
    self:GetBattleMsg()
    UE4.UDsProfileFunctionLib.RecordSnakeState("Client_StartGame")
    if not IsValid(PlayerController) then
        PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    end
    mapid = DSCommonfunc.GetOnlineLevelId() or 0
    if PlayerController then 
        UE4.Timer.Add(3, function()
            PlayerController:GMServerCall("OneShot999", "")--先关闭
            PlayerController:GMServerCall("OneShot999",0.22)
        end);
        PlayerController:GMServerCall("StateGod")
        PlayerController:Server_DebugSetReviveCount(20)
    end
    BP_LocalPlayerAutoAgent2.AGameTaskActor = self.AGameTaskActor
    isHaveChangeDamage = false

    DSCommonError.Init()

    DSCommonAction.Init()

    DSCommonfunc.Init()
    -- local mapid = DSCommonfunc.GetOnlineLevelId()
    -- DSCommonError.tfPrint("INFO","======== LocalPlayerAutoAgent2:mapid =",mapid)

    -- DsAutoMulti3.ReceiveBeginPlay()

    DSCommonfunc.DealBeginPlay()
    UE4.UDsProfileFunctionLib.StopMoveInput()
    if DSAutoTestAgent.iRunDone ~= 2 then -- 第一次进地图 而不是重连
        DSAutoTestAgent.iRunDone = 2
        UE4.UDsProfileFunctionLib.SetLastOnlienPlayerNum(CountTB(Online.GetRoomOthers()) + 1)
        DSCommonfunc.ClearStoreDicStatus()
        UE4.UDsProfileFunctionLib.RecordOnlineLevelInfo(mapid,DSAutoTestAgent.G_TokenPid)
        DSCommonfunc.currentMapIdIndex = DSCommonfunc.currentMapIdIndex + 1 -- 让Global_GetNextOnlinelevelMapid方法读取下一张地图
        UE4.UDsProfileFunctionLib.CheckOnlineLevelCrashMap(mapid) --会调用Global_GetNextOnlinelevelMapid
        DSCommonfunc.currentMapIdIndex = DSCommonfunc.currentMapIdIndex - 1
    else --重连回地图
        DSCommonfunc.refreshStorefromStoreDicStatus()
    end
    
    local getTime = os.date("%c");
    DSCommonError.tfPrint("INFO","开启时间为",getTime,",mapid: ",DSCommonfunc.GetOnlineLevelId() or "获取失败")
    UE4.UDsProfileFunctionLib.PrintOnlineLevelLog()
    self.tickcount = 0  --出生后等待

    -- 呼出鼠标,处理无渲染模式下鼠标锁定问题
    if PlayerController then
        DSCommonError.tfPrint("INFO","PlayerController:ExhaleMouse(true)")
        PlayerController:ExhaleMouse(true)
    end
end

function LocalPlayerAutoAgent:ReceiveTick(DeltaTime)
    -- local AMonsterList = UE4.UGameplayStatics.GetAllActorsOfClass(self, UE4.AGameAICharacter)
    -- DSCommonError.tfPrint("INFO","LocalPlayerAutoAgent:ReceiveTick AMonsterList:Length() =",AMonsterList:Length())
    -- local isIsNetworkFailure = UE4.UTGameEngine.IsNetworkFailure()
    -- DSCommonError.tfPrint("INFO","LocalPlayerAutoAgent:ReceiveTick isIsNetworkFailure =",isIsNetworkFailure)

    --断线处理
    -- DSCommonError.DealServerError()
    self:UpdataBattleMsg()

    -- DSCommonError.tfPrint("INFO","======== LocalPlayerAutoAgent2:OnTaskFinish Used Time =",DSCommonfunc.GetLevelCurGoTime())
    BP_LocalPlayerAutoAgent2.DeltaTime = DeltaTime
    if self.tickcount and self.tickcount < 10 then
        self.tickcount = self.tickcount + DeltaTime
        return
    end

    DSCommonfunc.RegularPrint(nil,nil,1.5,DeltaTime,UE4.UDsProfileFunctionLib.PrintPlayersStatus,false)

    -- PrintPlayersStatus()
    if not IsValid(PlayerController) then
        PlayerController = UE4.UGameplayStatics.GetPlayerController(GetGameIns(), 0)
    end
    if not isHaveChangeDamage then --没在游戏中途改过输出
        if DSCommonfunc.GetLevelCurGoTime(false) > 720 then --关卡经过了12分钟
            PlayerController:GMServerCall("OneShot999", "")
            UE4.Timer.Add(1, function()
                PlayerController:GMServerCall("OneShot999",100)
            end);
            isHaveChangeDamage = true
            DSCommonError.tfPrint("INFO","InCrease The Damage")
        elseif DSCommonfunc.GetLevelCurGoTime(false) < 720 then --打到boss的时候已经时间还没12分钟
            if (mapid == 166 and self.AGameTaskActor.AreaId == 5) or --166关卡区域5就是boss
                self.AGameTaskActor.AreaId == 6 then
                    PlayerController:GMServerCall("OneShot999", "")
                UE4.Timer.Add(1, function()
                    PlayerController:GMServerCall("OneShot999",0.01)
                end);
                isHaveChangeDamage = true
                DSCommonError.tfPrint("INFO","DeCrease The Damage")
            end
        end
    end
    if lastAreaId ~= self.AGameTaskActor.AreaId then
        DSCommonError.tfPrintf("INFO","Current area is %d , mapid is %s",self.AGameTaskActor.AreaId,mapid)
        lastAreaId = self.AGameTaskActor.AreaId
    end

    if mapid == 101 or (mapid >= 110 and mapid < 120) then
        DsAutoMulti1:Tick(DeltaTime,self.AGameTaskActor.AreaId,mapid,MetaData)
    elseif mapid == 102 or (mapid >= 120 and mapid < 130) then
        DsAutoMulti2:Tick(DeltaTime,self.AGameTaskActor.AreaId,mapid,MetaData)
    elseif mapid == 103 or (mapid >= 130 and mapid < 140) then
        DsAutoMulti3:Tick(DeltaTime,self.AGameTaskActor.AreaId,mapid,MetaData)
    elseif mapid == 104 or (mapid >= 140 and mapid < 150) then
        DsAutoMulti4:Tick(DeltaTime,self.AGameTaskActor.AreaId,mapid,MetaData)
    elseif mapid == 105 or (mapid >= 150 and mapid < 160) then
        DsAutoMulti5:Tick(DeltaTime,self.AGameTaskActor.AreaId,mapid,MetaData)
    elseif mapid == 106 or (mapid >= 160 and mapid < 170) then
        DsAutoMulti6:Tick(DeltaTime,self.AGameTaskActor.AreaId,mapid,MetaData)
    elseif mapid == 172 then
        DsAutoMulti4:Tick(DeltaTime,self.AGameTaskActor.AreaId,mapid,MetaData)
    elseif mapid == 107 or (mapid >= 170 and mapid < 180) then
        DsAutoMulti1:Tick(DeltaTime,self.AGameTaskActor.AreaId,mapid,MetaData)
    elseif mapid == 197 then
        DsAutoMulti1:Tick(DeltaTime,self.AGameTaskActor.AreaId,mapid,MetaData)
    elseif mapid == 109 or (mapid >= 190 and mapid <= 199) then
        DsAutoMulti9:Tick(DeltaTime,self.AGameTaskActor.AreaId,mapid,MetaData)
    -- 单机测试用
    elseif mapid == 0 then
        mapid = 152
        DsAutoMulti5:Tick(DeltaTime,self.AGameTaskActor.AreaId,mapid,MetaData)
    end

end

return LocalPlayerAutoAgent