-- ========================================================
-- @File    : OpenTreasureBox.lua
-- @Brief   : 开宝箱
-- @Author  :
-- @Date    :
-- ========================================================

---@class OpenTreasureBox : TaskItem
local OpenTreasureBox = Class()

---当前打开宝箱数目
OpenTreasureBox.CurrentOpenNum = 0
---关注的箱子
OpenTreasureBox.Boxs = nil

function OpenTreasureBox:OnActive()
    self.CurrentOpenNum = 0
    self.Boxs = self:FindBoxsByTag()
    ---激活找到的
    for i = 1, self.Boxs:Length() do
        ---@param f TreasureBoxBase
        local f = self.Boxs:Get(i)
        if f.bCanInteract then
            f:DoActive(self)
        end
    end

    self:SetExecuteDescription()
end

function OpenTreasureBox:OnActive_Client()
    self.CurrentOpenNum = self.CurrentOpenNum or 0
    --self:SetExecuteDescription()
end

function OpenTreasureBox:OnCountDown_Client()
    UI.Call("Fight", "UpdateTaskCountDown", self:GetCountDown(), self)
end

---箱子打开时的通知
function OpenTreasureBox:BoxOpen()
    self.CurrentOpenNum = self.CurrentOpenNum + 1
    if self.CurrentOpenNum >= self.OpenBoxNum then
        self:Finish()
    end
    self:SetExecuteDescription()
end

function OpenTreasureBox:GetDescription()
    if self:IsServer() then
        self.DescArgs:Clear()
        self.DescArgs:Add(self.CurrentOpenNum)
        self.DescArgs:Add(self.OpenBoxNum)
    elseif self:IsClient() then
        self.CurrentOpenNum = self.DescArgs:Get(1)
        self.OpenBoxNum = self.DescArgs:Get(2)
    end

    return string.format(self:GetUIDescription(), self.CurrentOpenNum .. "/" .. self.OpenBoxNum)
end

function OpenTreasureBox:OnFinish()
    UI.Call("Fight", "HiddenTaskCountDown", self)
    if self.Boxs and self.ClearBoxOnEnd then
        for i = 1, self.Boxs:Length() do
            self.Boxs:Get(i):Clear()
        end
    end
    self.Boxs = nil
end

function OpenTreasureBox:OnEnd()
    if self.Boxs and self.ClearBoxOnEnd then
        for i = 1, self.Boxs:Length() do
            self.Boxs:Get(i):Clear()
        end
    end
    self.Boxs = nil
end

function OpenTreasureBox:OnEnd_Client()
    UI.Call("Fight", "HiddenTaskCountDown", self)
end

return OpenTreasureBox
