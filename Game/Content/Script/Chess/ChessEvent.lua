----------------------------------------------------------------------------------
-- @File    : ChessEvent.lua
-- @Brief   : 棋盘事件相关
----------------------------------------------------------------------------------

---@class ChessTools 棋盘事件相关接口
ChessEvent = {
    tbConditions = {},          -- 执行条件
    tbTimings = {},             -- 执行时机
    tbActions = {},             -- 动作行为

    tbConditionCheckFunc = {},  -- 条件检测
    tbConditionRegFunc = {},    -- 条件注册
    
    tbTimingFunc = {},          -- 执行时机
    tbActionFunc = {},          -- 执行行为
}

-- 新建事件时的默认条件
ChessEvent.DefaultCondition = "Start"
ChessEvent.DefaultTiming = "Immediately"


-- 类型
ChessEvent.TypeCondition = "condition"
ChessEvent.TypeTiming = "timing"
ChessEvent.TypeAction = "action"
ChessEvent.TypeClassParam = "classParam"

-- 
ChessEvent.InputTypeText = "text"           -- 输入文本
ChessEvent.InputTypeCombo = "combo"         -- combo box
ChessEvent.InputTypeGrids = "grids"         -- 选择格子
ChessEvent.InputTypeTag = "tags"            -- 选择tag
ChessEvent.InputTypeEvent = "event"         -- 选择Event Id
ChessEvent.InputTypeObjectId = "objectId"   -- 选择物件 Id
ChessEvent.InputTypeCheckBox = "checkbox"   -- 单选框
ChessEvent.InputTypeItemId = "itemId"       -- 物品id
ChessEvent.InputTypeRewardId = "rewardId"   -- 奖励id
ChessEvent.InputTypeTaskId = "taskId"       -- 任务id
ChessEvent.InputTypeTaskVarId = "taskVarId" -- 任务变量id
ChessEvent.InputTypeModifyVar = "typeModifyVar" -- 修改变量类型
ChessEvent.InputTypeFightId = "fight"       -- 选择战斗
ChessEvent.InputTypePlotId = "plot"        -- 选择剧情
ChessEvent.InputTypeParticleId = "particle"     -- 选择特效
ChessEvent.InputTypeSequenceId = "sequence"     -- 选择动画
ChessEvent.InputTypeNpcId = "npcId"     -- 选择Npc


----------------------------------------------------------------------------------
--- 注册 执行条件
local _RegisterCondition = function(Id, Name, tbParam)
    table.insert(ChessEvent.tbConditions, {Id = Id, Name = Name, tbParam = tbParam})
end

--- 注册 执行时机
local _RegisterTiming = function(Id, Name, tbParam)
    table.insert(ChessEvent.tbTimings, {Id = Id, Name = Name, tbParam = tbParam})
end

--- 注册 行为内容
local _RegisterAction = function(Id, Name, tbParam)
    table.insert(ChessEvent.tbActions, {Id = Id, Name = Name, tbParam = tbParam})
end

---- 初始化
function ChessEvent:Init()
    self:RegisterConditionFunc()
    self:RegisterEventTimingFunc()
    self:RegisterEventAction()

    -- 注册 执行条件
    _RegisterCondition("OnInit", "当首次进入地图时", {})
    _RegisterCondition("Start", "当游戏开始瞬间", {})
    _RegisterCondition("EntryRegion", "当进入区域瞬间", {{id = "regionId", desc = "区域id", type = ChessEvent.InputTypeText, hint = "不填默认自身所在区域"}})
    _RegisterCondition("EntryGrid", "当进入格子瞬间", {{id = "gridId", desc = "格子id", type = ChessEvent.InputTypeGrids, hint = "不填默认自身"}})
    _RegisterCondition("EventComplete", "当事件完成瞬间", {{id = "eventId", desc = "事件id", type = ChessEvent.InputTypeEvent, hint = "哪个事件Id"}}) 
    _RegisterCondition("ObjectComplete", "当物件完成瞬间", {{id = "objectId", desc = "物件id", type = ChessEvent.InputTypeObjectId, hint = "哪个物件Id"}}) 
    _RegisterCondition("CheckGridObjectAppear", "当格子有物件瞬间", {{id = "gridId", desc = "格子id", type = ChessEvent.InputTypeGrids, hint = "不填默认自身"}, 
                                                        {id = "objectTag", desc = "物件Tag", type = ChessEvent.InputTypeTag, hint = "填写物件Tag, 要么填Tag要么填Id"},
                                                        {id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "填写物件Id, 要么填Tag要么填Id"}})
    _RegisterCondition("CheckGridObjectDisAppear", "当格子无物件瞬间", {{id = "gridId", desc = "格子id", type = ChessEvent.InputTypeGrids, hint = "不填默认自身"}, 
                                                        {id = "objectTag", desc = "物件Tag", type = ChessEvent.InputTypeTag, hint = "填写物件Tag, 要么填Tag要么填Id"},
                                                        {id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "填写物件Id, 要么填Tag要么填Id"}})
    _RegisterCondition("ShowObject", "当物件显示瞬间", {{id = "objectTag", desc = "物件Tag", type = ChessEvent.InputTypeTag, hint = "填写物件Tag, 要么填Tag要么填Id"},
                                                    {id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "填写物件Id, 要么填Tag要么填Id"}})
    _RegisterCondition("HideObject", "当物件隐藏瞬间", {{id = "objectTag", desc = "物件Tag", type = ChessEvent.InputTypeTag, hint = "填写物件Tag, 要么填Tag要么填Id"},
                                                    {id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "填写物件Id, 要么填Tag要么填Id"}})
    _RegisterCondition("FogDisappear", "当迷雾驱散瞬间", {{id = "gridId", desc = "格子id", type = ChessEvent.InputTypeGrids, hint = "哪个格子的迷雾被驱散时, 不填默认自身"}})
    _RegisterCondition("OnInteraction", "当互动时", {{id = "count", desc = "第几次", type = ChessEvent.InputTypeText, hint = "第几次互动，默认是每一次"},
                                                    {id = "objectTag", desc = "物件Tag", type = ChessEvent.InputTypeTag, hint = "填写物件Tag, 要么填Tag要么填Id"},
                                                    {id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "填写物件Id, 要么填Tag要么填Id"}})
    _RegisterCondition("ShowObjecting", "物件显示中", {{id = "objectTag", desc = "物件Tag", type = ChessEvent.InputTypeTag, hint = "填写物件Tag, 要么填Tag要么填Id"},
                                                    {id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "填写物件Id, 要么填Tag要么填Id"}})
    _RegisterCondition("HideObjecting", "物件隐藏中", {{id = "objectTag", desc = "物件Tag", type = ChessEvent.InputTypeTag, hint = "填写物件Tag, 要么填Tag要么填Id"},
                                                    {id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "填写物件Id, 要么填Tag要么填Id"}})
    _RegisterCondition("CheckHasItem", "存在物品", {{id = "itemId", desc = "物品Id", type = ChessEvent.InputTypeItemId, hint = "选择物品"},
                                                    {id = "count", desc = "物品数量", type = ChessEvent.InputTypeText, hint = "填写物品数量，默认1"}})
    _RegisterCondition("CheckTaskVar", "变量是否等于", {{id = "varId", desc = "物品Id", type = ChessEvent.InputTypeTaskVarId, hint = "判断任务变量"},
                                                    {id = "value", desc = "值", type = ChessEvent.InputTypeText, hint = "填写值"}})
    _RegisterCondition("CheckEventSendCount", "事件发送次数等于", {{id = "eventId", desc = "事件Id", type = ChessEvent.InputTypeEvent, hint = "事件id"},
                                                    {id = "count", desc = "发送次数", type = ChessEvent.InputTypeText, hint = "发送次数"}})
    

                                                    --  功能不好实现，暂且注释，看后面需求
