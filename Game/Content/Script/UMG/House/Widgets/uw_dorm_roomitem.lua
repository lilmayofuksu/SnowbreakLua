local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Button, function()
        if self.OnTorch and self.Data.GirlId then
            self:OnTorch()
        end
    end)
end

-- function tbClass:OnBtnClick()
--     if self.OnTorch and self.Data.GirlId then
--         self.OnTorch(self)
--     end
-- end


-- function tbClass:OnDropOver(InItem)
--     if not InItem.tbParam.GirlId or not InItem.tbParam.RoomId then
--         return
--     end
--     HouseBedroom.GirlLeaveRoom(InItem.tbParam.GirlId, InItem.tbParam.RoomId, function()
--         EventSystem.TriggerTarget(HouseBedroom, "UpdateAll")
--     end)
-- end

function tbClass:DisplayGirlItem(InParam)
    SetTexture(self.ImgIcon, InParam.Template.Icon)
    self.Heart:Display(InParam.Favor)
    self.OnTorch = InParam.OnTorch

    self:RemoveRegisterEvent(self.ClickEventHandle)
    self.ClickEventHandle = self:RegisterEventOnTarget(InParam.parent, InParam.GirlId, function()
        self:OnTorch()
    end)

    if InParam.RoomId and InParam.RoomId ~= 0 then
        WidgetUtils.Collapsed(self.Got)
        WidgetUtils.SelfHitTestInvisible(self.Lived)
        WidgetUtils.Collapsed(self.New)
    else
        WidgetUtils.Collapsed(self.Got)
        WidgetUtils.Collapsed(self.Lived)
        WidgetUtils.SelfHitTestInvisible(self.New)
    end

    if InParam.bInitSelect then
        self:OnTorch()
    end
end

function tbClass:OnSelect(IsSelected)
    if IsSelected then
        WidgetUtils.HitTestInvisible(self.Selected)
    else
        WidgetUtils.Collapsed(self.Selected)
    end
end

function tbClass:SetRoomGirl(InRoomId, InGirlId)
    if not InRoomId or not InGirlId or InGirlId == 0 then
        return
    end
    HouseStorage.SetBedroomGirlId(InRoomId, InGirlId)
end

function tbClass:OnListItemObjectSet(InParam)
    self.Data = InParam.Data
    if self.Data.bRoomWiget then
        self:DisplayGirlItem(self.Data)
        return
    end
    if not self.Data.FurnitureTmpId then
        return
    end
    local GirlId = self.Data.GirlId
    local AreaId = self.Data.AreaId
    if GirlId then
        local FurnitureTmpId = self.Data.FurnitureTmpId
        local Favor = HouseGirlLove:GetGirlLoveLevel(GirlId, HouseStorage.EGirlAttr.Favor)
        local HasFurniture = HouseFurniture.CheckFurnitureById(GirlId, FurnitureTmpId, 1)
        local Template = UE4.UItem.FindTemplate(1, GirlId, 1, 1)
        if HasFurniture then
            WidgetUtils.SelfHitTestInvisible(self.Got)
        else
            WidgetUtils.Collapsed(self.Got)
        end
        WidgetUtils.SelfHitTestInvisible(self.Heart)
        self.Heart:Display(Favor)
        SetTexture(self.ImgIcon, Template.Icon)
    end
    if AreaId then
        WidgetUtils.Collapsed(self.Heart)
        local HasFurniture = HouseFurniture.CheckFurnitureById(AreaId, FurnitureTmpId, 1)
        if HasFurniture then
            WidgetUtils.SelfHitTestInvisible(self.Got)
        else
            WidgetUtils.Collapsed(self.Got)
        end
        SetTexture(self.ImgIcon, HouseLogic:GetAreaIcon(AreaId))
    end
    WidgetUtils.Collapsed(self.New)
end

function tbClass:DisplayByGirlId(GirlId)
    local Favor = HouseGirlLove:GetGirlLoveLevel(GirlId)
    local HasFurniture = false
    local Template = UE4.UItem.FindTemplate(1, GirlId, 1, 1)
    if HasFurniture then
        WidgetUtils.SelfHitTestInvisible(self.Got)
    else
        WidgetUtils.Collapsed(self.Got)
    end
    self.Heart:Display(Favor)
    SetTexture(self.ImgIcon, Template.Icon)
end

function tbClass:OnClose()
    self:RemoveRegisterEvent(self.ClickEventHandle)
end

return tbClass