-- ========================================================
-- @File    : house_message_handle.lua
-- @Brief   : 宿舍数据传输
-- ========================================================
HouseMessageHandle = HouseMessageHandle or {}

HouseMessageHandle.tbCallback = HouseMessageHandle.tbCallback or {}

-- @param Func string 调用函数名
-- @param FuncParam table 调用函数参数
function HouseMessageHandle.HouseMessageSender(tbParam, InCallback)
    if not tbParam or not tbParam.FuncName then
        return
    end

    if InCallback then
        HouseMessageHandle.tbCallback[tbParam.FuncName] = InCallback
    end
    me:CallGS("House_Request", json.encode(tbParam))
end

s2c.Register("House_Request", function(tbParam)
    if (not tbParam) or (not tbParam.FuncName)then
        return
    end
    local func = HouseMessageHandle.tbCallback[tbParam.FuncName] or HouseMessageHandle[tbParam.FuncName]
    if not func then
        return
    end
    func(tbParam)
end)

--- 注册回调事件
--- @param key string 回调的key值 一般是传进来的funcname
--- @param func function 回调
function HouseMessageHandle.RegisterCallback(key, func)
    HouseMessageHandle.tbCallback[key] = func
end

function HouseMessageHandle.GiveGiftToAreaSuccess(tbParam)
    HouseGiftLogic:OnGiveGiftSuccess(tbParam)
end

function HouseMessageHandle.ReadGirlLoveStorySuccess(tbParam)
    HouseGirlLove:ReadGirlLoveStorySuccess(tbParam)
end

function HouseMessageHandle.ExchangeGiftRsp(tbParam)
    --HouseGiftLogic:ExchangeGiftRsp(tbParam)
    local ui = UI.GetUI('DormPresent')
    if ui then
        ui:OnExChangeRsp(tbParam)
    end
end