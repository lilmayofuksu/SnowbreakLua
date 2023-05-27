-- ========================================================
-- @File    : umg_common_arms_unlocktips.lua
-- @Brief   : 武器最大等级配件解锁提示界面
-- ========================================================
---@class tbClass UUserWidget
---@field ListArmsLevelAtt UListView
local tbClass = Class("UMG.BaseWidget")

function tbClass:OnInit()
   BtnAddEvent(self.bg.BtnClose, function()  UI.Close(self) end)
   
   self.ListArmsLevelAtt:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
   self.AttrListFactory = Model.Use(self)
end

function tbClass:OnOpen(partInfo)
    if not partInfo then return end
    local g, d, p, l = table.unpack(partInfo)
    local partTemplate = UE4.UItemLibrary.GetItemTemplateByGDPL(g, d, p, l)
    SetTexture(self.Icon, partTemplate.Icon)

    ---属性显示
    self:DoClearListItems(self.ListArmsLevelAtt)
    local cfg = WeaponPart.GetPartConfigByGDPL(g, d, p, l)
    if not cfg then return end

    local tbAttr = WeaponPart.GetPartAttr(cfg)
    for k, v in pairs(tbAttr or {}) do
        local sAdd = WeaponPart.ConvertType(k, v)
        local tbParam = {sPreWord = Text("attribute." .. k), nNum = sAdd}
        local pObj = self.AttrListFactory:Create(tbParam)
        self.ListArmsLevelAtt:AddItem(pObj)
    end

    ---配件名称
    self.PartName:SetText(Text(partTemplate.I18N))
end

return tbClass