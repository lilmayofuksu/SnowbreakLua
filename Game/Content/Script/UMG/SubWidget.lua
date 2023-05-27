local SubWidget = {
    ---UObject引用 代理
    tbRefProxy = {}
}

---事件注册
---@param nEvent string
---@param fCallback function
function SubWidget:RegisterEvent(nEvent, fCallback)
    self.registerEvents = self.registerEvents or {}
    local eventHandel =
        EventSystem.On(
        nEvent,
        function(...)
            fCallback(...)
        end
    )
    table.insert(self.registerEvents, eventHandel)
    return eventHandel
end

---事件注册
---@param pTarget userdata 事件触发对象
---@param nEvent string
---@param fCallback function
function SubWidget:RegisterEventOnTarget(pTarget, sEvent, fCallback)
    self.registerEvents = self.registerEvents or {}
    local eventHandel =
        EventSystem.OnTarget(
        pTarget,
        sEvent,
        function(...)
            fCallback(...)
        end
    )
    table.insert(self.registerEvents, eventHandel)
    return eventHandel
end

---移除注册的事件
function SubWidget:RemoveRegisterEvent(InHandel)
    if not self.registerEvents then return end

    if InHandel then
        self.registerEvents[InHandel] = nil
        EventSystem.Remove(InHandel)
    else
        for _, nHandle in pairs(self.registerEvents or {}) do
            EventSystem.Remove(nHandle)
        end
        self.registerEvents = nil
    end
end

---清除 List Object
---@param pList UListView
function SubWidget:DoClearListItems(pList)
    if not pList then return end
    DestroyListObj(pList)
    pList:ClearListItems()
end

---加载obj
function SubWidget:LoadAssetFormPath(Path)
    if not Path then return nil end
    local obj = UE4.UGameAssetManager.GameLoadAssetFormPath(Path)
    if obj and UnLua and UnLua.Ref then
        table.insert(self.tbRefProxy,  UnLua.Ref(obj))
    end
    return obj
end

-- 这个函数不允许被继承
function SubWidget:Destruct()
    DestroyListObjInWidget(self)
    if not self then return end

    for i = 1, #self.tbRefProxy do
        self.tbRefProxy[i] = nil
    end

    if self.RemoveRegisterEvent then
        self:RemoveRegisterEvent()
    end
    if self.OnDestruct then
        self:OnDestruct()
    end
    DestroyUITable(self)
end

function SubWidget:OnDestruct()
    -- 如果有需要，请子类继承这个接口
end

return SubWidget
