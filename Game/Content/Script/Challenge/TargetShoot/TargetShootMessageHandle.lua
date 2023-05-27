-- ========================================================
-- @File    : TargetShootMessageHandle.lua
-- @Brief   : 打靶数据传输
-- ========================================================
TargetShootMsgHandle = TargetShootMsgHandle or {}

TargetShootMsgHandle.tbCallback = TargetShootMsgHandle.tbCallback or {}

-- @param Func string 调用函数名
-- @param FuncParam table 调用函数参数
function TargetShootMsgHandle.TargetShootMsgSender(tbParam, InCallback)
    if not tbParam or not tbParam.FuncName then
        return
    end

    if InCallback then
        TargetShootMsgHandle.tbCallback[tbParam.FuncName] = InCallback
    end
    me:CallGS("TargetShoot_C2SMsg", json.encode(tbParam))
end

s2c.Register("TargetShoot_S2CMsg", function(tbParam)
    if (not tbParam) or (not tbParam.FuncName)then
        return
    end
    local func = TargetShootMsgHandle.tbCallback[tbParam.FuncName] or TargetShootMsgHandle[tbParam.FuncName]
    if not func then
        return
    end
    func(tbParam)
end)

--- 注册回调事件
--- @param key string 回调的key值 一般是传进来的funcname
--- @param func function 回调
function TargetShootMsgHandle.RegisterCallback(key, func)
    TargetShootMsgHandle.tbCallback[key] = func
end