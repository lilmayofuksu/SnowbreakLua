-- ========================================================
-- @File    : uw_achievement_list_num.lua
-- @Brief   : 任务界面  活跃点数
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data
    -- if self.tbParam.nstate and self.tbParam.nstate == 2 then
    --     WidgetUtils.Visible(self.PanelGet)
    -- else
    --     WidgetUtils.Collapsed(self.PanelGet)
    -- end
    if self.tbParam.nPoint then
        self.TextNum:SetText(self.tbParam.nPoint)
    end
end

return tbClass