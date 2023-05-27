local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnReset2_3, function()
        if self.BtnFunc then
            self.BtnFunc() 
        end
    end)
end

function tbClass:OnDestruct()
    BtnClearEvent(self.BtnReset2_3)
end



function tbClass:Set(tbParam)
    local sName = Text(tbParam.sName)
    local key = tbParam.sName..'_Desc'
    local sDesc = Text(key)
    self.TxtGun_Basis:SetText(sName)
    self.BtnFunc = tbParam.pFunc

    if self.BtnFunc then
        WidgetUtils.Visible(self.BtnReset2_3)
    else
        WidgetUtils.Collapsed(self.BtnReset2_3)
    end

    if sDesc ~= key then
        self.TxtWarn:SetText(sDesc)
        WidgetUtils.SelfHitTestInvisible(self.TxtWarn)
    else
        WidgetUtils.Collapsed(self.TxtWarn)
    end
    WidgetUtils.SelfHitTestInvisible(self.TxtGun_Basis)
end

return tbClass