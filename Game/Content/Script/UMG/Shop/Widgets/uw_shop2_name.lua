-- ========================================================
-- @File    : uw_shop2_name.lua
-- @Brief   : 商店2界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    
end

function tbClass:OnListItemObjectSet(pObj)
    local tbParam = pObj.Data;
    local shop = ShopLogic.GetShopInfo(tbParam.shopId)

    self.TxtBgFirst:SetText(Text(shop.sName))
    self.TxtBgFirst_1:SetText(Text(shop.sName))

    WidgetUtils.Collapsed(self.BgFirst)
end

return tbClass
