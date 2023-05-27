-- ========================================================
-- @File    : uw_widgets_monster_info.lua
-- @Brief   : 通用怪物信息组件（含名字和等级）
-- ========================================================
local tbClass = Class("UMG.SubWidget")

tbClass.tbImgSize = {
    1701116,
    1701117,
    1701118,
    1701119,
}

tbClass.tbSizeBgColor = {
    '3662F2CC',
    'C069D6CC',
    'E99B36CC',
    'E99B36CC',
}

tbClass.tbImgAttribute = {
    1701113,
    1701115,
    1701114,
}

function tbClass:OnListItemObjectSet(InObj)
    if not InObj and InObj.Data then
       return
    end

    if InObj.Data then
        local nId = InObj.Data
        if type(InObj.Data) == 'table' then
            nId = InObj.Data.cfg.tbMonster[1]
            if InObj.Data.rikiState == RikiLogic.tbState.Lock then
                WidgetUtils.SelfHitTestInvisible(self.Lock)
            else
                WidgetUtils.Collapsed(self.Lock)
            end

            if InObj.Data.OnTouch then
                BtnClearEvent(self.Btn)
                BtnAddEvent(self.Btn, InObj.Data.OnTouch)
            end
        else
            WidgetUtils.Collapsed(self.Lock)
        end
        self:UpdateIcon(nId)
        self.TxtName:SetText(Localization.GetMonsterName(nId))
    end

    WidgetUtils.Collapsed(self.PanelLevel)
end

function tbClass:UpdateIcon(monsterId)
    local MonsterInfo = UE4.ULevelLibrary.GetCharacterTemplate(monsterId)
    if MonsterInfo then
        if MonsterInfo.ProfileID then
            SetTexture(self.Imgmonster, MonsterInfo.ProfileID)
        end

        -- if MonsterInfo.BounceValue and MonsterInfo.BounceValue == 1 then
        --     WidgetUtils.SelfHitTestInvisible(self.PanelSize)
        -- else
        --     WidgetUtils.Collapsed(self.PanelSize)
        -- end

        local _, nIcon2 = RikiLogic:GetMonsterTypeIcon(monsterId)
        if MonsterInfo.TriangleType then
            SetTexture(self.ImgAttribute, self.tbImgAttribute[MonsterInfo.TriangleType+1] or self.tbImgAttribute[1])
        end

        SetTexture(self.ImgSize, nIcon2)
    end
end
return tbClass