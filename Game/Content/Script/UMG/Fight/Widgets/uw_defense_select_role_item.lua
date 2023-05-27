local tbClass = Class("UMG.SubWidget")

function tbClass:Initialize()
	
end

function tbClass:OnListItemObjectSet(pObj)
	local tbParam = pObj and pObj.Data
	if not tbParam or not IsValid(tbParam.Char) then
		return
	end

	if tbParam.Index == tbParam.NowIndex() then
		WidgetUtils.SelfHitTestInvisible(self.RoleSelected)
	else
		WidgetUtils.Collapsed(self.RoleSelected)
	end

	local Weapon = tbParam.Char:GetWeapon()
	if IsValid(Weapon) then
		SetTexture(self.ImgWeapon2, Item.WeaponTypeIcon[Weapon:GetWeaponItem():Detail()])
	end

	self.TxtNum2:SetText(Text('ui.roleup')..tbParam.Char.Level)

	SetTexture(self.ImgRole,tbParam.Char:K2_GetPlayerMember():Icon())

	self.GirlName:SetText(Text(tbParam.Char:K2_GetPlayerMember():I18N()))

	BtnClearEvent(self.SelClick)
	BtnAddEvent(self.SelClick,function ()
		tbParam.ClickFunc(tbParam.Index)
	end)
end

return tbClass;