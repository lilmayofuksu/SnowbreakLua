-- ========================================================
-- @File    : uw_exhibition_list.lua
-- @Brief   : 玩家信息
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
end

function tbClass:OnListItemObjectSet(InObj)
    self.Obj = InObj
    InObj.pUI = self
    local tbData = InObj.Data

    self.TxtName:SetText(Text(tbData.sName))
    self.TxtNum:SetText(tbData.nData)
    SetTexture(self.ImgIcon, tbData.nIcon)
end

return tbClass
