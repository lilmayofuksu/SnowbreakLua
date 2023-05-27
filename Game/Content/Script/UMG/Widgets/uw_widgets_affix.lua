

-- ========================================================
-- @File    : uw_widgets_affix.lua
-- @Brief   :词缀列表
-- @Author  :
-- @Date    :
-- ========================================================

local tbAffix = Class("UMG.SubWidget")

function tbAffix:Construct()
    -- body()
end

function tbAffix:OnListItemObjectSet(InParam)
    self.Param = InParam.Data
    self.TxtName:SetText(self.Param.sName)
    self.TxtIntro1:SetText(self.Param.Des1)
    self.TxtIntro1_1:SetText(self.Param.Des2)
    if self.Param.HasAffix3 then
        self.TxtIntro1_2:SetText(self.Param.Des3)
    else
        WidgetUtils.Collapsed(self.Content1_2)
        WidgetUtils.HitTestInvisible(self.Lock1_2)
        self.TxtRequire1_2:SetText(self.Param.Des3)
    end
end



return tbAffix