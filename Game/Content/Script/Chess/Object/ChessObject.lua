----------------------------------------------------------------------------------
-- @File    : ChessObject.lua
-- @Brief   : 棋盘上的物件 
----------------------------------------------------------------------------------

---@class ChessTools 棋盘上的物件
ChessObject = ChessObject or { }

----------------------------------------------------------------------------------
--- 注册 - 宝箱
----------------------------------------------------------------------------------
local tbRewardBox = {
    szName = "宝箱",
    tbParams = {
        {id = "id", desc = "奖励id", type = ChessEvent.InputTypeRewardId, hint = "奖励id"},
        {id = "spawnParticle", desc = "出现特效id", type = ChessEvent.InputTypeParticleId, hint = "宝箱出现时播放的特效"},
        {id = "particle", desc = "消失特效id", type = ChessEvent.InputTypeParticleId, hint = "领奖时播放的特效"},
        {id = "reappear", desc = "再次出现", type = ChessEvent.InputTypeCheckBox, hint = "已经领奖后，重置后物件是否再次出现"},
    }
}

function tbRewardBox:OnObjectAppear()
    local classArg = self.tbTargetData.cfg.tbData.classArg
    local actor = self.tbTargetData.actor
    if classArg.spawnParticle and actor then
        UE4.UWwiseLibrary.PostEventAttachedActor(Audio.Get(2009), actor)
        ChessTools:PlayEffect(actor, classArg.spawnParticle and classArg.spawnParticle[1])
        ChessClient:SetDataDirty()
    end
end

function tbRewardBox:OnInteraction()
    local classArg = self.tbTargetData.cfg.tbData.classArg
    if classArg.id and type(classArg.id) == "table" then 
        ChessData:SetReward(classArg.id[1], function()
            --- 领奖之后的操作
            ChessObject:HideObject(self.tbTargetData)
            ChessRuntimeHandler:SetTargetIsUsed(self.tbTargetData)
            ChessObject:NotifyObjectComplete(self.tbTargetData)

            --- write log
            local actor = self.tbTargetData.actor
            if actor then
                if actor:HasTag("treasurebox1") then
                    local now, max = ChessTools:GetBoxCount("treasurebox1")
                    ChessClient:WriteOperationLog(1, string.format("%d-%d-%d", classArg.id[1], now, max))
                elseif actor:HasTag("treasurebox2") then
                    local now, max = ChessTools:GetBoxCount("treasurebox2")
                    ChessClient:WriteOperationLog(2, string.format("%d-%d-%d", classArg.id[1], now, max))
                end
            end
            ChessClient:SetDataDirty()
            UE4.UWwiseLibrary.PostEventAttachedActor(Audio.Get(2010), actor)
        end)
    end
end

function tbRewardBox:CanReward()
    local classArg = self.tbTargetData.cfg.tbData.classArg
    if classArg.id and type(classArg.id) == "table" then 
        if RunFromEntry then
            local taskGroup, taskStartId, taskEndId = ChessReward:GetActivityRewardTask(ChessData.activityId, ChessData.activityType) 
            return not ChessReward:IsGetReward(taskGroup, taskStartId, classArg.id[1])
        else
            return ChessData:CanReward(classArg.id[1])
        end
    end
end

----------------------------------------------------------------------------------
--- 注册 - 门
----------------------------------------------------------------------------------
local tbDoor = {
    szName = "门",
    tbParams = {
        {id = "open", desc = "打开", type = ChessEvent.InputTypeCheckBox, hint = "门是否打开/关闭"},
        {id = "costItem", desc = "消耗道具", type = ChessEvent.InputTypeItemId, hint = "打开门所需要消耗的道具,不配则用其他事件打开"},
        {id = "costItemCount", desc = "消耗道具数量3", type = ChessEvent.InputTypeText, hint = "默认1"}
    }
}

function tbDoor:OnGameInit()
    local tbArg = self:GetArg()
    if not tbArg.open then return end

    self:OpenOrCloseDoor(true, true, 0)
