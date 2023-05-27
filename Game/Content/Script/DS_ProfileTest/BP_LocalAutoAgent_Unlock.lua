--- 本地Player自动测试-解锁全部关卡
local LocalPlayerAutoAgent = Class()



--- 发送GM网站执行
local SendGMToHttp = function(cmd,count)
    local tbServer = Login.GetServer()
    local trueAddr = tbServer.sAddr
    local url = string.format("http://%s:1234/gm/cmd/run", trueAddr)
    --local url = string.format("http://%s:1234/gm/cmd/run", "10.11.68.215")

    local tbParam = UE4.TMap(UE4.FString, UE4.FString)
    tbParam:Add("cmd",cmd)
    tbParam:Add("pid",string.format("%d",me:Id()))
    if count then
        tbParam:Add("Count",string.format("%d",count))
    end
    
    UE4.UDsProfileFunctionLib.SendFormDataToHttp(url, tbParam)
end

local SendCodeToHttp = function(code, target)
    local tbServer = Login.GetServer()
    local trueAddr = tbServer.sAddr
    local url = string.format("http://%s:1234/gm/script", trueAddr)
    DSCommonError.tfPrint("DEBUG",string.format("http://%s:1234/gm/script", trueAddr))
    local tbParam = {
        code = code;
        target = target or 1;
        pid = me:Id();
    }
    UE4.UGMLibrary.SendJsonToHttp(url, json.encode(tbParam))
end

function LocalPlayerAutoAgent:ReceiveBeginPlay()
    DSCommonError.tfPrint("INFO",'LocalPlayerAutoAgent_Unlock:ReceiveBeginPlay()')
    UE4.UDsProfileFunctionLib.RecordSnakeState("Client_unlock")
    --GuideLogic.SkipAllGuide()
    self.OperationHoldTime = 5
    if DSAutoTestAgent.iStartTime > 0 then
        self.OperationHoldTime = 0.2
    end
    self.OperationTimeCount = 0
    --self.SkipCount = 0
    self.UnlockChapter = 0
    self.LineUp = 0 -- 编队是否完成
    self.CheckLineupOver = false
    self.tbReady = {false}
    self.Index = 0 --主位少女
    self.Config = nil
    if DSAutoTestAgent then
        DSAutoTestAgent.nState = -1
        DSAutoTestAgent.bIsServerError = 0
        DSAutoTestAgent.CurrentMatchWaitTime = 0 --重置等待时间
        DSAutoTestAgent.tbCaptain = Online.GetCaptain()
        DSAutoTestAgent.tbStateFlag = Online.GetStateFlag()
        DSAutoTestAgent.Index = 0
        -- if DSAutoTestAgent.iRunDone~=2 then
        --     DSAutoTestAgent.iRunDone = 3
        -- end
    end
    if Online.GmOpenOne(2) then
        SendCodeToHttp(string.format("Online.GmOpenOne(%d)", 2))
    end
    UE4.UDsProfileFunctionLib.SavePidToFile()
end

function LocalPlayerAutoAgent:IsOperationDone()
    return self.OperationTimeCount >= self.OperationHoldTime
end

