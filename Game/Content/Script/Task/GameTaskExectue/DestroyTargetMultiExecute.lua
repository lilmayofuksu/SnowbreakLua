-- ========================================================
-- @File    : DestroyTargetMulti.lua
-- @Brief   : 
-- ========================================================

local DestroyTargetMulti = Class()
DestroyTargetMulti.DestroyNum = 0

function DestroyTargetMulti:OnActive()
    self.tbAllTarget = {}
    local TaskActor = self:GetGameTaskActor()
    if TaskActor and self.Names:Length() < 1 then
        self.Names:Clear()
        for _,v in ipairs(ChallengeMgr.tbBarricade[TaskActor.AreaId] or {}) do
            self.Names:Add(v)
        end
    end
    if self.Names:Length() < 1 then 
        self:Finish()
        return
    end

    local AllTarget = self:GetTargets()
    self.Count = AllTarget:Length()
    if self.Count < 1 then
        self:Finish()
        return
    end
    

    self.tbAllTarget = {}
    for i=1,self.Count do
        table.insert(self.tbAllTarget, AllTarget:Get(i))
    end

    ---注册物体摧毁
    self.DestroyHook =
        EventSystem.On(
        "DestructibleOnDestroy",
        function(InObject)
            if InObject then
                --延迟执行  防止立即注册立即调用
                UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
                    {
                        self,
                        function()
                            self:OnDestroy(InObject)
                        end
                    },
                    0.01,
                    false
                )
            end
        end
    )

    TaskCommon.AddHandle(self.DestroyHook)
    self:Init()
    self:SetExecuteDescription()
end

function DestroyTargetMulti:Init()
    for i,v in ipairs(self.tbAllTarget) do
        v:OnClient_Init()
    end
end

function DestroyTargetMulti:OnDestroy(InObject)
    if not InObject then return end
    for i,v in ipairs(self.tbAllTarget) do
        if InObject == v then
            self.Count = self.Count - 1
            v:OnClient_Destroy()
        end
    end

    if self.Count < 1 then self:Finish() end
end

function DestroyTargetMulti:OnEnd()
    EventSystem.Remove(self.DestroyHook)
    for i,v in ipairs(self.tbAllTarget) do
        v:OnClient_Destroy()
    end
end

return DestroyTargetMulti
