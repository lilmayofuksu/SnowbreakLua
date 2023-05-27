----------------------------------------------------------------------------------
-- @File    : ChessTools.lua
-- @Brief   : 棋盘相关接口 
----------------------------------------------------------------------------------

---@class ChessTools 棋盘相关接口
ChessTools = ChessTools or {
    tbTips = {},
}


----------------------------------------------------------------------------------
--- 请求与物件交互
function ChessTools:ApplyInteraction(targetActor)
    if targetActor:IsCustomInteraction() then 
        if ChessClient:CheckInteraction() then 
            return 
        end 

        if targetActor:BeginInteraction() then 
            ChessClient:SetInteractionActor(targetActor)
            EventSystem.Trigger(Event.NotifyHideChessInteraction, targetActor)
        end
    else 
        local uid = targetActor:GetUID()
        local regionId = targetActor:GetRegionId()
        local tbTarget = ChessRuntimeHandler:GetRegionObject(regionId, uid)
        if tbTarget then 
            ChessEvent:OnInteraction(tbTarget)
        end
    end
end

----------------------------------------------------------------------------------
--- 设置材质参数 
function ChessTools:SetActorMaterialParam(actor, type, matIdx, name, from, to, duration, delay)
    if type == "scalar" then 
        actor:SetMaterialParam(matIdx, name, from, to, duration, delay)
    elseif type == "color" then 
        local colorFrom = UE4.FLinearColor(from[1], from[2], from[3], from[4] or 1)
        local colorTo = UE4.FLinearColor(to[1], to[2], to[3], to[4] or 1)
        actor:SetMaterialColorParam(matIdx, name, colorFrom, colorTo, duration, delay)
    end
end

--- 播放特效
function ChessTools:PlayEffect(actor, particleId, isLoop)
    local cfg = ChessClient:GetParticleDef(particleId)
    if cfg then 
        local localtion = actor:K2_GetActorLocation() + UE.FVector(cfg.Offset[1] or 0, cfg.Offset[2] or 0, cfg.Offset[3] or 0)
        local rotate = UE4.FRotator(0,0,0)
        return ChessClient.gameMode:PlayEffect(cfg.Path, localtion, rotate, cfg.Loop or isLoop)
    end
end

----------------------------------------------------------------------------------
--- 得到任务内容描述
--- desc形如: 推动箱子到指定位置: {taskVar=1}/{taskVar=1,max}
function ChessTools:GetTaskContentDesc(mapId, desc)
    desc = Text(desc or "") 
    local tbMap = {}
    for subValue in string.gmatch(desc, "%b{}") do
        if not tbMap[subValue] then
            local value = string.sub(subValue, 2, -2)
            local array = Split(value, ",")
            local array1 = Split(array[1], "=")
            local type = array1[1]
            local id = array1[2]
            local flag = array[2]
            if type == "taskVar" then 
                id = tonumber(id) or 0
                local cfg = ChessConfigHandler:GetTaskVarById(tonumber(id))
                if flag == "max" then 
                    value = cfg and cfg.max or string.format("id=%s不存在", id)
                elseif flag == "min" then 
                    value = cfg and cfg.min or string.format("id=%s不存在", id)
                else
                    value = ChessData:GetMapTaskVar(id)
                end
            else 
                value = string.format("类型%s尚未实现", type)
            end
            tbMap[subValue] = value
      end
   end
   
   for key,v in pairs(tbMap) do 
        desc = string.gsub(desc, key, v)
   end
   return desc
end

--- 得到参数在任务中的引用情况
function ChessTools:GetArgValueRefrenceByTask(tbMapConfigData, inputType, checkValue)
    local tbRet = {}
    local check = function(mgr, type, tbTask, tbList)
        for _, tbData in ipairs(tbList) do 
            local class = mgr:FindClassById(eventType, tbData.id)
            if class then 
                for _, cfg in ipairs(class.tbParam) do 
                    if cfg.type == inputType then 
                        local data = tbData.tbParam[cfg.id]
                        if ChessTools:Contain(data, checkValue) then 
                            table.insert(tbRet, {type = type, tbTask = tbTask})
                        end 
                    end 
                end
            end
        end
    end
    
    for _, tbTask in ipairs(tbMapConfigData.tbData.tbTaskDef) do 
        check(ChessTaskCondition, ChessTask.TypeCondition, tbTask, tbTask.tbCondition);
        check(ChessTaskEventAction, ChessTask.TypeEventBegin, tbTask, tbTask.tbTaskBegin);
        check(ChessTaskEventAction, ChessTask.TypeEventEnd, tbTask, tbTask.tbTaskEnd);
        check(ChessTaskEventAction, ChessTask.TypeEventFail, tbTask, tbTask.tbTaskFail);
    end

    return tbRet
end

----------------------------------------------------------------------------------
function ChessTools:Contain(list, value)
    if type(list) == "number" then 
        return list == value 
    end
    
    if type(list) == "table" then 
        for _, v in ipairs(list) do 
            if v == value then 
                return true 
            end
        end
    end
end 

---检测tb1中是否包含tb2中任意元素
function ChessTools:Check_tb1_contain_tb2(tb1, tb2)
    if not tb1 or not tb2 or #tb1 == 0 then return end 
    for _, v in ipairs(tb2) do 
        for _, n in ipairs(tb1) do 
            if v == n then 
                return true;
            end
        end
    end