function LocalPlayerAutoAgent:LineUpTeam()
    DSCommonError.tfPrint("INFO","LocalPlayerAutoAgent:LineUpTeam()")
    local pCard = nil
    local Cards = UE4.TArray(UE4.UCharacterCard)
    me:GetCharacterCards(Cards,true)
    if Cards:Length() < 4 then
        DSCommonError.tfPrint("WARNING","CharacterCards Too Short")
        DSCommonfunc.GoToLoginLevel()
        return
    end
    for i = 1, Cards:Length() do
        local card = Cards:Get(i)
        DSCommonError.tfPrint("DEBUG","LocalPlayerAutoAgent:LineUpTeam card:id = ",card:Id())
        DSCommonError.tfPrint("DEBUG","LocalPlayerAutoAgent:LineUpTeam card:TemplateId = ",card:TemplateId())
        if card:TemplateId() == DSAutoTestAgent.TemplateIdList[DSAutoTestAgent.lineupCharlist[1]] then
            pCard = card:Id()
            break
        end
    end

    local pCard2,pCard3
    for i = 1, Cards:Length() do
        local card = Cards:Get(i)
        if pCard2 ==nil and card:TemplateId() == DSAutoTestAgent.TemplateIdList[DSAutoTestAgent.lineupCharlist[2]] then
            pCard2 = card:Id()
        end

        if pCard3 ==nil and card:TemplateId() == DSAutoTestAgent.TemplateIdList[DSAutoTestAgent.lineupCharlist[3]] then
            pCard3 = card:Id()
        end

        if pCard2 ~=nil and pCard3 ~=nil then
            break
        end
    end
    
    local tbData = {
        index = 1,
        name = "",
        member1 = pCard or 0,
        member2 = pCard2 or 0,
        member3 = pCard3 or 0,
    }
    DSCommonError.tfPrint("INFO","===================LocalPlayerAutoAgent Req_UpdateLineup==================>",json.encode(tbData))
    -- me:CallGS("Lineup_Update", json.encode(tbData))
    
    UE4.Timer.Add(1.5, function()
            tbData.index = DSAutoTestAgent.OnlinelineUpID
            DSCommonError.tfPrint("INFO","===================LocalPlayerAutoAgent Req_UpdateLineup Timer==================>",json.encode(tbData))
            me:CallGS("Lineup_Update", json.encode(tbData))
        end);
        
end

--检查编队成员
local CheckLineup = function()
    local memsData = me:GetLineupMembers(DSAutoTestAgent.OnlinelineUpID)
    if memsData:Length()~= 3 then return false
    else
         return true
    end
    -- for i = 1, 3 do
    --     if memsData:Get(i) == nil then return false end --空的直接返回false
    --     local cardTemplateId = memsData:Get(i):TemplateId()
    --     if cardTemplateId ~= DSAutoTestAgent.TemplateIdList[DSAutoTestAgent.lineupCharlist[1]] --如果没有一个对的上的
    --     and cardTemplateId ~= DSAutoTestAgent.TemplateIdList[DSAutoTestAgent.lineupCharlist[2]]
    --     and cardTemplateId ~= DSAutoTestAgent.TemplateIdList[DSAutoTestAgent.lineupCharlist[3]] then
    --         return false
    --     end
    -- end
    -- return true
end
--当游戏开始后 不能进行其他操作
function LocalPlayerAutoAgent:CheckGameStatus()
    if Online.GetOnlineState() >= Online.STATUS_ENTER then
        UI.ShowTip("tip.online_RoomStateError")
        return false
    end

    return true
end

function LocalPlayerAutoAgent:DoFight()
    if not self:CheckGameStatus() then
        return
    end

    --没有队长
    if not Formation.GetCaptain() then
        UI.ShowTip("tip.not_captain")
        return
    end

    --关卡信息
    -- if not Online.CheckOnlineLevel(Online.GetOnlineId()) then
    --    UI.ShowTip("tip.congif_err")
    -- --    me:OnlineExitRoom(me:Id())
    --    DSAutoTestAgent.WaitRSP = 0
    --    self.OperationTimeCount = 0
    --    Online.DoExitRoom(nil,  Online.GetMatchState())
    --    DSCommonError.tfPrint("INFO",'LocalPlayerAutoAgent:DoFight() -> UI.ShowTip("tip.congif_err")')
    --    return
    -- end

    --判断体力是否不足
    local  tbConfig = Online.GetConfig(Online.GetOnlineId())
    if tbConfig and tbConfig.nConsumeVigor > 0 and (not Cash.CheckMoney(Cash.MoneyType_Vigour, tbConfig.nConsumeVigor)) then
        return
    end

    --其他判断
    Online.ReadyRoom(DSAutoTestAgent.tbStateFlag[self.Index+1])
    --Online.ReadyRoom(self.tbReady[self.Index+1])
end

