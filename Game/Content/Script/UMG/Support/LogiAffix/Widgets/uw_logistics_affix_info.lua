-- ========================================================
-- @File    : uw_logistics_affix_info.lua
-- @Brief   : 洗练界面信息展示
-- ========================================================



local  tbAffixInfo = Class("UMG.BaseWidget")

function tbAffixInfo:OnOpen(InParam)
    self.TxtIntro:SetText(Logistics.GetAffixShowName(InParam.TxtTitle, InParam.TxtCont))
    if InParam.nIndex == 2 then
        WidgetUtils.Collapsed(self.ImgNum01)
        WidgetUtils.HitTestInvisible(self.ImgNum02)
    else
        WidgetUtils.Collapsed(self.ImgNum02)
        WidgetUtils.HitTestInvisible(self.ImgNum01)
    end
end



return tbAffixInfo