end

function tbDoor:HideTipsButton()
    local tbArg = self:GetArg()
    if not tbArg.costItem then
        return true
    end
    return false
end

--- 是否可以互动
function tbDoor:CanInteraction()
    if ChessRuntimeHandler:GetTargetShowState(self.tbTargetData) == 1 then 
        return false
    end
    return true;
end

function tbDoor:IsWalkable()
    if ChessRuntimeHandler:GetTargetShowState(self.tbTargetData) == 0 then 
        return false
    end
    return true;
end

function tbDoor:OnGameStart()
    local state = ChessRuntimeHandler:GetTargetShowState(self.tbTargetData) 
    if state == 1 then 
        self.tbTargetData.actor.ForceWalkable = true
    end
end

function tbDoor:OnInteraction()
    local tbArg = self:GetArg()
    local actor = self.tbTargetData.actor
    if tbArg.costItem then
        local costItem = tbArg.costItem
        local count = tonumber(tbArg.costItemCount) or 1
        if ChessData:GetItemCount(costItem[1]) >= count then
            ChessData:UseItem(costItem[1], count)
            UE4.UWwiseLibrary.PostEventAttachedActor(Audio.Get(2008), actor)
            self:OpenOrCloseDoor(1, false, 1)
        else
            ChessTools:ShowTip(Text("tip.NotEnoughItem"))
        end
    end
end

function tbDoor:GetArg()
    return self.tbTargetData.cfg.tbData.classArg or {}
end

function tbDoor:OpenOrCloseDoor(value, immediately, openType)
    local n = value and 1 or 0
    local oldState = ChessRuntimeHandler:GetTargetShowState(self.tbTargetData) 
    ChessRuntimeHandler:SetTargetShowState(self.tbTargetData, n) 
    local tplId = self.tbTargetData.cfg.tpl
    local tbCfg = ChessClient:GetGridDef(tplId)
    if tbCfg and #tbCfg.State0 > 0 then 
        local tbState = tbCfg["State" .. n] 
        local tbOldState = tbCfg["State" .. oldState]
        for i, tb in ipairs(tbState) do 
            if immediately then 
                ChessTools:SetActorMaterialParam(self.tbTargetData.actor, tb.type, tb.mat, tb.name, tb.value, tb.value, 0, tb.delay)
            else
                local fromData ;
                for _, tb2 in ipairs(tbOldState) do 
                    if tb2.name == tb.name then 
                        fromData = tb2;
                        break;
                    end
                end
                if fromData then 
                    ChessTools:SetActorMaterialParam(self.tbTargetData.actor, tb.type, tb.mat, tb.name, fromData.value, tb.value, tb.time or 0, tb.delay)
                end
            end
        end
    end
    self.tbTargetData.actor.ForceWalkable = n == 1
    if n == 1 then 
        local regionId, gridId = ChessData:GetPlayerPos()
        local x1, y1 = ChessTools:GridIdToXY(gridId)
        local x2, y2 = table.unpack(self.tbTargetData.pos)
        if math.abs(x1 - x2) + math.abs(y1 - y2) > 5 and openType ~= 0 then
            ChessClient:PlayCameraShow(self.tbTargetData.actor)
        end
        if openType == 1 then
            ChessTools:ShowTip(Text("ui.TxtChessTips8"))
        elseif openType == 2 then
            ChessTools:ShowTip(Text("ui.TxtChessTips10"))
        end
        ChessObject:NotifyObjectComplete(self.tbTargetData)
    end
    ChessClient:UpdateRegionPathFinding()
end


----------------------------------------------------------------------------------
--- 注册 - 道具箱子
----------------------------------------------------------------------------------
local tbItemBox = {
    szName = "道具箱子",
    tbParams = {
        {id = "id", desc = "打开", type = ChessEvent.InputTypeItemId, hint = "道具id"},
        {id = "count", desc = "数量", type = ChessEvent.InputTypeText, hint = "默认1"},
        {id = "plotId", desc = "剧情Id", type = ChessEvent.InputTypePlotId, hint = "剧情id"},
        {id = "sequenceId", desc = "sequenceId", type = ChessEvent.InputTypeSequenceId, hint = "播放的sequenceId"},
    }
}

