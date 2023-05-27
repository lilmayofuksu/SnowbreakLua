-- ========================================================
-- @File    : uw_widgets_weapon01.lua
-- @Brief   : 武器属性样式
-- ========================================================

local tbClass = Class("UMG.SubWidget")

---@param nNum number
---@param nAdd number
function tbClass:SetData(sName, nIcon, nNum, nAdd)
    self.Text_Cate:Settext(sName)
    self.TxtNum:SetText(nNum or 1)
    if nAdd then
        WidgetUtils.HitTestInvisible(self.PanelAdd)
        self.TxtAddNum:SetText(nAdd)
    else
        WidgetUtils.Collapsed(self.PanelAdd)
    end

    SetTexture(self.ImgType, nIcon)
end

--宿舍属性提升用
function tbClass:OnListItemObjectSet(pObj)
    self.tbParam = pObj.Data
    if self.tbParam then
        WidgetUtils.Collapsed(self.TxtNum)
        WidgetUtils.Collapsed(self.Image_83)
        self.TxtAddNum:SetText('+'..tostring(self.tbParam.Data))
        self.Text_Cate:SetText(Text('ui.'..string.lower(self.tbParam.Cate)))
    end
end

return tbClass