-- ========================================================
-- @File    : uw_dlcrogue_goods_role.lua
-- @Brief   : 肉鸽活动 商品 role item
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnCheck, function ()
        if not self.pCard then
            return
        end
        if self.pCard:IsTrial() then
            UI.Open("Role", 4, self.pCard, {self.pCard})
        else
            UI.Open("Role", 1, self.pCard, {self.pCard})
        end
    end)
end

function tbClass:Show(Card)
    if not Card then
        return
    end
    self.pCard = Card

    SetTexture(self.ImgIcon, Card:Icon())
    self.TxtLv:SetText(Card:EnhanceLevel())
    SetTexture(self.ImgQuality, Item.RoleColor3[Card:Color()])
    SetTexture(self.ImgType, Weapon.GetTypeIcon(Card:GetSlotWeapon()))
    if Card:Color()>=5 then
        SetTexture(self.Image_103, 1700120)
    else
        SetTexture(self.Image_103, 1700119)
    end

    if self.pCard:IsTrial() then
        WidgetUtils.HitTestInvisible(self.PanelTry)
    else
        WidgetUtils.Collapsed(self.PanelTry)
    end
end

return tbClass