end

--- 对每个格子和物件执行
function ChessTools:ForeachGroundAndObjectDo(tbMapConfigData, funcGround, funcObject)
    local tbData = tbMapConfigData.tbData
    for regionId, tbRegion in pairs(tbData.tbRegions) do 
        if funcGround then 
            for id, tb in pairs(tbRegion.tbGround) do 
                funcGround(regionId, id, tb)
            end
        end
        if funcObject then 
            for id, tb in pairs(tbRegion.tbObjects) do 
                funcObject(regionId, id, tb)
            end
        end
    end
end

--- 对每个事件执行
function ChessTools:ForeachEventDo(tbMapConfigData, funcEvent)
    local traverseGroup = function(regionId, type, id, tbData, gridId)
        if not tbData then return end
        for groupIdx, tbGroup in ipairs(tbData.tbGroups or {}) do 
            for eventIdx, tbEvent in ipairs(tbGroup.tbEvents or {}) do 
                funcEvent(regionId, type, id, tbEvent, groupIdx, eventIdx, {gridId = gridId, tbData = tbData, tbGroup = tbGroup})
            end
        end
    end
    local tbData = tbMapConfigData.tbData
    for regionId, tbRegion in pairs(tbData.tbRegions) do 
        for id, tb in pairs(tbRegion.tbGround) do 
            traverseGroup(regionId, "grid", id, tb.tbData, id)
        end
        for id, tb in pairs(tbRegion.tbObjects) do 
            traverseGroup(regionId, "object", id, tb.tbData, ChessTools:GridXYToId(tb.pos[1], tb.pos[2]))
        end
    end
end

--- 得到参数的引用情况
function ChessTools:GetEventArgValueRefrence(tbMapConfigData, inputType, checkValue)
    local tbRet = {}
    local check = function(eventType, regionId, type, id, tb, groupIdx, eventIdx) 
        local cfg = ChessEvent:GetConfig(eventType, tb.id)
        if cfg then 
            for _, cfg in ipairs(cfg.tbParam) do 
                if cfg.type == inputType then 
                    local data = tb.tbParam[cfg.id]
                    if ChessTools:Contain(data, checkValue) then 
                        table.insert(tbRet, {type = type, regionId = regionId, id = id, groupIdx = groupIdx, eventIdx = eventIdx})
                    end 
                end 
            end
        end
    end
    
    ChessTools:ForeachEventDo(tbMapConfigData, function(regionId, type, id, tbEventData, groupIdx, eventIdx, tbOther)
        for _, tb in ipairs(tbEventData.tbCondition or {}) do 
            check(ChessEvent.TypeCondition, regionId, type, id, tb, groupIdx, eventIdx)
        end
        check(ChessEvent.TypeTiming, regionId, type, id, tbEventData.tbTiming, groupIdx, eventIdx)
        for _, tb in ipairs(tbEventData.tbAction or {}) do 
            check(ChessEvent.TypeAction, regionId, type, id, tb, groupIdx, eventIdx)
        end
    end)
    return tbRet
end

----------------------------------------------------------------------------------
--- 将xy坐标转换为格子唯一id
--- x,y 取值[-127, 127]
--- 唯一id为uint16, 前8位存储x坐标，后8位存储y坐标
function ChessTools:GridXYToId(x, y)
    x = x + 128
    y = y + 128
    return tostring((x << 8) + y) 
end

--- 将唯一id转换为
--- id 取值[0, 65535]
--- 返回的x,y 取值[-127, 127]
function ChessTools:GridIdToXY(id)
    id = tonumber(id)
    local x = (id >> 8) - 128
    local y = (id % 256) - 128
    return x, y;
end
----------------------------------------------------------------------------------
--- 得到指定tag的宝箱
function ChessTools:GetBoxCount(tag)
    local count = 0;
    local tbList = ChessRuntimeHandler:FindObjectsByTagName(tag)
    for _, tbTargetData in ipairs(tbList) do 
        if tbTargetData.cfg.tbData then 
            local tbId = tbTargetData.cfg.tbData.id or {};
            local id = tbId[1]
            if id and ChessData:GetObjectIsUsed(id) == 1 then 
                count = count + 1
            end
        end
    end
    return count, #tbList
end

--- 棋盘格弹窗统一管理
function ChessTools:ShowTip(sTip, check, bPlotTip, tbCfg)
    if #self.tbTips == 0 and not (UI.IsOpen("MessageTip") or UI.IsOpen("ChessTips")) then
        if bPlotTip then
            ChessClient:SetLockControl(true)
        end
        if tbCfg and tbCfg.tbArg.main then
            UI.Open("ChessTips", tbCfg)
        else
            UI.ShowTip(sTip)
        end
        return
    end
    table.insert(self.tbTips, {sTip = sTip, check = check, bPlotTip = bPlotTip, tbCfg = tbCfg})
end

--- 开放给剧情 用于控制ChessMain界面的显隐
function ChessTools.SetChessMainVisible(InVisible)
    local chessMain =  UI.GetUI("ChessMain")
    if chessMain then
        chessMain:SetShowOrHide(InVisible)
    end
end