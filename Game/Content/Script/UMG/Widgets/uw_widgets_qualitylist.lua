-- ========================================================
-- @File    : uw_widgets_qualitylist.lua
-- @Brief   : 品质星级显示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Set(nColor)
    if not nColor or not self.ListRoleStar then return end

    self.Factory =  self.Factory or Model.Use(self)

    self:DoClearListItems(self.ListRoleStar)

    for i = 1, nColor do
        self.ListRoleStar:AddItem(self.Factory:Create({}))
    end

    self.ListRoleStar:PlayAnimation(0)
end


return tbClass