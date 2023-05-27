-- ========================================================
-- @File    : uw_widgets_attribute02.lua
-- @Brief   : 属性说明文本2号样式
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
    -- Dump(pObj)
    self.Text_Cate:SetText(pObj.Logic.sCate)
    self.IText_Num:SetText(pObj.Logic.nData)
end


function tbClass:OnDisable(InData)
    self.Text_Cate:SetText(InData.nPower)
    self.IText_Num:SetText(InData.Distance.."*"..InData.Rate)
end



return tbClass