-- ========================================================
-- @File    : MonsterArriveTo.lua
-- @Brief   : 敌人到达指定Tag的一个区域或多个区域
-- @Author  :
-- @Date    :
-- ========================================================

---@class MonsterArriveTo : GameTask_Execute
local MonsterArriveTo = Class()

MonsterArriveTo.FindBoxs = nil
MonsterArriveTo.CurrentNum = 0

function MonsterArriveTo:OnActive()
    self.CurrentNum = 0
    self.FindBoxs = self:GetBox()
    for i = 1, self.FindBoxs:Length() do
        self.FindBoxs:Get(i):DoActive(self)
    end
    self:SetExecuteDescription()
end

function MonsterArriveTo:OnActive_Client()
    --self:SetExecuteDescription()
end

function MonsterArriveTo:BeginOverlap()
    self.CurrentNum = self.CurrentNum + 1
    if self.CurrentNum >= self.MostNum then
        self:Fail()
        self:Reset()
    end
    self:SetExecuteDescription()
end

function MonsterArriveTo:OnFinish()
    self:Reset()
end

function MonsterArriveTo:Reset()
    if self.FindBoxs then
        for i = 1, self.FindBoxs:Length() do
            self.FindBoxs:Get(i):Reset()
        end
    end
    self.FindBoxs = nil
end

function MonsterArriveTo:GetDescription()
    if self:IsServer() then
        self.DescArgs:Clear()
        self.DescArgs:Add(self.CurrentNum)
        self.DescArgs:Add(self.MostNum)
    elseif self:IsClient() then
        self.CurrentNum = self.DescArgs:Get(1)
        self.MostNum = self.DescArgs:Get(2)
    end

    local Title = string.format(self:GetUIDescription(),self.CurrentNum.."/"..self.MostNum)
    return Title
end

function MonsterArriveTo:OnFail()
   
end

return MonsterArriveTo
