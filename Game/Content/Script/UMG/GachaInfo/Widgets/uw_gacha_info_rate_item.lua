-- ========================================================
-- @File    : uw_gacha_rateitem.lua
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
    local sName = string.format("%s-%s", Text(pTemplate.I18N), Text(pTemplate.I18n .. "_title"))
    self.TxtName:SetText(sName)

    SetTexture(self.ImgQuality, Item.ItemIconColorIcon[color])

    if tbParam.nUPTag == 1 then
        WidgetUtils.HitTestInvisible(self.ImgUp)
    else
        WidgetUtils.Collapsed(self.ImgUp)
    end

    local ColorStr = {
        [3] = '0003C4FF',
        [4] = '3D0469FF',
        [5] = 'A11600FF'
    }

    Color.SetColorFromHex(self.ImgQuality2, ColorStr[color])


    self.ListFactory = self.ListFactory or Model.Use(self)
    if self.ListRoleStar then
        self.ListRoleStar.bAutoPlay = false 
        local nStarNum = color
        self:DoClearListItems(self.ListRoleStar)
    
        for i = 1, nStarNum do
            local param = {}
            local pObj = self.ListFactory:Create(param)
            self.ListRoleStar:AddItem(pObj)
        end
    end
end


function tbClass:OnListItemObjectSet(pObj)

    self:Display(pObj.Data)

end

return tbClass