----------------------------------------------------------------------------------
-- @File    : ChessGameMode.lua
-- @Brief   : 棋盘GameMode
----------------------------------------------------------------------------------

require "Chess.ChessClient"

local tbClass = Class()

function tbClass:ReceiveBeginPlay()
    if not CheckStandalone() then return end
    
    print("ChessGameMode ReceiveBeginPlay");
    ChessClient:SetGameMode(self)
    GM.TryOpenAdin()

    self.EventReachGrid:Add(self, self.OnEventReachGrid)
    self.EventThroughGrid:Add(self, self.OnEventThroughGrid)
    self.EventUnlockGrid:Add(self, self.OnEventUnlockGrid)
    self.EventUpdateGridEvent:Add(self, self.OnUpdateEvents)
    self.EventClickActor:Add(self, self.OnEventClickActor)
    --self.EventBeginOverlapInteractionActor:Add(self, self.OnBeginOverlapInteractionActor)
    --self.EventEndOverlapInteractionActor:Add(self, self.OnEndOverlapInteractionActor)

    ChessClient:OpenUI()

    if not RunFromEntry then 
        local mapId = UE4.UMapManager.GetMapIdByLevelPath(self:GetWorld());
        if mapId > 0 then 
            local logicMapId =  ChessConfig:GetLogicMapIdByArtMapId(ChessEditor.ModuleName, mapId)
            if logicMapId and logicMapId > 0 then 
                if logicMapId ~= ChessEditor.CurrentMapId then 
                    ChessEditor.CurrentMapId = logicMapId
                    EventSystem.Trigger(Event.NotifyChess2DMapOpened)
                    print("change current mapid", logicMapId);
                end
            end
        end
    end

    if ChessClient.nextModuleName then 
        ChessClient:LoadMapById(ChessClient.nextModuleName, ChessClient.nextMapId, ChessClient.activityId, ChessClient.activityType);
    else 
        ChessEditor:RunFromLastRegion()
    end

    self.TipsEventHandle = EventSystem.On(Event.OnMessageTipsEnd, function()
        if #ChessTools.tbTips == 0 then
            if ChessClient:GetLockControl() then
                ChessClient:SetLockControl(false)
            end
            return
        end
        local tbNewTip = ChessTools.tbTips[1]
        table.remove(ChessTools.tbTips, 1)
        local sNewTip = tbNewTip.sTip
        if tbNewTip.tbCfg and tbNewTip.tbCfg.tbArg.main then
            UI.Open("ChessTips", tbNewTip.tbCfg)
            return
        elseif tbNewTip.bPlotTip then
            ChessClient:SetLockControl(true)
        else
            if ChessClient:GetLockControl() then
                ChessClient:SetLockControl(false)
            end
        end
        UI.ShowTip(sNewTip, tbNewTip.check)
    end)
end


function tbClass:ReceiveEndPlay()
    print("ChessGameMode ReceiveEndPlay");
    ChessData:Save()
    ChessClient:ClearAllData()
    EventSystem.Remove(self.TipsEventHandle)
end


----------------------------------------------------------------------------------
function tbClass:OnEventReachGrid(regionActor, groundActor)
    --local gridId = ChessTools:GridXYToId(groundActor.PosX, groundActor.PosY);
    --ChessEvent:OnEntryGrid(regionActor.RegionId, gridId)
end

function tbClass:OnEventThroughGrid(regionActor, groundActor, rotateZ)
    rotateZ = (rotateZ + 360) % 360
    local x, y = groundActor.PosX, groundActor.PosY
    local gridId = ChessTools:GridXYToId(x, y);
    local regionId = regionActor.RegionId
    ChessEvent:OnEntryGrid(regionId, gridId, rotateZ)

    -- 迷雾记录
    local ret, array = regionActor:GetViewData(false, false);
    if ret then 
        ChessData:ResetRegionView(regionId)
        for i = 1, array:Length() do 
            local value = array:Get(i)
            ChessData:SetRegionViewValue(regionId, i, value);
        end 
    end

    EventSystem.Trigger(Event.NotifyRefreshChessInteraction, {regionActor = regionActor, x = x, y = y})
end

function tbClass:OnEventUnlockGrid(regionActor, groundActor)
    
end

function tbClass:OnUpdateEvents(deltaTime)
    ChessEvent:Tick(deltaTime)
end

