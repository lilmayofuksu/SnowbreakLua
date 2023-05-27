-- ========================================================
-- @File    : uw_general_tips_list.lua
-- @Brief   : 属性显示条目
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(InObj)
    if InObj == nil or InObj.Data == nil then
        return
    end
    local Data = InObj.Data
    self.TxtDes:SetText(Data.sDes)
    self.TxtNow:SetText(Data.nValue)
    self.TxtAdd:SetText(Data.nAdd)
end

return tbClass