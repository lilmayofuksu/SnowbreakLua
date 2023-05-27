-- ========================================================
-- @File    : uw_widgets_common_title.lua
-- @Brief   : 通用导航栏
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.eventStack = self.eventStack or {}
    BtnAddEvent(self.BackBtn, function()
        local popEvent = self:Pop()
        if popEvent then popEvent() end

        UI.TryGCByObjectsCount()
    end)
    BtnAddEvent(self.ReturnMainBtn, function()
        if me:Id() > 0 and not me:IsOfflineLogin() then
            UI.OpenMainUI()
            UI.GC()
        else
            GoToLoginLevel()
        end
    end)
    table.insert(self.eventStack, 1, function() UI.CloseTop() end)
end

---设置自定义返回事件
function tbClass:SetCustomEvent(fBackEvent, fReturnEvent)
    if fBackEvent then
        self.eventStack = {}
        table.insert(self.eventStack, fBackEvent)
    end

    if fReturnEvent then
        BtnClearEvent(self.ReturnMainBtn)
        BtnAddEvent(self.ReturnMainBtn, fReturnEvent)
    end
end

---压入一个返回事件
function tbClass:Push(fEvent)
    self.eventStack = self.eventStack or {}
    table.insert(self.eventStack, fEvent)
end

---弹出一个返回事件
function tbClass:Pop()
    if #self.eventStack > 0 then
        return table.remove(self.eventStack, #self.eventStack)
    end
end

---清除压入的事件
function tbClass:ClearPushEvent()
    if self.eventStack and #self.eventStack > 1 then
        local copy = self.eventStack[1]
        self.eventStack = {}
        table.insert( self.eventStack, copy)
    end
end

return tbClass
