local tbClass = Class('UMG.BaseWidget')

tbClass.AttrPath = "UMG/Role/Widget/uw_role_attribute_data"

function tbClass:OnInit( ... )
	BtnAddEvent(self.BtnOk,function ( ... )
		UI.CloseByName('DormAttributeUp')
	end)
end

function tbClass:OnOpen(GirlId,Level)
	self.GirlId = GirlId or self.GirlId
	self.Level = Level or self.Level
	--local Level = HouseGirlLove:GetGirlLoveLevel(GirlId)
	local AttrItem = Model.Use(self)

	self:DoClearListItems(self.ListAtt)
	local tbAtt = HouseGirlLove:GetLoveAddAttTb(self.GirlId,self.Level)
	local tb = {}
	tb[UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", UE4.EAttributeType.Health)] = tbAtt.Health
	tb[UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", UE4.EAttributeType.Attack)] = tbAtt.Attack
	tb[UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", UE4.EAttributeType.Defence)] = tbAtt.Defence
	tb[UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", UE4.EAttributeType.Shield)] = tbAtt.Shield
	for k, v in pairs(tb) do
        local sCate = k--UE4.UUMGLibrary.GetEnumValueAsString("EAttributeType", value)
        local tbParam = {
            Cate = sCate, --self:InitRoleCate(Cate),
            ECate = sCate,
            Data = v, --ShowUnit(index),
            ShowBG = true
        }
        local NewAttrInfo = AttrItem:Create(tbParam)  -- NewObject(AttrItem, self, nil)
        self.ListAtt:AddItem(NewAttrInfo)
    end

    --local str = string.format(Text("house.LevelAttUp"),Level)
    --self.TxtTitle:SetText(str);
    self.TxtLevelNum:SetText(tostring(self.Level))

    HouseLogic:ShowMouseCursor(true)
end

function tbClass:OnClose( ... )
	HouseLogic:ShowMouseCursor(false)
end

return tbClass;