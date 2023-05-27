-- ========================================================
-- @File    : uw_widgets_page_point.lua
-- @Brief   : 登录公告界面轮动
-- ========================================================

local RollPoint = Class("UMG.SubWidget")

function RollPoint:Construct()
    -- self.Point:SetIsChecked(false)
    self.Point.OnCheckStateChanged:Add(
        self,
        function()
            print('reserve')
        end
    )

end

--- 
function RollPoint:OnOpen(tbParam)
    self.Param = tbParam
    self.Point:SetIsChecked(self.Param.bState)
end

return RollPoint