function tbItemBox:OnGameStart()
    local classArg = self.tbTargetData.cfg.tbData.classArg
    local actor = self.tbTargetData.actor
    if not classArg.sequenceId or type(classArg.sequenceId) ~= "table" then
        return
    end
    local sequenceId = classArg.sequenceId[1]
    local cfg = ChessClient:GetSequenceDef(sequenceId);
    ChessClient.gameMode:BP_PlayCustomAnim(cfg.Path, actor, cfg.Loop)
end

function tbItemBox:OnInteraction()
    local classArg = self.tbTargetData.cfg.tbData.classArg
    local actor = self.tbTargetData.actor
    local plotId = 0
    if classArg.plotId and type(classArg.plotId) == "table" then
        plotId = classArg.plotId[1] or 0
    end
    if classArg.id and type(classArg.id) == "table" then 
        if plotId > 0 then 
            local cfg = ChessConfig:GetPlotDefineByModuleName(ChessClient.moduleName).tbId2Data[plotId]
            UI.GetUI("ChessMain"):SetShowOrHide(false)
            UE4.UUMGLibrary.PlayPlot(GetGameIns(), cfg.PlotId, {GetGameIns(), function(lication, CompleteType)
                UE4.Timer.Add(0.01, function()
                    UE4.UWwiseLibrary.PostEventAttachedActor(Audio.Get(2012), actor)
                    UI.GetUI("ChessMain"):SetShowOrHide(true)
                    local id = classArg.id[1];
                    local data = ChessClient:GetItemDef().tbId2Data[id]
                    ChessTools:ShowTip(Text("ui.TxtChessTips2", Text(data.Name)), true)
                    ChessData:AddItemCount(id, 1)
                    ChessObject:HideObject(self.tbTargetData)
                    ChessObject:NotifyObjectComplete(self.tbTargetData)
                end)
            end})
        else
            UE4.UWwiseLibrary.PostEventAttachedActor(Audio.Get(2012), actor)
            local id = classArg.id[1];
            local data = ChessClient:GetItemDef().tbId2Data[id]
            ChessTools:ShowTip(Text("ui.TxtChessTips2", Text(data.Name)), true)
            ChessData:AddItemCount(id, 1)
            ChessObject:HideObject(self.tbTargetData)
            ChessObject:NotifyObjectComplete(self.tbTargetData)
        end
    end
end



----------------------------------------------------------------------------------
--- 注册 - 战斗
----------------------------------------------------------------------------------
local tbFight = {
    szName = "战斗",
    tbParams = {
        {id = "id", desc = "战斗id", type = ChessEvent.InputTypeFightId, hint = "战斗id"},
    }
}

function tbFight:DoInteraction()
    local classArg = self.tbTargetData.cfg.tbData.classArg
    if not classArg.id or type(classArg.id) ~= "table" then return end

    local id = classArg.id[1] or 0
    if id > 0 then 
        local regionId = self.tbTargetData.regionId
        local objId = self.tbTargetData.id
        local type = self.tbTargetData.isGround and 1 or 2
        ChessClient:BeginFight(id, {type = type, id = objId, regionId = regionId})
    else 
        ChessObject:HideObject(self.tbTargetData)
        ChessObject:NotifyObjectComplete(self.tbTargetData)
    end
end

function tbFight:OnInteraction()
    if self:IsFirstPass() then
        self:DoInteraction()
    else
        UI.Open("MessageBox", Text("ui.TxtChessSkip"),
        function()
            ChessObject:HideObject(self.tbTargetData)
            ChessObject:NotifyObjectComplete(self.tbTargetData)
        end, function() self:DoInteraction() end)
    end
