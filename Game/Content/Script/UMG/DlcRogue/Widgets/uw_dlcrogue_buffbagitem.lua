-- ========================================================
-- @File    : uw_dlcrogue_buffbagitem.lua
-- @Brief   :肉鸽buff背包item
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    BtnAddEvent(self.BtnCheck, function ()
        if self.FunClick then
            self.FunClick()
        end
    end)
end

function tbClass:OnListItemObjectSet(pObj)
    if not pObj or not pObj.Data then return end
    self.FunClick = pObj.Data.funClick

    function pObj.Data.SetSelect(Target, bSelect)
        pObj.Data.bSelect = bSelect
        self:SetSelect(bSelect)
    end

    self:UpdatePanel(pObj.Data.BuffInfo)
    self:SetSelect(pObj.Data.bSelect)
end

function tbClass:UpdatePanel(BuffInfo)
    SetTexture(self.ImgBuffIcon, BuffInfo.nIcon)
    self.TxtName:SetText(Text(BuffInfo.sName or BuffInfo.sBuffName))
end

function tbClass:SetSelect(bSelect)
    if bSelect then
        Color.Set(self.ImgBg, {0.205079, 0.964687, 0, 1})
        Color.Set(self.TxtName, {0.205079, 0.964687, 0, 1})
    else
        Color.Set(self.ImgBg, {1, 1, 1, 0.6})
        Color.Set(self.TxtName, {1, 1, 1, 0.6})
    end
end

return tbClass