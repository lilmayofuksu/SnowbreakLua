-- ========================================================
-- @File    : uw_achievement_list_dot.lua
-- @Brief   : 任务界面  活跃点数
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data
    if self.tbParam.nstate and self.tbParam.nstate >= 1 then
        WidgetUtils.Visible(self.Image)
    else
        WidgetUtils.Collapsed(self.Image)
    end
end

return tbClass