-- ========================================================
-- @File    : uw_logistics_tips.lua
-- @Brief   : 角色后勤Tip
-- @Author  :
-- @Date    :
-- ========================================================

local uw_logistics_tips = Class("UMG.BaseWidget")
local LogiTip = uw_logistics_tips
LogiTip.Path = "UMG.Role.Widget.Logistics.uw_logistics_tips_item_data"
LogiTip.Index = 1

function LogiTip:Construct()
    self.RoleItem = Model.Use(self,self.Path)
end

function LogiTip:OnOpen()
    if self.ListInfo then
        self:DoClearListItems(self.ListInfo)
        local IsLogiCard = RoleCard.GetShowRole()
        if IsLogiCard:GetSlotItem(Logistics.SelectType) then
            self.Index = 2
        end
        for i = 1, self.Index do
            local tbParam = {
                Model=i,
                SlotNum=self.Index
            }
            local NewItem = self.RoleItem:Create(tbParam)
            self.ListInfo:AddItem(NewItem)
        end
    end
end

return LogiTip
