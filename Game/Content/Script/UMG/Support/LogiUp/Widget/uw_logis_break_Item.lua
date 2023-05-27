-- ========================================================
-- @File    : uw_logis_break_Item.lua
-- @Brief   : 后勤卡培养属性变化条目
-- @Author  :
-- @Date    :
-- ========================================================

local uw_logis_break_Item = Class("UMG.SubWidget")
local AttrItem = uw_logis_break_Item

AttrItem.OnChangeAttrHandle = "ON_CHANGEATTR_HANDLE"

function AttrItem:Construct()
    --- body()
end

function AttrItem:OnListItemObjectSet(InObj)
    if InObj == nil then
        return
    end
    local Item = InObj.Logic
    self:Set(Item.Name,Item.New,Item.Now)
    ---self:ListenChange(self.OnChangeAttrHandle)
end

--- 处理变化
AttrItem.OnChangeHandle = nil
---@param InHandle EventSystem 事件
function AttrItem:ListenChange(InHandle)
    self.OnChangeHandle =
        EventSystem.OnTarget(
        self.Item,
        InHandle,
        function(...)
            self:Set(...)
        end
    )
end

--- 刷新属性条目
---@param InName string 属性名
---@param InDelt integer 变化值
---@param InAttr integer 当前值
function AttrItem:Set(InName, InNew, InNow)
    self.TxtName:SetText(InName)
    self.TxtDelt:SetText(InNew)
    self.TxtAttr:SetText(InNow)
end

return AttrItem
