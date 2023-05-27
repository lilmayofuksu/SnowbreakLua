-- ========================================================
-- @File    : umg_common_armsbreach_tips.lua
-- @Brief   : 武器突破
-- ========================================================
---@class tbClass
---@field ListArmsBreach UListView
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
    BtnAddEvent(self.BtnClose, function()   UI.Close(self) end)
    self.ListFactory = Model.Use(self)
    self.ListArmsBreach:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
end

function tbClass:OnOpen(pWeapon, fClose)
    if not pWeapon then return end
    Audio.PlaySounds(3014)

    self.fClose = fClose
    self.pWeapon = pWeapon
    --SetTexture(self.Icon, pWeapon:Icon())
    WidgetUtils.Collapsed(self.Icon)

    ---显示突破信息
    ---星级显示
    local nStarNum = self.pWeapon:Break()
    local nAllNum = self.Star:GetChildrenCount()
    for i = 0, nAllNum - 1 do
        local pWidget = self.Star:GetChildAt(i)
        if i < nStarNum then
            WidgetUtils.HitTestInvisible(pWidget.ImgStar)
        else
            WidgetUtils.Collapsed(pWidget.ImgStar)
        end
    end

    self.TxtNum:SetText(Weapon.GetMaxLv(self.pWeapon, self.pWeapon:Break()))
    self.TxtAddNum:SetText(Weapon.GetMaxLv(self.pWeapon, self.pWeapon:Break() + 1))

    self:DoClearListItems(self.ListArmsBreach)

    local nNow, sSubType =  Weapon.GetSubAttr(self.pWeapon, self.pWeapon:EnhanceLevel(), self.pWeapon:Quality() - 1)
    local nNew, _ =  Weapon.GetSubAttr(self.pWeapon, self.pWeapon:EnhanceLevel(), self.pWeapon:Quality())
    
    local tbParam = { sName = Text(string.format("attribute.%s", sSubType)), nIcon = Resource.GetAttrPaint(sSubType), nNum = nNow, nAdd = nNew}
    local NewObj = self.ListFactory:Create(tbParam)
    self.ListArmsBreach:AddItem(NewObj)
end

function tbClass:OnClose()
    if self.fClose then
        self.fClose()
    end
end

return tbClass