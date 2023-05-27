-- ========================================================
-- @File    : umg_common_clean_resultitem.lua
-- @Brief  : 扫荡结果item
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
end

function tbClass:OnDestruct()
end

function tbClass:DoShow(tbInfo)
    self.Factory = Model.Use(self)

    if tbInfo and tbInfo.nIdx then
        self.Num:SetText(string.format("%02d", tbInfo.nIdx))
    end

    self:DoClearListItems(self.ListItem)
    if tbInfo and tbInfo.tbAwards then
        for _, item in ipairs(tbInfo.tbAwards) do
            local cfg = {G = item[1], D = item[2], P = item[3], L = item[4], N = item[5], bGeted = state == 2}
            local pObj = self.Factory:Create(cfg)
            self.ListItem:AddItem(pObj)
        end
    end

end

return tbClass