local function CreateRoom(self)
    if DSAutoTestAgent.AutoSwitchMap then
        if not DSCommonfunc.AutoSwitchMap() then --如果已经跑完了应跑的地图
            self.OperationTimeCount = 0
            DSCommonError.tfPrint("INFO","Current mapid index:",DSCommonfunc.currentMapIdIndex)
            return
        end
    elseif DSAutoTestAgent.iDsMapID > 0 then
        if DSAutoTestAgent.iSpecifyTime > 0 then
            if DSAutoTestAgent.iSpecifyTime > DSAutoTestAgent.iCurrentRunTime then
                if DSAutoTestAgent.iRunDone == 3 or DSAutoTestAgent.iRunDone == 0 then
                    DSCommonError.tfPrintf("INFO","Done %d",DSAutoTestAgent.iCurrentRunTime)
                    DSAutoTestAgent.iCurrentRunTime = DSAutoTestAgent.iCurrentRunTime + 1
                else
                    DSCommonError.tfPrintf("INFO","Seems like create Room fail,try again")
                end
                DSCommonfunc.SwitchMapId(DSAutoTestAgent.iDsMapID)
            else
                DSCommonError.tfPrintf("INFO","SpecifyTime all done")
                return
            end
        else
            DSCommonfunc.SwitchMapId(DSAutoTestAgent.iDsMapID)
        end
    end
    UE4.Timer.Add(3.5, function()
        self.UnlockChapter = 1 -- 初始号已经配好号，所以要在这里设置一下
        me:OnlineCreateRoom(2, Online.TeamId)
        DSCommonError.tfPrint("INFO",'LocalPlayerDSAutoTestAgent:ReceiveTick() -> OnlineCreateRoom(2, Online.TeamId) Online.TeamId:',Online.TeamId)
    end);
    DSAutoTestAgent.iRunDone = 1
    DSAutoTestAgent.WaitRSP = 1
end

