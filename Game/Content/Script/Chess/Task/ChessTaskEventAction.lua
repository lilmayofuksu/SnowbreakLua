----------------------------------------------------------------------------------
-- @File    : ChessTaskEventAction.lua
-- @Brief   : 任务事件行为 
----------------------------------------------------------------------------------

---@class ChessTaskEventAction 棋盘任务事件行为
ChessTaskEventAction = ChessTaskEventAction or {
    tbClasses = {},
}


----------------------------------------------------------------------------------
--- 得到所有行为名
function ChessTaskEventAction:GetAllConditionNames()
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
function ChessTaskEventAction:FindClassById(id)
    for _, tb in pairs(self.tbClasses) do 
        if tb.Id == id  then 
            return tb
        end
    end
end

--- 通过名字找条件配置
function ChessTaskEventAction:FindClassByName(name)
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

-- 注册行为
local _RegisterAction = function ( szType )
    _ClassIndex = _ClassIndex + 1
	local tbClass = {Id = szType, tbParam = {}, Name = "", Index = _ClassIndex};
	setmetatable(tbClass, { __index = tbBase});
	ChessTaskEventAction.tbClasses[szType] = tbClass;
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

    -- 设置行为参数
    function tbBase:SetParams(tbParam)
        self.tbParam = tbParam
        return self
    end

    -- 执行行为
    function tbBase:Run() end

    -- 行为是否执行完毕
    function tbBase:IsComplete() return true end

    -- 得到描述
    function tbBase:GetDesc(tbValue) return self.Name end
end

------------------------------------ None
do 
    local tbClass = _RegisterAction("None"):SetName("无")
    function tbClass:GetDesc() return "" end
end

------------------------------------ 等待一段时间
do 
    local tbClass = _RegisterAction("WaitSecond"):SetName("等待一段时间"):SetParams({
        {id = "second", desc = "秒", type = ChessTask.InputTypeText, hint = "要等待多少秒"}
    });

    function tbClass:Run()
    end
    function tbClass:GetDesc(tbValue) 
        return string.format("%s: %d秒", self.Name, tonumber(tbValue.second) or 0)
    end
end

------------------------------------ 添加物品
do 
    local tbClass = _RegisterAction("AddItem"):SetName("添加物品"):SetParams({
        {id = "itemId", desc = "物品Id", type = ChessTask.InputTypeItemId, hint = "要添加的物品Id"},
        {id = "count", desc = "物品数量", type = ChessTask.InputTypeText, hint = "要添加的物品数量，默认1"}
    });

    function tbClass:Run()
        local itemId = self.tbParam.itemId;
        local count = tonumber(self.tbParam.count) or 1
        ChessData:AddItemCount(itemId, count)
    end
    function tbClass:GetDesc(tbValue) 
        local itemId = tbValue.itemId;
        local count = tonumber(tbValue.count) or 1
        return string.format("%s: 【%s】* %d", self.Name, ChessEditor:GetItemNameDesc(itemId), count)
    end
end

------------------------------------ 移除物品
do 
    local tbClass = _RegisterAction("RemoveItem"):SetName("移除物品"):SetParams({
        {id = "itemId", desc = "物品Id", type = ChessTask.InputTypeItemId, hint = "要移除的物品Id"},
        {id = "count", desc = "物品数量", type = ChessTask.InputTypeText, hint = "要移除的物品数量，默认1"}
    });

    function tbClass:Run()
        local itemId = self.tbParam.itemId;
        local count = tonumber(self.tbParam.count) or 1
        ChessData:UseItem(itemId, count)
    end
    function tbClass:GetDesc(tbValue) 
        local itemDesc = ChessEditor:GetItemNameDesc(tbValue.itemId);
        itemDesc = itemDesc ~= "" and itemDesc or "??"
        local count = tonumber(tbValue.count) or 1
        return string.format("%s: 【%s】* %d", self.Name, itemDesc, count)
    end
end


------------------------------------ 修改任务变量
do 
    local tbClass = _RegisterAction("ModifyTaskVar"):SetName("修改任务变量"):SetParams({
        {id = "varId", desc = "变量id", type = ChessTask.InputTypeTaskVarId, hint = ""},
        {id = "type", desc = "修改类型", type = ChessTask.InputTypeModifyVar, hint = ""},
        {id = "value", desc = "修改值", type = ChessTask.InputTypeText, hint = ""},
    });

    function tbClass:Run()
        local varId = self.tbParam.varId
        local type = self.tbParam.type
        local value = tonumber(self.tbParam.value) or 0
        ChessTask:ApplyModifyTaskVar(varId, type, value)
    end

    function tbClass:GetDesc(tbValue) 
        local varDesc = ChessEditor:GetTaskVarDesc(tbValue.varId);
        varDesc = varDesc ~= "" and varDesc or "??"
        local value = tonumber(tbValue.value) or 0
        local type = tbValue.type
        local desc = "??"
        if type == 0 then 
            desc = "无操作"
        elseif type == 1 then 
            desc = "增加 " .. value
        elseif type == 2 then 
            desc = "减少 " .. value
        elseif type == 3 then 
            desc = "设置为 " .. value
        elseif type == 4 then 
            desc = "重置为初始值 "
        end
        return string.format("%s: %s %s", self.Name, varDesc, desc)
    end
end

------------------------------------ 设置地图已经完成
do 
    local tbClass = _RegisterAction("SetMapComplete"):SetName("设置地图已经完成");
    function tbClass:Run()
        ChessData:SetMapComplete(ChessData.mapId)
    end
end




----------------------------------------------------------------------------------