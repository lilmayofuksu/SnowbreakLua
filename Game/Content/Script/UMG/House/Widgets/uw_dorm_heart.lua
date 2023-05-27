-- ========================================================
-- @File    : uw_dorm_heart.lua
-- @Brief   : 宿舍门卡入住界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Display(Num)
    self.Txtnum:SetText(Num)
end

return tbClass