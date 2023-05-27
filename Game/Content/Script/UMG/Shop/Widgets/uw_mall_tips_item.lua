-- ========================================================
-- @File    : uw_mall_tips.lua
-- @Brief   : 商城道具列表
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.ListFactory = Model.Use(self);
    self:DoClearListItems(self.ListContent)
end

--打开显示 商店打开
function tbClass:OnOpen(tbData, sText)
    if sText then
        self.RedirectTextBlock_93:SetText(Text(sText))
    else
        self.RedirectTextBlock_93:SetText("")
    end

    self:ShowItemList(tbData)
end

--tbData  TemplateInfo
function tbClass:ShowItemList(tbData)
    self:DoClearListItems(self.ListContent)
    if not tbData then 
        WidgetUtils.Collapsed(self.ListContent)
        return 
    end

    WidgetUtils.Visible(self.ListContent)

    for _, item in ipairs(tbData) do
        local cfg = {G = item[1], D = item[2], P = item[3], L = item[4], N = item[5] or 1}
        local pObj = self.ListFactory:Create(cfg)
        self.ListContent:AddItem(pObj)
    end
end

return tbClass;