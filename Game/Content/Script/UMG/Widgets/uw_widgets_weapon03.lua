-- ========================================================
-- @File    : uw_widgets_weapon03.lua
-- @Brief   : 武器属性样式
-- ========================================================

local tbClass = Class("UMG.SubWidget")

---@param nNum number
---@param nAdd number
function tbClass:SetData(sName, nIcon, nNum, nAdd, IsPercent)
    self.Text_Cate:Settext(sName)
    if IsPercent then
        self.TxtNum:SetText(string.format("%s%%", nNum or 1))
    else
        self.TxtNum:SetText(nNum or 1)
    end
    if nAdd then
        WidgetUtils.HitTestInvisible(self.PanelAdd)
        if IsPercent then
            self.TxtAddNum:SetText(string.format("%s%%", nAdd or 1))
        else
            self.TxtAddNum:SetText(nAdd or 1)
        end
    else
        WidgetUtils.Collapsed(self.PanelAdd)
    end

    SetTexture(self.ImgIcon, nIcon)
end

function tbClass:OnListItemObjectSet(tbParam)
    local Data = tbParam.Data
    self:SetData(Data.sName, Data.nIcon, Data.nNum, Data.nAdd, Data.IsPercent)
end

return tbClass