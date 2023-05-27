-- ========================================================
-- @File    : umg_common_fashiongain_tips.lua
-- @Brief   : 时装获取弹窗
-- ========================================================

local tbClass = Class("UMG.BaseWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnGoChange, function()
        if not self.Role or not self.pSkin then
            return
        end
        local tbParam = {
            CharacterTemplate = {Genre = 1, Detail = self.Role.Detail, Particular = self.Role.Particular, Level = 1},
            SkinIndex = self.pSkin:Level(),
        }   
        UI.Close(self)
        UI.Open("RoleFashion", tbParam, function() Fashion.TryPopGainTips() end)
    end)

    BtnAddEvent(self.BtnClose, function()
        UI.Close(self)
        Fashion.TryPopGainTips()
    end)
end

function tbClass:OnOpen()
    local InSkin
    local tbItem = Fashion.tbGainSkins[1]
    table.remove(Fashion.tbGainSkins, 1)
    if tbItem[6] and tbItem[6] > 0 then
        InSkin = me:GetItem(tbItem[6])
    else
        InSkin = Fashion.GetSkinItem({tbItem.G, tbItem.D, tbItem.P, tbItem.L})
    end
    if not InSkin or not InSkin:IsCharacterSkin() then
        return
    end

    self.pSkin = InSkin
    self.Role = UE4.UItem.FindTemplate(1, InSkin:Detail(), InSkin:Particular(), 1)
    if self.Role then
        self:UpdateText()
    end
    if UI.GetTop().sName == "rolefashion" then
        WidgetUtils.Collapsed(self.BtnGoChange)
    else
        WidgetUtils.Visible(self.BtnGoChange)
    end
end

function tbClass:UpdateText()
    self.TxtName:SetText(Text(self.pSkin:I18N()))
    self.TxtGirlName:SetText(Text(self.Role.I18N))
    SetTexture(self.ImgFashion, self.pSkin:Icon())
end

return tbClass