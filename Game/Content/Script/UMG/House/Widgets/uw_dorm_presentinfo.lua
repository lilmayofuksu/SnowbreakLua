local tbClass = Class('UMG.SubWidget')

function tbClass:UpdateGift(tbGDPLN)
	if type(tbGDPLN) ~= 'table' or #tbGDPLN < 4 then
		return
	end
	if not self.Factory then
		self.Factory = Model.Use(self)
	end

	self:DoClearListItems(self.ListGirl)
	local Tmp = UE4.UItemLibrary.GetItemTemplateByGDPL(tbGDPLN[1],tbGDPLN[2],tbGDPLN[3],tbGDPLN[4])
	if not Tmp then return end
	local GiftId = Tmp.Param1;
	local GiftInfo = HouseGiftLogic:GetGiftInfo(GiftId)
	if GiftInfo then
		for i,v in ipairs(GiftInfo.supportTargets) do
			if HouseLogic:CheckIsGirl(v) then
				self.ListGirl:AddItem(self.Factory:Create({GirlId = v,FurnitureTmpId = GiftInfo.furnitureTmpId}))
			else
				self.ListGirl:AddItem(self.Factory:Create({AreaId = v,FurnitureTmpId = GiftInfo.furnitureTmpId}))
			end
		end

		self.TxtLoveNum:SetText('+'..GiftInfo.addLoveNum)
		self.TxtDesc:SetText(Text(Tmp.I18N..'_des'))
	end
end

return tbClass;