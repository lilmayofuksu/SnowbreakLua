-- ========================================================
-- @File    : uw_gacha_recorditem.lua
-- @Brief   : 抽奖记录列表
-- ========================================================

local tbClass = Class("UMG.SubWidget")


local tbQualityBG = {1700103, 1700104, 1700105, 1700106, 1700107, 1700108}

local function TypeName(tbGDPL)
    if tbGDPL[1] == UE4.EItemType.CharacterCard then
        return Text("ui.character")
    elseif tbGDPL[1] == UE4.EItemType.Weapon then
        return Text("ui.weapon")
    end
    return ''
end

function tbClass:OnListItemObjectSet(pObj)
    local tbRecord = pObj.Data
    local pTemplate = UE4.UItem.FindTemplate(table.unpack(tbRecord.tbGDPL))
    if tbRecord.tbGDPL[1] == UE4.EItemType.CharacterCard then
        self.TxtName:SetText(string.format("%s-%s", Text(pTemplate.I18N), Text(pTemplate.I18n .. "_title")))
    else
        self.TxtName:SetText(Text(pTemplate.I18N))
    end

    self.TxtType:SetText(TypeName(tbRecord.tbGDPL))

    local bEnglish = (Localization.GetCurrentLanguage() == 'en_US')

    local sData = bEnglish and os.date("%m-%d-%Y %H:%M", tbRecord.nTime) or os.date("%Y-%m-%d %H:%M", tbRecord.nTime)

    self.TxtTime:SetText(sData)

    SetTexture(self.ImgQuility1, tbQualityBG[pTemplate.Color])

    local tbColor2 = {'#227014FF', '#227014FF', '#091FE3FF', '#8624ACFF', '#D05309FF', '#DA0612FF'}
    Color.SetColorFromHex(self.ImgQuility2, tbColor2[pTemplate.Color])
    self.ImgQuility2:SetOpacity(0.3)
end

return tbClass
