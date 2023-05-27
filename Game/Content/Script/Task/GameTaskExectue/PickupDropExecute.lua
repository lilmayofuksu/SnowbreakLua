-- ========================================================
-- @File    : PickupDropExecute.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================


---@class  PickupDropExecute: GameTask_Execute
local PickupDrop = Class()

PickupDrop.PickupNum = 0

function PickupDrop:OnActive()
    self.DropName = Text(self:GetDropName())
    self.HasPicked = {}
    self.PickupHook =
        EventSystem.On(
        Event.OnPickupDrop,
        function(InPlayerController,InDrop)
            local name = InDrop:GetName()
            if InDrop.TemplateID == self.DropID and not self.HasPicked[name] then 
                self.PickupNum = self.PickupNum + (self.UseRepresentNum and InDrop.RepresentNum or 1)
                self:Check()
                self:SetExecuteDescription()
                self.HasPicked[name] = true
            end
        end
    )
    self:SetExecuteDescription()
    TaskCommon.AddHandle(self.PickupHook)
end

function PickupDrop:GetDescription()
    if self:IsServer() then
        self.DescArgs:Clear()
        self.DescArgs:Add(self.PickupNum)
    elseif self:IsClient() then
        self.PickupNum = self.DescArgs:Get(1)
    end

    local Title = string.format(self:GetUIDescription(),self.DropName,self.PickupNum .. "/" .. self.Num)
    return Title
end

function PickupDrop:OnCountDown_Client()
    UI.Call("Fight", "UpdateTaskCountDown", self:GetCountDown(), self)
end

function PickupDrop:Check()
    if self.PickupNum >= self.Num then
        self:Finish()
    end
end

function PickupDrop:OnEnd()
    EventSystem.Remove(self.PickupHook)
end

function PickupDrop:OnEnd_Client()
    UI.Call("Fight", "HiddenTaskCountDown", self)
end
return PickupDrop