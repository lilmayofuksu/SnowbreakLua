-- ========================================================
-- @File    : uw_chess_tpl_grid_reference.lua
-- @Brief   : 棋盘格子关联显示格子
-- ========================================================

local view = Class("UMG.SubWidget")


function view:SetData(tbData)
    WidgetUtils.Collapsed(self.IsObject)
    WidgetUtils.Collapsed(self.IsGrid)
    self.tbData = tbData
    self:SetType(tbData.type)
end

function view:SetType(Intype)
    if Intype == "IsGrid" then
        WidgetUtils.SelfHitTestInvisible(self.IsGrid)
    elseif Intype == "IsObject" then
        WidgetUtils.SelfHitTestInvisible(self.IsObject)
    end
end

return view