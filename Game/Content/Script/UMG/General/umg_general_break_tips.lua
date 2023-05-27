-- ========================================================
-- @File    : umg_general_break_tips.lua
-- @Brief   : 通用突破提示
-- ========================================================

local tbClass = Class("UMG.BaseWidget")
function tbClass:OnInit()
    self.mask.OnMouseButtonDownEvent:Bind(self, tbClass.DownFun)
    self.AttrItemFactory = Model.Use(self)
end

function tbClass:DownFun()
    if self.CloseCallBack then self.CloseCallBack() end
    UI.Close(self)
    return UE4.UWidgetBlueprintLibrary.Handled()
end

---@param tbInfo 变化的数据
---@param pItem UItem 升级的道具
---@param tbInfo table 变化的属性 {sDes = "攻击" , nAdd = 10 , nValue = 10 }
---@param pCallBack function 关闭回调
function tbClass:OnOpen(pItem, tbInfo, pCallBack)
    self.CloseCallBack = pCallBack

    ---显示等级
    self.TxtNowLevel:SetText(pItem:Break())
    self.TxtNewLevel:SetText(pItem:Break() + 1)

    ---显示变化的属性
    self:DoClearListItems(self.ListAttr)
    for _, info in ipairs(tbInfo) do
        local NewObj = self.AttrItemFactory:Create(info)
        self.ListAttr:AddItem(NewObj)
    end
end
return tbClass