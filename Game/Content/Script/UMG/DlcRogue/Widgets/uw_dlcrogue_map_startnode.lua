-- ========================================================
-- @File    : uw_dlcrogue_map_node.lua
-- @Brief   : 肉鸽活动 map item
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:UpdateState(tbNode)
    for _, NodeInfo in pairs(tbNode) do
        if RogueLogic.GetBaseInfo().nCurNode==NodeInfo.nID then
            WidgetUtils.Collapsed(self.Completed1)
            WidgetUtils.HitTestInvisible(self.Lock1)
            WidgetUtils.Collapsed(self.ImgSl)
            --self:PlayAnimation(self.AllLoop, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
        else
            WidgetUtils.Collapsed(self.ImgSl)
            WidgetUtils.Collapsed(self.Lock1)
            WidgetUtils.HitTestInvisible(self.Completed1)
            --self:StopAnimation(self.AllLoop)
        end
        break
    end
end

return tbClass