end

function tbFight:GetPreviewInfo()
    local classArg = self.tbTargetData.cfg.tbData.classArg
    if not classArg.id or type(classArg.id) ~= "table" then return end

    local id = classArg.id[1] or 0
    if id <= 0 then 
        return
    end
    local cfg = ChessConfig:GetFightDefineByMoudleName(ChessClient.moduleName).tbId2Data[id]
    assert(cfg, string.format("关卡id=%d不存在", id))
    local AllShowItems = {}
    table.insert(AllShowItems, {tbItems = Drop.GetPreview(cfg.FirstDropID), bIsFirst = true, bGeted = not self:IsFirstPass()})
    table.insert(AllShowItems, {tbItems = Drop.GetPreview(cfg.BaseDropID)})
    table.insert(AllShowItems, {tbItems = Drop.GetPreview(cfg.RandomDropID)})
    return AllShowItems, cfg.Rank
end

function tbFight:IsFirstPass()
    local classArg = self.tbTargetData.cfg.tbData.classArg
    if not classArg.id or type(classArg.id) ~= "table" then return end

    local id = classArg.id[1] or 0
    if id <= 0 then 
        return
    end
    local cfg = ChessConfig:GetFightDefineByMoudleName(ChessClient.moduleName).tbId2Data[id]
    assert(cfg, string.format("关卡id=%d不存在", id))
    return cfg:IsFirstPass()
end

function tbFight:GetTipsDesc()
    local classArg = self.tbTargetData.cfg.tbData.classArg
    if not classArg.id or type(classArg.id) ~= "table" then return end

    local id = classArg.id[1] or 0
    if id <= 0 then 
        return
    end
    local cfg = ChessConfig:GetFightDefineByMoudleName(ChessClient.moduleName).tbId2Data[id]
    assert(cfg, string.format("关卡id=%d不存在", id))
    return cfg.Desc
end

----------------------------------------------------------------------------------
--- 注册 - 剧情
----------------------------------------------------------------------------------
local tbPlot = {
    szName = "剧情",
    tbParams = {
        {id = "id", desc = "剧情id", type = ChessEvent.InputTypePlotId, hint = "门是否打开/关闭"},
        {id = "item", desc = "道具id", type = ChessEvent.InputTypeItemId, hint = "需要持有或者消耗的道具id"},
        {id = "itemCount", desc = "道具数量", type = ChessEvent.InputTypeText, hint = "默认0 为0时表示只需要持有 大于0时表示需要消耗"},
    }
}

function tbPlot:OnInteraction()
    local classArg = self.tbTargetData.cfg.tbData.classArg
    if not classArg.id or type(classArg.id) ~= "table" then return end
    if UI.IsOpen("ChessTips") then return end

    if classArg.item then
        local itemCount = tonumber(classArg.itemCount) or 0
        if ChessData:GetItemCount(classArg.item[1]) <= 0 then
            ChessTools:ShowTip(Text("tip.NotEnoughItem"))
            return
        end
        if itemCount > 0 then
            ChessData:UseItem(classArg.item[1], itemCount)
        end
    end

    local cartoonId = classArg.id[1] or 0
    if cartoonId > 0 then 
        local cfg = ChessConfig:GetPlotDefineByModuleName(ChessClient.moduleName).tbId2Data[cartoonId]
        if not cfg then return end 

        UI.GetUI("ChessMain"):SetShowOrHide(false)
        UE4.UUMGLibrary.PlayPlot(GetGameIns(), cfg.PlotId, {GetGameIns(), function(lication, CompleteType)
            ChessObject:HideObject(self.tbTargetData)
            UE4.Timer.Add(0.01, function()
                UI.GetUI("ChessMain"):SetShowOrHide(true)
                ChessObject:NotifyObjectComplete(self.tbTargetData)
            end)
        end})
    else 
        ChessObject:HideObject(self.tbTargetData)
        ChessObject:NotifyObjectComplete(self.tbTargetData)
    end
