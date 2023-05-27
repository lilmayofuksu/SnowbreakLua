----------------------------------------------------------------------------------
-- @File    : ChessTaskCondition.lua
-- @Brief   : 任务条件
----------------------------------------------------------------------------------

---@class ChessTaskCondition 棋盘任务触发条件
ChessTaskCondition = ChessTaskCondition or {
    tbClasses = {},
}


----------------------------------------------------------------------------------
--- 得到所有条件名
function ChessTaskCondition:GetAllConditionNames()
    local tbList = {}
    for _, tb in pairs(self.tbClasses) do 
        table.insert(tbList, tb)
    end
    table.sort(tbList, function(a, b) return a.Index < b.Index end)

    local tbName = {}
    for _, tb in pairs(tbList) do 
        table.insert(tbName, tb.Name)
    end
    return tbName
end

--- 通过id找到条件配置
function ChessTaskCondition:FindClassById(id)
    for _, tb in pairs(self.tbClasses) do 
        if tb.Id == id  then 
            return tb
        end
    end
end

--- 通过名字找条件配置
function ChessTaskCondition:FindClassByName(name)
    for _, tb in pairs(self.tbClasses) do 
        if tb.Name == name then 
            return tb
        end
    end
end
----------------------------------------------------------------------------------
-- 基类
local tbBase = {}
local _ClassIndex = 0

-- 注册条件
local _RegisterCondition = function ( szType )
    _ClassIndex = _ClassIndex + 1
	local tbClass = {Id = szType, tbParam = {}, Name = "", Index = _ClassIndex};
	setmetatable(tbClass, { __index = tbBase});
	ChessTaskCondition.tbClasses[szType] = tbClass;
	return tbClass;
end

----------------------------------------------------------------------------------
-- 注册
do 
    -- 设置名字
    function tbBase:SetName(name)
        self.Name = name
        return self
    end

    -- 设置条件参数
    function tbBase:SetParams(tbParam)
        self.tbParam = tbParam
        return self
    end

    -- 检查是否条件满足
    function tbBase:OnCheck(tbParam) end

    -- 得到描述
    function tbBase:GetDesc(tbValue) return self.Name end

    -- 得到物件参数描述
    function tbBase:GetObjectParamDesc(id, tag) 
        local idDesc = ChessEditor:GetObjectIdDesc(id)
        local tagDesc = ChessEditor:GetObjectTagDesc(tag)
        if idDesc ~= "" and tagDesc ~= "" then 
            return string.format("id:%s tag:%s", idDesc, tagDesc)
        elseif idDesc ~= "" then
            return string.format("id:%s", idDesc)
        elseif tagDesc ~= "" then
            return string.format("tag:%s", tagDesc)
        else 
            return "物件:??"
        end
    end
end

------------------------------------ None
do 
    local tbClass = _RegisterCondition("None"):SetName("无")
    function tbClass:GetDesc() return "" end
end

------------------------------------ 当首次进入地图时
do 
    local tbClass = _RegisterCondition("OnInit"):SetName("当首次进入地图时")
    function tbClass:OnCheck(tbParam)
        return ChessTask.__isOnInit
    end
end

------------------------------------ 前置任务
do 
    local tbClass = _RegisterCondition("OnPreTaskId"):SetName("当前置任务完成时"):SetParams({
        {id = "preTaskId", desc = "任务id", type = ChessTask.InputTypeTaskId, hint = "任务id"}
    })

    function tbClass:OnCheck(tbParam)
        if not tbParam.preTaskId and type(classArg.plotId) ~= "table" then return false end
        local preTaskId = tbParam.preTaskId[1] 
        return ChessData:GetMapTaskIsComplete(preTaskId or 0)
    end

    function tbClass:GetDesc(tbValue) 
        return string.format("%s: %s", self.Name, ChessEditor:GetTaskDesc(tbValue.preTaskId))
    end
end


------------------------------------ 当事件执行完毕时
do 
    local tbClass = _RegisterCondition("EventComplete"):SetName("当事件执行完毕时"):SetParams({
        {id = "eventId", desc = "事件id", type = ChessTask.InputTypeEvent, hint = "哪个事件Id"}
    })
    function tbClass:OnCheck(tbParam)
        local tb = tbParam.eventId
        if not tb then return end
        return tb[1] == ChessTask.currentCompleteEventId
    end
    function tbClass:GetDesc(tbValue) 
        return string.format("%s: %s", self.Name, ChessEditor:GetObjectEventIdName(tbValue.eventId))
    end
end

------------------------------------ 当物件执行完毕时
do 
    local tbClass = _RegisterCondition("ObjectComplete"):SetName("当物件执行完毕时"):SetParams({
        {id = "objectId", desc = "物件id", type = ChessTask.InputTypeObjectId, hint = "哪个物件Id"}
    })
    function tbClass:OnCheck(tbParam)
        local tb = tbParam.objectId
        if not tb then return end
        return tb[1] == ChessTask.currentCompleteObjectId
    end
    function tbClass:GetDesc(tbValue) 
        return string.format("%s: %s", self.Name, ChessEditor:GetObjectIdDesc(tbValue.objectId))
    end
end

------------------------------------ 等待事件触发
do 
    local tbClass = _RegisterCondition("WaitEvent"):SetName("等待事件触发"):SetParams({
    })
    function tbClass:OnCheck(tbParam)
        return false
    end
    function tbClass:GetDesc(tbValue) 
        return self.Name
    end
end

----------------------------------------------------------------------------------