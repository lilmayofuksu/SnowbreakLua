-- ========================================================
-- @File    : umg_logistics_culture.lua
-- @Brief   : 后勤养成属性界面
-- @Author  :
-- @Date    :
-- ========================================================

local tbAttrClass = Class("UMG.SubWidget")


function tbAttrClass:OnListItemObjectSet(InObj)
    self.tbParam = InObj.Date or InObj.Logic

    local AttrName = Text("ui.attack")
    local nAtt = 0
    if self.tbParam.Name then
        AttrName = self.tbParam.Name
    end

    if self.tbParam.nAttr and self.tbParam.nAttr >= 0 then
        nAtt = self.tbParam.nAttr
    end
    self.TxtAttr:SetText(AttrName)
    self.TxtAttrNum:SetText(nAtt)

end

return tbAttrClass