--  _RegisterCondition("NearTo", "玩家靠近时", {{id = "distance", desc = "距离", type = ChessEvent.InputTypeText, hint = "直线距离多少个格子"}})
    

    -- 注册 执行时机
    _RegisterTiming("Immediately", "立刻执行", {})
    _RegisterTiming("Delay", "延迟执行", {{id = "time", desc = "时间", type = ChessEvent.InputTypeText, hint = "延迟时间，单位秒"}})
    _RegisterTiming("Sequence", "依次执行", {{id = "interval", desc = "间隔", type = ChessEvent.InputTypeText, hint = "行为执行间隔时间，单位秒，支持填多个，逗号隔开"}})


    -- 注册 行为内容
    _RegisterAction("PlaySequence", "播放Sequence", {{id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "谁来播放动画"}, 
                                                {id = "sequence", desc = "sequence", type = ChessEvent.InputTypeSequenceId, hint = "选择sequence"}});

    _RegisterAction("PlayEffect", "播放特效", {{id = "gridId", desc = "位置", type = ChessEvent.InputTypeGrids, hint = "在哪个格子处播放特效"}, 
                                                {id = "id", desc = "特效", type = ChessEvent.InputTypeParticleId, hint = "选择"}});

    _RegisterAction("HideObject", "隐藏物件", {{id = "objectTag", desc = "物件Tag", type = ChessEvent.InputTypeTag, hint = "隐藏谁，要么填Tag要么填Id"},
                                              {id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "隐藏谁，要么填Tag要么填Id"}})
    _RegisterAction("ShowObject", "显示物件", {{id = "objectTag", desc = "物件Tag", type = ChessEvent.InputTypeTag, hint = "显示谁，要么填Tag要么填Id"},
                                              {id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "显示谁，要么填Tag要么填Id"}})

    _RegisterAction("SetObjectState", "切换物件状态", {{id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "填Id"},
                                            {id = "state", desc = "状态编号", type = ChessEvent.InputTypeText, hint = "填1，2，3等"},
                                            {id = "time", desc = "过渡时间", type = ChessEvent.InputTypeText, hint = "填时间，单位秒"}})

    _RegisterAction("SetPosition", "设置物件位置", {{id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "设置谁，要么填Tag要么填Id"},
                                                {id = "gridId", desc = "位置格子", type = ChessEvent.InputTypeGrids, hint = "具体位置格子，只能选一个"}})

    _RegisterAction("PlayCartoon", "播放剧情", {{id = "cartoon", desc = "剧情名", type = ChessEvent.InputTypePlotId, hint = "要播放哪个剧情"},
                                            {id = "item", desc = "消耗道具", type = ChessEvent.InputTypeItemId, hint = "打开门所需要消耗的道具,不配则用其他事件打开"},
                                            {id = "itemCount", desc = "消耗道具数量3", type = ChessEvent.InputTypeText, hint = "默认1"}});
    _RegisterAction("DisperseFog", "驱散迷雾", {{id = "gridId", desc = "格子id", type = ChessEvent.InputTypeGrids, hint = "驱散哪个格子的迷雾"}});
    _RegisterAction("Fight", "战斗", {{id = "mapId", desc = "战斗id", type = ChessEvent.InputTypeFightId, hint = "选择战斗id"}});
    _RegisterAction("TransferRegion", "区域传送", {{id = "gridId", desc = "目标格子", type = ChessEvent.InputTypeGrids, hint = "不填读取区域默认出生点"}});

    --_RegisterAction("TransferMap", "地图传送", {{id = "mapId", desc = "地图Id", type = ChessEvent.InputTypeText, hint = "要传送到哪个地图，填写地图Id"}, 
    --                                            {id = "gridId", desc = "目标格子", type = ChessEvent.InputTypeText, hint = "不填读取1号区域默认出生点"}});
    
    _RegisterAction("AddItem", "添加物品", {{id = "itemId", desc = "物品Id", type = ChessEvent.InputTypeItemId, hint = "要添加的物品Id"},
                                            {id = "count", desc = "物品数量", type = ChessEvent.InputTypeText, hint = "要添加的物品数量，默认1"}});
    _RegisterAction("RemoveItem", "移除物品", {{id = "itemId", desc = "物品Id", type = ChessEvent.InputTypeItemId, hint = "要移除的物品Id"},
                                            {id = "count", desc = "物品数量", type = ChessEvent.InputTypeText, hint = "要移除的物品数量，默认1"}});
    _RegisterAction("ModifyTaskVar", "修改任务变量", {{id = "varId", desc = "变量id", type = ChessEvent.InputTypeTaskVarId, hint = "要修改的变量id"},
                                            {id = "type", desc = "修改类型", type = ChessEvent.InputTypeModifyVar, hint = "要怎么修改变量"},
                                            {id = "value", desc = "修改值", type = ChessEvent.InputTypeText, hint = "要修改多少"}});

    _RegisterAction("BeginTask", "开始任务", {{id = "taskId", desc = "任务Id", type = ChessEvent.InputTypeTaskId, hint = "选择要开始的任务"}});
    _RegisterAction("CompleteTask", "完成任务", {{id = "taskId", desc = "任务Id", type = ChessEvent.InputTypeTaskId, hint = "选择要完成的任务"}});

    _RegisterAction("AskQuitGame", "询问是否离开游戏", {{id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "音效绑定的物体"}});

    _RegisterAction("OpenHelpImages", "打开教程图界面", {{id = "imgId", desc = "教程图Id", type = ChessEvent.InputTypeText, hint = "HelpImages.txt对应的id"}});
    _RegisterAction("SetObjectUsed", "设置物件已经使用完毕", {{id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "设置的物件ID"},
                                                            {id = "objectTag", desc = "物件Tag", type = ChessEvent.InputTypeTag, hint = "设置的物件Tag"}});
    _RegisterAction("OpenOrCloseDoor", "开门/关门", {{id = "objectId", desc = "门Id", type = ChessEvent.InputTypeObjectId, hint = "门id"},
                                                    {id = "open", desc = "是否开门", type = ChessEvent.InputTypeCheckBox, hint = "勾上开门，不勾关门"}});

    -- _RegisterAction("PlayObjectMove", "播放物件移动动画", {{id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "要移动的物件"},
    --                                             {id = "x", desc = "位移x", type = ChessEvent.InputTypeText, hint = "x方向移动多少格子"},
    --                                             {id = "y", desc = "位移y", type = ChessEvent.InputTypeText, hint = "y方向移动多少格子"},
    --                                             {id = "time", desc = "时间", type = ChessEvent.InputTypeText, hint = "移动过时间，单位秒"}});
    -- _RegisterAction("PlayGroundMove", "播放地形移动动画", {{id = "gridId", desc = "目标格子", type = ChessEvent.InputTypeGrids, hint = "要移动的地形"},
    --                                             {id = "height", desc = "高度", type = ChessEvent.InputTypeText, hint = "地形高度"},
    --                                             {id = "time", desc = "时间", type = ChessEvent.InputTypeText, hint = "移动过时间，单位秒"},
    --                                             {id = "relative", desc = "相对", type = ChessEvent.InputTypeCheckBox, hint = "是否相对高度"},
    --                                             {id = "sequence", desc = "依次", type = ChessEvent.InputTypeCheckBox, hint = "是否依次移动"}});

    _RegisterAction("AddInteractionCount", "增加互动次数", {{id = "objectId", desc = "物件Id", type = ChessEvent.InputTypeObjectId, hint = "要增加谁的互动次数"}});
    _RegisterAction("DebugMsg", "提示信息", {{id = "msg", desc = "内容", type = ChessEvent.InputTypeText, hint = "填写输出内容"}});
    _RegisterAction("DebugSceneMsg", "场景说话", {{id = "msg", desc = "内容", type = ChessEvent.InputTypeText, hint = "填写多语言key，多个用逗号隔开"},
                                                {id = "gridId", desc = "格子id", type = ChessEvent.InputTypeGrids, hint = "哪个格子说话"},
                                                {id = "height", desc = "高度", type = ChessEvent.InputTypeText, hint = "高度偏移，单位米"},
                                                {id = "time", desc = "时间", type = ChessEvent.InputTypeText, hint = "每句话持续时间，默认3秒,-1表示永久"}});
