-- ========================================================
-- @File    :
-- @Brief   :
-- @Author  :
-- @DATE    : ${date} ${time}
-- ========================================================
--require("Task.Utils.TaskCommon")

require("DS_ProfileTest.Utils.DsCommonfunc")

local BP_TaskActor = Class()

BP_TaskActor.SynEventHandel = nil

--BP_TaskActor.CurrentFlowNode = nil
--BP_TaskActor.CurrentExecuteNodes = {}
---当前节点改变时的事件通知

BP_TaskActor.GameTask = nil
BP_TaskActor.TaskUMG = nil
BP_TaskActor.__bBindUI = false
BP_TaskActor.CurrentFlowNodes = {}
BP_TaskActor.BufferMaker = {}

function BP_TaskActor:SetGameTask()
    TaskCommon.TaskActor = self
    self.GameTask = self:GetGameTask()
    if not self.GameTask then return end
    
    self.GameTask.OnGameTaskStateChange:Add(
        self,
        function()
            self:OnGameTaskStateChange()
        end
    )
    self.GameTask.OnGameTaskFlowChange:Add(
        self,
        function(ThisPtr, FlowNode)
            self:OnGameTaskFlowChange(FlowNode)
        end
    )
    self.GameTask.OnGameTaskExecuteChange:Add(
        self,
        function(ThisPtr, ExecuteNode)
            self:OnGameTaskExecuteChange(ExecuteNode)
            DSCommonfunc.OnGameTaskExecuteChange(ExecuteNode)
        end
    )
    self.GameTask.OnGameTaskSuddenChange:Add(
        self,
        function(ThisPtr, ExecuteNode)
            self:OnGameTaskSuddenChange(ExecuteNode)
        end
    )
end

