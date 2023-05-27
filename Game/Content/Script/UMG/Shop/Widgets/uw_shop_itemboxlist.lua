-- ========================================================
-- @File    : uw_shop_itemboxlist.lua
-- @Brief   : 商店(商城)界面- 礼包界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self.TileView:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.TileView)
end

--显示商店
function tbClass:Init(Data)
    local shopInfo = ShopLogic.GetShopInfo(Data.shopId)
    if not shopInfo then return end

    self.Data = Data

    local tbgoods = ShopLogic.Sort(self.Data.goodsList)
    self:DoClearListItems(self.TileView)
    for _, config in ipairs(tbgoods) do
        local pObj = self.Factory:Create(config)
        self.TileView:AddItem(pObj)
    end
    self:PlayAnimation(self.AllEnter)
end

--显示商城
function tbClass:ShowMallInfo(Data)
    local tbConfig = Data and Data.tbConfig
    if not tbConfig then return end

    if tbConfig.nPic and self.Bg then
        SetTexture(self.Bg, tbConfig.nPic)
    end

    local tbgoods = IBLogic.GetIBShowGoods(tbConfig.nShopId)
    self:DoClearListItems(self.TileView)
    local nGetIdx = 0
    for i, config in ipairs(tbgoods) do
        local tbData = {bMall = true, tbConfig = config}
        local pObj = self.Factory:Create(tbData)
        self.TileView:AddItem(pObj)

        if Data.nSelectGoodsId and Data.nSelectGoodsId == config.nGoodsId then
            nGetIdx = i
        end
    end

    --self:PlayAnimation(self.AllEnter)

    if nGetIdx == #tbgoods and nGetIdx > 1 then
        nGetIdx = nGetIdx -1
    end

    self.TileView:ScrollIndexIntoView(nGetIdx)
    self.TileView:PlayAnimation()
 
end


return tbClass
