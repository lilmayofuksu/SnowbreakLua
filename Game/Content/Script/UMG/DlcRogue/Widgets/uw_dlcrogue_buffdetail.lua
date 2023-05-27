-- ========================================================
-- @File    : uw_dlcrogue_buffdetail.lua
-- @Brief   : 肉鸽活动 buff
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data
    if not self.tbParam then return end

    self:UpdatePanel(self.tbParam.BuffInfo)
    self:SetSelect(self.tbParam.bSelect)
    pObj.Data.SetSelect = function (target, bSelect)
        self:SetSelect(bSelect)
    end
end

function tbClass:UpdatePanel(BuffInfo)
    self.BuffIcon:Show(BuffInfo.nIcon)
    self.TxtBuffName:SetText(Text(BuffInfo.sName or BuffInfo.sBuffName))
    self.TxtBuffDetail:SetText(Text(BuffInfo.sDesc, table.unpack(BuffInfo.tbBuffParamPerCount or {})))
end

function tbClass:SetSelect(bSelect)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.ImgSl)
    else
        WidgetUtils.Collapsed(self.ImgSl)
    end
end

return tbClass
