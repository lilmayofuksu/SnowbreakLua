-- ========================================================
-- @File    : uw_shop_activity.lua
-- @Brief   : 商店界面-有banner的商品列表界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self:DoClearListItems(self.TileView)
    self.TileView:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    BtnAddEvent(self.BtnGo, function()
        if self.Data and self.Data.shopInfo then
            ShopLogic.GoToUI(self.Data.shopInfo)
        end
    end)
end

--商店入口
function tbClass:Init(Data)
    self.Data = Data

    local tbgoods = ShopLogic.Sort(self.Data.goodsList)
    self:DoClearListItems(self.TileView)
    for _, config in ipairs(tbgoods) do
        local pObj = self.Factory:Create(config)
        self.TileView:AddItem(pObj)
    end

    SetTexture(self.ImgBanner, tonumber(self.Data.shopInfo.sBannerImg) or self.Data.shopInfo.sBannerImg)
    if self.Data.shopInfo.nEnd > 0 then
        WidgetUtils.SelfHitTestInvisible(self.PanelTime)
        self.PanelTime:ShowNormal(self.Data.shopInfo.nEnd)
    else
        WidgetUtils.Collapsed(self.PanelTime)
    end
end

function tbClass:GetTimeDate(time)
    return os.date('%Y/%m/%d %H:%M', time)
end

--活动入口
function tbClass:OnOpen(tbParam)
    self.nActivityId = tbParam.nActivityId
    self.fRefreshFun = tbParam.fRefreshFun
    local tbActivity = Activity.GetActivityConfig(self.nActivityId)
    if not tbActivity then
        return
    end

    local tbShop = ShopLogic.GetShopInfo(tbActivity.tbCustomData[1] or 0)
    if tbShop then
        local tbShopInfo = ShopLogic.GetLocalGoodsList(tbActivity.tbCustomData[1] or 0, tbParam.bRefresh)
        if not tbShopInfo then return end

        local shop = ShopLogic.GetShopInfo(tbShopInfo.shopId)
        if not shop then return end

        local data = {shopId = tbShopInfo.shopId, goodsList = tbShopInfo.goodsList, shopInfo = shop}
        self:Init(data)
    end
    
    self:ShowActivityInfo(tbActivity)
    if self.fRefreshFun then
        self.fRefreshFun(tbActivity)
    end
end

--差异化
function tbClass:ShowActivityInfo(tbActivity)
    --背景图
    --SetTexture(self.ImgBanner, Resource.Get(tbTemplate.nBg), false)
    --Banner
    SetTexture(self.ImgBanner, tbActivity.nTitle)

    --说明

    --时间
    if tbActivity.nEndTime > 0 then
        WidgetUtils.SelfHitTestInvisible(self.PanelTime)
        self.PanelTime:ShowNormal(tbActivity.nEndTime)
    else
        WidgetUtils.Collapsed(self.PanelTime)
    end
end


return tbClass
