----------------------------------------------------------------------------------
-- @File    : Designer.lua
-- @Brief   : 与游戏编辑器对接 
----------------------------------------------------------------------------------

---@class Designer 与编辑器对接
Designer = Designer or {tbFunc = {}}

----------------------------------------------------------------------------------
--- 消息分发
function Designer.Dispatch(msg)
    if not msg then return end
    local tb = Split(msg, ";")
    if (#tb < 2) then return end
    
    local moduleId = tb[1]
    local key = tb[2];
    local tbParam = {}
    for i = 3, #tb do 
        local v = tb[i];
        local pos = string.find(v, ":");
        if pos then 
            local key = string.sub(v, 0, pos - 1)
            local value = string.sub(v, pos + 1, -1)
            tbParam[key] = value
        end 
    end

    local func = Designer.tbFunc[key]
    if func then 
        local ret = func(tbParam)
        if ret and ret ~= "" then 
            return moduleId .. ";" .. ret
        end
    else 
        printf_e("[designer] can not find func name: %s", key)
    end
end
----------------------------------------------------------------------------------

function Designer.Register(name, func)
    Designer.tbFunc[name] = func
end

----------------------------------------------------------------------------------
--- 加载其他文件
require 'Designer.Cartoon.CartoonMgr'
----------------------------------------------------------------------------------