-- ========================================================
-- @File    : uw_dorm_roleitem.lua
-- @Brief   : 
-- @Author  :
-- @Date    :
-- ========================================================
local tbClass = Class("UMG.SubWidget")

----------------------------------------------------------------------------------
--- 门卡界面相关功能
----------------------------------------------------------------------------------
function tbClass:RoomDisplay(InParam)
    --- 因为需要做拖拽相关功能 所以需要把角色相关的信息传进来
    self.Data = InParam
    WidgetUtils.Collapsed(self.New)
    self.OnTorch = InParam.OnTorch
    if InParam.Template then
        SetTexture(self.ImgIcon, InParam.Template.Icon)
    end
    self:SetActive(true)

    self.Heart:Display(HouseGirlLove:GetGirlLoveLevel(InParam.GirlId))
end

function tbClass:SetActive(bCollapsed)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.Image_199, bCollapsed)
    WidgetUtils.SetCollapsedOrSelfHitTestInvisible(self.ImgIcon, bCollapsed)
end

-- function tbClass:OnRoleItemDropOver(InItem)
--     if not InItem.tbParam.RoomId or not self.tbParam.RoomId then
--         return
--     end
--     HouseBedroom.ExchangeRoomGirl(InItem.tbParam.RoomId, self.tbParam.RoomId, function()
--         EventSystem.TriggerTarget(HouseBedroom, "UpdateAll")
--     end)
-- end

-- function tbClass:OnRoomItemDropOver(InItem)
--     if not self.tbParam.RoomId or not InItem.Data.GirlItem then
--         return
--     end
--     HouseBedroom.GirlLiveIn(InItem.Data.GirlItem, self.tbParam.RoomId, function()
--         EventSystem.TriggerTarget(HouseBedroom, "UpdateAll")
--     end)
-- end

function tbClass:SetClickFunc(Func)
    self.ClickFunc = Func;
end

function tbClass:OnClick()
    Audio.PlaySounds(3005)
    if self.ClickFunc then
        self.ClickFunc()
    end
    if self.OnTorch then
        self.OnTorch(self.Data.GirlId)
    end
end

function tbClass:SetShowPlayer()
    WidgetUtils.Collapsed(self.Role)
    WidgetUtils.SelfHitTestInvisible(self.Location)
    WidgetUtils.Collapsed(self.GM)
end

function tbClass:SetShowNpc99()
    WidgetUtils.Collapsed(self.Role)
    WidgetUtils.SelfHitTestInvisible(self.GM)
    WidgetUtils.Collapsed(self.Location)
end

return tbClass