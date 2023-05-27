-- ========================================================
-- @File    : uw_shop_ordinary.lua
-- @Brief   : 商店界面-没有banner的商品列表界面
-- ========================================================

local tbClass = Class("UMG.SubWidget")

tbClass.ExchangeShopID = 19 --碎片兑换按钮所在的商店编号

function tbClass:Construct()
    self.Factory = Model.Use(self)
    self.TileView:SetScrollbarVisibility(UE4.ESlateVisibility.Collapsed)
    self:DoClearListItems(self.TileView)

    BtnAddEvent(
        self.BtnInfo,
        function()
            UI.Open("ShopPieceTips")
        end
    )

    BtnAddEvent(
        self.BtnExchange,
        function()
            if self:CheckPieceConvert() then
                UI.Open("ShopPieceExchange")
            else
                UI.ShowTip("tip.PieceExchange_none")
            end
        end
    )
end

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

    if shopInfo.nWidgetType == 3 then
        return
    end

    if self.Data.shopId == self.ExchangeShopID then
        WidgetUtils.Visible(self.BtnExchange)
        WidgetUtils.Visible(self.BtnInfo)
    else
        WidgetUtils.Collapsed(self.BtnExchange)
        WidgetUtils.Collapsed(self.BtnInfo)
    end

    if self.Data.shopInfo.nWidgetType == 1 then
        --刷新次数
        local refreshInfo = ShopLogic.GetShopRefreshInfo(self.Data.shopId)
        if refreshInfo then
            WidgetUtils.Visible(self.HorizontalBox)
            WidgetUtils.Visible(self.BtnRefresh)
            self.refreshnum:SetText(refreshInfo.str)
            if refreshInfo.moneynum then
                WidgetUtils.HitTestInvisible(self.ImgCurrency_1)
                local moneyicon = Cash.GetMoneyInfo(refreshInfo.moneyid)
                if moneyicon then
                    SetTexture(self.ImgCurrency_1, moneyicon)
                end
                WidgetUtils.HitTestInvisible(self.moneyNum)
                self.moneyNum:SetText(refreshInfo.moneynum)
                self.RefreshText:SetText("TxtShopRefresh")
            else
                WidgetUtils.Collapsed(self.ImgCurrency_1)
                WidgetUtils.Collapsed(self.moneyNum)
                self.RefreshText:SetText("NumberDepletion")
            end
        else
            WidgetUtils.Hidden(self.HorizontalBox)
            WidgetUtils.Hidden(self.BtnRefresh)
            WidgetUtils.Hidden(self.ImgCurrency_1)
        end

        --倒计时刷新
        self.RefreshTime = ShopLogic.GetNextRefreshTime(self.Data.shopId)
        if self.RefreshTime > 0 then
            WidgetUtils.Visible(self.RefreshTimeBox)
            local seconds = math.ceil(self.RefreshTime - GetTime())
            local hour = math.floor(seconds / 3600)
            if hour >= 24 then  --天
                WidgetUtils.Visible(self.day)
                self.CountDown:SetText(math.ceil(seconds / 3600 / 24))
            else  --小时:分钟:秒
                WidgetUtils.Hidden(self.day)
                local min = math.floor((seconds % 3600) / 60)
                local sec = (seconds % 3600) % 60
                self.CountDown:SetText(string.format("%02d:%02d:%02d", hour, min, sec))
            end
        else
            WidgetUtils.Hidden(self.RefreshTimeBox)
        end

        if refreshInfo or self.RefreshTime > 0 then
            WidgetUtils.Visible(self.CanvasPanelTitle)
        else
            if self.Data.shopId == self.ExchangeShopID then
                WidgetUtils.Visible(self.CanvasPanelTitle)
                WidgetUtils.Collapsed(self.BtnRefresh)
                WidgetUtils.Collapsed(self.RefreshTimeBox)
                WidgetUtils.Collapsed(self.HorizontalBox)
            else
                WidgetUtils.Collapsed(self.CanvasPanelTitle)
            end
        end
        if self.BtnRefresh then
            self.BtnRefresh.OnClicked:Clear()
            self.BtnRefresh.OnClicked:Add(self, function()
                ShopLogic.UpdateShop(self.Data.shopId)
            end)
        end
    end
end

function tbClass:Tick(MyGeometry, InDeltaTime)
    if not self.RefreshTime or self.RefreshTime <= 0 then return end

    if not self.detime then self.detime = 0 end
    self.detime = self.detime + InDeltaTime
    if self.detime < 1 then return end
    self.detime = 0

    local seconds = math.ceil(self.RefreshTime - GetTime())
    if seconds > 0 then
        local hour = math.floor(seconds / 3600)
        if hour >= 24 then  --天
            return
        else  --小时:分钟:秒
            if self.day:GetVisibility() ~= UE4.ESlateVisibility.Hidden then
                WidgetUtils.Hidden(self.day)
            end
            local min = math.floor((seconds % 3600) / 60)
            local sec = math.floor(seconds % 3600 % 60)
            self.CountDown:SetText(string.format("%02d:%02d:%02d", hour, min, sec))
        end
    else
        self.RefreshTime = ShopLogic.GetNextRefreshTime(self.Data.shopId)
    end
end

function tbClass:CheckPieceConvert()
    local allCard = UE4.TArray(UE4.UCharacterCard)
    
    local tbConvertItems = {}

    me:GetCharacterCards(allCard)
    for i = 1, allCard:Length() do
        local pCard = allCard:Get(i)
        --满天启的获取其配置，找到碎片id
        if pCard:Break() >=4 then   --满天启==4
            local tbP = pCard:PiecesGDPLN()
            if me:GetItemCount(tbP:Get(1),tbP:Get(2),tbP:Get(3),tbP:Get(4)) > 0 then
                return true
            end
        end
    end

    return false
end

return tbClass
