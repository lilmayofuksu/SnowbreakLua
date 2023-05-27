-- ========================================================
-- @File    : uw_information_list.lua
-- @Brief   : 后勤入口列表
-- @Author  :
-- @Date    :
-- ========================================================

local  tbLogic = Class("UMG.SubWidget")

function tbLogic:Construct()
    -- print('ffffffffff')
end


function tbLogic:OnSlot(InOn)
    WidgetUtils.Hidden (self.On)
    WidgetUtils.Hidden(self.Off)
    if InOn then
        WidgetUtils.SelfHitTestInvisible (self.On)
    else
        WidgetUtils.SelfHitTestInvisible (self.Off)
    end
    
end

function tbLogic:SetBrushIcon(InItem)
    local ResId=InItem:Icon()
    if InItem:Break()>=4 then
        SetTexture(self.logisticsSlot,ResId,false)
    else
        SetTexture(self.logisticsSlot,ResId,false)
    end
end


return tbLogic