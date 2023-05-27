-- ========================================================
-- @File    : BaseWidget.lua
-- @Brief   : 界面基类
-- ========================================================

---@class BaseWidget : ULuaWidget
---@field sName string
---@field tbParam table
---@field tbChild table
---@field registerEvents table
---@field __bOpen boolean
---@field pIndex number

local widget = {
    ---界面的名字 与配置表一致
    sName = nil,
    ---子窗口
    tbChild = {},
    --- 注册的事件
    registerEvents = nil,
    ---是否打开了
    __bOpen = false,
    ---打开索引
    pIndex = nil,
    ---子界面对应的父界面的索引
    pParentIndex = -1,
    ---层级
    pOrder = 0,

    ---打开方式
    nRuntimeOpenType = nil,

    __bInit = false,

    ---UObject引用 代理
    tbRefProxy = {}
}

-------------外部接口-----------------------------
-- 是否显示
function widget:IsOpen()
    return self.__bOpen
end

-------------子类继承------------------------------
--- 初始化
function widget:OnInit()
end
--- 打开
function widget:OnOpen(...)
end
--- 失效
function widget:OnDisable(...)
end
--- 关闭
function widget:OnClose()
end

---是否支持ESC退出
function widget:CanEsc()
    return true
end

function widget:OnChildOpen(child)

end

function widget:OnChildClose(child)

end

-------------子类继承结束---------------------------

---事件注册
---@param nEvent string
---@param fCallback function
function widget:RegisterEvent(nEvent, fCallback)
    self.registerEvents = self.registerEvents or {}
    table.insert(self.registerEvents, EventSystem.On(nEvent, function(...) if self:IsOpen() then fCallback(...) end end ))
end

---移除注册的事件
function widget:RemoveRegisterEvent()
    for _, nHandle in pairs(self.registerEvents or {}) do
        EventSystem.Remove(nHandle)
    end
    self.registerEvents = nil
end

---清除 List Object
---@param pList UListView
function widget:DoClearListItems(pList)
    if not pList then return end 
    DestroyListObj(pList)
    pList:ClearListItems()
    self.tbCacheListView = self.tbCacheListView or {}
    if not self.tbCacheListView[pList] then self.tbCacheListView[pList] = 1 end
end

---加载obj
function widget:LoadAssetFormPath(Path)
    if not Path then return nil end
    local obj = UE4.UGameAssetManager.GameLoadAssetFormPath(Path)
    if obj and UnLua and UnLua.Ref then
        table.insert(self.tbRefProxy,  UnLua.Ref(obj))
    end
    return obj
end

------------------UI管理器调用----------------------

function widget:DoInit()
    self.bIsFocusable = true
    self:OnInit()
end

--- 打开UI
function widget:DoOpen(...)
    self.__bOpen = true
    self:__InternalOpen()
    EventSystem.Trigger(Event.UIOpen, self)
    self:OnOpen(...)
end

--- 隐藏UI 暂停UI
function widget:DoDisable(...)
    self:CancelStreamingScene()

    for _, child in pairs(self.tbChild) do
        if child then
            child:DoDisable()
        end
    end
    if IsValid(self) then
        self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    self:OnDisable(...)
    self.__bOpen = false
end

--- 重新显示UI
function widget:DoActive()
    for _, child in pairs(self.tbChild) do
        if child then
            child:DoActive()
        end
    end
   self:DoOpen()
end

--- 关闭UI 播放退出动画（暂时无）
function widget:DoClose(pCallback)
    if not (DSAutoTestAgent.bOpenAutoAgent and DSAutoTestAgent.bRunNullRhi) then
        local uMGStreamingSubsystem = UE4.UUMGStreamingSubsystem.GetAssetStreamingSubsystem()
        if uMGStreamingSubsystem and uMGStreamingSubsystem.ReleaseStreaming then
            uMGStreamingSubsystem:ReleaseStreaming(self)
        end
    end

    self:CancelStreamingScene()

    for _, child in pairs(self.tbChild) do
        if child then
            UI.Close(child)
        end
    end
    self.__bOpen = false
    self.tbChild = {}
    EventSystem.Trigger(Event.UIClose, self.sName)
    SafeCall(function() self:OnClose() end)
    if pCallback then
        pCallback()
    end
    self:RemoveRegisterEvent()
   
    UE4.UUMGLibrary.ReleaseUMGResources(self)
    DestroyListObjInWidget(self)
    DestroyUITable(self)
    if IsValid(self) then
        self:RemoveFromParent()
    else
        print("widget:DoClose RemoveFromParent self is not IsValid!")
    end