end


----------------------------------------------------------------------------------
--- 注册 - 重置装置
----------------------------------------------------------------------------------
local tbResetBox = {
    szName = "重置装置",
    tbParams = {
        {id = "id", desc = "物件列表", type = ChessEvent.InputTypeObjectId, hint = "选择要重置的物件列表"},
        {id = "boxReceive", desc = "接收器列表", type = ChessEvent.InputTypeObjectId, hint = "选择关联的接收器，重置时会隐藏上面的特效"},
        {id = "particle", desc = "特效id", type = ChessEvent.InputTypeParticleId, hint = "重置时播放的特效"}
    }
}

function tbResetBox:DoInteraction()
    local actor = self.tbTargetData.actor
    local classArg = self.tbTargetData.cfg.tbData.classArg

    local tbList = ChessRuntimeHandler:FindTargetByTagAndId(nil, classArg.id) 
    local ok;
    for _, tbTargetData in ipairs(tbList) do 
        local cfg = tbTargetData.cfg
        local gridId = ChessTools:GridXYToId(cfg.pos[1], cfg.pos[2])
        local regionId = tbTargetData.regionId
        ok = ChessRuntimeHandler:SetTargetPosition(tbTargetData, regionId, gridId) or ok
    end
    if ok then 
        UE4.UWwiseLibrary.PostEventAttachedActor(Audio.Get(2007), actor)
        ChessClient:WriteOperationLog(3, string.format("%d,%d", actor.posX, actor.posY))
        ChessClient:SetDataDirty()
        ChessClient:UpdateRegionPathFinding()
    end

    -- 隐藏接收器身上的特效
    local tbList = ChessRuntimeHandler:FindTargetByTagAndId(nil, classArg.boxReceive)
    for _, tbTargetData in ipairs(tbList) do 
        local classHandler = tbTargetData.classHandler
        if classHandler and classHandler.classname == "box_receiver" then 
            classHandler:DestroyEffect()
        end
    end

    ChessTools:PlayEffect(actor, classArg.particle and classArg.particle[1])
    ChessTools:ShowTip("ui.TxtChessTips", true)
end

function tbResetBox:OnInteraction()
    UI.Open("MessageBox", Text("ui.TxtChessTips7"), function() self:DoInteraction() end)
end

----------------------------------------------------------------------------------
--- 注册 - 箱子接收器
----------------------------------------------------------------------------------
local tbBoxReceive = {
    szName = "箱子接收器",
    tbParams = {
        {id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "检测的物件id，可以选多个Id或者不选，不选时默认任意物件"},
        {id = "particle", desc = "特效id", type = ChessEvent.InputTypeParticleId, hint = "上面有箱子时播放特效，否则隐藏特效"}
    }
}

-- 当游戏开始时
function tbBoxReceive:OnGameStart()    
    local tbGround = ChessRuntimeHandler:GetActorAllGroundData(self.tbTargetData)
    local ok = false;
    for i = 1, #tbGround do 
        ChessRuntimeHandler:ForeachObjectInGround(tbGround[i], function(objectData)
            if objectData ~= self.tbTargetData and not ok then 
                ok = self:CheckTaget(objectData)
            end
        end)
        if ok then break end
    end
    if ok then 
        self:PlayEffect()
    end
end

-- 当出现物件时
-- tbObjecttData: 出现的物件数据
function tbBoxReceive:OnObjectAppear(tbObjectData)
    local actor = self.tbTargetData.actor
    if self.effectId then return end
    if not self:CheckTaget(tbObjectData) then return end
    self:PlayEffect()
    UE4.UWwiseLibrary.PostEventAttachedActor(Audio.Get(2006), actor)
    ChessObject:NotifyObjectComplete(self.tbTargetData)
    ChessClient:SetDataDirty()
end

