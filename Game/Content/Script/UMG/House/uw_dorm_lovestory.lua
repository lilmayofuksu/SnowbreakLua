local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
	--[[BtnAddEvent(self.BtnAttribute,function ( ... )
		UI.Open('DormAttribute',self.GirlId or 1)
	end)]]
	WidgetUtils.Collapsed(self.BtnAttribute)
end

function tbClass:OnOpen(GirlId)
	local BackEvent = function ( )
		UI.Close(self);
	end
	self.Title:SetCustomEvent(BackEvent,function ()
        GoToMainLevel()
    end)
    self.Title:SetShowExitBtn(false)
	if not GirlId then
		return 
	end
	self.GirlId = GirlId;
	self.SuitId = 1
	--Find Suit Girl Card:
	local GirlTArray = RoleCard.GetAllCharacter(2)
	for i = 1,#GirlTArray do
		local Tmp = GirlTArray[i]
		if Tmp.Particular == self.SuitId and Tmp.Detail == GirlId then
			local pTemplate = UE4.UItemLibrary.GetCharacterAtrributeForAppearID(Tmp.AppearID)
			if pTemplate then 
				WidgetUtils.SelfHitTestInvisible(self.Spine)
				local param = UE4.FSpineParameters()
				local scale,offset = HouseGirlLove:GetGirlSpineCfg(GirlId)
				param.Scale = scale;
				param.Offset = offset;
				if self.Spine and self.Spine.GetSpineDefaultAnimName then
					param.Animation = self.Spine:GetSpineDefaultAnimName(pTemplate.SpinResKey)
				end
				self.Spine:PlaySpine(pTemplate.SpinResKey,param)
			end
		end
	end

	self:DoClearListItems(self.ListStory)
	if not self.Factory then
		self.Factory = Model.Use(self)
	end
	local GirlStoryInfo = HouseGirlLove:GetGirlLoveStoryInfo(GirlId)
	if GirlStoryInfo then
		for i,v in ipairs(GirlStoryInfo) do
			if self['Story'..i] then
				self['Story'..i]:OnListItemObjectSet(self.Factory:Create(v))
			end
			--self.ListStory:AddItem(self.Factory:Create(v))
		end
	end
	--self.Girl:DisplayByGirlId(GirlId)
	local RoleTemplate
	if GirlId ~= 0 then
		RoleTemplate = UE4.UItem.FindTemplate(1, GirlId, 1, 1)
		self.TxtName:SetText(Text(RoleTemplate and RoleTemplate.I18N))
	end
	local Favor = HouseGirlLove:GetGirlLoveLevel(GirlId)
	self.TxtLv:SetText(Favor)
end

function tbClass:OnClose()
	
end

return tbClass;