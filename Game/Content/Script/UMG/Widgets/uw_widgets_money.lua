-- ========================================================
-- @File    : uw_widgets_money.lua
-- @Brief   : 通用货币组件
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.ItemFactory = self.ItemFactory or Model.Use(self)
    self:DoClearListItems(self.TileMoney)
end

---初始化
---@param tbTypes table 显示的所有类型
---@param bShowAdd boolean 是否显示添加按钮（默认显示）
function tbClass:Init(tbTypes, bShowAdd)
    self.ItemFactory = self.ItemFactory or Model.Use(self)
    
    if bShowAdd ~= false then
        bShowAdd = true
    end
    self:DoClearListItems(self.TileMoney)
    for _, nType in ipairs(tbTypes) do
        local tbParam = {nType = nType, bShowAdd = bShowAdd}
        if nType == Cash.MoneyType_Gold then
            tbParam.bShowAdd = false
        end
        local NewObj = self.ItemFactory:Create(tbParam)
        self.TileMoney:AddItem(NewObj)
    end

    self.TileMoney:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

---清空
function tbClass:ClearAll()
    self:DoClearListItems(self.TileMoney)
end

return tbClass
