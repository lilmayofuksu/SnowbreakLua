-- ========================================================
-- @File    : uw_riki_monster_item.lua
-- @Brief   : 图鉴怪物信息组件
-- ========================================================
local tbClass = Class("UMG.SubWidget")
tbClass.tbSizeBgColor = {
    '3662F2CC',
    'C069D6CC',
    'E99B36CC',
    'E99B36CC',
}

function tbClass:OnListItemObjectSet(InObj)
    if not InObj and InObj.Data then
       return
    end
    local tbData = InObj.Data
    self:UpdateIcon(tbData.cfg.tbMonster[1])
    local nIcon1, nIcon2 = RikiLogic:GetMonsterTypeIcon(tbData.cfg.tbMonster[1])
    WidgetUtils.SelfHitTestInvisible(self.ImgType1)
    WidgetUtils.SelfHitTestInvisible(self.ImgType2)
    SetTexture(self.ImgType1, nIcon1)
    SetTexture(self.ImgType2, nIcon2)

    -- local Color = UE4.UUMGLibrary.GetSlateColorFromHex(self.tbSizeBgColor[tbType[2]] or self.tbSizeBgColor[1])
    -- self.SizeBg:SetBrushTintColor(Color)
    self.Name:SetText(Text(tbData.cfg.Extension3))

    if tbData.OnTouch then
        BtnClearEvent(self.Button)
        BtnAddEvent(self.Button, tbData.OnTouch)
    end

    if tbData.rikiState == RikiLogic.tbState.Lock then
        WidgetUtils.Visible(self.Lock)
    else
        WidgetUtils.Collapsed(self.Lock)
    end
end

function tbClass:UpdateIcon(monsterId)
    if not monsterId then return end
    local MonsterInfo = UE4.ULevelLibrary.GetCharacterTemplate(monsterId)
    if MonsterInfo and MonsterInfo.ProfileID then
        SetTexture(self.Imgmonster, MonsterInfo.ProfileID)
    end
end

return tbClass