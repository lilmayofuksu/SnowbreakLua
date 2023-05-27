-- ========================================================
-- @File    : uw_bp_days_list.lua
-- @Brief   : bp通行证奖励的天数
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
end

function tbClass:OnListItemObjectSet(pObj)
    local tbParam = pObj.Data;
   
   self:DoShow(tbParam.nDay)
end

function tbClass:DoShow(nDay)
    nDay = nDay or 0
   
   if self.Txt then
        self.Txt:SetText(nDay)
   end
end

return tbClass