---当点击Actor时
function tbClass:OnEventClickActor(actor)
    if not actor then
        return
    end
    if actor.IsGround then 
        if actor.InteractionActor then
            actor = actor.InteractionActor
        else
            return
        end
    end

    local tbTarget = ChessRuntimeHandler:FindTargetByActor(actor)
    if not tbTarget then return end
    if tbTarget.classHandler and tbTarget.classHandler.IsWalkable and tbTarget.classHandler:IsWalkable() then return end

    --local objType = tbTarget.cfg.tbData.objType or 0;

    local tbParam =  {
        needMoveTo = false,     -- 是否需要移动
        groundActor = nil,      -- 移动目的地，如果没有表示不可到达
        actor = actor,          -- 点击的actor
        tbTarget = tbTarget,    -- actor target
    }

    if UE4.UChessLibrary.CheckCanInteraction(ChessClient.gameMode, actor) then 
        tbParam.needMoveTo = false
    else 
        tbParam.needMoveTo = true
        tbParam.groundActor = UE4.UChessLibrary.GetNearestInteractionGround(ChessClient.gameMode, actor)
    end
    local tbDef = ChessClient:GetGridDef(tbTarget.cfg.tpl)
    if not tbDef or not tbDef.Interaction then
        if tbDef and not tbDef.Interaction and actor:HasTag("ShowTipsAfterMoveTo") then 
            local controller = ChessClient:GetPlayerController()
            if controller:MoveToGround(actor,  {self, function()
                EventSystem.Trigger(Event.NotifyShowChessItemTip, tbParam)
            end}) then
                ChessClient:SetShowTipsAfterMoveTo(true)
            else
                EventSystem.Trigger(Event.NotifyShowChessItemTip, tbParam)
            end
        end
        return
    end
    EventSystem.Trigger(Event.NotifyShowChessItemTip, tbParam)
end

-- -- 当玩家碰到交互物件时
-- function tbClass:OnBeginOverlapInteractionActor(actor)
--     EventSystem.Trigger(Event.NotifyShowChessInteraction, actor)
-- end

-- -- 当玩家离开交互物件时
-- function tbClass:OnEndOverlapInteractionActor(actor)
--     EventSystem.Trigger(Event.NotifyHideChessInteraction, actor)
-- end

function tbClass:BP_PlayCustomAnim(InPath, TargetActor, bLooping)
    if not self.AllSequenceRoot then
        self.AllSequenceRoot = {}
    end
    if not TargetActor then
        return
    end
    if not self.AllSequenceRoot[InPath] or not bLooping then
        ---当前Sequence没有播放,播放Sequence并将目标Actor Attach到SequenceRoot上
        local LevelSequence = UE4.UGameAssetManager.GameLoadAssetFormPath(InPath)
        if not LevelSequence then
            return
        end
        local SequencePlayer, SequenceActor = UE4.ULevelSequencePlayer.CreateLevelSequencePlayer(self, LevelSequence)
        if not SequenceActor or not SequencePlayer then
            return
        end
        local ParentActor = TargetActor:GetAttachParentActor()
        SequencePlayer.OnFinished:Add(
            self,
            function()
                if ParentActor then
                    TargetActor:K2_AttachToActor(ParentActor)
                else
                    TargetActor:K2_DetachFromActor()
                end
                SequenceActor:K2_DestroyActor()
                self.AllSequenceRoot[InPath] = nil
            end
        )
        SequencePlayer:PlayLooping(bLooping and -1 or 1)
        local SequenceRoot = UE4.ULevelLibrary.GetSpawnedSequenceRoot(SequenceActor);
        TargetActor:K2_AttachToActor(SequenceRoot)
        self.AllSequenceRoot[InPath] = SequenceActor
    else
        ---当前Sequence正在播放,将目标Actor Attach到SequenceRoot上
        local SequenceActor = self.AllSequenceRoot[InPath]
        local SequencePlayer = SequenceActor:GetSequencePlayer()
        local SequenceRoot = UE4.ULevelLibrary.GetSpawnedSequenceRoot(SequenceActor);
        local ParentActor = TargetActor:GetAttachParentActor()
        ---判断是否已经Attach到SequenceRoot上了
        if ParentActor == SequenceRoot then
            return
        end
        SequencePlayer.OnFinished:Add(
            self,
            function()
                if ParentActor then
                    TargetActor:K2_AttachToActor(ParentActor)
                else
                    TargetActor:K2_DetachFromActor()
                end
                SequenceActor:K2_DestroyActor()
            end
        )
        TargetActor:K2_AttachToActor(SequenceRoot)
    end


end

function tbClass:BP_OnChessDataDirty()
    ChessData:Save()
end
----------------------------------------------------------------------------------
return tbClass
----------------------------------------------------------------------------------