-- =======================================================
-- @File    : EventSystem.lua
-- @Brief   : 通用Lua层事件管理器
-- @Author  :
-- @Date    : 2020-04-23
-- =======================================================

--- 事件派发系统
--- @class EventSystem
--- @field tbEvents table 全局事件集合
--- @field tbTargets table 自定义对象事件集合
--- @field tbHandles table 记录指定Handles对应的事件类型
--- @field nAllocId number 用于递增生成事件ID
EventSystem = EventSystem or {
    tbEvents    = {},
    tbTargets   = {},
    tbHandles   = {},
    nAllocId    = 0,
};

------------------------- 通用接口 ------------------------

--- 删除一个事件
--- @param nHandleId number 注册成功返回的事件ID
function EventSystem.Remove(nHandleId)
    if not nHandleId then return end;

    local vEv = EventSystem.tbHandles[nHandleId];
    if not vEv then return end;

    if type(vEv) == 'string' then
        EventSystem.tbEvents[vEv][nHandleId] = nil;
    elseif vEv.p and vEv.s then
        local tbTargetEvents = EventSystem.tbTargets[vEv.p];
        if not tbTargetEvents then return end;

        local tbEvents = tbTargetEvents[vEv.s];
        if tbEvents then tbEvents[nHandleId] = nil end;
    end

    EventSystem.tbHandles[nHandleId] = nil;
end

--- 清除所有
function EventSystem.Reset()
    EventSystem.tbEvents    = {};
    EventSystem.tbTargets   = {};
    EventSystem.tbHandles   = {};
    EventSystem.nAllocId    = 0;
end

---------------------- 全局事件接口 -----------------------

--- 注册全局事件
--- @param emEvent number 注册事件类型，见Enums.lua中Event定义
--- @param fCallback function 回调，如果pTarget有值，将会以第一个参数传入回调
--- @param bOnce bool 选填，是否只执行一次，自动删除
--- @return number 返回用于删除的ID.
function EventSystem.On(emEvent, fCallback, bOnce)
    local nHandleId = EventSystem.nAllocId + 1;
    EventSystem.nAllocId = nHandleId;
    EventSystem.tbEvents[emEvent] = EventSystem.tbEvents[emEvent] or {};
    EventSystem.tbEvents[emEvent][nHandleId] = { f = fCallback, bOnce = bOnce };
    EventSystem.tbHandles[nHandleId] = emEvent;
    return nHandleId;
end

--- 触发全局事件(lua层和C++层)
--- @param emEvent number 触发事件的类型，见Enums.lua中Event定义
--- @vararg any @触发需要参数，如果关联了对象，对象为第一次参数
function EventSystem.TriggerToAll(emEvent, ...)
    EventSystem.Trigger(emEvent, ...)
    EventSystem.TriggerToCpp(emEvent, ...)
end

--- 触发全局事件(仅在lua层)
--- @param emEvent number 触发事件的类型，见Enums.lua中Event定义
--- @vararg any @触发需要参数，如果关联了对象，对象为第一次参数
function EventSystem.Trigger(emEvent, ...)
    local tbRemoved = {};
    local tbTODO = {}

    for nHandleId, tbInfo in pairs(EventSystem.tbEvents[emEvent] or {}) do
        table.insert(tbTODO, tbInfo.f)
        if tbInfo.bOnce then
            table.insert(tbRemoved, nHandleId);
        end
    end

    --登陆信息 优先处理函数
    if emEvent == "Logined" then
        ZoneTime.DoLogin()
    end

    for _, nHandleId in ipairs(tbRemoved) do
        EventSystem.tbEvents[emEvent][nHandleId] = nil;
        EventSystem.tbHandles[nHandleId] = nil;
    end

    for _, f in ipairs(tbTODO) do
        f(...)
    end
end

--- 触发全局事件(C++层)
--- @param emEvent number 触发事件的类型，见Enums.lua中Event定义
--- @vararg any @触发需要参数，如果关联了对象，对象为第一次参数
function EventSystem.TriggerToCpp(emEvent, ...)
    DispatchEventToCpp(emEvent, ...)
end

----------------------- 自定义事件接口 ---------------------------

--- 监听一个对象触发的事件
--- @param pTarget userdata 事件触发对象
--- @param sEvent string 自定义事件类型
--- @param fCallback function 事件回调，第一个参数为Target
function EventSystem.OnTarget(pTarget, sEvent, fCallback)
    local nHandleId = EventSystem.nAllocId + 1;
    EventSystem.nAllocId = nHandleId;
    EventSystem.tbTargets[pTarget] = EventSystem.tbTargets[pTarget] or {};
    EventSystem.tbTargets[pTarget][sEvent] = EventSystem.tbTargets[pTarget][sEvent] or {};
    EventSystem.tbTargets[pTarget][sEvent][nHandleId] = fCallback;
    EventSystem.tbHandles[nHandleId] = { p = pTarget, s = sEvent };
    return nHandleId;
end

--- 触发对象事件
--- @param pTarget userdata 事件触发者
--- @param sEvent string 自定义事件类型
--- @vararg any @触发事件传入的其他参数
function EventSystem.TriggerTarget(pTarget, sEvent, ...)
    local tbTargets = EventSystem.tbTargets[pTarget];
    if not tbTargets then return end;

    local tbEvents = tbTargets[sEvent];
    if not tbEvents then return end;

    for _, f in pairs(tbEvents) do f(pTarget, ...) end;
end

--- 删除绑定在对象上的所有事件
--- @param pTarget userdata 调用EventSystem.On时传入的pTarget
function EventSystem.RemoveAllByTarget(pTarget)
    for _1, tbHandles in pairs(EventSystem.tbTargets[pTarget] or {}) do
        for nHandleId, _2 in pairs(tbHandles) do
            EventSystem.tbHandles[nHandleId] = nil;
        end
    end

    EventSystem.tbTargets[pTarget] = nil;
end

--- 删除绑定在对象上指定eventName的所有事件
--- @param pTarget userdata 调用EventSystem.On时传入的pTarget
--- @param sEvent string 调用EventSystem.On时传入的sEvent
function EventSystem.RemoveAllByTargetName(pTarget, sEvent)
    if not EventSystem.tbTargets[pTarget] then return end
    local list = EventSystem.tbTargets[pTarget][sEvent];
    if not list then return end;
    for nHandleId, _ in pairs(list) do
        EventSystem.tbHandles[nHandleId] = nil;
    end
    EventSystem.tbTargets[pTarget][sEvent] = nil;
end

---输入监听内容
function EventSystem.Print(bTarget)
    if bTarget then
        print('==================Target Event===================')
        local GetName = function (pTarget)
            for key, value in pairs(_G) do
                if value == pTarget then
                    return key
                end
            end
            if pTarget.GetName then
                return pTarget:GetName()
            end
           return pTarget
        end
       for pTarget, tbEvent in pairs(EventSystem.tbTargets) do
            local sPrint = GetName(pTarget)
            for sName, tbHandles in pairs(tbEvent) do
                for _, fCallback in pairs(tbHandles) do
                    print('     ',sPrint , sName, fCallback)
                end
            end  
       end
       print('==================Target Event===================')
    else
        local GetIndex = function(nIndex)
            for key, value in pairs(Event) do
                if value == nIndex then
                    return key
                end
            end
            return nIndex
        end

        print('==================Event===================')
        for nID, tbHandles in pairs(EventSystem.tbEvents) do
            local sName = GetIndex(nID)
            for nHandle, tbInfo in pairs(tbHandles) do
                print('   ',sName, nID, nHandle, tbInfo.f)
            end
        end
        print('==================Event===================')
    end
end
