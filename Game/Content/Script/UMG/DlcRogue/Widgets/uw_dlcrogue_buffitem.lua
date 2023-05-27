-- ========================================================
-- @File    : uw_dlcrogue_buffitem.lua
-- @Brief   : 肉鸽活动 增益buffitem
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnCheck, function ()
        if self.FunClick then
            self.FunClick()
        end
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data.tbParam
    if not self.tbParam then return end

    self.FunClick = pObj.Data.funClick
    self.bShowText = pObj.Data.bShowText

    self.PanelBuffAll = pObj.Data.PanelBuffAll
    self.BuffTxt = pObj.Data.BuffTxt

    function pObj.Data.SetSelect(Target, bSelect)
        pObj.Data.bSelect = bSelect
        self:SetSelect(bSelect)
    end
    self:SetSelect(pObj.Data.bSelect, true)

    SetTexture(self.ImgBuffIcon, self.tbParam.nIcon)
end

function tbClass:SetSelect(bSelect, bHideText)
    if bSelect then
        if self.bShowText and not bHideText then
            self:ShowBuffTxt(true)
        end
        Color.Set(self.ImgBg, {0.205079, 0.964687, 0, 1})
    else
        if self.bShowText then
           self:ShowBuffTxt(false)
        end
        Color.Set(self.ImgBg, {1, 1, 1, 0.6})
    end
end

function tbClass:ShowBuffTxt(bShow)
    if self.BuffTxt then
        if bShow then
            WidgetUtils.SelfHitTestInvisible(self.BuffTxt)
            self.BuffTxt.TxtName:SetText(Text(self.tbParam.sName or self.tbParam.sBuffName))
            self.BuffTxt.TxtBuffDetail:SetContent(Text(self.tbParam.sSimpleDesc, table.unpack(self.tbParam.tbBuffParamPerCount or {})))
            if self.PanelBuffAll then
                local ret = UE4.UUMGLibrary.WidgetLocalToOtherWidgetLocal(self.BtnCheck, self.PanelBuffAll)
                self.BuffTxt:SetRenderTranslation(UE4.FVector2D(ret.X, 0))
            end
        else
            WidgetUtils.Collapsed(self.BuffTxt)
        end
    end
end

return tbClass