--初始号创房邀请组队流程
local function InviteOperate(self)
    if me:Level() < 10 then
        DSCommonError.tfPrint("WARNING","Player Level Low")
        if (self.UnlockChapter == 0) then
            self.UnlockChapter = 1
            if DSAutoTestAgent.bGetAllItem == 0 then
                SendCodeToHttp("GM.UnLockAllLevel()")
                DSCommonError.tfPrint("INFO",'LocalPlayerDSAutoTestAgent:ReceiveTick() -> SendGMToHttp("解锁所有关卡")')
            end
        elseif (self.UnlockChapter == 1 and DSAutoTestAgent.bGetAllItem == 0 ) then
            if DSAutoTestAgent.bGetAllItem == 0 then
                DSCommonError.tfPrint("INFO",'LocalPlayerDSAutoTestAgent:ReceiveTick() -> SendGMToHttp("一键配号")')
                GuideLogic.SkipAllGuide()
                SendCodeToHttp(string.format("GM.GMOneKeyAddItem(%s)", 80))
                DSAutoTestAgent.bGetAllItem = 1
            end
        elseif self.UnlockChapter == 1 and DSAutoTestAgent.bGetAllItem == 1 then --等级仍然没上来
            DSCommonError.tfPrint("WARNING","The player level is still too low and may need to be Update")
            DSCommonfunc.GoToLoginLevel()
        end
    elseif self.LineUp == 0 then --编队
        self:LineUpTeam()
        self.LineUp = 1
    elseif not self.CheckLineupOver then
        self.CheckLineupOver = true
        if not CheckLineup() then
            DSCommonError.tfPrint("WARNING","A lineup did not correspond detected")
            DSCommonfunc.GoToLoginLevel()
        end
    -- 状态检查结束
    elseif tonumber(string.sub(tostring(DSAutoTestAgent.G_TokenPid),-1,-1)) % 3 == 1 then --尾号1、4、7这种是队长
        if Online.GetOnlineState() == Online.STATUS_INVALID or Online.GetOnlineState() == Online.STATUS_END and DSAutoTestAgent.WaitRSP == 0 then --还没创建房间
            CreateRoom(self)
        elseif CountTB(Online.GetRoomOthers()) + 1 < DSAutoTestAgent.TeamSize then --人没齐
            local merber1 =  UE4.UDsProfileFunctionLib.ReadPidByFile(DSAutoTestAgent.G_TokenPrefix .. tostring(DSAutoTestAgent.G_TokenPid + 1)) 
            local merber2 =  UE4.UDsProfileFunctionLib.ReadPidByFile(DSAutoTestAgent.G_TokenPrefix .. tostring(DSAutoTestAgent.G_TokenPid + 2))
            if merber1 < 1 then
                DSCommonError.tfPrintf("WARNING","Cannot find %s%d,PID:%d",DSAutoTestAgent.G_TokenPrefix,DSAutoTestAgent.G_TokenPid + 1,merber1) 
            end
            if merber2 < 1 then
                DSCommonError.tfPrintf("WARNING","Cannot find %s%d,PID:%d",DSAutoTestAgent.G_TokenPrefix,DSAutoTestAgent.G_TokenPid + 2,merber2) 
            end
            for key, _ in pairs(Online.GetRoomOthers()) do
                if key == merber1 then
                    DSCommonError.tfPrintf("INFO","%s%d in the room,PID:%d",DSAutoTestAgent.G_TokenPrefix,DSAutoTestAgent.G_TokenPid + 1,merber1)
                    merber1 = -1
                elseif key == merber2 then
                    DSCommonError.tfPrintf("INFO","%s%d in the room,PID:%d",DSAutoTestAgent.G_TokenPrefix,DSAutoTestAgent.G_TokenPid + 2,merber2)
                    merber2 = -1
                end
            end
            if merber1 > 0 then
                Online.InvitePlayer(merber1)
                DSCommonError.tfPrintf("INFO","Invite %s%d,PID:%d",DSAutoTestAgent.G_TokenPrefix,DSAutoTestAgent.G_TokenPid + 1,merber1)
            end
            if merber2 > 0 then
                Online.InvitePlayer(merber2)
                DSCommonError.tfPrintf("INFO","Invite %s%d,PID:%d",DSAutoTestAgent.G_TokenPrefix,DSAutoTestAgent.G_TokenPid + 2,merber2)
            end
            DSCommonError.tfPrintf("INFO","wait invite member...")
            -- DSCommonError.tfPrint("INFO","===================LocalPlayerDSAutoTestAgent MatchWaitTime ",DSAutoTestAgent.MaxMatchWaitTime - DSAutoTestAgent.CurrentMatchWaitTime," ==================>")
        elseif Online.GetOnlineState() ~= Online.STATUS_ENTER and
            (DSAutoTestAgent.iStartTime < 1 or os.time() >= DSAutoTestAgent.iStartTime) then --下面就是判断准备了,判断是否设置了指定时间开启
            if DSAutoTestAgent.TeamSize == 1 then 
                Online.ReadyRoom(DSAutoTestAgent.tbStateFlag[self.Index+1])
                DSCommonError.tfPrintf("INFO","Start room time:%s",os.date("%c"))
            elseif DSAutoTestAgent.TeamSize == 2 then --2人队
                local bAllReady = true
                for i=2,#DSAutoTestAgent.tbStateFlag do
                    if DSAutoTestAgent.tbStateFlag[i] ~= Online.Player_State_Ready then
                        bAllReady = false
                        break
                    end
                end
                if #DSAutoTestAgent.tbStateFlag<DSAutoTestAgent.TeamSize then
                    bAllReady = false
                end
                if bAllReady then
                    Online.ReadyRoom(DSAutoTestAgent.tbStateFlag[self.Index+1])
                    DSCommonError.tfPrintf("INFO","Start room time:%s",os.date("%c"))
                end
            elseif DSAutoTestAgent.TeamSize == 3 then --3人队
                if Online.CheckMemberAllReady() then
                    Online.ReadyRoom(DSAutoTestAgent.tbStateFlag[self.Index+1])
                    DSCommonError.tfPrintf("INFO","Start room time:%s",os.date("%c"))
                end
            end
            DSCommonError.tfPrint("INFO","===================LocalPlayerDSAutoTestAgent is Captain==================>")
        end
        -- DSAutoTestAgent.CurrentMatchWaitTime = DSAutoTestAgent.CurrentMatchWaitTime + self.OperationHoldTime
    else --等待队长邀请
        -- if CountTB(Online.GetRoomOthers()) == 0 then --不在房间内
        if Online.GetPreId() == 0 then --不在房间内
            local inviteList = Online.GetCurInviteInfo()
            if inviteList then
                Online.AcceptInvite(inviteList[4],inviteList[3])
                self.UnlockChapter = 1 -- 初始号已经配好号，所以要在这里设置一下
                DSCommonError.tfPrint("INFO",string.format("Accepted %s invite",inviteList[1]))
                DSAutoTestAgent.iRunDone = 1
            else
                DSCommonError.tfPrint("INFO","waiting for invite...")
            end
        -- elseif Online:CheckRoomPlayer() == false then --如果不是队长邀请的房间
        --     DSCommonError.tfPrint("INFO","======== LocalPlayerAutoAgent2:OnTaskFinish DoRealExit =========")
        --     DSCommonfunc.DoExitRoomWithClearState()
        elseif DSAutoTestAgent.tbCaptain[1] then
            DSCommonError.tfPrint("INFO","Captain left!!!")
            DSCommonError.tfPrint("INFO","======== LocalPlayerAutoAgent2:OnTaskFinish DoRealExit =========")
            DSCommonfunc.DoExitRoomWithClearState()
        else
            local nStateFlag = DSAutoTestAgent.tbStateFlag[self.Index+1]
            if nStateFlag ~= Online.Player_State_Ready and
                (DSAutoTestAgent.iStartTime < 1 or os.time() >= DSAutoTestAgent.iStartTime-12) then --队友准备15秒后队长不开会被踢,给个12秒别太极限
                Online.ReadyRoom(DSAutoTestAgent.tbStateFlag[self.Index+1])
                DSCommonfunc.RegularPrint("INFO","Set the status to Ready",1,self.OperationHoldTime)
            end
            DSCommonError.tfPrint("WARNING","Prepared Detected?")
        end
    end
