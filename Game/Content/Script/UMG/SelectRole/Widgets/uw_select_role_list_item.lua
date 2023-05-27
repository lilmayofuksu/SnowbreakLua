-- ========================================================
-- @File    : uw_change_role_list_item.lua
-- @Brief   : 面板角色选择条目
-- ========================================================
---@class tbClass : UUserWidget
local tbClass= Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Info.BtnClick, function() if self.tbInfo.fClick then self.tbInfo:fClick() end end)
end 

function tbClass:OnDestruct()
    EventSystem.Remove(self.nSelectEvent)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbInfo = pObj.Data
    if not self.tbInfo then return end
    if not self.tbInfo.pCard then
        self.Info:SetByCard(nil)
        return
    end
    self.Info:SetByCard(self.tbInfo.pCard)
    self.Info:SetOnSelected(self.tbInfo.bSet or false)
    ---选择事件
    EventSystem.Remove(self.nSelectEvent)
    self.nSelectEvent = EventSystem.OnTarget(self.tbInfo, "SET_SELECTED", function(_, bSelect)
        self.tbInfo.bSelect = bSelect
        self:SelectChange(bSelect)
    end )
    self:SelectChange(self.tbInfo.bSelect)
end

function tbClass:SelectChange(bSelect)
    self.Info:SetSelect(bSelect)
end

return tbClass