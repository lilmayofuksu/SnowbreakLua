-- ========================================================
-- @File    : uw_gacha_tap_reward_item.lua
-- @Brief   : 抽奖结果列表元素
-- ========================================================

local tbClass = Class("UMG.SubWidget")

local tbQualityBG = {1701036, 1701037, 1701038, 1701039, 1701040, 1701041}

local tbQualityBG2 = {1701042, 1701043, 1701044, 1701045, 1701046, 1701047}

local tbQualityPieceBG = {1701048, 1701049, 1701050, 1701051, 1701052, 1701053}


function tbClass:Construct()
    self.tbPanels = {
        {
            pInPanel = self.CharacterCard,
            Match = function(tbGDPL)
                return tbGDPL[1] == UE4.EItemType.CharacterCard
            end,
            Set = function(pTemplate, nCount, tbPiece)
                self:SetCharacterCard(pTemplate, nCount, tbPiece)
            end
        },
        {
            pInPanel = self.SupporterCard,
            Match = function(tbGDPL)
                return tbGDPL[1] == UE4.EItemType.SupporterCard
            end,
            Set = function(pTemplate)
                self:SetSupporterCard(pTemplate)
            end
        },
        {
            pInPanel = self.Weapon,
            Match = function(tbGDPL)
                return tbGDPL[1] == UE4.EItemType.Weapon
            end,
            Set = function(pTemplate)
                self:SetWeapon(pTemplate)
            end
        },
        {
            pInPanel = self.Piece,
            Match = function(tbGDPL)
                return tbGDPL[1] == UE4.EItemType.Suplies and tbGDPL[2] == 4
            end,
            Set = function(pTemplate, nCount, bPlayTansEffect)
                self:SetPiece(pTemplate, nCount, bPlayTansEffect)
            end
        },
        {
            pInPanel = self.Item,
            Match = function(tbGDPL)
                return tbGDPL[1] == UE4.EItemType.Useable or (tbGDPL[1] == UE4.EItemType.Suplies and tbGDPL[2] ~= 4)
            end,
            Set = function(pTemplate, nCount)
                self:SetItem(pTemplate, nCount)
            end
        }
    }
    
end

function tbClass:OnListItemObjectSet(pObj)
    local tbInfo = pObj.Data

    for _, tbPanel in ipairs(self.tbPanels) do
        if not tbPanel.Match(tbInfo.tbGDPL) then
            WidgetUtils.Hidden(tbPanel.pInPanel)
        else
            WidgetUtils.Visible(tbPanel.pInPanel)
            local pTemplate = UE4.UItem.FindTemplate(table.unpack(tbInfo.tbGDPL))
            tbPanel.Set(pTemplate, tbInfo.nCount, tbInfo.tbTransSame)
        end
    end
end

function tbClass:SetCharacterCard(pTemplate, nCount, tbPiece)
    local tbColorEffect = {1,2,3,4,5,6}
    PlayEffect(self.RarityRole, tbColorEffect[pTemplate.Color])
    SetTexture(self.ImgRole, pTemplate.Icon)
    SetTexture(self.ImgLogoRole, pTemplate.Icon)
    SetTexture(self.RarityRoleImg, tbQualityBG[pTemplate.Color or 1])
    WidgetUtils.Visible(self.BtnRoleInfo)
    BtnClearEvent(self.BtnRoleInfo)
    BtnAddEvent(self.BtnRoleInfo, function()
        UI.Open("ItemInfo", pTemplate.Genre, pTemplate.Detail, pTemplate.Particular, pTemplate.Level, nCount)
    end)

    local tbColor = {[3] = '091FE3', [4] = '8624AC', [5] = 'D05309'}

    local Color = UE4.UUMGLibrary.GetSlateColorFromHex(tbColor[pTemplate.Color] or '091FE3')
    self.ImgPieceQuality:SetColorAndOpacity(Color)

    if not tbPiece then
        return
    end

    ---碎片转换效果
    WidgetUtils.Collapsed(self.BtnRoleInfo)
    UE4.UKismetSystemLibrary.K2_SetTimerDelegate(
        {
            self,
            function()
                WidgetUtils.Collapsed(self.CharacterCard)
                WidgetUtils.Visible(self.Piece)
                local pTemplate = UE4.UItem.FindTemplate(tbPiece[1], tbPiece[2], tbPiece[3], tbPiece[4])
                self:SetPiece(pTemplate , tbPiece[5], true)
            end
        },
        self.DelayTime or 1,
        false
    )
end


function tbClass:SetWeapon(pTemplate)
    local tbColorEffect = {7, 8, 9, 10, 11, 12}
    local tbColor2Effect = {13, 14, 15, 16, 17, 18}
    PlayEffect(self.RarityWeapon, tbColorEffect[pTemplate.Color])
    PlayEffect(self.RarityWeapon2, tbColor2Effect[pTemplate.Color])
    
    SetTexture(self.Rarityweaponup, tbQualityBG2[pTemplate.Color])

    SetTexture(self.ImgWeapon, pTemplate.Icon)
    SetTexture(self.LogoWeapon, pTemplate.Icon)
    BtnClearEvent(self.BtnWeaponInfo)
    BtnAddEvent(self.BtnWeaponInfo, function()
        UI.Open("ItemInfo", pTemplate.Genre, pTemplate.Detail, pTemplate.Particular, pTemplate.Level, 1)
    end)

    SetTexture(self.TypeWeapon, Item.WeaponTypeIcon[pTemplate.Detail] or 0)
end

function tbClass:SetPiece(pTemplate, nCount, bPlayTansEffect)
    WidgetUtils.HitTestInvisible(self.RarityPiece)

    SetTexture(self.RarityPiece, tbQualityBG2[pTemplate.Color])

    SetTexture(self.ImgPiece, pTemplate.Icon)
    self.TxtNumPiece:SetText("x" .. nCount)
    SetTexture(self.ImgPieceEx, pTemplate.EXIcon)

    local tbColorEffect = {7, 8, 9, 10, 11, 12}
    PlayEffect(self.RarityPiece2, tbColorEffect[pTemplate.Color])

    WidgetUtils.HitTestInvisible(self.RarityPieceRole)
    SetTexture(self.RarityPieceRole, tbQualityPieceBG[pTemplate.Color or 1])

    if bPlayTansEffect == true then
        if pTemplate.Color == 5 then
            PlayEffect(self.Switch, 19)
            Audio.PlaySounds(3036)
        else
            PlayEffect(self.Switch, 26)
            Audio.PlaySounds(3037)
        end
    else
        WidgetUtils.Collapsed(self.Switch)
    end
    local pOriginalCardTemplate = Item.Piece2Character(pTemplate.Genre, pTemplate.Detail, pTemplate.Particular, pTemplate.Level)
    WidgetUtils.Visible(self.ImgLogoPiece)
    if pOriginalCardTemplate then
        SetTexture(self.ImgLogoPiece, pOriginalCardTemplate.Icon)
    end

    BtnClearEvent(self.BtnPieceInfo)
    BtnAddEvent(self.BtnPieceInfo, function()
        UI.Open("ItemInfo", pTemplate.Genre, pTemplate.Detail, pTemplate.Particular, pTemplate.Level, nCount)
    end)
end

function tbClass:SetSupporterCard(pTemplate)
end

function tbClass:SetItem(pTemplate, nCount)
end

return tbClass