end

--随机号配号创房组队流程
local function RandomAccountOperate(self)
    --配号
    if (self.UnlockChapter == 0) then
        self.UnlockChapter = 1
        if DSAutoTestAgent.bGetAllItem == 0 then
            SendCodeToHttp("GM.UnLockAllLevel()")
            DSCommonError.tfPrint("INFO",'LocalPlayerDSAutoTestAgent:ReceiveTick() -> SendGMToHttp("解锁所有关卡")')
        end
    elseif (self.UnlockChapter == 1 and DSAutoTestAgent.bGetAllItem == 0 ) then
        if DSAutoTestAgent.bGetAllItem == 0 then
            DSCommonError.tfPrint("INFO",'LocalPlayerDSAutoTestAgent:ReceiveTick() -> SendGMToHttp("一键配号")')
            SendCodeToHttp(string.format("GM.GMOneKeyAddItem(%s)", 80))
            DSAutoTestAgent.bGetAllItem = 1
        end
    elseif self.LineUp == 0 then --编队
        self:LineUpTeam()
        self.LineUp = 1
    elseif not self.CheckLineupOver then
        self.CheckLineupOver = true
        if not CheckLineup() then
            DSCommonError.tfPrint("WARNING","A lineup did not correspond detected")
            DSCommonfunc.GoToLoginLevel()
        end
    --进行联机操作
    --1.创建房间
    elseif ((Online.GetOnlineState() == Online.STATUS_INVALID or Online.GetOnlineState() == Online.STATUS_END)
        and self.UnlockChapter == 1 and self.LineUp == 1) and DSAutoTestAgent.WaitRSP == 0 then
            CreateRoom(self)
    elseif (Online.GetOnlineState() == Online.STATUS_OPEN and DSAutoTestAgent.TeamSize~= #DSAutoTestAgent.tbCaptain
        and self.UnlockChapter == 1 and self.LineUp == 1 and not Online.GetMatchState() and DSAutoTestAgent.TeamSize ~= 1 and DSAutoTestAgent.tbCaptain[self.Index+1]) then
        --开启匹配
        Online.MatchSwitch(true)
        DSAutoTestAgent.CurrentMatchWaitTime = 0
        DSCommonError.tfPrint("INFO","===================LocalPlayerDSAutoTestAgent Online.MatchSwitch(true)==================>")
    elseif (Online.GetOnlineState() == Online.STATUS_OPEN
    and self.UnlockChapter == 1 and self.LineUp == 1 and DSAutoTestAgent.tbStateFlag[self.Index+1] ~= Online.Player_State_Ready) then
        DSAutoTestAgent.tbCaptain = DSAutoTestAgent.tbCaptain or Online.GetCaptain()
        DSCommonError.tfPrint("INFO","===================LocalPlayerDSAutoTestAgent Online.ReadyRoom()==================> isCaptain =",DSAutoTestAgent.tbCaptain[self.Index+1])
        DSCommonError.tfPrint("INFO","===================LocalPlayerDSAutoTestAgent Online.ReadyRoom()==================> nStateFlag = ",DSAutoTestAgent.tbStateFlag[self.Index+1])
        local nStateFlag = DSAutoTestAgent.tbStateFlag[self.Index+1]
        if not DSAutoTestAgent.tbCaptain[self.Index+1] and
        nStateFlag ~= Online.Player_State_Ready and (DSAutoTestAgent.iStartTime < 1 or os.time() >= DSAutoTestAgent.iStartTime-12) then -- 如果自己不是队长
                Online.ReadyRoom(DSAutoTestAgent.tbStateFlag[self.Index+1])
                DSCommonError.tfPrint("INFO","Set the status to Ready")
                DSCommonError.tfPrint("INFO","===================LocalPlayerDSAutoTestAgent Online.ReadyRoom==================>")
        elseif DSAutoTestAgent.TeamSize == 1 and (DSAutoTestAgent.iStartTime < 1 or os.time() >= DSAutoTestAgent.iStartTime) then
            Online.ReadyRoom(DSAutoTestAgent.tbStateFlag[self.Index+1])
            DSCommonError.tfPrintf("INFO","Start room time:%s",os.date("%c"))
            DSCommonError.tfPrint("INFO","===================LocalPlayerDSAutoTestAgent Online.ReadyRoom==================>")
        elseif DSAutoTestAgent.TeamSize == 2 and (DSAutoTestAgent.iStartTime < 1 or os.time() >= DSAutoTestAgent.iStartTime) then
            DSCommonError.tfPrint("INFO","===================LocalPlayerDSAutoTestAgent is Captain!!!==================>")
            local bAllReady = true
            for i=2,#DSAutoTestAgent.tbStateFlag do
                if DSAutoTestAgent.tbStateFlag[i] ~= Online.Player_State_Ready then
                    bAllReady = false
                    break
                end
            end
            if #DSAutoTestAgent.tbStateFlag<DSAutoTestAgent.TeamSize then
                bAllReady = false
            end
            if bAllReady then
                Online.ReadyRoom(DSAutoTestAgent.tbStateFlag[self.Index+1])
                DSCommonError.tfPrintf("INFO","Start room time:%s",os.date("%c"))
                DSCommonError.tfPrint("INFO","===================LocalPlayerDSAutoTestAgent Online.ReadyRoom() Captain==================>")
            end
        elseif DSAutoTestAgent.TeamSize == 3 and (DSAutoTestAgent.iStartTime < 1 or os.time() >= DSAutoTestAgent.iStartTime) then
            if Online.CheckMemberAllReady() then
                Online.ReadyRoom(DSAutoTestAgent.tbStateFlag[self.Index+1])
                DSCommonError.tfPrintf("INFO","Start room time:%s",os.date("%c"))
                DSCommonError.tfPrint("INFO","===================LocalPlayerDSAutoTestAgent Online.ReadyRoom22222 ()==================>")
            end
        end
        -- 超过等待时间选择直接开
        DSAutoTestAgent.CurrentMatchWaitTime = DSAutoTestAgent.CurrentMatchWaitTime + self.OperationHoldTime
        DSCommonError.tfPrint("INFO","===================LocalPlayerDSAutoTestAgent MatchWaitTime ",DSAutoTestAgent.MaxMatchWaitTime - DSAutoTestAgent.CurrentMatchWaitTime," ==================>")
        DSCommonError.tfPrint("INFO","LocalPlayerDSAutoTestAgent:ReceiveTick() -> CheckStatus",DSAutoTestAgent,nParam1,DSAutoTestAgent.WaitRSP,Online.GetOnlineState(),DSAutoTestAgent.nErrCode,self.UnlockChapter,self.LineUp)
    end
