-- ========================================================
-- @File    : uw_gachainfo_list.lua
-- @Brief   : 抽奖记录展示
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnClick, function()
        if self.pObj and self.pObj.Data.fClick then
            self.pObj.Data.fClick(self.pObj)
        end
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    local data = pObj.Data
    if not data then return end

    self.pObj = pObj

    local sDes = Text(data.tbData.sName) or ''

    self.TxtName_1:SetText(sDes)
    self.TxtName:SetText(sDes)

    self:OnSelectChange(data.bSelect)

    pObj.pUI = self
end

function tbClass:OnSelectChange(bSelect)
    if bSelect then
        WidgetUtils.HitTestInvisible(self.PanelSelect)
    else
        WidgetUtils.Collapsed(self.PanelSelect)
    end
end

return tbClass