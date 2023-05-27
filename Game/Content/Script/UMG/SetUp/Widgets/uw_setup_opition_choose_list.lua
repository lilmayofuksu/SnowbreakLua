-- ========================================================
-- @File    : uw_setup_opition_choose_list.lua
-- @Brief   : 
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    WidgetUtils.Collapsed(self.PanelList)
    local pFunc = function()
        if self.OnSelect then self.OnSelect() end
    end
    BtnAddEvent(self.ChooseBtn, pFunc)
    BtnAddEvent(self.ChooseBtn1, pFunc)
end

function tbClass:OnListItemObjectSet(pObj)
    local tbParam = pObj.Data
    local Txt = Text('setting.' .. tbParam.Value)
    self.Index = tbParam.Index
    if tbParam.IsImg then
        SetTexture(self.ImgLanguage, tonumber(tbParam.Value))
        SetTexture(self.ImgLanguage1, tonumber(tbParam.Value))
        WidgetUtils.Collapsed(self.TxtSwitch)
        WidgetUtils.Collapsed(self.TxtSwitch1)
        WidgetUtils.SelfHitTestInvisible(self.ImgLanguage)
        WidgetUtils.SelfHitTestInvisible(self.ImgLanguage1)
    else
        self.TxtSwitch:SetText(Txt)
        self.TxtSwitch1:SetText(Txt)
        WidgetUtils.SelfHitTestInvisible(self.TxtSwitch)
        WidgetUtils.SelfHitTestInvisible(self.TxtSwitch1)
        WidgetUtils.Collapsed(self.ImgLanguage)
        WidgetUtils.Collapsed(self.ImgLanguage1)
    end

    self.OnSelect = tbParam.pSelect

    tbParam.Check = function (nIndex, nSelected)
        if self.Index ~= nIndex then return end
        self:Check(nSelected)
    end
    self:Check(tbParam.Cur)
end

function tbClass:Check(Selected)
    if self.Index == Selected then
        WidgetUtils.Collapsed(self.PanelChoose)
        WidgetUtils.SelfHitTestInvisible(self.PanelNowCHoose)
    else
        WidgetUtils.Collapsed(self.PanelNowCHoose)
        WidgetUtils.SelfHitTestInvisible(self.PanelChoose)
    end
end

return tbClass