function tbBoxReceive:PlayEffect()
    local tbArg = self:GetArg()
    if not tbArg.particle then return end 
    
    local actor = self.tbTargetData.actor
    self.effectId = ChessTools:PlayEffect(actor, tbArg.particle and tbArg.particle[1], true)
end

-- 当丢失物件时
-- 丢失的物件数据
function tbBoxReceive:OnObjectDisappear(tbObjectData)
    if not self:CheckTaget(tbObjectData) then return end
    self:DestroyEffect()
end

-- 隐藏特效
function tbBoxReceive:DestroyEffect()
    if self.effectId then 
        ChessClient.gameMode:DestroyEffect(self.effectId)
        self.effectId = nil
    end
end

-- 检测目标是否正确
function tbBoxReceive:CheckTaget(tbObjectData)
    local tbArg = self:GetArg()
    local tbId = tbArg.objectId
    if not tbId or #tbId == 0 then return true end

    if tbObjectData.cfg.tbData then 
        local ids = tbObjectData.cfg.tbData.id
        return ChessTools:Check_tb1_contain_tb2(tbId, ids)
    end
    return false;
end

function tbBoxReceive:GetArg()
    return self.tbTargetData.cfg.tbData.classArg or {}
end

----------------------------------------------------------------------------------
--- 注册 - Npc
----------------------------------------------------------------------------------
local tbNpc = {
    szName = "Npc",
    tbParams = {
        {id = "id", desc = "npcid", type = ChessEvent.InputTypeNpcId, hint = "npcid"},
        {id = "plotId", desc = "剧情id", type = ChessEvent.InputTypePlotId, hint = "剧情id"},
    }
}

-- 当游戏开始时
function tbNpc:OnGameStart()
    local classArg = self.tbTargetData.cfg.tbData.classArg
    local actor = self.tbTargetData.actor
    local objectId = 0

    if not classArg.id or type(classArg.id) ~= "table" then return end
    if self.tbTargetData.cfg.tbData.id and type(self.tbTargetData.cfg.tbData.id) == "table" then
        objectId = self.tbTargetData.cfg.tbData.id[1]
    end
    if objectId ~= 0 and ChessData:GetObjectCompleteCount(objectId) > 0 then return end
    
    local npcId = classArg.id[1] or 0
    if npcId > 0 then
        local npcCfg = ChessClient:GetNpcDef(npcId)
        actor.regionActor:SpawnNpc(actor, npcCfg.ModelPath)
        local cfg = ChessClient:GetParticleDef(npcCfg.ParticleId)
        if cfg and actor.BindingNpc then 
            local localtion = actor:K2_GetActorLocation() + UE.FVector(cfg.Offset[1] or 0, cfg.Offset[2] or 0, cfg.Offset[3] or 0)
            local rotate = UE4.FRotator(0,0,0)
            actor.BindingNpc:AttachEffect(cfg.Path, localtion, rotate)
        else
            UE.UUMGLibrary.LogError("特效id不存在，无法挂载到npc上：" .. cfg.ParticleId)
        end
    end
    if actor.BindingNpc and (self.tbTargetData.cfg.tbData.hide == true or (objectId ~= 0 and not ChessData:GetObjectIsActive(objectId))) then 
        actor.BindingNpc:SetActiveState(false)
    end
end

function tbNpc:CanInteraction()
    local classArg = self.tbTargetData.cfg.tbData.classArg
    if not classArg.plotId or type(classArg.plotId) ~= "table" then return false end

    local cartoonId = classArg.plotId[1] or 0
    if cartoonId <= 0 then return false end

    local cfg = ChessConfig:GetPlotDefineByModuleName(ChessClient.moduleName).tbId2Data[cartoonId]
    if not cfg then return false end 

    local actor = self.tbTargetData.actor
    if not actor or not actor.BindingNpc or not actor.BindingNpc.IsActive then
        return false
    end

    return true
end

