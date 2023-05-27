-- ========================================================
-- @File    : uw_widgets_star_list.lua
-- @Brief   : 角色主要技能节点提示
-- @Author  :
-- @Date    :
-- ========================================================

local tbShowStar = Class("UMG.SubWidget")

function tbShowStar:Construct()
    --body()
end

function tbShowStar:OnShowStar(InStar)
    local nStar = self.PanelStar:GetChildrenCount()
    for i = 1, nStar do
        local pStar = self.PanelStar:GetChildAt(i)
        WidgetUtils.Hidden(pStar)
        if i<=InStar then
            WidgetUtils.SelfHitTestInvisible(pStar)
        end
    end
end

return tbShowStar