end

--打开子界面
function widget:OpenChild(InChild, ...)
    if not InChild then
        error("Open child :  child is nil")
        return
    end
    InChild.pParentIndex = self.pIndex
    self.tbChild[InChild.pIndex] = InChild
    InChild:DoOpen(...)
    self:OnChildOpen(InChild)
end

---关闭子界面
function widget:CloseChild(InChild, pCallBack)
    local child = self.tbChild[InChild.pIndex]
    if not child then
        --print("Lua error Message: close child fail: " .. (self.sName or "nil"), debug.traceback())
        return
    end
    child:DoClose(pCallBack)
    self.tbChild[child.pIndex] = nil
    self:OnChildClose(child)
end

function widget:GetTopChild()
    local childIndex = -1
    for nIndex, _ in pairs(self.tbChild) do
        if childIndex < nIndex then childIndex = nIndex end
    end
    if childIndex == -1 then return nil end
    return self.tbChild[childIndex]
end

---关闭一个子UI
function widget:CloseTopChild()
    local pChild = self:GetTopChild()
    if pChild == nil then return false end
    UI.Close(pChild)
    return true
end

function widget:__InternalOpen()
    if self:IsInViewport() == false then
        if not (DSAutoTestAgent.bOpenAutoAgent and DSAutoTestAgent.bRunNullRhi) then
            self:AddToViewport(self.pOrder)
        end
    end

    if not self.__bInit then
        self:DoInit()
        self.__bInit = true
    end

    self:PlayOpenAnimation()
    self:PlayDefaultAnim()
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    UI.PlayMusic(self)
    if not self.DontFocus or not self:DontFocus() then 
        self:SetFocus()
    end
end

-- 这个函数不允许被继承
function widget:Destruct()
    -- 如果没有这个方法，肯定是出问题了
    if not self.RemoveRegisterEvent then return end

    for i = 1, #self.tbRefProxy do
        self.tbRefProxy[i] = nil
    end

    -- 如果是主UI
    if self.sName and self.pIndex then
        self:OnDestruct()
    else
        --print("Destruct aaaa", self.sName, self:GetName(), self.pIndex )
        DestroyListObjInWidget(self)
        self:RemoveRegisterEvent()
        self:OnDestruct()
        DestroyUITable(self)
        self:Destroy()
    end
end

function widget:OnDestruct()
    -- 如果有需要，请子类继承这个接口
end

-----------------UI管理器调用结束------------------------


---异步加载子部件
---@param tbWidgetPath table 子部件路劲
function widget:StreamingWidgets(tbWidgetPath)
    if not tbWidgetPath then return end

    local uMGStreamingSubsystem = UE4.UUMGStreamingSubsystem.GetAssetStreamingSubsystem()
    if not uMGStreamingSubsystem then return end

    for _, sPath in ipairs(tbWidgetPath) do
        uMGStreamingSubsystem:RequestStreaming(self, sPath)
    end
end

---预加载场景
function widget:StreamingScene(sType)
    self:CancelStreamingScene()
    self.__nStreamingSceneTimer = UE4.Timer.Add(1, function()
        self.__nStreamingSceneTimer = nil
        PreviewScene.PreloadScene(sType)
    end)
end

---取消场景Streaming
function widget:CancelStreamingScene()
    if self.__nStreamingSceneTimer then
        UE4.Timer.Cancel(self.__nStreamingSceneTimer)
        self.__nStreamingSceneTimer = nil
    end
end

return widget
