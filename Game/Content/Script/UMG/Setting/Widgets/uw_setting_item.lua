-- ========================================================
-- @File    : uw_setting_item.lua
-- @Brief   : 设置条目
-- @Author  :
-- @Date    :
-- ========================================================

---@class uw_setting_item : ULuaWidget 设置item
local uw_setting_item = Class("UMG.SubWidget")

local Item = uw_setting_item

Item.Data = nil

Item.Base = 100

function Item:Init(InData)
    self.Data = InData
    self.TypeText:SetText(self:GetDes(InData.K))
    self.Slide:SetValue(InData.V * self.Base)
    self.Slide.OnValueChanged:Add(self, Item.Change)
    self.Add.OnClicked:Add(
        self,
        function()
            self:AddNum(1)
        end
    )
    self.Sub.OnClicked:Add(
        self,
        function()
            self:AddNum(-1)
        end
    )
    self:Refresh()
end

function Item:GetDes(InType)
    if InType==UE4.ESensitivityType.Slide then
        return "滑屏灵敏度"
    elseif InType==UE4.ESensitivityType.AimFire then
        return "开镜开火灵敏度"
    elseif InType==UE4.ESensitivityType.Aim then
        return "开镜灵敏度"
    elseif InType==UE4.ESensitivityType.Fire then
        return "开火灵敏度"
    elseif InType==UE4.ESensitivityType.Skill then
        return "技能灵敏度"
    elseif InType==UE4.ESensitivityType.AccFactor then
        return "加速度系数"
    end
    return ""
end

function Item:AddNum(InNum)
    local Num = self.Slide:GetValue() + InNum
    self.Slide:SetValue(Num)
    self:Refresh()
end

function Item:Change(v)
    self.Data.V = self.Slide:GetValue() / self.Base
    self:Refresh()
end

function Item:Refresh()
    self.Data.V = self.Slide:GetValue() / self.Base
    self.Value:SetText(math.floor(self.Slide:GetValue() + 0.5))
end

function Item:Save()
    local  GamePersistentUser =  UE4.UGamePersistentUser.LoadPersistentUser()
    if not GamePersistentUser then return end
    GamePersistentUser:SaveSensitivityByType(self.Data.K,self.Data.V)
end

function Item:OnDestruct()
    self.Data = nil
end

return Item
