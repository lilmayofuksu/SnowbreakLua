-- ========================================================
-- @File    : uw_formation_roleitem.lua
-- @Brief   : 爬塔编队item
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.Button, function()
        if self.tbParam and self.tbParam.UpdateSelectPos then
            self.tbParam.UpdateSelectPos()
        end
    end)
    BtnAddEvent(self.ButtonCheck, function()
        if self.ShowCard then
            if self.tbParam and self.tbParam.FunCheck then
                self.tbParam.FunCheck()
            end
            UI.Open("Role", 2, self.ShowCard)
        end
    end)
end

function tbClass:UpdatePanel(tbParam)
    self.tbParam = tbParam

    self.nPos = self.tbParam.nPos
    self.nLineupIndex = self.tbParam.nLineupIndex

    self:UpdateCard()
end

function tbClass:UpdateCard()
    local pCard = Formation.GetCardByIndex(self.nLineupIndex, self.nPos - 1)
    if pCard then
        self.ShowCard = pCard
        WidgetUtils.Collapsed(self.Lock)
        WidgetUtils.SelfHitTestInvisible(self.Normal)
        SetTexture(self.Girl, pCard:Icon())
        local WeaponTemplateId = pCard:DefaultWeaponGPDL()
        SetTexture(self.ImgWeapon, Item.WeaponTypeIcon[WeaponTemplateId.Detail])
        SetTexture(self.ImgQuality, Item.RoleColor_short[pCard:Color()])
        self.TxtNum:SetText(pCard:EnhanceLevel())
        self.TxtName:SetText(Text(pCard:I18N() .. "_title"))
    else
        WidgetUtils.Collapsed(self.Normal)
        WidgetUtils.SelfHitTestInvisible(self.Lock)
    end
end

function tbClass:UpdateBGColor(bSelect)
    if self.tbParam then
        if self.tbParam.bSelectLineup == bSelect then
            return
        end
        self.tbParam.bSelectLineup = bSelect
    end

    if bSelect then
        Color.Set(self.BgNormal, {0.854993, 0.775822, 0.467784, 1})
        Color.Set(self.BgLock, {0.854993, 0.775822, 0.467784, 1})
    else
        Color.Set(self.BgNormal, {1, 1, 1, 1})
        Color.Set(self.BgLock, {1, 1, 1, 1})
    end
end

return tbClass
