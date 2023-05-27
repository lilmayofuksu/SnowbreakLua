-- ========================================================
-- @File    : uw_bprewarditem.lua
-- @Brief   : bp奖励物品
-- ========================================================
local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
end

function tbClass:OnListItemObjectSet(pObj)
    local tbParam = pObj.Data;

    if tbParam.bAdv then
          WidgetUtils.Collapsed(self.days)
          self.days:DoShow(tbParam.nLevel)
     else
          WidgetUtils.SelfHitTestInvisible(self.days)

          self.days:DoShow(tbParam.nLevel)
     end

    function tbParam.UpdateFlagShow()
        if tbParam.bNew and not tbParam.bLock then
            WidgetUtils.Visible(self.Red)
            if tbParam.bAdv then
                WidgetUtils.SelfHitTestInvisible(self.Senior)
                WidgetUtils.Collapsed(self.Normal)
            else
                WidgetUtils.SelfHitTestInvisible(self.Normal)
                WidgetUtils.Collapsed(self.Senior)
            end
        else
            WidgetUtils.Hidden(self.Red)
            WidgetUtils.Collapsed(self.Senior)
            WidgetUtils.Collapsed(self.Normal)
        end
    end
    tbParam.UpdateFlagShow()

    self.items:Display(tbParam)
end

return tbClass