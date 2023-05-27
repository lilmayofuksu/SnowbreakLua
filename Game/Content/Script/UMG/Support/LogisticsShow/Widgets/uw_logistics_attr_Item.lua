-- ========================================================
-- @File    : uw_logistics_attr_Item.lua
-- @Brief   : 角色后勤属性列表
-- @Author  :
-- @Date    :
-- ========================================================

local  tbItem = Class("UMG.SubWidget")

function tbItem:Construct()
    -- body
end

function tbItem:OnListItemObjectSet(InObj)
    if InObj == nil or InObj.Logic == nil then
        return
    end
    local Item =InObj.Logic
    self:SetAttrInfo(Item.Name,Item.Now)
    self:AttrChange(Item.ESign)
end

function tbItem:SetAttrInfo(InName,InVal)
    self.TxtName:SetText(InName)
    self.TxtAttr:SetText(InVal)
end

--- 比较标志
---@param InType Enum AttrSign
function tbItem:AttrChange(InType)
   
    WidgetUtils.Hidden(self.ImgPlus)
    WidgetUtils.Hidden(self.ImgSub)
    if InType==AttrSign.AttrNone then
        return
    elseif InType==AttrSign.AttrPluse then
        WidgetUtils.SelfHitTestInvisible(self.ImgPlus)
        return
    elseif InType==AttrSign.AttrSub then
        WidgetUtils.SelfHitTestInvisible(self.ImgSub)

    end
end


return tbItem