end


function LocalPlayerAutoAgent:ReceiveTick(DeltaTime)
    if (not DSAutoTestAgent.bOpenAutoAgent) then
        return
    end

    if (not DSAutoTestAgent.bLoginAndInitTeam) then
        return
    end
    
    if (self:IsOperationDone()) then
        DSAutoTestAgent.tbCaptain = Online.GetCaptain()
        DSAutoTestAgent.tbStateFlag = Online.GetStateFlag()

        if (DSAutoTestAgent.nErrCode > 0) then
            DSCommonError.tfPrint("ERROR",'LocalPlayerAutoAgent:ReceiveTick() -> DSAutoTestAgent.nErrCode = ',DSAutoTestAgent.nErrCode)
            if DSAutoTestAgent.nErrCode == 204 then -- 参数错误
                DSCommonError.tfPrint("ERROR","PARAMS ERROR")
                DSCommonfunc.GoToLoginLevel()
            elseif DSAutoTestAgent.nErrCode == 716 then
                -- DSCommonfunc.DoExitRoomWithClearState()
                DSCommonError.tfPrint("ERROR","OnlineRoomState ERROR")
                DSCommonfunc.GoToLoginLevel()
            elseif DSAutoTestAgent.nErrCode == 718 then -- 编队错误问题
                DSCommonError.tfPrint("ERROR","lineup ERROR")
                DSCommonfunc.GoToLoginLevel()
            end
            
            DSAutoTestAgent.WaitRSP = 0
            DSAutoTestAgent.nErrCode = 0
            -- DSAutoTestAgent.nParam1 = 0

            self.OperationTimeCount = 0
            return
        end

        if DSAutoTestAgent.nParam1 == 712 or DSAutoTestAgent.nParam1 == 211798 then --TODO:需要重新验证是否有此参数情况
            DSAutoTestAgent.WaitRSP = 0
            DSAutoTestAgent.nParam1 = 0
            self.OperationTimeCount = 0
            DSCommonfunc.DoExitRoomWithClearState()
            return
        end

        if Online.GetOnlineState() == Online.STATUS_OPEN then --在房间内
            self.Config = self.Config or Online.GetConfig(Online.GetPreId())
            if self.Config ~= nil and DSAutoTestAgent.TeamSize > self.Config.nMaxPlayer then --期望玩家超过房间最大人数
                DSCommonError.tfPrint("ERROR","TeamSize is larger than MaxPlayer！,reset to ",self.Config.nMaxPlayer)
                DSAutoTestAgent.TeamSize = self.Config.nMaxPlayer
            end
        end

        -- 房间状态
        -- 并不需要判断玩家是否在房间内，用联机状态就够了
        if DSAutoTestAgent.CurrentMatchWaitTime>= DSAutoTestAgent.MaxMatchWaitTime and not DSAutoTestAgent.bSpecifyPlayerID then -- 超过等待时间选择直接开,邀请组队模式不需要超时自己进副本机制
            DSCommonError.tfPrint("WARNING","Match Time out")
            DSAutoTestAgent.CurrentMatchWaitTime = 0 --重置等待时间
            Online.ReadyRoom(DSAutoTestAgent.tbStateFlag[self.Index+1])
        elseif self.UnlockChapter == 1 and self.LineUp == 1 and --4:自己退了或者超时不开 5:有人进出了 11:被t了
        (DSAutoTestAgent.nState == 4 or DSAutoTestAgent.nState == 5 or DSAutoTestAgent.nState == 11) then
            DSAutoTestAgent.CurrentMatchWaitTime = 0 -- 重置等待时间
            DSAutoTestAgent.nState = -1
            DSCommonError.tfPrint("INFO","===================LocalPlayerDSAutoTestAgent WaitMatch Retime! ==================>")
        elseif DSAutoTestAgent.bSpecifyPlayerID then
            InviteOperate(self)
        else
            RandomAccountOperate(self)
        end
        self.OperationTimeCount = 0
    end
    self.OperationTimeCount = self.OperationTimeCount + DeltaTime
    --DSCommonError.tfPrint("INFO",'LocalPlayerDSAutoTestAgent:ReceiveTick() OperationTimeCount = ',self.OperationTimeCount)
end

return LocalPlayerAutoAgent
