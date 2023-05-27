-- ========================================================
-- @File    : uw_widgets_skilltag.lua
-- @Brief   : 技能标签
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data
    if self.tbParam and self.tbParam.nID then
        self:Show(self.tbParam.nID)
    end
end

function tbClass:Show(ID)
    local taginfo = RoleCard.SkillTagData[ID]
    if taginfo then
        self.TxtType:SetText(Text(taginfo.sDes))
        Color.SetColorFromHex(self.Image, "#"..taginfo.sColor)
    end
end

return tbClass
