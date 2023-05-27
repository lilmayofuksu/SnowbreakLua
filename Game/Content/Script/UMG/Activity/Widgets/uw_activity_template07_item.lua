-- ========================================================
-- @File    : uw_activity_template07_item.lua
-- @Brief   : 活动模板7  充值返还item
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
end

function tbClass:OnListItemObjectSet(pObj)
    local tbConfig = pObj.Data.tbConfig
    local nIndex = pObj.Data.nIndex or 0

    self:ShowLess(nIndex, tbConfig)
    self:ShowMid(nIndex, tbConfig)
    self:ShowHigh(nIndex, tbConfig)
end

--显示低等级
function tbClass:ShowLess(nIndex, tbConfig)
    nIndex = nIndex or 0
    if not tbConfig or nIndex ~= 1 then 
        WidgetUtils.Collapsed(self.HorizontalBox_511)
        return
    end
    WidgetUtils.SelfHitTestInvisible(self.HorizontalBox_511)
    self:SetNumData(self.TxtLogisAttr, self.TxtTotal, self.TxtTotal2, tbConfig)
end

--显示中等级
function tbClass:ShowMid(nIndex, tbConfig)
    if not tbConfig or nIndex ~= 2 then 
        WidgetUtils.Collapsed(self.HorizontalBox)
        return
    end
    WidgetUtils.SelfHitTestInvisible(self.HorizontalBox)
    self:SetNumData(self.TxtLogisAttr_1, self.TxtTotal_1, self.TxtTotal_3, tbConfig)
end

--显示高等级
function tbClass:ShowHigh(nIndex, tbConfig)
    if not tbConfig or nIndex ~= 3 then
        WidgetUtils.Collapsed(self.HorizontalBox_1)
        return
    end
    WidgetUtils.SelfHitTestInvisible(self.HorizontalBox_1)
    self:SetNumData(self.TxtLogisAttr_2, self.TxtTotal_2, nil, tbConfig)
end

--设置数据
function tbClass:SetNumData(pPanel1, pPanel2, pPanel3, tbConfig)
    if pPanel1 then
        if tbConfig.nNum == 0 and tbConfig.nMaxNum then
            pPanel1:SetText(string.format(Text("ui.RecharegeTxt1"), tbConfig.nMaxNum))
        elseif tbConfig.nMaxNum then
            pPanel1:SetText(string.format(Text("ui.RecharegeTxt2"), tbConfig.nNum, tbConfig.nMaxNum))
        else
            pPanel1:SetText(string.format(Text("ui.RecharegeTxt3"), tbConfig.nNum, tbConfig.nMaxNum))
        end
    end

    if pPanel2 and pPanel3 then
        pPanel2:SetText(string.format("%d%%", tbConfig.nMoney))
        pPanel3:SetText(string.format("%d%%", tbConfig.nGold))
    elseif pPanel2 then
        pPanel2:SetText(string.format("%d%%   %d%%", tbConfig.nMoney,  tbConfig.nGold))
    end
end

return tbClass