end

--- 得到配置
function ChessEvent:GetConfig(type, id)
    local tbList = self:GetList(type)
    for _, tb in ipairs(tbList or {}) do 
        if tb.Id == id then 
            return tb;
        end
    end
end

-- 得到配置列表
function ChessEvent:GetList(type)
    local tbList;
    if type == ChessEvent.TypeCondition then tbList = self.tbConditions
    elseif type == ChessEvent.TypeTiming then tbList = self.tbTimings
    elseif type == ChessEvent.TypeAction then tbList = self.tbActions
    end
    return tbList;
end

----------------------------------------------------------------------------------
--- 条件注册和检测
----------------------------------------------------------------------------------
--- 将value合并到tb
local add_to_table = function(tb, value)
    if not value then return end
    for i, k in pairs(value) do 
        tb[i] = k
    end
end

local set_table_value = function(tb, value, key1, key2, key3) 
    tb[key1] = tb[key1] or {}
    if key3 then 
        local tb1 = tb[key1];
        tb1[key2] = tb1[key2] or {}
        tb1[key2][key3] = value
    else 
        tb[key1][key2] = value
    end
end

local _registerConditionFunc = function(type, pCheckFunc, pRegFunc) 
    ChessEvent.tbConditionCheckFunc[type] = pCheckFunc
    ChessEvent.tbConditionRegFunc[type] = pRegFunc;
end

--- 检测格子坐标
local _condition_check_grid = function(tbEvent, tbCondition, tbValue, InRegionId, InGridId)
    local tbGrids = tbCondition.tbParam.gridId
    if tbGrids and #tbGrids > 0 then 
        for _, tbGrid in ipairs(tbGrids) do 
            local regionId, gridId = tbGrid[1], tbGrid[2]
            if regionId == InRegionId and gridId == InGridId then 
                return true 
            end
        end
    else 
        return tbValue.regionId == InRegionId and tbValue.gridId == InGridId
    end
end

--- 检测格子tag 或者 id 
local _condition_check_object_tag_id = function(tbEvent, tbCondition, tbValue, tbTargetData)
    if not tbTargetData then return end
    local tbTag = tbCondition.tbParam.objectTag
    local tbId = tbCondition.tbParam.objectId
    local tags = tbTargetData.cfg.tbData.tag
    local ids = tbTargetData.cfg.tbData.id
    if ChessTools:Check_tb1_contain_tb2(tags, tbTag) or ChessTools:Check_tb1_contain_tb2(ids, tbId) then 
        return true 
    end
end

--- 检测多个格子的情况
--- 所有格子都要指定tag的物件
local _condition_check_multi_grid_tag = function(tbEvent, tbCondition, tbValue, tbTargetData)
    if not tbTargetData then return end
    local tbGrids = tbCondition.tbParam.gridId
    local tbTag = tbCondition.tbParam.objectTag
    local tbTargets = ChessRuntimeHandler:FindTargetByTagAndId(tbTag)
    local tbGridDef = ChessConfig:GetGridDefineByModuleName(ChessClient.moduleName)
    -- 检测是否有目标在目标格子上
    local checkTarget = function(regionId, gridId) 
        local x, y = ChessTools:GridIdToXY(gridId)
        for _, tbTarget in ipairs(tbTargets) do 
            local tx, ty = tbTarget.pos[1], tbTarget.pos[2]
            local size = tbGridDef.tbId2Data[tbTarget.cfg.tpl].Size
            local sx, sy = size[1], size[2]
            if tbTarget.regionId == regionId and x >= tx and x <= (tx + sx - 1) and y >= ty and y <= (ty + sy - 1) then 
                return true
            end
        end
    end

    if tbGrids and #tbGrids > 0 then 
        for _, tbGrid in ipairs(tbGrids) do 
            local regionId, gridId = tbGrid[1], tbGrid[2]
            if not checkTarget(regionId, gridId) then 
                return false;
            end
        end
        return true;
    else 
        return false
    end
end


--- 检测物件是否激活
local _condition_check_object_active_by_tag_id = function(tbEvent, tbCondition, tbValue, checkValue)
    local tbTag = tbCondition.tbParam.objectTag
    local tbId = tbCondition.tbParam.objectId
    local tbList = ChessRuntimeHandler:FindTargetByTagAndId(tbTag, tbId)
    for _, tb in ipairs(tbList) do 
        if tb.active ~= checkValue then return false end
    end
    return true;
end

--- 注册格子
local _condition_reg_grid = function(tbReg, tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther) 
    local tbGrids = tbCondition.tbParam.gridId;
    if tbGrids and #tbGrids > 0 then 
        for _, tbGrid in ipairs(tbGrids) do 
            local _regionId, _gridId = tbGrid[1], tbGrid[2]
            set_table_value(tbReg, true, _regionId, _gridId, tbEvent)
        end
    else
        set_table_value(tbReg, {regionId = regionId, gridId = tbOther.gridId}, regionId, tbOther.gridId, tbEvent)
    end
end

