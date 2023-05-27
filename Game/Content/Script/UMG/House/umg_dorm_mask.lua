local tbClass = Class("UMG.BaseWidget")

function tbClass:OnOpen()
    local Index = HouseGirlLove:GetRandomLoadingTexId()
    if Index then
        SetTexture(self.ImageBg,Index)
    end
	WidgetUtils.SelfHitTestInvisible(self.ImageBg)
end

function tbClass:SetMaskOpa()
    WidgetUtils.Collapsed(self.ImageBg)
    self.ImageBg:SetRenderOpacity(1.0)
    UI.Close('DormMask')
end

function tbClass:HideMask()
    if self.IsVisible and self:IsVisible() then
    	self:UnbindAllFromAnimationFinished(self.Enter)
        self:BindToAnimationEvent(self.Enter,
        { self, tbClass.SetMaskOpa},
        UE4.EWidgetAnimationEvent.Finished)
        self:PlayAnimation(self.Enter)
    	--WidgetUtils.Collapsed(self.ImageBg)
    else
        self:SetMaskOpa()
    end
end

return tbClass;