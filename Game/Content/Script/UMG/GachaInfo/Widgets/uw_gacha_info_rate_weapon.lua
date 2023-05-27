-- ========================================================
-- @File    : uw_gacha_info_rate_weapon.lua
-- @Brief   : 奖品图标展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")


function tbClass:Construct()
    BtnAddEvent(self.BtnClick, function()
        if self.pTemplate then
            UI.Open("ItemInfo", self.pTemplate.Genre, self.pTemplate.Detail, self.pTemplate.Particular, self.pTemplate.Level, 1)
        end
       
    end)
end

function tbClass:Display(tbParam)
    if not tbParam then return end

    local pTemplate = tbParam.pTemplate

    if not pTemplate then return end

    self.pTemplate = pTemplate

    local color = pTemplate.Color

    SetTexture(self.Icon, pTemplate.Icon)
    self.TxtName:SetText(Text(pTemplate.I18n))

    SetTexture(self.ImgQuality, Item.ItemIconColorIcon[color])

    local ColorStr = {[3] = '091FE3', [4] = '8624AC', [5] = 'D05309'}
    Color.SetColorFromHex(self.ImgQuality2, ColorStr[color])

    SetTexture(self.ImgType, Item.WeaponTypeIcon[pTemplate.Detail])

    if tbParam.nUPTag == 1 then
        WidgetUtils.HitTestInvisible(self.ImgUp)
    else
        WidgetUtils.Collapsed(self.ImgUp)
    end
end

function tbClass:OnListItemObjectSet(pObj)
    self:Display(pObj.Data)
end

return tbClass