function tbNpc:OnInteraction()
    local classArg = self.tbTargetData.cfg.tbData.classArg
    if not classArg.plotId or type(classArg.plotId) ~= "table" then return end

    local actor = self.tbTargetData.actor
    if not actor or not actor.BindingNpc then
        return
    end

    local cartoonId = classArg.plotId[1] or 0
    if cartoonId > 0 then 
        local cfg = ChessConfig:GetPlotDefineByModuleName(ChessClient.moduleName).tbId2Data[cartoonId]
        if not cfg then return end 
        actor.BindingNpc.IsInteract = true
        EventSystem.On(Event.NotifyChessNpcInteractEnd, function(InNpc)
            if InNpc ~= actor.BindingNpc then
                return
            end
            UI.GetUI("ChessMain"):SetShowOrHide(false)
            UE4.UUMGLibrary.PlayPlot(GetGameIns(), cfg.PlotId, {GetGameIns(), function(lication, CompleteType)
                UE4.Timer.Add(0.01, function()
                    UI.GetUI("ChessMain"):SetShowOrHide(true)
                    ChessObject:HideObject(self.tbTargetData)
                    ChessObject:NotifyObjectComplete(self.tbTargetData)
                end)
            end})
        end)
    else 
        ChessObject:HideObject(self.tbTargetData)
        ChessObject:NotifyObjectComplete(self.tbTargetData)
    end
end

----------------------------------------------------------------------------------

local function InheritClass(className, tbBase, tbTargetData)
    local tbNew = Inherit(tbBase);
    tbNew.tbTargetData = tbTargetData
    tbNew.classname = className
    return tbNew
end

-- 注册类
function ChessObject:RegisterClass(classname, tbTargetData)
    if classname == "rewardbox" then 
        return InheritClass(classname, tbRewardBox, tbTargetData)
    elseif classname == "door" then 
        return InheritClass(classname, tbDoor, tbTargetData)
    elseif classname == "fight" then 
        return InheritClass(classname, tbFight, tbTargetData)
    elseif classname == "plot" then 
        return InheritClass(classname, tbPlot, tbTargetData)
    elseif classname == "box_reset" then 
        return InheritClass(classname, tbResetBox, tbTargetData)
    elseif classname == "itembox" then 
        return InheritClass(classname, tbItemBox, tbTargetData)
    elseif classname == "box_receiver" then
        return InheritClass(classname, tbBoxReceive, tbTargetData)
    elseif classname == "npc" then
        return InheritClass(classname, tbNpc, tbTargetData)
    end
end


function ChessObject:GetClassParams(classname)
    if not classname or classname == "" then return end
    if classname == "rewardbox" then 
        return tbRewardBox.tbParams, tbRewardBox.szName
    elseif classname == "door" then 
        return tbDoor.tbParams, tbDoor.szName
    elseif classname == "fight" then 
        return tbFight.tbParams, tbFight.szName
    elseif classname == "plot" then 
        return tbPlot.tbParams, tbPlot.szName
    elseif classname == "box_reset" then 
        return tbResetBox.tbParams, tbResetBox.szName
    elseif classname == "itembox" then
        return tbItemBox.tbParams, tbItemBox.szName
    elseif classname == "box_receiver" then 
        return tbBoxReceive.tbParams, tbBoxReceive.szName
    elseif classname == "npc" then 
        return tbNpc.tbParams, tbNpc.szName
    end
end


---隐藏物件
function ChessObject:HideObject(tbTargetData)
    local ret = ChessRuntimeHandler:SetTargetActive(tbTargetData, false) 
    if ret then 
        ChessEvent:OnHideObject(tbTargetData)
        ChessClient:UpdateRegionPathFinding()
    end
end

-- 通知物件完成
function ChessObject:NotifyObjectComplete(tbTargetData)
    local ids = tbTargetData.cfg.tbData.id
    if ids then 
        for _, id in pairs(ids) do
            ChessData:SetObjectCompleteCount(id, true);
            
            ChessEvent:OnObjectComplete(id)
            ChessTask:OnObjectComplete(id)
        end
    end
end