--- 注册tag id 
local _condition_reg_object_tag_id = function(tbTagReg, tbIdReg, tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
    local tbTag = tbCondition.tbParam.objectTag
    local tbId = tbCondition.tbParam.objectId
    if tbTag and #tbTag > 0 then 
        for _, tag in ipairs(tbTag) do 
            set_table_value(tbTagReg, true, tag, tbEvent)
        end
    end
    if tbId and #tbId > 0 then 
        for _, _id in ipairs(tbId) do 
            --print("_condition_reg_object_tag_id ", _id, tbEvent, type, id);
            set_table_value(tbIdReg, true, _id, tbEvent)
        end
    end
end

--- 注册条件检测函数
function ChessEvent:RegisterConditionFunc()
    -- 当首次进入场景 
    _registerConditionFunc("OnInit", 
        function(tbEvent, tbCondition, tbValue)
            return self.__isOnInit
        end, 
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            self.tbInitEvents[tbEvent] = true;
        end
    )

    -- 游戏开始 
    _registerConditionFunc("Start", 
        function(tbEvent, tbCondition, tbValue)
            return self.__isGameStart
        end, 
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            self.tbStartEvents[tbEvent] = true;
        end
    )

    -- 进入区域 
    _registerConditionFunc("EntryRegion", 
        function(tbEvent, tbCondition, tbValue)
            local regionId = tonumber(tbCondition.tbParam.regionId) or tbValue.regionId
            return self.__curEntryRegionId == regionId
        end, 
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            local id = tonumber(tbCondition.tbParam.regionId) or 0
            if id == 0 then id = regionId end
            set_table_value(self.tbEntryRegionEvents, {regionId = id}, id, tbEvent)
        end
    )

    -- 进入格子 
    _registerConditionFunc("EntryGrid", 
        function(tbEvent, tbCondition, tbValue)
            return _condition_check_grid(tbEvent, tbCondition, tbValue, self.__curEntryRegionId, self.__curEntryGridId)
        end,
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            _condition_reg_grid(self.tbEntryGridEvents, tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
        end
    )

    -- 任意事件完成（如果要求所有事件完成，得加参数：是否要求所有完成，以及改变算法）
    _registerConditionFunc("EventComplete", 
        function(tbEvent, tbCondition, tbValue) 
            local tbEventId = tbCondition.tbParam.eventId;
            for _, eventId in ipairs(tbEventId) do 
                if self.__curEventCompleteId == eventId then 
                    return true 
                end
            end
        end,
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            local tbEventId = tbCondition.tbParam.eventId;
            for _, eventId in ipairs(tbEventId) do 
                set_table_value(self.tbEventCompleteEvents, true, eventId, tbEvent)
            end
        end
    )

    -- 任意物件完成
    _registerConditionFunc("ObjectComplete", 
        function(tbEvent, tbCondition, tbValue) 
            local tbobjectId = tbCondition.tbParam.objectId;
            for _, objectId in ipairs(tbobjectId) do 
                if ChessData:GetObjectCompleteCount(objectId) == 0 then
                    return false
                end
            end
            return true
        end,
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            local tbobjectId = tbCondition.tbParam.objectId;
            for _, objectId in ipairs(tbobjectId) do 
                set_table_value(self.tbObjectCompleteObjects, true, objectId, tbEvent)
            end
        end
    )


    -- 显示物件时 (任意tag或者id满足时)
    _registerConditionFunc("ShowObject", 
        function(tbEvent, tbCondition, tbValue)
            return _condition_check_object_tag_id(tbEvent, tbCondition, tbValue, self.__curShowObject)
        end,
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            _condition_reg_object_tag_id(self.tbShowObjectByTagEvents, self.tbShowObjectByIdEvents, tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
        end
    )    

    -- 隐藏物件 (任意tag或者id满足时)
    _registerConditionFunc("HideObject",
        function(tbEvent, tbCondition, tbValue)
            return _condition_check_object_tag_id(tbEvent, tbCondition, tbValue, self.__curHideObject)
        end,
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            _condition_reg_object_tag_id(self.tbHideObjectByTagEvents, self.tbHideObjectByIdEvents, tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
        end
    )

    -- 迷雾驱散 
    _registerConditionFunc("FogDisappear", 
        function(tbEvent, tbCondition, tbValue)
            return _condition_check_grid(tbEvent, tbCondition, tbValue, self.__curRegionId, self.__curFogGridId)
        end,
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            _condition_reg_grid(self.tbFogDisappearEvents, tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
        end
    )

    -- 当格子上出现某物件时
    _registerConditionFunc("CheckGridObjectAppear",
        function(tbEvent, tbCondition, tbValue)
            if tbCondition.tbParam.objectTag and #tbCondition.tbParam.objectTag > 0 then 
                return _condition_check_grid(tbEvent, tbCondition, tbValue, self.__curCheckAppearRegionId, self.__curCheckAppearGridId)
                    and _condition_check_multi_grid_tag(tbEvent, tbCondition, tbValue, self.__curAppearObj)
            else 
                return _condition_check_grid(tbEvent, tbCondition, tbValue, self.__curCheckAppearRegionId, self.__curCheckAppearGridId)
                    and _condition_check_object_tag_id(tbEvent, tbCondition, tbValue, self.__curAppearObj);
            end
        end,
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            _condition_reg_grid(self.tbCheckGridObjectAppearEvents, tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
        end
    )

    -- 当格子上丢失某物件时
    _registerConditionFunc("CheckGridObjectDisAppear",
        function(tbEvent, tbCondition, tbValue)
            return _condition_check_grid(tbEvent, tbCondition, tbValue, self.__curCheckDisAppearRegionId, self.__curCheckDisAppearGridId)
                and _condition_check_object_tag_id(tbEvent, tbCondition, tbValue, self.__curDisAppearObj);
        end,
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            _condition_reg_grid(self.tbCheckGridObjectDisAppearEvents, tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
        end
    )

    -- 物件显示中ing (任意tag或者id满足时)
    _registerConditionFunc("ShowObjecting", 
        function(tbEvent, tbCondition, tbValue)
            return _condition_check_object_active_by_tag_id(tbEvent, tbCondition, tbValue, true)
        end,
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            _condition_reg_object_tag_id(self.tbShowObjectingByTagEvents, self.tbShowObjectingByIdEvents, tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
        end
    )

    -- 物件隐藏中ing (任意tag或者id满足时)
    _registerConditionFunc("HideObjecting",
        function(tbEvent, tbCondition, tbValue)
            return _condition_check_object_active_by_tag_id(tbEvent, tbCondition, tbValue, false)
        end,
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            _condition_reg_object_tag_id(self.tbHideObjectingByTagEvents, self.tbHideObjectingByIdEvents, tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
        end
    )

    -- 当互动时
    _registerConditionFunc("OnInteraction", 
        function(tbEvent, tbCondition, tbValue)
            if not _condition_check_object_tag_id(tbEvent, tbCondition, tbValue, self.__curInteractionObject) then 
                return false
            end
            local count = tonumber(tbCondition.tbParam.count) or 0
            if count <= 0 then return true end

            local ids = tbCondition.tbParam.objectId
            if ids and #ids > 0 then 
                return ChessData:GetObjectInteractionCount(ids[1]) == count
            end
            return true;
        end,
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            _condition_reg_object_tag_id(self.tbInteractionByTagEvents, self.tbInteractionByIdEvents, tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
        end
    )

    -- 检测背包中是否有某道具
    _registerConditionFunc("CheckHasItem",
        function(tbEvent, tbCondition, tbValue)
            local itemId = tbCondition.tbParam.itemId
            local count = tonumber(tbCondition.tbParam.count) or 1
            if itemId and #itemId > 0 and count >= 1 then 
                return ChessData:GetItemCount(itemId[1]) >= count
            end 
        end,
        function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            _condition_reg_object_tag_id(self.tbInteractionByTagEvents, self.tbInteractionByIdEvents, tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
        end
    )

    -- 判断变量是否等于
    _registerConditionFunc("CheckTaskVar", function(tbEvent, tbCondition, tbValue)
        local varId = tbCondition.tbParam.varId
        local value = tonumber(tbCondition.tbParam.value) or 0
        if varId and varId[1] then 
            return ChessData:GetMapTaskVar(varId[1]) == value
        end
    end,
    function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
        
    end)

    -- 判断事件发送次数
    _registerConditionFunc("CheckEventSendCount", function(tbEvent, tbCondition, tbValue)
        local varId = tbCondition.tbParam.eventId
        local count = tonumber(tbCondition.tbParam.count) or 0
        if varId and varId[1] then 
            return ChessData:GetEventSendCount(varId[1]) == count
        end
    end,
    function(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
        
    end)
end

----------------------------------------------------------------------------------
--- 注册执行时机
----------------------------------------------------------------------------------
local _register_timing_func = function(type, func)
    ChessEvent.tbTimingFunc[type] = func
end

function ChessEvent:RegisterEventTimingFunc()
    -- 立即执行
    _register_timing_func("Immediately", function(tbEvent) 
        local tb = {}
        function tb:Init()
            for _, tbAction in ipairs(tbEvent.tbAction) do 
                ChessEvent:TryDoAction(tbEvent, tbAction)
            end
        end
        function tb:Update(deltaTime) end
        function tb:IsEnd() return true end
        return tb;
    end)

    -- 延迟执行
    _register_timing_func("Delay", function(tbEvent)
        local tb = {}
        function tb:Init()
            self.waitTime = tonumber(tbEvent.tbTiming.tbParam.time)
            self.curTime = 0
        end
        function tb:Update(deltaTime)
            self.curTime = self.curTime + deltaTime;
            if self.curTime >= self.waitTime then 
                for _, tbAction in ipairs(tbEvent.tbAction) do 
                    ChessEvent:TryDoAction(tbEvent, tbAction)
                end
                self.isEnd = true
            end
        end
        function tb:IsEnd() return self.isEnd end
        return tb;
    end)

    -- 依次执行
    _register_timing_func("Sequence", function(tbEvent)
        local tb = {tbTimeLimit = {}}
        function tb:Init()
            self.count = #tbEvent.tbAction
            local tbStr = Split(tbEvent.tbTiming.tbParam.interval, ",")
            if #tbStr <= 1 then 
                local delta = tonumber(tbStr[1]) or 0
                self.tbTimeLimit[1] = 0
                for i = 2, self.count do 
                    self.tbTimeLimit[i] = self.tbTimeLimit[i - 1] + delta
                end
            else 
                local time = 0
                for i = 1, #tbStr do 
                    time = tonumber(tbStr[i]) or 0
                    if i == 1 then 
                        self.tbTimeLimit[i] = time 
                    else
                        self.tbTimeLimit[i] = self.tbTimeLimit[i - 1] + time 
                    end
                end
                for i = #self.tbTimeLimit + 1, self.count do 
                    self.tbTimeLimit[i] = self.tbTimeLimit[i - 1] + time
                end
            end
            self.curTime = 0
            self.curIdx = 1;
        end
        function tb:Update(deltaTime)
            self.curTime = self.curTime + deltaTime;
            while(true) do 
                local time = self.tbTimeLimit[self.curIdx]
                if not time or self.curTime < time then break end
                local tbAction = tbEvent.tbAction[self.curIdx]
                ChessEvent:TryDoAction(tbEvent, tbAction)
                self.curIdx = self.curIdx + 1;
            end
            self.isEnd = self.curIdx > self.count
        end
        function tb:IsEnd() return self.isEnd end
        return tb
    end)
end

----------------------------------------------------------------------------------
--- 注册行为
----------------------------------------------------------------------------------
local _register_action_func = function(type, func)
    ChessEvent.tbActionFunc[type] = func
end

function ChessEvent:RegisterEventAction()
    -- 输出调试信息
    _register_action_func("DebugMsg", function(tbAction, tbEvent)
        ChessTools:ShowTip(tbAction.tbParam.msg, true)
    end)

    -- 场景说话 
    _register_action_func("DebugSceneMsg", function(tbAction, tbEvent)
        local tbGroundData = ChessRuntimeHandler:FindGroundDataByGridId(tbAction.tbParam.gridId)
        if #tbGroundData > 0 then 
            local actor = tbGroundData[1].actor
            local offset = tbAction.tbParam.height or 0;
            local duration = tonumber(tbAction.tbParam.time) or 3;
            EventSystem.Trigger(Event.NotifyChessTalkMsg, {actor = actor, msg = tbAction.tbParam.msg, offset = offset, duration = duration})
        end
    end)

    -- 显示物件 
    _register_action_func("ShowObject", function(tbAction, tbEvent)
        local tbTag, tbId = tbAction.tbParam.objectTag, tbAction.tbParam.objectId
        local tbList = ChessRuntimeHandler:FindTargetByTagAndId(tbTag, tbId) 
        if #tbList > 0 then
            local ok;
            for _, tbTargetData in ipairs(tbList) do 
                local ret = ChessRuntimeHandler:SetTargetActive(tbTargetData, true) 
                if ret then 
                    ok = true;
                    ChessEvent:OnShowObject(tbTargetData)
                end
            end
            if ok then 
                ChessClient:UpdateRegionPathFinding()
            end
        end
    end)

    -- 播放Sequence 
    _register_action_func("PlaySequence", function(tbAction, tbEvent)
        local tbTag, tbId = tbAction.tbParam.objectTag, tbAction.tbParam.objectId
        local tbList = ChessRuntimeHandler:FindTargetByTagAndId(tbTag, tbId) 
        local tbSeq = tbAction.tbParam.sequence
        local cfg = ChessClient:GetSequenceDef(tbSeq[1]);
        for _, tbData in ipairs(tbList) do 
            local actor = tbData.actor
            if actor then 
                ChessClient.gameMode:BP_PlayCustomAnim(cfg.Path, actor, cfg.Loop)
            end
        end
    end)

    -- 播放特效
    _register_action_func("PlayEffect", function(tbAction, tbEvent)
        local tbGroundData = ChessRuntimeHandler:FindGroundDataByGridId(tbAction.tbParam.gridId)
        local id = tbAction.tbParam.id
        local cfg = ChessClient:GetParticleDef(id[1])
        if not cfg then return end

        for _, tbData in ipairs(tbGroundData) do 
            local actor = tbData.actor
            if actor then 
                local localtion = actor:K2_GetActorLocation() + UE.FVector(cfg.Offset[1] or 0, cfg.Offset[2] or 0, cfg.Offset[3] or 0)
                local rotate = UE4.FRotator(0,0,0)
                ChessClient.gameMode:PlayEffect(cfg.Path, localtion, rotate, cfg.Loop)
            end
        end
        
    end)

    -- 切换物件显示状态
    _register_action_func("SetObjectState", function(tbAction, tbEvent)
        local tbId = tbAction.tbParam.objectId
        local state = tonumber(tbAction.tbParam.state) or 0
        if state < 0 then state = 0 end
        if state > 1 then 
            UE.UUMGLibrary.LogError("切换物件显示状态错误，state最大为1，实际配置为" .. state)
            return 
        end

        local time = tonumber(tbAction.tbParam.time)
        local tbList = ChessRuntimeHandler:FindTargetByTagAndId(nil, tbId) 
        for _, tbTargetData in ipairs(tbList or {}) do 
            local oldState = ChessRuntimeHandler:GetTargetShowState(tbTargetData) 
            if oldState ~= state then
                local ret = ChessRuntimeHandler:SetTargetShowState(tbTargetData, state) 
                if ret then 
                    local cfgId = ChessRuntimeHandler:GetObjectCfgId(tbTargetData)
                    local tbCfg = ChessClient:GetGridDef(cfgId)
                    local tbFrom = tbCfg["State" .. oldState]
                    local tbTo = tbCfg["State" .. state]
                    for _, tb in ipairs(tbFrom) do 
                        local toData ;
                        for _, tb2 in ipairs(tbTo) do 
                            if tb2.name == tb.name then 
                                toData = tb2;
                                break;
                            end
                        end
                        if toData then 
                            local duration = tb.time or time
                            ChessTools:SetActorMaterialParam(tbTargetData.actor, tb.type, tb.mat, tb.name, tb.value, toData.value, duration, tb.delay)
                        else 
                            ChessTools:SetActorMaterialParam(tbTargetData.actor, tb.type, tb.mat, tb.name, tb.value, tb.value, 0, tb.delay)
                        end
                    end
                end
            end
        end
    end)

    -- 设置物件位置
    _register_action_func("SetPosition", function(tbAction, tbEvent)
        local tbTag, tbId = tbAction.tbParam.objectTag, tbAction.tbParam.objectId
        local tbGridId = tbAction.tbParam.gridId
        local tbList = ChessRuntimeHandler:FindTargetByTagAndId(tbTag, tbId) 
        if #tbList > 0 and tbGridId and tbGridId[1] then
            local ok;
            local regionId, gridId = tbGridId[1][1], tbGridId[1][2]
            for _, tbTargetData in ipairs(tbList) do 
                ok = ChessRuntimeHandler:SetTargetPosition(tbTargetData, regionId, gridId) or ok
            end
            if ok then 
                ChessClient:UpdateRegionPathFinding()
            end
        end
    end)

    -- 隐藏物件 
    _register_action_func("HideObject", function(tbAction, tbEvent)
        local tbTag, tbId = tbAction.tbParam.objectTag, tbAction.tbParam.objectId
        local tbList = ChessRuntimeHandler:FindTargetByTagAndId(tbTag, tbId) 
        if #tbList > 0 then 
            local ok;
            for _, tbTargetData in ipairs(tbList) do 
                local ret = ChessRuntimeHandler:SetTargetActive(tbTargetData, false) 
                if ret then 
                    ok = true;
                    ChessEvent:OnHideObject(tbTargetData)
                end
            end
            if ok then 
                ChessClient:UpdateRegionPathFinding()
            end
        end
    end)

    -- 区域传送
    _register_action_func("TransferRegion", function(tbAction, tbEvent)
        local tbGroundData = ChessRuntimeHandler:FindGroundDataByGridId(tbAction.tbParam.gridId)
        if #tbGroundData > 0 then 
            ChessClient:TransferInRegion(tbGroundData[1].actor)
        end
    end)

    -- 播放剧情
    _register_action_func("PlayCartoon", function(tbAction, tbEvent)
        if _G.type(tbAction.tbParam.cartoon) ~= "table" then return end

        if tbAction.tbParam.item then
            local itemCount = tonumber(tbAction.tbParam.itemCount) or 0
            if ChessData:GetItemCount(tbAction.tbParam.item[1]) <= 0 then
                ChessTools:ShowTip(Text("tip.NotEnoughItem"))
                return
            end
            if itemCount > 0 then
                ChessData:UseItem(tbAction.tbParam.item[1], itemCount)
            end
        end

        local cartoonId = tbAction.tbParam.cartoon[1] or 0
        if cartoonId > 0 then 
            local cfg = ChessConfig:GetPlotDefineByModuleName(ChessClient.moduleName).tbId2Data[cartoonId]
            if not cfg then return end 

            UI.GetUI("ChessMain"):SetShowOrHide(false)
            UE4.UUMGLibrary.PlayPlot(GetGameIns(), cfg.PlotId, {GetGameIns(), function(lication, CompleteType)
                UI.GetUI("ChessMain"):SetShowOrHide(true)
            end})
        end
    end)

    -- 增加互动次数
    _register_action_func("AddInteractionCount", function(tbAction, tbEvent)
        local ids = tbAction.tbParam.objectId
        if ids and #ids > 0 then 
            ChessData:AddObjectInteractionCount(ids[1])
        end
    end)

    -- 设置物件已经使用完毕
    _register_action_func("SetObjectUsed", function(tbAction, tbEvent)
        local ids = tbAction.tbParam.objectId
        local tbTag = tbAction.tbParam.objectTag
        if ids and #ids > 0 then 
            for _, id in pairs(ids) do
                ChessData:SetObjectIsUsed(id)
            end
        end

        if tbTag then
            local tbList = ChessRuntimeHandler:FindTargetByTagAndId(tbTag)
            for _, item in pairs(tbList) do 
                --- 仅用于处理箱子
                if item.cfg and item.cfg.tbData and item.cfg.tbData.id then
                    ChessData:SetObjectIsUsed(item.cfg.tbData.id[1])
                end
            end
        end
    end)

    -- 开门/关门
    _register_action_func("OpenOrCloseDoor", function(tbAction, tbEvent)
        local objectId = tbAction.tbParam.objectId
        local isOpen = tbAction.tbParam.open
        local tbList = ChessRuntimeHandler:FindTargetByTagAndId({}, objectId) 
        for i = 1, #tbList do 
            local classHandler = tbList[i].classHandler
            if classHandler and classHandler.OpenOrCloseDoor then 
                classHandler:OpenOrCloseDoor(isOpen, false, 2)
            end
        end
    end)

    -- 添加道具
    _register_action_func("AddItem", function(tbAction, tbEvent)
        local ids = tbAction.tbParam.itemId
        local count = tonumber(tbAction.tbParam.count) or 1
        if ids and #ids > 0 then 
            ChessData:AddItemCount(ids[1], count)
        end
    end)

    -- 移除道具
    _register_action_func("RemoveItem", function(tbAction, tbEvent)
        local ids = tbAction.tbParam.itemId
        local count = tonumber(tbAction.tbParam.count) or 1
        if ids and #ids > 0 then 
            ChessData:UseItem(ids[1], count)
        end
    end)

    -- 修改任务变量
    _register_action_func("ModifyTaskVar", function(tbAction, tbEvent)
        local varId = tbAction.tbParam.varId
        local type = tbAction.tbParam.type
        local value = tonumber(tbAction.tbParam.value) or 0
        ChessTask:ApplyModifyTaskVar(varId, type, value)
    end)

    -- 开始任务
    _register_action_func("BeginTask", function(tbAction, tbEvent)
        local taskId = tbAction.tbParam.taskId
        if taskId then 
            ChessTask:BeginTask(taskId)
        end
    end)

    -- 完成任务
    _register_action_func("CompleteTask", function(tbAction, tbEvent)
        local taskId = tbAction.tbParam.taskId
        if taskId then 
            ChessTask:CompleteTask(taskId)
        end
    end)

    -- 询问是否离开游戏
    _register_action_func("AskQuitGame", function(tbAction, tbEvent)
        local fOkEvent = function()
            --绑定音效
            local objectId = tbAction.tbParam.objectId
            local tbList = ChessRuntimeHandler:FindTargetByTagAndId({}, objectId) 
            if tbList and #tbList > 0 then
                local actor = tbList[1].actor
                UE4.UWwiseLibrary.PostEventAttachedActor(Audio.Get(2011), actor)
            else
                Audio.PlaySounds(2011)
            end
            ChessData:SetMapComplete(ChessData.mapId)
            ChessClient:SetDataDirty()
        end
        local fCancel = function()
        end
        ChessClient:WriteOperationLog(5)
        UI.Open("MessageBox", Text("ui.TxtChessTips5"), fOkEvent, fCancel)
    end)

    -- 弹出教程图
    _register_action_func("OpenHelpImages", function(tbAction, tbEvent)
        local sImgId = tbAction.tbParam.imgId
        if not sImgId then return end
        local imgId = tonumber(sImgId) or 0
        ChessClient:StopMovementImmediately()
        if imgId > 0 then
            UI.Open("HelpImages", imgId)
        end
    end)

    -- 服务器返回 退出地图
    s2c.Register('chess.quit_game', function() GoToMainLevel() end)
end

----------------------------------------------------------------------------------
--- 设置地图数据
function ChessEvent:SetMapData(tbMapConfigData)
    self.tbEntryGridEvents = {}                                 -- 进入格子 相关事件
    self.tbEventCompleteEvents = {}                             -- 事件完成 相关事件
    self.tbObjectCompleteObjects = {}                           -- 物件完成 相关事件
    self.tbStartEvents = {}                                     -- 游戏开始 相关事件
    self.tbInitEvents = {}                                      -- 首次进入场景 相关事件
    self.tbShowObjectByTagEvents = {}                           -- 通过Tag检查显示物件瞬间 相关事件
    self.tbShowObjectByIdEvents = {}                            -- 通过Id检查显示物件瞬间 相关事件
    self.tbHideObjectByTagEvents = {}                           -- 通过Tag检查隐藏物件瞬间 相关事件
    self.tbHideObjectByIdEvents = {}                            -- 通过Td检查隐藏物件瞬间 相关事件

    self.tbShowObjectingByTagEvents = {}                        -- 通过Tag检查显示物件中 相关事件
    self.tbShowObjectingByIdEvents = {}                         -- 通过Id检查显示物件中 相关事件
    self.tbHideObjectingByTagEvents = {}                        -- 通过Tag检查隐藏物件中 相关事件
    self.tbHideObjectingByIdEvents = {}                         -- 通过Td检查隐藏物件中 相关事件

    self.tbInteractionByTagEvents = {}                          -- 通过tag互动
    self.tbInteractionByIdEvents = {}                           -- 通过id互动

    self.tbFogDisappearEvents = {}                              -- 迷雾被驱散 相关事件
    self.tbCheckGridObjectAppearEvents = {}                     -- 当格子上出现某物件时 相关事件
    self.tbCheckGridObjectDisAppearEvents = {}                  -- 当格子上丢失某物件时 相关事件
    self.tbEntryRegionEvents = {}                               -- 进入区域 相关事件
    self.tbCurrentEventList = {}                                -- 当前事件列表

    -- 暂时没用，注释掉
    --self.tbEventMapping = {}                                    -- event与物件数据和group的对照关系，方便后续查询使用

    -- 预处理事件
    ChessTools:ForeachEventDo(tbMapConfigData, function(regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther) 
        for _, tbCondition in ipairs(tbEvent.tbCondition) do 
            local pRegFunc = ChessEvent.tbConditionRegFunc[tbCondition.id]
            pRegFunc(tbCondition, regionId, type, id, tbEvent, groupIdx, eventIdx, tbOther)
            --self.tbEventMapping[tbEvent] = {tbData = tbOther.tbData, tbGroup = tbOther.tbGroup}
        end
    end)
end

function ChessEvent:TryDoEvents(tbList)
    for tbEvent, tbValue in pairs(tbList or {}) do 
        self:TryDoEvent(tbEvent, tbValue)
    end
end

function ChessEvent:TryDoEvent(tbEvent, tbValue)
    for _, tbCondition in ipairs(tbEvent.tbCondition) do 
        local pFun = ChessEvent.tbConditionCheckFunc[tbCondition.id]
        if not pFun(tbEvent, tbCondition, tbValue) then 
            return 
        end
    end


    if tbEvent.id then
        local sendCount = ChessData:GetEventSendCount(tbEvent.id)
        local cfg = ChessEditor.tbMapData.tbData.tbEventDef[tbEvent.id]
        if cfg and cfg.max and sendCount >= cfg.max then
            return
        end
    end
    ChessEvent:DoEvent(tbEvent)
end

function ChessEvent:TryDoAction(tbEvent, tbAction)
    local pFunc = ChessEvent.tbActionFunc[tbAction.id];
    if pFunc then 
        pFunc(tbAction, tbEvent)
    end
end


----------------------------------------------------------------------------------
--- 执行事件
function ChessEvent:DoEvent(tbEvent)
    if tbEvent.id then 
        ChessData:AddEventSendCount(tbEvent.id)
    end

    local func = ChessEvent.tbTimingFunc[tbEvent.tbTiming.id]
    local tb = func(tbEvent);
    tb.id = tbEvent.id
    tb:Init()
    if not tb:IsEnd() then 
        table.insert(self.tbCurrentEventList, tb)
    else 
        ChessEvent:OnEventComplete(tbEvent.id)
    end
    if #self.tbCurrentEventList > 0 then 
        ChessClient.gameMode.HasEvent = true;
    end
end

--- 每帧更新
function ChessEvent:Tick(deltaTime)
    for i = #self.tbCurrentEventList, 1, -1 do
        local tb = self.tbCurrentEventList[i] 
        tb:Update(deltaTime)
        if tb:IsEnd() then 
            table.remove(self.tbCurrentEventList, i);
            ChessEvent:OnEventComplete(tb.id)
        end
    end
    if #self.tbCurrentEventList == 0 then 
        ChessClient.gameMode.HasEvent = false
    end
end


----------------------------------------------------------------------------------
--- 首次进入场景时
function ChessEvent:OnGameInit()
    self.__isOnInit = true;
    self:TryDoEvents(self.tbInitEvents)
    self.__isOnInit = nil;
    ChessRuntimeHandler:OnGameInit()
end

--- 游戏开始时
function ChessEvent:OnGameStart()
    self.__isGameStart = true;
    self:TryDoEvents(self.tbStartEvents)
    self.__isGameStart = nil;
    ChessRuntimeHandler:OnGameStart()
    ChessTask:OnGameStart()
end

--- 进入区域时
function ChessEvent:OnEntryRegion(regionId)
    self.__curEntryRegionId = regionId
    self:TryDoEvents(self.tbEntryRegionEvents[regionId])
    self.__curEntryRegionId = nil
end

--- 进入格子时
function ChessEvent:OnEntryGrid(regionid, gridId, rotateZ)
    ChessData:SetPlayerPos(regionid, gridId, rotateZ)
    self.__curEntryGridId = gridId
    self.__curEntryRegionId = regionid
    self:TryDoEvents( self:GetTableValue(self.tbEntryGridEvents, regionid, gridId) )
    self.__curEntryGridId = nil
    self.__curEntryRegionId = nil
end

--- 事件完成时 
function ChessEvent:OnEventComplete(eventId)
    if not eventId or eventId == 0 then return end 
    
    self.__curEventCompleteId = eventId
    self:TryDoEvents( self:GetTableValue(self.tbEventCompleteEvents, eventId) )
    self.__curEventCompleteId = nil
    ChessTask:OnEventComplete(eventId)
end

--- 物件完成时 
function ChessEvent:OnObjectComplete(objectId)
    if not objectId or objectId == 0 then return end 
    
    self.__curObjectCompleteId = objectId
    self:TryDoEvents( self:GetTableValue(self.tbObjectCompleteObjects, objectId) )
    self.__curObjectCompleteId = nil
end

--- 物件显示时 
function ChessEvent:OnShowObject(tbTargetData)
    self.__curShowObject = tbTargetData
    local cfgData = tbTargetData.cfg.tbData
    local tbTag = cfgData and cfgData.tag
    local tbId = cfgData and cfgData.id
    local tbEvents = {}
    for _, tag in ipairs(tbTag or {}) do 
        local tbList = self.tbShowObjectByTagEvents[tag]
        add_to_table(tbEvents, tbList);
    end
    for _, id in ipairs(tbId or {}) do 
        local tbList = self.tbShowObjectByIdEvents[id]
        add_to_table(tbEvents, tbList);
    end
    self:TryDoEvents( tbEvents )
    self.__curShowObject = nil
    EventSystem.Trigger(Event.NotifyShowChessObject, tbTargetData)
end

--- 物件隐藏时
function ChessEvent:OnHideObject(tbTargetData)
    self.__curHideObject = tbTargetData
    local cfgData = tbTargetData.cfg.tbData
    local tbTag = cfgData and cfgData.tag
    local tbId = cfgData and cfgData.id
    local tbEvents = {}
    for _, tag in ipairs(tbTag or {}) do 
        local tbList = self.tbHideObjectByTagEvents[tag]
        add_to_table(tbEvents, tbList);
    end
    for _, id in ipairs(tbId or {}) do 
        local tbList = self.tbHideObjectByIdEvents[id]
        add_to_table(tbEvents, tbList);
    end
    self:TryDoEvents( tbEvents )
    self.__curHideObject = nil
    EventSystem.Trigger(Event.NotifyHideChessObject, tbTargetData)
end

--- 迷雾驱散时
function ChessEvent:OnFogDisappear(regionId, gridId)
    self.__curFogGridId = gridId
    self.__curRegionId = regionId
    self:TryDoEvents( self:GetTableValue(self.tbFogDisappearEvents, regionId, gridId) )
    self.__curFogGridId = nil;
    self.__curRegionId = nil
end

--- 当格子上出现某物件时
function ChessEvent:OnCheckGridObjectAppear(regionId, gridId, tbTargetData)
    self.__curAppearObj = tbTargetData
    self.__curCheckAppearRegionId = regionId
    self.__curCheckAppearGridId = gridId
    self:TryDoEvents( self:GetTableValue(self.tbCheckGridObjectAppearEvents, regionId, gridId) )
    self.__curAppearObj = nil
    self.__curCheckAppearRegionId = nil
    self.__curCheckAppearGridId = nil

    local tbGroundData = ChessRuntimeHandler:FindGroundDataByGridId({{regionId, gridId}})[1]
    ChessRuntimeHandler:ForeachObjectInGround(tbGroundData, function(tbObjectData)
        if tbObjectData.classHandler and tbObjectData.classHandler.OnObjectAppear then 
            tbObjectData.classHandler:OnObjectAppear(tbTargetData)
        end
    end)
end

--- 当格子上丢失某物件时
function ChessEvent:OnCheckGridObjectDisAppear(regionId, gridId, tbTargetData)
    self.__curDisAppearObj = tbTargetData
    self.__curCheckDisAppearRegionId = regionId
    self.__curCheckDisAppearGridId = gridId
    self:TryDoEvents( self:GetTableValue(self.tbCheckGridObjectDisAppearEvents, regionId, gridId) )
    self.__curDisAppearObj = nil
    self.__curCheckDisAppearRegionId = nil
    self.__curCheckDisAppearGridId = nil

    local tbGroundData = ChessRuntimeHandler:FindGroundDataByGridId({{regionId, gridId}})[1]
    ChessRuntimeHandler:ForeachObjectInGround(tbGroundData, function(tbObjectData)
        if tbObjectData.classHandler and tbObjectData.classHandler.OnObjectDisappear then 
            tbObjectData.classHandler:OnObjectDisappear(tbTargetData)
        end
    end)
end

--- 当互动时
function ChessEvent:OnInteraction(tbTargetData)
    self.__curInteractionObject = tbTargetData
    local cfgData = tbTargetData.cfg.tbData
    local tbTag = cfgData and cfgData.tag
    local tbId = cfgData and cfgData.id
    local tbEvents = {}
    for _, tag in ipairs(tbTag or {}) do 
        local tbList = self.tbInteractionByTagEvents[tag]
        add_to_table(tbEvents, tbList);
    end
    for _, id in ipairs(tbId or {}) do 
        local tbList = self.tbInteractionByIdEvents[id]
        add_to_table(tbEvents, tbList);
    end
    self:TryDoEvents( tbEvents )
    self.__curInteractionObject = nil

    if tbTargetData.classHandler and tbTargetData.classHandler.OnInteraction then 
        -- local id = tbTargetData.cfg.tbData.id
        -- if ChessData:GetObjectIsUsed(id[1]) == 1 then 
        --     print("已经被使用完毕");
        --     return
        -- end
        if tbTargetData.cfg.tbData and tbTargetData.cfg.tbData.classArg then 
            tbTargetData.classHandler:OnInteraction()
        end
    end
end

--- 从table中取值
function ChessEvent:GetTableValue(tb, key1, key2, key3)
    local tb1 = tb[key1];
    if key3 then 
        if not tb1 then return end 
        local tb2 = tb1[key2]
        return tb2 and tb2[key3] or {};
    end
    if key2 then 
        return tb1 and tb1[key2] or {};
    end
    return tb1 or {};
end

----------------------------------------------------------------------------------

ChessEvent:Init()

----------------------------------------------------------------------------------