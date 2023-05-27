----------------------------------------------------------------------------------
-- @File    : ChessTaskCompleteCondition.lua
-- @Brief   : 任务完成条件
----------------------------------------------------------------------------------

---@class ChessTaskCompleteCondition 棋盘任务完成条件
ChessTaskCompleteCondition = ChessTaskCompleteCondition or {
    tbClasses = {},
}

--- 条件配置
ChessTaskCompleteCondition.tbConfig = 
{
    {id = 1, name = "变量等于固定值"},
    {id = 2, name = "变量大于固定值"},
    {id = 3, name = "变量小于固定值"},

    {id = 11, name = "变量等于最大值"},
    {id = 12, name = "变量等于最小值"},

    {id = 21, name = "变量A等于变量B"},
    {id = 22, name = "变量A大于变量B"},
    {id = 23, name = "变量A小于变量B"},
}


----------------------------------------------------------------------------------
--- 得到所有条件名
function ChessTaskCompleteCondition:GetAllConditionNames()
    local tbName = {}
    for _, tb in ipairs(self.tbConfig) do 
        table.insert(tbName, tb.name)
    end
    return tbName
end

--- 通过id找名字
function ChessTaskCompleteCondition:FindNameById(id)
    local cfg = self:FindCfgById(id)
    return cfg and cfg.name or ""
end

--- 通过名字找id
function ChessTaskCompleteCondition:FindIdByName(name)
    for _, tb in ipairs(self.tbConfig) do 
        if tb.name == name then 
            return tb.id
        end
    end
end

--- 通过id查找配置
function ChessTaskCompleteCondition:FindCfgById(id)
    for _, tb in ipairs(self.tbConfig) do 
        if tb.id == id then 
            return tb
        end
    end
end

--- 得到描述
function ChessTaskCompleteCondition:GetDesc(tbData)
    local cfg = self:FindCfgById(tbData.id);
    if not cfg then return "" end

    local varA = tbData.tbParam['a'] or 0
    local varB = tbData.tbParam['b'] or 0
    local defA = ChessConfigHandler:GetTaskVarById(varA)
    local defB = ChessConfigHandler:GetTaskVarById(varB)

    local getDesc1 = function(name)
        if defA then 
            return string.format("变量(%d - %s)%s固定值%d", defA.id, defA.name, name, varB);
        else 
            return string.format("变量( ?? )%s固定值%d", name, varB);
        end
    end

    local getDesc2 = function(varName, desc)
        if defA then 
            return string.format("变量(%d - %s)等于%s%s", defA.id, defA.name, desc, defA[varName]);
        else 
            return string.format("变量( ?? )等于%s??", desc);
        end
    end

    local getDesc3 = function(name)
        local descA = defA and string.format("%d - %s", defA.id, defA.name) or " ?? "
        local descB = defB and string.format("%d - %s", defB.id, defB.name) or " ?? "
        return string.format("变量(%s)%s变量(%s)", descA, name, descB);
    end

    if cfg.id == 1 then  return getDesc1("等于")
    elseif cfg.id == 2 then return getDesc1("大于")
    elseif cfg.id == 3 then return getDesc1("小于")
    elseif cfg.id == 11 then return getDesc2("max", "最大值")
    elseif cfg.id == 12 then return getDesc2("min", "最小值")
    elseif cfg.id == 21 then return getDesc3("等于")
    elseif cfg.id == 22 then return getDesc3("大于")
    elseif cfg.id == 23 then return getDesc3("小于")
    else return "" end
end

----------------------------------------------------------------------------------
--- 检查任务是否已经完成
function ChessTaskCompleteCondition:CheckIsComplete(tbTask)
    if #tbTask.tbTaskComplete == 0 then return false end

    for _, tb in ipairs(tbTask.tbTaskComplete) do 
        if not self:CheckTaskVar(tb.taskId, tb.type, tb.destValue) then 
            return false;
        end
    end
    return true;
end

function ChessTaskCompleteCondition:CheckTaskVar(taskId, checkType, chechValue)
    if not taskId then return end 

    local value = ChessData:GetMapTaskVar(taskId);
    if checkType == 1 then return value == chechValue end
    if checkType == 2 then return value > chechValue end
    if checkType == 3 then return value < chechValue end

    local varDef = ChessConfigHandler:GetTaskVarById(taskId);
    if checkType == 11 then return value == varDef.max end
    if checkType == 12 then return value == varDef.min end

    local varB = ChessData:GetMapTaskVar(chechValue);
    if checkType == 21 then return value == varB end
    if checkType == 22 then return value > varB end
    if checkType == 23 then return value < varB end
    return false
end

----------------------------------------------------------------------------------