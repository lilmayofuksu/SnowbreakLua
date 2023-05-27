local uw_fightonline_shop_allbuff = Class("UMG.SubWidget")

function uw_fightonline_shop_allbuff:OnDestruct()
	BtnRemoveEvent(self.BtnDetail)
    self.ListBuff.OnCustListViewScrolled:Remove(self, self.ScrollHandle)
end

function uw_fightonline_shop_allbuff:Construct()
	BtnRemoveEvent(self.BtnDetail)
	BtnAddEvent(self.BtnDetail,function ( ... )
        if not UI.IsOpen('FightOnlineAllBuff') then
            local pawn = self:GetOwningPlayerPawn()
            local buffList = pawn and pawn.RandomBufferes
            if buffList and buffList:Length() > 0 then
                UI.Open('FightOnlineAllBuff')
            else
                UI.ShowTip(Text('ui.TxtOnlineEvent11'))
            end
        end
    end)

    self.ScrollHandle = function (_,_)
        WidgetUtils.Collapsed(self.BuffTxt)
    end
    self.ListBuff.OnCustListViewScrolled:Add(self, self.ScrollHandle)
    self.tbCacheListView = self.tbCacheListView or {}
    self.tbCacheListView[self.ListBuff] = 1
	self.ListBuff:SetScrollbarVisibility(UE4.ESlateVisibility.Hidden)
end

return uw_fightonline_shop_allbuff;