function BP_TaskActor:TryStartTask(bOpenUI)
    print("AGameTaskActor::TryStartTask", bOpenUI);
    local openUI = function() 
        if UE4.UGameLibrary.IsOnlineServer(self) then
            self:StartTask()
            return true
        end

        self.TaskUMG = UI.GetUI("Fight")
        if Launch.GetType() == LaunchType.CHAPTER then
            self.bIsAllStarGot = self:IsAllStarGot()
        end

        print("AGameTaskActor:openUI", self.TaskUMG, bOpenUI);
        if not self.TaskUMG and bOpenUI then
            print("AGameTaskActor:TryOpen Fight");
            local ok = false;
            SafeCall(function()
                self.TaskUMG = UI.Open("Fight")
                if self.TaskUMG then
                    -- 防止客户端通知任务的时候还没有taskumg造成任务列表消失
                    if #self.CurrentFlowNodes > 0 then
                        
                        self.TaskUMG.LevelTask:InitFlowList(self.CurrentFlowNodes[#self.CurrentFlowNodes], self.GameTask)
                    end
                    self:StartTask()
                    print("AGameTaskActor: OpenUI OK")
                    ok = true;
                end
            end)
            return ok
        else  
            self:StartTask()
            return true
        end
    end

    local IsOnlineClient = UE4.UGameLibrary.IsOnlineClient(self)
    if not IsOnlineClient then 
        openUI();
        return
    end

    -- 如果是联机，需要等待本地玩家PlayerState同步完毕
    local check;
    check = function() 
        if UE4.UGameLibrary.IsLocalPlayerStateOK(self) and openUI() then 
            return
        else 
            UE4.Timer.Add(0.35, check)
        end
    end
    check();
end

function BP_TaskActor:UnBindGameTaskUIEvent()
    if not self.GameTask or not self.TaskUMG then 
        return
    end
    self.GameTask.OnGameTaskStateChange:Clear()
    self.GameTask.OnGameTaskFlowChange:Clear()
    self.GameTask.OnGameTaskExecuteChange:Clear()
    self.TaskUMG:DoClearListItems(self.TaskUMG.LevelTask.TaskList)
end

function BP_TaskActor:vIn(tbl, value)
    if tbl == nil then
        return false
    end

    for k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

function BP_TaskActor:OnGameTaskStateChange()
end

function BP_TaskActor:OnGameTaskFlowChange(FlowNode)
    if FlowNode == nil then
        return
    end

    -- 开放世界任务单独处理
    if Launch.GetType() == LaunchType.OPENWORLD then 
        EventSystem.Trigger(Event.OnFlowChange, FlowNode)
        return
    end

    if self:vIn(self.CurrentFlowNodes, FlowNode) == false and self.GameTask:FlowIsRoot(FlowNode) then
        if self.TaskUMG then
            self.TaskUMG.LevelTask:InitFlowList(FlowNode,self.GameTask)
        end
        self.CurrentFlowNodes[#self.CurrentFlowNodes + 1] = FlowNode
    else
        EventSystem.Trigger(Event.OnFlowChange, FlowNode)
    end
end

function BP_TaskActor:OnGameTaskExecuteChange(ExecuteNode)
    EventSystem.Trigger(Event.OnExecuteChange, ExecuteNode)
end

function BP_TaskActor:OnGameTaskSuddenChange(ExecuteNode)
    EventSystem.Trigger(Event.OnChallengeStart, ExecuteNode)
end

function BP_TaskActor:ReceiveBeginPlay()
    self.OnTaskFinish:Add(
        self,
        function(ThisPtr,FinishResult,LevelTime,FailedReason)
            local func = function ( ... )
                EventSystem.Trigger(Event.OnLevelFinish, FinishResult, LevelTime,FailedReason)
                if Launch.GetType() == LaunchType.BOSS then
                    if self.ReconnectHandle then
                        EventSystem.Remove(self.ReconnectHandle)
                        self.ReconnectHandle = nil
                    end
                end
                if not self:HasAuthority() or (IsEditor and not RunFromEntry) then
                    if FinishResult == UE4.ELevelFinishResult.Success then
                        ---结算
                        if self.PlaySuccess then
                            UI.Open("Success")
                        else
                            UI.OpenWithCallback("Settlement", function()
                                Audio.PlaySounds(3010)
                            end)
                        end
                    else
                        if self.PlayFailed then
                            UI.Open("Fail")
                        else
                            UI.OpenWithCallback("Settlement", function()
                                Audio.PlaySounds(3010)
                            end)
                        end
                    end
                end
            end
            --防止发通关协议时因为断线卡住
            if self.ReconnectHandle then
                EventSystem.Remove(self.ReconnectHandle)
                self.ReconnectHandle = nil
            end
            self.ReconnectHandle = EventSystem.On(Event.ReconnectSuccess,function()
                --防止没有me而加定时器
                UE4.Timer.Add(1,function ( ... )
                    if me then
                        EventSystem.Trigger(Event.OnLevelFinish, FinishResult, LevelTime,FailedReason)
                    end
                end)
            end)
            TaskCommon.AddHandle(self.ReconnectHandle)
            func()
        end
    )

    self.OnGameTaskStart:Add(
        self,
        function ()
            if self.ReconnectHandle then
                EventSystem.Remove(self.ReconnectHandle)
                self.ReconnectHandle = nil
            end
        end
    )

    self.OnLevelUINotify:Add(
        self,
        function(ThisPtr,UIIndex,UITypeID)
            EventSystem.Trigger(Event.OnLevelUINotify, UIIndex,UITypeID)
        end
    )
    self:InitLevelPainter()

    self.NotifyTimes:Clear()
    self.OnLevelTimeNotify:Add(
        self,
        function(_, InTime)
            EventSystem.Trigger(Event.FightTip, {Type = 2, Msg = InTime})
        end
    )
    for _,v in ipairs({60, 30}) do
        self.NotifyTimes:Add(v)
    end

    self.OnLevelCountDown:Add(self, function (nCountDown)
        -- 爬塔任务面板更新
        if Launch.GetType() == LaunchType.TOWER and self.TaskUMG then
            self.TaskUMG.Star:OnStarTaskChange(false, true, false)
        end
    end)

    --UE4.UWwiseLibrary.PostEvent2D(GetGameIns(), 'enterlevel');
    if self.PlayLevelBeginSound then
        self:RPC_PlayCharacterVoice('enterlevel')
    end
    --[[local EntrySound = math.random(2)
    if EntrySound == 1 then
        UE4.UWwiseLibrary.PostEvent2D(GetGameIns(), 'enterlevel');
    else
        UE4.UWwiseLibrary.PostEvent2D(GetGameIns(), 'enterlevel002');
    end--]]

    --处理强制下线情况
    self.KickOutHandle = EventSystem.On(Event.Kickout, function(sMsg)
        UE4.UGameplayStatics.SetGamePaused(self, true)
    end)
    TaskCommon.AddHandle(self.KickOutHandle)

    self:BindPlayVoice()
end

function BP_TaskActor:ReceiveEndPlay()
    if self.GameTask then
        self.GameTask:End(self)
    end
    if self.ReconnectHandle then
        EventSystem.Remove(self.ReconnectHandle)
        self.ReconnectHandle = nil
    end

    if self.KickOutHandle then
        EventSystem.Remove(self.KickOutHandle)
        self.KickOutHandle = nil
    end

    TaskCommon.ClearHandle()
end

function BP_TaskActor:ResetReconnectHandle()
    if self.ReconnectHandle then
        EventSystem.Remove(self.ReconnectHandle)
        self.ReconnectHandle = nil
    end
end

function BP_TaskActor:FightTip(InKey, InType, IsNodeId)
    local Msg = Text(InKey)
    if IsNodeId and self.GameTask then
        local node = self.GameTask:GetTaskNode(tonumber(InKey))

        if node then
            Msg = node:GetExecuteDescription(true)

            if node.PlayFinishVoice and Launch.GetType() == LaunchType.CHAPTER and not self.bIsAllStarGot then
                self:StarInfoTip(node)
            end
        end
    end
    if Msg and Msg ~= "" then
        EventSystem.Trigger(Event.FightTip, {bShowCompleteTip = true, Type = InType, bShowUIAnim = true, Msg = Msg})
    end
end

function BP_TaskActor:IsAllStarGot()
    local result = true
    if Launch.GetType() ~= LaunchType.CHAPTER then
        return true
    end
    local cfg = ChapterLevel.Get(Launch.GetLevelID())
    if cfg then
        local tbStarInfo = cfg:DidGotStars()
        for _, value in pairs(tbStarInfo) do
            result = result and value
        end
    end
    return result
end

-- 关卡的三星周期提示
function BP_TaskActor:StarInfoTip(Execute)
    if DialogueMgr.IsPlayingSequence() then
        return
    end

    if self.TaskUMG then
        self.TaskUMG:TryPlayStarInfoTip(Execute)
    end
end

function BP_TaskActor:AddBufferMaker(nBuffId, InHandle)
    if self.BufferMaker[nBuffId] then
        EventSystem.Remove(self.BufferMaker[nBuffId])
        self.BufferMaker[nBuffId] = nil
    end
    self.BufferMaker[nBuffId] = InHandle
end

function BP_TaskActor:RemoveBufferMaker(nBuffId)
    if self.BufferMaker[nBuffId] then
        EventSystem.Remove(self.BufferMaker[nBuffId])
    end
end

function BP_TaskActor:GetVictorySequence()
    local PlayCharacter = UE4.UGameplayStatics.GetPlayerCharacter(self, 0)
    if not PlayCharacter then return end
    local pWaepon = PlayCharacter:GetWeapon()
    local TemplateId = PlayCharacter:GetTemplateID()
    local Template = UE4.ULevelLibrary.GetPlayerTemplate(TemplateId)
    local pCard = PlayCharacter:K2_GetPlayerMember()
    local pSkin = pCard:GetSlotItem(5)
    local nSkinLelve = pSkin == nil and 1 or pSkin:Level()
    local WeaponResNameDec = pWaepon.WeaponInfo.ResNameDec
    local DefaultWeaponResNameDec = string.sub(WeaponResNameDec, 0, string.len(WeaponResNameDec) - 1) .. "a"
    local CharacterResNameDec = Template.ResNameDec

    if nSkinLelve > 1 then
        local SequenceRoot = string.format("/Game/Cinematics/%s_%02d_victory/Sequence/", CharacterResNameDec, nSkinLelve)
        --- 找对应皮肤的Sequence
        local SequenceStr = string.format("%s_%02d_%s_victory_Master", CharacterResNameDec, nSkinLelve, WeaponResNameDec)
        local bLoadSuccess, Sequence = self:LoadSequence(SequenceRoot, SequenceStr)
        if bLoadSuccess then
            self:LoadSequenceLight(Sequence, CharacterResNameDec)
            return Sequence, CharacterResNameDec
        end

        if DefaultWeaponResNameDec ~= WeaponResNameDec then
            --- 如果没找到该武器找a枪
            local SequenceStr = string.format("%s_%02d_%s_victory_Master", CharacterResNameDec, nSkinLelve, DefaultWeaponResNameDec)
            local bLoadSuccess, Sequence = self:LoadSequence(SequenceRoot, SequenceStr)
            if bLoadSuccess then
                self:LoadSequenceLight(Sequence, CharacterResNameDec)
                return Sequence, CharacterResNameDec
            end
        end
    end
    local SequenceRoot = string.format("/Game/Cinematics/%s_victory/Sequence/", CharacterResNameDec)
    local SequenceStr = string.format("%s_%s_victory_Master", CharacterResNameDec, WeaponResNameDec)
    local bLoadSuccess, Sequence = self:LoadSequence(SequenceRoot, SequenceStr)
    if not bLoadSuccess then
        --- 如果没有找对对应武器的Sequence就去找a武器的
        local DefaultWeaponResNameDec = string.sub(WeaponResNameDec, 0, string.len(WeaponResNameDec) - 1) .. "a"
        SequenceStr = string.format("%s_%s_victory_Master", CharacterResNameDec, DefaultWeaponResNameDec)
        bLoadSuccess, Sequence = self:LoadSequence(SequenceRoot, SequenceStr)
    end
    self:LoadSequenceLight(Sequence, CharacterResNameDec)
    return Sequence, CharacterResNameDec
end

--- 加载Sequence资源
--- @param InSequencePath string Sequence路径
--- @return boolean 是否加载成功
--- @return ULevelSequence 加载的Sequence资源
function BP_TaskActor:LoadSequence(ParantRoot, FileName)
    local SequencePath = string.format("%s%s.%s", ParantRoot, FileName, FileName)
    local SoftSequencePath = UE4.UKismetSystemLibrary.MakeSoftObjectPath(SequencePath)
    local Sequence = UE4.UGameAssetManager.GameLoadAsset(SoftSequencePath)
    if not Sequence then return false end
    return true, Sequence
end

--- 加载Sequence灯光配置
function BP_TaskActor:LoadSequenceLight(Sequence, CharacterResNameDec)
    local SettlementId = Settlement.GetSettlementLight(CharacterResNameDec)
    local LightStr = "light_"..SettlementId
    local LightRoot = "/Game/Cinematics/Victor_light/"

    local bLoadLight, SequenceLight = self:LoadSequence(LightRoot, LightStr)
    if bLoadLight then
        UE4.ULevelLibrary.ChangeLevelSequenceLight(Sequence, SequenceLight)
    end
    return Sequence, CharacterResNameDec
end

return BP_TaskActor
